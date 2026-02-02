#!/bin/bash
# 通过 sqlcmd 恢复完整 + 差异 + 日志备份链
# 用法：./scripts/sql_restore.sh --full <full.bak> [--diff <diff.bak>] [--log <log.trn>]

set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONTAINER_NAME=${CONTAINER_NAME:-sqlserver2019}
DB_NAME=${DB_NAME:-School_Data}
SA_PASSWORD=${SA_PASSWORD:-YourStrong!Passw0rd123}
CONTAINER_BACKUP_DIR="/var/opt/mssql/data/backup"
SQLCMD=${SQLCMD_PATH:-/opt/mssql-tools18/bin/sqlcmd}
SQLCMD_OPTS="-S localhost -U sa -P \"$SA_PASSWORD\" -C"

FULL_BAK=""
DIFF_BAK=""
LOG_BAK=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --full)
      FULL_BAK=${2:-}
      shift 2
      ;;
    --diff)
      DIFF_BAK=${2:-}
      shift 2
      ;;
    --log)
      LOG_BAK=${2:-}
      shift 2
      ;;
    *)
      echo "未知参数: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$FULL_BAK" ]]; then
  echo "必须指定 --full <完整备份文件路径>"
  exit 1
fi

resolve_host_path() {
    local path=$1
    if [[ "$path" != /* ]]; then
        path="$ROOT_DIR/$path"
    fi
    if [[ ! -f "$path" ]]; then
        echo "找不到文件: $path" >&2
        exit 1
    fi
    local basename
    basename=$(basename "$path")
    RES_HOST="$path"
    RES_CONTAINER="$CONTAINER_BACKUP_DIR/$basename"
}

RES_HOST=""
RES_CONTAINER=""

resolve_host_path "$FULL_BAK"
HOST_FULL="$RES_HOST"
CONTAINER_FULL="$RES_CONTAINER"

if [[ -n "$DIFF_BAK" ]]; then
    resolve_host_path "$DIFF_BAK"
    HOST_DIFF="$RES_HOST"
    CONTAINER_DIFF="$RES_CONTAINER"
else
    CONTAINER_DIFF=""
fi

if [[ -n "$LOG_BAK" ]]; then
    resolve_host_path "$LOG_BAK"
    HOST_LOG="$RES_HOST"
    CONTAINER_LOG="$RES_CONTAINER"
else
    CONTAINER_LOG=""
fi

# 确保备份位于容器挂载目录内
# (此脚本假设备份都存放在 School_Data/backup 下)

if ! docker ps --filter "name=^/${CONTAINER_NAME}$" --filter "status=running" -q >/dev/null; then
    echo "启动 SQL Server 容器 $CONTAINER_NAME ..."
    docker start "$CONTAINER_NAME" >/dev/null
fi

echo "将数据库切换到 SINGLE_USER 模式..."
    docker exec "$CONTAINER_NAME" bash -c "$SQLCMD $SQLCMD_OPTS -Q \"ALTER DATABASE [$DB_NAME] SET SINGLE_USER WITH ROLLBACK IMMEDIATE;\"" >/dev/null

run_restore() {
    local sql=$1
    docker exec "$CONTAINER_NAME" bash -c "$SQLCMD $SQLCMD_OPTS -Q \"$sql\""
}

echo "还原完整备份: $HOST_FULL"
run_restore "RESTORE DATABASE [$DB_NAME] FROM DISK = N'$CONTAINER_FULL' WITH REPLACE, NORECOVERY, STATS=5;"

if [[ -n "$CONTAINER_DIFF" ]]; then
    echo "还原差异备份: $HOST_DIFF"
    run_restore "RESTORE DATABASE [$DB_NAME] FROM DISK = N'$CONTAINER_DIFF' WITH NORECOVERY, STATS=5;"
fi

if [[ -n "$CONTAINER_LOG" ]]; then
    echo "还原日志备份: $HOST_LOG"
    run_restore "RESTORE LOG [$DB_NAME] FROM DISK = N'$CONTAINER_LOG' WITH RECOVERY, STATS=5;"
else
    echo "差异/日志未提供，直接在完整/差异备份后 RECOVERY"
    run_restore "RESTORE DATABASE [$DB_NAME] WITH RECOVERY;"
fi

echo "切回 MULTI_USER 模式"
docker exec "$CONTAINER_NAME" bash -c "$SQLCMD $SQLCMD_OPTS -Q \"ALTER DATABASE [$DB_NAME] SET MULTI_USER;\"" >/dev/null

echo "还原完成！"
