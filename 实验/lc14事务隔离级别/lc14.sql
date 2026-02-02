-- ========================================
-- LC14 事务隔离级别实验脚本
-- 结合笔记中的实验目标：演示脏读、不可重复读、幻象读以及隔离级别的防护能力
-- 表使用 school_data.students / teachers（假定已存在），可按需调整表名
-- ========================================

USE school_data;
GO

PRINT '========== LC14 隔离级别实验开始 =========='; 
PRINT '';

-- 通用辅助：确保没有悬挂事务
IF @@TRANCOUNT > 0 ROLLBACK TRANSACTION;

/*===============================================================
  1. READ UNCOMMITTED 未提交读：演示脏读
     事务A更新 salary 不提交；事务B 在 READ UNCOMMITTED 下读取
===============================================================*/
PRINT '---- 实验1：READ UNCOMMITTED 演示脏读 ----';
PRINT '';

-- 事务A：更新后延时再回滚
BEGIN TRANSACTION;
    UPDATE teachers SET salary = salary + 100 WHERE tid = '200003125';
    PRINT '事务A：已更新 salary（未提交），当前值：';
    SELECT tid, salary FROM teachers WHERE tid = '200003125';
    WAITFOR DELAY '00:00:05'; -- 窗口供事务B读取
ROLLBACK TRANSACTION;
PRINT '事务A：已回滚';
PRINT '';

-- 事务B：未提交读（脏读）
SET TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
PRINT '事务B：READ UNCOMMITTED 读取（可能读到脏数据）';
SELECT tid, salary FROM teachers WHERE tid = '200003125';
PRINT '';
SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- 恢复默认

/*===============================================================
  2. READ COMMITTED 提交读：防止脏读，但可能不可重复读
     事务A两次读取；事务B中途提交更新，观察两次读取不一致
===============================================================*/
PRINT '---- 实验2：READ COMMITTED 防脏读、演示不可重复读 ----';
PRINT '';

-- 事务B：提交读
SET TRANSACTION ISOLATION LEVEL READ COMMITTED;
BEGIN TRANSACTION;
    DECLARE @s1 INT, @s2 INT;
    SELECT @s1 = salary FROM teachers WHERE tid = '200003125';
    PRINT '事务B 第一次读取 salary=' + CAST(@s1 AS VARCHAR);
    
    WAITFOR DELAY '00:00:05'; -- 期间由事务A更新提交
    
    SELECT @s2 = salary FROM teachers WHERE tid = '200003125';
    PRINT '事务B 第二次读取 salary=' + CAST(@s2 AS VARCHAR);
COMMIT TRANSACTION;
PRINT '对比：若 @s1 != @s2，发生不可重复读（允许，因为共享锁读后释放）';
PRINT '';

/* 在上述等待期间运行的事务A（示意，手动或另会话执行）：
BEGIN TRAN
UPDATE teachers SET salary = salary + 50 WHERE tid='200003125';
COMMIT;
*/

/*===============================================================
  3. REPEATABLE READ 可重复读：防脏读、防不可重复读，但仍可能幻象读
     事务B两次读取同一行，事务A尝试更新会被阻塞；但插入新行可能形成幻象
===============================================================*/
PRINT '---- 实验3：REPEATABLE READ 防不可重复读，幻象读仍可能 ----';
PRINT '';

SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRANSACTION;
    DECLARE @r1 INT, @r2 INT;
    SELECT @r1 = salary FROM teachers WHERE tid = '200003125';
    PRINT 'RR 第一次读取 salary=' + CAST(@r1 AS VARCHAR);
    
    WAITFOR DELAY '00:00:10'; -- 期间：更新同一行会被阻塞；插入新的 tid 记录仍可出现幻象
    
    SELECT @r2 = salary FROM teachers WHERE tid = '200003125';
    PRINT 'RR 第二次读取 salary=' + CAST(@r2 AS VARCHAR);
COMMIT TRANSACTION;
PRINT '若 @r1 == @r2：不可重复读被防止。仍需注意范围内插入/删除导致幻象读。';
PRINT '';

SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- 恢复

/* 可选补充：演示幻象读（REPEATABLE READ 仍可能出现）
   会话B：范围查询两次；会话A：在间隙插入同范围的新行

-- 会话B
SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
BEGIN TRAN;
    PRINT 'RR 幻象读演示：第一次范围查询';
    SELECT tid, salary FROM teachers WHERE tid BETWEEN '200003100' AND '200003200';
    WAITFOR DELAY '00:00:10'; -- 期间会话A插入同范围新行
    PRINT 'RR 幻象读演示：第二次范围查询';
    SELECT tid, salary FROM teachers WHERE tid BETWEEN '200003100' AND '200003200';
COMMIT;

-- 会话A（在等待窗口执行）
INSERT INTO teachers (tid, tname, email, salary)
VALUES ('200003150', 'phantom', 'phantom@example.com', 4000);

说明：若第二次查询多出插入的新行，即出现幻象读。SQL Server 需要 SERIALIZABLE 才阻止此类插入。
*/

/*===============================================================
  4. SERIALIZABLE 可串行化：最高隔离，防脏读/不可重复读/幻象读
     事务B两次范围查询；事务A尝试插入/更新同范围将被阻塞
===============================================================*/
PRINT '---- 实验4：SERIALIZABLE 防止所有并发读问题 ----';
PRINT '';

SET TRANSACTION ISOLATION LEVEL SERIALIZABLE;
BEGIN TRANSACTION;
    PRINT 'SERIALIZABLE 第一次范围查询（tid between 200003100 and 200003200）';
    SELECT tid, salary FROM teachers WHERE tid BETWEEN '200003100' AND '200003200';
    
    WAITFOR DELAY '00:00:05'; -- 期间插入/删除/更新该范围将被阻塞
    
    PRINT 'SERIALIZABLE 第二次范围查询';
    SELECT tid, salary FROM teachers WHERE tid BETWEEN '200003100' AND '200003200';
COMMIT TRANSACTION;
PRINT '范围锁防止幻象读，确保两次结果一致';
PRINT '';

SET TRANSACTION ISOLATION LEVEL READ COMMITTED; -- 恢复默认

PRINT '========== LC14 隔离级别实验结束 =========='; 
GO