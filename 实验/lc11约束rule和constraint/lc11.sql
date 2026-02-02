-- 创建Worker表
Use SCHOOL_data

-- 清理：删除可能存在的规则绑定和规则
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'R2' AND type = 'R')
BEGIN
    EXEC sp_unbindrule 'Worker.Sage'
    DROP RULE R2
END

IF EXISTS (SELECT * FROM sys.objects WHERE name = 'R3' AND type = 'R')
BEGIN
    EXEC sp_unbindrule 'Worker.Sage'
    DROP RULE R3
END

-- 清理：删除可能存在的表
IF EXISTS (SELECT * FROM sys.objects WHERE name = 'Worker' AND type = 'U')
    DROP TABLE Worker

-- 创建Worker表
Create Table Worker(
    Number char(5),
    Name char(8) constraint U1 unique,
    Sex char(1),
    Sage int constraint U2 check (Sage<=28),
    Department char(20),
    constraint PK_Worker Primary Key (Number)
)

Insert into Worker (Number, Name, Sex, Sage, Department) Values ('00001', '李勇', 'M', 14, '科技部')

Select * From Worker

-- ============================================
-- 以下练习均在worker表上进行（请按照示例中worker建表）
-- ============================================

-- (1) 加入约束U3，令sage值大于等于0。
ALTER TABLE Worker ADD CONSTRAINT U3 CHECK (Sage >= 0)


-- (2) 演示插入违反约束U3的记录。
INSERT INTO Worker (Number, Name, Sex, Sage, Department) VALUES ('00002', '王二', 'M', -2, '科技部')


-- (3) 演示插入不违反约束U3的记录。
INSERT INTO Worker (Number, Name, Sex, Sage, Department) VALUES ('00002', '王二', 'M', 2, '科技部')
select * from Worker;

-- (4) 加入约束U4，令sage值<0，观察执行是否成功，分析原因。
ALTER TABLE Worker ADD CONSTRAINT U4 CHECK (Sage < 0)


-- (5) 加入规则R2，确保插入的记录的sage值在1到100之间，并绑定到sage属性。
CREATE RULE R2 AS @sage BETWEEN 1 AND 100
GO
EXEC sp_bindrule 'R2', 'Worker.Sage'


-- (6) 演示插入违反R2的记录。
INSERT INTO Worker (Number, Name, Sex, Sage, Department) VALUES ('00003', '陈三', 'M', 0, '创新部')

-- (7) 解除规则R2的绑定，并重复(6)的操作。
EXEC sp_unbindrule 'Worker.Sage'
INSERT INTO Worker (Number, Name, Sex, Sage, Department) VALUES ('00003', '陈三', 'M', 0, '创新部')
select * from Worker;


-- (8) 已知示例三中已插入sage为38的记录，那么加入规则R3，令sage大于50。观察加入规则R3的操作是否能成功。
CREATE RULE R3 AS @sage > 50
GO
EXEC sp_bindrule 'R3', 'Worker.Sage'
INSERT INTO Worker (Number, Name, Sex, Sage, Department) VALUES ('00004', '张四', 'M', 38, '销售部')
select * from Worker;
