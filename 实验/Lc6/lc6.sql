use School_Data;

--WITH CHECK OPTION会对插入或更新操作进行检查， 由于新插入操作score=59， 不满足视图CS定义"score>60"的条件， 所以数据插入失败

--将视图CS(包含定义WITH CHECK OPTION) 中所有课程编号为10010的课程成绩都减五分， 是否可以正确执行？
--因为有些score减5分后， 会<60， 不满足WITH CHECK OPTION的条件。所以数据更新失败。

--删除视图后，由该视图导出的子视图也会失效，也必须删除

--(1)定义选课信息和名称的视图 VIEWC;
drop view if exists VIEWC;
go

create view VIEWC as
select CHOICES.*, COURSES.cname
from CHOICES
    join COURSES on CHOICES.cid = COURSES.cid;
go

select * from VIEWC;

--(2)定义学生姓名与选课信息的视图 VIEWS;
drop view if exists VIEWS;
go

create view VIEWS as
select STUDENTS.sname, CHOICES.*
from CHOICES
    join STUDENTS on CHOICES.sid = STUDENTS.sid;
go

select * from VIEWS;

--(3)定义年级低于1998的学生的视图S1(SID, SNAME, GRADE);
drop view if exists S1;
go

create view S1 (SID, SNAME, GRADE) as
select sid, sname, grade
from STUDENTS
where
    grade > 1998;
go

select * from S1;

--(4)查询学生为"uxjof"的学生的选课信息;
select * from VIEWS where sname = 'uxjof';

--(5)查询选修课程"UML"的学生的编号和成绩;
select sid as 学生编号, score as 成绩 from VIEWC where cname = 'UML';

--(6)向视图S1插入记录(60000001,Lily,2001);
-- 问题：视图S1定义为grade>1998，插入的grade=2001满足条件
-- 如果视图没有WITH CHECK OPTION，插入会成功并且在视图中可以看到
-- 如果视图有WITH CHECK OPTION，插入也会成功，因为满足条件

--6先清理可能存在的测试数据
delete from STUDENTS where sid = '60000001';

--6查看插入前的视图内容
select * from S1 where SID = '60000001';

--6查看插入前的基表内容
select * from STUDENTS where sid = '60000001';

-- 执行插入操作
insert into S1 (SID, SNAME, GRADE) values ('60000001', 'Lily', 2001);

--6查看插入后的视图内容（可以看到grade=2001的记录，因为满足视图条件grade>1998）
select * from S1 where SID = '60000001';

--6查看插入后的基表内容（可以看到记录已插入）
select * from STUDENTS where sid = '60000001';

--(7)定义包括更新和插入约束的视图S1,尝试向视图插入记录(60000001,Lily,1997),删除所有年级为1999的学生记录,讨论更新和插入约束带来的影响。
-- 先清理测试数据
delete from STUDENTS where sid = '60000001';

-- 删除原来的S1视图
drop view if exists S1;
go

-- 重新创建带WITH CHECK OPTION的视图
create view S1 (SID, SNAME, GRADE) as
select sid, sname, grade
from STUDENTS
where
    grade > 1998
with
    check option;
go

--7操作前-视图S1中sid=60000001的记录
select * from S1 where SID = '60000001';

--7操作前-基表中grade=1999的记录数
select count(*) as 记录数 from STUDENTS where grade = 1999;

-- 尝试插入记录(60000001,Lily,1997) - 应该失败，因为1997不满足grade>1998
-- 由于有WITH CHECK OPTION，这个插入操作会被拒绝
insert into S1 (SID, SNAME, GRADE) values ('60000001', 'Lily', 1997);

--7插入后-视图S1中sid=60000001的记录
select * from S1 where SID = '60000001';

--7插入后-基表中sid=60000001的记录
select * from STUDENTS where sid = '60000001';

-- 删除所有年级为1999的学生记录
-- 年级1999在视图S1中(因为1999>1998)，不可以通过视图删除，要先删除基表的内容，视图动态变化
delete
from choices
where sid in(
    select sid
    from STUDENTS
    where STUDENTS.grade = 1999
    )

-- 这个操作会删除所有grade=1999的记录
delete from S1 where GRADE = 1999;

--7删除后-视图中grade=1999的记录数
select count(*) as 记录数 from STUDENTS where grade = 1999;

--7删除后-基表中grade=1999的记录数
select count(*) as 记录数 from STUDENTS where grade = 1999;

-- 讨论：WITH CHECK OPTION确保通过视图插入或更新的数据必须满足视图的WHERE条件
-- 1. 插入grade=1997失败，因为不满足grade>1998，WITH CHECK OPTION会拒绝此操作
-- 2. 删除grade=1999成功，因为这些记录在视图范围内(1999>1998)，记录数会减少

--(8)在视图 VIEWS中将姓名为"uxjof"的学生的选课成绩都加上5分。
-- 先备份原始成绩到临时表
if object_id('tempdb..#uxjof_backup') is not null
    drop table #uxjof_backup;

select C.no, C.sid, C.tid, C.cid, C.score as original_score
into #uxjof_backup
from CHOICES C
join STUDENTS S on C.sid = S.sid
where S.sname = 'uxjof';

--8更新前-uxjof的选课成绩
select * from VIEWS where sname = 'uxjof';

-- 执行更新操作
update VIEWS set score = score + 5 where sname = 'uxjof';

--8更新后-uxjof的选课成绩
select * from VIEWS where sname = 'uxjof';

--8更新后-基表CHOICES中的对应记录
select C.*
from CHOICES C
    join STUDENTS S on C.sid = S.sid
where
    S.sname = 'uxjof';

-- 恢复原始成绩（避免反复运行导致成绩越来越高）
update C
set C.score = B.original_score
from CHOICES C
join #uxjof_backup B on C.no = B.no;

--8恢复后-uxjof的选课成绩已恢复到原始值
select * from VIEWS where sname = 'uxjof';

--(9)取消以上建立的所有视图。
--9删除前-当前数据库中的视图
select TABLE_NAME as 视图名称
from INFORMATION_SCHEMA.VIEWS
where
    TABLE_NAME in ('VIEWC', 'VIEWS', 'S1');

-- 删除视图
drop view if exists VIEWC;

drop view if exists VIEWS;

drop view if exists S1;

--9删除后-当前数据库中的视图
select TABLE_NAME as 视图名称
from INFORMATION_SCHEMA.VIEWS
where
    TABLE_NAME in ('VIEWC', 'VIEWS', 'S1');