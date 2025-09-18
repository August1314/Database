/*
数据库表设计练习 - 第二周

(1)创建数据库表 CUSTOMERS(CID, CNAME,CITY, DISCNT)，数据库表AGENTS(AID, ANAME,CITY, PERCENT)，数据库表 PRODUCTS(PID, PNAME)，其中，CID，AID, PID分别是各表的主键，具有唯一性约束，表AGENTS中的PERCENT属性具有小于100的约束。
(2)创建数据库表 ORDERS( ORDNA, MONTH,CID,AID,PID,QTY, DOLLARS)。其中， ORDNA是主键，具有唯一性约束。CID，AID，PID是外键，分别参照的是表 CUSTOMERS的CID字段，表 AGENTS的AID字段，表 PRODUCTS的PID字段。
(3)增加数据库表 PRODUCTS的三个属性列：CITY, QUANTITY, PRICE。
(4)为以上4个表建立各自的按主键增序排列的索引。
(5)取消步骤(4)建立的4个索引。
(6)创建表CUSTOMERS的按CNAME降序排列的唯一性索引。
(7)删除表AGENTS中的CITY属性。
(8)修改表CUSTOMERS中CITY属性为CHAR(40)
(9)删除表ORDERS
*/

-- 使用数据库
USE class2;

-- ===========================================
-- 清理现有表（如果存在）
-- ===========================================
-- 删除可能存在的表（按依赖关系顺序）
IF OBJECT_ID('ORDERS', 'U') IS NOT NULL DROP TABLE ORDERS;
IF OBJECT_ID('CUSTOMERS', 'U') IS NOT NULL DROP TABLE CUSTOMERS;
IF OBJECT_ID('AGENTS', 'U') IS NOT NULL DROP TABLE AGENTS;
IF OBJECT_ID('PRODUCTS', 'U') IS NOT NULL DROP TABLE PRODUCTS;

-- ===========================================
-- 任务(1): 创建基础表
-- ===========================================
-- 1. 先创建被引用的表
CREATE TABLE CUSTOMERS (
    CID INT PRIMARY KEY,
    CNAME NVARCHAR(50) NOT NULL,
    CITY NVARCHAR(50),
    DISCNT DECIMAL(5,2)
);

CREATE TABLE AGENTS (
    AID INT PRIMARY KEY,
    ANAME NVARCHAR(50) NOT NULL,
    CITY NVARCHAR(50),
    [PERCENT] DECIMAL(5,2) CHECK ([PERCENT] < 100)
);

CREATE TABLE PRODUCTS (
    PID INT PRIMARY KEY,
    PNAME NVARCHAR(100) NOT NULL
);

-- 2. 最后创建 ORDERS 表（包含外键约束）
CREATE TABLE ORDERS (
    ORDNA INT PRIMARY KEY,
    MONTH NVARCHAR(10),
    CID INT NOT NULL,
    AID INT NOT NULL,
    PID INT NOT NULL,
    QTY INT,
    DOLLARS DECIMAL(10,2),

    -- 外键约束（使用显式约束名）
    CONSTRAINT FK_ORDERS_CUSTOMERS FOREIGN KEY (CID) REFERENCES CUSTOMERS(CID),
    CONSTRAINT FK_ORDERS_AGENTS FOREIGN KEY (AID) REFERENCES AGENTS(AID),
    CONSTRAINT FK_ORDERS_PRODUCTS FOREIGN KEY (PID) REFERENCES PRODUCTS(PID)
);

-- 结果查看（步骤1 与 步骤2：建表与外键）
-- 查看已创建的基础表
SELECT name AS TableName
FROM sys.tables
WHERE name IN ('CUSTOMERS','AGENTS','PRODUCTS','ORDERS')
ORDER BY name;

-- 查看 ORDERS 外键信息
SELECT fk.name AS FK_Name,
       OBJECT_NAME(fk.parent_object_id) AS ParentTable,
       OBJECT_NAME(fk.referenced_object_id) AS ReferencedTable
FROM sys.foreign_keys fk
WHERE fk.parent_object_id = OBJECT_ID('ORDERS');

-- 查看各表列定义（简要）
SELECT 'CUSTOMERS' AS TableName, COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'CUSTOMERS'
UNION ALL
SELECT 'AGENTS', COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'AGENTS'
UNION ALL
SELECT 'PRODUCTS', COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'PRODUCTS'
UNION ALL
SELECT 'ORDERS', COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS WHERE TABLE_NAME = 'ORDERS';

-- ===========================================
-- 任务(3): 增加数据库表 PRODUCTS的三个属性列：CITY, QUANTITY, PRICE
-- ===========================================
ALTER TABLE PRODUCTS 
ADD CITY NVARCHAR(50), 
    QUANTITY INT, 
    PRICE DECIMAL(10,2);

-- 结果查看（步骤3：PRODUCTS 新增列）
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'PRODUCTS' AND COLUMN_NAME IN ('CITY','QUANTITY','PRICE')
ORDER BY COLUMN_NAME;

-- ===========================================
-- 任务(4): 为以上4个表建立各自的按主键增序排列的索引
-- ===========================================
-- 注意：主键会自动创建聚集索引，所以我们创建非聚集索引
-- 聚集索引：每个表只能有一个，决定数据的物理存储顺序
-- 非聚集索引：每个表可以有多个，不影响数据的物理存储顺序
-- 为 CUSTOMERS 表创建主键非聚集索引（升序）
CREATE UNIQUE NONCLUSTERED INDEX IDX_CUSTOMERS_CID
ON CUSTOMERS (CID ASC);

-- 为 AGENTS 表创建主键非聚集索引（升序）
CREATE UNIQUE NONCLUSTERED INDEX IDX_AGENTS_AID
ON AGENTS (AID ASC);

-- 为 PRODUCTS 表创建主键非聚集索引（升序）
CREATE UNIQUE NONCLUSTERED INDEX IDX_PRODUCTS_PID
ON PRODUCTS (PID ASC);

-- 为 ORDERS 表创建主键非聚集索引（升序）
CREATE UNIQUE NONCLUSTERED INDEX IDX_ORDERS_ORDNA
ON ORDERS (ORDNA ASC);

-- 结果查看（步骤4：四个主键索引/非聚集索引）
SELECT OBJECT_NAME(i.object_id) AS TableName,
       i.name AS IndexName,
       i.is_unique AS IsUnique,
       i.type_desc AS IndexType
FROM sys.indexes i
WHERE i.name IN ('IDX_CUSTOMERS_CID','IDX_AGENTS_AID','IDX_PRODUCTS_PID','IDX_ORDERS_ORDNA')
ORDER BY TableName, IndexName;

-- ===========================================
-- 任务(5): 取消步骤(4)建立的4个索引
-- ===========================================
-- 删除 CUSTOMERS 表的索引
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_CUSTOMERS_CID' AND object_id = OBJECT_ID('CUSTOMERS'))
    DROP INDEX IDX_CUSTOMERS_CID ON CUSTOMERS;

-- 删除 AGENTS 表的索引
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_AGENTS_AID' AND object_id = OBJECT_ID('AGENTS'))
    DROP INDEX IDX_AGENTS_AID ON AGENTS;

-- 删除 PRODUCTS 表的索引
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_PRODUCTS_PID' AND object_id = OBJECT_ID('PRODUCTS'))
    DROP INDEX IDX_PRODUCTS_PID ON PRODUCTS;

-- 删除 ORDERS 表的索引
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_ORDERS_ORDNA' AND object_id = OBJECT_ID('ORDERS'))
    DROP INDEX IDX_ORDERS_ORDNA ON ORDERS;

-- 结果查看（步骤5：索引删除）
SELECT OBJECT_NAME(i.object_id) AS TableName,
       i.name AS IndexName
FROM sys.indexes i
WHERE i.name IN ('IDX_CUSTOMERS_CID','IDX_AGENTS_AID','IDX_PRODUCTS_PID','IDX_ORDERS_ORDNA');

-- ===========================================
-- 任务(6): 创建表CUSTOMERS的按CNAME降序排列的唯一性索引
-- ===========================================
-- 先删除可能存在的同名索引
IF EXISTS (SELECT * FROM sys.indexes WHERE name = 'IDX_CUSTOMERS_CNAME_DESC' AND object_id = OBJECT_ID('CUSTOMERS'))
    DROP INDEX IDX_CUSTOMERS_CNAME_DESC ON CUSTOMERS;

CREATE UNIQUE NONCLUSTERED INDEX IDX_CUSTOMERS_CNAME_DESC
ON CUSTOMERS (CNAME DESC);

-- 结果查看（步骤6：唯一索引 CNAME 降序）
SELECT OBJECT_NAME(i.object_id) AS TableName,
       i.name AS IndexName,
       i.is_unique AS IsUnique,
       i.type_desc AS IndexType
FROM sys.indexes i
WHERE i.name = 'IDX_CUSTOMERS_CNAME_DESC';

-- ===========================================
-- 任务(7): 删除表AGENTS中的CITY属性
-- ===========================================
ALTER TABLE AGENTS DROP COLUMN CITY;

-- 结果查看（步骤7：AGENTS 列删除）
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'AGENTS';

-- ===========================================
-- 任务(8): 修改表CUSTOMERS中CITY属性为CHAR(40)
-- ===========================================
ALTER TABLE CUSTOMERS 
ALTER COLUMN CITY CHAR(40);

-- 结果查看（步骤8：CUSTOMERS 列类型变更）
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'CUSTOMERS' AND COLUMN_NAME = 'CITY';

-- ===========================================
-- 任务(9): 删除表ORDERS
-- ===========================================
DROP TABLE ORDERS;

-- 结果查看（步骤9：ORDERS 表删除）
SELECT name AS TableName
FROM sys.tables
WHERE name = 'ORDERS';

-- ===========================================
-- 验证结果
-- ===========================================
-- 查看所有表
SELECT TABLE_NAME 
FROM INFORMATION_SCHEMA.TABLES 
WHERE TABLE_TYPE = 'BASE TABLE';

-- 查看 CUSTOMERS 表结构
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'CUSTOMERS';

-- 查看 AGENTS 表结构
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'AGENTS';

-- 查看 PRODUCTS 表结构
SELECT COLUMN_NAME, DATA_TYPE, CHARACTER_MAXIMUM_LENGTH, IS_NULLABLE
FROM INFORMATION_SCHEMA.COLUMNS 
WHERE TABLE_NAME = 'PRODUCTS';