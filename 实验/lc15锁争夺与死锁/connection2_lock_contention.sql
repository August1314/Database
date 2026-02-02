-- ========================================
-- LC15 实验1：锁争夺演示 - 连接2
-- 功能：查询事务（被阻塞），然后使用lock_timeout解决阻塞
-- 执行说明：
-- 1. 在第二个SQL Server连接中执行此文件
-- 2. 先执行"步骤1：查询事务（被阻塞）"部分
-- 3. 观察阻塞现象（查询会一直等待）
-- 4. 取消查询（如果还在执行），然后执行"步骤2：使用lock_timeout"部分
-- ========================================

USE School_Data;
GO

PRINT '========== 连接2：锁争夺实验 - 查询事务（被阻塞）==========';
PRINT '';
PRINT '注意：请确保连接1已经执行了connection1_lock_contention.sql';
PRINT '并且连接1的事务未提交（保持锁定状态）';
PRINT '';

-- ========================================
-- 步骤1：查询事务（被阻塞）
-- ========================================
PRINT '===============================================================';
PRINT '步骤1：查询事务（被阻塞）';
PRINT '===============================================================';
PRINT '';
PRINT '执行以下代码，观察阻塞现象：';
PRINT '';

-- 设置隔离级别为 REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;
SELECT * FROM students WHERE sid = '800001216';

COMMIT TRAN;

PRINT '步骤1完成';
PRINT '';
PRINT '===============================================================';
PRINT '如果查询被阻塞，请执行以下操作：';
PRINT '1. 取消当前查询（如果还在执行）';
PRINT '2. 继续执行下面的"步骤2：使用lock_timeout"部分';
PRINT '===============================================================';
PRINT '';
GO

-- ========================================
-- 步骤2：使用lock_timeout解决阻塞
-- ========================================
PRINT '===============================================================';
PRINT '步骤2：使用lock_timeout解决阻塞';
PRINT '===============================================================';
PRINT '';
PRINT '执行以下代码，设置锁超时后重新查询：';
PRINT '';

-- 确保没有悬挂事务
IF @@TRANCOUNT > 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT '已回滚悬挂事务';
END

-- 设置隔离级别为 REPEATABLE READ
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;

-- 设置锁超时时间为2000毫秒（2秒）
SET lock_timeout 2000;
BEGIN TRY
    BEGIN TRAN;
    SELECT * FROM students WHERE sid = '800001216';
    COMMIT TRAN;
END TRY
BEGIN CATCH
    ROLLBACK TRAN;
    
    IF ERROR_NUMBER() = 1222
    BEGIN
        PRINT '===============================================================';
    END
    ELSE
    BEGIN
        PRINT '发生其他错误：';
        PRINT '错误代码：' + CAST(ERROR_NUMBER() AS VARCHAR);
        PRINT '错误消息：' + ERROR_MESSAGE();
    END
END CATCH


