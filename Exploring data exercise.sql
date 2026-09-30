-- with exploratory data analysis, we try to understand the data that we cleaned and see if we can come to some conclusion
-- the first step is to try to make sense of the data

-- the first step is to understand the range of years for our data
select min(`date`) as min_date, max(`date`) as max_date
from layoffs_staging_update;

-- the second step is to try to understand what is the highest number of laid offs
select max(total_laid_off)
from layoffs_staging_update;

-- the third step is to try to understand which company had the most laid offs
select*
from layoffs_staging_update
where total_laid_off = 12000;

-- next we try to check which company had a percentage laid off of 1, that means a 100% laid off
select*
from layoffs_staging_update
where percentage_laid_off = 1;

-- with the above, we can now try to explore more this data to know a few key things
-- in this instance we check which company had the most laid off in that it had a 100% laid off, everyone was sacked
select*
from layoffs_staging_update
where percentage_laid_off = 1
order by total_laid_off desc; 

-- next we try to sort by the company that raised the highest amount of money and laid off everybody
select*
from layoffs_staging_update
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- we also try to sort by the industry to see which industry laid off the most but still had a 100% lay off
select industry, sum(total_laid_off) as total
from layoffs_staging_update
where percentage_laid_off = 1
group by industry
order by total desc;

-- we can also check all industries to see which industry had the most laid off without a 100% layoff to compare with companies that had a laid off of 100%
select industry, sum(total_laid_off) as total
from layoffs_staging_update
group by industry
order by total desc;

-- we sort the country with the most laid off but with a 100% laid off
select country, sum(total_laid_off) as total
from layoffs_staging_update
where percentage_laid_off = 1
group by country
order by total desc;

-- sorting the country with the most laid off to compare with countries that had a 100% laid off
select country, sum(total_laid_off) as total
from layoffs_staging_update
group by country
order by total desc;

-- we can check which company raised the highest amount of money
select company, sum(funds_raised_millions) as funds_millions
from layoffs_staging_update
group by company
order by funds_millions desc;

-- we now check which industry raised the most money
select industry, sum(funds_raised_millions) as funds_millions
from layoffs_staging_update
group by industry
order by funds_millions desc;

-- we now check which country raised the most money
select country, sum(funds_raised_millions) as funds_millions
from layoffs_staging_update
group by country
order by funds_millions desc;

-- now we sort by years to understand which year had the most amount raised
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
