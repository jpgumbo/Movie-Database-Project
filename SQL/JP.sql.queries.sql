-- I join critic reviews with movies so I can see the review emotions together with the Metascore.

SELECT
    cr.movie_id,
    m.title,
    m.metascore,
    cr.posemo,
    cr.negemo,
    cr.tone
FROM critic_reviews AS cr
JOIN movies AS m
    ON cr.movie_id = m.movie_id;


-- I join critic reviews, movies and sales so I can compare review emotions with worldwide box office.

SELECT
    m.title,
    m.metascore,
    cr.posemo,
    cr.negemo,
    cr.tone,
    s.domestic_box_office + s.international_box_office AS worldwide_box_office
FROM critic_reviews AS cr
JOIN movies AS m
    ON cr.movie_id = m.movie_id
JOIN sales AS s
    ON cr.movie_id = s.movie_id;
