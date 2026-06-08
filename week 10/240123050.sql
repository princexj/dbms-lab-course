-- task01;
create database week10;
use week10;

-- task02;
create table members(
member_id int,
member_name varchar(100),
member_type varchar(100),
primary key(member_id));
/*
mysql -uroot -p --local-infile week10
load data local infile 'members.csv' into table members fields terminated by ',' lines terminated by '\n';
*/

create table books(
book_id  int,
title varchar(200),
price decimal(10,2),
primary key(book_id));
/*
load data local infile 'books.csv' into table books fields terminated by',' lines terminated by '\n';
*/
create table issues(
issue_id int,
member_id int,
book_id int,
issue_date date,
due_date date,
return_date date,
damage int,
primary key(issue_id),
foreign key (member_id) references members(member_id),
foreign key (book_id) references books(book_id));
/*
load data local infile 'issues.csv' into table issues fields terminated by',' lines terminated by '\n';
*/

-- task03;
drop function if exists calculate_penalty;
DELIMITER $$
create function calculate_penalty(temp_id int,temp_date date)
returns decimal(10,2)
DETERMINISTIC
BEGIN
	declare total_penalty decimal(10,2) default 0.00;
    declare current_fine decimal(10,2) default 0.00;
    declare temp_member_type varchar(100) default 'student';
	declare temp_book_price DECIMAL(10,2);
    declare temp_return_date date default null;
    declare temp_due_date date;
    declare temp_book_lost int default 0;
	declare temp_overdue_days int default 0;
    declare temp_days_to_fine int default 0;
    declare done int default 0;
    
    DECLARE issue_cursor CURSOR FOR 
        SELECT i.due_date, i.return_date, b.price
        FROM issues i
        JOIN books b ON i.book_id = b.book_id
        WHERE i.member_id = temp_id;
	
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = 1;
        
	select member_type into temp_member_type from members where member_id=temp_id;
    
	open issue_cursor;
    read_loop: loop
    FETCH issue_cursor INTO temp_due_date, temp_return_date, temp_book_price;
            IF done THEN
            LEAVE read_loop;
			END IF;
		
	        IF ISNULL(temp_return_date) THEN
            SET temp_overdue_days = DATEDIFF(temp_date, temp_due_date);
            SET temp_book_lost = 1; 
        ELSE
            SET temp_overdue_days = DATEDIFF(temp_return_date, temp_due_date);
        END IF;

        IF temp_overdue_days > 0 THEN
            IF (temp_book_lost=1) THEN
                IF temp_overdue_days < 60 THEN
                    SET temp_days_to_fine = temp_overdue_days;
                ELSE
                    SET temp_days_to_fine = 60;
                END IF;
            ELSE
                SET temp_days_to_fine = temp_overdue_days;
            END IF;

            IF temp_member_type = 'student' THEN
                IF temp_days_to_fine <= 5 THEN
                    SET current_fine = temp_days_to_fine * 2;
                ELSE
                    SET current_fine = (5 * 2) + ((temp_days_to_fine - 5) * 5); 
                END IF;
            ELSEIF temp_member_type = 'staff' THEN
                IF temp_days_to_fine <= 7 THEN
                    SET current_fine = temp_days_to_fine * 2;
                ELSE
                    SET current_fine = (7 * 2) + ((temp_days_to_fine - 7) * 4); 
                END IF;
            ELSEIF temp_member_type = 'faculty' THEN
                IF temp_days_to_fine <= 10 THEN
                    SET current_fine = temp_days_to_fine * 1;
                ELSE
                    SET current_fine = (10 * 1) + ((temp_days_to_fine - 10) * 3); 
                END IF;
            END IF;

   
            IF (temp_book_lost=1) THEN
                SET current_fine = current_fine + temp_book_price + (0.20 * temp_book_price);
            END IF;
        END IF;

        -- Accumulate the total penalty for this member
        SET total_penalty = total_penalty + current_fine;

	end loop;
    CLOSE issue_cursor;
    RETURN total_penalty;
END$$
DELIMITER ;

update issues 
set return_date=null
where return_date= 0000-00-00;

SELECT member_name, calculate_penalty(member_id, '2026-05-31') AS penalty 
FROM members 
WHERE member_type = 'faculty';

SELECT member_name, calculate_penalty(member_id, '2026-05-31') AS penalty 
FROM members 
WHERE member_type = 'student';

SELECT member_name, calculate_penalty(member_id, '2026-05-31') AS penalty 
FROM members 
WHERE member_type = 'staff' ;
	

    
    
    
    

    
    