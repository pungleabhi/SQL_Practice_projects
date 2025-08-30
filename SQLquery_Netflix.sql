-- Netflix Database

create database sql_project_p3;
use sql_project_p3;

drop table if exists netflix;
create table netflix
(show_id varchar(6),
type varchar(10),
title varchar(150),
director varchar(210),
casts Text,
country varchar(123),
date_added varchar(50),
release_year varchar(100),
rating varchar(100),
duration varchar(15),
listed_in varchar(255),
description text
);

LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/netflix_titles.csv'
INTO TABLE netflix
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"' 
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(show_id, type, title, director, casts, country, date_added, release_year, rating, duration, listed_in, description);

SHOW VARIABLES LIKE 'secure_file_priv';


select director from netflix where show_id = 's2';
-- set the empty fields as null
SELECT * 
FROM netflix
WHERE director = '' OR country = '';
UPDATE netflix
SET rating= NULL
WHERE rating = '';

select * from netflix;
select count(*) from netflix;
select distinct type from netflix;

-- Busuness problems

-- 1. Count the number of Movies vs TV shows
 select * from netflix;
select type, count(*)
from netflix
group by type;

-- 2. Find the most common rating for movies and TV shows
select type , rating
from
(
	select type,rating,count(*),
	rank() over(partition by type order by count(*)desc) as ranking
	from netflix
	group by type, rating
    ) as t1
where ranking = 1;
-- order by type,count(*) desc;

-- 3. List all movies released in a specific year (e.g., 2020)
select release_year , title
from netflix
where type = 'Movie' and
release_year = '2020';

-- //4. Find the top 5 countries with the most content on Netflix
select * from netflix;

select country, count(show_id)
from netflix
group by country;

select string_to_array(country,',') as new_country 
from netflix;

-- 5. Identify the longest movie
select * from netflix;

SELECT 
    title,
    duration
FROM netflix
WHERE type = 'Movie'
ORDER BY CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) DESC
LIMIT 1;
-- cast is to convert the "string" value in duration into "interger" to perform numeric comparison
-- as unsigned is used to consider only non-negative values , if there is any -ve value (-60) it will take it as 0 , to consider -ve values we use "signed as" 

-- 6. Find content added in the last 5 years
select type, title , date_added
from netflix
where str_to_date(date_added,'%M %e,%Y') >= date_sub(current_date() , interval 5 year);

-- 7. Find all the movies/TV shows by director 'Rajiv Chilaka'!
select * from netflix
where director like '%Rajiv Chilaka%';

-- 8. List all TV shows with more than 5 seasons
select title, duration from netflix
where type = 'TV Show'
and CAST(SUBSTRING_INDEX(duration, ' ', 1) AS UNSIGNED) >=5;

-- //9. Count the number of content items in each genre

SELECT genre, COUNT(*) AS total_content
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(listed_in, ',', numbers.n), ',', -1)) AS genre
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6
    ) numbers
    ON CHAR_LENGTH(listed_in) - CHAR_LENGTH(REPLACE(listed_in, ',', '')) >= numbers.n - 1
) AS genres
WHERE genre IS NOT NULL AND genre <> ''
GROUP BY genre
ORDER BY total_content DESC;

-- 10. Find each year and the average numbers of content release by India on netflix. 
-- return top 5 year with highest avg content release !
select year(str_to_date(date_added,'%M %e,%Y')) as year ,
	count(*),
    count(*)/(select count(*) from netflix where country = 'India') * 100 as avg_content_per_year
from netflix
where country = 'India'
group by 1
order by 3 desc
limit 5;

-- 11. List all movies that are documentaries
SELECT title, type, listed_in
FROM netflix
WHERE type = 'Movie'
  AND listed_in LIKE '%Documentaries%';

-- 12. Find all content without a director
select * from netflix where director is NULL;

-- 13. Find how many movies actor 'Salman Khan' appeared in last 10 years!
select title,casts,release_year
from netflix
where casts like '%Salman Khan%'
and
release_year > extract(year from current_date())-20;

-- //14. Find the top 10 actors who have appeared in the highest number of movies produced in India.
SELECT actor, COUNT(*) AS appearances
FROM (
    SELECT TRIM(SUBSTRING_INDEX(SUBSTRING_INDEX(casts, ',', numbers.n), ',', -1)) AS actor
    FROM netflix
    JOIN (
        SELECT 1 AS n UNION ALL
        SELECT 2 UNION ALL
        SELECT 3 UNION ALL
        SELECT 4 UNION ALL
        SELECT 5 UNION ALL
        SELECT 6 UNION ALL
        SELECT 7 UNION ALL
        SELECT 8 UNION ALL
        SELECT 9 UNION ALL
        SELECT 10
    ) numbers
    ON CHAR_LENGTH(casts) - CHAR_LENGTH(REPLACE(casts, ',', '')) >= numbers.n - 1
    WHERE type = 'Movie' AND country LIKE '%India%'
) AS actors
WHERE actor IS NOT NULL AND actor <> ''
GROUP BY actor
ORDER BY appearances DESC
LIMIT 10;

-- 15: Categorize the content based on the presence of the keywords 'kill' and 'violence' in 
-- the description field. Label content containing these keywords as 'Bad' and all other content as 'Good'. Count how many items fall into each category.
select * from netflix;
select
	case
		when description like '%kill%' or description like '%violence%'
        then 'Bad'
        else 'Good'
	end as category,
    count(*) as total_content
from netflix
group by category;