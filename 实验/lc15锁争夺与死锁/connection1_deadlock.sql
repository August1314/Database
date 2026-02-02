-- ========================================
-- LC15 实验2：死锁演示 - 连接1
-- 功能：执行死锁演示代码（连接1）
-- 执行说明：
-- 1. 在第一个SQL Server连接中执行此文件
-- 2. 同时（或几乎同时）在连接2中执行 connection2_deadlock.sql
-- 3. 观察执行结果：一个连接成功，另一个连接因死锁被终止
-- ========================================

USE School_Data;
GO

PRINT '========== 连接1：死锁实验 ==========';

-- 确保测试学生数据存在
IF NOT EXISTS (SELECT 1 FROM students WHERE sid = '800001216')
BEGIN
    INSERT INTO students (sid, sname, email, grade)
    VALUES ('800001216', 'gfxrgs', 'hhce4@qhldj.gov', 1992);
    PRINT '已插入测试学生数据：800001216';
END

-- 确保没有悬挂事务
IF @@TRANCOUNT > 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT '已回滚悬挂事务';
END

-- 显示当前数据
PRINT '当前数据（事务开始前）：';
SELECT * FROM students WHERE sid = '800001216';
PRINT '';

-- 设置隔离级别为 REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRY
    BEGIN TRAN;

    SELECT * FROM students WHERE sid = '800001216';

    WAITFOR DELAY '00:00:05';

    UPDATE students 
    SET grade = 1994 
    WHERE sid = '800001216';
    COMMIT TRAN;

    SELECT * FROM students WHERE sid = '800001216';
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    
    IF ERROR_NUMBER() = 1205
    BEGIN
        PRINT '===============================================================';
        PRINT '连接1：发生死锁，被选作死锁牺牲品';
        PRINT '错误代码：1205';
        PRINT '错误消息：' + ERROR_MESSAGE();
        PRINT '===============================================================';
        PRINT '';
        PRINT '说明：SQL Server检测到死锁，选择此事务作为牺牲品并终止';
        PRINT '事务已自动回滚';
        PRINT '';
    END
    ELSE
    BEGIN
        PRINT '===============================================================';
        PRINT '连接1：发生其他错误';
        PRINT '错误代码：' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT '错误消息：' + ERROR_MESSAGE();
        PRINT '===============================================================';
    END
END CATCH

PRINT '';
PRINT '===============================================================';
PRINT '实验说明：';
PRINT '1. 如果连接1成功，说明连接2被选作死锁牺牲品';
PRINT '2. 如果连接1失败（错误1205），说明连接1被选作死锁牺牲品';
PRINT '3. 死锁牺牲品的事务会被自动回滚';
PRINT '4. 成功的事务会正常提交并更新数据';
PRINT '===============================================================';

