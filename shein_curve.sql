SELECT * FROM us_shein_curve_clean;

CREATE TABLE shein_curve
LIKE us_shein_curve_clean;

INSERT INTO shein_curve
SELECT * FROM us_shein_curve_clean;

SELECT * FROM shein_curve;

		-- Changing the data type --

-- find text in int column
SELECT * FROM shein_curve
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_curve
WHERE color_count REGEXP '^[^0-9]';

-- replacing empty space with null in order to change datatype

UPDATE shein_curve
SET rank_title = null
WHERE rank_title = '';

UPDATE shein_curve
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE shein_curve
SET color_count = null
WHERE color_count = '';

ALTER TABLE shein_curve
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
    
-- removing unnecessary text
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_curve
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

UPDATE shein_curve
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

-- lowercase

UPDATE shein_curve
SET goods_title = LOWER(goods_title);

-- remove non english or number letters

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', '')) AS cleaned_code FROM shein_curve
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

UPDATE shein_curve
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, '[^a-zA-Z0-9 ]', ''))
WHERE goods_title REGEXP '[^a-zA-Z0-9 ]';

-- remove double spacing

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_curve
WHERE goods_title REGEXP ' {2,}';

UPDATE shein_curve 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';

SELECT * FROM shein_curve
ORDER BY length(goods_title);

	-- FEATURE ENGINEERING--
-- rank_sub
SELECT goods_title,
	CASE
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(\\S+ bra \\S+)' AND goods_title REGEXP '(bikini|swimwear)' AND goods_title NOT REGEXP 'toy(s)?'
		THEN 'swimwear'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'swimwear'
        
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
		
        ELSE 'clothing'
	END as goods2
FROM shein_curve;


UPDATE shein_curve
SET rank_sub = 
	CASE
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(\\S+ bra \\S+)' AND goods_title REGEXP '(bikini|swimwear)' AND goods_title NOT REGEXP 'toy(s)?'
		THEN 'swimwear'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks|swim)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'swimwear'
        
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
		
        ELSE 'clothing'
	END
;
    
SELECT * FROM shein_curve
ORDER BY length(goods_title);

-- specific_gender
-- most of the clothes in curve are for women according to shein
SELECT goods_title, 
	CASE
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
        
        WHEN goods_title REGEXP 'unisex' THEN 'unisex'
        
        WHEN goods_title REGEXP '(^men(s)?|\\S+ men)'
        THEN 'men'
        
	ELSE 'women' 
	END AS 'test'
FROM shein_curve
;

UPDATE shein_curve
SET specific_gender = 
	CASE
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?' THEN 'unisex'
        
        WHEN goods_title REGEXP 'unisex' THEN 'unisex'
        
        WHEN goods_title REGEXP '(^men(s)?|\\S+ men)'
        THEN 'men'
        
		ELSE 'women' 
	END;
    
-- gender

UPDATE shein_curve
SET gender = 
	CASE
		WHEN specific_gender = 'men' THEN 'male'
        
        
        WHEN specific_gender = 'unisex' THEN 'unisex'
        
        WHEN specific_gender = 'women' THEN 'female'
        
	END;
    
-- category
UPDATE shein_curve
SET category = 'curve';

SELECT * FROM shein_curve
ORDER BY length(goods_title);