# DataGrip 连接 SQL Server 步骤

## ✅ SQL Server 环境已准备就绪

**SQL Server 2019 容器正在运行中！**

- 容器名称: `sqlserver2019`
- 端口: `1433`
- 状态: 运行中 ✅

## 🔗 在 DataGrip 中配置连接

### 步骤 1: 创建新数据源
1. 打开 DataGrip
2. 点击 `+` 按钮
3. 选择 `Microsoft SQL Server`

### 步骤 2: 配置连接参数
```
Host: localhost
Port: 1433
Authentication: SQL Server Authentication  ← 重要！
Database: (留空)
User: sa
Password: YourStrong!Passw0rd123
```

**重要提示**：确保选择 `SQL Server Authentication` 而不是 `Kerberos`

### 步骤 3: 测试连接
- 点击 `Test Connection` 按钮
- 如果成功，会显示 "Connection successful"

## 📊 连接成功后的操作

### 查看数据库
```sql
-- 查看所有数据库
SELECT name FROM sys.databases;
```

### 使用您的课程数据
您的 School_Data 文件已经挂载到容器中，应该可以在 DataGrip 中看到。

## 🎯 下一步操作

1. **在 DataGrip 中建立连接**
2. **浏览数据库结构**
3. **开始执行 SQL 查询**
4. **探索您的课程数据**

## 🚨 如果连接失败

### 检查容器状态
```bash
docker ps
```

### 查看容器日志
```bash
docker logs sqlserver2019
```

### 重启容器（如果需要）
```bash
docker restart sqlserver2019
```

## 🎉 完成！

现在您可以在 DataGrip 中使用 Microsoft SQL Server 了！
