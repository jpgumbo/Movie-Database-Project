-- First, I check how many critic reviews are available and whether
-- the emotional variables (posemo, negemo, and tone) contain values.
-- This helps me understand whether the critic review data is suitable
-- for investigating H2 before I start combining it with other tables.

SELECT
    COUNT(*) AS total_reviews,
    COUNT(posemo) AS posemo_values,
    COUNT(negemo) AS negemo_values,
    COUNT(tone) AS tone_values
FROM critic_reviews;

-- Here, I calculate the average emotional characteristics of critic
-- reviews for each movie. The critic_reviews table contains multiple
-- reviews per movie, while the movies and sales tables contain
-- movie-level information. Aggregating the reviews gives me one
-- emotional profile per movie, which I can later compare with
-- Metascore and worldwide box-office revenue.

SELECT
    movie_id,
    AVG(posemo) AS avg_posemo,
    AVG(negemo) AS avg_negemo,
    AVG(tone) AS avg_tone,
    COUNT(*) AS number_of_reviews
FROM critic_reviews
GROUP BY movie_id;




-- I join critic_reviews with movies using movie_id.
-- This lets me connect the critic review information
-- to the movie information, such as the Metascore.

SELECT
    cr.movie_id,
    m.title,
    m.metascore
FROM critic_reviews cr
JOIN movies m
    ON cr.movie_id = m.movie_id
LIMIT 20;


-- I combine the critic review averages with the movie information.
-- This gives me one row for each movie with its average emotional
-- characteristics and its Metascore.
-- I need these variables together so I can later investigate H2.

SELECT
    cr.movie_id,
    AVG(cr.posemo) AS avg_posemo,
    AVG(cr.negemo) AS avg_negemo,
    AVG(cr.tone) AS avg_tone,
    m.metascore
FROM critic_reviews cr
JOIN movies m
    ON cr.movie_id = m.movie_id
GROUP BY
    cr.movie_id,
    m.metascore;

	-- I now add the sales information to my critic review data.
-- This allows me to connect the emotional characteristics of critic
-- reviews and the Metascore to the movie's box-office performance.
-- Worldwide box office is calculated by adding domestic and
-- international box office revenue.

SELECT
    cr.movie_id,
    AVG(cr.posemo) AS avg_posemo,
    AVG(cr.negemo) AS avg_negemo,
    AVG(cr.tone) AS avg_tone,
    m.metascore,
    s.domestic_box_office,
    s.international_box_office,
    s.domestic_box_office + s.international_box_office AS worldwide_box_office
FROM critic_reviews cr
JOIN movies m
    ON cr.movie_id = m.movie_id
JOIN sales s
    ON cr.movie_id = s.movie_id
GROUP BY
    cr.movie_id,
    m.metascore,
    s.domestic_box_office,
    s.international_box_office;



	-- I check whether any sales records are missing domestic or
-- international box-office values.
-- This is important because I need both values to calculate
-- worldwide box office for H2.

SELECT
    COUNT(*) AS total_sales,
    COUNT(domestic_box_office) AS domestic_values,
    COUNT(international_box_office) AS international_values
FROM sales;


-- I check how many sales records have both domestic and
-- international box-office values.
-- I need both values to calculate worldwide box-office revenue
-- for the H2 analysis.

SELECT
    COUNT(*) AS complete_sales
FROM sales
WHERE domestic_box_office IS NOT NULL
AND international_box_office IS NOT NULL;


-- I count the unique movies instead of individual critic reviews.
-- A movie can have many critic reviews, so COUNT(*) would count
-- reviews rather than movies.
-- I only want movies with both domestic and international
-- box-office values because these are needed to calculate
-- worldwide box office for H2.

SELECT
    COUNT(DISTINCT cr.movie_id) AS movies_for_h2
FROM critic_reviews cr
JOIN sales s
    ON cr.movie_id = s.movie_id
WHERE s.domestic_box_office IS NOT NULL
AND s.international_box_office IS NOT NULL;


-- I compare the Metascore with worldwide box-office revenue.
-- This helps me see whether movies with higher critic scores
-- tend to have higher box-office revenue.

SELECT
    m.title,
    m.metascore,
    s.domestic_box_office + s.international_box_office AS worldwide_box_office
FROM movies m
JOIN sales s
    ON m.movie_id = s.movie_id
WHERE m.metascore IS NOT NULL
AND s.domestic_box_office IS NOT NULL
AND s.international_box_office IS NOT NULL
LIMIT 20;


-- I sort the movies by Metascore from highest to lowest.
-- This lets me inspect the movies with the highest critic scores
-- and compare their box-office revenue.

SELECT
    m.title,
    m.metascore,
    s.domestic_box_office + s.international_box_office AS worldwide_box_office
FROM movies m
JOIN sales s
    ON m.movie_id = s.movie_id
WHERE m.metascore IS NOT NULL
AND s.domestic_box_office IS NOT NULL
AND s.international_box_office IS NOT NULL
ORDER BY m.metascore DESC
LIMIT 20;


-- I group movies by their Metascore range.
-- This helps me see whether box-office revenue changes
-- as the Metascore increases.

SELECT
    m.metascore,
    AVG(s.domestic_box_office + s.international_box_office) AS average_worldwide_box_office
FROM movies m
JOIN sales s
    ON m.movie_id = s.movie_id
WHERE m.metascore IS NOT NULL
AND s.domestic_box_office IS NOT NULL
AND s.international_box_office IS NOT NULL
GROUP BY m.metascore
ORDER BY m.metascore 
Limit 50;


-- I look at the movies with the highest average positive emotion
-- in their critic reviews.
-- I also show their worldwide box-office revenue.
-- This helps me explore whether positive emotional language
-- is related to movie sales.

SELECT
    cr.movie_id,
    AVG(cr.posemo) AS average_positive_emotion,
    s.domestic_box_office + s.international_box_office AS worldwide_box_office
FROM critic_reviews cr
JOIN sales s
    ON cr.movie_id = s.movie_id
WHERE s.domestic_box_office IS NOT NULL
AND s.international_box_office IS NOT NULL
GROUP BY
    cr.movie_id,
    s.domestic_box_office,
    s.international_box_office
ORDER BY average_positive_emotion DESC
LIMIT 20;


-- I look at the average negative emotion in critic reviews.
-- I compare it with the worldwide box office
-- to see whether there is an obvious relationship.

SELECT
    AVG(negemo) AS average_negative_emotion,
    AVG(domestic_box_office + international_box_office) AS average_box_office
FROM critic_reviews
JOIN sales
    ON critic_reviews.movie_id = sales.movie_id;


-- I look at the average tone in critic reviews.
-- I compare it with the average worldwide box office.
-- This helps me explore whether tone is related to box-office revenue.

SELECT
    AVG(tone) AS average_tone,
    AVG(domestic_box_office + international_box_office) AS average_box_office
FROM critic_reviews
JOIN sales
    ON critic_reviews.movie_id = sales.movie_id;	


-- I look at the average tone of each movie's critic reviews.
-- I compare this with the movie's worldwide box office.
-- This helps me explore whether tone is related to box-office revenue.

SELECT
    critic_reviews.movie_id,
    AVG(tone) AS average_tone,
    AVG(domestic_box_office + international_box_office) AS average_box_office
FROM critic_reviews
JOIN sales
    ON critic_reviews.movie_id = sales.movie_id
WHERE domestic_box_office IS NOT NULL
AND international_box_office IS NOT NULL
GROUP BY critic_reviews.movie_id
ORDER BY average_tone DESC
LIMIT 20;


-- I bring together the Metascore and the three emotional
-- characteristics of critic reviews.
-- I also include worldwide box office.
-- This gives me one row for each movie that I can use
-- for the next stage of investigating H2.

SELECT
    critic_reviews.movie_id,
    AVG(posemo) AS average_positive_emotion,
    AVG(negemo) AS average_negative_emotion,
    AVG(tone) AS average_tone,
    movies.metascore,
    sales.domestic_box_office + sales.international_box_office AS worldwide_box_office
FROM critic_reviews
JOIN movies
    ON critic_reviews.movie_id = movies.movie_id
JOIN sales
    ON critic_reviews.movie_id = sales.movie_id
WHERE movies.metascore IS NOT NULL
AND sales.domestic_box_office IS NOT NULL
AND sales.international_box_office IS NOT NULL
GROUP BY
    critic_reviews.movie_id,
    movies.metascore,
    sales.domestic_box_office,
    sales.international_box_office;


-- I check whether Metascore is related to worldwide box office.

SELECT
    CORR(metascore, worldwide_box_office) AS metascore_box_office
FROM (
    SELECT
        movies.metascore,
        sales.domestic_box_office + sales.international_box_office AS worldwide_box_office
    FROM movies
    JOIN sales
        ON movies.movie_id = sales.movie_id
    WHERE movies.metascore IS NOT NULL
    AND sales.domestic_box_office IS NOT NULL
    AND sales.international_box_office IS NOT NULL
) AS data;


-- I check the relationship between positive emotion and box office.

SELECT
    CORR(average_positive_emotion, worldwide_box_office)
FROM (
    SELECT
        AVG(posemo) AS average_positive_emotion,
        sales.domestic_box_office + sales.international_box_office AS worldwide_box_office
    FROM critic_reviews
    JOIN sales
        ON critic_reviews.movie_id = sales.movie_id
    GROUP BY critic_reviews.movie_id,
             sales.domestic_box_office,
             sales.international_box_office
) AS data;


-- I check the relationship between negative emotion and box office.

SELECT
    CORR(average_negative_emotion, worldwide_box_office)
FROM (
    SELECT
        AVG(negemo) AS average_negative_emotion,
        sales.domestic_box_office + sales.international_box_office AS worldwide_box_office
    FROM critic_reviews
    JOIN sales
        ON critic_reviews.movie_id = sales.movie_id
    GROUP BY critic_reviews.movie_id,
             sales.domestic_box_office,
             sales.international_box_office
) AS data;


-- I check the relationship between tone and box office.

SELECT
    CORR(average_tone, worldwide_box_office)
FROM (
    SELECT
        AVG(tone) AS average_tone,
        sales.domestic_box_office + sales.international_box_office AS worldwide_box_office
    FROM critic_reviews
    JOIN sales
        ON critic_reviews.movie_id = sales.movie_id
    GROUP BY critic_reviews.movie_id,
             sales.domestic_box_office,
             sales.international_box_office
) AS data;

