-- 1.0. BACKUP TABLE
SELECT * FROM us_shein_baby_and_maternity_clean;

CREATE TABLE shein_baby_and_maternity
LIKE us_shein_baby_and_maternity_clean;

INSERT INTO shein_baby_and_maternity
SELECT * FROM us_shein_baby_and_maternity_clean;

SELECT * FROM shein_baby_and_maternity;


-- 1.1. DATA TYPE PREPARATION: Replace empty strings with NULL        

UPDATE shein_baby_and_maternity
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_baby_and_maternity
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_baby_and_maternity
SET color_count = null
WHERE color_count = '';

-- 1.2. DATA TYPE CONVERSION
ALTER TABLE shein_baby_and_maternity
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
    
-- 2.1. CLEANING: Remove numbers and numerical words
-- Check affected rows (optional)
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_baby_and_maternity
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

-- Update the column
UPDATE shein_baby_and_maternity
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- 2.2. CLEANING: Format text
-- Convert to lowercase
UPDATE shein_baby_and_maternity
SET goods_title = LOWER(goods_title);

-- remove double spacing

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_baby_and_maternity
WHERE goods_title REGEXP ' {2,}';

UPDATE shein_baby_and_maternity 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

-- Remove non-alphanumeric characters (keep spaces)
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_baby_and_maternity
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

UPDATE shein_baby_and_maternity
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

SELECT * FROM shein_baby_and_maternity
ORDER BY length(goods_title);

-- 3.1. FEATURE ENGINEERING: Populate 'category'
	
UPDATE shein_baby_and_maternity
SET category = 'baby & maternity'
;

-- 3.2. FEATURE ENGINEERING: Populate 'specific_gender' (baby/kids/women)
SELECT goods_title,
    CASE
		-- unisex keywords
		WHEN goods_title REGEXP 'boys and girls|boys, ?girls|boys & girls|boys girls|girls boys|unisex' THEN 'unisex'
        
        WHEN goods_title REGEXP 'boys' AND goods_title REGEXP 'girls' THEN 'unisex'
		-- Girls keywords
        WHEN goods_title REGEXP 'girl(s)?' THEN 'girls'
            
        -- Boys keywords
        WHEN goods_title REGEXP 'boy|men' THEN 'boys'
        
        -- women keywords
		WHEN goods_title REGEXP 'maternity|women' THEN 'women'
        -- Unisex (default)
        ELSE 'unisex'
    END as test
FROM shein_baby_and_maternity
;

UPDATE shein_baby_and_maternity
SET specific_gender =
    CASE
		-- unisex keywords
		WHEN goods_title REGEXP 'boys and girls|boys, ?girls|boys & girls|boys girls|girls boys|unisex' THEN 'unisex'
        
        WHEN goods_title REGEXP 'boys' AND goods_title REGEXP 'girls' THEN 'unisex'
		-- Girls keywords
        WHEN goods_title REGEXP 'girl(s)?' THEN 'girls'
            
        -- Boys keywords
        WHEN goods_title REGEXP 'boy|men' THEN 'boys'
        
        -- women keywords
		WHEN goods_title REGEXP 'maternity|women' THEN 'women'
        -- Unisex (default)
        ELSE 'unisex'
    END;

-- 3.3. FEATURE ENGINEERING: Populate 'gender' (male/female/unisex)
 UPDATE shein_baby_and_maternity
SET gender =
    CASE
		-- unisex keywords
		WHEN goods_title REGEXP 'boys and girls|boys, ?girls|boys & girls|boys girls|girls boys|unisex' THEN 'unisex'
        
        WHEN goods_title REGEXP 'boys' AND goods_title REGEXP 'girls' THEN 'unisex'
		-- Girls keywords
        WHEN goods_title REGEXP 'girl(s)?' THEN 'female'
            
        -- Boys keywords
        WHEN goods_title REGEXP 'boy|men' THEN 'male'
        
        -- women keywords
		WHEN goods_title REGEXP 'maternity|women' THEN 'fe'
        -- Unisex (default)
        ELSE 'unisex'
    END;

SELECT * FROM shein_baby_and_maternity
ORDER BY length(goods_title);

-- 3.4. FEATURE ENGINEERING: Populate 'rank_sub' (Subcategory)
SELECT goods_title, 
	CASE
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots \\S+' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(\\S+ bra \\S+)' AND goods_title REGEXP '(bikini|swimwear)' AND goods_title NOT REGEXP 'toy(s)?'
		THEN 'swimwear'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'swimwear'
        
		WHEN goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|vest|\\S+ set|tracksuit)' 
        AND goods_title NOT REGEXP 'toy(s)?|accessories|necklace'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ Pantyhose|\\S+ boxer|\\S+ panties|\\S+ underwear|\\S+ bra \\S+|\\S+ brief)'  AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'underwear'
        
		WHEN goods_title REGEXP '(Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort)' AND
        goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'outwear'
        
        WHEN goods_title REGEXP '(\\S+ Strapless|)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ TShirt|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)' 
        AND goods_title NOT REGEXP 'toy(s)?|necklace|hair'
        THEN 'clothing'
        
		ELSE 'accessory'
	END 
FROM shein_baby_and_maternity
; 	


																		
UPDATE shein_baby_and_maternity
SET rank_sub = 
	CASE
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots \\S+' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(\\S+ bra \\S+)' AND goods_title REGEXP '(bikini|swimwear)' AND goods_title NOT REGEXP 'toy(s)?'
		THEN 'swimwear'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'swimwear'
        
		WHEN goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|vest|\\S+ set|tracksuit)' 
        AND goods_title NOT REGEXP 'toy(s)?|accessories|necklace'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ Pantyhose|\\S+ boxer|\\S+ panties|\\S+ underwear|\\S+ bra \\S+|\\S+ brief)'  AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'underwear'
        
		WHEN goods_title REGEXP '(Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort)' AND
        goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'outwear'
        
        WHEN goods_title REGEXP '(\\S+ Strapless)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ TShirt|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)' 
        AND goods_title NOT REGEXP 'toy(s)?|necklace|hair'
        THEN 'clothing'
        
		ELSE 'accessory'
	END;

-- 3.5. FINAL SUB CATEGORY CORRECTIONS    
SELECT * FROM shein_baby_and_maternity
WHERE goods_title REGEXP 'bra|panty|tights|socks|stockings' AND rank_sub = 'accessory'
ORDER BY length(goods_title);

UPDATE shein_baby_and_maternity
SET rank_sub = 'clothing'
WHERE goods_title REGEXP 'bra|panty|tights|socks|stockings' AND rank_sub = 'accessory';

SELECT * FROM shein_baby_and_maternity
ORDER BY length(goods_title);

SELECT * FROM shein_baby_and_maternity
WHERE goods_title REGEXP '\\S+ hair brush|\\S+ toothbrush|\\S+ building|\\S+ bag \\S+|\\S+ dustproof ' AND rank_sub = 'clothing' AND
 goods_title NOT REGEXP 'shorts|jumpsuit|dress|tshirt'
ORDER BY length(goods_title);

UPDATE shein_baby_and_maternity
SET rank_sub = 'accessory'
WHERE goods_title REGEXP '\\S+ hair brush|\\S+ toothbrush|\\S+ building|\\S+ bag \\S+|\\S+ dustproof|accessories' AND rank_sub = 'clothing' AND
goods_title NOT REGEXP 'shorts|jumpsuit|dress|tshirt';
 
 SELECT * FROM shein_baby_and_maternity
ORDER BY length(goods_title);