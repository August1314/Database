#!/bin/bash
# 重置数据库到原始状态
# 使用方法: ./reset_database.sh

set -e  # 遇到错误立即退出

DB_DIR=~/Downloads/Database/School_Data
BACKUP_DIR=~/Downloads/Database/School_Data_Backup

echo "=========================================="
echo "重置 School_Data 数据库到原始状态"
echo "=========================================="

# 检查备份文件是否存在
if [ ! -f "$BACKUP_DIR/School_Data.MDF.backup" ]; then
    echo "错误: 找不到备份文件 School_Data.MDF.backup"
    echo "请先运行 ./backup_database.sh 创建备份"
    exit 1
fi

if [ ! -f "$BACKUP_DIR/School_Log.LDF.backup" ]; then
    echo "错误: 找不到备份文件 School_Log.LDF.backup"
    echo "请先运行 ./backup_database.sh 创建备份"
    exit 1
fi

# 显示备份信息
if [ -f "$BACKUP_DIR/backup_time.txt" ]; then
    echo "备份时间: $(cat $BACKUP_DIR/backup_time.txt)"
fi

# 停止 Docker 容器
echo ""
echo "停止 SQL Server 容器..."
docker stop sqlserver2019

# 等待容器完全停止
sleep 2

# 恢复备份文件
echo "恢复 School_Data.MDF..."
cp "$BACKUP_DIR/School_Data.MDF.backup" "$DB_DIR/School_Data.MDF"

echo "恢复 School_Log.LDF..."
cp "$BACKUP_DIR/School_Log.LDF.backup" "$DB_DIR/School_Log.LDF"

# 重启容器
echo ""
echo "重启 SQL Server 容器..."
docker start sqlserver2019

# 等待 SQL Server 启动
echo "等待 SQL Server 启动..."
sleep 5

echo ""
echo "=========================================="
echo "数据库已重置到原始状态！"
echo "=========================================="
echo ""
echo "你现在可以重新连接数据库了"
