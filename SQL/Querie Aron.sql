Student: Aron Knibbe
/*
H3 / SUB-QUESTION 3

Purpose:
This query prepares an analysis-ready dataset to investigate whether
the emotional characteristics of user reviews explain variation in a
film's post-release box-office trajectory beyond the aggregate userscore.

The query:
1. Combine individual user reviews to movie level.
2. Calculates the average positive emotion, negative emotion and tone.
3. Combines the user-review data with movie and sales data.
4. Calculates the post-release box-office trajectory.
5. Filters out movies for which the required variables are unavailable.
*/


-- STEP 1: Combine individual user reviews to movie level
WITH user_emotions AS (
    SELECT
        movie_id,

        -- Number of user reviews available for each movie
        COUNT(*) AS number_user_reviews,

        -- Average emotional characteristics of the user reviews
        AVG(posemo) AS avg_user_posemo,
        AVG(negemo) AS avg_user_negemo,
        AVG(tone) AS avg_user_tone

    FROM user_reviews

    -- Creates one observation per movie
    GROUP BY movie_id
)


-- STEP 2: Select the variables required for H3 / Sub-question 3
SELECT
    m.movie_id,
    m.title,

    -- Aggregate user rating
    m.userscore,

    -- Box-office variables
    s.opening_weekend,
    s.domestic_box_office,


    -- STEP 3: Calculate the post-release box-office trajectory
    -- Domestic box office divided by opening-weekend revenue
    -- NULLIF prevents division by zero
    s.domestic_box_office::numeric
        / NULLIF(s.opening_weekend, 0)
        AS post_release_trajectory,


    -- Aggregated user-review information
    u.number_user_reviews,
    u.avg_user_posemo,
    u.avg_user_negemo,
    u.avg_user_tone


-- STEP 4: Combine the required tables
FROM movies AS m

-- Add box-office information
INNER JOIN sales AS s
    ON m.movie_id = s.movie_id

-- Add the aggregated emotional characteristics of user reviews
INNER JOIN user_emotions AS u
    ON m.movie_id = u.movie_id


-- STEP 5: Keep only movies with the variables required for the analysis
WHERE
    m.userscore IS NOT NULL
    AND s.opening_weekend IS NOT NULL
    AND s.opening_weekend > 0
    AND s.domestic_box_office IS NOT NULL


-- STEP 6: Sort movies from highest to lowest post-release trajectory
ORDER BY post_release_trajectory DESC;

