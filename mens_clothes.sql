-- ==============================================================
-- BACKUP TABLE: Create a working copy of the source data
-- ==============================================================
SELECT * FROM us_shein_mens_clothes_clean;

CREATE TABLE shein_mens_clothes
LIKE us_shein_mens_clothes_clean;

INSERT INTO shein_mens_clothes
SELECT * FROM us_shein_mens_clothes_clean;

SELECT * FROM shein_mens_clothes;


-- ==============================================================
-- DATA TYPE CLEANUP: Convert text to INT by removing invalid entries
-- ==============================================================

-- Identify non-numeric values in integer-bound columns
SELECT * FROM shein_mens_clothes
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_mens_clothes
WHERE color_count REGEXP '^[^0-9]';

-- Clear non-numeric values
UPDATE shein_mens_clothes
SET rank_title = ''
WHERE rank_title REGEXP '^[^0-9]';

UPDATE shein_mens_clothes
SET color_count = ''
WHERE color_count REGEXP '^[^0-9]';

-- Replace empty strings with NULL for proper type conversion
UPDATE shein_mens_clothes
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_mens_clothes
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_mens_clothes
SET color_count = null
WHERE color_count = '';

-- Modify column data types
ALTER TABLE shein_mens_clothes
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
    
-- ==============================================================
-- CLEAN goods_title: Remove numbers, non-English chars, extra spaces
-- ==============================================================

-- Preview: Remove words containing digits
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_mens_clothes
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

-- Apply: Remove words with numbers
UPDATE shein_mens_clothes
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- Convert to lowercase
UPDATE shein_mens_clothes
SET goods_title = LOWER(goods_title);

-- Preview: Remove non-alphanumeric characters (except space)
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_mens_clothes
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Apply: Keep only letters, numbers, and single spaces
UPDATE shein_mens_clothes
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Preview: Collapse multiple spaces
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_mens_clothes
WHERE goods_title REGEXP ' {2,}';

-- Apply: Replace multiple spaces with single space
UPDATE shein_mens_clothes 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

-- Final check
SELECT * FROM shein_mens_clothes
ORDER BY length(goods_title);

-- ==============================================================
-- FEATURE ENGINEERING: Add categorical metadata
-- ==============================================================

-- Set gender assumptions (all men's clothing)
UPDATE shein_mens_clothes
SET specific_gender = 'men';

-- gender
UPDATE shein_mens_clothes
SET gender = 'male';

-- category
UPDATE shein_mens_clothes
SET category = 'mens_clothes';

-- ==============================================================
-- SUBCATEGORY CLASSIFICATION: Refine rank_sub based on title
-- ==============================================================
-- rank_sub
UPDATE shein_mens_clothes
SET rank_sub = 'clothing';

SELECT * FROM shein_mens_clothes
WHERE goods_title REGEXP 'Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded'
ORDER BY length(goods_title);

UPDATE shein_mens_clothes
SET rank_sub = 'outwear'
 WHERE goods_title REGEXP 'Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded';
 
SELECT * FROM shein_mens_clothes
WHERE goods_title REGEXP '(Swimsuit|Swimwear|Swim Trunks|swim)'
ORDER BY length(goods_title);

UPDATE shein_mens_clothes
SET rank_sub = 'swimwear'
WHERE goods_title REGEXP '(Swimsuit|Swimwear|Swim Trunks|swim)';

-- ==============================================================
-- FINAL OUTPUT: Sorted by title length for review
-- ==============================================================
SELECT * FROM shein_mens_clothes
ORDER BY length(goods_title);