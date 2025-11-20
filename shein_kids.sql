-- 1.0. BACKUP TABLE
SELECT * FROM us_shein_kids_clean;

CREATE TABLE shein_kids
LIKE us_shein_kids_clean;

INSERT INTO shein_kids
SELECT * FROM us_shein_kids_clean;

SELECT * FROM shein_kids;

		-- Changing data type --
-- 1.1. DATA TYPE PREPARATION: Handle Non-Numeric Values        
-- Find records with non-numeric characters in columns intended for INT/FLOAT
SELECT * FROM shein_kids
WHERE rank_title REGEXP '^[^0-9]' OR color_count REGEXP '^[^0-9]';

-- Replace non-numeric strings with empty string (intermediate step)
UPDATE shein_kids
SET rank_title = ''
WHERE rank_title REGEXP '^[^0-9]';

UPDATE shein_kids
SET color_count = ''
WHERE color_count REGEXP '^[^0-9]';

-- Replace empty strings with NULL to facilitate data type change and filtering
UPDATE shein_kids
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_kids
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_kids
SET color_count = null
WHERE color_count = '';

-- 2.1. CLEANING: Standardize/Shorten Goods Title
SELECT goods_title FROM shein_kids;

-- A. Extract main title by removing numerical/quantity prefixes
-- Target: Titles starting with a count (e.g., '3pc set, Dinosaur print...')
SELECT goods_title, TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 2),',', -1)) AS g2 FROM shein_kids
WHERE goods_title REGEXP '^[0-9]+ ?(pc|pairs|pcs large|pcs\/set),' 
ORDER BY length(g2);

-- Target: Titles starting with a count, keeping only the first item (less aggressive)
UPDATE shein_kids
SET goods_title = TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 2),',', -1))
WHERE goods_title REGEXP '^[0-9]+ ?(pc|pairs|pcs large|pcs\/set),' ;

SELECT goods_title, TRIM(SUBSTRING_INDEX(goods_title,',', 1)) AS g2 FROM shein_kids
WHERE goods_title REGEXP '^[0-9]+'
ORDER BY length(g2);

UPDATE shein_kids
SET goods_title = TRIM(SUBSTRING_INDEX(goods_title,',', 1))
WHERE goods_title REGEXP '^[0-9]+' ;


SELECT goods_title FROM shein_kids
ORDER BY length(goods_title);

-- B. Remove numbers and measurement units/count words from the title
-- Remove any word containing numbers (e.g., '10pc')
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_kids
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

UPDATE shein_kids
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- Remove standalone unit/count words
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*^(pair|pc(s)?|set(s)?|cm|in|piece|size(s)?)\\S*\\b','')) AS goods_title FROM shein_kids
WHERE goods_title REGEXP '^(pair|pc(s)?|set(s)?|cm|in|piece|size(s)?)'
ORDER BY length(goods_title);

UPDATE shein_kids
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*^(pair|pc(s)?|set(s)?|cm|in|piece|size(s)?)\\S*\\b',''))
WHERE goods_title REGEXP '^(pair|pc(s)?|set(s)?|cm|in|piece|size(s)?)';

SELECT goods_title, TRIM(SUBSTRING_INDEX(goods_title,',', 1)) AS g2 FROM shein_kids
WHERE goods_title REGEXP '^[^0-9]+'
ORDER BY length(g2);

-- C. Handle specific comma-separated patterns
-- Pattern 1: `day, ...`
SELECT goods_title,
CASE
		WHEN goods_title LIKE '%day,%'
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 2),',','-1')) 
END
FROM shein_kids
WHERE goods_title REGEXP '^day, ';

UPDATE shein_kids
SET goods_title =
CASE
	WHEN goods_title LIKE '%day,%'
	THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 2),',','-1')) 
END
WHERE goods_title REGEXP '^day, ';

SELECT goods_title,
	CASE
		WHEN goods_title REGEXP '^summer,' 
			THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 6),',','-1'))
	END
FROM shein_kids
WHERE goods_title REGEXP '^summer, ';

UPDATE shein_kids
SET goods_title =
	CASE
		WHEN goods_title REGEXP '^summer,' 
			THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 6),',','-1'))
	END
WHERE goods_title REGEXP '^summer, ';

UPDATE shein_kids
SET goods_title =
	CASE
		WHEN goods_title REGEXP '^dinosaurs, summer,' 
			THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 3),',','-1'))
	END
WHERE goods_title REGEXP '^dinosaurs, summer,' ;

UPDATE shein_kids
SET goods_title =
	CASE
		WHEN goods_title REGEXP '^classic, '
        THEN TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(goods_title,',', 2),',','-1')) 
	END
WHERE goods_title REGEXP '^classic, ';

SELECT * FROM shein_kids
ORDER BY length(goods_title);

-- D. Final formatting and cleanup
-- Convert to lowercase

UPDATE shein_kids
SET goods_title = LOWER(goods_title);

-- Remove double spacing

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_kids
WHERE goods_title REGEXP ' {2,}';

UPDATE shein_kids 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

-- Remove non-alphanumeric characters (keeping spaces)

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_kids
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

UPDATE shein_kids
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

SELECT * FROM shein_kids
ORDER BY length(goods_title);

-- 3.1. FEATURE ENGINEERING: Populate 'category'
UPDATE shein_kids
SET category = 'shein kids'
WHERE category = '';

-- 3.2. FEATURE ENGINEERING: Populate 'specific_gender' (with 'women' target)
SELECT goods_title,
    CASE
		-- unisex keywords
		WHEN goods_title REGEXP 'boys and girls|boys, ?girls|boys & girls|boys girls|girls boys|unisex' THEN 'unisex'
        
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
         
        WHEN goods_title REGEXP 'boys' AND goods_title REGEXP 'girls' THEN 'unisex'
        
         -- women keywords
        WHEN goods_title REGEXP 'women|maternity' THEN 'women'
        
		-- Girls keywords
        WHEN goods_title REGEXP 'girl|women|skort|romper|jumpsuit|camisole|ruffle|skirt
			|lace|frill|puff|pleated|princess|butterfly|heart|unicorn|candy-colored|swimsuit|bikini|cover-up|pink|
            tie-dye|shiny|glitter|hair|makeup' THEN 'girls'
            
        -- Boys keywords
        WHEN goods_title REGEXP 'boy|men|blue|black|gray' THEN 'boys'

        -- Unisex (default)
        ELSE 'unisex'
    END as test
FROM shein_kids;
    
UPDATE shein_kids
SET specific_gender =
    CASE
		-- unisex keywords
		WHEN goods_title REGEXP 'boys and girls|boys, ?girls|boys & girls|boys girls|girls boys|unisex' THEN 'unisex'
        
        WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
        
        WHEN goods_title REGEXP 'boys' AND goods_title REGEXP 'girls' THEN 'unisex'
        
        -- women keywords
        WHEN goods_title REGEXP 'women|maternity' THEN 'women'
		-- Girls keywords
        WHEN goods_title REGEXP 'girl|skort|romper|jumpsuit|camisole|ruffle|skirt
			|lace|frill|puff|pleated|princess|butterfly|heart|unicorn|candy-colored|swimsuit|bikini|cover-up|pink|
            tie-dye|shiny|glitter|hair|makeup' THEN 'girls'
            
        -- Boys keywords
        WHEN goods_title REGEXP 'boy|men|blue|black|gray' THEN 'boys'

        -- Unisex (default)
        ELSE 'unisex'
    END
;

-- 3.3. FEATURE ENGINEERING: Populate 'gender' (with 'female' target)
UPDATE shein_kids
SET gender =
    CASE
		-- unisex keywords
		WHEN goods_title REGEXP 'boys and girls|boys, ?girls|boys & girls|boys girls|girls boys|unisex' THEN 'unisex'
        
        WHEN goods_title REGEXP 'boys' AND goods_title REGEXP 'girls' THEN 'unisex'
		-- female keywords
        WHEN goods_title REGEXP 'girl|women|skort|romper|jumpsuit|camisole|ruffle|skirt
			|lace|frill|puff|pleated|princess|butterfly|heart|unicorn|candy-colored|swimsuit|bikini|cover-up|pink|
            tie-dye|shiny|glitter|hair|makeup' THEN 'female'
            
        -- male keywords
        WHEN goods_title REGEXP 'boy|men|blue|black|gray' THEN 'male'

        -- Unisex (default)
        ELSE 'unisex'
    END
;

SELECT * FROM shein_kids
ORDER BY length(goods_title);

SELECT goods_title FROM shein_kids
ORDER BY length(goods_title);

-- 3.4. FEATURE ENGINEERING: Populate 'rank_sub' (Subcategory)
SELECT goods_title,
	CASE
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(\\S+ bra \\S+)' AND goods_title REGEXP '(bikini|swimwear)' AND goods_title NOT REGEXP 'toy(s)?'
		THEN 'clothing'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
		WHEN goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|vest|\\S+ set|tracksuit)' 
        AND goods_title NOT REGEXP 'toy(s)?|accessories|necklace'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ Pantyhose|\\S+ boxer|\\S+ panties|\\S+ underwear|\\S+ bra|\\S+ brief)'  AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'underwear'
        
		WHEN goods_title REGEXP '(Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort|belt)' AND
        goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'outwear'
        
        WHEN goods_title REGEXP '(\\S+ Strapless)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ TShirt|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)' 
        AND goods_title NOT REGEXP 'toy(s)?|necklace|hair'
        THEN 'clothing'
        
		ELSE 'accessories'
	END as goods2
FROM shein_kids
;

SELECT * FROM shein_kids
ORDER BY length(goods_title);

UPDATE shein_kids
SET rank_sub = 
	CASE
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(\\S+ bra \\S+)' AND goods_title REGEXP '(bikini|swimwear)' AND goods_title NOT REGEXP 'toy(s)?'
		THEN 'clothing'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
		WHEN goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|vest|\\S+ set|tracksuit)' 
        AND goods_title NOT REGEXP 'toy(s)?|accessories|necklace'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ Pantyhose|\\S+ boxer|\\S+ panties|\\S+ underwear|\\S+ bra \\S+|bra$|\\S+ brief)'  AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'underwear'
        
		WHEN goods_title REGEXP '(Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort|belt)' AND
        goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'outwear'
        
        WHEN goods_title REGEXP '(\\S+ Strapless)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ TShirt|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)' 
        AND goods_title NOT REGEXP 'toy(s)?|necklace|hair'
        THEN 'clothing'
        
		ELSE 'accessories'
	END;

-- 3.5. FINAL SUB CATEGORY CORRECTION
SELECT * FROM shein_kids
ORDER BY length(goods_title);

SELECT * FROM shein_kids
WHERE rank_sub = 'accessories'  AND goods_title regexp 'shirt|sleeve|shrot(s)?'
ORDER BY length(goods_title);

UPDATE shein_kids
SET rank_sub = 'clothing'
WHERE rank_sub = 'accessories'  AND goods_title regexp 'shirt|sleeve|shrot(s)?';

SELECT * FROM shein_kids
WHERE rank_sub = 'accessories'  
ORDER BY length(goods_title);

SELECT * FROM shein_kids
WHERE goods_title REGEXP 'women|maternity'
ORDER BY length(goods_title);