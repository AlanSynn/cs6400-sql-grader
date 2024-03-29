select email from clients where Phone_Number like '555%' or Phone_Number like '404%';

select property_name, customer, c.ccnumber, c.cvv, c.exp_date from reserve r, customer c where r.customer = c.email and (start_date between '2022-10-15' and '2022-10-20') and (end_date between '2022-10-21' and '2022-10-30') ;

SELECT Owner_Email as "Owner Email", Property_Name as "Property Name", Content as "Positive review" FROM Review where (Content LIKE "%great%" OR Content LIKE "%excellent%") and LENGTH(Content) > 25;

SELECT To_Airport as "Destination Airport", AVG(Cost) as "Average Cost", AVG(Capacity) as "Average Capacity" FROM Flight GROUP BY (To_Airport);

select property_name, owner_email, airport, distance from is_close_to where distance in (select min(distance) as closest_property from is_close_to group by airport);

SELECT A.Email, A.First_Name, A.Last_Name, C.Phone_Number from Accounts A JOIN Clients C
ON A.Email = C.Email
ORDER BY A.Last_Name;

select * from flight order by cost, flight_date desc;

SELECT Property_Name, Property_Owner, GROUP_CONCAT(Amenity_Name)
FROM Amenity
GROUP BY Property_Name, Property_Owner;

SELECT C.Email, C.CcNumber from Customer C JOIN Book B ON C.Email = B.Customer
WHERE B.Was_Cancelled = 1;

create or replace view v1 as  select f.airline_name, sum(num_seats) as total_seats from book b, flight f where b.flight_num = f.flight_num and b.airline_name = f.airline_name and flight_date = '2022-10-18' and not was_cancelled group by f.airline_name;
select airline.airline_name,  v1.total_seats from airline left join v1 on airline.airline_name = v1.airline_name;


SELECT 
	  c.First_Name AS owner_first_name,
      c.Last_Name AS owner_last_name,
      SUM(r.Num_Guests) AS total_guests
	FROM 
	  Accounts c 
	  INNER JOIN Reserve r ON c.Email = r.Owner_Email 
	  AND YEAR(r.Start_Date)= '2022'
	GROUP BY 
	  c.Email
	ORDER BY 
	  c.First_Name, c.Last_Name;

SELECT Property.Property_Name, Property.Owner_Email, COUNT(Review.Customer) AS Review_Count
	FROM Property
	LEFT JOIN Review ON Property.Property_Name = Review.Property_Name AND Property.Owner_Email = Review.Owner_Email
	GROUP BY Property.Property_Name, Property.Owner_Email
	HAVING COUNT(Review.Customer) > 0
	ORDER BY Review_Count DESC;

SELECT DISTINCT C.Email
	FROM Customer C
	JOIN Book B ON C.Email = B.Customer
	JOIN Flight F ON B.Flight_Num = F.Flight_Num AND B.Airline_Name = F.Airline_Name
	JOIN Airline A ON F.Airline_Name = A.Airline_Name
	GROUP BY C.Email
	HAVING AVG(A.Rating) > 4.0
	ORDER BY C.Email;

WITH PropertyAmenities AS (
	    SELECT Property_Name, Property_Owner, COUNT(*) AS Amenity_Count
	    FROM Amenity
	    GROUP BY Property_Name, Property_Owner
	)
	SELECT Property.Property_Name, Property.Owner_Email, COALESCE(Amenity_Count, 0) AS Amenity_Count
	FROM Property
	LEFT JOIN PropertyAmenities ON Property.Property_Name = PropertyAmenities.Property_Name
	ORDER BY Amenity_Count DESC;

WITH AirportTraffic AS (
	    SELECT From_Airport AS Airport_Id, COUNT(*) AS Departures, 0 AS Arrivals
	    FROM Flight
	    GROUP BY From_Airport
	    UNION ALL
	    SELECT To_Airport AS Airport_Id, 0 AS Departures, COUNT(*) AS Arrivals
	    FROM Flight
	    GROUP BY To_Airport
	)
	SELECT Airport_Id, SUM(Departures) + SUM(Arrivals) AS Total_Traffic
	FROM AirportTraffic
	GROUP BY Airport_Id
	ORDER BY Total_Traffic DESC
	LIMIT 5;












