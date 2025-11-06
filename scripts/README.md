# 数据库重置脚本使用说明

这些脚本帮助你管理 School_Data 数据库，确保可以随时恢复到干净的初始状态。

## 文件说明

- `backup_database.sh` - 备份原始数据库文件
- `reset_database.sh` - 重置数据库到原始状态

## 使用步骤

### 第一次使用（创建备份）

1. 确保你的数据库是干净的初始状态
2. 给脚本添加执行权限：
   ```bash
   chmod +x scripts/backup_database.sh
   chmod +x scripts/reset_database.sh
   ```

3. 运行备份脚本：
   ```bash
   ./scripts/backup_database.sh
   ```

这会在 `~/Downloads/Database/School_Data_Backup/` 目录下创建备份文件。

### 日常使用（重置数据库）

当你想恢复到干净的数据库状态时：

```bash
./scripts/reset_database.sh
```

这个脚本会：
1. 停止 SQL Server 容器
2. 用备份文件覆盖当前数据库文件
3. 重启 SQL Server 容器

## 工作原理

### 备份位置
- 原始文件: `~/Downloads/Database/School_Data/`
- 备份文件: `~/Downloads/Database/School_Data_Backup/`

### 备份的文件
- `School_Data.MDF` - 数据库主文件
- `School_Log.LDF` - 事务日志文件

## 注意事项

1. **第一次备份很重要**：确保在数据库是干净状态时创建备份
2. **重置会丢失所有更改**：重置后，所有的INSERT、UPDATE、DELETE操作都会被撤销
3. **容器会重启**：重置过程中会停止并重启 Docker 容器，需要等待几秒钟

## 故障排除

### 问题：找不到备份文件
**解决方案**：先运行 `./scripts/backup_database.sh` 创建备份

### 问题：权限被拒绝
**解决方案**：运行 `chmod +x scripts/*.sh` 添加执行权限

### 问题：Docker 容器无法停止
**解决方案**：手动停止容器 `docker stop sqlserver2019`，然后重试

## 快速参考

```bash
# 创建备份（只需要做一次）
./scripts/backup_database.sh

# 重置数据库（可以多次使用）
./scripts/reset_database.sh

# 查看备份信息
ls -lh ~/Downloads/Database/School_Data_Backup/
cat ~/Downloads/Database/School_Data_Backup/backup_time.txt
```

## 工作流程示例

```bash
# 1. 第一次使用，创建备份
./scripts/backup_database.sh

# 2. 做实验，修改数据库
# ... 运行各种 SQL 语句 ...

# 3. 实验完成，重置数据库
./scripts/reset_database.sh

# 4. 继续下一个实验
# ... 数据库已经是干净的了 ...
```
