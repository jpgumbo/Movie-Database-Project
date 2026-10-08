-- ============================================================
-- Query 1 - H1: review scores and worldwide box office
-- Written by: [Luca Alexandrescu]
-- Returns one row per film with both aggregate scores and the
-- worldwide box office. Result: 4,890 films.
-- ============================================================

SELECT m.movie_id,                                              -- primary key of the film
       m.title,                                                 -- film title, to read the result
       m.metascore,                                             -- aggregate critic score (0-100)
       m.userscore,                                             -- aggregate user score (0-10)
       s.domestic_box_office + s.international_box_office        -- worldwide revenue is calculated,
           AS worldwide_box_office,                             -- because it is not stored (normalization)
       s.production_budget,                                     -- control variable
       s.runtime_minutes,                                       -- control variable
       s.release_date                                           -- control variable (year effects)
FROM movies m                                                   -- main table: one row per film
JOIN sales s ON s.movie_id = m.movie_id                         -- link by foreign key; inner join keeps
                                                                -- only films that have sales data
WHERE m.metascore IS NOT NULL                                   -- H1 needs the critic score
  AND m.userscore IS NOT NULL                                   -- H1 needs the user score
  AND s.domestic_box_office IS NOT NULL                         -- both parts are needed, otherwise the
  AND s.international_box_office IS NOT NULL                    -- worldwide figure cannot be calculated
ORDER BY m.movie_id;                                            -- stable order on every run