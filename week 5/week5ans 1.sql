-- task 1
CREATE DATABASE week05;

-- task 2
USE week05;

-- task 3
CREATE TABLE table1 (id INT);
CREATE TABLE table2 (name CHAR(50));
CREATE TABLE table3 (description VARCHAR(200));
CREATE TABLE table4 (price float);
create table table5(balance decimal(12,2));
create table table6(born date);
create table table7(last_login datetime);
create table table8(roll int,marks int);
create table table9(code char(6),city char(30));
create table table10(emp_id  char(8),name varchar(100));
create table table11(sensor_id int,reading float);
create table table12(id int,name char(10),details varchar(150),height float,join_date date);

-- task 4
ALTER TABLE table1 ADD COLUMN code CHAR(10) AFTER id;
ALTER TABLE table2 ADD COLUMN notes VARCHAR(500) FIRST;
ALTER TABLE table3 ADD COLUMN weight FLOAT;
ALTER TABLE table4 ADD COLUMN recorded_at DATETIME;
ALTER TABLE table5 ADD COLUMN name CHAR(40), ADD COLUMN comment VARCHAR(300), ADD COLUMN value FLOAT, ADD COLUMN updated DATETIME;
ALTER TABLE table5 DROP COLUMN name;
ALTER TABLE table5 DROP COLUMN comment;
ALTER TABLE table5 MODIFY COLUMN updated DATE;
ALTER TABLE table5 RENAME COLUMN value TO amount;

-- task 5
RENAME TABLE table5 TO new_table5;
ALTER TABLE new_table5 RENAME COLUMN balance TO c1, RENAME COLUMN amount TO c2, RENAME COLUMN updated TO c3;
RENAME TABLE new_table5 TO table5;
ALTER TABLE table5 RENAME COLUMN c1 TO id_23,RENAME COLUMN c2 TO val_23,RENAME COLUMN c3 TO dt_23;

-- task 6
DROP TABLE table1, table2, table3, table4, table5, table6, table7, table8, table9, table10, table11, table12;
DROP DATABASE week05;


