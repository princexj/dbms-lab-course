
-- task 01
create database week07;
use week07;

-- task02
create table student(
cid char(7),
roll_number char(10),
name char(100) not null,
approval_status char(20) not null,
credit_status char(10) not null,
primary key(cid,roll_number)
);

create table course(
cid char(7) primary key,
name char(100) not null);

create table credit(
cid char(7) primary key,
l int not null,
t int not null,
p int not null,
c int not null); 

-- task03

/*
mysql> load data local infile 'students-credits.csv' into table student fields terminated by ',' lines terminated by '\n';
Query OK, 18871 rows affected (0.16 sec)
Records: 18871  Deleted: 0  Skipped: 0  Warnings: 0

mysql> load data local infile 'courses.csv' into table course fields terminated by ',' lines terminated by '\n';
Query OK, 348 rows affected (0.01 sec)
Records: 348  Deleted: 0  Skipped: 0  Warnings: 0

mysql> load data local infile 'credits.csv' into table credit fields terminated by ',' lines terminated by '\n';
Query OK, 348 rows affected (0.01 sec)
Records: 348  Deleted: 0  Skipped: 0  Warnings: 0

*/

-- task04
select * from student where name='Adarsh Kumar udai';
select cid , name , credit_status from student where credit_status='Credit' and cid='EE 390';
SELECT cid, roll_number, credit_status, approval_status FROM student WHERE approval_status = 'Pending' AND credit_status = 'Credit';
SELECT cid, l, t, p, c FROM credit WHERE c != 6;
SELECT roll_number, name, cid, credit_status, approval_status FROM student WHERE credit_status = 'Audit' AND approval_status = 'Approved';

-- task05
SELECT course.name, credit.l, credit.t, credit.p, credit.c 
FROM course,credit
WHERE course.cid=credit.cid and credit.c = 8;

SELECT course.name, credit.l, credit.t, credit.p, credit.c 
FROM course,credit
WHERE course.cid=credit.cid and credit.t > 0;

SELECT course.cid,course.name, credit.l, credit.t, credit.p, credit.c 
FROM course,credit
WHERE course.cid=credit.cid and credit.c=6 and not (l=3 and t=0 and p=0);

SELECT course.cid,course.name,student.name, credit.l, credit.t, credit.p, credit.c 
FROM course,credit,student
WHERE course.cid=credit.cid and course.cid=student.cid and student.name='Pasch Paul Ole';

SELECT student.roll_number,student.name,course.cid,course.name, credit.l, credit.t, credit.p, credit.c 
FROM course,credit,student
WHERE course.cid=credit.cid and course.cid=student.cid and student.credit_status='Credit' and (l=3 and t=1 and p=0 and c=8) and student.cid like 'EE%';

-- task06
SELECT cid,name
FROM student
WHERE upper(name) like '%ATUL%';

SELECT student.roll_number, student.credit_status, course.name 
FROM student 
JOIN course ON student.cid = course.cid 
WHERE LOWER(course.name) LIKE 'introduction to%';

SELECT cid 
FROM course 
WHERE cid LIKE '___3%';

SELECT cid, name 
FROM course 
WHERE cid LIKE '____2%M';

SELECT student.name, student.cid, course.name 
FROM student 
JOIN course ON student.cid = course.cid 
WHERE student.credit_status = 'Credit' 
  AND UPPER(student.name) LIKE 'A%TA';
 

