# MySQL 学习指南

## 安装完成确认

✅ **MySQL 9.3.0 已成功安装在您的 macOS 系统上**

## 基本操作命令

### 1. 启动和停止 MySQL 服务

```bash
# 启动 MySQL 服务
brew services start mysql

# 停止 MySQL 服务
brew services stop mysql

# 重启 MySQL 服务
brew services restart mysql

# 查看服务状态
brew services list | grep mysql
```

### 2. 连接 MySQL

```bash
# 使用 root 用户连接（需要输入密码）
mysql -u root -p

# 连接后可以执行 SQL 命令
```

### 3. 基本 SQL 命令

```sql
-- 查看所有数据库
SHOW DATABASES;

-- 创建新数据库
CREATE DATABASE mydb;

-- 使用数据库
USE mydb;

-- 查看当前数据库中的表
SHOW TABLES;

-- 退出 MySQL
EXIT;
```

## 学习路径建议

### 第一阶段：基础概念
1. **数据库基础概念**
   - 什么是数据库
   - 关系型数据库 vs 非关系型数据库
   - 表、行、列的概念

2. **SQL 基础语法**
   - SELECT 查询
   - INSERT 插入
   - UPDATE 更新
   - DELETE 删除

### 第二阶段：进阶操作
1. **数据表设计**
   - 数据类型
   - 主键和外键
   - 索引

2. **复杂查询**
   - JOIN 连接
   - 子查询
   - 聚合函数

### 第三阶段：高级特性
1. **存储过程和函数**
2. **触发器**
3. **事务处理**
4. **性能优化**

## 推荐学习资源

1. **在线教程**
   - MySQL 官方文档
   - W3Schools SQL 教程
   - 菜鸟教程 MySQL

2. **实践项目**
   - 学生管理系统
   - 图书管理系统
   - 电商数据库设计

## 常用配置信息

- **MySQL 版本**: 9.3.0
- **安装路径**: /opt/homebrew/Cellar/mysql/9.3.0
- **数据目录**: /opt/homebrew/var/mysql
- **配置文件**: /opt/homebrew/etc/my.cnf
- **默认端口**: 3306

## 下一步

现在您可以开始学习 SQL 基础语法了！建议从简单的 SELECT 查询开始。
