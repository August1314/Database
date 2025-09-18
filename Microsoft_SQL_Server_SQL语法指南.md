# Microsoft SQL Server SQL 语法指南

## 📚 目录
1. [基础语法](#基础语法)
2. [数据查询 (SELECT)](#数据查询-select)
3. [数据操作 (INSERT, UPDATE, DELETE)](#数据操作)
4. [表管理 (CREATE, ALTER, DROP)](#表管理)
5. [索引和约束](#索引和约束)
6. [存储过程和函数](#存储过程和函数)
7. [事务控制](#事务控制)
8. [高级查询](#高级查询)
9. [常用函数](#常用函数)
10. [最佳实践](#最佳实践)

---

## 基础语法

### 注释
```sql
-- 单行注释
/* 多行注释
   可以跨越多行 */
```

### 标识符和命名规则
```sql
-- 标准标识符（推荐）
CREATE TABLE Students (
    StudentID INT,
    StudentName VARCHAR(50)
);

-- 带引号的标识符（包含特殊字符或关键字）
CREATE TABLE [Order Details] (
    [Order ID] INT,
    [Product Name] VARCHAR(100)
);
```

---

## 数据查询 (SELECT)

### 基本查询
```sql
-- 查询所有列
SELECT * FROM Students;

-- 查询指定列
SELECT StudentID, StudentName, Age FROM Students;

-- 使用别名
SELECT 
    StudentID AS ID,
    StudentName AS Name,
    Age
FROM Students;
```

### WHERE 条件
```sql
-- 基本条件
SELECT * FROM Students WHERE Age > 18;

-- 多个条件
SELECT * FROM Students 
WHERE Age > 18 AND Major = 'Computer Science';

-- 模糊查询
SELECT * FROM Students 
WHERE StudentName LIKE '张%';

-- IN 操作符
SELECT * FROM Students 
WHERE Major IN ('Computer Science', 'Mathematics');

-- BETWEEN 操作符
SELECT * FROM Students 
WHERE Age BETWEEN 18 AND 25;
```

### 排序和限制
```sql
-- 排序
SELECT * FROM Students 
ORDER BY Age DESC, StudentName ASC;

-- 限制结果数量
SELECT TOP 10 * FROM Students 
ORDER BY Age DESC;

-- 分页查询
SELECT * FROM Students 
ORDER BY StudentID
OFFSET 10 ROWS FETCH NEXT 5 ROWS ONLY;
```

---

## 数据操作

### INSERT 插入数据
```sql
-- 插入单行
INSERT INTO Students (StudentID, StudentName, Age, Major)
VALUES (1, '张三', 20, 'Computer Science');

-- 插入多行
INSERT INTO Students (StudentID, StudentName, Age, Major)
VALUES 
    (2, '李四', 19, 'Mathematics'),
    (3, '王五', 21, 'Physics');

-- 从其他表插入
INSERT INTO Students (StudentID, StudentName, Age)
SELECT StudentID, StudentName, Age 
FROM NewStudents;
```

### UPDATE 更新数据
```sql
-- 更新单列
UPDATE Students 
SET Age = 22 
WHERE StudentID = 1;

-- 更新多列
UPDATE Students 
SET Age = 22, Major = 'Data Science' 
WHERE StudentID = 1;

-- 使用子查询更新
UPDATE Students 
SET Major = 'Computer Science'
WHERE StudentID IN (
    SELECT StudentID FROM Enrollments 
    WHERE CourseID = 'CS101'
);
```

### DELETE 删除数据
```sql
-- 删除指定记录
DELETE FROM Students 
WHERE StudentID = 1;

-- 删除所有记录
DELETE FROM Students;

-- 使用子查询删除
DELETE FROM Students 
WHERE StudentID NOT IN (
    SELECT DISTINCT StudentID FROM Enrollments
);
```

---

## 表管理

### CREATE TABLE 创建表
```sql
-- 基本表结构
CREATE TABLE Students (
    StudentID INT PRIMARY KEY IDENTITY(1,1),
    StudentName VARCHAR(50) NOT NULL,
    Age INT CHECK (Age >= 16),
    Major VARCHAR(50),
    Email VARCHAR(100) UNIQUE,
    EnrollmentDate DATE DEFAULT GETDATE()
);

-- 创建表时添加约束
CREATE TABLE Courses (
    CourseID VARCHAR(10) PRIMARY KEY,
    CourseName VARCHAR(100) NOT NULL,
    Credits INT CHECK (Credits > 0),
    Instructor VARCHAR(50),
    CONSTRAINT FK_Course_Instructor 
        FOREIGN KEY (Instructor) REFERENCES Instructors(InstructorID)
);
```

### ALTER TABLE 修改表
```sql
-- 添加列
ALTER TABLE Students 
ADD Phone VARCHAR(20);

-- 修改列
ALTER TABLE Students 
ALTER COLUMN Phone VARCHAR(15);

-- 删除列
ALTER TABLE Students 
DROP COLUMN Phone;

-- 添加约束
ALTER TABLE Students 
ADD CONSTRAINT CK_Student_Age CHECK (Age >= 16);

-- 删除约束
ALTER TABLE Students 
DROP CONSTRAINT CK_Student_Age;
```

### DROP TABLE 删除表
```sql
-- 删除表
DROP TABLE Students;

-- 条件删除（如果存在）
IF OBJECT_ID('Students', 'U') IS NOT NULL
    DROP TABLE Students;
```

---

## 索引和约束

### 创建索引
```sql
-- 创建唯一索引
CREATE UNIQUE INDEX IX_Students_Email 
ON Students (Email);

-- 创建复合索引
CREATE INDEX IX_Students_Major_Age 
ON Students (Major, Age);

-- 创建包含列索引
CREATE INDEX IX_Students_Major_Include 
ON Students (Major) 
INCLUDE (StudentName, Age);
```

### 约束类型
```sql
-- 主键约束
ALTER TABLE Students 
ADD CONSTRAINT PK_Students PRIMARY KEY (StudentID);

-- 外键约束
ALTER TABLE Enrollments 
ADD CONSTRAINT FK_Enrollments_Students 
FOREIGN KEY (StudentID) REFERENCES Students(StudentID);

-- 检查约束
ALTER TABLE Students 
ADD CONSTRAINT CK_Students_Age 
CHECK (Age >= 16 AND Age <= 100);

-- 唯一约束
ALTER TABLE Students 
ADD CONSTRAINT UQ_Students_Email 
UNIQUE (Email);
```

---

## 存储过程和函数

### 存储过程
```sql
-- 创建存储过程
CREATE PROCEDURE GetStudentsByMajor
    @Major VARCHAR(50)
AS
BEGIN
    SELECT StudentID, StudentName, Age
    FROM Students
    WHERE Major = @Major;
END;

-- 调用存储过程
EXEC GetStudentsByMajor @Major = 'Computer Science';

-- 带输出参数的存储过程
CREATE PROCEDURE GetStudentCount
    @Major VARCHAR(50),
    @Count INT OUTPUT
AS
BEGIN
    SELECT @Count = COUNT(*)
    FROM Students
    WHERE Major = @Major;
END;

-- 调用带输出参数的存储过程
DECLARE @Result INT;
EXEC GetStudentCount @Major = 'Computer Science', @Count = @Result OUTPUT;
SELECT @Result AS StudentCount;
```

### 用户定义函数
```sql
-- 标量函数
CREATE FUNCTION GetStudentFullInfo(@StudentID INT)
RETURNS VARCHAR(200)
AS
BEGIN
    DECLARE @Result VARCHAR(200);
    SELECT @Result = StudentName + ' (' + Major + ')'
    FROM Students
    WHERE StudentID = @StudentID;
    RETURN @Result;
END;

-- 表值函数
CREATE FUNCTION GetStudentsByAgeRange(@MinAge INT, @MaxAge INT)
RETURNS TABLE
AS
RETURN
(
    SELECT StudentID, StudentName, Age, Major
    FROM Students
    WHERE Age BETWEEN @MinAge AND @MaxAge
);

-- 使用函数
SELECT dbo.GetStudentFullInfo(1) AS StudentInfo;
SELECT * FROM dbo.GetStudentsByAgeRange(18, 25);
```

---

## 事务控制

### 基本事务
```sql
-- 开始事务
BEGIN TRANSACTION;

-- 执行操作
INSERT INTO Students (StudentName, Age, Major)
VALUES ('新学生', 20, 'Computer Science');

-- 提交事务
COMMIT TRANSACTION;

-- 回滚事务
BEGIN TRANSACTION;
INSERT INTO Students (StudentName, Age, Major)
VALUES ('测试学生', 20, 'Test');
ROLLBACK TRANSACTION;
```

### 保存点
```sql
BEGIN TRANSACTION;
INSERT INTO Students (StudentName, Age, Major)
VALUES ('学生1', 20, 'CS');

SAVE TRANSACTION SavePoint1;

INSERT INTO Students (StudentName, Age, Major)
VALUES ('学生2', 21, 'Math');

-- 回滚到保存点
ROLLBACK TRANSACTION SavePoint1;

-- 提交剩余事务
COMMIT TRANSACTION;
```

---

## 高级查询

### JOIN 连接
```sql
-- 内连接
SELECT s.StudentName, c.CourseName, e.Grade
FROM Students s
INNER JOIN Enrollments e ON s.StudentID = e.StudentID
INNER JOIN Courses c ON e.CourseID = c.CourseID;

-- 左外连接
SELECT s.StudentName, c.CourseName
FROM Students s
LEFT JOIN Enrollments e ON s.StudentID = e.StudentID
LEFT JOIN Courses c ON e.CourseID = c.CourseID;

-- 右外连接
SELECT s.StudentName, c.CourseName
FROM Students s
RIGHT JOIN Enrollments e ON s.StudentID = e.StudentID
RIGHT JOIN Courses c ON e.CourseID = c.CourseID;

-- 全外连接
SELECT s.StudentName, c.CourseName
FROM Students s
FULL OUTER JOIN Enrollments e ON s.StudentID = e.StudentID
FULL OUTER JOIN Courses c ON e.CourseID = c.CourseID;
```

### 子查询
```sql
-- 标量子查询
SELECT StudentName, 
       (SELECT COUNT(*) FROM Enrollments WHERE StudentID = s.StudentID) AS CourseCount
FROM Students s;

-- 存在性检查
SELECT StudentName
FROM Students s
WHERE EXISTS (
    SELECT 1 FROM Enrollments e 
    WHERE e.StudentID = s.StudentID 
    AND e.Grade > 90
);

-- IN 子查询
SELECT StudentName
FROM Students
WHERE StudentID IN (
    SELECT StudentID FROM Enrollments 
    WHERE Grade > 85
);
```

### 聚合函数
```sql
-- 基本聚合
SELECT 
    COUNT(*) AS TotalStudents,
    AVG(Age) AS AverageAge,
    MIN(Age) AS MinAge,
    MAX(Age) AS MaxAge,
    SUM(Credits) AS TotalCredits
FROM Students s
JOIN Enrollments e ON s.StudentID = e.StudentID
JOIN Courses c ON e.CourseID = c.CourseID;

-- GROUP BY
SELECT Major, COUNT(*) AS StudentCount, AVG(Age) AS AverageAge
FROM Students
GROUP BY Major;

-- HAVING
SELECT Major, COUNT(*) AS StudentCount
FROM Students
GROUP BY Major
HAVING COUNT(*) > 5;
```

### 窗口函数
```sql
-- ROW_NUMBER
SELECT StudentName, Age,
       ROW_NUMBER() OVER (ORDER BY Age DESC) AS AgeRank
FROM Students;

-- RANK
SELECT StudentName, Grade,
       RANK() OVER (ORDER BY Grade DESC) AS GradeRank
FROM Enrollments;

-- 分区窗口函数
SELECT StudentName, Major, Age,
       ROW_NUMBER() OVER (PARTITION BY Major ORDER BY Age DESC) AS MajorRank
FROM Students;
```

---

## 常用函数

### 字符串函数
```sql
-- 字符串连接
SELECT StudentName + ' (' + Major + ')' AS FullInfo
FROM Students;

-- 字符串长度
SELECT StudentName, LEN(StudentName) AS NameLength
FROM Students;

-- 子字符串
SELECT StudentName, SUBSTRING(StudentName, 1, 2) AS FirstTwoChars
FROM Students;

-- 替换
SELECT StudentName, REPLACE(StudentName, '张', '李') AS ModifiedName
FROM Students;

-- 大小写转换
SELECT UPPER(StudentName) AS UpperName,
       LOWER(StudentName) AS LowerName
FROM Students;
```

### 日期函数
```sql
-- 当前日期时间
SELECT GETDATE() AS CurrentDateTime,
       GETUTCDATE() AS CurrentUTCDateTime;

-- 日期部分
SELECT StudentName,
       YEAR(EnrollmentDate) AS EnrollmentYear,
       MONTH(EnrollmentDate) AS EnrollmentMonth,
       DAY(EnrollmentDate) AS EnrollmentDay
FROM Students;

-- 日期计算
SELECT StudentName,
       DATEDIFF(YEAR, EnrollmentDate, GETDATE()) AS YearsEnrolled
FROM Students;

-- 日期格式化
SELECT StudentName,
       FORMAT(EnrollmentDate, 'yyyy-MM-dd') AS FormattedDate
FROM Students;
```

### 数学函数
```sql
-- 基本数学函数
SELECT 
    ROUND(3.14159, 2) AS Rounded,
    CEILING(3.2) AS Ceiling,
    FLOOR(3.8) AS Floor,
    ABS(-5) AS Absolute,
    POWER(2, 3) AS Power
FROM Students;
```

### 条件函数
```sql
-- CASE 表达式
SELECT StudentName, Age,
       CASE 
           WHEN Age < 18 THEN '未成年'
           WHEN Age BETWEEN 18 AND 25 THEN '青年'
           ELSE '成年'
       END AS AgeGroup
FROM Students;

-- IIF 函数
SELECT StudentName, Age,
       IIF(Age >= 18, '成年', '未成年') AS AgeStatus
FROM Students;

-- COALESCE 函数
SELECT StudentName, 
       COALESCE(Phone, Email, '无联系方式') AS ContactInfo
FROM Students;
```

---

## 最佳实践

### 性能优化
```sql
-- 使用适当的索引
CREATE INDEX IX_Students_Major ON Students(Major);

-- 避免 SELECT *
SELECT StudentID, StudentName FROM Students;

-- 使用参数化查询
DECLARE @Major VARCHAR(50) = 'Computer Science';
SELECT * FROM Students WHERE Major = @Major;

-- 使用 EXISTS 而不是 IN（大数据集）
SELECT StudentName FROM Students s
WHERE EXISTS (
    SELECT 1 FROM Enrollments e 
    WHERE e.StudentID = s.StudentID
);
```

### 安全性
```sql
-- 使用参数化查询防止 SQL 注入
CREATE PROCEDURE GetStudentsByMajor
    @Major VARCHAR(50)
AS
BEGIN
    SELECT * FROM Students WHERE Major = @Major;
END;

-- 使用适当的权限
GRANT SELECT ON Students TO StudentRole;
GRANT INSERT, UPDATE, DELETE ON Students TO AdminRole;
```

### 代码规范
```sql
-- 使用有意义的表名和列名
CREATE TABLE StudentEnrollments (
    StudentID INT,
    CourseID VARCHAR(10),
    EnrollmentDate DATE,
    Grade DECIMAL(3,2)
);

-- 使用一致的命名约定
-- 表名：PascalCase (StudentEnrollments)
-- 列名：PascalCase (StudentID, CourseID)
-- 存储过程：动词开头 (GetStudentsByMajor)
```

---

## 🎯 学习建议

1. **从基础开始** - 先掌握 SELECT, INSERT, UPDATE, DELETE
2. **多练习** - 使用您的 School_Data 数据库进行练习
3. **理解索引** - 学习如何优化查询性能
4. **掌握 JOIN** - 这是关系型数据库的核心
5. **学习事务** - 确保数据一致性

## 📚 推荐资源

- [Microsoft SQL Server 官方文档](https://docs.microsoft.com/en-us/sql/)
- [SQL Server 教程](https://www.w3schools.com/sql/)
- [SQL Server 最佳实践](https://docs.microsoft.com/en-us/sql/sql-server/best-practices/)

---

**开始您的 SQL Server 学习之旅吧！** 🚀
