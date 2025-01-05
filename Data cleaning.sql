-- DATA SOURCE 
`https://www.kaggle.com/datasets/swaptr/layoffs-2022`

USE world_layoffs;

-- DATA CLEANING

SELECT *
FROM layoffs;

-- Remove duplicate
-- Standardise the data
-- Null values/ Blank values
-- Remove any columns/ rows

-- Create a staging table to work and clean the data
Create table layoffs_staging 
Like layoffs;

Insert layoffs_staging
Select *
From layoffs;


Select * FROM layoffs_staging;

-- Remove duplicate - check if there is any duplicate
SELECT * 
FROM layoffs_staging;


WITH duplicate_cte AS
(
SELECT *, 
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised) AS row_num
FROM layoffs_staging
)
SELECT *
FROM duplicate_cte
WHERE row_num>1;


CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` text,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised` double DEFAULT NULL, 
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

INSERT INTO layoffs_staging2
SELECT *,
ROW_NUMBER() OVER(
PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country,
funds_raised) AS row_num
FROM layoffs_staging;


SET SQL_SAFE_UPDATES = 0;

DELETE 
FROM layoffs_staging2
WHERE row_num > 1;

SELECT * 
FROM layoffs_staging2;


-- Standardising data

SELECT company, TRIM(company)
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET company = TRIM(company);


SELECT *
FROM layoffs_staging2
WHERE industry LIKE 'Crypto%';


UPDATE layoffs_staging2
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';


SELECT DISTINCT country
FROM layoffs_staging2
ORDER BY 1;

SELECT DISTINCT country, TRIM(TRAILING '.' FROM country)
FROM layoffs_staging2
ORDER BY 1;

UPDATE layoffs_staging2
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';


-- Format date column
SELECT `date`,
STR_TO_DATE(`date`,'%Y-%m-%d')
FROM layoffs_staging2;

UPDATE layoffs_staging2
SET `date` = STR_TO_DATE(`date`,'%Y-%m-%d');

ALTER TABLE layoffs_staging2
MODIFY COLUMN `date` DATE;


-- POPULATE NULL DATA 
SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL
AND percentage_laid_off IS NULL;


SELECT *
FROM layoffs_staging2
WHERE industry IS NULL
OR industry = ' ';

UPDATE layoffs_staging2
SET industry = NULL
WHERE industry = ' ';

SELECT *
FROM layoffs_staging2 t1
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = ' ')
AND t2.industry IS NOT NULL;

UPDATE layoffs_staging2 t1 
JOIN layoffs_staging2 t2
	ON t1.company = t2.company
SET t1.industry  = t2.industry
WHERE t1.industry IS NULL 
AND t2.industry IS NOT NULL;

DESCRIBE layoffs_staging2;


SELECT total_laid_off, LENGTH(total_laid_off) 
FROM layoffs_staging2 
WHERE total_laid_off IS NOT NULL;

UPDATE layoffs_staging2
SET total_laid_off = NULL
WHERE total_laid_off = '' 
OR total_laid_off = '0' 
OR TRIM(total_laid_off) = '';

UPDATE layoffs_staging2
SET percentage_laid_off = NULL
WHERE percentage_laid_off = '' 
OR percentage_laid_off = '0' 
OR TRIM(percentage_laid_off) = '';

SELECT *
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

DELETE 
FROM layoffs_staging2
WHERE total_laid_off IS NULL 
AND percentage_laid_off IS NULL;

ALTER TABLE layoffs_staging2
DROP COLUMN row_num;

SELECT *
FROM layoffs_staging2;


