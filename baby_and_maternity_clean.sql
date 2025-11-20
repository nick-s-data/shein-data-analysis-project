-- ==============================================================
-- BACKUP TABLE: Create a working copy of the source data
-- ==============================================================

SELECT * FROM us_shein_baby_and_maternity_clean;

CREATE TABLE shein_baby_and_maternity_clean
LIKE us_shein_baby_and_maternity_clean;

INSERT INTO shein_baby_and_maternity_clean
SELECT * FROM us_shein_baby_and_maternity_clean;

SELECT * FROM shein_baby_and_maternity_clean;


-- ==============================================================
-- DATA CLEANUP: Fix empty strings to NULL in key columns
-- ==============================================================

-- Preview: Empty selling_proposition
SELECT selling_proposition 
FROM shein_baby_and_maternity_clean 
WHERE selling_proposition = '';

-- Replace empty strings with NULL
UPDATE shein_baby_and_maternity_clean
SET    selling_proposition = NULL
WHERE  selling_proposition = '';

-- Replace empty color_count with NULL
UPDATE shein_baby_and_maternity_clean
SET    color_count = NULL
WHERE  color_count = '';


-- ==============================================================
-- STANDARDIZE goods_title: Dresses & Short Sleeves
-- ==============================================================

-- Preview: Maternity/Women's dresses
SELECT 
    goods_title,
    CASE WHEN goods_title LIKE '%dress%' THEN 'dress women' ELSE goods_title END AS standardized
FROM shein_baby_and_maternity_clean
WHERE goods_title LIKE '%maternity%' OR goods_title LIKE '%women%';

-- Apply: Standardize women's dresses
UPDATE shein_baby_and_maternity_clean
SET    goods_title = CASE 
    WHEN goods_title LIKE '%dress%' THEN 'dress women'
    ELSE goods_title 
END
WHERE  goods_title LIKE '%maternity%' OR goods_title LIKE '%women%';


-- Preview: Girl's dresses
SELECT 
    goods_title,
    CASE WHEN goods_title LIKE '%dress%' THEN 'dress girl' ELSE goods_title END AS standardized
FROM shein_baby_and_maternity_clean
WHERE goods_title LIKE '%girl%';

-- Apply: Standardize girl's dresses
UPDATE shein_baby_and_maternity_clean
SET    goods_title = CASE 
    WHEN goods_title LIKE '%dress%' THEN 'dress girl'
    ELSE goods_title 
END
WHERE  goods_title LIKE '%girl%';


-- Preview: Women's short sleeve
SELECT 
    goods_title,
    CASE WHEN goods_title LIKE '%Short Sleeve%' THEN 'short sleeve women' ELSE goods_title END AS standardized
FROM shein_baby_and_maternity_clean
WHERE goods_title LIKE '%maternity%' OR goods_title LIKE '%women%';

-- Apply: Standardize women's short sleeve
UPDATE shein_baby_and_maternity_clean
SET    goods_title = CASE 
    WHEN goods_title LIKE '%Short Sleeve%' THEN 'short sleeve women'
    ELSE goods_title 
END
WHERE  goods_title LIKE '%maternity%' OR goods_title LIKE '%women%';


-- Preview: Kids' short sleeve
SELECT 
    goods_title,
    CASE WHEN goods_title LIKE '%Short Sleeve%' THEN 'short sleeve kids' ELSE goods_title END AS standardized
FROM shein_baby_and_maternity_clean
WHERE goods_title LIKE '%boy%' OR goods_title LIKE '%girl%';

-- Apply: Standardize kids' short sleeve
UPDATE shein_baby_and_maternity_clean
SET    goods_title = CASE 
    WHEN goods_title LIKE '%Short Sleeve%' THEN 'short sleeve kids'
    ELSE goods_title 
END
WHERE  goods_title LIKE '%boy%' OR goods_title LIKE '%girl%';


-- ==============================================================
-- STANDARDIZE: Specific product types
-- ==============================================================

-- Standardize 'puzzle'
UPDATE shein_baby_and_maternity_clean
SET    goods_title = 'puzzle'
WHERE  goods_title LIKE '%puzzle%';

-- Standardize 'swimsuit'
UPDATE shein_baby_and_maternity_clean
SET    goods_title = 'swimsuit'
WHERE  goods_title LIKE '%swimsuit%';


-- ==============================================================
-- CLEAN TITLE PREFIXES: Remove leading numbers, sets, commas, etc.
-- ==============================================================

-- Preview: Complex prefix cleanup logic
SELECT 
    goods_title,
    CASE
        WHEN goods_title REGEXP '^[0-9]+(pcs|pc), ' THEN 
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title, ',', 2), ',', -1))
        WHEN goods_title REGEXP '^[0-9]+(pcs|pc)' THEN 
            TRIM(SUBSTRING_INDEX(goods_title, ',', 1))
        WHEN goods_title REGEXP '^[0-9]+' OR goods_title REGEXP '^\\(' OR goods_title REGEXP '^\\\'' THEN 
            TRIM(SUBSTRING_INDEX(goods_title, ',', 1))
        WHEN goods_title REGEXP '^[^0-9], ' THEN 
            TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title, ',', 2), ',', -1))
        WHEN goods_title REGEXP '^[^0-9]' THEN 
            TRIM(SUBSTRING_INDEX(goods_title, ',', 1))
        ELSE goods_title
    END AS cleaned_title
FROM shein_baby_and_maternity_clean;

-- Apply: Remove unwanted prefixes
UPDATE shein_baby_and_maternity_clean
SET    goods_title = CASE
    WHEN goods_title REGEXP '^[0-9]+(pcs|pc), ' THEN 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title, ',', 2), ',', -1))
    WHEN goods_title REGEXP '^[0-9]+(pcs|pc)' THEN 
        TRIM(SUBSTRING_INDEX(goods_title, ',', 1))
    WHEN goods_title REGEXP '^[0-9]+' OR goods_title REGEXP '^\\(' OR goods_title REGEXP '^\\\'' THEN 
        TRIM(SUBSTRING_INDEX(goods_title, ',', 1))
    WHEN goods_title REGEXP '^[^0-9], ' THEN 
        TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title, ',', 2), ',', -1))
    WHEN goods_title REGEXP '^[^0-9]' THEN 
        TRIM(SUBSTRING_INDEX(goods_title, ',', 1))
    ELSE goods_title
END;


-- ==============================================================
-- CLEAN NON-ASCII & SPECIAL CHARACTERS
-- ==============================================================

-- Preview: Remove non-alphanumeric (except space)
SELECT 
    goods_title,
    TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_title
FROM shein_baby_and_maternity_clean
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Apply: Keep only letters, numbers, and spaces
UPDATE shein_baby_and_maternity_clean
SET    goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE  goods_title REGEXP '[^a-zA-Z0-9 ]';


-- ==============================================================
-- REMOVE NUMBERS FROM TITLE (if title starts with number)
-- ==============================================================

-- Preview: Remove number-containing words if title starts with digit
SELECT 
    goods_title,
    CASE 
        WHEN goods_title REGEXP '^[0-9]+' 
        THEN TRIM(REGEXP_REPLACE(goods_title, '\\b\\S*[0-9]+\\S*\\b', ''))
        ELSE goods_title 
    END AS cleaned_title
FROM shein_baby_and_maternity_clean;

-- Apply
UPDATE shein_baby_and_maternity_clean
SET    goods_title = CASE 
    WHEN goods_title REGEXP '^[0-9]+' 
    THEN TRIM(REGEXP_REPLACE(goods_title, '\\b\\S*[0-9]+\\S*\\b', ''))
    ELSE goods_title 
END;


-- ==============================================================
-- REMOVE PCS/PC/SET leftovers
-- ==============================================================

-- Preview
SELECT 
    goods_title,
    TRIM(REGEXP_REPLACE(goods_title, '[0-9]+ ?(pcs|pc|set)', '')) AS cleaned_title
FROM shein_baby_and_maternity_clean
WHERE goods_title REGEXP '[0-9]+ ?(pcs|pc|set)';

-- Apply
UPDATE shein_baby_and_maternity_clean
SET    goods_title = TRIM(REGEXP_REPLACE(goods_title, '[0-9]+ ?(pcs|pc|set)', ''))
WHERE  goods_title REGEXP '[0-9]+ ?(pcs|pc|set)';


-- ==============================================================
-- REMOVE DOUBLE SPACES
-- ==============================================================

-- Preview
SELECT 
    goods_title,
    TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) AS cleaned_title
FROM shein_baby_and_maternity_clean
WHERE goods_title REGEXP ' {2,}';

-- Apply
UPDATE shein_baby_and_maternity_clean
SET    goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE  goods_title REGEXP ' {2,}';


-- ==============================================================
-- CONVERT TO LOWERCASE
-- ==============================================================

UPDATE shein_baby_and_maternity_clean
SET    goods_title = LOWER(goods_title);


-- ==============================================================
-- CATEGORY STANDARDIZATION
-- ==============================================================

UPDATE shein_baby_and_maternity_clean
SET    category = 'baby and maternity'
WHERE  category REGEXP 'baby/maternity';


-- ==============================================================
-- MANUAL FIX: Specific known product
-- ==============================================================

-- Investigate known case
SELECT * FROM us_shein_baby_and_maternity_clean
WHERE price = 4 AND discount = 0 AND color_count = 4;

-- Apply fix
UPDATE shein_baby_and_maternity_clean
SET    goods_title = 'stretchy beanie hat'
WHERE  price = 4 AND discount = 0 AND color_count = 4;


-- ==============================================================
-- FINAL OUTPUT
-- ==============================================================

SELECT * FROM shein_baby_and_maternity_clean
ORDER BY LENGTH(goods_title);