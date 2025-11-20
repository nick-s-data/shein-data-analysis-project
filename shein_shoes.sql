-- 1.0. BACKUP TABLE
SELECT * FROM us_shein_shoes_clean;

CREATE TABLE shein_shoes
LIKE us_shein_shoes_clean;

INSERT INTO shein_shoes
SELECT * FROM us_shein_shoes_clean;

SELECT * FROM shein_shoes;


-- 1.1. DATA TYPE PREPARATION: Handle Non-Numeric Values

-- Find records with non-numeric text
SELECT * FROM shein_shoes
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_shoes
WHERE color_count REGEXP '^[^0-9]';

UPDATE shein_shoes
SET rank_title = ''
WHERE rank_title REGEXP '^[^0-9]';

UPDATE shein_shoes
SET color_count = ''
WHERE color_count REGEXP '^[^0-9]';

-- Replace empty strings with NULL

UPDATE shein_shoes
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_shoes
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_shoes
SET color_count = null
WHERE color_count = '';

-- 1.2. DATA TYPE CONVERSION
ALTER TABLE shein_shoes
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
    

-- 2.1. CLEANING: Remove numbers and numerical words
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_shoes
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

UPDATE shein_shoes
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- 2.2. CLEANING: Normalize text
-- Convert to lowercase
UPDATE shein_shoes
SET goods_title = LOWER(goods_title);

-- Remove non-alphanumeric characters (keep spaces)

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_shoes
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

UPDATE shein_shoes
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- Remove double spacing
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_shoes
WHERE goods_title REGEXP ' {2,}';

UPDATE shein_shoes 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

SELECT * FROM shein_shoes
ORDER BY length(goods_title);

-- 3.1. FEATURE ENGINEERING: Specific Gender
-- B. Specific Gender Assignment
SELECT goods_title,
    CASE
		WHEN rank_sub REGEXP '\\S+ women(s)?' THEN 'women'
        
        WHEN rank_sub REGEXP '\\S+ men' THEN 'men'
        
        WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
        
        WHEN goods_title REGEXP 'unisex' THEN 'unisex'
        
		-- women keywords
        WHEN goods_title REGEXP 'girl|\\S+ women(s)?|^women(s)?|\\s+ woman' THEN 'women'
            
        -- men keywords
        WHEN goods_title REGEXP '\\S+ men(s)?|boy|^men|\\s+ man' THEN 'men'

        -- Unisex (default)
        ELSE 'unisex'
    END as test
FROM shein_shoes
WHERE goods_title REGEXP '\\S+ men'
;

UPDATE shein_shoes
SET specific_gender =
	CASE
		WHEN rank_sub REGEXP '\\S+ women(s)?' THEN 'women'
        
        WHEN rank_sub REGEXP '\\S+ men' THEN 'men'
        
        WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
        
        WHEN goods_title REGEXP 'unisex' THEN 'unisex'
        
		-- women keywords
        WHEN goods_title REGEXP 'girl|\\S+ women(s)?|^women(s)?|\\s+ woman|ladies|lady|female' THEN 'women'
            
        -- men keywords
        WHEN goods_title REGEXP '\\S+ men(s)?|boy|^men|\\s+ man|\\S+ male' THEN 'men'

        -- Unisex (default)
        ELSE 'unisex'
    END;

SELECT * FROM shein_shoes
WHERE specific_gender = 'unisex' AND goods_title REGEXP 'women(s)?|woman' AND goods_title NOT REGEXP '\\S+ men(s)?'
ORDER BY length(goods_title);

-- C. Correction 1: Refine 'unisex' to 'women' if female terms exist without conflicting male terms
UPDATE shein_shoes
SET specific_gender = 'women'
WHERE specific_gender = 'unisex' AND goods_title REGEXP 'women(s)?|woman' AND goods_title NOT REGEXP '\\S+ men(s)?';

SELECT * FROM shein_shoes
WHERE specific_gender = 'unisex' AND
goods_title REGEXP 'stiletto|kitten heel|sculptural heeled|pump|mule|sandal|slingback|mary jane|d\\''orsay|court pumps|ankle strap|thong sandal|tie leg|back strap
|rhinestone|glitter|pearl|bow|jewelled|sequins|feather|clear strap|dobby mesh|fluffy pom|floral|embroidered|pleats|patent|female|bridal|lolita|sxy|haute|vacation shoes|party style' 
AND goods_title NOT REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title NOT REGEXP '\\S+ women(s)?|\\S+ woman(s)?'
ORDER BY length(goods_title);

-- D. Correction 2: Refine remaining 'unisex' to 'women' based on highly feminine footwear keywords
UPDATE shein_shoes
SET specific_gender = 'women'
WHERE specific_gender = 'unisex' AND
goods_title REGEXP 'stiletto|kitten heel|sculptural heeled|pump|mule|sandal|slingback|mary jane|d\\''orsay|court pumps|ankle strap|thong sandal|tie leg|back strap
|rhinestone|glitter|pearl|bow|jewelled|sequins|feather|clear strap|dobby mesh|fluffy pom|floral|embroidered|pleats|patent|female|bridal|lolita|sxy|haute|vacation shoes|party style' 
AND goods_title NOT REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title NOT REGEXP '\\S+ women(s)?|\\S+ woman(s)?';

SELECT * FROM shein_shoes
WHERE rank_sub = 'unisex' 
ORDER BY length(goods_title);

-- 3.2. FEATURE ENGINEERING: Gender (gender)
UPDATE shein_shoes
SET gender =
	CASE
		WHEN specific_gender = 'women' THEN 'female'
        
        WHEN specific_gender = 'men' THEN 'male'
        
        WHEN specific_gender = 'unisex' THEN 'unisex'
        
    END;
    
-- 3.3. FEATURE ENGINEERING: Category and Subcategory
-- rank_sub
UPDATE shein_shoes
SET rank_sub = 'footwear';

UPDATE shein_shoes
SET category = 'shoes';

SELECT * FROM shein_shoes
ORDER BY length(goods_title);