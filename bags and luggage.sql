	-- backup table --
SELECT * FROM us_shein_bags_and_luggage_clean;

CREATE TABLE shein_bags_and_luggage
LIKE us_shein_bags_and_luggage_clean;

INSERT INTO shein_bags_and_luggage
SELECT * FROM us_shein_bags_and_luggage_clean;

SELECT * FROM shein_bags_and_luggage;

	-- Changing the data type --
 -- find text in int column
SELECT * FROM shein_bags_and_luggage
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_bags_and_luggage
WHERE color_count REGEXP '^[^0-9]';

UPDATE shein_bags_and_luggage
SET rank_title = ''
WHERE rank_title REGEXP '^[^0-9]';

UPDATE shein_bags_and_luggage
SET color_count = ''
WHERE color_count REGEXP '^[^0-9]';   

-- replacing empty space with null in order to change datatype

UPDATE shein_bags_and_luggage
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_bags_and_luggage
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_bags_and_luggage
SET color_count = null
WHERE color_count = '';

ALTER TABLE shein_bags_and_luggage
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
    
SELECT goods_title FROM shein_bags_and_luggage;

-- standardize goods_title
-- removing unnecessary words

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*^[0-9]+\\S*\\b','')) AS goods_title FROM shein_bags_and_luggage
WHERE goods_title NOT REGEXP '^(2020|2023|2024)';

UPDATE shein_bags_and_luggage
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*^[0-9]+\\S*\\b',''))
WHERE goods_title NOT REGEXP '^(2020|2023|2024)';

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+ ?(pcs|pc|sets|set)\\S*\\b','')) AS goods_title FROM shein_bags_and_luggage
WHERE goods_title REGEXP '[0-9]+ ?(pcs|pc|sets|set)';

UPDATE shein_bags_and_luggage
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+ ?(pcs|pc|sets|set)\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+ ?(pcs|pc|sets|set)';

SELECT goods_title FROM shein_bags_and_luggage;

UPDATE shein_bags_and_luggage
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+ ?in ?[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+ ?in ?[0-9]+';

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*(ml|kg|oz|cm)\\S*\\b','')) AS goods_title FROM shein_bags_and_luggage
WHERE goods_title REGEXP '(ml|kg|oz|cm)';

UPDATE shein_bags_and_luggage
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*(ml|kg|oz|cm)\\S*\\b',''))
WHERE goods_title REGEXP '(ml|kg|oz|cm)';

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'35l Gym Bag','Gym Bag')) AS goods_title FROM shein_bags_and_luggage
WHERE goods_title REGEXP '35l Gym Bag';

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*(pcs|pc)\\S*\\b','Gym Bag')) AS goods_title FROM shein_bags_and_luggage
WHERE goods_title REGEXP '(pcs|pc)';

UPDATE shein_bags_and_luggage
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*(pcs|pc)\\S*\\b','Gym Bag'))
WHERE goods_title REGEXP '(pcs|pc)';

-- lowercase

UPDATE shein_bags_and_luggage
SET goods_title = LOWER(goods_title);

-- remove double spacing

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_bags_and_luggage
WHERE goods_title REGEXP ' {2,}';

UPDATE shein_bags_and_luggage 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

-- remove non english or number letters

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_bags_and_luggage
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

UPDATE shein_bags_and_luggage
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

SELECT * FROM shein_bags_and_luggage
ORDER BY length(goods_title);

		-- FEATURE ENGINEERING --
 -- creating category column       
ALTER TABLE shein_bags_and_luggage
ADD category varchar(45);
        
SELECT category FROM shein_bags_and_luggage;
UPDATE shein_bags_and_luggage
SET category = 'bags & luggage';

-- rank_sub
UPDATE shein_bags_and_luggage
SET rank_sub = 'accessory';

-- specific_gender 
ALTER TABLE shein_bags_and_luggage
ADD specific_gender varchar(45);

SELECT goods_title,
	CASE
		-- unisex first so it will take first the two genders
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?|^men(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?|^women(s)?|girl|lady|ladies' THEN 'unisex'
        
        -- men keywords and because 'men' is part of the word 'women' so men should be filterd first
		WHEN goods_title REGEXP '\\S+ men(s)?|^men(s)?|\\S+ man(s)?|^man(s)?|\\S+ boy(s)?' THEN 'men'
        
        -- women keywords
        WHEN goods_title REGEXP '\\S+ women(s)?|^women(s)?|\\S+ woman(s)?|^woman(s)?|lady|ladies|girl(s)?|cosmetic|lipstick|makeup|purse|pink' 
        THEN 'women'
        
        -- based on AI the rest of the list is unisex
        ELSE 'unisex'
	END AS test
FROM shein_bags_and_luggage
ORDER BY length(goods_title);

UPDATE shein_bags_and_luggage
SET specific_gender =
	CASE
		-- unisex first so it will take first the two genders
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?|^men(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?|^women(s)?|girl|lady|ladies' THEN 'unisex'
        
        -- men keywords and because 'men' is part of the word 'women' so men should be filterd first
		WHEN goods_title REGEXP '\\S+ men(s)?|^men(s)?|\\S+ man(s)?|^man(s)?|\\S+ boy(s)?' THEN 'men'
        
        -- women keywords
        WHEN goods_title REGEXP '\\S+ women(s)?|^women(s)?|\\S+ woman(s)?|^woman(s)?|lady|ladies|girl(s)?|cosmetic|lipstick|makeup|purse|pink' 
        THEN 'women'
        
        -- based on AI the rest of the list is unisex
        ELSE 'unisex'
	END;
    
-- gender
ALTER TABLE shein_bags_and_luggage
ADD gender VARCHAR(45);

UPDATE shein_bags_and_luggage
SET gender =
	CASE
		WHEN specific_gender = 'men' THEN 'male'
        WHEN specific_gender = 'women' THEN 'female'
        WHEN specific_gender = 'unisex' THEN 'unisex'
        END;

SELECT * FROM shein_bags_and_luggage
ORDER BY length(goods_title);