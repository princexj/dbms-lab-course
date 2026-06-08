
-- task 01
create database week08;
use week08;

-- task 02 a)
create table course(
course_id varchar(10),
course_title varchar(100) not null,
primary key(course_id));

/*
mysql -uroot -p --local-infile week08

load data local infile 'courses.csv' into table course fields terminated by ',' lines terminated by '\n';
*/


-- task 02 b)
CREATE TABLE student (
    course_id VARCHAR(10),
    roll_number VARCHAR(20),
    student_name VARCHAR(100) NOT NULL,
    approval_status VARCHAR(20) NOT NULL,
    credit_status VARCHAR(20) NOT NULL,
    PRIMARY KEY (roll_number, course_id),
    FOREIGN KEY (course_id) REFERENCES course(course_id)
);

/*
load data local infile 'students-credits.csv' into table student fields terminated by ',' lines terminated by '\n';
*/

-- task 02 c)
create table credit(
course_id varchar(10),
l int not null,
t int not null,
p int not null,
c int not null,
primary key(course_id),
foreign key (course_id) references course(course_id));

/*
load data local infile 'credits.csv' into table credit fields terminated by ',' lines terminated by '\n';
*/

-- task 02 d)
create table faculty_courses(
course_id varchar(10),
faculty_name varchar(100),
primary key(course_id,faculty_name),
foreign key (course_id) references course(course_id));

/*
load data local infile 'faculty-course.csv' into table faculty_courses fields terminated by ',' lines terminated by '\n';
*/

-- task 02 e)

create table semester(
dept_name varchar(100),
sem_num varchar(10),
course_id varchar(10),
primary key(dept_name,sem_num,course_id),
foreign key (course_id) references course(course_id)
);

/*
load data local infile 'semester.csv' into table semester fields terminated by ',' lines terminated by '\n';
*/

-- task 04 
-- a)
select course_id,count(roll_number) as num_of_student
from student
where credit_status='Audit' and course_id like '______M%'
group by course_id;



-- b)
SELECT LEFT(course.course_id, 2) AS department_name, SUM(credit.c) AS total_credits
FROM course JOIN credit ON course.course_id = credit.course_id
GROUP BY LEFT(course.course_id, 2);

-- task 05
-- a)
select temp.course_id,temp.num_of_students
from (select course_id,count(roll_number) as num_of_students
from student
where credit_status='Audit'
group by course_id
) as temp
where num_of_students >= 4;
-- b)
SELECT c.course_id, c.course_title
FROM course c
JOIN faculty_courses fc ON c.course_id = fc.course_id
GROUP BY c.course_id, c.course_title
HAVING COUNT(fc.faculty_name) > 1;
-- c)
SELECT faculty_name, COUNT(course_id) AS num_courses
FROM faculty_courses
GROUP BY faculty_name
HAVING COUNT(course_id) > 1;


-- task 06
-- a)

select course.course_id,course.course_title
from course join credit on course.course_id=credit.course_id
where credit.c = (select min(c) from credit);

-- b)
with temp as (select *
from credit 
where course_id like 'CS%')

select temp.course_id,faculty_courses.faculty_name
from temp join faculty_courses on temp.course_id=faculty_courses.course_id
where temp.c=(select min(c) from temp);


-- task 08
-- a)
SELECT sem_num
FROM semester s
JOIN credit c1  ON s.course_id = c1.course_id
WHERE s.dept_name = 'BSBE'
GROUP BY s.sem_num
HAVING SUM(c1.c) < ANY (
    SELECT SUM(c2.c)
    FROM semester s2
    JOIN credit c2 ON s2.course_id = c2.course_id
    WHERE s2.dept_name = 'DD'
    GROUP BY s2.sem_num
);

-- b)
SELECT sem_num
FROM semester s
JOIN credit c1 ON s.course_id = c1.course_id
WHERE s.dept_name = 'BSBE'
GROUP BY s.sem_num
HAVING SUM(c1.c) >= ALL (
    SELECT SUM(c2.c)
    FROM semester s2
    JOIN credit c2 ON s2.course_id = c2.course_id
    WHERE s2.dept_name = 'DD'
    GROUP BY s2.sem_num
);









