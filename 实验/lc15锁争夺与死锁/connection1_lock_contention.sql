-- ========================================
-- LC15 实验1：锁争夺演示 - 连接1
-- 功能：更新事务（不提交），保持锁定状态
-- 执行说明：
-- 1. 在第一个SQL Server连接中执行此文件
-- 2. 执行后，事务不会提交，保持锁定状态
-- 3. 请保持此连接打开，不要提交或回滚事务
-- 4. 实验完成后，执行 COMMIT 或 ROLLBACK 来结束事务
-- ========================================

USE School_Data;
GO

PRINT '========== 连接1：锁争夺实验 - 更新事务（不提交）==========';
PRINT '';

-- 确保测试学生数据存在
IF NOT EXISTS (SELECT 1 FROM students WHERE sid = '800001216')
BEGIN
    INSERT INTO students (sid, sname, email, grade)
    VALUES ('800001216', 'gfxrgs', 'hhce4@qhldj.gov', 1992);
    PRINT '已插入测试学生数据：800001216';
END
ELSE
BEGIN
    PRINT '测试学生数据已存在：800001216';
END

PRINT '当前测试学生数据（更新前）：';
SELECT * FROM students WHERE sid = '800001216';
PRINT '';

-- 确保没有悬挂事务
IF @@TRANCOUNT > 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT '已回滚悬挂事务';
END

-- 设置隔离级别为 REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
-- 开始事务并更新数据（不提交）
BEGIN TRAN;
UPDATE students 
SET grade = 1993 
WHERE sid = '800001216';

-- 显示更新后的数据（在同一事务中）
PRINT '更新后的数据（在同一事务中）：';
SELECT * FROM students WHERE sid = '800001216';
PRINT '';

PRINT '===============================================================';
PRINT '重要提示：';
PRINT '1. 事务已开始但未提交，数据已被锁定';
PRINT '2. 请保持此连接打开，不要执行 COMMIT 或 ROLLBACK';
PRINT '3. 现在可以在连接2中执行查询操作，观察阻塞现象';
PRINT '4. 实验完成后，执行以下命令之一：';
PRINT '   - COMMIT TRAN;  （提交事务，保留更新）';
PRINT '   - ROLLBACK TRAN;（回滚事务，撤销更新）';
PRINT '===============================================================';

-- 注意：这里故意不提交事务，保持锁定状态
-- 实验完成后，请手动执行 COMMIT 或 ROLLBACK
