-- ========================================
-- 图片1: 创建学生表并插入数据
-- 说明: 创建Stu_Union表，包含学号、姓名、性别、年龄、系别字段，学号为主键
-- ========================================
USE School_Data
CREATE TABLE Stu_Union (sno CHAR(5) NOT NULL UNIQUE,
                        sname CHAR(8),
                        ssex CHAR(1),
                        sage INT,
                        sdept CHAR(20),
                        CONSTRAINT PK_Stu_Union PRIMARY KEY(sno));
insert into Stu_Union values ('10001','王勇','0',24,'EE');
insert into Stu_Union values ('95002','王敏','1',23,'CS');
insert into Stu_Union values ('95003','王洁','0',25,'EE');
insert into Stu_Union values ('95005','王杰','0',25,'EE');
insert into Stu_Union values ('95009','李勇','0',25,'EE');
select * from stu_union;

-- ========================================
-- 图片2: 创建课程表并插入数据
-- 说明: 创建Course表，包含课程号、课程名、学分字段，课程号为主键
-- ========================================
USE School_Data
create table Course (
  cno char(4) NOT NULL UNIQUE,
  cname varchar(50) NOT NULL,
  cpoints int,
  constraint PK primary key (cno));
insert Course values ('0001','ComputerNetworks',2);
insert Course values ('0002','Database',3);
select * from Course

-- ========================================
-- 图片3: 创建选课表并插入数据
-- 说明: 创建SC表，包含学号、课程号、成绩字段，设置外键关联Stu_Union和Course表，并设置级联删除
-- ========================================
USE School_Data
CREATE TABLE SC(
sno CHAR(5) REFERENCES Stu_Union (sno) on delete cascade,
cno CHAR(4) REFERENCES Course(cno) on delete cascade,
grade INT,
CONSTRAINT PK_SC PRIMARY KEY (sno,cno)
);
insert into sc values ('95002','0001',2);
insert into sc values ('95002','0002',2);
insert into sc values ('10001','0001',2);
insert into sc values ('10001','0002',2);
Select * From SC;

-- ========================================
-- 图片4: 测试外键约束-插入不存在的学号
-- 说明: 尝试插入学号'99'的选课记录，由于该学号在Stu_Union表中不存在，违反外键约束，插入失败
-- ========================================
USE School_Data
insert into sc values ('99','0001',2);

-- ========================================
-- 图片5: 测试级联删除
-- 说明: 删除学号为'10001'的学生，由于SC表设置了级联删除，该学生的选课记录也会被自动删除
-- ========================================
USE School_Data
delete from Stu_Union where sno='10001';
select * from SC;

-- ========================================
-- 图片6: 创建学生卡表并插入数据
-- 说明: 创建Stu_Card表，包含卡号、学生ID、余额字段，设置外键关联students表并级联删除
-- ========================================
USE School_Data
create table Stu_Card(
        card_id char(14),
        stu_id char(10) references students(sid) on delete cascade,
        remained_money decimal(10,2),
        constraint PK_stu_card Primary key (card_id)
)
insert into Stu_Card values ('05212567','800001216',100.25);
insert into Stu_Card values ('05212222','800005753',200.50);
select * from Stu_Card;

-- ========================================
-- 图片7: 创建银行卡表并插入数据
-- 说明: 创建ICBC_Card表，包含银行卡号、学生卡号、存款金额字段，设置外键关联stu_card表并级联删除
-- ========================================
USE School_Data
create table ICBC_Card(
        bank_id char(20),
        stu_card_id char (14) references stu_card(card_id) on delete cascade,
        restored_money decimal (10,2),
        constraint PK_Icbc_card Primary key (bank_id)
)
insert into ICBC_Card values ('9558844022312','05212567',15000.1);
insert into ICBC_Card values ('9558844023645','05212222',50000.3);
select * from ICBC_Card;

-- ========================================
-- 图片8: 测试外键约束-删除被引用的记录
-- 说明: 尝试删除students表中sid为'800001216'的记录，由于choices表中存在引用且未设置级联删除，删除失败
-- ========================================
delete from students where sid='800001216';

-- ========================================
-- 图片9: 修改外键约束为级联删除并测试
-- 说明: 先删除choices表的外键约束，然后重新添加带级联删除的外键约束，再次删除students记录成功
-- ========================================
USE School_Data
alter table choices drop [FK_CHOICES_STUDENTS];
alter table choices add
CONSTRAINT [FK_CHOICES_STUDENTS] FOREIGN KEY
    (
        [sid]
    ) REFERENCES [dbo].[STUDENTS] (
        [sid]
    )on delete cascade;
delete from students where sid='800001216';
select * from stu_card;
select * from icbc_card;

-- ========================================
-- 图片10: 修改外键约束为no action
-- 说明: 删除ICBC_Card表的外键约束，重新添加外键约束但设置为no action（不允许删除被引用的记录）
-- ========================================
Alter table ICBC_Card
    drop constraint FK_ICBC_Card__stu_c__5E8F139D;
Alter table ICBC_Card
    add constraint FK_ICBC_Card foreign key (stu_card_id)
        references Stu_card(card_id) on delete no action ;

-- ========================================
-- 图片11: 测试事务中的外键约束
-- 说明: 在事务中尝试删除students表中sid为'800005753'的记录，由于ICBC_Card表外键设置为no action，删除失败
-- ========================================
Begin Transaction del
delete from students where sid='800005753';
select * from stu_card;
select * from icbc_card;
Commit Transaction del

-- ========================================
-- 图片12: 查询表数据
-- 说明: 查询stu_card和icbc_card表的数据，验证之前的删除操作未成功
-- ========================================
USE School_Data
select * from stu_card;
select * from icbc_card;

-- ========================================
-- 图片13: 测试循环外键依赖-错误示例
-- 说明: 尝试创建两个表，它们互相引用对方作为外键，这会导致循环依赖错误，创建失败
-- ========================================
USE School_Data
create table listen_course (
    teacher_id char(6),tname varchar(20),course_id char(4)
    constraint PK_listen_course primary key(teacher_id)
    constraint FK_listen_course foreign key(course_id)
        references teach_course(course_id)
)
create table teach_course(
    course_id char(4),cname varchar(30),teacher_id char(6)
    constraint PK_teach_course primary key(course_id)
    constraint FK_teach_course foreign key(teacher_id)
        references listen_course(teacher_id)
)

-- ========================================
-- 图片14: 解决循环外键依赖-正确示例
-- 说明: 先创建listen_course表（不包含外键），再创建teach_course表（包含外键），最后用ALTER TABLE为listen_course添加外键
-- ========================================
USE School_Data
create table listen_course (
    teacher_id char(6),tname varchar(20),course_id char(4)
    constraint PK_listen_course primary key(teacher_id)
)
USE School_Data
create table teach_course(
    course_id char(4),cname varchar(30),teacher_id char(6)
    constraint PK_teach_course primary key(course_id)
    constraint FK_teach_course foreign key(teacher_id)
        references listen_course(teacher_id)
)
alter table listen_course
    add constraint FK_listen_course foreign key(course_id)
        references teach_course(course_id);
