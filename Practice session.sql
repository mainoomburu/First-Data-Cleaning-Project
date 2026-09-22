-- The first step in cleaning a data is arranging the process in what you will do --
-- Step 1: Removing duplicates 
-- Step 2: Standardizing the data
-- Step 3: Removing nulls

-- Before removing the duplicates, its important that we create a new table where we can manipulate the data
-- We do this to have a fallback and a reference as our source data should not be changed
create table working_layoffs
like layoffs;

-- we then check if the table columns have been added and are similar
select*
from working_layoffs;

-- we insert now the data
insert into working_layoffs
select*
from layoffs;

-- we check if the rows have been inserted
select*
from working_layoffs;

-- so to discover the duplicates, we create a new row 
-- to do this, we use a window function
select*,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_namba
from working_layoffs;

with duplicates as (
select*,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_namba
from working_layoffs
)
select*
from duplicates;

-- to find the duplicates, we check the row number column and check for any row with a value greater than 1
-- each row is given a unique row number
with duplicates as (
select*,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_namba
from working_layoffs
)
select*
from duplicates
where row_namba > 1;

-- since we cannot alter a table using window functions or common table expressions
-- we create a new table where we will manipulate the table
create table working_layoffs_update
like working_layoffs;

select*
from working_layoffs_update;

alter table working_layoffs_update
add column row_namba int;

-- now we insert data
insert into working_layoffs_update
select*,
row_number() over(partition by company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions) as row_namba
from working_layoffs;

select*
from working_layoffs_update;

-- to find the duplicates
select*
from working_layoffs_update
where row_namba > 1;

delete
from working_layoffs_update
where row_namba > 1;

-- after we go to the second major step of standardizing the data
-- to do this we have to go column by column, row by row to see the major issues we need to identify and sort them out
select distinct company
from working_layoffs_update;

update working_layoffs_update
set company = trim(company);

select distinct location
from working_layoffs_update;

select distinct industry
from working_layoffs_update;

-- in the industry column we notice a blank row
-- we set it to null 
update working_layoffs_update
set industry = null
where industry = '';

update working_layoffs_update
set industry = 'Crypto'
where industry like 'Crypto%';

select distinct country
from working_layoffs_update;

update working_layoffs_update
set country = 'United States'
where country like 'United States%';

-- next we try to change the date column from text field to date
select distinct `date`,
str_to_date(`date`, '%m/%d/%Y') as new_date
from working_layoffs_update;

update working_layoffs_update
set `date` = str_to_date(`date`, '%m/%d/%Y');

alter table working_layoffs_update
modify column `date` date;

-- next we remove the row number column as it has already helped us identify the duplicates
alter table working_layoffs_update
drop column row_namba;

-- the next major step is to remove the nulls
-- in this instance we start with the industry column since we had a blank row which we populated as null
select A.industry, B.industry
from working_layoffs_update as A
join working_layoffs_update as B
	on A.company = B.company
    and A.location = B.location
where A.industry is null
and B.industry is not null;

-- so we try to populate these distinct rows
update working_layoffs_update as A
join working_layoffs_update as B
	on A.company = B.company
    and A.location = B.location
set A.industry = B.industry
where A.industry is null
and B.industry is not null;

-- now we check if we have nulls in this column
select A.industry, B.industry
from working_layoffs_update as A
join working_layoffs_update as B
	on A.company = B.company
    and A.location = B.location
where A.industry is null
and B.industry is not null;

-- next we work on the total laid off column and percentage
select*
from working_layoffs_update
where total_laid_off is null
and percentage_laid_off is null;

-- we remove these as they will not help us work on our exploratory data analysis
delete
from working_layoffs_update
where total_laid_off is null
and percentage_laid_off is null;

-- now these shows our cleaned data
select*
from working_layoffs_update;
