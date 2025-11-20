-- 1.0. BACKUP TABLE
SELECT * FROM us_shein_sports_and_outdoors_clean;

CREATE TABLE shein_sports_and_outdoors
LIKE us_shein_sports_and_outdoors_clean;

-- in order to find duplicates
UPDATE us_shein_sports_and_outdoors_clean
SET rank_title = null
WHERE rank_title = '';

UPDATE us_shein_sports_and_outdoors_clean
SET selling_proposition = null
WHERE selling_proposition = '';

UPDATE us_shein_sports_and_outdoors_clean
SET color_count = null
WHERE color_count = '';

ALTER TABLE us_shein_sports_and_outdoors_clean
    MODIFY COLUMN rank_title INT,
    MODIFY COLUMN selling_proposition INT,
    MODIFY COLUMN color_count INT UNSIGNED;
    
-- Add helper column for duplicate identification
ALTER TABLE shein_sports_and_outdoors
ADD row_num INT;

-- Insert data and assign row numbers to identify duplicates
INSERT INTO shein_sports_and_outdoors
SELECT *, row_number() OVER(PARTITION BY selling_proposition,price, 
discount, goods_title,rank_title, rank_sub, color_count) AS row_num
FROM us_shein_sports_and_outdoors_clean;

SELECT * FROM shein_sports_and_outdoors;

-- 1.1. CLEANING: Remove Duplicate Records
-- removing duplicates
SELECT row_num FROM shein_sports_and_outdoors
WHERE row_num >1;

DELETE FROM shein_sports_and_outdoors
WHERE row_num >1;

-- 2.1. DATA TYPE PREPARATION: Check for invalid characters (optional SELECTs)
-- find text in int column
SELECT * FROM shein_sports_and_outdoors
WHERE rank_title REGEXP '^[^0-9]';

SELECT * FROM shein_sports_and_outdoors
WHERE color_count REGEXP '^[^0-9]';

-- 3.1. CLEANING: Remove numbers and words containing numbers/units
-- Remove any word containing numbers
SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b','')) AS goods_title FROM shein_sports_and_outdoors
WHERE goods_title REGEXP '[0-9]+'
ORDER BY length(goods_title);

UPDATE shein_sports_and_outdoors
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\b\\S*[0-9]+\\S*\\b',''))
WHERE goods_title REGEXP '[0-9]+';

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title,'\\S+ s \\S+|^a \\S+|\\S+ pcs \\S+|^pc|\\S+ kg \\S+','')) AS goods_title FROM shein_sports_and_outdoors
WHERE goods_title REGEXP '\\S+ s \\S+|^a \\S+|\\S+ pcs \\S+|^pc \\S+ |\\S+ kg \\S+'
ORDER BY length(goods_title);

UPDATE shein_sports_and_outdoors
SET goods_title = TRIM(REGEXP_REPLACE(goods_title,'\\S+ s \\S+|^a \\S+|\\S+ pcs \\S+|^pc|\\S+ kg \\S+',''))
WHERE goods_title REGEXP '\\S+ s \\S+|^a \\S+|\\S+ pcs \\S+|^pc \\S+ |\\S+ kg \\S+';

-- 3.2. CLEANING: Normalize text
-- Convert to lowercase
UPDATE shein_sports_and_outdoors
SET goods_title = LOWER(goods_title);

-- remove double spacing

SELECT goods_title, TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' ')) FROM shein_sports_and_outdoors
WHERE goods_title REGEXP ' {2,}';

UPDATE shein_sports_and_outdoors 
SET goods_title = TRIM(REGEXP_REPLACE(goods_title, ' {2,}', ' '))
WHERE goods_title REGEXP ' {2,}';
/* note: non-alphanumeric removed in excel*/

-- 4.1. FEATURE ENGINEERING
SELECT * FROM shein_sports_and_outdoors
ORDER BY length(goods_title);

-- 4.1. FEATURE ENGINEERING: Rank Subcategory
SELECT goods_title,
	CASE
		WHEN goods_title REGEXP 'accessiores|accessories|accessory|bag|towel(s)|laggage|key(s)?' AND goods_title NOT REGEXP 'sleeve|ovesize|ezwear'
        THEN 'accessory'
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(|\\S+ bra \\S+|\\S+ bra$)' AND goods_title REGEXP '(bikini|swimwear)'
		THEN 'swimwear'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks)' AND goods_title NOT REGEXP 'towel(s)?|bag'
        THEN 'swimwear'
        
		WHEN goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|vest|\\S+ set|tracksuit)' 
        AND goods_title NOT REGEXP 'toy(s)?|accessories|necklace'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ Pantyhose|\\S+ panties|\\S+ underwear|\\S+ bra \\S+|\\S+ bra$|\\S+ brief|panty$|\\S+ panty|^bra||\\S+ tight(s)?)'  AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'underwear'
        
		WHEN goods_title REGEXP '(Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort|belt|suit)' AND
        goods_title NOT REGEXP 'toy(s)?'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded|thermal pullover|shoulder thermal|drop shoulder)' AND goods_title NOT REGEXP 'toy(s)?'
        THEN 'outwear'
        
        WHEN goods_title REGEXP '(\\S+ Strapless|waist trainer|backless|shoulder|v neck|shapewear)'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(sleeve|\\S+ TShirt|corset|shapewear bottom|oversize|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)' 
        AND goods_title NOT REGEXP 'toy(s)?|necklace|hair'
        THEN 'clothing'
		
        ELSE 'accessory'
	END as goods2
FROM shein_sports_and_outdoors
ORDER BY length(goods_title);

UPDATE shein_sports_and_outdoors
SET rank_sub = 
	CASE
		WHEN goods_title REGEXP '\\btowel\\b|\\bmat\\b|accessiores|accessories|accessory|bag|towel(s)?|laggage|key(s)?|game(s)?$|\\b game(s)? \\b|fishing rod|\\bpad(s)?\\b' AND goods_title NOT REGEXP 'sleeve|ovesize|ezwear'
        THEN 'accessory'
		WHEN goods_title REGEXP 'shoes|socks|tights|sandals|slippers|sneakers|flipflops|\\S+ boots' 
        AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?|pad(s)?)\\b'
        THEN 'footwear'
        
        WHEN goods_title REGEXP '(|\\S+ bra \\S+|\\S+ bra$)' AND goods_title REGEXP '(bikini|swimwear)'
        AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
		THEN 'swimwear'
        
         WHEN goods_title REGEXP '(Swimsuit|Bikini|Tankini|Swimwear|Swim Trunks)'
         AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
        THEN 'swimwear'
        
        WHEN goods_title REGEXP '(\\S+ Pantyhose|\\S+ panties|\\S+ underwear|\\bbra\\b|\\S+ bra$|\\S+ brief|panty$|\\S+ panty|^bra|bottom(s)?)'
        AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
        THEN 'underwear'
        
        WHEN goods_title REGEXP '(Coat|Cardigan|jacket|\\S+ hoodie|\\S+ hooded|thermal pullover|vest|shoulder thermal|drop shoulder|thermal)'
        AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
        THEN 'outwear'
        
        WHEN goods_title REGEXP '(Dress|Sundress|Romper|jumpsuit|outfit(s)?|sportswear|pj|pajama(s)?|\\S+ set|tracksuit|\\btanktop\\b)' 
       AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
        THEN 'clothing'
        
		WHEN goods_title REGEXP '(Shorts|Capris|Jeans|Pants|Leggings|Cycling Shorts|Capri Pants|skirt|trouser(s)?|skort|suit|tights)'
        AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(\\S+ Strapless|pullover|waist trainer|backless|shoulder|shapewear|v neck|neck|apron|ezwear)'
        AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
        THEN 'clothing'
        
        WHEN goods_title REGEXP '(sleeve|\\S+ TShirt|corset|shapewear bottom|oversize|\\S+ Tank Top|\\S+ Camisole|\\S+ Blouse|Shirt|\\S+ Sweater|\\S+ Cardigan|\\S+ Bodysuit|\\S+ hoodie|\\S+ tee|Cover Up|\\S+ top)' 
        AND goods_title NOT REGEXP '\\b(accessories|accessory|bag|bag|towel(s)?)\\b'
        THEN 'clothing'
		
        ELSE 'accessory'
	END;
    
SELECT * FROM shein_sports_and_outdoors
ORDER BY length(goods_title);

SELECT * FROM shein_sports_and_outdoors
WHERE goods_title REGEXP '\\b(ezwear|^acrylic|dazy|musera)\\b' AND
 rank_sub = 'accessory' AND goods_title NOT REGEXP 'accessiores|accessories|accessory|bag'
ORDER BY length(goods_title);

SELECT * FROM shein_sports_and_outdoors
WHERE goods_title REGEXP '\\b(bra)\\b' AND
 rank_sub = 'clothing' AND goods_title NOT REGEXP 'accessiores|accessories|accessory|bag'
ORDER BY length(goods_title);


-- 4.2. FEATURE ENGINEERING: Specific Gender Assignment
ALTER TABLE shein_sports_and_outdoors
ADD specific_gender varchar(45);

SELECT goods_title,
	CASE
		-- unisex first so it will take first the two genders
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?|^men(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?|^women(s)?|girl|lady|ladies' THEN 'unisex'
        
        WHEN goods_title REGEXP 'unisex' THEN 'unisex'

        -- men keywords and because 'men' is part of the word 'women' so men should be filterd first
		WHEN goods_title REGEXP '\\S+ men(s)?|^men(s)?|\\S+ man(s)?|^man(s)?|\\S+ boy(s)?' AND rank_sub != 'accessory' THEN 'men'
        
        -- women 
        ELSE 'women'
	END AS test
FROM shein_sports_and_outdoors
WHERE rank_sub != 'accessory'
ORDER BY length(goods_title);

UPDATE shein_sports_and_outdoors
SET specific_gender = 
-- not including accessories for now in order to sort the clothes
		CASE
		-- unisex first so it will take first the two genders
		WHEN goods_title REGEXP '\\S+ men(s)?|\\S+ man(s)?|^men(s)?' AND goods_title REGEXP '\\S+ women(s)?|\\S+ woman(s)?|^women(s)?|girl|lady|ladies' THEN 'unisex'
        
        WHEN goods_title REGEXP 'unisex' THEN 'unisex'

        -- men keywords and because 'men' is part of the word 'women' so men should be filterd first
		WHEN goods_title REGEXP '\\S+ men(s)?|^men(s)?|\\S+ man(s)?|^man(s)?|\\S+ boy(s)?' AND rank_sub != 'accessory' THEN 'men'
        
        ELSE 'women'
	END
WHERE rank_sub != 'accessory';
    
SELECT goods_title,
	CASE
		## based on ai the remaining accessories  for women - 75, for men -4 and the rest unisex
		## using keywords inorder to sort
        
        -- men keywords and because 'men' is part of the word 'women' so men should be filterd first
		WHEN goods_title REGEXP 'Manfinity fitness color drawstring waist joggers|Manfinity sport corelite men phone pocket sports shorts|Men western cowboy boot hat pendant keychain|
        Manfinity fitness men in phone pocket sports stretchy shorts with towel loop gym shorts|Golf club set for men' AND rank_sub = 'accessory' THEN 'men'
        
        -- women keywords
        WHEN goods_title REGEXP 'rhinestone|pearl|bowknot|flower|Pair silicone breast lift tape push up adhesive nipple cover|pair bikini breast pads|
        pair women minimalist windproof adjustable fashion versatile ski goggles|cute bubble tea keychain|heart charm keychain|pom pom charm keychain|women lipstick bag charm'
        AND rank_sub = 'accessory'
        THEN 'women'
        
        -- rest is unisex
         WHEN rank_sub = 'accessory' THEN 'unisex'
	END AS test
FROM shein_sports_and_outdoors
WHERE rank_sub = 'accessory'
ORDER BY length(goods_title);

UPDATE shein_sports_and_outdoors
SET specific_gender = 
-- not including accessories for now in order to sort the clothes
		CASE
		## based on ai the remaining accessories  for women - 75, for men -4 and the rest unisex
		## using keywords inorder to sort
        
        -- men keywords and because 'men' is part of the word 'women' so men should be filterd first
		WHEN goods_title REGEXP 'Manfinity fitness color drawstring waist joggers|Manfinity sport corelite men phone pocket sports shorts|Men western cowboy boot hat pendant keychain|
        Manfinity fitness men in phone pocket sports stretchy shorts with towel loop gym shorts|Golf club set for men' AND rank_sub = 'accessory' THEN 'men'
        
        -- women keywords
        WHEN goods_title REGEXP 'rhinestone|pearl|bowknot|flower|Pair silicone breast lift tape push up adhesive nipple cover|pair bikini breast pads|
        pair women minimalist windproof adjustable fashion versatile ski goggles|cute bubble tea keychain|heart charm keychain|pom pom charm keychain|women lipstick bag charm'
        AND rank_sub = 'accessory'
        THEN 'women'
        
        -- rest is unisex
         WHEN rank_sub = 'accessory' THEN 'unisex'
	END
    WHERE rank_sub = 'accessory';

SELECT * FROM shein_sports_and_outdoors
ORDER BY length(goods_title);

-- 4.3. FEATURE ENGINEERING: Gender Assignment
ALTER TABLE shein_sports_and_outdoors
ADD gender varchar(45);

UPDATE shein_sports_and_outdoors
SET gender =
	CASE
		WHEN specific_gender = 'men' THEN 'male'
        WHEN specific_gender = 'women' THEN 'female'
        WHEN specific_gender = 'unisex' THEN 'unisex'
        END;
        
SELECT * FROM shein_sports_and_outdoors
ORDER BY length(goods_title);

-- 4.3. FEATURE ENGINEERING: CATEGORY Assignment
ALTER TABLE shein_sports_and_outdoors
ADD category varchar(45);

UPDATE shein_sports_and_outdoors
SET category = 'sports & outdoors';

SELECT * FROM shein_sports_and_outdoors
ORDER BY length(goods_title);

-- 4.4. FINAL FEATURE AND CLEANUP
ALTER TABLE shein_sports_and_outdoors
DROP COLUMN row_num;