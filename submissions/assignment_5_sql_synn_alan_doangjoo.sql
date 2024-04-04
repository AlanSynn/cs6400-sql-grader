-- HW2 SQL by Alan Synn

-- Initialize before executing follows
-- DROP VIEW IF EXISTS query_1;
-- DROP VIEW IF EXISTS query_2;
-- DROP VIEW IF EXISTS query_3;
-- DROP VIEW IF EXISTS query_4;
-- DROP VIEW IF EXISTS query_5;
-- DROP VIEW IF EXISTS query_6;
-- DROP VIEW IF EXISTS query_7;
-- DROP VIEW IF EXISTS query_8;
-- DROP VIEW IF EXISTS query_9;
-- DROP VIEW IF EXISTS query_10;
-- DROP VIEW IF EXISTS intermediate_query_10;
-- DROP VIEW IF EXISTS query_11;
-- DROP VIEW IF EXISTS query_12;
-- DROP VIEW IF EXISTS query_13;
-- DROP VIEW IF EXISTS query_14;
-- DROP VIEW IF EXISTS query_15;

-- Query 1
CREATE VIEW query_1 AS
	SELECT Email
    FROM Clients
    WHERE Phone_Number LIKE '555-%' OR Phone_Number LIKE '404-%';
-- SELECT * FROM query_1;

-- Query 2
CREATE VIEW query_2 AS
SELECT
    p.Property_Name,
    c.Email,
    c.CcNumber,
    c.Cvv,
    c.Exp_Date
FROM
    Reserve r
JOIN
    Customer c ON r.Customer = c.Email
JOIN
    Property p ON r.Property_Name = p.Property_Name AND r.Owner_Email = p.Owner_Email
WHERE
    r.Start_Date BETWEEN '2022-10-15' AND '2022-10-20'
AND
    r.End_Date BETWEEN '2022-10-21' AND '2022-10-30';
-- SELECT * FROM query_2;

-- Query 3
CREATE VIEW query_3 AS
SELECT
    p.Owner_Email,
    r.Property_Name,
    r.Content
FROM
    Review r
JOIN
    Property p ON r.Property_Name = p.Property_Name AND r.Owner_Email = p.Owner_Email
WHERE
    (r.Content LIKE '%great%' OR r.Content LIKE '%excellent%')
AND
    LENGTH(r.Content) > 25;
-- SELECT * FROM query_3;

-- Query 4
CREATE VIEW query_4 AS
SELECT
    To_Airport AS Destination_Airport_Code,
    AVG(Cost) AS Average_Cost,
    AVG(Capacity) AS Average_Capacity
FROM
    Flight
GROUP BY
    To_Airport;
-- SELECT * FROM query_4;

-- Query 5
CREATE VIEW query_5 AS
SELECT
    p.Property_Name,
    p.Owner_Email,
    ict.Airport,
    ict.Distance
FROM
    Property p
JOIN
    Is_Close_To ict ON p.Property_Name = ict.Property_Name AND p.Owner_Email = ict.Owner_Email
INNER JOIN
    (SELECT
         Airport,
         MIN(Distance) AS MinDistance
     FROM
         Is_Close_To
     GROUP BY
         Airport) AS minDist ON ict.Airport = minDist.Airport AND ict.Distance = minDist.MinDistance;
-- SELECT * FROM query_5;

-- Query 6
CREATE VIEW query_6 AS
SELECT
    a.Email,
    a.First_Name,
    a.Last_Name,
    c.Phone_Number
FROM
    Accounts a
JOIN
    Clients c ON a.Email = c.Email
LEFT JOIN
    Admins ad ON a.Email = ad.Email
WHERE
    ad.Email IS NULL
ORDER BY
    a.Last_Name;
-- SELECT * FROM query_6;

-- Query 7
CREATE VIEW query_7 AS
SELECT
    Flight_Num,
    Airline_Name,
    From_Airport,
    To_Airport,
    Departure_Time,
    Arrival_Time,
    Flight_Date,
    Cost,
    Capacity
FROM
    Flight
ORDER BY
    Cost ASC,
    Flight_Date DESC;
-- SELECT * FROM query_7;

-- Query 8
CREATE VIEW query_8 AS
SELECT
    p.Property_Name,
    p.Owner_Email AS Property_Owner,
    GROUP_CONCAT(a.Amenity_Name ORDER BY a.Amenity_Name ASC SEPARATOR ', ') AS Amenities
FROM
    Property p
JOIN
    Amenity a ON p.Property_Name = a.Property_Name AND p.Owner_Email = a.Property_Owner
GROUP BY
    p.Property_Name, p.Owner_Email;
-- SELECT * FROM query_8;

-- Query 9
CREATE VIEW query_9 AS
SELECT
    c.Email,
    c.CcNumber
FROM
    Customer c
JOIN
    Book b ON c.Email = b.Customer
WHERE
    b.Was_Cancelled = TRUE;
-- SELECT * FROM query_9;

-- Query 10
CREATE VIEW intermediate_query_10 AS
SELECT
    b.Flight_Num,
    b.Airline_Name,
    b.Num_Seats
FROM
    Book b
JOIN
    Flight f ON b.Flight_Num = f.Flight_Num AND b.Airline_Name = f.Airline_Name
WHERE
    f.Flight_Date = '2022-10-18'
AND
    b.Was_Cancelled = FALSE;
-- SELECT * FROM intermediate_query_10;

CREATE VIEW query_10 AS
SELECT
    Airline_Name,
    SUM(Num_Seats) AS Total_Seats_Booked
FROM
    intermediate_query_10
GROUP BY
    Airline_Name;
-- SELECT * FROM query_10;

-- Additional Questions

-- Query 11
CREATE VIEW query_11 AS
SELECT
    a.First_Name,
    a.Last_Name,
    SUM(r.Num_Guests) AS Total_Guests_2022
FROM
    Owners o
JOIN
    Accounts a ON o.Email = a.Email
JOIN
    Property p ON o.Email = p.Owner_Email
JOIN
    Reserve r ON p.Property_Name = r.Property_Name AND p.Owner_Email = r.Owner_Email
WHERE
    YEAR(r.Start_Date) = 2022
GROUP BY
    a.First_Name, a.Last_Name
ORDER BY
    a.First_Name ASC, a.Last_Name ASC;
-- SELECT * FROM query_11;

-- Query 12
CREATE VIEW query_12 AS
SELECT
    p.Property_Name,
    p.Owner_Email,
    COUNT(r.Score) AS Review_Count
FROM
    Property p
JOIN
    Review r ON p.Property_Name = r.Property_Name AND p.Owner_Email = r.Owner_Email
GROUP BY
    p.Property_Name, p.Owner_Email
HAVING
    COUNT(r.Score) >= 1
ORDER BY
    Review_Count DESC;
-- SELECT * FROM query_12;

-- Query 13
CREATE VIEW query_13 AS
SELECT DISTINCT
    c.Email
FROM
    Customer c
JOIN
    Book b ON c.Email = b.Customer
JOIN
    Airline a ON b.Airline_Name = a.Airline_Name
WHERE
    a.Rating > 4.0
ORDER BY
    c.Email ASC;
-- SELECT * FROM query_13;

-- Query 14
CREATE VIEW query_14 AS
SELECT
    p.Property_Name,
    p.Owner_Email,
    COUNT(a.Amenity_Name) AS Total_Amenity_Count
FROM
    Property p
JOIN
    Amenity a ON p.Property_Name = a.Property_Name AND p.Owner_Email = a.Property_Owner
GROUP BY
    p.Property_Name, p.Owner_Email
ORDER BY
    Total_Amenity_Count DESC;
-- SELECT * FROM query_14;

-- Query 15
CREATE VIEW query_15 AS
SELECT
    Airport_ID,
    SUM(Total_Traffic) AS Total_Traffic
FROM
    (
        SELECT
            From_Airport AS Airport_ID,
            COUNT(*) AS Total_Traffic
        FROM
            Flight
        GROUP BY
            From_Airport
        UNION ALL
        SELECT
            To_Airport AS Airport_ID,
            COUNT(*) AS Total_Traffic
        FROM
            Flight
        GROUP BY
            To_Airport
    ) AS CombinedTraffic
GROUP BY
    Airport_ID
ORDER BY
    SUM(Total_Traffic) DESC, Airport_ID ASC
LIMIT 5;
-- SELECT * FROM query_15;