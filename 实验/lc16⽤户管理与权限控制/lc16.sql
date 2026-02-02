-- ========================================
-- LC16 用户管理与权限控制实验脚本
-- 实验目标：
-- 1. 在school数据库上创建用户"王二"，在students表上创建视图grade2000
-- 2. 授予用户王二在视图grade2000的select权限
-- 3. 授予用户王二在视图grade2000的修改sname列的权限
-- 4. 查看SQL Server错误日志
-- ========================================

USE School_Data;
GO

-- ==================== 环境准备 ====================

-- 清理可能存在的用户和视图（如果存在）
IF EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '王二')
BEGIN
    DROP USER [王二];
END

IF EXISTS (SELECT 1 FROM sys.server_principals WHERE name = '王二')
BEGIN
    DROP LOGIN [王二];
END

IF OBJECT_ID('grade2000', 'V') IS NOT NULL
BEGIN
    DROP VIEW grade2000;
END

GO

-- ========================================
-- 题目1：创建用户"王二"和视图grade2000
-- ========================================

-- Step1: 创建登录
IF NOT EXISTS (SELECT 1 FROM sys.server_principals WHERE name = '王二')
BEGIN
    EXEC sp_addlogin '王二', 'WangEr@2025', 'School_Data', 'English';
END

-- Step2: 授予数据库访问权限
IF NOT EXISTS (SELECT 1 FROM sys.database_principals WHERE name = '王二')
BEGIN
    EXEC sp_grantdbaccess '王二';
END
go

-- Step3: 创建视图grade2000
CREATE VIEW grade2000 AS
SELECT sid, sname, email, grade
FROM students
WHERE grade = 2000;
GO

-- 查看视图内容（单独批次执行）
SELECT * FROM grade2000;
GO

-- ========================================
-- 题目2：授予用户王二在视图grade2000的SELECT权限
-- ========================================

GRANT SELECT ON grade2000 TO [王二];

-- 验证：查看权限
SELECT * FROM sys.database_permissions
WHERE grantee_principal_id = USER_ID('王二') AND major_id = OBJECT_ID('grade2000');

GO

-- ========================================
-- 题目3：授予用户王二在视图grade2000的修改sname列的权限
-- ========================================

GRANT UPDATE ON dbo.[grade2000] ([sname]) TO [王二];

-- 验证：查看权限（可选）
SELECT * FROM sys.database_permissions
WHERE grantee_principal_id = USER_ID('王二')
AND major_id = OBJECT_ID('grade2000')
AND permission_name = 'UPDATE';

GO

-- ========================================
-- 题目4：查看SQL Server错误日志
-- ========================================

-- 注意：查看错误日志需要通过SSMS的图形界面操作
-- 路径：对象资源管理器 -> 管理 -> SQL Server 日志
-- 或者使用以下系统存储过程查看当前日志

-- 查看当前错误日志
EXEC xp_readerrorlog 0, 1, NULL, NULL, NULL, NULL, N'DESC';

-- 查看特定错误（例如：登录失败）
EXEC xp_readerrorlog 0, 1, N'Login failed', NULL, NULL, NULL, N'DESC';

-- 说明：
-- 参数说明：
-- 0 = 当前日志
-- 1 = SQL Server错误日志（不是SQL Server代理日志）
-- NULL = 搜索字符串（可以为NULL查看所有）
-- NULL = 搜索字符串2（可以为NULL）
-- NULL = 开始时间（可以为NULL）
-- NULL = 结束时间（可以为NULL）
-- N'DESC' = 排序方式（DESC降序，ASC升序）

GO

-- ========================================
-- 验证步骤（可选）
-- ========================================

-- 验证1：查看视图内容
SELECT * FROM grade2000;

-- 验证2：查看用户信息
SELECT name, type_desc, default_schema_name 
FROM sys.database_principals 
WHERE name = '王二';

-- 验证3：查看权限信息
SELECT 
    dp.name AS 用户名,
    o.name AS 对象名,
    dp2.name AS 权限授予者,
    p.permission_name AS 权限类型,
    p.state_desc AS 权限状态
FROM sys.database_permissions p
INNER JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
INNER JOIN sys.objects o ON p.major_id = o.object_id
LEFT JOIN sys.database_principals dp2 ON p.grantor_principal_id = dp2.principal_id
WHERE dp.name = '王二' AND o.name = 'grade2000';

