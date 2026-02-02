-- ========================================
-- SQL Server 权限管理实验 (Lecture 7)
-- ========================================

-- ==================== 环境重置部分 ====================
USE master;
GO

PRINT '========== 开始重置实验环境 ==========';

-- 删除已存在的数据库用户
USE School_Data;
GO

IF EXISTS (
    SELECT *
    FROM sys.database_principals
    WHERE
        name = 'USER1'
) DROP
USER USER1;

IF EXISTS (
    SELECT *
    FROM sys.database_principals
    WHERE
        name = 'USER2'
) DROP
USER USER2;

IF EXISTS (
    SELECT *
    FROM sys.database_principals
    WHERE
        name = 'USER3'
) DROP
USER USER3;
GO

-- 删除已存在的登录名
USE master;
GO

IF EXISTS (
    SELECT *
    FROM sys.server_principals
    WHERE
        name = 'USER1'
) DROP
LOGIN USER1;

IF EXISTS (
    SELECT *
    FROM sys.server_principals
    WHERE
        name = 'USER2'
) DROP
LOGIN USER2;

IF EXISTS (
    SELECT *
    FROM sys.server_principals
    WHERE
        name = 'USER3'
) DROP
LOGIN USER3;
GO

-- 重新创建登录名
CREATE
LOGIN USER1
WITH
    PASSWORD = 'YourStrong!Passw0rd123',
    DEFAULT_DATABASE = School_Data;

CREATE
LOGIN USER2
WITH
    PASSWORD = 'YourStrong!Passw0rd123',
    DEFAULT_DATABASE = School_Data;

CREATE
LOGIN USER3
WITH
    PASSWORD = 'YourStrong!Passw0rd123',
    DEFAULT_DATABASE = School_Data;
GO

-- 重新创建数据库用户（无任何权限）
USE School_Data;
GO

CREATE USER USER1 FOR LOGIN USER1 WITH DEFAULT_SCHEMA = dbo;

CREATE USER USER2 FOR LOGIN USER2 WITH DEFAULT_SCHEMA = dbo;

CREATE USER USER3 FOR LOGIN USER3 WITH DEFAULT_SCHEMA = dbo;
GO

PRINT '========== 环境重置完成 ==========';

PRINT '';
GO

-- ==================== 实验题目部分 ====================

--(1)授予所有用户对表 STUDENTS的查询权限
PRINT '========== 题目(1)：授予所有用户对表 STUDENTS的查询权限 ==========';
-- 在这里写你的代码
GRANT SELECT ON STUDENTS TO PUBLIC;

-- 验证权限
PRINT '验证：查看STUDENTS表的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('STUDENTS')
    AND dp.name IN (
        'USER1',
        'USER2',
        'USER3',
        'public'
    );
GO

PRINT '';
GO

--(2)授予所有用户对表 COURSES的查询和更新权限
PRINT '========== 题目(2)：授予所有用户对表 COURSES的查询和更新权限 ==========';

-- 在这里写你的代码
GRANT SELECT ON COURSES TO PUBLIC;
GRANT UPDATE ON COURSES TO PUBLIC;

-- 验证权限
PRINT '验证：查看COURSES表的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('COURSES')
    AND dp.name IN (
        'USER1',
        'USER2',
        'USER3',
        'public'
    );
GO

PRINT '';
GO

--(3)授予USER1对表 TEACHERS的查询,更新工资的权限,且允许USER1可以传播这些权限
PRINT '========== 题目(3)：授予USER1对表 TEACHERS的查询、更新工资的权限，且允许传播 ==========';

-- 在这里写你的代码
create view TS as select salary from TEACHERS;
grant select on TS to USER1 with grant option;
grant update on TS to USER1 with grant option;

-- 验证权限
PRINT '验证：查看USER1对TEACHERS表的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态,
    CASE
        WHEN p.state = 'W' THEN '是'
        ELSE '否'
    END AS 可传播
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('TS')
    AND dp.name = 'USER1';
GO

PRINT '';
GO

--(4)授予USER2对表 CHOICES的查询,更新成绩的权限
PRINT '========== 题目(4)：授予USER2对表 CHOICES的查询、更新成绩的权限 ==========';

-- 在这里写你的代码
create view CS as select score from CHOICES;

grant select on CS to USER2;
grant update on CS to USER2;

-- 验证权限
PRINT '验证：查看USER2对CHOICES表的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('CS')
    AND dp.name = 'USER2';
GO

PRINT '';
GO

--(5)由USER1授予USER2对表 TEACHERS的查询权限和传播的此项权限的权利
PRINT '========== 题目(5)：由USER1授予USER2对表 TEACHERS的查询权限（带传播权） ==========';

-- 在这里写你的代码
-- 提示：需要使用 EXECUTE AS USER = 'USER1' 来切换到USER1身份

-- 验证权限
PRINT '验证：查看USER2对TEACHERS表的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态,
    CASE
        WHEN p.state = 'W' THEN '是'
        ELSE '否'
    END AS 可传播
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('TS')
    AND dp.name = 'USER2';
GO

PRINT '';
GO

--(6)由USER2授予USER3对表 TEACHERS的查询权限,和传播的此项权限的权利。
--   再由USER3授予USER2上述权限,这样的SQL语句能否成功得到执行?
PRINT '========== 题目(6)：测试权限传播链 ==========';

-- 在这里写你的代码
-- 提示：需要切换USER2和USER3的身份

-- 验证权限
PRINT '验证：查看USER3对TEACHERS表的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态,
    CASE
        WHEN p.state = 'W' THEN '是'
        ELSE '否'
    END AS 可传播
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('TS')
    AND dp.name IN ('USER2', 'USER3');
GO

PRINT '';
GO

--(7)取消USER1对表 TEACHERS的查询权限,考虑由USER2的身份对表 TEACHERS进行查询,操作能否成功?为什么？
PRINT '========== 题目(7)：取消USER1对表 TEACHERS的查询权限，测试USER2 ==========';

-- 在这里写你的代码
revoke select on TS from USER1 cascade;

-- 验证权限
PRINT '验证：查看TS视图的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('TS')
    AND dp.name IN ('USER1', 'USER2', 'USER3','public');
GO

PRINT '';
GO

--(8)取消USER1和USER2的关于表 COURSES的权限
PRINT '========== 题目(8)：取消USER1和USER2关于表 COURSES的权限 ==========';

-- 在这里写你的代码
revoke select on COURSES from USER1;
revoke update on COURSES from USER1;

revoke select on COURSES from USER2;
revoke update on COURSES from USER2;

revoke select on COURSES from public;
revoke update on COURSES from public;

-- 验证权限
PRINT '验证：查看COURSES表的权限';

SELECT
    dp.name AS 用户名,
    permission_name AS 权限类型,
    state_desc AS 状态
FROM sys.database_permissions p
    JOIN sys.database_principals dp ON p.grantee_principal_id = dp.principal_id
WHERE
    p.major_id = OBJECT_ID('COURSES')
    AND dp.name IN ('USER1', 'USER2', 'public');
GO

PRINT '';

PRINT '========== 实验完成 ==========';
GO