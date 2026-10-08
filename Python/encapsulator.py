# I import psycopg so Python can connect to PostgreSQL.
import psycopg

# I import pandas so I can work with database results as DataFrames.
import pandas as pd


# I connect Python to my PostgreSQL database.
connection = psycopg.connect(
    dbname="movie_db_test",
    user="johnpaul",
    host="localhost",
    port="5432"
)


# I create a function that gets basic movie information.
def get_movie_data():

    # I write the SQL query I want Python to run.
    query = """
    SELECT
        movie_id,
        title,
        metascore
    FROM movies;
    """

    # I run the SQL query using my database connection.
    data = pd.read_sql(query, connection)

    # I return the results as a pandas DataFrame.
    return data


# I create a function that gets the critic review data
# needed for my H2 investigation.
def get_critic_review_data():

    # I write the SQL query that combines critic reviews,
    # movies, and sales at movie level.
    query = """
    SELECT
        cr.movie_id,
        AVG(cr.posemo) AS average_positive_emotion,
        AVG(cr.negemo) AS average_negative_emotion,
        AVG(cr.tone) AS average_tone,
        m.metascore,
        s.domestic_box_office,
        s.international_box_office,
        s.domestic_box_office + s.international_box_office AS worldwide_box_office
    FROM critic_reviews cr
    JOIN movies m
        ON cr.movie_id = m.movie_id
    JOIN sales s
        ON cr.movie_id = s.movie_id
    WHERE m.metascore IS NOT NULL
    AND s.domestic_box_office IS NOT NULL
    AND s.international_box_office IS NOT NULL
    GROUP BY
        cr.movie_id,
        m.metascore,
        s.domestic_box_office,
        s.international_box_office;
    """

    # I run the SQL query and store the results as a DataFrame.
    data = pd.read_sql(query, connection)

    # I return the movie-level critic review data.
    return data


# I create a function that calculates the correlations
# between review emotions, Metascore, and worldwide box office.
def get_correlation_data():

    # I write the SQL query that calculates the correlations.
    query = """
    SELECT
        CORR(metascore, worldwide_box_office) AS metascore_box_office,
        CORR(average_positive_emotion, worldwide_box_office) AS positive_emotion_box_office,
        CORR(average_negative_emotion, worldwide_box_office) AS negative_emotion_box_office,
        CORR(average_tone, worldwide_box_office) AS tone_box_office
    FROM (
        SELECT
            cr.movie_id,
            AVG(cr.posemo) AS average_positive_emotion,
            AVG(cr.negemo) AS average_negative_emotion,
            AVG(cr.tone) AS average_tone,
            m.metascore,
            s.domestic_box_office + s.international_box_office AS worldwide_box_office
        FROM critic_reviews cr
        JOIN movies m
            ON cr.movie_id = m.movie_id
        JOIN sales s
            ON cr.movie_id = s.movie_id
        WHERE m.metascore IS NOT NULL
        AND s.domestic_box_office IS NOT NULL
        AND s.international_box_office IS NOT NULL
        GROUP BY
            cr.movie_id,
            m.metascore,
            s.domestic_box_office,
            s.international_box_office
    ) AS data;
    """

    # I run the SQL query using my database connection.
    data = pd.read_sql(query, connection)

    # I return the correlation results as a pandas DataFrame.
    return data
