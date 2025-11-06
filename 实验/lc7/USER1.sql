USE School_Data;

select * from STUDENTS;

select * from TEACHERS;

select salary from TEACHERS;

select salary from TS;


--(5)
grant select on TS to USER2 with grant option;

--（8）
select * from COURSES;