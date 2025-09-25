# DataGrip 连接 Microsoft SQL Server 设置指南

## 🎯 目标
在 DataGrip 中连接 Microsoft SQL Server，使用您的 School_Data 课程数据。

## 📋 前置条件
- DataGrip 已安装
- Docker Desktop 已安装

## 🚀 步骤一：启动 Docker Desktop

1. **打开 Docker Desktop 应用程序**
2. **等待 Docker 完全启动**（状态栏显示 "Docker Desktop is running"）

## 🐳 步骤二：运行 SQL Server 容器

### 2.1 拉取 SQL Server 2019 镜像
```bash
docker pull mcr.microsoft.com/mssql/server:2019-latest
```

### 2.2 运行 SQL Server 容器
```bash
docker run -e 'ACCEPT_EULA=Y' -e 'SA_PASSWORD=YourStrong!Passw0rd123' \
  -p 1433:1433 --name sqlserver2019 \
  -v /Users/lianglihang/Downloads/Database/School_Data:/var/opt/mssql/data \
  -d mcr.microsoft.com/mssql/server:2019-latest
```

**重要参数说明：**
- `SA_PASSWORD`: SQL Server 管理员密码（必须是强密码）
- `-p 1433:1433`: 映射端口 1433
- `--name sqlserver2019`: 容器名称
- `-v`: 挂载您的数据库文件目录

### 2.3 检查容器状态
```bash
docker ps
```

### 2.4 启动容器
```bash
docker start sqlserver2019
```

### 2.5 停止容器
```bash
docker stop sqlserver2019
```

### 2.6 重启容器
```bash
docker restart sqlserver2019
```

docker start sqlserver2019

# 停止容器
docker stop sqlserver2019

# 重启容器
docker restart sqlserver2019

## 🔗 步骤三：在 DataGrip 中配置连接

### 3.1 创建新数据源
1. 打开 DataGrip
2. 点击 `+` 按钮
3. 选择 `Microsoft SQL Server`

### 3.2 配置连接参数
```
Host: localhost
Port: 1433
Database: (留空)
User: sa
Password: YourStrong!Passw0rd123
```

### 3.3 测试连接
- 点击 `Test Connection`
- 如果成功，会显示 "Connection successful"

## 📊 步骤四：恢复 School_Data 数据库

### 4.1 连接到 SQL Server
在 DataGrip 中执行以下 SQL 命令：

```sql
-- 创建数据库
CREATE DATABASE School_Data;

-- 使用数据库
USE School_Data;

-- 恢复数据库文件（需要将 MDF 文件复制到容器内）
-- 注意：这需要特殊的方法，因为 MDF/LDF 文件需要 SQL Server 管理工具
```

## 🔧 替代方案：使用 SQL Server Management Studio (SSMS)

如果直接恢复 MDF 文件有困难，建议：

1. **在 Windows 虚拟机中安装 SQL Server**
2. **使用 SSMS 恢复数据库**
3. **导出数据为 SQL 脚本或 CSV**
4. **在 macOS 的 SQL Server 中重新创建**

## 📝 常用 SQL Server 命令

```sql
-- 查看所有数据库
SELECT name FROM sys.databases;

-- 查看当前数据库的表
SELECT TABLE_NAME FROM INFORMATION_SCHEMA.TABLES;

-- 查看表结构
EXEC sp_help 'table_name';
```

## 🚨 故障排除

### Docker 连接问题
```bash
# 重启 Docker Desktop
# 检查 Docker 状态
docker version

# 查看容器日志
docker logs sqlserver2019
```

### 连接失败
1. 检查端口 1433 是否被占用
2. 确认密码符合强密码要求
3. 检查防火墙设置

## 📚 学习资源

- [SQL Server 官方文档](https://docs.microsoft.com/en-us/sql/)
- [DataGrip 使用指南](https://www.jetbrains.com/help/datagrip/)

## 🎉 完成

设置完成后，您就可以在 DataGrip 中：
- 浏览数据库结构
- 执行 SQL 查询
- 分析数据
- 创建图表和报告
