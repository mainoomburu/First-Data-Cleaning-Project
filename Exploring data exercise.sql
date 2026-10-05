-- with exploratory data analysis, we try to understand the data that we cleaned and see if we can come to some conclusion
-- the first step is to try to make sense of the data

-- 1. understand the range of years for our data
select min(`date`) as min_date, max(`date`) as max_date
from layoffs_staging_update;

-- 2. try to understand what is the highest number of laid offs
select max(total_laid_off)
from layoffs_staging_update;

-- 3. try to understand which company had the most laid offs
select*
from layoffs_staging_update
where total_laid_off = 12000;

-- 4. check which company had a percentage laid off of 1, that means a 100% laid off
select*
from layoffs_staging_update
where percentage_laid_off = 1;

-- with the above, we can now try to explore more this data to know a few key things
-- 5. check which company had the most laid off in that it had a 100% laid off, everyone was sacked
select*
from layoffs_staging_update
where percentage_laid_off = 1
order by total_laid_off desc; 

-- 6. sort by the company that raised the highest amount of money and laid off everybody
select*
from layoffs_staging_update
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- 7. sort by the industry to see which industry laid off the most but still had a 100% lay off
select industry, sum(total_laid_off) as total
from layoffs_staging_update
where percentage_laid_off = 1
group by industry
order by total desc;

-- 8. check all industries to see which industry had the most laid off without a 100% layoff to compare with companies that had a laid off of 100%
select industry, sum(total_laid_off) as total
from layoffs_staging_update
group by industry
order by total desc;

-- 9. sort the country with the most laid off but with a 100% laid off
select country, sum(total_laid_off) as total
from layoffs_staging_update
where percentage_laid_off = 1
group by country
order by total desc;

-- 10. sorting the country with the most laid off to compare with countries that had a 100% laid off
select country, sum(total_laid_off) as total
from layoffs_staging_update
group by country
order by total desc;

-- 11. check which company raised the highest amount of money
select company, sum(funds_raised_millions) as funds_millions
from layoffs_staging_update
group by company
order by funds_millions desc;

-- 12. check which industry raised the most money
select industry, sum(funds_raised_millions) as funds_millions
from layoffs_staging_update
group by industry
order by funds_millions desc;

-- 13. check which country raised the most money
select country, sum(funds_raised_millions) as funds_millions
from layoffs_staging_update
group by country
order by funds_millions desc;

-- 14. sort by years to understand which year had the most amount raised
-- we use the year() inbuilt function to seperate the months and days from the date
select year(`date`) as years, sum(funds_raised_millions) as total_millions
from layoffs_staging_update
group by years
order by total_millions desc;

-- we now can check across the years which country had the highest laid off
select year(`date`) as years, country, sum(total_laid_off) as total_laid
from layoffs_staging_update
group by years, country
order by total_laid desc;

-- we now compate this data with countries that laid off everybody
select year(`date`) as years, country, sum(total_laid_off) as total_laid
from layoffs_staging_update
where percentage_laid_off = 1
group by years, country
order by total_laid desc;

-- we now check the companies that laid off more people
select year(`date`) as years, company, sum(total_laid_off) as total_laid
from layoffs_staging_update
group by years, company
order by total_laid desc;

select year(`date`) as years, company, sum(funds_raised_millions) as total_funds
from layoffs_staging_update
group by years, company
order by total_funds desc;

-- now we will use CTEs to explore the data deeper
-- in this instance, we try to understand and see the total laid off across the months in a year
-- we want each year to show how many laid off occured in each month
-- so first we try to extract the month
select substring(`date`, 6,2) as `Month`
from layoffs_staging_update;

-- next that we know positionally the value of month
select substring(`date`, 1,7) as `Month`
from layoffs_staging_update;

-- we sort the number of laid offs from the beginning of our data set to the end 
select substring(`date`, 1,7) as `Month`, sum(total_laid_off) as total_off
from layoffs_staging_update
where substring(`date`, 1,7) is not null
group by `Month`
order by `Month` asc;

-- but still we would love to understand how the lay offs progressed as the months went by
-- to do this, we use a common table expression
with rolling_total as 
(
select substring(`date`, 1,7) as `Month`, sum(total_laid_off) as total_off
from layoffs_staging_update
where substring(`date`, 1,7) is not null
group by `Month`
order by `Month` asc
)
select `Month`, total_off, sum(total_off) over(order by `Month`) as roll_total
from rolling_total;

-- now we try to understand the total laid off for companies by year

select company, year(`date`) as years, sum(total_laid_off) as total_laid
from layoffs_staging_update
where year(`date`) is not null
group by company, years
order by company;

-- we now try to rank which companies laid off more employees across the years by showing the top 5 companies that laid off employees year by year
with yearly_layoffs as
(
select company, year(`date`) as years, sum(total_laid_off) as total_laid
from layoffs_staging_update
where year(`date`) is not null
group by company, years
),
yearly_ranking_layoff as
(
select*, 
dense_rank() over(partition by years order by total_laid desc) as ranking
from yearly_layoffs
)
select*
from yearly_ranking_layoff
where ranking <= 5;

-- country layoffs
-- before creating a CTE its best practice to first run the function you want to place inside your CTE
select country, year(`date`) as years, sum(total_laid_off) as total_laid_off
from layoffs_staging_update
group by country, years
order by country;

with country_layoffs as
(
select country, year(`date`) as years, sum(total_laid_off) as total_laid_off
from layoffs_staging_update
where year(`date`) is not null
group by country, years
),
country_ranking as
(
select*,
dense_rank() over(partition by years order by total_laid_off desc) as ranking
from country_layoffs
)
select*
from country_ranking
where ranking <= 5;

-- total funds raised by country
select country, year(`date`) as years, sum(funds_raised_millions) as total_cash
from layoffs_staging_update
group by country, years
order by country;

with country_layoffs as
(
select country, year(`date`) as years, sum(funds_raised_millions) as total_cash
from layoffs_staging_update
where year(`date`) is not null
group by country, years
),
country_ranking as
(
select*,
dense_rank() over(partition by years order by total_cash desc) as ranking
from country_layoffs
)
select*
from country_ranking
where ranking <= 5;
