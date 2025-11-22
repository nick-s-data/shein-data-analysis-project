-- CREATE TABLE: Create the merged categories table
CREATE TABLE shein_merged_categories
LIKE shein_baby_and_maternity;

-- INSERT DATA: Merge all category tables using UNION ALL
INSERT INTO shein_merged_categories
SELECT * FROM shein_baby_and_maternity
UNION ALL
SELECT * FROM shein_bags_and_luggage
UNION ALL
SELECT * FROM shein_curve
UNION ALL
SELECT * FROM shein_jewlery_and_accessories
UNION ALL
SELECT * FROM shein_kids
UNION ALL
SELECT * FROM shein_mens_clothes
UNION ALL
SELECT * FROM shein_shoes
UNION ALL
SELECT * FROM shein_sports_and_outdoors
UNION ALL
SELECT * FROM shein_swimwear
UNION ALL
SELECT * FROM shein_womens_clothing
UNION ALL
SELECT * FROM shein_underwear_and_sleepwear;

-- INITIAL CHECK
SELECT * FROM shein_merged_categories;

--  DATA CLEANING: Fix inconsistent 'rank_sub' for accessories

-- Check affected rows (optional)
SELECT rank_sub FROM shein_merged_categories
WHERE rank_sub REGEXP 'accessory'
OR rank_sub REGEXP 'accessories'
;

-- Update the inconsistent value
UPDATE shein_merged_categories
SET rank_sub = 'accessories'
WHERE rank_sub = 'accessory';

SELECT rank_sub, goods_title FROM shein_merged_categories
WHERE goods_title REGEXP '\\S+ clips|\\S+ sunglasses|\\S+ bracelet|\\S+ hair' AND goods_title 
NOT REGEXP "tshirt|shirt|sleeve|short|printed|top|dress"
AND rank_sub REGEXP 'clothing';

-- Update the inconsistent value
UPDATE shein_merged_categories
SET rank_sub = 'accessories'
WHERE goods_title REGEXP '\\S+ clips|\\S+ sunglasses|\\S+ bracelet|\\S+ hair' AND goods_title
NOT REGEXP "tshirt|shirt|sleeve|short|printed|top|dress" AND rank_sub REGEXP 'clothing';

-- Final check after merging and cleaning
SELECT * FROM shein_merged_categories;

		## EDA ##
-- summery statistics / descriptive statistics

-- Summary Statistics: Averages
SELECT
-- checking avg
	ROUND(AVG(selling_proposition),2) AS 'average_selling-proposition',
    ROUND(AVG(price),2) AS 'average_price' ,
    ROUND(AVG(discount),2) AS 'average_discount' ,
    ROUND(AVG(rank_title),2) AS 'average_rating',
    ROUND(AVG(color_count),2) AS 'average_color_count'  
FROM shein_merged_categories;

-- Summary Statistics: Min/Max Values
SELECT
-- checking min max values
	ROUND(MAX(selling_proposition), 2) AS "MAX_selling_proposition",
    ROUND(MIN(selling_proposition), 2) AS "MIN_selling_proposition",
    ROUND(MAX(price), 2) AS "MAX_price",
    ROUND(MIN(price), 2) AS "MIN_price",
    ROUND(MAX(discount), 2) AS "MAX_discount",
    ROUND(MIN(CASE WHEN discount > 0 THEN discount END), 2) AS "MIN_discount",
    ROUND(MAX(rank_title), 2) AS "MAX_rank_title", -- Corrected typo from 'MAX_ratin'
    ROUND(MIN(rank_title), 2) AS "MIN_rank_title",
    ROUND(MAX(color_count), 2) AS "MAX_color_count",
    ROUND(MIN(color_count), 2) AS "MIN_color_count"
FROM shein_merged_categories;

-- Summary Statistics: Standard Deviation (Population)
SELECT
-- checking Standard Deviation  values
    -- Standard Deviation (Population) for continuous variables
    ROUND(STDDEV_POP(selling_proposition), 2) AS STD_selling_proposition,
    ROUND(STDDEV_POP(price), 2) AS STD_price,
    ROUND(STDDEV_POP(discount), 2) AS STD_discount,

    -- STDDEV for rank and count metrics
    ROUND(STDDEV_POP(rank_title), 2) AS STD_rank_title,
    ROUND(STDDEV_POP(color_count), 2) AS STD_color_count
FROM
    shein_merged_categories;

-- Summary Statistics: 68% Range (AVG +/- STD DEV)
-- This combines the AVG and STD DEV calculations for key metrics.
SELECT 
	'selling_proposition' AS 'statistics',
	ROUND(AVG(selling_proposition) - STDDEV_POP(selling_proposition), 2) AS 'lower_68_range',
    ROUND(STDDEV_POP(selling_proposition), 2) AS 'STD_value',
    ROUND(AVG(selling_proposition) + STDDEV_POP(selling_proposition), 2) AS 'upper_68_range',
    ROUND(AVG(selling_proposition),2) AS 'average'
FROM shein_merged_categories
WHERE selling_proposition IS NOT NULL

UNION ALL

SELECT
	'price' AS 'statistics',
	ROUND(AVG(price) - STDDEV_POP(price), 2) AS 'lower_68_range',
    ROUND(STDDEV_POP(price), 2) AS 'STD_value',
    ROUND(AVG(price) + STDDEV_POP(price), 2) AS 'upper_68_range',
    ROUND(AVG(price),2) AS 'average'
FROM shein_merged_categories
WHERE price IS NOT NULL

UNION ALL

SELECT
	'discount' AS 'statistics',
	ROUND(AVG(discount) - STDDEV_POP(discount), 2) AS 'lower_68_range',
    ROUND(STDDEV_POP(discount), 2) AS 'STD_value',
    ROUND(AVG(discount) + STDDEV_POP(discount), 2) AS 'upper_68_range',
    ROUND(AVG(discount),2) AS 'average'
FROM shein_merged_categories
WHERE discount > 0

UNION ALL

SELECT
	'rank_title' AS 'statistics',
	ROUND(AVG(rank_title) - STDDEV_POP(rank_title), 2) AS 'lower_68_range',
    ROUND(STDDEV_POP(rank_title), 2) AS 'STD_value',
    ROUND(AVG(rank_title) + STDDEV_POP(rank_title), 2) AS 'upper_68_range',
    ROUND(AVG(rank_title),2) AS 'average'
FROM shein_merged_categories
WHERE rank_title IS NOT NULL

UNION ALL

SELECT
	'color_count' AS 'statistics',
	ROUND(AVG(color_count) - STDDEV_POP(color_count), 2) AS 'lower_68_range',
    ROUND(STDDEV_POP(color_count), 2) AS 'STD_value',
    ROUND(AVG(color_count) + STDDEV_POP(color_count), 2) AS 'upper_68_range',
    ROUND(AVG(color_count),2) AS 'average'
FROM shein_merged_categories
WHERE color_count IS NOT NULL;
-- note 'selling_proposition' has High Variability thats why we need to check for median +
-- selling_proposition is likely skewed
 
-- Median Calculation for selling_proposition (Due to potential skew/high variability)
WITH ordered_data AS( 
	SELECT
		selling_proposition,
		ROW_NUMBER() OVER(ORDER BY selling_proposition ASC) AS row_num,
        COUNT(*) OVER() AS r
	FROM shein_merged_categories
	WHERE selling_proposition IS NOT NULL),

MEDIAN AS (
	SELECT
		selling_proposition
	FROM ordered_data
		WHERE row_num IN (FLOOR((r+1)/2), CEIL((r+1)/2))
)
SELECT
	ROUND(AVG(selling_proposition),1) AS 'Median' 
 FROM MEDIAN;


		## QUESTIONG TO ANSWER ##
## 1. Which gender-specific items in 'shein kids' have the highest selling_proposition relative to price, indicating value-for-money winners?
    
WITH value_scores AS (
    SELECT 
        rank_sub,
        specific_gender,
        goods_title,
        price,
        selling_proposition,
        
        -- How many units do I sell per dollar of price?
        (selling_proposition / price) as 'units_per_price' , -- volume efficiency
        
        -- Rank the highest volume per specific gender
        ROW_NUMBER() OVER (PARTITION BY specific_gender ORDER BY (selling_proposition / price) DESC) AS rn
        
    FROM shein_merged_categories
    WHERE category = 'shein kids'
        AND price > 0
        AND selling_proposition IS NOT NULL
)
SELECT 
    rank_sub,
    specific_gender,
    goods_title,
    price,
    selling_proposition,
    ROUND(units_per_price,2) 'units_per_price' -- volume efficiency
FROM value_scores
WHERE rn BETWEEN 1 AND 10 -- Filter for the highest efficiency item per specific gender
ORDER BY units_per_price DESC;
/*
return on investment conclusion:
	We need to commit more strongly to girls’ accessories
	Expand unisex offerings
    reduce "women" items in kids category
*/


-- 2. Do items with higher color_count (>6) show stronger engagement (selling_proposition) in 'baby & maternity' for 'girls' vs. 'boys'?
WITH cleaned AS (
    SELECT
        specific_gender,
        selling_proposition,
        CASE
            WHEN color_count <= 6 THEN 'Medium 4-6'
            ELSE 'High >6'
        END AS variety_tier
    FROM shein_merged_categories
    WHERE category = 'baby & maternity' 
      AND specific_gender IN ('girls', 'boys')
      AND selling_proposition IS NOT NULL
      AND color_count IS NOT NULL
      AND color_count > 0
),

ranked AS (
    SELECT
        specific_gender,
        variety_tier,
        selling_proposition,
        ROW_NUMBER() OVER (PARTITION BY specific_gender, variety_tier ORDER BY selling_proposition) AS rn,
        COUNT(*) OVER (PARTITION BY specific_gender, variety_tier) AS cnt
    FROM cleaned
),

middle AS (
    SELECT
        specific_gender,
        variety_tier,
        selling_proposition
    FROM ranked
    WHERE rn IN (FLOOR((cnt + 1)/2), CEIL((cnt + 1)/2))
)

SELECT
    specific_gender,
    variety_tier,
    ROUND(AVG(selling_proposition), 0) AS median_engagement
FROM middle
GROUP BY specific_gender, variety_tier
ORDER BY
    specific_gender;
    
/* conclusion:
	color_count that higher than 6
	has nearly the same engagement/buyers
*/ 

-- 3. In 'swimwear' and 'underwear' subcategories, which gender segments have the lowest discount but highest selling_proposition, suggesting untapped premium potential?
WITH clean AS(SELECT
	rank_sub,
    gender,
    selling_proposition,
    CASE
		WHEN discount < 0.10 THEN 'low(<10%)'
        ELSE 'high(>10%)'
	END AS discount_range
FROM shein_merged_categories
WHERE
	rank_sub IN ('swimwear','underwear')
	AND
    selling_proposition IS NOT NULL
    AND 
    discount > 0),
ranked AS(
	SELECT
		rank_sub,
		gender,
        discount_range,
        selling_proposition,
        ROW_NUMBER() OVER(PARTITION BY rank_sub, gender, discount_range ORDER BY selling_proposition) rn,
        COUNT(*) OVER (PARTITION BY rank_sub, gender, discount_range) AS cnt
	FROM clean),
median AS (
	SELECT 
		rank_sub,
		gender,
        discount_range,
        selling_proposition
	FROM ranked
	WHERE rn IN (FLOOR((cnt + 1)/2), CEIL((cnt + 1)/2))
)
SELECT
	rank_sub,
	gender,
	discount_range,
	ROUND(AVG(selling_proposition),2) median_engagement
FROM median
WHERE discount_range = 'low(<10%)'
GROUP BY rank_sub, gender, discount_range
ORDER BY median_engagement DESC;

-- 4. Are there hidden winners? Low-priced products with top quality rank (rate = 1 or 2) and high engagement (selling_proposition) — ideal for bundling or promotion?

-- Note on Rank Title data availability
SELECT count(*), COUNT(*) - (SELECT COUNT(rank_title) FROM shein_merged_categories WHERE rank_title IS NOT NULL) AS null_count, 
 (SELECT COUNT(rank_title) FROM shein_merged_categories WHERE rank_title IS NOT NULL) AS not_null_count  FROM shein_merged_categories
;

/* in order to know what high engagement is
we need to know the median, which ive found above (600- 50%),
from there i want to know what value is above 75%. */
 
WITH ranked AS (
    SELECT
        selling_proposition,
        ROW_NUMBER() OVER (ORDER BY selling_proposition) AS rn,
        COUNT(*) OVER () AS cnt
    FROM shein_merged_categories
    WHERE selling_proposition IS NOT NULL
),
-- Find P75 for selling_proposition (Threshold for 'High Engagement')
p75_row AS (
    SELECT
        selling_proposition AS p75
    FROM ranked
    WHERE rn = CEIL(0.75 * cnt)
)
SELECT ROUND(p75, 0) AS p75
FROM p75_row;
/* 1600 and above are the highest values from selling_proposition 75-100%)*/

-- Find P25 for price (Threshold for 'low Engagement')
WITH ranked AS (
    SELECT price,
           ROW_NUMBER() OVER (ORDER BY price) AS rn,
           COUNT(*) OVER () AS cnt
    FROM shein_merged_categories
    WHERE price IS NOT NULL
),
p25_row AS (
    SELECT price AS p25
    FROM ranked
    WHERE rn = CEIL(0.25 * cnt)
)
SELECT ROUND(p25, 2) AS p25 FROM p25_row;

-- Final Query: Hidden Winners
SELECT
	rank_sub,
	goods_title,
    rank_title,
    price,
    selling_proposition
FROM shein_merged_categories
WHERE price < 4.9
AND rank_title IN (1,2)
AND rank_title IS NOT NULL
AND selling_proposition IS NOT NULL
AND selling_proposition > 1600
ORDER BY price ASC;

-- 5. Can we identify underpenetrated niches? E.g., high average price + low competition (few products) + high rating = premium opportunity?
WITH stats AS(
	SELECT
		rank_sub,
        COUNT(*) AS item_cnt,
        ROUND(AVG(price),2) AS avg_price,
        
        -- Calculate the percentage of items with top rank (1 or 2) within each subcategory
        ROUND(100 * SUM(CASE WHEN rank_title IN (1,2) THEN 1 ELSE 0 END) / COUNT(*),1) top_rank
        FROM shein_merged_categories
        WHERE rank_title IS NOT NULL -- Limit analysis to items with quality rank data
        GROUP BY rank_sub
),
-- Calculate P75 for Average Price (High Price Threshold)
avg_order AS (
	SELECT avg_price, ROW_NUMBER() OVER(ORDER BY avg_price) AS rn1, COUNT(*) OVER() AS r1 FROM stats
),
-- Calculate P25 for Item Count (Low Competition Threshold)
item_order AS (
	SELECT item_cnt, ROW_NUMBER() OVER(ORDER BY item_cnt) AS rn2, COUNT(*) OVER() AS r2 FROM stats
),
the_limit AS (
	SELECT
		(SELECT avg_price FROM avg_order WHERE rn1 = CEIL(r1 * 0.75)) AS p75_higher,
        (SELECT item_cnt FROM item_order WHERE rn2 = CEIL(r2 * 0.25)) AS p25_lower
)
SELECT
	s.rank_sub,
    s.avg_price,
    s.item_cnt,
    s.top_rank
FROM stats s, the_limit tl
WHERE s.avg_price >= tl.p75_higher
AND s.item_cnt <= tl.p25_lower
;