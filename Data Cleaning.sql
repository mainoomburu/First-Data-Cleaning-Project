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

-- now we check for duplicate data in our table --
-- we will use and implement a row number to give each unique row a number --
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
