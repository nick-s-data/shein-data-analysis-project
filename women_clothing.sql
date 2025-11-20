-- ==============================================================
-- BACKUP TABLE: Create a working copy of the source data
-- ==============================================================
SELECT * FROM `us-shein-womens_clothing_clean`;

CREATE TABLE shein_womens_clothing
LIKE `us-shein-womens_clothing_clean`;

INSERT INTO shein_womens_clothing
SELECT * FROM `us-shein-womens_clothing_clean`;

SELECT * FROM shein_womens_clothing;

-- ==============================================================
-- DATA TYPE CLEANUP: Convert text to INT by removing invalid entries
-- ==============================================================

-- Identify non-numeric values in integer-bound columns
SELECT * FROM shein_womens_clothing
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_womens_clothing
WHERE color_count REGEXP '^[^0-9]';

-- Replace empty strings with NULL for proper type conversion
UPDATE shein_womens_clothing
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_womens_clothing
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_womens_clothing
SET color_count = null
WHERE color_count = '';

-- Modify column data types
ALTER TABLE shein_womens_clothing
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
    
-- ==============================================================
-- CLEAN goods_title: Remove numbers, non-English chars, extra spaces
-- ==============================================================

-- Preview: Remove words containing digits
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_womens_clothing
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

-- Apply: Remove words with numbers
UPDATE shein_womens_clothing
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- Convert to lowercase
UPDATE shein_womens_clothing
SET goods_title = LOWER(goods_title);

-- Preview: Remove non-alphanumeric characters (except space)
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_womens_clothing
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Apply: Keep only letters, numbers, and single spaces
UPDATE shein_womens_clothing
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- remove double spacing
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_womens_clothing
WHERE goods_title REGEXP ' {2,}';

-- Apply: Replace multiple spaces with single space
UPDATE shein_womens_clothing 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

-- Final check after cleaning
SELECT * FROM shein_womens_clothing
ORDER BY length(goods_title);

-- ==============================================================
-- FEATURE ENGINEERING: Add categorical metadata
-- ==============================================================

-- Set gender and category assumptions
 UPDATE shein_womens_clothing
 SET specific_gender = 'women';

-- gender  
 UPDATE shein_womens_clothing
 SET gender = 'female';
 
-- category 
UPDATE shein_womens_clothing
SET category = 'women_clothing';

-- ==============================================================
-- SUBCATEGORY CLASSIFICATION: Refine rank_sub based on title
-- ==============================================================
UPDATE shein_womens_clothing
SET rank_sub = 'clothing';

SELECT * FROM shein_womens_clothing
WHERE goods_title REGEXP 'Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded'
ORDER BY length(goods_title);

UPDATE shein_womens_clothing
SET rank_sub = 'outwear'
WHERE goods_title REGEXP 'Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded';
 
SELECT * FROM shein_womens_clothing
WHERE goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)'
ORDER BY length(goods_title);

UPDATE shein_womens_clothing
SET rank_sub = 'swimwear'
WHERE goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)';

SELECT * FROM shein_womens_clothing
WHERE goods_title REGEXP '(\\S+ Pantyhose|\\S+ boxer|\\S+ panties|\\S+ underwear|\\S+ bra \\S+|\\S+ brief)' AND rank_sub != 'swimwear'
ORDER BY length(goods_title);

UPDATE shein_womens_clothing
SET rank_sub = 'underwear'
WHERE goods_title REGEXP '(\\S+ Pantyhose|\\S+ boxer|\\S+ panties|\\S+ underwear|\\S+ bra \\S+|\\S+ brief)' AND rank_sub != 'swimwear';

-- ==============================================================
-- FINAL OUTPUT: Sorted by title length for review
-- ==============================================================
SELECT * FROM shein_womens_clothing
ORDER BY length(goods_title);