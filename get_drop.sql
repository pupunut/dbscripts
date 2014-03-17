-- --------------------------------------------------------------------------------
-- Routine DDL
-- Note: comments before and after the routine body will not be stored by the server
-- --------------------------------------------------------------------------------
DELIMITER $$

CREATE DEFINER=`root`@`localhost` PROCEDURE `get_drop`()
BEGIN
  DECLARE output TEXT DEFAULT ' ';
  DECLARE done INT DEFAULT FALSE;
  DECLARE found, lp, lp_count INT DEFAULT 0;
  DECLARE last_sn INT DEFAULT -1;
  DECLARE last_open, last_close, last_high, last_low, last_cn, last_count, last_total INT;
  DECLARE curr_open, curr_close, curr_high, curr_low, curr_cn, curr_count, curr_total, curr_sn INT;
  DECLARE curr_date, last_date, next_date DATE;
  DECLARE cur CURSOR FOR SELECT * FROM period order by sn, date;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET done = TRUE;

  DROP TABLE period_dst;
  CREATE TABLE period_dst SELECT * from period where 0 = 1;
  OPEN cur;

  select count(*) into lp_count from period where sn=600000;
  set output = CONCAT('lp_count == ', lp_count);
  select output;

  read_loop: LOOP
    FETCH cur INTO curr_sn, curr_date, curr_open, curr_high, curr_low, curr_close, curr_count, curr_total;
    
	IF done THEN
      LEAVE read_loop;
    END IF;

    IF curr_sn = last_sn THEN
		set lp = lp + 1;

		IF curr_open > last_low AND curr_open < last_open AND curr_open > curr_close THEN
			set found = found + 1;
		END IF;
	ELSE
        # found a target
		IF found = lp_count THEN
			insert into period_dst select * from period where sn = last_sn and date = last_date;
		END IF;
        #new loop, initialize the variables
		IF curr_open > curr_close THEN
			SET found = 1; #drop at the first day
		ELSE
			SET found = 0;
		END IF;
		SET lp = 1;
    END IF;

    set last_sn = curr_sn;
    set last_date = curr_date;
    set last_open = curr_open;
    set last_high = curr_high;
    set last_low = curr_low;
    set last_close = curr_close;
  END LOOP;

  CLOSE cur;
END
