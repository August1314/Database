use School_Data;

-- (1)查询选修C++课程的成绩比姓名为 ZNKOO的学生高的所有学生的编号和姓名;
select distinct
    STUDENTS.sid,
    STUDENTS.sname
from
    STUDENTS
    join CHOICES on CHOICES.sid = STUDENTS.sid
    join COURSES on COURSES.cid = CHOICES.cid
where
    COURSES.cname = 'C++'
    and STUDENTS.sname != 'ZNKOO'
    and CHOICES.score > (
        select score
        from
            STUDENTS s
            join CHOICES c on s.sid = c.sid
            join COURSES co on c.cid = co.cid
        where
            s.sname = 'ZNKOO'
            and co.cname = 'C++'
    )

-- (2)找出和学生883794999或学生850955252的年级一样的学生的姓名;
select distinct
    sname
from STUDENTS
where
    STUDENTS.sid != '883794999'
    and STUDENTS.grade in (
        select grade
        from STUDENTS
        where
            STUDENTS.sid = '883794999'
    )
union
select distinct
    sname
from STUDENTS
where
    STUDENTS.sid != '850955252'
    and STUDENTS.grade in (
        select grade
        from STUDENTS
        where
            STUDENTS.sid = '850955252'
    )

-- (3)查询没有选修Java的学生名称;
SELECT SNAME
FROM STUDENTS
WHERE NOT EXISTS(
SELECT *
FROM CHOICES
JOIN COURSES ON CHOICES.CID=COURSES.CID
WHERE STUDENTS.SID=CHOICES.SID
AND COURSES.CNAME='Java')

-- (4)找出课时最少的课程的详细信息;
select *
from COURSES as col
where
    col.hour <= ALL (
        select hour
        from COURSES
        where
            COURSES.hour is not null
    )

select * from TEACHERS;

-- (5)查询工资最高的教师的编号和开设的课程号;
select t.tid, t.tname, ch.cid, t.salary
from
    TEACHERS as t
    join CHOICES as ch on t.tid = ch.tid
    join COURSES as co on ch.cid = co.cid
where
    t.salary >= ALL (
        select salary
        from TEACHERS
        where
            salary is not NULL
    )

-- (6)找出选修课程ERP成绩最高的学生编号;
select distinct
    ch.sid
from CHOICES as ch
    join COURSES as co on ch.cid = co.cid
where
    co.cname = 'ERP'
    and ch.score >= ALL (
        select score
        from CHOICES c
            join COURSES co2 on c.cid = co2.cid
        where
            co2.cname = 'ERP'
            and score is not null
    )

-- (7)查询没有学生选修的课程名称;
select distinct
    cname
from COURSES
except
select distinct
    cname
from CHOICES as ch
    join COURSES as co on ch.cid = co.cid

-- (8)查询讲授课程UML的教师所讲授的所有课程名称;
select distinct
    cname
from
    TEACHERS as t
    join CHOICES as ch on ch.tid = t.tid
    join COURSES as co on co.cid = ch.cid
where
    t.tid in (
        select t.tid
        from
            TEACHERS as t
            join CHOICES as ch on ch.tid = t.tid
            join COURSES as co on co.cid = ch.cid
        where
            co.cname = 'UML'
    )

-- (9)使用集合交运算， 查询既选修了database又选修了UML课程的学生编号;
select distinct
    STUDENTS.sid
from
    STUDENTS
    join CHOICES on STUDENTS.sid = CHOICES.sid
    join COURSES on COURSES.cid = CHOICES.cid
where
    cname = 'database'
intersect
select distinct
    STUDENTS.sid
from
    STUDENTS
    join CHOICES on STUDENTS.sid = CHOICES.sid
    join COURSES on COURSES.cid = CHOICES.cid
where
    cname = 'UML'

-- (10)使用集合减运算， 查询选修了database却没有选修UML课程的学生编号;
select distinct
    STUDENTS.sid
from
    STUDENTS
    join CHOICES on STUDENTS.sid = CHOICES.sid
    join COURSES on COURSES.cid = CHOICES.cid
where
    cname = 'database'
except
select distinct
    STUDENTS.sid
from
    STUDENTS
    join CHOICES on STUDENTS.sid = CHOICES.sid
    join COURSES on COURSES.cid = CHOICES.cid
where
    cname = 'UML'