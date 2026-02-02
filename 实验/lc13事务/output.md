[2025-12-04 11:04:30] School_Data> USE school_data
[2025-12-04 11:04:30] [S0001][5701] Changed database context to 'School_Data'.
[2025-12-04 11:04:30] 在 6 ms 内完成
[2025-12-04 11:04:30] School_Data> PRINT '========== 开始环境准备 ==========';
                                   PRINT '';
                                   
                                   -- 检查并清理未提交的事务（确保可重复运行）
                                   IF @@TRANCOUNT > 0
                                   BEGIN
                                       PRINT '警告：检测到未提交的事务，正在回滚...';
                                       ROLLBACK TRANSACTION;
                                   END
                                   
                                   -- 清理可能存在的存储过程
                                   IF OBJECT_ID('sp_update_course_hour', 'P') IS NOT NULL 
                                       DROP PROCEDURE sp_update_course_hour;
========== 开始环境准备 ==========

[2025-12-04 11:04:30] 在 17 ms 内完成
[2025-12-04 11:04:30] School_Data> PRINT '环境清理完成';
                                   PRINT '';
                                   
                                   -- 确保测试数据存在（如果不存在则插入，如果存在则恢复初始值）
                                   -- 检查并插入/恢复测试学生数据
                                   IF NOT EXISTS (SELECT 1 FROM students WHERE sid = '800001216')
                                       INSERT INTO students VALUES ('800001216', '张三', 'zhangsan@example.com', 2023);
                                   ELSE
                                       UPDATE students SET sname = '张三', email = 'zhangsan@example.com', grade = 2023 WHERE sid = '800001216';
                                   
                                   IF NOT EXISTS (SELECT 1 FROM students WHERE sid = '800005753')
                                       INSERT INTO students VALUES ('800005753', '李四', 'lisi@example.com', 2023);
                                   ELSE
                                       UPDATE students SET sname = '李四', email = 'lisi@example.com', grade = 2023 WHERE sid = '800005753';
                                   
                                   -- 检查并插入/恢复测试教师数据
                                   IF NOT EXISTS (SELECT 1 FROM teachers WHERE tid = 'T001')
                                       INSERT INTO teachers VALUES ('T001', '王老师', 'wang@example.com', 5000);
                                   ELSE
                                       UPDATE teachers SET tname = '王老师', email = 'wang@example.com', salary = 5000 WHERE tid = 'T001';
                                   
                                   IF NOT EXISTS (SELECT 1 FROM teachers WHERE tid = 'T002')
                                       INSERT INTO teachers VALUES ('T002', '李老师', 'li@example.com', 6000);
                                   ELSE
                                       UPDATE teachers SET tname = '李老师', email = 'li@example.com', salary = 6000 WHERE tid = 'T002';
                                   
                                   PRINT '测试数据准备完成';
                                   PRINT '========== 环境准备完成 ==========';
                                   PRINT '';
环境清理完成

测试数据准备完成
========== 环境准备完成 ==========

[2025-12-04 11:04:30] 6 ms 中有 4 行受到影响
[2025-12-04 11:04:30] School_Data> -- 题目1: 编写一个嵌套事务。外层修改students表某记录，内层在teachers表插入一条记录。
                                   -- 演示内层插入操作失败后，外层修改操作回滚。
                                   PRINT '========== 题目1：嵌套事务演示 ==========';
                                   PRINT '';
                                   
                                   BEGIN TRANSACTION OuterTransaction;
                                       -- 外层事务：修改students表
                                       BEGIN TRY
                                           UPDATE students
                                           SET sname = '张三（已修改）'
                                           WHERE sid = '800001216';
                                           
                                           -- 内层事务：插入teachers表（使用已存在的tid，会违反主键约束）
                                           BEGIN TRANSACTION InnerTransaction;
                                               BEGIN TRY
                                                   -- 尝试插入一个已存在的tid，会导致主键冲突
                                                   INSERT INTO teachers (tid, tname, email, salary)
                                                   VALUES ('T001', '新教师', 'newteacher@example.com', 7000);
                                                   
                                                   COMMIT TRANSACTION InnerTransaction;
                                               END TRY
                                               BEGIN CATCH
                                                   PRINT '内层事务失败：' + ERROR_MESSAGE();
                                                   -- 在SQL Server中，ROLLBACK TRANSACTION（无名称）会回滚所有嵌套事务
                                                   -- 回滚后，@@TRANCOUNT 变为 0，事务完全结束
                                                   ROLLBACK TRANSACTION;
                                                   -- 抛出错误，让外层CATCH处理
                                                   THROW;
                                               END CATCH
                                           
                                           -- 如果内层事务失败，这里不会执行（因为THROW会跳转到外层CATCH）
                                           COMMIT TRANSACTION OuterTransaction;
                                       END TRY
                                       BEGIN CATCH
                                           PRINT '外层事务失败：' + ERROR_MESSAGE();
                                           -- 如果内层已经执行了ROLLBACK，@@TRANCOUNT 为 0，这里不会执行ROLLBACK
                                           -- 如果内层没有ROLLBACK（理论上不应该发生），这里会回滚
                                           IF @@TRANCOUNT > 0
                                           BEGIN
                                               ROLLBACK TRANSACTION;
                                               PRINT '外层事务已回滚';
                                           END
                                           ELSE
                                           BEGIN
                                               PRINT '事务已由内层回滚';
                                           END
                                       END CATCH
                                   
                                   -- 验证回滚结果（应该显示原始数据，因为事务已回滚）
                                   PRINT '验证回滚结果：';
                                   DECLARE @StudentName VARCHAR(30);
                                   DECLARE @TeacherName VARCHAR(30);
                                   SELECT @StudentName = sname FROM students WHERE sid = '800001216';
                                   SELECT @TeacherName = tname FROM teachers WHERE tid = 'T001';
                                   
                                   IF @StudentName = '张三（已修改）'
                                       PRINT '错误：students表数据未被回滚，sname仍然是"张三（已修改）"';
                                   ELSE IF @StudentName = '张三'
                                       PRINT '正确：students表数据已回滚，sname恢复为"张三"';
                                   ELSE
                                       PRINT '警告：students表数据异常，sname=' + ISNULL(@StudentName, 'NULL');
                                   
                                   IF @TeacherName = '新教师'
                                       PRINT '错误：teachers表数据未被回滚，T001的tname仍然是"新教师"';
                                   ELSE IF @TeacherName = '王老师'
                                       PRINT '正确：teachers表数据已回滚，T001的tname恢复为"王老师"';
                                   ELSE
                                       PRINT '警告：teachers表数据异常，T001的tname=' + ISNULL(@TeacherName, 'NULL');
                                   
                                   SELECT 'students' AS 表名, sid, sname FROM students WHERE sid = '800001216'
                                   UNION ALL
                                   SELECT 'teachers' AS 表名, tid AS sid, tname AS sname FROM teachers WHERE tid = 'T001';
                                   
                                   PRINT '========== 题目1完成 ==========';
                                   PRINT '';
========== 题目1：嵌套事务演示 ==========

内层事务失败：Violation of PRIMARY KEY constraint 'PK_TEACHERS'. Cannot insert duplicate key in object 'dbo.TEACHERS'. The duplicate key value is (T001      ).
外层事务失败：Violation of PRIMARY KEY constraint 'PK_TEACHERS'. Cannot insert duplicate key in object 'dbo.TEACHERS'. The duplicate key value is (T001      ).
事务已由内层回滚
验证回滚结果：
正确：students表数据已回滚，sname恢复为"张三"
正确：teachers表数据已回滚，T001的tname恢复为"王老师"
========== 题目1完成 ==========

[2025-12-04 11:04:31] 8 ms 中有 1 行受到影响
[2025-12-04 11:04:31] School_Data> -- 题目2: 编写一个带有保存点的事务。更新teachers表中数据后，设置事务保存点，
                                   -- 然后在表courses中插入数据，如果courses插入数据失败，则回滚到事务保存点。
                                   -- 演示courses插入失败，但teachers表更新成功的操作。
                                   PRINT '========== 题目2：保存点事务演示 ==========';
                                   PRINT '';
                                   
                                   -- 恢复测试数据到初始状态（确保可重复运行）
                                   IF EXISTS (SELECT 1 FROM teachers WHERE tid = 'T002')
                                   BEGIN
                                       UPDATE teachers
                                       SET tname = '李老师', salary = 6000
                                       WHERE tid = 'T002';
                                   END
                                   
                                   -- 获取一个已存在的课程cid用于测试（如果courses表为空，则先插入一个测试课程）
                                   DECLARE @TestCid CHAR(10);
                                   SELECT TOP 1 @TestCid = cid FROM courses;
                                   IF @TestCid IS NULL
                                   BEGIN
                                       -- 如果courses表为空，先插入一个测试课程
                                       INSERT INTO courses (cid, cname, hour) VALUES ('TEST001', '测试课程', 32);
                                       SET @TestCid = 'TEST001';
                                   END
                                   
                                   BEGIN TRANSACTION SavepointTransaction;
                                       BEGIN TRY
                                           -- 更新teachers表
                                           UPDATE teachers
                                           SET tname = '李老师（已更新）', salary = 6500
                                           WHERE tid = 'T002';
                                           
                                           -- 设置保存点
                                           SAVE TRANSACTION Savepoint1;
                                           
                                           -- 尝试插入courses表（使用已存在的cid，会失败）
                                           BEGIN TRY
                                               INSERT INTO courses (cid, cname, hour)
                                               VALUES (@TestCid, '新课程', 32);
                                               
                                               COMMIT TRANSACTION SavepointTransaction;
                                           END TRY
                                           BEGIN CATCH
                                               PRINT 'courses表插入失败：' + ERROR_MESSAGE();
                                               ROLLBACK TRANSACTION Savepoint1;
                                               COMMIT TRANSACTION SavepointTransaction;
                                           END CATCH
                                           
                                       END TRY
                                       BEGIN CATCH
                                           PRINT '事务失败：' + ERROR_MESSAGE();
                                           ROLLBACK TRANSACTION SavepointTransaction;
                                       END CATCH
                                   
                                   -- 验证结果
                                   SELECT * FROM teachers WHERE tid = 'T002';
                                   SELECT * FROM courses;
                                   
                                   PRINT '========== 题目2完成 ==========';
                                   PRINT '';
========== 题目2：保存点事务演示 ==========

courses表插入失败：Violation of PRIMARY KEY constraint 'PK_COURSES'. Cannot insert duplicate key in object 'dbo.COURSES'. The duplicate key value is (10001     ).
========== 题目2完成 ==========

[2025-12-04 11:04:31] 13 ms 中有 2 行受到影响
[2025-12-04 11:04:31] School_Data> -- 题目3: 编写一个包含事务的存储过程，用于更新courses表的课时。
                                   -- 如果更新记录的cid不存在，则输出"课程信息不存在"，
                                   -- 其他错误输出"修改课时失败"，
                                   -- 如果执行成功，则输出"课时修改成功"。
                                   -- 调用该存储过程，演示更新成功与更新失败的操作。
                                   PRINT '========== 题目3：存储过程演示 ==========';
                                   PRINT '';
========== 题目3：存储过程演示 ==========

[2025-12-04 11:04:31] 在 3 ms 内完成
[2025-12-04 11:04:31] School_Data> CREATE PROCEDURE sp_update_course_hour
                                       @cid CHAR(10),
                                       @new_hour INT
                                   AS
                                   BEGIN
                                       SET NOCOUNT ON;
                                       
                                       BEGIN TRANSACTION;
                                       
                                       BEGIN TRY
                                           -- 检查课程是否存在
                                           IF NOT EXISTS (SELECT 1 FROM courses WHERE cid = @cid)
                                           BEGIN
                                               ROLLBACK TRANSACTION;
                                               PRINT '课程信息不存在';
                                               RETURN;
                                           END
                                           
                                           -- 更新课时
                                           UPDATE courses
                                           SET hour = @new_hour
                                           WHERE cid = @cid;
                                           
                                           -- 检查是否真的更新了（防止WHERE条件不匹配）
                                           IF @@ROWCOUNT = 0
                                           BEGIN
                                               ROLLBACK TRANSACTION;
                                               PRINT '课程信息不存在';
                                               RETURN;
                                           END
                                           
                                           COMMIT TRANSACTION;
                                           PRINT '课时修改成功';
                                       END TRY
                                       BEGIN CATCH
                                           ROLLBACK TRANSACTION;
                                           PRINT '修改课时失败';
                                           PRINT '错误信息：' + ERROR_MESSAGE();
                                       END CATCH
                                   END;
[2025-12-04 11:04:31] 在 7 ms 内完成
[2025-12-04 11:04:31] School_Data> -- 获取一个已存在的课程cid用于测试
                                   DECLARE @TestCid1 CHAR(10);
                                   SELECT TOP 1 @TestCid1 = cid FROM courses;
                                   IF @TestCid1 IS NULL
                                   BEGIN
                                       PRINT '错误：courses表中没有数据，无法进行演示';
                                       RETURN;
                                   END
                                   
                                   -- 保存原始hour值
                                   DECLARE @OriginalHour INT;
                                   DECLARE @NewHour INT;
                                   SELECT @OriginalHour = hour FROM courses WHERE cid = @TestCid1;
                                   SET @NewHour = @OriginalHour + 10;
                                   
                                   -- 演示1：更新成功的情况
                                   PRINT '演示1：更新成功（更新课程：' + @TestCid1 + '）';
                                   EXEC sp_update_course_hour @cid = @TestCid1, @new_hour = @NewHour;
                                   SELECT * FROM courses WHERE cid = @TestCid1;
                                   PRINT '';
                                   
                                   -- 演示2：更新失败的情况（课程不存在）
                                   PRINT '演示2：更新失败（课程不存在）';
                                   EXEC sp_update_course_hour @cid = 'C999', @new_hour = 50;
                                   PRINT '';
                                   
                                   PRINT '========== 题目3完成 ==========';
                                   PRINT '';
                                   
                                   PRINT '========== 实验完成 ==========';
演示1：更新成功（更新课程：10001     ）
课时修改成功

演示2：更新失败（课程不存在）
课程信息不存在

========== 题目3完成 ==========

========== 实验完成 ==========
[2025-12-04 11:04:32] 在 301 ms (execution: 32 ms, fetching: 269 ms) 内检索到从 1 开始的 1 行
