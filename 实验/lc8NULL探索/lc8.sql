-- ========================================
-- SQL Server 空值处理与分组查询实验 (Lecture 8)
-- ========================================

USE School_Data;
GO

-- ==================== 实验题目 ====================

--(1)通过查询选修课程C++的学生的人数，其中成绩合格的学生人数，不合格的学生人数，讨论NULL值的特殊含义。

-- 查询选修C++课程的总人数
SELECT COUNT(*) AS [选修C++的总人数]
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    );

-- 查询成绩合格的学生人数（score >= 60）
SELECT COUNT(*) AS 成绩合格的学生人数
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    )
    AND score >= 60;

-- 查询成绩不合格的学生人数（score < 60）
SELECT COUNT(*) AS 成绩不合格的学生人数
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    )
    AND score < 60;

-- 查询成绩为NULL的学生人数
SELECT COUNT(*) AS 成绩为NULL的学生人数
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    )
    AND score IS NULL;

-- 综合查询：显示所有统计信息
SELECT
    COUNT(*) AS 总人数,
    COUNT(score) AS 有成绩的人数,
    SUM(
        CASE
            WHEN score >= 60 THEN 1
            ELSE 0
        END
    ) AS 合格人数,
    SUM(
        CASE
            WHEN score < 60 THEN 1
            ELSE 0
        END
    ) AS 不合格人数,
    SUM(
        CASE
            WHEN score IS NULL THEN 1
            ELSE 0
        END
    ) AS 成绩为NULL的人数
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    );
GO

--(2)查询选修课程C++的学生的编号和成绩，使用 ORDER BY按成绩进行排序时,取NULL的项是否出现在结果中？如果有，在什么位置?

-- 按成绩升序排序
SELECT sid AS 学生编号, score AS 成绩
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    )
ORDER BY score ASC;

-- 按成绩降序排序
SELECT sid AS 学生编号, score AS 成绩
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    )
ORDER BY score DESC;
GO

--(3)在上面的查询的过程中，如果加上保留字 DISTINCT会有什么效果呢?

-- 不使用DISTINCT
SELECT sid AS 学生编号, score AS 成绩
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    )
ORDER BY score ASC;

-- 使用DISTINCT
SELECT DISTINCT
    sid AS 学生编号,
    score AS 成绩
FROM CHOICES
WHERE
    cid = (
        SELECT cid
        FROM COURSES
        WHERE
            cname = 'C++'
    )
ORDER BY score ASC;
GO

--(4)按年级对所有的学生进行分组，能得到多少个组?与现实的情况有什么不同?

-- 按年级分组，统计每个年级的学生人数
SELECT grade AS 年级, COUNT(*) AS 学生人数
FROM STUDENTS
GROUP BY
    grade
ORDER BY grade;

-- 查看是否存在NULL年级
SELECT COUNT(*) AS [NULL年级的学生人数] FROM STUDENTS WHERE grade IS NULL;
GO

--(5)结合分组,使用集合函数求每个课程选修的学生的平均分,总的选课记录数,最高成绩,最低成绩,讨论考察取空值的项对集合函数的作用的影响。

-- 按课程分组，统计各项指标
SELECT
    c.cname AS 课程名称,
    COUNT(*) AS 选课记录数,
    COUNT(ch.score) AS 有成绩的记录数,
    AVG(ch.score) AS 平均分,
    MAX(ch.score) AS 最高成绩,
    MIN(ch.score) AS 最低成绩,
    SUM(
        CASE
            WHEN ch.score IS NULL THEN 1
            ELSE 0
        END
    ) AS 成绩为NULL的记录数
FROM CHOICES ch
    JOIN COURSES c ON ch.cid = c.cid
GROUP BY
    c.cname
ORDER BY c.cname;

-- 对比：使用COUNT(*)和COUNT(score)的区别
SELECT
    c.cname AS 课程名称,
    COUNT(*) AS [COUNT星号],
    COUNT(ch.score) AS COUNT_score,
    COUNT(*) - COUNT(ch.score) AS [差值即NULL数量]
FROM CHOICES ch
    JOIN COURSES c ON ch.cid = c.cid
GROUP BY
    c.cname
ORDER BY c.cname;
GO

--(6)采用嵌套查询的方式,利用比较运算符和谓词ALL的结合来查询表 STUDENTS中最晚入学的学生年级。当存在 GRADE取空值的项时,考虑可能出现的情况,并解释。

-- 方法1：使用MAX函数
SELECT MAX(grade) AS 最晚入学年级 FROM STUDENTS;

-- 方法2：使用嵌套查询和ALL谓词
SELECT DISTINCT
    grade AS 最晚入学年级
FROM STUDENTS
WHERE
    grade >= ALL (
        SELECT grade
        FROM STUDENTS
        WHERE
            grade IS NOT NULL
    );

-- 查看是否存在NULL年级的学生
SELECT sid, sname, grade FROM STUDENTS WHERE grade IS NULL;

-- 如果不排除NULL，查看结果
SELECT DISTINCT
    grade AS 最晚入学年级
FROM STUDENTS
WHERE
    grade >= ALL (
        SELECT grade
        FROM STUDENTS
    );
GO