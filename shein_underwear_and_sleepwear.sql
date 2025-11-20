-- ==============================================================
-- BACKUP TABLE: Create a working copy of the source data
-- ==============================================================

SELECT * FROM us_shein_underwear_and_sleepwear_clean;

CREATE TABLE shein_underwear_and_sleepwear
LIKE us_shein_underwear_and_sleepwear_clean;

INSERT INTO shein_underwear_and_sleepwear
SELECT * FROM us_shein_underwear_and_sleepwear_clean;

SELECT * FROM shein_underwear_and_sleepwear;


-- ==============================================================
-- DATA TYPE CLEANUP: Convert text to INT by removing invalid entries
-- ==============================================================

-- Identify non-numeric values in integer-bound columns
SELECT * FROM shein_underwear_and_sleepwear
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_underwear_and_sleepwear
WHERE color_count REGEXP '^[^0-9]';

-- Clear non-numeric values
UPDATE shein_underwear_and_sleepwear
SET    rank_title = ''
WHERE  rank_title REGEXP '^[^0-9]';

UPDATE shein_underwear_and_sleepwear
SET    color_count = ''
WHERE  color_count REGEXP '^[^0-9]';

-- Replace empty strings with NULL for proper type conversion
UPDATE shein_underwear_and_sleepwear
SET    rank_title = NULL
WHERE  rank_title = '';

UPDATE shein_underwear_and_sleepwear
SET    selling_proposition = NULL
WHERE  selling_proposition = '';

UPDATE shein_underwear_and_sleepwear
SET    color_count = NULL
WHERE  color_count = '';

-- Modify column data types
ALTER TABLE shein_underwear_and_sleepwear
    MODIFY COLUMN rank_title          INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count         INT UNSIGNED;


-- ==============================================================
-- CLEAN goods_title: Remove numbers, non-English chars, extra spaces
-- ==============================================================

-- Preview: Remove words containing digits
SELECT 
    goods_title,
    TRIM(REGEXP_REPLACE(goods_title, '\\b\\S*[0-9]+\\S*\\b', '')) AS cleaned_title
FROM shein_underwear_and_sleepwear
WHERE goods_title REGEXP '[0-9]+'
ORDER BY LENGTH(goods_title);

-- Apply: Remove words with numbers
UPDATE shein_underwear_and_sleepwear
SET    goods_title = TRIM(REGEXP_REPLACE(goods_title, '\\b\\S*[0-9]+\\S*\\b', ''))
WHERE  goods_title REGEXP '[0-9]+';

-- Convert to lowercase
UPDATE shein_underwear_and_sleepwear
SET    goods_title = LOWER(goods_title);

-- Preview: Remove non-alphanumeric characters (except space)
SELECT 
    goods_title,
    TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_title
FROM shein_underwear_and_sleepwear
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Apply: Keep only letters, numbers, and single spaces
UPDATE shein_underwear_and_sleepwear
SET    goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE  goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Preview: Collapse multiple spaces
SELECT 
    goods_title,
    TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) AS cleaned_title
FROM shein_underwear_and_sleepwear
WHERE goods_title REGEXP ' {2,}';

-- Apply: Replace multiple spaces with single space
UPDATE shein_underwear_and_sleepwear
SET    goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE  goods_title REGEXP ' {2,}';

-- Final check after cleaning
SELECT * FROM shein_underwear_and_sleepwear
ORDER BY LENGTH(goods_title);


-- ==============================================================
-- FEATURE ENGINEERING: rank_sub, category, gender classification
-- ==============================================================

-- Default rank_sub
UPDATE shein_underwear_and_sleepwear
SET    rank_sub = 'underwear';

-- Preview: Footwear items
SELECT * FROM shein_underwear_and_sleepwear
WHERE goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots \\S+'
ORDER BY LENGTH(goods_title);

-- Assign: Footwear
UPDATE shein_underwear_and_sleepwear
SET    rank_sub = 'footwear'
WHERE  goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots \\S+';


-- Preview: Clothing items
SELECT * FROM shein_underwear_and_sleepwear
WHERE goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|vest|tracksuit|
Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort|
\\S+ TShirt|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)'
ORDER BY LENGTH(goods_title);

-- Assign: Clothing
UPDATE shein_underwear_and_sleepwear
SET    rank_sub = 'clothing'
WHERE  goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|vest|tracksuit|
Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort|
\\S+ TShirt|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)';


-- Set category
UPDATE shein_underwear_and_sleepwear
SET    category = 'underwear & sleepwear';


-- ==============================================================
-- GENDER CLASSIFICATION: specific_gender using CASE logic
-- ==============================================================

-- Preview: Test gender logic
SELECT 
    goods_title,
    CASE
        WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
        WHEN goods_title REGEXP 'unisex' THEN 'unisex'
        WHEN goods_title REGEXP '(^men(s)?|\\S+ men|\\S+ boxer)' THEN 'men'
        ELSE 'women'
    END AS test_gender
FROM shein_underwear_and_sleepwear;

-- Apply: Assign specific_gender
UPDATE shein_underwear_and_sleepwear
SET    specific_gender = CASE
    WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
    WHEN goods_title REGEXP 'unisex' THEN 'unisex'
    WHEN goods_title REGEXP '(^men(s)?|\\S+ men|\\S+ boxer)' THEN 'men'
    ELSE 'women'
END;


-- ==============================================================
-- CLEANUP: Fix ambiguous 'unisex' → 'women' if only women keywords
-- ==============================================================

-- Preview: Unisex items that are actually women's
SELECT * FROM shein_underwear_and_sleepwear
WHERE specific_gender = 'unisex'
  AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?'
  AND goods_title NOT REGEXP '\\S+ men|^men|unisex'
ORDER BY LENGTH(goods_title);

-- Correct: Reassign to 'women'
UPDATE shein_underwear_and_sleepwear
SET    specific_gender = 'women'
WHERE  specific_gender = 'unisex'
  AND  goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?'
  AND  goods_title NOT REGEXP '\\S+ men|^men|unisex';


-- Final sanity check: Should return 0 rows
SELECT * FROM shein_underwear_and_sleepwear
WHERE specific_gender = 'women'
  AND goods_title REGEXP '\\S+ men|^men|unisex'
ORDER BY LENGTH(goods_title);


-- ==============================================================
-- DERIVE gender FROM specific_gender
-- ==============================================================

UPDATE shein_underwear_and_sleepwear
SET    gender = CASE
    WHEN specific_gender = 'unisex' THEN 'unisex'
    WHEN specific_gender = 'women'  THEN 'female'
    WHEN specific_gender = 'men'    THEN 'male'
    ELSE 'female'
END;


-- ==============================================================
-- FINAL OUTPUT: Sorted by title length for review
-- ==============================================================

SELECT * FROM shein_underwear_and_sleepwear
ORDER BY LENGTH(goods_title);