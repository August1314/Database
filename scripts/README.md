# 数据库重置脚本使用说明

这些脚本帮助你管理 School_Data 数据库，确保可以随时恢复到干净的初始状态。

## 文件说明

- `backup_database.sh` - 备份原始数据库文件
- `reset_database.sh` - 重置数据库到原始状态
- `sql_backup.sh` - 使用 SQL Server 自带的 BACKUP 命令创建完整/差异/事务日志备份
- `sql_restore.sh` - 通过 RESTORE 命令按备份链恢复数据库（支持完整 + 差异 + 日志）

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

---

## SQL Server 内部备份（满足 lc5 任务）

`sql_backup.sh` 与 `sql_restore.sh` 使用 SQL Server 的 `BACKUP` / `RESTORE` 指令，能够创建**完整备份**、**差异备份**、**事务日志备份**，并按顺序还原，非常适合 lc5 实验的要求。

### 目录约定
- 备份文件统一保存在 `School_Data/backup/`
- 容器内对应目录为 `/var/opt/mssql/data/backup`（已自动创建）

### 1. 创建备份

```bash
# 完整备份
./scripts/sql_backup.sh full

# 差异备份（建立在最近的一次完整备份之上）
./scripts/sql_backup.sh diff

# 事务日志备份
./scripts/sql_backup.sh log
```

脚本会在 `School_Data/backup/` 下生成类似 `School_Data_full_20251120_153000.bak` 的文件，可多次运行保留历史。

### 2. 还原备份链

```bash
./scripts/sql_restore.sh --full School_Data/backup/School_Data_full_20251120_153000.bak \
                         --diff School_Data/backup/School_Data_diff_20251120_160500.bak \
                         --log  School_Data/backup/School_Data_log_20251120_161000.trn
```

- `--diff`、`--log` 可选，但必须保证顺序正确：**完整 → 差异 → 日志**
- 如果只提供完整备份，脚本会直接 `RECOVERY`
- 还原时会自动将数据库切换到 `SINGLE_USER`，完成后恢复为 `MULTI_USER`

### 3. 实验建议流程
1. 运行 `sql_backup.sh full` 创建基准备份  
2. 执行若干实验操作  
3. 运行 `sql_backup.sh diff` / `sql_backup.sh log` 捕获中间状态  
4. 使用 `sql_restore.sh` 依次还原，观察还原前后的数据差异，记录在实验报告中  

> 如果需要完全清空数据库，仍可以使用 `reset_database.sh` 恢复最初拷贝的 MDF/LDF 快照。

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
