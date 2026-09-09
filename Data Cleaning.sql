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
