-- ========================================
-- LC15 锁争夺与死锁实验脚本
-- 实验目标：
-- 1. 在students表上演示锁争夺，通过sp_who查看阻塞的进程。通过设置lock_timeout解除锁争夺。
-- 2. 在students表上演示死锁。
-- 3. 讨论如何避免死锁以及死锁的处理方法。
-- ========================================

USE School_Data;
GO

PRINT '========== LC15 锁争夺与死锁实验开始 =========='; 
PRINT '';

-- ==================== 环境准备 ====================

PRINT '---- 环境准备：确保测试数据存在 ----';
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

PRINT '当前测试学生数据：';
SELECT * FROM students WHERE sid = '800001216';
PRINT '';

-- 确保没有悬挂事务
IF @@TRANCOUNT > 0 
BEGIN
    ROLLBACK TRANSACTION;
    PRINT '已回滚悬挂事务';
END

PRINT '========== 环境准备完成 ==========';
PRINT '';
GO

/*===============================================================
  实验1：演示锁争夺（Lock Contention）
  
  执行说明：
  本实验需要打开两个独立的SQL Server连接（会话）来演示锁争夺。
  
  步骤：
  1. 在连接1中执行"连接1：更新事务（不提交）"部分的代码
  2. 在连接2中执行"连接2：查询事务（被阻塞）"部分的代码
  3. 在连接3（或任意连接）中执行"查看阻塞情况"部分的代码
  4. 在连接2中执行"使用lock_timeout解决阻塞"部分的代码
===============================================================*/

PRINT '===============================================================';
PRINT '实验1：演示锁争夺（Lock Contention）';
PRINT '===============================================================';
PRINT '';
PRINT '注意：本实验需要多个连接同时执行，请按照以下步骤操作：';
PRINT '1. 打开连接1，执行"连接1：更新事务（不提交）"部分';
PRINT '2. 打开连接2，执行"连接2：查询事务（被阻塞）"部分';
PRINT '3. 打开连接3，执行"查看阻塞情况"部分';
PRINT '4. 在连接2中执行"使用lock_timeout解决阻塞"部分';
PRINT '';
GO

-- ========================================
-- 连接1：更新事务（不提交）
-- 执行说明：在第一个连接中执行此代码块，事务不会提交，保持锁定状态
-- ========================================
PRINT '---- 连接1：更新事务（不提交）----';
PRINT '请在第一个连接中执行以下代码：';
PRINT '';
PRINT 'SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;';
PRINT 'BEGIN TRAN;';
PRINT 'UPDATE students SET grade = 1993 WHERE sid = ''800001216'';';
PRINT 'PRINT ''连接1：已更新数据但未提交，事务保持锁定状态'';';
PRINT 'PRINT ''请保持此连接打开，不要提交或回滚事务'';';
PRINT '-- 注意：不要执行 COMMIT 或 ROLLBACK，保持事务打开';
PRINT '';
GO

-- ========================================
-- 连接2：查询事务（被阻塞）
-- 执行说明：在第二个连接中执行此代码块，会被连接1阻塞
-- ========================================
PRINT '---- 连接2：查询事务（被阻塞）----';
PRINT '请在第二个连接中执行以下代码：';
PRINT '';
PRINT 'SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;';
PRINT 'BEGIN TRAN;';
PRINT 'SELECT * FROM students WHERE sid = ''800001216'';';
PRINT 'COMMIT TRAN;';
PRINT '';
PRINT '预期结果：查询会被阻塞，一直等待连接1释放锁';
PRINT '';
GO

-- ========================================
-- 查看阻塞情况：使用 sp_who
-- 执行说明：在任意连接中执行此代码块，查看进程阻塞情况
-- ========================================
PRINT '---- 查看阻塞情况：使用 sp_who ----';
PRINT '请在任意连接中执行以下代码：';
PRINT '';
PRINT 'EXEC sp_who;';
PRINT '';
PRINT '说明：';
PRINT '- 查看 blk 列，如果值非0，表示该进程被阻塞';
PRINT '- 被阻塞的进程状态为 suspended（挂起）';
PRINT '- 例如：如果进程54的blk值为58，说明进程54被进程58阻塞';
PRINT '';
GO

-- ========================================
-- 使用 lock_timeout 解决阻塞
-- 执行说明：在连接2中执行此代码块，设置锁超时后重新查询
-- ========================================
PRINT '---- 使用 lock_timeout 解决阻塞 ----';
PRINT '请在连接2中执行以下代码（先取消之前的查询，如果还在执行）：';
PRINT '';
PRINT 'SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;';
PRINT 'SET lock_timeout 2000;  -- 设置超时时间为2000毫秒（2秒）';
PRINT 'BEGIN TRAN;';
PRINT 'SELECT * FROM students WHERE sid = ''800001216'';';
PRINT 'COMMIT TRAN;';
PRINT '';
PRINT '预期结果：';
PRINT '- 如果2秒内无法获取锁，将返回错误1222';
PRINT '- 错误消息：已超过了锁请求超时时段';
PRINT '';
GO

-- ========================================
-- 清理：提交或回滚连接1的事务
-- 执行说明：实验完成后，在连接1中执行此代码块
-- ========================================
PRINT '---- 清理：提交或回滚连接1的事务 ----';
PRINT '实验完成后，请在连接1中执行以下代码之一：';
PRINT '';
PRINT '-- 选项1：提交事务（保留更新）';
PRINT 'COMMIT TRAN;';
PRINT '';
PRINT '-- 选项2：回滚事务（撤销更新）';
PRINT 'ROLLBACK TRAN;';
PRINT '';
GO

/*===============================================================
  实验2：演示死锁（Deadlock）
  
  执行说明：
  本实验需要打开两个独立的SQL Server连接（会话）来演示死锁。
  
  步骤：
  1. 在连接1和连接2中同时（或几乎同时）执行"死锁演示代码"部分
  2. 观察其中一个连接成功，另一个连接因死锁被终止
  3. 查看死锁错误信息（错误代码1205）
===============================================================*/

PRINT '';
PRINT '===============================================================';
PRINT '实验2：演示死锁（Deadlock）';
PRINT '===============================================================';
PRINT '';
PRINT '注意：本实验需要两个连接同时执行，请按照以下步骤操作：';
PRINT '1. 打开连接1和连接2';
PRINT '2. 在连接1和连接2中同时（或几乎同时）执行"死锁演示代码"部分';
PRINT '3. 观察执行结果：一个连接成功，另一个连接因死锁被终止';
PRINT '';
GO

-- ========================================
-- 死锁演示代码
-- 执行说明：在连接1和连接2中同时执行此代码块
-- ========================================
PRINT '---- 死锁演示代码 ----';
PRINT '请在连接1和连接2中同时执行以下代码：';
PRINT '';
PRINT 'SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;';
PRINT 'BEGIN TRAN;';
PRINT 'SELECT * FROM students WHERE sid = ''800001216'';  -- 获取共享锁';
PRINT 'WAITFOR DELAY ''00:00:05'';  -- 延时5秒，为死锁创造条件';
PRINT 'UPDATE students SET grade = 1994 WHERE sid = ''800001216'';  -- 尝试转换为排他锁';
PRINT 'COMMIT TRAN;';
PRINT 'SELECT * FROM students WHERE sid = ''800001216'';';
PRINT '';
PRINT '预期结果：';
PRINT '- 连接1：执行成功，成功更新数据';
PRINT '- 连接2：执行失败，返回错误1205（死锁牺牲品）';
PRINT '- 错误消息：事务(进程 ID XX)与另一个进程被死锁在锁资源上,并且已被选作死锁牺牲品';
PRINT '';
GO

-- ========================================
-- 死锁原因分析
-- ========================================
PRINT '---- 死锁原因分析 ----';
PRINT '';
PRINT '死锁产生的原因：';
PRINT '1. 两个连接都通过SELECT语句获取共享锁（Shared Lock）';
PRINT '2. 两个连接都尝试通过UPDATE语句将共享锁升级为排他锁（Exclusive Lock）';
PRINT '3. 由于REPEATABLE READ隔离级别，共享锁在事务完成前不能释放';
PRINT '4. 连接1等待连接2释放共享锁，连接2等待连接1释放共享锁';
PRINT '5. 形成循环等待，导致死锁';
PRINT '6. SQL Server检测到死锁，选择一个事务作为"死锁牺牲品"并终止';
PRINT '';
GO

-- ========================================
-- 验证死锁后的数据状态
-- ========================================
PRINT '---- 验证死锁后的数据状态 ----';
PRINT '死锁实验完成后，执行以下代码查看最终数据：';
PRINT '';
PRINT 'SELECT * FROM students WHERE sid = ''800001216'';';
PRINT '';
PRINT '说明：成功执行的事务会更新数据，被终止的事务会回滚';
PRINT '';
GO

/*===============================================================
  实验3：讨论如何避免死锁以及死锁的处理方法
===============================================================*/

PRINT '';
PRINT '===============================================================';
PRINT '实验3：如何避免死锁以及死锁的处理方法';
PRINT '===============================================================';
PRINT '';
GO

-- ========================================
-- 避免死锁的策略
-- ========================================
PRINT '---- 避免死锁的策略 ----';
PRINT '';
PRINT '1. 统一资源访问顺序';
PRINT '   - 所有事务按照相同的顺序访问资源';
PRINT '   - 例如：总是先访问students表，再访问teachers表';
PRINT '   - 避免不同事务以相反顺序访问相同资源';
PRINT '';
PRINT '2. 减少事务持有锁的时间';
PRINT '   - 尽快提交或回滚事务';
PRINT '   - 避免在事务中执行长时间操作';
PRINT '   - 将长事务拆分为多个短事务';
PRINT '';
PRINT '3. 使用较低的隔离级别';
PRINT '   - 在满足业务需求的前提下，使用较低的隔离级别';
PRINT '   - 较低的隔离级别可以减少锁的持有时间';
PRINT '';
PRINT '4. 使用锁超时';
PRINT '   - 设置合理的 lock_timeout 值';
PRINT '   - 避免事务永久等待';
PRINT '';
PRINT '5. 避免用户交互';
PRINT '   - 不要在事务中等待用户输入';
PRINT '   - 用户交互会延长锁的持有时间';
PRINT '';
GO

-- ========================================
-- 死锁处理方法
-- ========================================
PRINT '---- 死锁处理方法 ----';
PRINT '';
PRINT '1. 错误代码识别';
PRINT '   - 错误代码 1222：锁超时（Lock Timeout）';
PRINT '   - 错误代码 1205：死锁（Deadlock）';
PRINT '';
PRINT '2. 应用程序中的错误处理';
PRINT '   - 在错误处理器中捕获错误1222或1205';
PRINT '   - 自动重新提交事务';
PRINT '';
PRINT '3. 错误处理示例代码：';
PRINT '';
PRINT 'BEGIN TRY';
PRINT '    BEGIN TRAN';
PRINT '    -- 执行数据库操作';
PRINT '    UPDATE students SET grade = 1995 WHERE sid = ''800001216'';';
PRINT '    COMMIT TRAN';
PRINT 'END TRY';
PRINT 'BEGIN CATCH';
PRINT '    IF ERROR_NUMBER() = 1222 OR ERROR_NUMBER() = 1205';
PRINT '    BEGIN';
PRINT '        -- 锁超时或死锁，自动重试';
PRINT '        ROLLBACK TRAN';
PRINT '        PRINT ''发生锁超时或死锁，正在重试...'';';
PRINT '        -- 重新提交事务逻辑';
PRINT '    END';
PRINT '    ELSE';
PRINT '    BEGIN';
PRINT '        -- 其他错误处理';
PRINT '        ROLLBACK TRAN';
PRINT '        PRINT ''错误：'' + ERROR_MESSAGE();';
PRINT '    END';
PRINT 'END CATCH';
PRINT '';
GO

-- ========================================
-- 实际应用示例：带错误处理的事务
-- ========================================
PRINT '---- 实际应用示例：带错误处理的事务 ----';
PRINT '';
PRINT '以下是一个带错误处理和重试机制的事务示例：';
PRINT '';

-- 创建示例存储过程（可选）
IF OBJECT_ID('sp_update_student_grade_safe', 'P') IS NOT NULL
    DROP PROCEDURE sp_update_student_grade_safe;
GO

CREATE PROCEDURE sp_update_student_grade_safe
    @sid CHAR(10),
    @new_grade INT,
    @max_retries INT = 3
AS
BEGIN
    DECLARE @retry_count INT = 0;
    DECLARE @success BIT = 0;
    
    WHILE @retry_count < @max_retries AND @success = 0
    BEGIN
        BEGIN TRY
            BEGIN TRAN;
            
            SET TRANSACTION ISOLATION LEVEL REPEATABLE READ;
            SET lock_timeout 5000;  -- 设置5秒超时
            
            UPDATE students 
            SET grade = @new_grade 
            WHERE sid = @sid;
            
            COMMIT TRAN;
            SET @success = 1;
            PRINT '更新成功';
        END TRY
        BEGIN CATCH
            ROLLBACK TRAN;
            
            IF ERROR_NUMBER() = 1222 OR ERROR_NUMBER() = 1205
            BEGIN
                SET @retry_count = @retry_count + 1;
                PRINT '发生锁超时或死锁（错误代码：' + CAST(ERROR_NUMBER() AS VARCHAR) + '），正在重试...（' + CAST(@retry_count AS VARCHAR) + '/' + CAST(@max_retries AS VARCHAR) + '）';
                WAITFOR DELAY '00:00:01';  -- 等待1秒后重试
            END
            ELSE
            BEGIN
                PRINT '发生其他错误：' + ERROR_MESSAGE();
                BREAK;
            END
        END CATCH
    END
    
    IF @success = 0
    BEGIN
        PRINT '更新失败：已达到最大重试次数';
        RETURN -1;
    END
    
    RETURN 0;
END;
GO

PRINT '存储过程 sp_update_student_grade_safe 创建完成';
PRINT '';
PRINT '使用示例：';
PRINT 'EXEC sp_update_student_grade_safe @sid = ''800001216'', @new_grade = 1996, @max_retries = 3;';
PRINT '';
GO

-- ========================================
-- 锁的类型和兼容性
-- ========================================
PRINT '---- 锁的类型和兼容性 ----';
PRINT '';
PRINT '锁的兼容性矩阵：';
PRINT '';
PRINT '            | 共享锁(S) | 排他锁(X) | 更新锁(U) |';
PRINT '------------|-----------|-----------|-----------|';
PRINT '共享锁(S)   |    兼容   |   不兼容  |    兼容   |';
PRINT '排他锁(X)   |   不兼容  |   不兼容  |   不兼容  |';
PRINT '更新锁(U)   |    兼容   |   不兼容  |   不兼容  |';
PRINT '';
PRINT '锁的升级过程（REPEATABLE READ隔离级别下）：';
PRINT '1. 共享锁（Shared Lock）：读取数据时获取';
PRINT '2. 更新锁（Update Lock）：准备更新时尝试升级';
PRINT '3. 排他锁（Exclusive Lock）：实际执行更新时获取';
PRINT '';
GO

-- ========================================
-- 实验总结
-- ========================================
PRINT '';
PRINT '===============================================================';
PRINT '实验总结';
PRINT '===============================================================';
PRINT '';
PRINT '1. 锁争夺（Lock Contention）';
PRINT '   - 多个事务同时请求同一资源的锁会导致阻塞';
PRINT '   - 可以通过 sp_who 查看阻塞关系';
PRINT '   - 使用 lock_timeout 可以避免永久等待';
PRINT '';
PRINT '2. 死锁（Deadlock）';
PRINT '   - 两个或多个事务相互等待对方释放锁';
PRINT '   - SQL Server自动检测并选择一个牺牲品';
PRINT '   - 牺牲品事务返回错误1205并回滚';
PRINT '';
PRINT '3. 错误处理';
PRINT '   - 错误1222：锁超时';
PRINT '   - 错误1205：死锁';
PRINT '   - 在应用程序中捕获这些错误并自动重试';
PRINT '';
PRINT '4. 最佳实践';
PRINT '   - 统一资源访问顺序';
PRINT '   - 减少事务持有锁的时间';
PRINT '   - 设置合理的锁超时时间';
PRINT '   - 根据业务需求选择合适的隔离级别';
PRINT '';
GO

PRINT '========== LC15 锁争夺与死锁实验结束 =========='; 
GO
