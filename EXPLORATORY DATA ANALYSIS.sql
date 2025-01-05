USE world_layoffs;

-- EXPLORATORY DATA ANALYSIS

SELECT *
FROM layoffs_staging2;

SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging2;

-- Look at the companies had 100% laid off
SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
ORDER BY total_laid_off DESC;
-- Mostly like the startups who went out of business

-- Total laid off of companies
SELECT company, SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company
ORDER BY 2 DESC;
-- The most highest of total laid off is Intel

-- Timeline of the dataset 
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging2;
-- This is 1 year period from mid 2023 to mid 2024

-- Look at which industry had the most laid off 
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY industry
ORDER BY 2 DESC
LIMIT 10;
-- Transportation had the highest total laid off during the time period 

-- Look at which country had the most laid off 
SELECT country, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY country
ORDER BY 2 DESC
LIMIT 10;
-- United States had fairly the most total laid off

-- Look at which year had the most laid off 
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY YEAR(`date`)
ORDER BY 2 DESC;
-- 2024 had the highest number of total laid off


-- Rolling total of layoffs per month
SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off)
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC;

WITH Rolling_Total AS 
(SELECT SUBSTRING(`date`,1,7) AS `MONTH`, SUM(total_laid_off) AS total_off
FROM layoffs_staging2
GROUP BY `MONTH`
ORDER BY 1 ASC
)
SELECT `MONTH`, total_off, SUM(Total_off) OVER (ORDER BY  `MONTH`) AS rolling_total
FROM Rolling_Total;

-- Look at total laid off of each company per year
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
ORDER BY 3 DESC;


WITH Company_Year (company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY company, YEAR(`date`)
), Company_Year_Rank AS 
(SELECT*, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Company_Year
ORDER BY Ranking ASC
)
SELECT *
FROM Company_Year_Rank
WHERE Ranking <=5;


-- Look at total laid off of each country per year
SELECT country, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country, YEAR(`date`)
ORDER BY 3 DESC;


WITH Country_Year (country, years, total_laid_off) AS
(
SELECT country, YEAR(`date`), SUM(total_laid_off) 
FROM layoffs_staging2
GROUP BY country, YEAR(`date`)
), Country_Year_Rank AS 
(SELECT*, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM Country_Year
ORDER BY Ranking ASC
)
SELECT *
FROM Country_Year_Rank
WHERE Ranking <=3;









