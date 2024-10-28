-- this is a Netflix dataset querying project

CREATE TABLE netflix 
(
		show_id	VARCHAR(5),
		type VARCHAR(7),
		title VARCHAR(110),
		director VARCHAR(210),
		casts VARCHAR(800),
		country	VARCHAR(130),
		date_added	VARCHAR(50),
		release_year  INT,
		rating	VARCHAR(10),
		duration	VARCHAR(20),
		listed_in	VARCHAR(100),
		description VARCHAR(260)
);

-- To check if the table has been created apporpriately, after which dataset will be imported.

SELECT * 
FROM netflix;


-- 1. Count the number of movies VS Tv Shows

SELECT type, COUNT(*)
FROM netflix
GROUP BY type;

-- 2. Find the most common rating for movies and tv shows 

WITH CTE AS 
(
	SELECT 
		type AS film_type,
		rating AS film_rating, 
		COUNT(rating),
		RANK() OVER(PARTITION BY type ORDER BY COUNT(rating) DESC) AS rnk_num
	FROM netflix
	WHERE rating IS NOT NULL
	GROUP BY 
		type, 
		rating
	ORDER BY type, COUNT(rating) DESC
)
	SELECT 
		film_type,
		film_rating
	FROM CTE
	WHERE rnk_num = 1;

-- 3. List all movies released in a specific year (2022)

SELECT title, type, release_year
FROM netflix 
WHERE release_year = 2022 and type = 'Movie';

-- 4. Find the top 5 countries with the most content on Netflix

-- UNNEST() is used because some tv shows/movies are produced in multiple countries
-- TRIM() is used to remove excess spaces if any

SELECT 
	TRIM(UNNEST(STRING_TO_ARRAY(country, ','))) as countries,
	COUNT(*) as total_content
FROM netflix
WHERE country IS NOT NULL
GROUP BY countries
ORDER BY total_content DESC
LIMIT 5;

-- 5. Identify the longest movie?

SELECT title, duration
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	duration = (SELECT MAX(duration) FROM netflix);

-- 6. Find the movies/TV Shows added in the last 5 years

SELECT title, date_added, description 
FROM Netflix
WHERE 
	TO_DATE(date_added, 'Month DD, YYYY') >= CURRENT_DATE - INTERVAL '5 years';


-- 7. Find all the movies/tv shows by director 'Kemi Adetiba'

SELECT title, type, director
FROM netflix
WHERE director ILIKE '%Kemi Adetiba%';


-- 8. List all tv shows with more than 5 seasons ---readmore

SELECT title, type, duration
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	SPLIT_PART(duration, ' ',1)::numeric > 5;

-- ::numeric is used to into a numeric value useful for calculations

-- 9. Count the number of content in each genre
SELECT TRIM(UNNEST(STRING_TO_ARRAY(listed_in, ','))) as genre, COUNT(*) as content_count
FROM netflix
GROUP BY genre
ORDER BY COUNT(*) DESC;

-- 10. List all TV Shows that are TV dramas
SELECT title, type, listed_in AS genre
FROM netflix
WHERE 
	type = 'TV Show'
	AND
	listed_in ILIKE '% TV Dramas%';

-- 11. Find how many movies actor 'Adam Sandler' appeared in last 10 years

SELECT Title, release_year, casts
FROM Netflix
WHERE 
	release_year > EXTRACT(YEAR FROM CURRENT_DATE) - 10 
	AND 
	type = 'Movie'
	AND
	casts ILIKE '%Adam Sandler%';

-- 12. Find the top 10 actors who have appeared in the highest 
-- number of movies produced in USA

SELECT TRIM(UNNEST(STRING_TO_ARRAY(casts, ','))) as Actor, COUNT(*) AS no_of_movies_castedIn
FROM netflix
WHERE 
	type = 'Movie'
	AND 
	Country ILIKE '%United States%'
GROUP BY Actor
ORDER BY COUNT(*) DESC
LIMIT 10;

--13. Categorize the content based on keywords 'kill' and 'violence' in the description 
--field.label content containing these keywords as 'bad' and all the other content as 'good'.
-- Count how many items fall into each category.

WITH CTE AS 
	(
	SELECT title,
	CASE
		WHEN description ILIKE '%kill%' 
				OR
			 description ILIKE '%violence'
		THEN 'Bad_Content'
		ELSE 'Good_Content'
		END as Content_category
FROM netflix
		)
SELECT content_category, 
	COUNT(*) as content_count
FROM CTE
GROUP BY content_category;
