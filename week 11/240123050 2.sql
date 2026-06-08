CREATE DATABASE week11;
USE week11;

CREATE TABLE sailors(
    sid INT PRIMARY KEY,
    sname CHAR(50),
    rating INT,
    age DECIMAL(3,1)
);

CREATE TABLE boats(
    bid INT PRIMARY KEY,
    bname CHAR(50),
    bcolor CHAR(50)
);

CREATE TABLE reserves(
    sid INT,
    bid INT,
    day DATE,
    PRIMARY KEY (sid, bid, day),
    FOREIGN KEY (sid) REFERENCES sailors(sid) ON UPDATE CASCADE ON DELETE CASCADE,
    FOREIGN KEY (bid) REFERENCES boats(bid) ON UPDATE CASCADE ON DELETE CASCADE
);

CREATE TABLE sailors_log(
    sid INT,
    event_ba CHAR(50),
    op_code CHAR(50),
    date_time DATETIME
);

CREATE TABLE boats_log(
    bid INT,
    event_ba CHAR(50),
    op_code CHAR(50),
    date_time DATETIME
);

CREATE TABLE reserves_log(
    sid INT,
    bid INT,
    day DATE,
    event_ba CHAR(50),
    op_code CHAR(50),
    date_time DATETIME
);

LOAD DATA LOCAL INFILE 'sailors01.csv' INTO TABLE sailors FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE 'boats01.csv' INTO TABLE boats FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE 'reserves01.csv' INTO TABLE reserves FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

DELIMITER $$

CREATE TRIGGER sailors_01 BEFORE INSERT ON sailors
FOR EACH ROW 
BEGIN
    INSERT INTO sailors_log VALUES (NEW.sid, 'before', 'insert', NOW());
END$$

CREATE TRIGGER boats_01 BEFORE INSERT ON boats
FOR EACH ROW 
BEGIN
    INSERT INTO boats_log VALUES (NEW.bid, 'before', 'insert', NOW());
END$$

CREATE TRIGGER reserves_01 BEFORE INSERT ON reserves
FOR EACH ROW 
BEGIN
    INSERT INTO reserves_log VALUES (NEW.sid, NEW.bid, NEW.day, 'before', 'insert', NOW());
END$$

CREATE TRIGGER sailors_02 AFTER UPDATE ON sailors
FOR EACH ROW 
BEGIN 
    INSERT INTO sailors_log VALUES (NEW.sid, 'after', 'update', NOW());
END$$

CREATE TRIGGER boats_02 AFTER UPDATE ON boats
FOR EACH ROW 
BEGIN 
    INSERT INTO boats_log VALUES (NEW.bid, 'after', 'update', NOW());
END$$

CREATE TRIGGER reserves_02 AFTER UPDATE ON reserves
FOR EACH ROW 
BEGIN 
    INSERT INTO reserves_log VALUES (NEW.sid, NEW.bid, NEW.day, 'after', 'update', NOW());
END$$

CREATE TRIGGER sailors_03 AFTER DELETE ON sailors
FOR EACH ROW 
BEGIN 
    INSERT INTO sailors_log VALUES (OLD.sid, 'after', 'deleted', NOW());
END$$

CREATE TRIGGER boats_03 AFTER DELETE ON boats
FOR EACH ROW 
BEGIN 
    INSERT INTO boats_log VALUES (OLD.bid, 'after', 'deleted', NOW());
END$$

CREATE TRIGGER reserves_03 AFTER DELETE ON reserves
FOR EACH ROW 
BEGIN 
    INSERT INTO reserves_log VALUES (OLD.sid, OLD.bid, OLD.day, 'after', 'deleted', NOW());
END$$

DELIMITER ;

LOAD DATA LOCAL INFILE 'insert-sailors02.csv' INTO TABLE sailors FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
LOAD DATA LOCAL INFILE 'insert-boats02.csv' INTO TABLE boats FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';

DELIMITER $$

CREATE PROCEDURE GenReservesData()
BEGIN
    DECLARE limit_pairs INT DEFAULT 0;
    DECLARE limit_res INT DEFAULT 0;
    DECLARE s_id_rand INT;
    DECLARE b_id_rand INT;
    DECLARE d_rand DATE;
    
    WHILE limit_pairs < 50 DO
        SELECT sid INTO s_id_rand FROM sailors ORDER BY RAND() LIMIT 1;
        SELECT bid INTO b_id_rand FROM boats ORDER BY RAND() LIMIT 1;
        SET limit_res = 0;
        
        WHILE limit_res < 2 DO
            SET d_rand = DATE_ADD('2026-01-01', INTERVAL FLOOR(RAND() * 365) DAY);
            INSERT IGNORE INTO reserves (sid, bid, day) VALUES (s_id_rand, b_id_rand, d_rand);
            
            IF ROW_COUNT() > 0 THEN
                SET limit_res = limit_res + 1;
            END IF;
        END WHILE;
        
        SET limit_pairs = limit_pairs + 1;
    END WHILE;
END $$

DELIMITER ;

CALL GenReservesData();

SELECT * FROM sailors_log;
SELECT * FROM boats_log;
SELECT * FROM reserves_log;

CREATE TABLE tmp_sailor_upd (sid INT, val_rating INT);
LOAD DATA LOCAL INFILE 'update-sailors02.csv' INTO TABLE tmp_sailor_upd FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
UPDATE sailors s INNER JOIN tmp_sailor_upd t ON s.sid = t.sid SET s.rating = t.val_rating;

CREATE TABLE tmp_boat_upd (bid INT, val_bcolor INT);
LOAD DATA LOCAL INFILE 'update-boats02.csv' INTO TABLE tmp_boat_upd FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
UPDATE boats b INNER JOIN tmp_boat_upd t ON b.bid = t.bid SET b.bcolor = t.val_bcolor;

UPDATE reserves SET day = DATE_ADD(day, INTERVAL 1 DAY) ORDER BY sid, bid, day LIMIT 100;

SELECT * FROM sailors_log;
SELECT * FROM boats_log;
SELECT * FROM reserves_log;

CREATE TABLE tmp_sailor_del (sid INT);
LOAD DATA LOCAL INFILE 'delete-sailors02.csv' INTO TABLE tmp_sailor_del FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
DELETE FROM sailors WHERE sid IN (SELECT sid FROM tmp_sailor_del);

CREATE TABLE tmp_boat_del (bid INT);
LOAD DATA LOCAL INFILE 'delete-boats02.csv' INTO TABLE tmp_boat_del FIELDS TERMINATED BY ',' LINES TERMINATED BY '\n';
DELETE FROM boats WHERE bid IN (SELECT bid FROM tmp_boat_del);

DELETE FROM reserves ORDER BY sid, bid, day LIMIT 100;

SELECT * FROM sailors_log;
SELECT * FROM boats_log;
SELECT * FROM reserves_log;
