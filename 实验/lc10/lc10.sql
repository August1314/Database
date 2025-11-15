-- ========================================
-- SQL Server 参照完整性实验 (Lecture 10)
-- ========================================

USE School_Data;
GO

-- ==================== 环境准备 ====================

PRINT '========== 开始环境准备 ==========';
PRINT '';

-- 清理可能存在的表（按依赖关系倒序删除）
-- 注意：必须先删除有外键约束的表，再删除被引用的表

-- 删除互相引用的表时，需要先删除外键约束
IF OBJECT_ID('department_leaders', 'U') IS NOT NULL
BEGIN
    IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_leader_evaluator')
        ALTER TABLE department_leaders DROP CONSTRAINT FK_leader_evaluator;
END

IF OBJECT_ID('department_members', 'U') IS NOT NULL
    DROP TABLE department_members;
IF OBJECT_ID('department_leaders', 'U') IS NOT NULL
    DROP TABLE department_leaders;
IF OBJECT_ID('student_help', 'U') IS NOT NULL
    DROP TABLE student_help;
IF OBJECT_ID('ICBC_Card', 'U') IS NOT NULL
    DROP TABLE ICBC_Card;
IF OBJECT_ID('Stu_Card', 'U') IS NOT NULL
    DROP TABLE Stu_Card;
IF OBJECT_ID('SC', 'U') IS NOT NULL
    DROP TABLE SC;
IF OBJECT_ID('Stu_Union', 'U') IS NOT NULL
    DROP TABLE Stu_Union;
IF OBJECT_ID('Course', 'U') IS NOT NULL
    DROP TABLE Course;

PRINT '环境清理完成';
GO

-- 创建基础表
CREATE TABLE Stu_Union (
    sno CHAR(5) NOT NULL UNIQUE,
    sname CHAR(8),
    ssex CHAR(1),
    sage INT,
    sdept CHAR(20),
    CONSTRAINT PK_Stu_Union PRIMARY KEY(sno)
);

CREATE TABLE Course (
    cno CHAR(4) NOT NULL UNIQUE,
    cname VARCHAR(50) NOT NULL,
    cpoints INT,
    CONSTRAINT PK_Course PRIMARY KEY (cno)
);

-- 插入基础数据
INSERT INTO Stu_Union VALUES ('10001','王勇','0',24,'EE');
INSERT INTO Stu_Union VALUES ('95002','王敏','1',23,'CS');
INSERT INTO Stu_Union VALUES ('95003','王洁','0',25,'EE');
INSERT INTO Stu_Union VALUES ('95005','王杰','0',25,'EE');
INSERT INTO Stu_Union VALUES ('95009','李勇','0',25,'EE');

INSERT INTO Course VALUES ('0001','ComputerNetworks',2);
INSERT INTO Course VALUES ('0002','Database',3);

PRINT '环境准备完成';
PRINT '';
GO

-- ==================== 实验题目 ====================

-- 题目1: 用alter table语句将SC表中的on delete cascade改为on delete no action,
-- 重新插入SC的数据（按照实验一）。再删除Stu_Union中sno为'10001'的数据。
-- 观察结果，并分析原因。

PRINT '========== 题目(1)：测试on delete no action约束 ==========';

-- 创建SC表，初始设置为cascade
CREATE TABLE SC(
    sno CHAR(5),
    cno CHAR(4),
    grade INT,
    CONSTRAINT PK_SC PRIMARY KEY (sno,cno),
    CONSTRAINT FK_SC_Student FOREIGN KEY (sno) REFERENCES Stu_Union(sno) ON DELETE CASCADE,
    CONSTRAINT FK_SC_Course FOREIGN KEY (cno) REFERENCES Course(cno) ON DELETE CASCADE
);

-- 插入数据
INSERT INTO SC VALUES ('95002','0001',2);
INSERT INTO SC VALUES ('95002','0002',2);
INSERT INTO SC VALUES ('10001','0001',2);
INSERT INTO SC VALUES ('10001','0002',2);

PRINT '初始SC表数据：';
SELECT * FROM SC;
PRINT '';

-- 修改外键约束为no action
ALTER TABLE SC DROP CONSTRAINT FK_SC_Student;
ALTER TABLE SC ADD CONSTRAINT FK_SC_Student 
    FOREIGN KEY (sno) REFERENCES Stu_Union(sno) ON DELETE NO ACTION;

PRINT '已将外键约束改为 ON DELETE NO ACTION';
PRINT '尝试删除Stu_Union中sno为10001的数据...';

-- 尝试删除
DELETE FROM Stu_Union WHERE sno='10001';

-- 实验结果：
-- 报错：The DELETE statement conflicted with the REFERENCE constraint
-- 原因分析：
-- 1. ON DELETE NO ACTION表示当删除父表记录时，如果子表中存在引用该记录的数据，则拒绝删除
-- 2. SC表中存在sno='10001'的记录，引用了Stu_Union表中的'10001'
-- 3. 因此删除操作被拒绝，保护了数据的参照完整性
-- 4. 这与CASCADE不同，CASCADE会自动删除子表中的相关记录

PRINT '查看SC表数据（删除失败，数据未变）：';
SELECT * FROM SC;
PRINT '';

-- 环境恢复
DROP TABLE SC;
GO

-- 题目2: 用alter table语句将SC表中的on delete no action改为on delete set NULL,
-- 重新插入SC的数据（按照实验一）。再删除Stu_Union中sno为'10001'的数据。
-- 观察结果，并分析原因。

PRINT '========== 题目(2)：测试on delete set null约束 ==========';

-- 创建SC表，使用单独的ID作为主键，sno作为外键（允许NULL）
CREATE TABLE SC(
    sc_id INT IDENTITY(1,1),  -- 使用自增ID作为主键
    sno CHAR(5) NULL,  -- 允许NULL以支持SET NULL
    cno CHAR(4) NOT NULL,
    grade INT,
    CONSTRAINT PK_SC PRIMARY KEY (sc_id),
    CONSTRAINT UQ_SC_sno_cno UNIQUE (sno, cno),  -- 保证学号和课程号的组合唯一
    CONSTRAINT FK_SC_Student FOREIGN KEY (sno) REFERENCES Stu_Union(sno) ON DELETE NO ACTION,
    CONSTRAINT FK_SC_Course FOREIGN KEY (cno) REFERENCES Course(cno) ON DELETE CASCADE
);

-- 插入数据
INSERT INTO SC (sno, cno, grade) VALUES ('95002','0001',2);
INSERT INTO SC (sno, cno, grade) VALUES ('95002','0002',2);
INSERT INTO SC (sno, cno, grade) VALUES ('10001','0001',2);
INSERT INTO SC (sno, cno, grade) VALUES ('10001','0002',2);

PRINT '初始SC表数据：';
SELECT sno, cno, grade FROM SC;
PRINT '';

-- 修改外键约束为set null
PRINT '将外键约束改为 ON DELETE SET NULL...';
ALTER TABLE SC DROP CONSTRAINT FK_SC_Student;
ALTER TABLE SC ADD CONSTRAINT FK_SC_Student 
    FOREIGN KEY (sno) REFERENCES Stu_Union(sno) ON DELETE SET NULL;

PRINT '外键约束已修改为 ON DELETE SET NULL';
PRINT '尝试删除Stu_Union中sno为10001的数据...';

-- 删除学生记录
DELETE FROM Stu_Union WHERE sno='10001';

PRINT '删除成功！';
PRINT '查看SC表数据（sno应该被设置为NULL）：';
SELECT sno, cno, grade FROM SC;

-- 实验结果：
-- 1. 删除成功，Stu_Union表中sno='10001'的记录被删除
-- 2. SC表中原本sno='10001'的记录，其sno字段被设置为NULL
-- 3. 这保持了数据的参照完整性，同时保留了选课记录
-- 
-- 原因分析：
-- 1. ON DELETE SET NULL表示当删除父表记录时，将子表中引用该记录的外键列设置为NULL
-- 2. 为了使用SET NULL，外键列必须允许NULL值
-- 3. 如果外键列是主键的一部分，则无法使用SET NULL（因为主键不允许NULL）
-- 4. 本例中使用独立的ID作为主键，sno作为可空的外键列，因此可以使用SET NULL

PRINT '';

-- 环境恢复
DROP TABLE SC;
GO

-- 题目3: 建立事务T3，修改ICBC_Card表的外键属性，使其变为on delete set NULL,
-- 尝试删除students表中一条记录。观察结果，并分析原因。

PRINT '========== 题目(3)：在事务中测试on delete set null ==========';

-- 先检查并修改choices表的外键约束，避免删除students时的冲突
IF EXISTS (SELECT 1 FROM sys.foreign_keys WHERE name = 'FK_CHOICES_STUDENTS')
BEGIN
    PRINT '修改choices表的外键约束为ON DELETE CASCADE...';
    ALTER TABLE choices DROP CONSTRAINT FK_CHOICES_STUDENTS;
    ALTER TABLE choices ADD CONSTRAINT FK_CHOICES_STUDENTS 
        FOREIGN KEY (sid) REFERENCES students(sid) ON DELETE CASCADE;
    PRINT '外键约束已修改';
    PRINT '';
END

-- 创建Stu_Card和ICBC_Card表
CREATE TABLE Stu_Card(
    card_id CHAR(14),
    stu_id CHAR(10),
    remained_money DECIMAL(10,2),
    CONSTRAINT PK_stu_card PRIMARY KEY (card_id),
    CONSTRAINT FK_StuCard_Student FOREIGN KEY (stu_id) 
        REFERENCES students(sid) ON DELETE CASCADE
);

CREATE TABLE ICBC_Card(
    bank_id CHAR(20),
    stu_card_id CHAR(14) NULL,  -- 允许NULL以支持SET NULL
    restored_money DECIMAL(10,2),
    CONSTRAINT PK_Icbc_card PRIMARY KEY (bank_id),
    CONSTRAINT FK_ICBC_StuCard FOREIGN KEY (stu_card_id) 
        REFERENCES Stu_Card(card_id) ON DELETE CASCADE
);

-- 插入测试数据（假设students表中有相应记录）
IF EXISTS (SELECT 1 FROM students WHERE sid='800001216')
BEGIN
    INSERT INTO Stu_Card VALUES ('05212567','800001216',100.25);
    INSERT INTO ICBC_Card VALUES ('9558844022312','05212567',15000.1);
    PRINT '已插入sid=800001216的测试数据';
END
ELSE
BEGIN
    PRINT '警告：students表中不存在sid=800001216的记录';
END

IF EXISTS (SELECT 1 FROM students WHERE sid='800005753')
BEGIN
    INSERT INTO Stu_Card VALUES ('05212222','800005753',200.50);
    INSERT INTO ICBC_Card VALUES ('9558844023645','05212222',50000.3);
    PRINT '已插入sid=800005753的测试数据';
END
ELSE
BEGIN
    PRINT '警告：students表中不存在sid=800005753的记录';
END

PRINT '';
PRINT '初始数据：';
SELECT * FROM Stu_Card;
SELECT * FROM ICBC_Card;
PRINT '';

-- 创建事务T3
BEGIN TRANSACTION T3
    PRINT '事务T3开始：修改ICBC_Card外键为ON DELETE SET NULL';
    
    -- 删除原有外键约束
    ALTER TABLE ICBC_Card DROP CONSTRAINT FK_ICBC_StuCard;
    
    -- 添加新的外键约束（SET NULL）
    ALTER TABLE ICBC_Card ADD CONSTRAINT FK_ICBC_StuCard 
        FOREIGN KEY (stu_card_id) REFERENCES Stu_Card(card_id) ON DELETE SET NULL;
    
    PRINT '外键约束已修改为 ON DELETE SET NULL';
    PRINT '';
    
    -- 尝试删除students表中的记录
    IF EXISTS (SELECT 1 FROM students WHERE sid='800001216')
    BEGIN
        PRINT '尝试删除students表中sid=800001216的记录...';
        DELETE FROM students WHERE sid='800001216';
        
        PRINT '删除成功！';
        PRINT '';
        PRINT '查看Stu_Card表（应该被级联删除）：';
        SELECT * FROM Stu_Card;
        PRINT '';
        
        PRINT '查看ICBC_Card表（stu_card_id应该被设置为NULL）：';
        SELECT * FROM ICBC_Card;
        PRINT '';
    END
    ELSE
    BEGIN
        PRINT '测试数据不存在，使用模拟数据演示...';
        PRINT '直接删除Stu_Card中的记录来演示SET NULL效果';
        DELETE FROM Stu_Card WHERE card_id='05212567';
        
        PRINT '查看ICBC_Card表（stu_card_id应该被设置为NULL）：';
        SELECT * FROM ICBC_Card;
        PRINT '';
    END
    
COMMIT TRANSACTION T3

-- 实验结果分析：
-- 1. 删除students表中的记录后，由于Stu_Card表设置了ON DELETE CASCADE，
--    Stu_Card中对应的记录会被自动删除
-- 2. 当Stu_Card中的记录被删除时，由于ICBC_Card表设置了ON DELETE SET NULL，
--    ICBC_Card表中引用该card_id的stu_card_id字段会被设置为NULL
-- 3. 这展示了级联操作的链式反应：students -> Stu_Card (CASCADE) -> ICBC_Card (SET NULL)
-- 4. 事务保证了这一系列操作的原子性

PRINT '实验结论：';
PRINT 'ON DELETE SET NULL适用于需要保留子表记录但清除引用关系的场景';
PRINT '与CASCADE不同，SET NULL不会删除子表记录，只是将外键列设置为NULL';

PRINT '';

-- 环境恢复
DROP TABLE ICBC_Card;
DROP TABLE Stu_Card;
GO

-- 题目4: 创建一个班里的学生互助表，规定：包括学生编号，学生姓名，学生的帮助对象，
-- 每个学生有且仅有一个帮助对象，帮助对象也必须是班里的学生。（表的自参照问题）

PRINT '========== 题目(4)：表的自参照问题 ==========';

-- 创建学生互助表
CREATE TABLE student_help(
    student_id CHAR(5) NOT NULL,
    student_name VARCHAR(20),
    help_target_id CHAR(5) NOT NULL,  -- 帮助对象的学号
    CONSTRAINT PK_student_help PRIMARY KEY (student_id),
    CONSTRAINT FK_help_target FOREIGN KEY (help_target_id) 
        REFERENCES student_help(student_id),
    CONSTRAINT CHK_not_self CHECK (student_id <> help_target_id)  -- 不能帮助自己
);

PRINT '学生互助表创建成功';
PRINT '表结构说明：';
PRINT '1. student_id: 学生编号（主键）';
PRINT '2. student_name: 学生姓名';
PRINT '3. help_target_id: 帮助对象的学号（外键，引用本表的student_id）';
PRINT '4. 约束：每个学生有且仅有一个帮助对象（主键保证唯一性）';
PRINT '5. 约束：帮助对象必须是班里的学生（外键约束）';
PRINT '6. 约束：不能帮助自己（CHECK约束）';
PRINT '';

-- 插入示例数据（注意：必须先插入被引用的学生）
-- 由于自参照的特性，插入数据时需要特别注意顺序
-- 方法1：先插入所有学生（help_target_id暂时设为已存在的学生），然后更新
-- 方法2：临时禁用外键约束

PRINT '插入示例数据：';

-- 先插入第一个学生（他帮助自己，稍后更新）
-- 由于有CHECK约束不能帮助自己，我们需要先禁用约束或使用其他方法

-- 方法：先禁用外键约束，插入数据，再启用
ALTER TABLE student_help NOCHECK CONSTRAINT FK_help_target;

INSERT INTO student_help VALUES ('10001', '王勇', '95002');
INSERT INTO student_help VALUES ('95002', '王敏', '95003');
INSERT INTO student_help VALUES ('95003', '王洁', '95005');
INSERT INTO student_help VALUES ('95005', '王杰', '10001');

-- 重新启用外键约束并检查数据
ALTER TABLE student_help CHECK CONSTRAINT FK_help_target;

PRINT '数据插入成功：';
SELECT 
    s1.student_id AS 学生编号,
    s1.student_name AS 学生姓名,
    s1.help_target_id AS 帮助对象编号,
    s2.student_name AS 帮助对象姓名
FROM student_help s1
LEFT JOIN student_help s2 ON s1.help_target_id = s2.student_id;

PRINT '';
PRINT '自参照特点：';
PRINT '1. 表中的外键引用本表的主键';
PRINT '2. 形成了学生之间的帮助关系网络';
PRINT '3. 插入数据时需要注意引用完整性';

PRINT '';
GO

-- 题目5: 学校学生会的每个部门都有一个部长，每个部长领导多个部员，
-- 每个部只有一个部员有评测部长的权利，请给出体现这两种关系（领导和评测）的
-- 两张互参照的表的定义。（两个表互相参照的问题）

PRINT '========== 题目(5)：两个表互相参照的问题 ==========';

-- 方案：创建两个表 - department_leaders（部长表）和 department_members（部员表）
-- 关系1：部长领导多个部员（leaders -> members，一对多）
-- 关系2：每个部只有一个部员有评测部长的权利（members -> leaders，一对一）

-- 先创建部长表（不包含外键）
CREATE TABLE department_leaders(
    leader_id CHAR(5) NOT NULL,
    leader_name VARCHAR(20),
    department VARCHAR(30),
    evaluator_id CHAR(5) NULL,  -- 有评测权的部员ID（外键，稍后添加）
    CONSTRAINT PK_leaders PRIMARY KEY (leader_id)
);

-- 创建部员表（包含对部长表的外键）
CREATE TABLE department_members(
    member_id CHAR(5) NOT NULL,
    member_name VARCHAR(20),
    department VARCHAR(30),
    leader_id CHAR(5) NOT NULL,  -- 所属部长ID（外键）
    has_evaluation_right BIT DEFAULT 0,  -- 是否有评测权
    CONSTRAINT PK_members PRIMARY KEY (member_id),
    CONSTRAINT FK_member_leader FOREIGN KEY (leader_id) 
        REFERENCES department_leaders(leader_id) ON DELETE CASCADE
);

-- 为部长表添加外键约束（引用部员表）
-- 注意：由于已经存在CASCADE路径，这里必须使用NO ACTION避免循环级联
ALTER TABLE department_leaders 
    ADD CONSTRAINT FK_leader_evaluator FOREIGN KEY (evaluator_id) 
        REFERENCES department_members(member_id) ON DELETE NO ACTION;

-- 添加约束：每个部门只能有一个部员有评测权
-- 这可以通过唯一索引实现
CREATE UNIQUE INDEX UQ_evaluator_per_dept 
    ON department_members(department, has_evaluation_right) 
    WHERE has_evaluation_right = 1;

PRINT '两个互参照表创建成功';
PRINT '';
PRINT '表结构说明：';
PRINT '1. department_leaders（部长表）：';
PRINT '   - leader_id: 部长ID（主键）';
PRINT '   - leader_name: 部长姓名';
PRINT '   - department: 部门名称';
PRINT '   - evaluator_id: 有评测权的部员ID（外键 -> department_members）';
PRINT '';
PRINT '2. department_members（部员表）：';
PRINT '   - member_id: 部员ID（主键）';
PRINT '   - member_name: 部员姓名';
PRINT '   - department: 部门名称';
PRINT '   - leader_id: 所属部长ID（外键 -> department_leaders）';
PRINT '   - has_evaluation_right: 是否有评测权';
PRINT '';
PRINT '关系说明：';
PRINT '1. 领导关系：部长(leader_id) <- 部员(leader_id)，一对多';
PRINT '2. 评测关系：部长(evaluator_id) -> 部员(member_id)，一对一';
PRINT '3. 约束：每个部门只有一个部员有评测权（唯一索引）';
PRINT '';

-- 插入示例数据
PRINT '插入示例数据：';

-- 先禁用外键约束以便插入互相引用的数据
ALTER TABLE department_leaders NOCHECK CONSTRAINT FK_leader_evaluator;

-- 插入部长数据
INSERT INTO department_leaders (leader_id, leader_name, department, evaluator_id) 
VALUES ('L0001', '张三', '宣传部', NULL);
INSERT INTO department_leaders (leader_id, leader_name, department, evaluator_id) 
VALUES ('L0002', '李四', '组织部', NULL);

-- 插入部员数据
INSERT INTO department_members VALUES ('M0001', '王五', '宣传部', 'L0001', 1);  -- 有评测权
INSERT INTO department_members VALUES ('M0002', '赵六', '宣传部', 'L0001', 0);
INSERT INTO department_members VALUES ('M0003', '孙七', '组织部', 'L0002', 1);  -- 有评测权
INSERT INTO department_members VALUES ('M0004', '周八', '组织部', 'L0002', 0);

-- 更新部长表的evaluator_id
UPDATE department_leaders SET evaluator_id = 'M0001' WHERE leader_id = 'L0001';
UPDATE department_leaders SET evaluator_id = 'M0003' WHERE leader_id = 'L0002';

-- 重新启用外键约束
ALTER TABLE department_leaders CHECK CONSTRAINT FK_leader_evaluator;

PRINT '数据插入成功';
PRINT '';

-- 查询领导关系
PRINT '领导关系（部长领导的部员）：';
SELECT 
    l.leader_id AS 部长ID,
    l.leader_name AS 部长姓名,
    l.department AS 部门,
    m.member_id AS 部员ID,
    m.member_name AS 部员姓名,
    CASE WHEN m.has_evaluation_right = 1 THEN '是' ELSE '否' END AS 是否有评测权
FROM department_leaders l
LEFT JOIN department_members m ON l.leader_id = m.leader_id
ORDER BY l.department, m.member_id;

PRINT '';

-- 查询评测关系
PRINT '评测关系（有权评测部长的部员）：';
SELECT 
    l.leader_id AS 部长ID,
    l.leader_name AS 部长姓名,
    l.department AS 部门,
    m.member_id AS 评测者ID,
    m.member_name AS 评测者姓名
FROM department_leaders l
LEFT JOIN department_members m ON l.evaluator_id = m.member_id;

PRINT '';
PRINT '互参照特点：';
PRINT '1. 两个表互相引用对方的主键作为外键';
PRINT '2. 创建时需要先创建一个表（不含外键），再创建另一个表，最后用ALTER TABLE添加外键';
PRINT '3. 插入数据时需要临时禁用外键约束，或者分步插入并更新';
PRINT '4. 体现了复杂的业务关系：领导关系（一对多）和评测关系（一对一）';

PRINT '';
GO

PRINT '========== 实验完成 ==========';
GO
