#!/bin/bash
# 备份原始数据库文件
# 使用方法: ./backup_database.sh

set -e  # 遇到错误立即退出

DB_DIR=~/Downloads/Database/School_Data
BACKUP_DIR=~/Downloads/Database/School_Data_Backup

echo "=========================================="
echo "备份 School_Data 数据库文件"
echo "=========================================="

# 创建备份目录
if [ ! -d "$BACKUP_DIR" ]; then
    echo "创建备份目录: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
fi

# 检查数据库文件是否存在
if [ ! -f "$DB_DIR/School_Data.MDF" ]; then
    echo "错误: 找不到 School_Data.MDF 文件"
    exit 1
fi

if [ ! -f "$DB_DIR/School_Log.LDF" ]; then
    echo "错误: 找不到 School_Log.LDF 文件"
    exit 1
fi

# 停止 Docker 容器以确保文件不被占用
echo "停止 SQL Server 容器..."
docker stop sqlserver2019 || true

# 等待容器完全停止
sleep 2

# 备份文件
echo "备份 School_Data.MDF..."
cp "$DB_DIR/School_Data.MDF" "$BACKUP_DIR/School_Data.MDF.backup"

echo "备份 School_Log.LDF..."
cp "$DB_DIR/School_Log.LDF" "$BACKUP_DIR/School_Log.LDF.backup"

# 记录备份时间
date > "$BACKUP_DIR/backup_time.txt"

echo ""
echo "=========================================="
echo "备份完成！"
echo "备份位置: $BACKUP_DIR"
echo "备份时间: $(cat $BACKUP_DIR/backup_time.txt)"
echo "=========================================="
echo ""
echo "重启 SQL Server 容器..."
docker start sqlserver2019

echo "完成！"
