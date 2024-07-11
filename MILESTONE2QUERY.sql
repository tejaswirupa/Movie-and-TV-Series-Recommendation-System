#Query to find a Movie and a TV Series containing substring “last”

SELECT 'Movie' AS Type,
       M.Movie_ID AS Show_ID,
       M.Name AS Show_Name
FROM Movie M
WHERE M.Name LIKE '%last%'

UNION ALL

SELECT 'TV Series' AS Type,
       TV.TV_Series_ID AS Show_ID,
       TV.Name AS Show_Name
FROM TV_Series TV
WHERE TV.Name LIKE '%last%';


#Shows released within the past year (-365 days)

SELECT 
    Movie_ID,
    Name AS Show_Name,
    Release_Date AS Show_Release_Date,
    'Movie' AS Type
FROM 
    Movie
WHERE 
    Release_Date BETWEEN DATE_SUB(CURDATE(), INTERVAL 365 DAY) AND CURDATE()

UNION ALL

SELECT 
    TV_Series_ID AS Movie_ID,
    Name AS Show_Name,
    Release_Date AS Show_Release_Date,
    'TV Series' AS Type
FROM 
    TV_Series
WHERE 
    Release_Date BETWEEN DATE_SUB(CURDATE(), INTERVAL 365 DAY) AND CURDATE();
    

#Top rated movies for users between the age of 18 and 30

SELECT 
    M.Movie_ID,
    M.Name AS Movie_Name,
    AVG(H.rating) AS average_rating
FROM 
    User U
JOIN 
    History H ON U.User_ID = H.User_ID
JOIN 
    Show_Table ST ON H.Show_ID = ST.Show_ID
JOIN 
    Movie M ON ST.Movie_ID = M.Movie_ID
WHERE 
    YEAR(CURDATE()) - YEAR(U.birthday) BETWEEN 18 AND 30
GROUP BY 
    M.Movie_ID, M.Name
ORDER BY 
    average_rating DESC
LIMIT 10;


#Top 10 Genres

SELECT 
    M.Genre,
    COUNT(*) AS Genre_Count
FROM 
    Movie M
JOIN 
    Show_Table S ON M.Movie_ID = S.Movie_ID
JOIN 
    History H ON S.Show_ID = H.Show_ID
GROUP BY 
    M.Genre
ORDER BY 
    Genre_Count DESC
LIMIT 10;


#Most Watched shows between 2020-2024

SELECT S.show_id, M.name AS Movie_Name, COUNT(*) AS Most_Watched
FROM History H
JOIN  Show_Table S ON H.show_id = S.show_id
JOIN Movie M ON S.movie_id = M.movie_id
WHERE YEAR(M.Release_Date) BETWEEN 2020 AND 2024
GROUP BY S.show_id
ORDER BY Most_Watched DESC
LIMIT 5;


#Most Popular Shows in User’s watchlist

SELECT
    s.Show_ID,
    IFNULL(m.Name, tv.Name) AS show_name,
    COUNT(*) AS appearance_count
FROM
    WatchlistShow wli
JOIN
    Show_Table s ON wli.Show_ID = s.Show_ID
LEFT JOIN
    Movie m ON s.Movie_ID = m.Movie_ID
LEFT JOIN
    TV_Series tv ON s.TV_Series_ID = tv.TV_Series_ID
GROUP BY
    s.show_ID
ORDER BY
    appearance_count DESC
LIMIT 10;


#Recommendation based on Watch History of the User

SELECT DISTINCT ST.Show_ID,
       CASE
           WHEN M.Name IS NOT NULL THEN M.Name
           WHEN TS.Name IS NOT NULL THEN TS.Name
           ELSE 'Unknown'
       END AS Show_Name,
       AVG(H.rating) AS average_rating
FROM Show_Table ST
LEFT JOIN Movie M ON ST.Movie_ID = M.Movie_ID
LEFT JOIN TV_Series TS ON ST.TV_Series_ID = TS.TV_Series_ID
LEFT JOIN History H ON ST.Show_ID = H.Show_ID
WHERE ST.Show_ID NOT IN (
    SELECT Show_ID
    FROM History
    WHERE User_ID = 10
)
AND (
    M.Genre IN (
        SELECT M.Genre
        FROM History H
        JOIN Show_Table ST ON H.Show_ID = ST.Show_ID
        JOIN Movie M ON ST.Movie_ID = M.Movie_ID
        WHERE H.User_ID = 10
    )
    OR
    TS.Genre IN (
        SELECT TS.Genre
        FROM History H
        JOIN Show_Table ST ON H.Show_ID = ST.Show_ID
        JOIN TV_Series TS ON ST.TV_Series_ID = TS.TV_Series_ID
        WHERE H.User_ID = 10
    )
)
GROUP BY ST.Show_ID, Show_Name
ORDER BY AVG(H.rating) DESC, RAND()
LIMIT 10;


#TV Series with the most number of Episodes

SELECT 
    TV_Series_ID,
    Name AS TV_Series_Name,
    Number_of_Episodes
FROM 
    TV_Series
ORDER BY 
    Number_of_Episodes DESC
LIMIT 10;


# Shows with the most Views

SELECT 
    ST.Show_ID,
    CASE
        WHEN M.Name IS NOT NULL THEN M.Name
        WHEN TS.Name IS NOT NULL THEN TS.Name
    END AS Show_Name,
    COUNT(*) AS Views
FROM 
    History H
JOIN 
    Show_Table ST ON H.Show_ID = ST.Show_ID
LEFT JOIN 
    Movie M ON ST.Movie_ID = M.Movie_ID
LEFT JOIN 
    TV_Series TS ON ST.TV_Series_ID = TS.TV_Series_ID
GROUP BY 
    ST.Show_ID, Show_Name
ORDER BY 
    Views DESC
LIMIT 10;


#Find the average age gap between users’ age and show release dates

SELECT ROUND(AVG(DATEDIFF(u.Birthday, m.Release_Date)/365.25), 0) as Average_Age_Gap_In_Years
FROM User u, Movie m;