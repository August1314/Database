use school_data;
--1.创建表CARD(cid,sid,money),其中cid为主键,具有唯一性约束，sid为外键，参照STUDENTS表的sid字段。
-- 数据类型：cid为char(10),sid为char(10),money为decimal(10,2)。
create TABLE CARD(
    cid char(10) primary key,
    sid char(10) references students(sid),
    money decimal(10,2)
);

--2.给表CARD增加一个属性列：bank，数据类型为char(20)。
alter table card add bank char(20);

--3.删除表CARD的属性bank。
alter table card drop column bank;

--4.查询工资最高的教师姓名和开设的课程编号。
select tname,cid
from teachers as t
join choices as ch
on ch.tid = t.tid
where salary=(select MAX(salary) from TEACHERS where salary is not null)

--5.查询所有课程平均课时。
select avg(hour)
from courses;

--6.利用集合减运算，查询选修课程C++但没有选修database的学生编号。
select s.sid
from students as s
left join choices as c
on s.sid = c.sid
where c.cid = (select cid from courses where cname = 'C++')

except

select s.sid
from students as s
left join choices as c
on s.sid = c.sid
where c.cid = (select cid from courses where cname = 'database')

--7.查询课时与UML或C++的课时一样的课程名称。
select cname from COURSES as c
where c.hour in (select hour from COURSES where cname in ('UML', 'C++') and hour is not null)

--8.查询database课程的平均成绩和最高成绩。
select avg(ch.score) as avg_score, max(ch.score) as max_score
from courses as co
join choices as ch
on co.cid = ch.cid
where co.cname = 'database'

--9.查询选修了所有课程的学生姓名。
select st.sname as student_name
from students as st
left join choices as ch
on st.sid = ch.sid
join courses as co
on ch.cid = co.cid
group by st.sid,st.sname
having count(co.cid) = (select count(cid) from courses)

--10.查询没有选修database课程的学生姓名。
select distinct sname
from students

except

select distinct s.sname
from students as s
left join choices as ch
on s.sid = ch.sid
join courses as co
on ch.cid = co.cid
where co.cname = 'database'

--11.查询至少被两位学生选修的课程名称。
select distinct co.cname
from courses as co
join choices as ch
on ch.cid = co.cid
join students as st
on st.sid = ch.sid
group by co.cid,co.cname
having count(st.sid) >=2

--12.建立视图VIEW_SC，这个视图由学生姓名以及其选修的课程名称和相应分数构成。
create view view_sc as
    select distinct s.sname,co.cname,ch.score
    from students as s
    left join choices as ch
    on s.sid = ch.sid
    left join courses as co
    on co.cid = ch.cid

drop view view_sc;

select * from view_sc;

--13.利用视图VIEW_SC，查询分数大于90分数的学生姓名。
select sname from view_sc
where score>90 and score is not null

--14.是否能利用视图VIEW_SC插入数据？为什么？（问答题）
不能，因为：
1视图VIEW_SC是基于三个表(students, choices, courses)的left join连接创建的，数据库无法确定如何将插入的数据分配到这三个表中

--15.创建规则R1，确保插入的money值大于0，并将规则R1绑定到表CARD的money属性上。
create rule R1 as @value>0
go
exec sp_bindrule R1,'CARD.[MONEY]'

--16.在表CARD中插入一条违反规则R1的记录。
insert card values('1','800001216',1);

select sid from students
select * from card

insert card values('2','800002933',-100);

--17.解绑表CARD上规则R1的绑定。
exec sp_unbindrule 'CARD.[MONEY]'
go
insert card values('2','800002933',-100);
select * from card

--18.为表STUDENTS建立触发器T1，禁止删除学号为800015960的记录。
CREATE TRIGGER T1
ON STUDENTS
INSTEAD OF DELETE
AS
BEGIN
 IF EXISTS (SELECT * FROM deleted WHERE sid = '800015960')
 BEGIN
 RAISERROR('Cannot delete student with ID 800015960', 16, 1)
 ROLLBACK TRANSACTION
 END
END;

drop trigger T1;

--19.演示违反触发器T1的操作。
delete from students where sid = '800015960';

--20.编写一个嵌套事务。外层修改STUDENTS表某记录，内层在COURSES表插入一条记录。演示内层插入操作失败后，外层修改操作回滚。
update students set sname='MAC' where sid = '800015960';
begin transaction outer_tran
    begin try
        -- 外层事务：修改students表
        update students set sname='MIKE' where sid = '800015960'
        
        -- 创建保存点（savepoint）用于部分回滚，替代嵌套事务
        save transaction inner_savepoint
        
        begin try
            -- 尝试插入一条可能违反约束的记录（例如：使用已存在的cid）
            -- 假设'100'已经是一个存在的course ID，这会导致主键冲突
            insert into courses (cid, cname, hour) values('100','test',10);
        end try
        begin catch
            -- 内层插入失败，回滚到保存点
            rollback transaction inner_savepoint
            print '内层插入失败：' + ERROR_MESSAGE()
            -- 由于内层失败，将外层事务标记为失败
            raiserror('内层插入失败，回滚外层事务', 16, 1)
        end catch
        
        commit transaction outer_tran
    end try
    begin catch
        -- 外层事务回滚
        rollback transaction outer_tran
        print '外层事务回滚：' + ERROR_MESSAGE()
    end catch

go


-- 验证修改是否被回滚
select sname from students where sid = '800015960';

