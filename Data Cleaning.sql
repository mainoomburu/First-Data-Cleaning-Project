-- DATA CLEANING --

-- The first step is to create a staging table for our imported table --
create table layoffs_staging
like layoffs;

-- we now check if the table has been created and has similar columns --
select *
from layoffs_staging;

-- next we insert the data into the new table --
insert layoffs_staging
select*
from layoffs;

-- The first step in data cleaning is checking for duplicates and removing duplicates from our table --
-- we will use and implement a window function row number to give each unique row a number --
select*,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_namba
from layoffs_staging;

-- we use a filter to check if any row number has a value other than 1, as a 2 is a duplicate --
-- we use a CTE for this --
with duplicate_rows as(
select*,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_namba
from layoffs_staging
)
select*
from duplicate_rows
where row_namba > 1;

-- Since we cannot update a CTE, its best practice to create another staging table where we can add a new column of row number --
-- then we can update that table --
create table layoffs_staging_update
like layoffs_staging;

alter table layoffs_staging_update
add column row_namba int;

select*
from layoffs_staging_update;

-- now we insert data into our newly created table --
insert into layoffs_staging_update
select*,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_namba
from layoffs_staging;

-- we can now check to see if we can filter our table --
select*
from layoffs_staging_update
where row_namba > 1;

-- we now delete these rows --
delete
from layoffs_staging_update
where row_namba > 1;

-- Standardizing data --
-- Finding issues in your data and fixing it --
-- In this stage, we run, column by column looking for issues within the table --
select*
from layoffs_staging_update;

-- Company column --
select distinct company
from layoffs_staging_update;

select company, trim(company)
from layoffs_staging_update;

update layoffs_staging_update
set company = trim(company);

-- location column --
select distinct location
from layoffs_staging_update
order by 1;

-- industry column --
select distinct industry
from layoffs_staging_update
order by 1;

select*
from layoffs_staging_update
where industry like 'crypto%';

update layoffs_staging_update
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct industry
from layoffs_staging_update
order by 1;

-- We only note this for now as the next step after standardizing is working on the blank and null values --
select*
from layoffs_staging_update
where industry = '';

-- Country column --
select distinct country
from layoffs_staging_update
order by 1;

select distinct country
from layoffs_staging_update
where country like 'United States%';

update layoffs_staging_update
set country = 'United States'
where country like 'United States%';

-- Date column --
-- In this column we change it from a text data type to date --
select `date`,
str_to_date(`date`, '%m/%d/%Y')
from layoffs_staging_update;

update layoffs_staging_update
set `date` = str_to_date(`date`, '%m/%d/%Y');

-- We can now change our date column to date data type --
alter table layoffs_staging_update
modify column `date` date;

select*
from layoffs_staging_update;

-- Now we drop our row number column --
alter table layoffs_staging_update
drop column row_namba;

-- REMOVING NULLS --
-- in our industry column, there were some rows with missing values --
select distinct industry
from layoffs_staging_update
where industry is null
or industry = '';

-- next we check these rows --
-- we check each returned row's value seperately to see if there might have been an ommission of data --
select *
from layoffs_staging_update
where industry is null
or industry = '';

select*
from layoffs_staging_update
where company = 'Airbnb';

select*
from layoffs_staging_update
where company like '%Interactive';

select*
from layoffs_staging_update
where company = 'Carvana';

select*
from layoffs_staging_update
where company = 'Juul';

-- so we use a self join to try and populate these blanks --
-- so first we set the blank rows to null
update layoffs_staging_update
set industry = null
where industry = '';

select A.industry, B.industry
from layoffs_staging_update as A
join layoffs_staging_update as B
	on A.company = B.company
    and A.location = B.location
where (A.industry is null or A.industry = '')
and B.industry is not null;

update layoffs_staging_update as A
join layoffs_staging_update as B
	on A.company = B.company
    and A.location = B.location
set A.industry = B.industry
where (A.industry is null or A.industry = '')
and B.industry is not null;

-- next we remove the null values --
select *
from layoffs_staging_update
where total_laid_off is null
and percentage_laid_off is null;

-- since we do not have the total values to be able to populate these columns, we remove them as we can not use this data in our exploratory data analysis --
delete
from layoffs_staging_update
where total_laid_off is null
and percentage_laid_off is null;

-- Now we check if the changes have been effected to our table --
select*
from layoffs_staging_update;

-- Exploring our data

select*
from layoffs_staging_update;

-- we first try to see the maximum number of total laid off employees by a company
select max(total_laid_off), max(percentage_laid_off)
from layoffs_staging_update;

-- next we try to check which companies laid off the most people
-- in this case if a company had a percentage laid off of 1, that means it laid off everybody even if we do not have the total laid off value
select*
from layoffs_staging_update
where percentage_laid_off = 1;

-- this allows us to order our table to identify which company went under with the most total laid off
select*
from layoffs_staging_update
where percentage_laid_off = 1
order by total_laid_off desc;

-- this allows us to identify which company had raised the most amount of money but still went under
select*
from layoffs_staging_update
where percentage_laid_off = 1
order by funds_raised_millions desc;

-- now we try to understand which company laid off more people across the dataset
select company, sum(total_laid_off) as sum_of_total_laid_off
from layoffs_staging_update
group by company
order by sum_of_total_laid_off desc;

-- now we try to understand the date range of our data
select min(`date`), max(`date`)
from layoffs_staging_update;

-- we now check which industry had the most laid off
select industry, sum(total_laid_off) as sum_total_laid_off
from layoffs_staging_update
group by industry
order by sum_total_laid_off desc;

-- we try to check which country had the most laid off
select country, sum(total_laid_off) as sum_total_laid_off
from layoffs_staging_update
group by country
order by sum_total_laid_off desc;

-- we check which stage had the most laid off
select stage, sum(total_laid_off) as sum_total_laid_off
from layoffs_staging_update
group by stage
order by sum_total_laid_off desc;

-- we now try to understand which year had the highest laid off 
select year(`date`) as years, sum(total_laid_off) as sum_total_laid_off
from layoffs_staging_update
group by year(`date`)
order by years desc;

-- we now try to understand the progression of lay offs
