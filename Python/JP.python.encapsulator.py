# JP: I import psycopg because I need Python to connect
# to our PostgreSQL database.
import psycopg

# JP: I import pandas because I want the database results
# to be returned as pandas DataFrames.
import pandas as pd


# JP: I connect Python to our PostgreSQL database.
# I use the same database that I worked with in pgAdmin.
connection = psycopg.connect(
    dbname="movie_db_test",
    user="johnpaul",
    host="localhost",
    port="5432"
)


# JP: I create this function to retrieve basic movie information.
# This gives me the movie ID, title, and Metascore.
def get_movie_data():

    # JP: I write the SQL query I want Python to run.
    query = """
    SELECT
        movie_id,
        title,
        metascore
    FROM movies;
    """

    # JP: I run the SQL query and store the results
    # as a pandas DataFrame.
    data = pd.read_sql(query, connection)

    # JP: I return the movie data so it can be used
    # for further analysis.
    return data


# JP: I create this function for my H2 investigation.
# I combine critic review emotions, Metascore, and
# worldwide box office at the movie level.
def get_critic_review_data():

    # JP: I use the SQL query from my H2 investigation.
    # I average the emotional characteristics because
    # each movie has multiple critic reviews.
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

    # JP: I run the query and turn the results
    # into a pandas DataFrame.
    data = pd.read_sql(query, connection)

    # JP: I return the movie-level critic review data
    # so I can use it for further analysis.
    return data


# JP: I create this function to calculate the correlations
# I investigated during my SQL analysis.
# I compare Metascore and the emotional characteristics
# with worldwide box office.
def get_correlation_data():

    # JP: I write the SQL query that calculates
    # the four correlations I investigated.
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

    # JP: I run the query and store the correlation results
    # as a pandas DataFrame.
    data = pd.read_sql(query, connection)

    # JP: I return the correlation results so they can be used for analysis.
    return data
