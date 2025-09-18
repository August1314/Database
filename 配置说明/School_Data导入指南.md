# School_Data 数据库导入 DataGrip 指南

## 🎯 目标
将您的 School_Data.MDF 和 School_Log.LDF 文件导入到 DataGrip 中使用。

## 📋 方法一：使用 SQL Server Management Studio (推荐)

### 步骤 1: 下载并安装 SQL Server Management Studio
1. 访问 [Microsoft 官网](https://docs.microsoft.com/en-us/sql/ssms/download-sql-server-management-studio-ssms)
2. 下载 SSMS 18.x 或更新版本
3. 安装到您的 Mac（通过虚拟机或 Wine）

### 步骤 2: 在 SSMS 中附加数据库
1. 连接到 SQL Server 实例
2. 右键点击 "Databases" → "Attach"
3. 选择您的 School_Data.MDF 文件
4. 确认日志文件路径
5. 点击 "OK"

## 📋 方法二：使用 DataGrip 直接导入

### 步骤 1: 在 DataGrip 中执行 SQL 命令

```sql
-- 方法 1: 尝试附加数据库
CREATE DATABASE School_Data ON 
(FILENAME = '/var/opt/mssql/data/School_Data.MDF'),
(FILENAME = '/var/opt/mssql/data/School_Log.LDF')
FOR ATTACH;
```

### 步骤 2: 如果附加失败，尝试恢复

```sql
-- 方法 2: 恢复数据库
RESTORE DATABASE School_Data FROM DISK = '/var/opt/mssql/data/School_Data.MDF'
WITH REPLACE;
```

## 📋 方法三：手动复制文件到容器

### 步骤 1: 复制文件到容器
```bash
# 复制 MDF 文件
docker cp /Users/lianglihang/Downloads/Database/School_Data/School_Data.MDF sqlserver2019:/var/opt/mssql/data/

# 复制 LDF 文件
docker cp /Users/lianglihang/Downloads/Database/School_Data/School_Log.LDF sqlserver2019:/var/opt/mssql/data/
```

### 步骤 2: 在 DataGrip 中附加
```sql
CREATE DATABASE School_Data ON 
(FILENAME = '/var/opt/mssql/data/School_Data.MDF'),
(FILENAME = '/var/opt/mssql/data/School_Log.LDF')
FOR ATTACH;
```

## 📋 方法四：导出为 SQL 脚本

### 步骤 1: 使用 SQL Server 工具导出
1. 在 Windows 环境中打开 School_Data.MDF
2. 使用 "Generate Scripts" 功能
3. 导出为 SQL 脚本文件
4. 在 DataGrip 中执行脚本

## 🔧 故障排除

### 权限问题
```bash
# 检查容器内文件权限
docker exec sqlserver2019 ls -la /var/opt/mssql/data/

# 修改文件权限
docker exec sqlserver2019 chown mssql:mssql /var/opt/mssql/data/School_Data.*
```

### 文件路径问题
确保文件路径正确：
- MDF 文件：`/var/opt/mssql/data/School_Data.MDF`
- LDF 文件：`/var/opt/mssql/data/School_Log.LDF`

## 🎉 验证导入成功

```sql
-- 查看所有数据库
SELECT name FROM sys.databases;

-- 使用 School_Data 数据库
USE School_Data;

-- 查看所有表
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;

-- 查看表结构
SELECT COLUMN_NAME, DATA_TYPE, IS_NULLABLE 
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'YourTableName';
```

## 💡 建议

1. **优先使用方法三**：手动复制文件到容器
2. **如果仍然失败**：考虑在 Windows 虚拟机中处理
3. **学习目的**：可以先使用我们创建的示例数据库练习

## 🚀 下一步

导入成功后，您就可以：
- 浏览数据库结构
- 执行 SQL 查询
- 分析课程数据
- 学习数据库操作
