
# SQL语句语法总结笔记

## 1. 表操作

### 1.1 创建表
```sql
CREATE TABLE 表名 (
    列名1 数据类型 约束,
    列名2 数据类型 约束,
    ...
);

-- 示例
CREATE TABLE CUSTOMERS (
    CID INT PRIMARY KEY,
    CNAME NVARCHAR(40) NOT NULL,
    CITY NVARCHAR(40) DEFAULT '北京',
    GRADE INT,
    AGENT_ID INT REFERENCES AGENTS(AID)
);
```

### 1.2 修改表
```sql
-- 添加列
ALTER TABLE 表名 ADD 列名 数据类型 约束;

-- 修改列
ALTER TABLE 表名 ALTER COLUMN 列名 新数据类型;

-- 添加约束
ALTER TABLE 表名 ADD CONSTRAINT 约束名 约束类型 (列名);

-- 示例
ALTER TABLE PRODUCTS ADD CITY NVARCHAR(50);
ALTER TABLE ORDERS ADD FOREIGN KEY (CID) REFERENCES CUSTOMERS(CID);
```

### 1.3 删除表
```sql
DROP TABLE 表名;
```

### 1.4 创建索引
```sql
CREATE [UNIQUE] [CLUSTERED|NONCLUSTERED] INDEX 索引名
ON 表名(列名 [ASC|DESC]);

-- 示例
CREATE UNIQUE NONCLUSTERED INDEX IX_AGENTS
ON AGENTS(AID);
```

## 2. SQL函数与查询

### 2.1 SELECT语句
```sql
SELECT [DISTINCT] 列名1, 列名2, ...
FROM 表名
[WHERE 条件]
[GROUP BY 列名]
[HAVING 条件]
[ORDER BY 列名 [ASC|DESC]];
```

### 2.2 聚合函数
```sql
SELECT 
    COUNT(*), -- 记录数
    SUM(列名), -- 求和
    AVG(列名), -- 平均值
    MAX(列名), -- 最大值
    MIN(列名) -- 最小值
FROM 表名
[WHERE 条件];
```

### 2.3 JOIN操作
```sql
-- 内连接
SELECT 列名
FROM 表1
INNER JOIN 表2 ON 表1.列 = 表2.列;

-- 左连接
SELECT 列名
FROM 表1
LEFT JOIN 表2 ON 表1.列 = 表2.列;

-- 右连接
SELECT 列名
FROM 表1
RIGHT JOIN 表2 ON 表1.列 = 表2.列;
```

### 2.4 嵌套查询
```sql
SELECT 列名
FROM 表名
WHERE 列名 IN (SELECT 列名 FROM 表名 WHERE 条件);

-- 示例
SELECT CNAME FROM CUSTOMERS
WHERE CID IN (SELECT CID FROM ORDERS WHERE AMOUNT > 2000);
```

## 2.5 NULL值处理

### 2.5.1 NULL值的比较
```sql
-- 判断NULL值
SELECT * FROM 表名 WHERE 列名 IS NULL;
SELECT * FROM 表名 WHERE 列名 IS NOT NULL;

-- NULL值与任何值比较都返回未知（UNKNOWN）
SELECT * FROM 表名 WHERE 列名 = NULL; -- 永远不会返回结果
SELECT * FROM 表名 WHERE 列名 <> NULL; -- 永远不会返回结果
```

### 2.5.2 NULL值在聚合函数中的处理
```sql
-- COUNT(*) 包含NULL值，COUNT(列名) 排除NULL值
SELECT 
    COUNT(*) AS 总记录数,
    COUNT(score) AS 非空记录数,
    SUM(score) AS 总和, -- 忽略NULL值
    AVG(score) AS 平均值, -- 忽略NULL值
    MAX(score) AS 最大值, -- 忽略NULL值
    MIN(score) AS 最小值  -- 忽略NULL值
FROM CHOICES;
```

### 2.5.3 NULL值在排序中的行为
```sql
-- 升序排列时，NULL值排在最前面
SELECT sid, score FROM CHOICES ORDER BY score ASC;

-- 降序排列时，NULL值排在最后面
SELECT sid, score FROM CHOICES ORDER BY score DESC;
```

### 2.5.4 NULL值在分组中的行为
```sql
-- NULL值会被视为一个独立的组
SELECT grade, COUNT(*) AS 学生人数
FROM STUDENTS
GROUP BY grade
ORDER BY grade;
```

### 2.5.5 NULL值在逻辑运算中的处理
```sql
-- NULL与TRUE的AND运算结果为UNKNOWN
SELECT * FROM 表名 WHERE 1 = 1 AND NULL;

-- NULL与FALSE的AND运算结果为FALSE
SELECT * FROM 表名 WHERE 1 = 0 AND NULL;

-- NULL与TRUE的OR运算结果为TRUE
SELECT * FROM 表名 WHERE 1 = 1 OR NULL;

-- NULL与FALSE的OR运算结果为UNKNOWN
SELECT * FROM 表名 WHERE 1 = 0 OR NULL;
```

## 3. 视图

### 3.1 创建视图
```sql
CREATE VIEW 视图名 AS
SELECT 列名1, 列名2, ...
FROM 表名
[WHERE 条件];

-- 带检查选项
CREATE VIEW 视图名 AS
SELECT 列名1, 列名2, ...
FROM 表名
WHERE 条件
WITH CHECK OPTION;
```

### 3.2 使用视图
```sql
-- 查询视图
SELECT * FROM 视图名;

-- 更新视图（需满足基表约束）
UPDATE 视图名
SET 列名 = 值
WHERE 条件;

-- 删除视图
DROP VIEW 视图名;
```

## 4. 约束

### 4.1 主键约束
```sql
-- 创建表时指定
CREATE TABLE 表名 (
    列名 数据类型 PRIMARY KEY,
    ...
);

-- 多列主键
CREATE TABLE 表名 (
    列名1 数据类型,
    列名2 数据类型,
    PRIMARY KEY (列名1, 列名2)
);

-- 表创建后添加
ALTER TABLE 表名 ADD PRIMARY KEY (列名);
```

### 4.2 外键约束
```sql
-- 创建表时指定
CREATE TABLE 表名 (
    列名 数据类型,
    外键列 数据类型 REFERENCES 父表(主键列),
    ...
);

-- 带级联操作
ALTER TABLE 表名 ADD
FOREIGN KEY (外键列) REFERENCES 父表(主键列)
ON DELETE CASCADE -- 或 NO ACTION/SET NULL
ON UPDATE CASCADE;
```

### 4.3 检查约束
```sql
-- 创建表时指定
CREATE TABLE 表名 (
    列名 数据类型 CHECK (条件),
    ...
);

-- 表创建后添加
ALTER TABLE 表名 ADD CONSTRAINT 约束名 CHECK (条件);

-- 示例
ALTER TABLE Worker ADD CONSTRAINT U3 CHECK (Sage >= 0);
```

### 4.4 唯一约束
```sql
-- 创建表时指定
CREATE TABLE 表名 (
    列名 数据类型 UNIQUE,
    ...
);

-- 表创建后添加
ALTER TABLE 表名 ADD CONSTRAINT 约束名 UNIQUE (列名);
```

## 5. 规则

### 5.1 创建规则
```sql
CREATE RULE 规则名 AS @变量 条件;

-- 示例
CREATE RULE R2 AS @sage BETWEEN 1 AND 100;
```

### 5.2 绑定规则
```sql
EXEC sp_bindrule '规则名', '表名.列名';

-- 示例
EXEC sp_bindrule 'R2', 'Worker.Sage';
```

### 5.3 解绑规则
```sql
EXEC sp_unbindrule '表名.列名';

-- 示例
EXEC sp_unbindrule 'Worker.Sage';
```

## 6. 触发器

### 6.1 AFTER触发器
```sql
CREATE TRIGGER 触发器名
ON 表名
AFTER INSERT|UPDATE|DELETE
AS
BEGIN
    -- 触发器逻辑
    -- 使用 INSERTED 和 DELETED 虚拟表
END;
```

### 6.2 INSTEAD OF触发器
```sql
CREATE TRIGGER 触发器名
ON 视图名
INSTEAD OF INSERT|UPDATE|DELETE
AS
BEGIN
    -- 替代操作逻辑
END;
```

### 6.3 示例
```sql
-- 禁止插入年龄超过最大年龄的记录
CREATE TRIGGER T4
ON Worker
AFTER INSERT
AS
BEGIN
    DECLARE @maxAge INT;
    SELECT @maxAge = MaxSage FROM stu_card;
    IF EXISTS (SELECT * FROM INSERTED WHERE Sage > @maxAge)
    BEGIN
        ROLLBACK TRANSACTION;
        RAISERROR('插入失败，年龄超过最大限制', 16, 1);
    END;
END;
```

## 7. 事务处理

### 7.1 开始事务
```sql
BEGIN TRANSACTION [事务名];
-- 或简写为
BEGIN TRAN [事务名];
```

### 7.2 提交事务
```sql
COMMIT TRANSACTION [事务名];
-- 或简写为
COMMIT TRAN [事务名];
```

### 7.3 回滚事务
```sql
ROLLBACK TRANSACTION [事务名];
-- 或简写为
ROLLBACK TRAN [事务名];
```

### 7.4 保存点
```sql
SAVE TRANSACTION 保存点名;

-- 回滚到保存点
ROLLBACK TRANSACTION 保存点名;
```

### 7.5 嵌套事务
```sql
BEGIN TRANSACTION OuterTransaction;
    UPDATE students SET sname = '张三（已修改）' WHERE sid = '800001216';
    
    BEGIN TRANSACTION InnerTransaction;
        BEGIN TRY
            INSERT INTO teachers VALUES ('T001', '新教师', 'newteacher@example.com', 7000);
            COMMIT TRANSACTION InnerTransaction;
        END TRY
        BEGIN CATCH
            PRINT '内层事务失败：' + ERROR_MESSAGE();
            ROLLBACK TRANSACTION; -- 会回滚所有嵌套事务
        END CATCH
    
COMMIT TRANSACTION OuterTransaction;
```

### 7.6 错误处理
```sql
BEGIN TRY
    BEGIN TRANSACTION;
    
    -- 事务操作
    
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    IF @@TRANCOUNT > 0
    BEGIN
        ROLLBACK TRANSACTION;
    END;
    
    PRINT '错误：' + ERROR_MESSAGE();
END CATCH;
```

## 8. 事务隔离级别

### 8.1 设置隔离级别
```sql
SET TRANSACTION ISOLATION LEVEL [隔离级别];
```

### 8.2 隔离级别类型
```sql
-- 未提交读（允许脏读）
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;

-- 提交读（防止脏读，默认级别）
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;

-- 可重复读（防止脏读和不可重复读）
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 可串行化（防止所有并发问题）
SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
```

## 9. 锁与死锁

### 9.1 锁超时设置
```sql
SET LOCK_TIMEOUT 超时时间(毫秒);

-- 示例：设置2秒超时
SET LOCK_TIMEOUT 2000;
```

### 9.2 查看进程和阻塞
```sql
-- 查看当前所有进程
EXEC sp_who;

-- 查看阻塞信息
EXEC sp_who2;
```

### 9.3 死锁处理
```sql
-- 错误代码识别
-- 1205：死锁（Deadlock）
-- 1222：锁超时（Lock Timeout）

-- 带重试机制的死锁处理
BEGIN TRY
    BEGIN TRAN;
    
    -- 数据库操作
    
    COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    
    IF ERROR_NUMBER() = 1205 OR ERROR_NUMBER() = 1222
    BEGIN
        -- 自动重试逻辑
        PRINT '发生死锁或锁超时，正在重试...';
    END;
END CATCH;
```

### 9.4 避免死锁的策略
- 统一资源访问顺序
- 减少事务持有锁的时间
- 使用较低的隔离级别
- 设置合理的锁超时
- 避免在事务中等待用户输入

## 10. 用户管理与权限控制

### 10.1 创建登录
```sql
-- SQL Server 2000风格
EXEC sp_addlogin '用户名', '密码', '数据库', '语言';

-- 示例
EXEC sp_addlogin '王二', 'WangEr@2025', 'School_Data', 'English';
```

### 10.2 创建用户
```sql
-- SQL Server 2000风格
EXEC sp_grantdbaccess '登录名', '数据库用户名';

-- 示例
EXEC sp_grantdbaccess '王二';
```

### 10.3 授予权限
```sql
-- 授予表/视图权限
GRANT 权限类型 ON 对象名 TO 用户名;

-- 授予特定列的权限
GRANT UPDATE (列名) ON 对象名 TO 用户名;

-- 示例
GRANT SELECT ON grade2000 TO [王二];
GRANT UPDATE (sname) ON grade2000 TO [王二];
```

### 10.4 撤销权限
```sql
REVOKE 权限类型 ON 对象名 FROM 用户名;
```

### 10.5 拒绝权限
```sql
DENY 权限类型 ON 对象名 TO 用户名;
```

### 10.6 查看权限
```sql
-- 查看用户对对象的权限
SELECT * FROM sys.database_permissions
WHERE grantee_principal_id = USER_ID('用户名')
AND major_id = OBJECT_ID('对象名');

-- 查看用户信息
SELECT name, type_desc, default_schema_name 
FROM sys.database_principals 
WHERE name = '用户名';
```

## 11. 系统管理

### 11.1 查看错误日志
```sql
-- 查看当前错误日志
EXEC xp_readerrorlog 0, 1, NULL, NULL, NULL, NULL, N'DESC';

-- 查看特定错误
EXEC xp_readerrorlog 0, 1, N'Login failed', NULL, NULL, NULL, N'DESC';
```

### 11.2 检查连接状态
```sql
-- 查看当前连接
SELECT * FROM sys.dm_exec_connections;

-- 查看会话信息
SELECT * FROM sys.dm_exec_sessions;
```

## 12. 常用系统函数

| 函数名 | 功能描述 |
|--------|----------|
| `ERROR_NUMBER()` | 获取错误号 |
| `ERROR_MESSAGE()` | 获取错误信息 |
| `@@TRANCOUNT` | 当前事务嵌套层数 |
| `@@ROWCOUNT` | 上一条SQL语句影响的行数 |
| `GETDATE()` | 获取当前日期和时间 |
| `USER_ID()` | 获取当前用户ID |
| `OBJECT_ID()` | 获取对象ID |
| `IDENTITY()` | 生成标识值 |
| `SCOPE_IDENTITY()` | 获取当前作用域内最后生成的标识值 |

---

**注意：** 以上语法主要基于SQL Server，不同数据库系统可能存在细微差异。