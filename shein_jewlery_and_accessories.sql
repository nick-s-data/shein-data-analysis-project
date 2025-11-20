-- 1.0. BACKUP TABLE
SELECT * FROM us_shein_jewlery_and_accessories_clean;

CREATE TABLE shein_jewlery_and_accessories
LIKE us_shein_jewlery_and_accessories_clean;

-- Add helper column for duplicate identification
ALTER TABLE shein_jewlery_and_accessories
ADD row_num INT;

-- Insert data and assign row numbers to identify duplicates
INSERT INTO shein_jewlery_and_accessories (
    selling_proposition,price, discount, goods_title,rank_title, rank_sub, color_count,row_num
)
SELECT
    *, 
    row_number() OVER(PARTITION BY selling_proposition,price, discount, goods_title,rank_title, rank_sub, color_count) AS row_num
FROM
    us_shein_jewlery_and_accessories_clean;

SELECT * FROM shein_jewlery_and_accessories;


-- 1.1. DATA TYPE PREPARATION: Check for invalid characters (optional SELECTs)
-- find text in int column
SELECT * FROM shein_jewlery_and_accessories
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_jewlery_and_accessories
WHERE color_count REGEXP '^[^0-9]';

-- 1.2. DATA TYPE PREPARATION: Replace empty strings with NULL
UPDATE shein_jewlery_and_accessories
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_jewlery_and_accessories
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_jewlery_and_accessories
SET color_count = null
WHERE color_count = '';

-- 1.3. DATA TYPE CONVERSION: Modify Column Types
ALTER TABLE shein_jewlery_and_accessories
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;


-- 1.4. Remove Duplicate Records
SELECT row_num FROM shein_jewlery_and_accessories
WHERE row_num >1;

DELETE FROM shein_jewlery_and_accessories
WHERE row_num >1;

-- 2.1. CLEANING: Remove numbers and words containing numbers
-- removing unnecessary text
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_jewlery_and_accessories
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

UPDATE shein_jewlery_and_accessories
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- 2.2. CLEANING: Normalize text
-- Convert to lowercase
UPDATE shein_jewlery_and_accessories
SET goods_title = LOWER(goods_title);

-- Remove non-alphanumeric characters (keep spaces)

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM table
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

UPDATE shein_jewlery_and_accessories
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- remove double spacing
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_jewlery_and_accessories
WHERE goods_title REGEXP ' {2,}';

UPDATE shein_jewlery_and_accessories 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';



SELECT * FROM shein_jewlery_and_accessories
ORDER BY length(goods_title);

-- 3.1. FEATURE ENGINEERING: Rank Subcategory (Simple assignment for this table)
-- rank_sub
UPDATE shein_jewlery_and_accessories
SET rank_sub = 'accessory';

-- 3.2. FEATURE ENGINEERING: Specific Gender
-- specific_gender
ALTER TABLE shein_jewlery_and_accessories
ADD specific_gender varchar(45);

SELECT goods_title ,
	CASE
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?|^men(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?|^women(s)?|girl|lady|ladies' THEN 'unisex'
        WHEN goods_title REGEXP 'unisex|cartoon monkey keychain' THEN 'unisex'
        WHEN  goods_title REGEXP '\\S+ men|^men|Baseball|Ties|Fedora'  AND goods_title NOT REGEXP '^unisex|\\S+ unisex|\\S+ women(s)?|^women(s)?|\\S+ woman(s)?' THEN 'men'
        
-- most of the accessories are for women even the once that unisex still leaning towards the feminine side so ive decided to put it in the women gender
        ELSE 'women'
	END AS 'test'
FROM shein_jewlery_and_accessories;

UPDATE shein_jewlery_and_accessories
SET specific_gender = 
	CASE
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?|^men(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?|^women(s)?|girl|lady|ladies' THEN 'unisex'
        WHEN goods_title REGEXP 'unisex|cartoon monkey keychain' THEN 'unisex'
        WHEN  goods_title REGEXP '\\S+ men|^men|Baseball|Ties|Fedora'  AND goods_title NOT REGEXP '^unisex|\\S+ unisex|\\S+ women(s)?|^women(s)?|\\S+ woman(s)?' THEN 'men'
        
-- most of the accessories are for women even the once that unisex still leaning towards the feminine side so ive decided to put it in the women gender
        ELSE 'women'
	END;

SELECT * FROM shein_jewlery_and_accessories
WHERE specific_gender = 'unisex' AND goods_title REGEXP 'butterfly'
ORDER BY length(goods_title);

-- 3.3. FEATURE ENGINEERING:Gender
-- gender
ALTER TABLE shein_jewlery_and_accessories
ADD gender varchar(45);

UPDATE shein_jewlery_and_accessories
SET gender = 
	CASE
		WHEN specific_gender = 'women' THEN 'female'
        WHEN specific_gender = 'men' THEN 'male'
        WHEN specific_gender = 'unisex' THEN 'unisex'
	END;

-- 3.4. FEATURE ENGINEERING: Category (Simple assignment)
-- category
ALTER TABLE shein_jewlery_and_accessories
ADD category varchar(45);

UPDATE shein_jewlery_and_accessories
SET category = 'jewlery & accessories';

-- 3.5. FINAL CLEANUP
-- removing unnecessary column
ALTER TABLE shein_jewlery_and_accessories
DROP COLUMN row_num;

SELECT * FROM shein_jewlery_and_accessories
ORDER BY length(goods_title);