[2025-11-06 10:52:39] School_Data> PRINT '========== 题目(1)：创建class表并设置主键 ==========';
                                   
                                   -- 在这里写你的代码
                                   CREATE TABLE class(
                                       class_id varchar(5)  PRIMARY KEY,
                                       name varchar(10),
                                       department varchar(20)
                                   )
========== 题目(1)：创建class表并设置主键 ==========
[2025-11-06 10:52:39] 在 13 ms 内完成
[2025-11-06 10:52:46] School_Data> EXEC sp_help 'class'








[2025-11-06 10:52:48] [S0001][15470] No foreign keys reference table 'class', or you do not have permissions on referencing tables.
[2025-11-06 10:52:48] [S0001][15647] No views with schema binding reference table 'class'.
[2025-11-06 10:52:48] 在 2 s 490 ms (execution: 51 ms, fetching: 2 s 439 ms) 内检索到从 1 开始的 1 行
[2025-11-06 10:53:43] School_Data> SET XACT_ABORT OFF
                                   BEGIN TRANSACTION T3
                                   insert into class values ('0001','01CSC','CS');
                                       BEGIN Transaction T4
                                       insert into class values ('0001','01CSC','CS');
                                       COMMIT TRANSACTION T4
                                   COMMIT TRANSACTION T3
[2025-11-06 10:53:43] [S0000][3621] The statement has been terminated.
[2025-11-06 10:53:43] 26 ms 中有 1 行受到影响
[2025-11-06 10:53:43] [23000][2627] 行 5: Violation of PRIMARY KEY constraint 'PK__class__FDF47986A721E16E'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 10:53:47] School_Data> SELECT * FROM class
[2025-11-06 10:53:48] 在 344 ms (execution: 6 ms, fetching: 338 ms) 内检索到从 1 开始的 1 行
[2025-11-06 10:54:18] School_Data> SET XACT_ABORT OFF
                                   BEGIN TRANSACTION T3
                                   insert into class values ('0001','01CSC','CS');
                                       BEGIN Transaction T4
                                       insert into class values ('0001','01CSC','CS');
                                       COMMIT TRANSACTION T4
                                   COMMIT TRANSACTION T3
[2025-11-06 10:54:18] [23000][2627] 行 3: Violation of PRIMARY KEY constraint 'PK__class__FDF47986A721E16E'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 10:54:18] [23000][2627] 行 5: Violation of PRIMARY KEY constraint 'PK__class__FDF47986A721E16E'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 10:54:18] [S0000][3621] The statement has been terminated.
[2025-11-06 10:54:18] [S0000][3621] The statement has been terminated.
[2025-11-06 10:54:28] School_Data> IF OBJECT_ID('class', 'U') IS NOT NULL
                                       DROP TABLE class;
[2025-11-06 10:54:28] 在 21 ms 内完成
[2025-11-06 10:54:30] School_Data> CREATE TABLE class(
                                       class_id varchar(5)  PRIMARY KEY,
                                       name varchar(10),
                                       department varchar(20)
                                   )
[2025-11-06 10:54:30] 在 7 ms 内完成
[2025-11-06 10:54:34] School_Data> SET XACT_ABORT OFF
                                   BEGIN TRANSACTION T3
                                   insert into class values ('0001','01CSC','CS');
                                       BEGIN Transaction T4
                                       insert into class values ('0001','01CSC','CS');
                                       COMMIT TRANSACTION T4
                                   COMMIT TRANSACTION T3
[2025-11-06 10:54:34] [S0000][3621] The statement has been terminated.
[2025-11-06 10:54:34] 11 ms 中有 1 行受到影响
[2025-11-06 10:54:34] [23000][2627] 行 5: Violation of PRIMARY KEY constraint 'PK__class__FDF4798634627C12'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 10:55:01] School_Data> UPDATE class SET class_id = NULL where name = '01CSC'
[2025-11-06 10:55:01] [23000][515] 行 1: Cannot insert the value NULL into column 'class_id', table 'School_Data.dbo.class'; column does not allow nulls. UPDATE fails.
[2025-11-06 10:55:01] [S0000][3621] The statement has been terminated.
[2025-11-06 10:55:21] School_Data> SELECT * FROM class
[2025-11-06 10:55:22] 在 348 ms (execution: 9 ms, fetching: 339 ms) 内检索到从 1 开始的 1 行
[2025-11-06 10:55:54] School_Data> INSERT INTO class values ('0002','01CSC','CS');
                                   INSERT INTO class values ('0002','03CSC','CS');
[2025-11-06 10:55:54] [S0000][3621] The statement has been terminated.
[2025-11-06 10:55:54] 17 ms 中有 1 行受到影响
[2025-11-06 10:55:54] [23000][2627] 行 2: Violation of PRIMARY KEY constraint 'PK__class__FDF4798634627C12'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0002).
[2025-11-06 10:59:03] School_Data> SELECT * FROM class
[2025-11-06 10:59:04] 在 342 ms (execution: 5 ms, fetching: 337 ms) 内检索到从 1 开始的 2 行
[2025-11-06 10:59:45] School_Data> SET XACT_ABORT ON
                                   BEGIN TRANSACTION T
                                   INSERT INTO class values ('0003','03CSC','CS');
                                   INSERT INTO class values ('0001','03CSC','CS');
                                   Commit TRANSACTION T
[2025-11-06 10:59:45] 21 ms 中有 1 行受到影响
[2025-11-06 10:59:45] [23000][2627] 行 4: Violation of PRIMARY KEY constraint 'PK__class__FDF4798634627C12'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 11:00:18] School_Data> SELECT * FROM class
[2025-11-06 11:00:18] 在 349 ms (execution: 4 ms, fetching: 345 ms) 内检索到从 1 开始的 2 行
[2025-11-06 11:00:49] School_Data> SET XACT_ABORT OFF
                                   BEGIN TRANSACTION T
                                   INSERT INTO class values ('0003','03CSC','CS');
                                   INSERT INTO class values ('0001','03CSC','CS');
                                   Commit TRANSACTION T
[2025-11-06 11:00:49] [S0000][3621] The statement has been terminated.
[2025-11-06 11:00:49] 14 ms 中有 1 行受到影响
[2025-11-06 11:00:49] [23000][2627] 行 4: Violation of PRIMARY KEY constraint 'PK__class__FDF4798634627C12'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 11:01:07] School_Data> SELECT * FROM class
[2025-11-06 11:01:08] 在 355 ms (execution: 4 ms, fetching: 351 ms) 内检索到从 1 开始的 3 行
[2025-11-06 11:02:21] School_Data> ALTER TABLE class ADD CONSTRAINT class_name_pk PRIMARY KEY (name)
[2025-11-06 11:02:21] [S0000][1779] 行 1: Table 'class' already has a primary key defined on it.
[2025-11-06 11:02:21] [S0000][1750] 行 1: Could not create constraint or index. See previous errors.
[2025-11-06 11:02:37] School_Data> SELECT * FROM class
[2025-11-06 11:02:38] 在 344 ms (execution: 4 ms, fetching: 340 ms) 内检索到从 1 开始的 3 行
[2025-11-06 11:02:44] School_Data> EXEC sp_help 'class'








[2025-11-06 11:02:46] [S0001][15470] No foreign keys reference table 'class', or you do not have permissions on referencing tables.
[2025-11-06 11:02:46] [S0001][15647] No views with schema binding reference table 'class'.
[2025-11-06 11:02:46] 在 2 s 419 ms (execution: 58 ms, fetching: 2 s 361 ms) 内检索到从 1 开始的 1 行
[2025-11-06 11:03:59] School_Data> USE School_Data
[2025-11-06 11:03:59] [S0001][5701] Changed database context to 'School_Data'.
[2025-11-06 11:03:59] 在 5 ms 内完成
[2025-11-06 11:03:59] School_Data> IF OBJECT_ID('class', 'U') IS NOT NULL
                                       DROP TABLE class;
[2025-11-06 11:03:59] 在 14 ms 内完成
[2025-11-06 11:03:59] School_Data> PRINT '========== 环境准备完成 ==========';
                                   PRINT '';
========== 环境准备完成 ==========

[2025-11-06 11:03:59] 在 3 ms 内完成
[2025-11-06 11:03:59] School_Data> PRINT '========== 题目(1)：创建class表并设置主键 ==========';
                                   
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
========== 题目(1)：创建class表并设置主键 ==========
验证：查看class表的结构








[2025-11-06 11:04:01] [S0001][15470] No foreign keys reference table 'class', or you do not have permissions on referencing tables.
[2025-11-06 11:04:01] [S0001][15647] No views with schema binding reference table 'class'.

[2025-11-06 11:04:01] 在 2 s 518 ms (execution: 55 ms, fetching: 2 s 463 ms) 内检索到从 1 开始的 1 行
[2025-11-06 11:04:01] School_Data> PRINT '========== 题目(2)：测试嵌套事务中的主键冲突 ==========';
                                   
                                   -- 在这里写你的代码
                                   -- 提示：
                                   -- 1. 使用BEGIN TRANSACTION创建事务T3
                                   -- 2. 在T3中插入第一条记录
                                   -- 3. 在T3中嵌套创建事务T4
                                   -- 4. 在T4中尝试插入相同的记录
                                   -- 5. 观察是否会报错
                                   
                                   SET XACT_ABORT OFF
                                   BEGIN TRANSACTION T3
                                   insert into class values ('0001','01CSC','CS');
                                       BEGIN Transaction T4
                                       insert into class values ('0001','01CSC','CS');
                                       COMMIT TRANSACTION T4
                                   COMMIT TRANSACTION T3
                                   
                                   
                                   -- 查看表中的数据
                                   PRINT '查看表中的数据：';
                                   SELECT * FROM class;
                                   
                                   PRINT '';
========== 题目(2)：测试嵌套事务中的主键冲突 ==========
[2025-11-06 11:04:01] [S0000][3621] The statement has been terminated.
查看表中的数据：
[2025-11-06 11:04:01] 19 ms 中有 1 行受到影响
[2025-11-06 11:04:01] [23000][2627] 行 15: Violation of PRIMARY KEY constraint 'PK__class__FDF4798636B93626'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 11:04:03] School_Data> PRINT '========== 题目(3)：尝试将主键设置为NULL ==========';
                                   
                                   -- 在这里写你的代码
                                   UPDATE class SET class_id = NULL where name = '01CSC';
                                   
                                   -- 查看表中的数据
                                   PRINT '查看表中的数据：';
                                   SELECT * FROM class;
                                   
                                   PRINT '';
[2025-11-06 11:04:03] [23000][515] 行 4: Cannot insert the value NULL into column 'class_id', table 'School_Data.dbo.class'; column does not allow nulls. UPDATE fails.
========== 题目(3)：尝试将主键设置为NULL ==========
[2025-11-06 11:04:03] [S0000][3621] The statement has been terminated.
查看表中的数据：
[2025-11-06 11:04:03] School_Data> PRINT '========== 题目(4)：测试批量插入时的主键冲突 ==========';
                                   
                                   -- 在这里写你的代码
                                   INSERT INTO class values ('0002','01CSC','CS');
                                   INSERT INTO class values ('0002','03CSC','CS');
                                   
                                   
                                   -- 查看表中的数据
                                   PRINT '查看表中有几条记录：';
                                   SELECT COUNT(*) AS 记录数 FROM class;
                                   SELECT * FROM class;
                                   
                                   PRINT '';
========== 题目(4)：测试批量插入时的主键冲突 ==========
[2025-11-06 11:04:03] [S0000][3621] The statement has been terminated.
查看表中有几条记录：
[2025-11-06 11:04:03] 11 ms 中有 1 行受到影响
[2025-11-06 11:04:03] [23000][2627] 行 5: Violation of PRIMARY KEY constraint 'PK__class__FDF4798636B93626'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0002).
[2025-11-06 11:04:03] School_Data> PRINT '========== 题目(5)：测试事务回滚对主键冲突的影响 ==========';
                                   
                                   -- 在这里写你的代码
                                   -- 提示：
                                   -- 1. 使用BEGIN TRANSACTION创建事务
                                   -- 2. 插入第一条记录（'0003'，'03CSC','CS'）
                                   -- 3. 插入第二条记录（'0001'，'03CSC'，'CS'）- 这条会冲突
                                   -- 4. 使用ROLLBACK回滚事务
                                   SET XACT_ABORT ON
                                   BEGIN TRANSACTION T
                                   INSERT INTO class values ('0003','03CSC','CS');
                                   INSERT INTO class values ('0001','03CSC','CS');
                                   Commit TRANSACTION T
                                   
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
========== 题目(5)：测试事务回滚对主键冲突的影响 ==========
[2025-11-06 11:04:03] 11 ms 中有 1 行受到影响
[2025-11-06 11:04:03] [23000][2627] 行 12: Violation of PRIMARY KEY constraint 'PK__class__FDF4798636B93626'. Cannot insert duplicate key in object 'dbo.class'. The duplicate key value is (0001).
[2025-11-06 11:04:03] School_Data> PRINT '========== 题目(6)：尝试将name列设置为主键 ==========';
                                   
                                   -- 在这里写你的代码
                                   -- 提示：
                                   -- 1. 先删除原有的主键约束
                                   -- 2. 尝试在name列上创建主键约束
                                   ALTER TABLE class ADD CONSTRAINT class_name_pk PRIMARY KEY (name);
                                   
                                   -- 查看表结构
                                   PRINT '查看表结构：';
                                   EXEC sp_help 'class';
                                   
                                   -- 查看表中的数据
                                   PRINT '查看表中的数据：';
                                   SELECT * FROM class;
                                   
                                   PRINT '';
[2025-11-06 11:04:03] [S0000][1779] 行 7: Table 'class' already has a primary key defined on it.
[2025-11-06 11:04:03] [S0000][1750] 行 7: Could not create constraint or index. See previous errors.
========== 题目(6)：尝试将name列设置为主键 ==========
[2025-11-06 11:04:03] School_Data> PRINT '========== 实验完成 =========='
========== 实验完成 ==========
[2025-11-06 11:04:03] 在 3 ms 内完成
