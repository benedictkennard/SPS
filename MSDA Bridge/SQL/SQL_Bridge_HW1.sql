SELECT DISTINCT Dest, Distance FROM Flights ORDER BY Distance DESC LIMIT 1

SELECT DISTINCT Engines FROM planes ORDER BY Engines
	SELECT Engines, MAX(Seats) FROM Planes GROUP BY Engines
	SELECT DISTINCT Engines, Seats, Model FROM Planes WHERE Engines=1 AND Seats=16 OR Engines=2 AND Seats=400 OR Engines=3 AND Seats=379 OR Engines=4 AND Seats=450 ORDER BY Engines, Model

SELECT COUNT(*) FROM Flights

SELECT Carrier, COUNT(*) FROM Flights GROUP BY Carrier

SELECT Carrier, COUNT(*) FROM Flights GROUP BY Carrier ORDER BY COUNT(*) DESC

SELECT Carrier, COUNT(*) FROM Flights GROUP BY Carrier ORDER BY COUNT(*) DESC LIMIT 5

SELECT Carrier, COUNT(*) FROM Flights WHERE Distance > 1000 GROUP BY Carrier ORDER BY COUNT(*) DESC LIMIT 5

SELECT ROUND(MAX(wind_gust),2), Origin FROM Weather