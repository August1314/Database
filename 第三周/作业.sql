USE School_Data;

-- (1) 查询全部课程的详细记录
SELECT DISTINCT *
FROM COURSES
ORDER BY cid;

-- (2) 查询所有有选修课的学生的编号
SELECT DISTINCT C.sid, S.sname
FROM CHOICES AS C
JOIN STUDENTS AS S ON C.sid = S.sid
ORDER BY C.sid;

-- (3) 查询课时 < 88(小时) 的课程的编号
SELECT cid
FROM COURSES
WHERE [hour] < 88;

-- (4) 找出总分超过 400 分的学生
SELECT S.sid AS [学号], SUM(C.score) AS [总分]
FROM STUDENTS AS S
JOIN CHOICES AS C ON S.sid = C.sid
GROUP BY S.sid
HAVING SUM(C.score) > 400;

-- (5) 查询课程的总数
SELECT COUNT(*) FROM COURSES;

-- (6) 查询所有课程和选修该课程的学生总数（包含无人选的课程）
SELECT C.cid, COUNT(CH.sid) AS [number of students]
FROM COURSES AS C
LEFT JOIN CHOICES AS CH ON CH.cid = C.cid
GROUP BY C.cid;

-- (7) 查询选修成绩超过 60 的课程超过两门的学生编号
SELECT X.sid, MIN(X.score) AS [lowest score]
FROM CHOICES AS X
WHERE X.score > 60
GROUP BY X.sid
HAVING COUNT(*) > 2;

-- (8) 统计各个学生的选修课程数目和平均成绩
SELECT CH.sid AS [学号],
       COUNT(*) AS [选修课程数目],
       AVG(CH.score) AS [平均成绩]
FROM CHOICES AS CH
GROUP BY CH.sid;

-- (9) 查询选修 Java 的所有学生的编号及姓名
SELECT C.sid AS [学号], S.sname AS [姓名]
FROM CHOICES AS C
JOIN STUDENTS AS S ON C.sid = S.sid
JOIN COURSES  AS K ON C.cid = K.cid
WHERE K.cname = 'java';

-- (10) 查询姓名为 sssht 的学生所选课程的编号和成绩
SELECT C.cid AS [课程编号], C.score AS [成绩]
FROM CHOICES AS C
JOIN STUDENTS AS S ON C.sid = S.sid
WHERE S.sname = 'sssht';

-- (11) 查询课时比课程 C++ 多的课程的名称
SELECT X.cname
FROM COURSES AS X
JOIN COURSES AS Y ON Y.cname = 'C++'
WHERE X.cname <> 'C++' AND X.[hour] > Y.[hour];