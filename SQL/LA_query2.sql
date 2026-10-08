-- ============================================================
-- Query 2 - Sub-question 1: rating distributions of critics and users
-- Written by: [Luca Alexandrescu]
-- Critics rate 0-100 and users 0-10, so the user scores are
-- multiplied by 10 to put both on the same scale.
-- Result: critics mean 62.75 (sd 20.71), users 65.86 (sd 31.87).
-- ============================================================

SELECT 'critic' AS reviewer_type,                 -- label, so both halves can be told apart
       COUNT(*) AS n_reviews,                     -- number of critic reviews with a score
       ROUND(AVG(idvscore), 2) AS mean_score,     -- average score
       ROUND(STDDEV(idvscore), 2) AS sd_score,    -- spread: the key number for this sub-question
       MIN(idvscore) AS min_score,                -- lowest score given
       MAX(idvscore) AS max_score                 -- highest score given
FROM critic_reviews
WHERE idvscore IS NOT NULL                        -- reviews without a score say nothing about the distribution

UNION ALL                                         -- place the user result underneath the critic result

SELECT 'user',                                    -- same columns in the same order as above
       COUNT(*),
       ROUND(AVG(idvscore * 10), 2),              -- x 10 puts the 0-10 scale onto 0-100
       ROUND(STDDEV(idvscore * 10), 2),
       MIN(idvscore * 10),
       MAX(idvscore * 10)
FROM user_reviews
WHERE idvscore IS NOT NULL;