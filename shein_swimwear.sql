-- ==============================================================
-- BACKUP TABLE: Create a working copy of the source data
-- ==============================================================

SELECT * FROM us_shein_swimwear_clean;

CREATE TABLE shein_swimwear
LIKE us_shein_swimwear_clean;

INSERT INTO shein_swimwear
SELECT * FROM us_shein_swimwear_clean;

SELECT * FROM shein_swimwear;


-- ==============================================================
-- DATA TYPE CLEANUP: Convert text to INT by removing invalid entries
-- ==============================================================

-- Identify non-numeric values in integer-bound columns
SELECT * FROM shein_swimwear
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_swimwear
WHERE color_count REGEXP '^[^0-9]';

-- Clear non-numeric values
UPDATE shein_swimwear
SET rank_title = ''
WHERE rank_title REGEXP '^[^0-9]';

UPDATE shein_swimwear
SET color_count = ''
WHERE color_count REGEXP '^[^0-9]';

-- Replace empty strings with NULL for proper type conversion
UPDATE shein_swimwear
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_swimwear
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_swimwear
SET color_count = null
WHERE color_count = '';

-- Modify column data types
ALTER TABLE shein_swimwear
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
 
-- ==============================================================
-- CLEAN goods_title: Remove numbers, non-English chars, extra spaces
-- ==============================================================

-- Preview: Remove words containing digits
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_swimwear
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

-- Apply: Remove words with numbers
UPDATE shein_swimwear
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- Convert to lowercase
UPDATE shein_swimwear
SET goods_title = LOWER(goods_title);

-- Preview: Remove non-alphanumeric characters (except space)
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_swimwear
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Apply: Keep only letters, numbers, and single spaces
UPDATE shein_swimwear
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Preview: Collapse multiple spaces
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_swimwear
WHERE goods_title REGEXP ' {2,}';

-- Apply: Replace multiple spaces with single space
UPDATE shein_swimwear 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

-- Final check
SELECT * FROM shein_swimwear
ORDER BY length(goods_title);

-- ==============================================================
-- FEATURE ENGINEERING: Add categorical metadata
-- ==============================================================

-- Verify no men's swimwear exists
SELECT * FROM shein_swimwear
WHERE goods_title REGEXP 'men'
ORDER BY length(goods_title);
-- no men swimwears

-- Set gender and category assumptions (based on data inspection)
UPDATE shein_swimwear
SET specific_gender = 'women';

-- gender
UPDATE shein_swimwear
SET gender = 'female';

-- category
UPDATE shein_swimwear
SET category = 'swimwear';

-- rank_sub
UPDATE shein_swimwear
SET rank_sub = 'swimwear';

-- Final sorted output
SELECT * FROM shein_swimwear
ORDER BY length(goods_title);