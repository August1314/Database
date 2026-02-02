#!/bin/bash
# 通过 sqlcmd 执行完整/差异/事务日志备份
# 用法： ./scripts/sql_backup.sh [full|diff|log]

set -euo pipefail

action=${1:-}
if [[ -z "$action" ]]; then
    echo "用法: $0 [full|diff|log]"
    exit 1
fi

action=$(echo "$action" | tr 'A-Z' 'a-z')

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST_BACKUP_DIR="$ROOT_DIR/School_Data/backup"
CONTAINER_BACKUP_DIR="/var/opt/mssql/data/backup"
CONTAINER_NAME=${CONTAINER_NAME:-sqlserver2019}
DB_NAME=${DB_NAME:-School_Data}
SA_PASSWORD=${SA_PASSWORD:-YourStrong!Passw0rd123}
SQLCMD=${SQLCMD_PATH:-/opt/mssql-tools18/bin/sqlcmd}
SQLCMD_OPTS="-S localhost -U sa -P \"$SA_PASSWORD\" -C"

mkdir -p "$HOST_BACKUP_DIR"

docker exec "$CONTAINER_NAME" mkdir -p "$CONTAINER_BACKUP_DIR" >/dev/null 2>&1 || true

if ! docker ps --filter "name=^/${CONTAINER_NAME}$" --filter "status=running" -q >/dev/null; then
    echo "启动 SQL Server 容器 $CONTAINER_NAME ..."
    docker start "$CONTAINER_NAME" >/dev/null
fi

TIMESTAMP=$(date +%Y%m%d_%H%M%S)
case "$action" in
    full)
        FILE_NAME="${DB_NAME}_full_${TIMESTAMP}.bak"
        SQL="BACKUP DATABASE [$DB_NAME] TO DISK = N'$CONTAINER_BACKUP_DIR/$FILE_NAME' WITH INIT, STATS=5;"
        ;;
    diff|differential)
        FILE_NAME="${DB_NAME}_diff_${TIMESTAMP}.bak"
        SQL="BACKUP DATABASE [$DB_NAME] TO DISK = N'$CONTAINER_BACKUP_DIR/$FILE_NAME' WITH DIFFERENTIAL, INIT, STATS=5;"
        ;;
    log|tlog)
        FILE_NAME="${DB_NAME}_log_${TIMESTAMP}.trn"
        SQL="BACKUP LOG [$DB_NAME] TO DISK = N'$CONTAINER_BACKUP_DIR/$FILE_NAME' WITH INIT, STATS=5;"
        ;;
    *)
        echo "未知操作: $action (必须是 full/diff/log)"
        exit 1
        ;;
esac

# 确保数据库处于 FULL 恢复模式（差异/日志备份需要）
if [[ "$action" != "full" ]]; then
    docker exec "$CONTAINER_NAME" bash -c "$SQLCMD $SQLCMD_OPTS -Q \"ALTER DATABASE [$DB_NAME] SET RECOVERY FULL WITH NO_WAIT;\"" >/dev/null
fi

echo "执行 $action 备份，输出文件: $HOST_BACKUP_DIR/$FILE_NAME"

docker exec "$CONTAINER_NAME" bash -c "$SQLCMD $SQLCMD_OPTS -Q \"$SQL\""

echo "备份完成: $HOST_BACKUP_DIR/$FILE_NAME"
