-- ========================================
-- LC12 触发器实验
-- ========================================

USE school_data;
GO

-- ==================== 环境准备 ====================

PRINT '========== 开始环境准备 ==========';
PRINT '';

-- 清理可能存在的触发器、视图和表
IF OBJECT_ID('T4', 'TR') IS NOT NULL DROP TRIGGER T4;
IF OBJECT_ID('T5', 'TR') IS NOT NULL DROP TRIGGER T5;
IF OBJECT_ID('T6', 'TR') IS NOT NULL DROP TRIGGER T6;

IF OBJECT_ID('student_card_view', 'V') IS NOT NULL DROP VIEW student_card_view;

IF OBJECT_ID('Stu_Card', 'U') IS NOT NULL DROP TABLE Stu_Card;
IF OBJECT_ID('Worker', 'U') IS NOT NULL DROP TABLE Worker;

PRINT '环境清理完成';
PRINT '';

-- 插入 students 测试数据（如果不存在，students表数据库内已存在）
IF NOT EXISTS (SELECT 1 FROM students WHERE sid = '800001216')
    INSERT INTO students VALUES ('800001216', '张三', 'zhangsan@example.com', 2023);

IF NOT EXISTS (SELECT 1 FROM students WHERE sid = '800005753')
    INSERT INTO students VALUES ('800005753', '李四', 'lisi@example.com', 2023);

-- 创建 Worker 表
CREATE TABLE Worker(
    Number CHAR(5),
    Name CHAR(8) CONSTRAINT U1 UNIQUE,
    Sex CHAR(1),
    Sage INT CONSTRAINT U2 CHECK (Sage<=28),
    Department CHAR(20),
    CONSTRAINT PK_Worker PRIMARY KEY (Number)
);

-- 插入 Worker 测试数据
INSERT INTO Worker (Number, Name, Sex, Sage, Department)
VALUES ('00001', '李勇', 'M', 14, '科技部');

INSERT INTO Worker (Number, Name, Sex, Sage, Department)
VALUES ('00002', '王敏', 'F', 20, '研发部');

INSERT INTO Worker (Number, Name, Sex, Sage, Department)
VALUES ('00003', '张强', 'M', 25, '市场部');

PRINT 'Worker 表创建并插入数据完成';
SELECT * FROM Worker;
PRINT '';

-- 创建 Stu_Card 表
CREATE TABLE Stu_Card (
    card_id CHAR(14),
    stu_id CHAR(10) REFERENCES students(sid) ON DELETE CASCADE,
    remained_money DECIMAL(10,2),
    CONSTRAINT PK_stu_card PRIMARY KEY (card_id)
);

-- 插入 Stu_Card 测试数据
INSERT INTO Stu_Card VALUES ('05212567', '800001216', 100.25);
INSERT INTO Stu_Card VALUES ('05212222', '800005753', 200.50);

PRINT 'Stu_Card 表创建并插入数据完成';
SELECT * FROM Stu_Card;
PRINT '';

PRINT '========== 环境准备完成 ==========';
PRINT '';
GO

-- ==================== 实验题目 ====================

-- 题目1: 建立一个在worker表上的触发器T4，要求插入记录的sage值必须比表中已记录的最大sage值大。
PRINT '========== 题目1：创建触发器T4 ==========';
PRINT '';
GO

CREATE TRIGGER T4
ON Worker
AFTER INSERT
AS
BEGIN
    DECLARE @MaxSage INT;
    DECLARE @NewSage INT;
    
    -- 获取插入前表中的最大sage值（排除刚插入的记录）
    SELECT @MaxSage = MAX(Sage)
    FROM Worker
    WHERE Number NOT IN (SELECT Number FROM inserted);
    
    -- 如果表为空（第一次插入），@MaxSage为NULL，设置为-1以允许任何值插入
    IF @MaxSage IS NULL
        SET @MaxSage = -1;
    
    -- 检查插入的记录中是否有sage值小于等于最大值的
    SELECT @NewSage = MIN(Sage)
    FROM inserted;
    
    IF @NewSage <= @MaxSage
    BEGIN
        PRINT '错误：插入的sage值(' + CAST(@NewSage AS VARCHAR) + ')必须大于表中已记录的最大sage值(' + CAST(@MaxSage AS VARCHAR) + ')';
        ROLLBACK TRANSACTION;
    END
    ELSE
    BEGIN
        PRINT '触发器T4检查通过：新插入的sage值(' + CAST(@NewSage AS VARCHAR) + ')大于最大sage值(' + CAST(@MaxSage AS VARCHAR) + ')';
    END
END;
GO

PRINT '触发器T4创建完成';
PRINT '';

-- 题目2: 演示违反触发器T4的操作，即插入一条比表中已记录的最大sage值小的记录。
PRINT '========== 题目2：演示违反触发器T4的操作 ==========';
PRINT '';

PRINT '当前Worker表中的最大sage值：';
SELECT MAX(Sage) AS MaxSage FROM Worker;
PRINT '';

PRINT '尝试插入sage值为15的记录（当前最大值为25，应该失败）：';
BEGIN TRY
    INSERT INTO Worker (Number, Name, Sex, Sage, Department)
    VALUES ('00004', '测试', 'M', 15, '测试部');
    PRINT '插入成功';
END TRY
BEGIN CATCH
    PRINT '插入失败：' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- 题目3: 建立一个在worker表上的触发器T5，要求当更新一个记录的时候，表中记录的sage值要比已记录的sage值大，因为一般工资级别只能升不能降。
PRINT '========== 题目3：创建触发器T5 ==========';
PRINT '';
GO

CREATE TRIGGER T5
ON Worker
AFTER UPDATE
AS
BEGIN
    -- 检查是否有sage字段被更新
    IF UPDATE(Sage)
    BEGIN
        -- 检查更新后的sage值是否小于更新前的sage值
        IF EXISTS (
            SELECT 1
            FROM inserted i
            INNER JOIN deleted d ON i.Number = d.Number
            WHERE i.Sage <= d.Sage
        )
        BEGIN
            PRINT '错误：更新后的sage值必须大于更新前的sage值（工资级别只能升不能降）';
            ROLLBACK TRANSACTION;
        END
        ELSE
        BEGIN
            PRINT '触发器T5检查通过：sage值已正确更新（新值大于旧值）';
        END
    END
END;
GO

PRINT '触发器T5创建完成';
PRINT '';

-- 题目4: 演示违反触发器T5的操作。
PRINT '========== 题目4：演示违反触发器T5的操作 ==========';
PRINT '';

PRINT '查看当前Worker表中Number=00002的记录：';
SELECT * FROM Worker WHERE Number = '00002';
PRINT '';

PRINT '尝试将Number=00002的sage值从20降低到18（应该失败）：';
BEGIN TRY
    UPDATE Worker
    SET Sage = 18
    WHERE Number = '00002';
    PRINT '更新成功';
    SELECT * FROM Worker WHERE Number = '00002';
END TRY
BEGIN CATCH
    PRINT '更新失败：' + ERROR_MESSAGE();
    SELECT * FROM Worker WHERE Number = '00002';
END CATCH
PRINT '';

PRINT '尝试将Number=00002的sage值从20提升到22（应该成功）：';
BEGIN TRY
    UPDATE Worker
    SET Sage = 22
    WHERE Number = '00002';
    PRINT '更新成功';
    SELECT * FROM Worker WHERE Number = '00002';
END TRY
BEGIN CATCH
    PRINT '更新失败：' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- 题目5: 为worker表建立触发器T6，禁止修改编号为00001的记录。
PRINT '========== 题目5：创建触发器T6 ==========';
PRINT '';
GO

CREATE TRIGGER T6
ON Worker
AFTER UPDATE, DELETE
AS
BEGIN
    -- 检查是否有Number='00001'的记录被更新或删除
    -- 对于UPDATE：deleted表包含更新前的记录
    -- 对于DELETE：deleted表包含被删除的记录
    -- 对于UPDATE，即使更新后Number改变了，deleted表中仍会有原值'00001'
    IF EXISTS (
        SELECT 1 FROM deleted WHERE Number = '00001'
    )
    BEGIN
        PRINT '错误：禁止修改编号为00001的记录';
        ROLLBACK TRANSACTION;
    END
END;
GO

PRINT '触发器T6创建完成';
PRINT '';

PRINT '演示：尝试更新Number=00001的记录（应该失败）：';
BEGIN TRY
    UPDATE Worker
    SET Name = '新名字'
    WHERE Number = '00001';
    PRINT '更新成功';
END TRY
BEGIN CATCH
    PRINT '更新失败：' + ERROR_MESSAGE();
END CATCH
PRINT '';

PRINT '演示：尝试删除Number=00001的记录（应该失败）：';
BEGIN TRY
    DELETE FROM Worker
    WHERE Number = '00001';
    PRINT '删除成功';
END TRY
BEGIN CATCH
    PRINT '删除失败：' + ERROR_MESSAGE();
END CATCH
PRINT '';

-- 题目6: 建立基于students和stu_card两个表的视图，创建INSTEADOF触发器使该视图支持更新操作，并演示更新操作。
PRINT '========== 题目6：创建视图和INSTEADOF触发器 ==========';
PRINT '';
GO

-- 创建视图
CREATE VIEW student_card_view
AS
SELECT 
    s.sid,
    s.sname,
    s.email,
    s.grade,
    sc.card_id,
    sc.remained_money
FROM students s
INNER JOIN Stu_Card sc ON s.sid = sc.stu_id;
GO

PRINT '视图student_card_view创建完成';
PRINT '查看视图内容：';
SELECT * FROM student_card_view;
PRINT '';
GO

-- 创建INSTEAD OF UPDATE触发器
CREATE TRIGGER trg_student_card_view_update
ON student_card_view
INSTEAD OF UPDATE
AS
BEGIN
    -- 更新students表
    UPDATE students
    SET 
        sname = i.sname,
        email = i.email,
        grade = i.grade
    FROM students s
    INNER JOIN inserted i ON s.sid = i.sid;
    
    -- 更新Stu_Card表
    UPDATE Stu_Card
    SET 
        remained_money = i.remained_money
    FROM Stu_Card sc
    INNER JOIN inserted i ON sc.stu_id = i.sid;
    
    PRINT '视图更新成功：已同步更新students表和Stu_Card表';
END;
GO

PRINT 'INSTEAD OF UPDATE触发器创建完成';
PRINT '';

-- 演示更新操作
PRINT '演示：通过视图更新数据';
PRINT '更新前视图内容：';
SELECT * FROM student_card_view WHERE sid = '800001216';
PRINT '';

PRINT '执行更新操作（更新姓名和余额）：';
BEGIN TRY
    UPDATE student_card_view
    SET 
        sname = '张三（已更新）',
        remained_money = 150.75
    WHERE sid = '800001216';
    
    PRINT '更新后视图内容：';
    SELECT * FROM student_card_view WHERE sid = '800001216';
    PRINT '';
    
    PRINT '验证基表数据：';
    SELECT 'students表' AS 表名, sid, sname, email, grade FROM students WHERE sid = '800001216'
    UNION ALL
    SELECT 'Stu_Card表' AS 表名, stu_id AS sid, CAST(remained_money AS VARCHAR) AS sname, '' AS email, NULL AS grade FROM Stu_Card WHERE stu_id = '800001216';
END TRY
BEGIN CATCH
    PRINT '更新失败：' + ERROR_MESSAGE();
END CATCH
PRINT '';

PRINT '========== 实验完成 ==========';
