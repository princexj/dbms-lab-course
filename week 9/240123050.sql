-- task01
CREATE DATABASE IF NOT EXISTS week09;
USE week09;

-- task02
-- 1
CREATE TABLE sailors (
    sid INT PRIMARY KEY,
    sname VARCHAR(50) NOT NULL,
    rating INT NOT NULL,
    age DECIMAL(4,1) NOT NULL
);
/*
mysql -uroot -p --local-infile week09
load data local infile 'sailors.csv' into table sailors fields terminated by ',' lines terminated by '\n';
*/

-- 2
CREATE TABLE boats (
    bid INT PRIMARY KEY,
    bname VARCHAR(50) NOT NULL,
    color VARCHAR(20) NOT NULL
);
/*
load data local infile 'boats.csv' into table boats fields terminated by ',' lines terminated by '\n';
*/

-- 3
CREATE TABLE reserves (
    sid INT,
    bid INT,
    day DATE,
    PRIMARY KEY (sid, bid, day),
    FOREIGN KEY (sid) REFERENCES sailors(sid),
    FOREIGN KEY (bid) REFERENCES boats(bid)
);
/*
load data local infile 'reserves.csv' into table reserves fields terminated by ',' lines terminated by '\n';
*/

-- task03
CREATE VIEW view_sailor_rating AS 
SELECT sid, rating FROM sailors;
INSERT IGNORE INTO view_sailor_rating (sid, rating) VALUES (91, 7), (92, 8), (93, 9), (94, 10), (22, 8);
UPDATE view_sailor_rating SET rating = 8 WHERE sid = 91;
DELETE FROM view_sailor_rating WHERE sid = 9;
SELECT * FROM sailors;

CREATE VIEW view_green_boats AS 
SELECT bid, bname, color FROM boats WHERE color = 'green';
INSERT INTO view_green_boats VALUES (205, 'River Mania', 'green'), (206, 'green-bird', 'green'), (207, 'blue-warriors', 'blue');

CREATE VIEW view_green_boats_new AS 
SELECT bid, bname, color FROM boats WHERE color = 'green' WITH CHECK OPTION;
-- This insertion will fail
INSERT INTO view_green_boats_new VALUES (207, 'blue-warriors', 'blue');

CREATE VIEW view_sailor_boat_info AS
SELECT s.sid, s.rating, b.bid, b.bname
FROM sailors s
JOIN reserves r ON s.sid = r.sid
JOIN boats b ON r.bid = b.bid;
INSERT INTO view_sailor_boat_info (sid, rating) VALUES (80, 8);
INSERT INTO view_sailor_boat_info (bid, bname) VALUES (105, 'Lucky Lake');
UPDATE view_sailor_boat_info SET bname = 'Jumper' WHERE bid = 101;
UPDATE view_sailor_boat_info SET bname = 'Interlake' WHERE bid = 101;

-- task04
CREATE VIEW view_max_rating_sailors AS
SELECT s.sid, s.sname, s.rating, b.bid, b.bname
FROM sailors s
JOIN reserves r ON s.sid = r.sid
JOIN boats b ON b.bid = r.bid
WHERE s.rating = (
    SELECT MAX(s2.rating) 
    FROM sailors s2 
    JOIN reserves r2 ON s2.sid = r2.sid
);

INSERT INTO view_max_rating_sailors (sid, sname, rating) VALUES (80, 'best sailor', 10);
UPDATE view_max_rating_sailors SET rating = -9 WHERE sid = 74;
DELETE FROM view_max_rating_sailors WHERE sid = 74;
UPDATE view_max_rating_sailors SET bname = 'Can I get updated?' WHERE bid = 102;

CREATE VIEW view_distinct_ratings AS 
SELECT DISTINCT rating FROM sailors;

INSERT INTO view_distinct_ratings (rating) VALUES (2);
UPDATE view_distinct_ratings SET rating = -7 WHERE rating = 7;
DELETE FROM view_distinct_ratings WHERE rating = 7;

CREATE VIEW view_boats_two_sailors_same_rating AS
SELECT b.*, s1.sid AS s1_id,s1.sname AS s1_name,s1.age AS s1_age, s1.rating AS s1_rating, s2.sid AS s2_id,s2.sname AS s2_name,s2.age AS s2_age, s2.rating AS s2_rating,r1.day AS date_reserved_for_s1,r2.day AS date_reserved_for_s2
FROM boats b
JOIN reserves r1 ON b.bid = r1.bid
JOIN sailors s1 ON r1.sid = s1.sid
JOIN reserves r2 ON b.bid = r2.bid
JOIN sailors s2 ON r2.sid = s2.sid
WHERE s1.sid != s2.sid AND s1.rating = s2.rating;

INSERT INTO view_boats_two_sailors_same_rating (s1_id, s1_name, s1_rating, s1_age) VALUES (80, 'budding sailor', 10, 25);
UPDATE view_boats_two_sailors_same_rating SET s1_rating = 6 WHERE s1_rating = 8;
DELETE FROM view_boats_two_sailors_same_rating WHERE s1_rating = 7;

CREATE VIEW view_boats_same_rating_age_36 AS
SELECT b.*, s1.sid AS s1_id,s1.sname AS s1_name,s1.age AS s1_age, s1.rating AS s1_rating, s2.sid AS s2_id,s2.sname AS s2_name,s2.age AS s2_age, s2.rating AS s2_rating,r1.day AS date_reserved_for_s1,r2.day AS date_reserved_for_s2
FROM boats b
JOIN reserves r1 ON b.bid = r1.bid
JOIN sailors s1 ON r1.sid = s1.sid
JOIN reserves r2 ON b.bid = r2.bid
JOIN sailors s2 ON r2.sid = s2.sid
WHERE s1.sid != s2.sid AND s1.rating = s2.rating AND s1.age > 36 AND s2.age > 36;

INSERT INTO view_boats_same_rating_age_36 (s1_id, s1_name, s1_rating, s1_age) VALUES (80, 'budding sailor', 10, 25);
UPDATE view_boats_same_rating_age_36 SET s1_rating = 6 WHERE s1_rating = 8;
DELETE FROM view_boats_same_rating_age_36 WHERE s1_rating = 7;

CREATE VIEW view_union_green_blue AS
SELECT s.sid, s.sname, s.rating, b.bid, b.color
FROM sailors s
JOIN reserves r ON s.sid = r.sid
JOIN boats b ON r.bid = b.bid
WHERE b.color = 'green'
UNION
SELECT s.sid, s.sname, s.rating, b.bid, b.color
FROM sailors s
JOIN reserves r ON s.sid = r.sid
JOIN boats b ON r.bid = b.bid
WHERE b.color = 'blue';

INSERT INTO view_union_green_blue (sid, sname) VALUES (81, 'Sanjay');
-- This update will fail as intended because it's a UNION view
UPDATE view_union_green_blue SET rating = 9 WHERE sid = 22;
DELETE FROM view_union_green_blue WHERE sid = 22;

-- task05
CREATE VIEW view_task5_1 AS SELECT rating FROM view_sailor_rating;
INSERT INTO view_task5_1 (rating) VALUES (7), (8), (9), (10), (8);
UPDATE view_task5_1 SET rating = 9 WHERE rating = 8;
DELETE FROM view_task5_1 WHERE rating = 10;

CREATE VIEW view_task5_5 AS 
SELECT r.sid, v.bname, r.day 
FROM reserves r 
JOIN view_green_boats v ON r.bid = v.bid;

-- task06
ALTER TABLE sailors RENAME COLUMN rating TO rting;
SELECT * FROM view_sailor_rating;
SELECT * FROM view_sailor_boat_info;
SELECT * FROM view_max_rating_sailors;
SELECT * FROM view_distinct_ratings;
SELECT * FROM view_boats_two_sailors_same_rating;
SELECT * FROM view_boats_same_rating_age_36;
SELECT * FROM view_task5_1;

ALTER TABLE sailors RENAME COLUMN rting TO rating;
SELECT * FROM view_sailor_rating;
SELECT * FROM view_sailor_boat_info;
SELECT * FROM view_max_rating_sailors;
SELECT * FROM view_distinct_ratings;
SELECT * FROM view_boats_two_sailors_same_rating;
SELECT * FROM view_boats_same_rating_age_36;
SELECT * FROM view_task5_1;

ALTER TABLE sailors DROP COLUMN rating;
SELECT * FROM view_sailor_rating;
SELECT * FROM view_sailor_boat_info;
SELECT * FROM view_max_rating_sailors;
SELECT * FROM view_distinct_ratings;
SELECT * FROM view_boats_two_sailors_same_rating;
SELECT * FROM view_boats_same_rating_age_36;
SELECT * FROM view_task5_1; 

-- task 07
-- 1-2
CREATE TABLE sailors_1 AS SELECT * FROM sailors; 
CREATE TABLE boats_1 AS SELECT * FROM boats; 
CREATE TABLE reserves_1 AS SELECT * FROM reserves; 

-- 3
ALTER TABLE sailors_1 MODIFY sid SMALLINT; 
ALTER TABLE boats_1 MODIFY bid CHAR(3); 
ALTER TABLE boats_1 MODIFY color CHAR(5); 

-- 4
SHOW CREATE TABLE reserves; 
DESCRIBE boats;
DESCRIBE reserves;

-- 5-6
ALTER TABLE boats MODIFY bid CHAR(3); 
DESCRIBE boats;
SHOW CREATE TABLE reserves; 

-- 7
-- This insert is expected to fail or exhibit issues depending on strict mode and exact definitions due to type mismatch
INSERT IGNORE INTO reserves VALUES (22, '101', '2024-01-01');

-- 8-9
ALTER TABLE reserves MODIFY bid CHAR(3);
DESCRIBE reserves; 
INSERT IGNORE INTO reserves VALUES (22, '101', '2024-01-01');
