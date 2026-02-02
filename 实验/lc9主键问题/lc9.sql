-- ========================================
-- SQL Server 实体完整性实验 (Lecture 9)
-- ========================================

USE School_Data;
GO

-- ==================== 环境准备 ====================

-- 如果表已存在，先删除
IF OBJECT_ID('class', 'U') IS NOT NULL
    DROP TABLE class;
GO

PRINT '========== 环境准备完成 ==========';
PRINT '';
GO

-- ==================== 实验题目 ====================

--(1) 在school数据库中建立一张新表class，包括class_id(varchar(4)), name(varchar(10)), department(varchar(20))三个列，并约束class_id为主键。

PRINT '========== 题目(1)：创建class表并设置主键 ==========';

-- 在这里写你的代码
CREATE TABLE class(
    class_id varchar(5)  PRIMARY KEY,
    name varchar(10),
    department varchar(20)
)

-- 验证表结构
PRINT '验证：查看class表的结构';
EXEC sp_help 'class';

PRINT '';
GO

--(2) 创建事务T3，在事务中插入一个元组（'0001'，'01CSC','CS'）,并在T3中嵌套创建事务T4，T4也插入和T3一样的元组，编写代码测试，查看结果。

PRINT '========== 题目(2)：测试嵌套事务中的主键冲突 ==========';

-- 设置XACT_ABORT OFF，使得错误发生时不自动回滚整个事务
SET XACT_ABORT OFF

BEGIN TRANSACTION T3
    INSERT INTO class VALUES ('0001','01CSC','CS');
    
    BEGIN TRANSACTION T4
        INSERT INTO class VALUES ('0001','01CSC','CS');  -- 违反主键约束
    COMMIT TRANSACTION T4
    
COMMIT TRANSACTION T3

-- 实验结果：
-- 1. T3中的第一条INSERT成功执行
-- 2. T4中的第二条INSERT违反主键约束，报错：Violation of PRIMARY KEY constraint
-- 3. 由于XACT_ABORT OFF，T4的错误不会导致T3回滚
-- 4. T3成功提交，表中有1条记录（'0001','01CSC','CS'）

-- 查看表中的数据
PRINT '查看表中的数据：';
SELECT * FROM class;

PRINT '';
GO

--(3) 在表class中，尝试设置name='01CSC'的记录的class_id 为NULL，查看结果

PRINT '========== 题目(3)：尝试将主键设置为NULL ==========';

UPDATE class SET class_id = NULL WHERE name = '01CSC';

-- 实验结果：
-- 报错：Cannot insert the value NULL into column 'class_id'
-- 原因：主键约束包含两个限制：
--   1. NOT NULL约束：主键列不允许为NULL
--   2. UNIQUE约束：主键列的值必须唯一
-- 因此，无法将主键列的值更新为NULL

-- 查看表中的数据
PRINT '查看表中的数据：';
SELECT * FROM class;

PRINT '';
GO

--(4) 在表class中，不创建事务，插入两个元组（'0002'，'01CSC','CS'），（'0002'，'03CSC'，'CS'），然后查看表中有几条记录，为什么？

PRINT '========== 题目(4)：测试批量插入时的主键冲突 ==========';

INSERT INTO class VALUES ('0002','01CSC','CS');
INSERT INTO class VALUES ('0002','03CSC','CS');

-- 实验结果：
-- 1. 第一条INSERT成功执行，插入('0002','01CSC','CS')
-- 2. 第二条INSERT违反主键约束，报错：Violation of PRIMARY KEY constraint
-- 3. 表中有2条记录：('0001','01CSC','CS') 和 ('0002','01CSC','CS')
-- 
-- 原因分析：
-- 在SQL Server中，每条INSERT语句是一个独立的语句
-- 第一条INSERT成功后立即提交（因为没有显式事务）
-- 第二条INSERT失败不会影响第一条已提交的记录
-- 这与在事务中的行为不同

-- 查看表中的数据
PRINT '查看表中有几条记录：';
SELECT COUNT(*) AS 记录数 FROM class;
SELECT * FROM class;

PRINT '';
GO

--(5) 在表class中，创建事务，并设置开启回滚，然后插入两个元组（'0003'，'03CSC','CS'），（'0001'，'03CSC'，'CS'），查看结果，表中有几条记录？

PRINT '========== 题目(5)：测试事务回滚对主键冲突的影响 ==========';

SET XACT_ABORT O
BEGIN TRANSACTION T
    INSERT INTO class VALUES ('0003','03CSC','CS');
    INSERT INTO class VALUES ('0001','03CSC','CS');  -- 违反主键约束，'0001'已存在
COMMIT TRANSACTION T

-- 实验结果：
-- 1. 第一条INSERT成功执行
-- 2. 第二条INSERT违反主键约束，报错
-- 3. 由于XACT_ABORT OFF，错误不会自动回滚事务
-- 4. COMMIT语句仍然执行，提交了第一条成功的INSERT
-- 5. 表中有3条记录：('0001',...), ('0002',...), ('0003',...)
--
-- 对比实验：如果设置SET XACT_ABORT ON
-- 则第二条INSERT失败时会自动回滚整个事务
-- 第一条INSERT也不会被提交，表中仍然只有2条记录

-- 查看表中有几条记录
PRINT '查看表中有几条记录：';
SELECT COUNT(*) AS 记录数 FROM class;
SELECT * FROM class;


SET XACT_ABORT OFF
BEGIN TRANSACTION T
INSERT INTO class values ('0003','03CSC','CS');
INSERT INTO class values ('0001','03CSC','CS');
Commit TRANSACTION T

-- 查看表中有几条记录
PRINT '查看表中有几条记录：';
SELECT COUNT(*) AS 记录数 FROM class;
SELECT * FROM class;

PRINT '';
GO

--(6) 在完成上面几步的前提下，尝试设置'name'为主键，看能否成功，并思考原因。

PRINT '========== 题目(6)：尝试将name列设置为主键 ==========';

-- 尝试直接添加主键约束（不删除原有主键）
ALTER TABLE class ADD CONSTRAINT class_name_pk PRIMARY KEY (name);

-- 实验结果：
-- 报错：Table 'class' already has a primary key defined on it.
-- 
-- 原因分析：
-- 1. 一个表只能有一个主键约束
-- 2. class表已经在class_id列上定义了主键
-- 3. 必须先删除原有主键约束，才能在其他列上创建新的主键
--
-- 正确的做法应该是：
-- 1. 先查找主键约束的名称：
--    SELECT name FROM sys.key_constraints 
--    WHERE type = 'PK' AND parent_object_id = OBJECT_ID('class');
-- 2. 删除原有主键：ALTER TABLE class DROP CONSTRAINT [约束名];
-- 3. 创建新主键：ALTER TABLE class ADD CONSTRAINT class_name_pk PRIMARY KEY (name);
--
-- 但即使删除了原有主键，在name列上创建主键也可能失败，因为：
-- 表中存在name列值重复的记录（'01CSC'出现了2次）
-- 主键要求列值唯一，所以会失败

-- 查看表结构
PRINT '查看表结构：';
EXEC sp_help 'class';

-- 查看表中的数据
PRINT '查看表中的数据：';
SELECT * FROM class;

PRINT '';
GO

PRINT '========== 实验完成 ==========';
GO
