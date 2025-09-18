-- MySQL 学习示例数据库
-- 这个文件包含了学习 MySQL 的基础示例

-- 创建学习数据库
CREATE DATABASE IF NOT EXISTS learning_db;
USE learning_db;

-- 创建学生表
CREATE TABLE students (
    id INT PRIMARY KEY AUTO_INCREMENT,
    name VARCHAR(50) NOT NULL,
    age INT,
    email VARCHAR(100),
    major VARCHAR(50),
    enrollment_date DATE
);

-- 创建课程表
CREATE TABLE courses (
    id INT PRIMARY KEY AUTO_INCREMENT,
    course_name VARCHAR(100) NOT NULL,
    credits INT,
    instructor VARCHAR(50)
);

-- 创建选课表（学生和课程的关系表）
CREATE TABLE enrollments (
    id INT PRIMARY KEY AUTO_INCREMENT,
    student_id INT,
    course_id INT,
    grade DECIMAL(3,2),
    semester VARCHAR(20),
    FOREIGN KEY (student_id) REFERENCES students(id),
    FOREIGN KEY (course_id) REFERENCES courses(id)
);

-- 插入示例数据 - 学生
INSERT INTO students (name, age, email, major, enrollment_date) VALUES
('张三', 20, 'zhangsan@email.com', '计算机科学', '2023-09-01'),
('李四', 19, 'lisi@email.com', '数学', '2023-09-01'),
('王五', 21, 'wangwu@email.com', '物理', '2023-09-01'),
('赵六', 20, 'zhaoliu@email.com', '计算机科学', '2023-09-01'),
('钱七', 22, 'qianqi@email.com', '化学', '2023-09-01');

-- 插入示例数据 - 课程
INSERT INTO courses (course_name, credits, instructor) VALUES
('数据库原理', 3, '张教授'),
('数据结构', 4, '李教授'),
('算法设计', 3, '王教授'),
('线性代数', 3, '赵教授'),
('概率论', 3, '钱教授');

-- 插入示例数据 - 选课
INSERT INTO enrollments (student_id, course_id, grade, semester) VALUES
(1, 1, 85.5, '2023秋季'),
(1, 2, 92.0, '2023秋季'),
(2, 3, 78.5, '2023秋季'),
(2, 4, 88.0, '2023秋季'),
(3, 1, 90.5, '2023秋季'),
(3, 5, 85.0, '2023秋季'),
(4, 1, 95.0, '2023秋季'),
(4, 2, 89.5, '2023秋季'),
(5, 3, 82.0, '2023秋季'),
(5, 4, 91.5, '2023秋季');

-- 基础查询示例

-- 1. 查看所有学生
SELECT * FROM students;

-- 2. 查看所有课程
SELECT * FROM courses;

-- 3. 查看所有选课记录
SELECT * FROM enrollments;

-- 4. 查询计算机科学专业的学生
SELECT name, age, email FROM students WHERE major = '计算机科学';

-- 5. 查询年龄大于20的学生
SELECT name, age FROM students WHERE age > 20;

-- 6. 查询学分大于3的课程
SELECT course_name, credits, instructor FROM courses WHERE credits > 3;

-- 7. 查询成绩大于85的选课记录
SELECT * FROM enrollments WHERE grade > 85;

-- 8. 使用 JOIN 查询学生姓名和课程名称
SELECT s.name, c.course_name, e.grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id;

-- 9. 查询每个学生的平均成绩
SELECT s.name, AVG(e.grade) as average_grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name;

-- 10. 查询每门课程的选课人数
SELECT c.course_name, COUNT(e.student_id) as enrollment_count
FROM courses c
LEFT JOIN enrollments e ON c.id = e.course_id
GROUP BY c.id, c.course_name;

-- 11. 查询成绩排名前3的学生
SELECT s.name, c.course_name, e.grade
FROM students s
JOIN enrollments e ON s.id = e.student_id
JOIN courses c ON e.course_id = c.id
ORDER BY e.grade DESC
LIMIT 3;

-- 12. 统计各专业的学生人数
SELECT major, COUNT(*) as student_count
FROM students
GROUP BY major;

-- 13. 查询没有选课的学生
SELECT s.name, s.major
FROM students s
LEFT JOIN enrollments e ON s.id = e.student_id
WHERE e.student_id IS NULL;

-- 14. 查询选课最多的学生
SELECT s.name, COUNT(e.course_id) as course_count
FROM students s
JOIN enrollments e ON s.id = e.student_id
GROUP BY s.id, s.name
ORDER BY course_count DESC
LIMIT 1;

-- 15. 更新学生信息示例
-- UPDATE students SET age = 21 WHERE name = '张三';

-- 16. 删除记录示例（请谨慎使用）
-- DELETE FROM enrollments WHERE grade < 60;

-- 查看表结构
DESCRIBE students;
DESCRIBE courses;
DESCRIBE enrollments;
