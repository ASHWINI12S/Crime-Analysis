CREATE DATABASE CRIME_ANALYSIS;
USE CRIME_ANALYSIS;

CREATE TABLE Officer (
    OfficerID INT AUTO_INCREMENT PRIMARY KEY ,
    Name VARCHAR(255) NOT NULL,
    BadgeNumber VARCHAR(50) NOT NULL UNIQUE,
    Officer_Rank VARCHAR(50),
    Department VARCHAR(255)
);


CREATE TABLE Crime (
    CrimeID INT AUTO_INCREMENT PRIMARY KEY ,
    CrimeType VARCHAR(255) NOT NULL,
    DateReported DATE NOT NULL,
    Location VARCHAR(255) NOT NULL,
    Description TEXT,
    OfficerID INT,
   Constraint Fk_Crime_Officer FOREIGN KEY (OfficerID) REFERENCES Officer(OfficerID)
);

CREATE TABLE Criminal (
    CriminalID INT PRIMARY KEY AUTO_INCREMENT,
    Name VARCHAR(255) NOT NULL,
    DateOfBirth DATE,
    Gender CHAR(1),
    Address VARCHAR(255),
    CrimeID INT,
    ArrestedDate DATE,
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

CREATE TABLE Victim (
    VictimID INT PRIMARY KEY AUTO_INCREMENT,
    VictimName VARCHAR(255) NOT NULL,
    DateOfBirth DATE,
    Gender CHAR(1),
    Address VARCHAR(255),
    CrimeID INT,
    FOREIGN KEY (CrimeID) REFERENCES Crime(CrimeID)
);

#Count the total number of crimes:
SELECT COUNT(*)  TotalCrimes
FROM Crime;

#Count of Crime by diff CrimeType:
SELECT CrimeType,Count(CrimeType) CountOfCrimesbyCrimeType 
FROM Crime GROUP BY CrimeType ;

#Count of Crminal by Gender:
SELECT Gender,COUNT(CrimeID) FROM criminal GROUP BY Gender;

#Find the oldest criminal:
SELECT DateOfBirth,YEAR(curdate())-YEAR(DateOfBirth) Age from 
criminal ORDER BY DateOfBirth  LIMIT 1; 

#List all officers
Select officerId,officerName from officer;

#List all crimes:
SELECT CrimeID, Description FROM crime;

#Find the youngest criminal:
SELECT DateOfBirth,YEAR(curdate())-YEAR(DateOfBirth) Age from 
criminal ORDER BY DateOfBirth desc LIMIT 1; 

#Find the most recent crime reported:
SELECT * FROM crime
ORDER BY DateReported DESC LIMIT 1;

#Find the most recent criminal and crime:
select Cr.Name,C.CrimeType,C.DateReported,Cr.ArrestedDate from criminal Cr
INNER JOIN crime C
on Cr.CrimeID=C.CrimeID
order by Cr.ArrestedDate limit 1
;

#Crimes by Officer's Department:
SELECT Department,COUNT(OfficerID) TotalOfficers FROM officer GROUP BY Department;

#Count the total number of Officers by Officer_Rank:
SELECT Officer_Rank,COUNT(OfficerID) TotalOfficers FROM officer GROUP BY Officer_Rank;

#Find officers who have not reported any crimes:
select * from officer where OfficerID not in (select OfficerID from crime);

#Count of Lowest cases handle by officer
Select OfficerID,count(*)TotalCasesHandle from crime group by OfficerID order by TotalCasesHandle limit 1;

#Find the names of victims who were involved in crimes that occurred in the past 5 days:
Select victimName from victim where CrimeID in
(select CrimeID from crime 
where DateReported >= date_sub(curdate(),interval 5 day));

#Get the details of crimes that have victims but no associated criminals:
SELECT CrimeID, CrimeType, DateReported, Location
FROM Crime
WHERE CrimeID NOT IN (
    SELECT CrimeID
    FROM Criminal
) AND CrimeID IN (
    SELECT CrimeID
    FROM Victim
);

#Find the names of officers who have handled more than 10 crimes:
select OfficerName from officer where officerId in
(Select officerId from crime group by officerId  having count(crimeid)>10);

#Find the name of officer who handled more cases:
SELECT 
    O.OfficerName, COUNT(C.crimeid) TotalCrimeHandled
FROM
    officer O
        INNER JOIN
    crime C ON O.officerId = C.officerId
GROUP BY C.officerId
HAVING TotalCrimeHandled > 10
ORDER BY TotalCrimeHandled DESC
LIMIT 1;

#List all crimes and the dates they were reported along with the arrest dates
SELECT c.CrimeID, c.Description, c.DateReported, cr.ArrestedDate
FROM crime c
JOIN criminal cr ON c.CrimeID = cr.CrimeID;

#Address where most Criminal reside:
select Address,count(*) TotalCriminal from criminal 
group by Address order by count(*) desc limit 1;

#High-Crime Areas :
select Location,count(*) CrimeRate from crime 
group by Location order by count(*) desc limit 1;


#Total Robbery Cases:
Select count(*)Robbery_Cases from crime where CrimeType='Robbery';

#Crimes by Month
Select month(DateReported) Month,count(*)TotalCrime from crime 
group by Month;

#Crimes Involving a Specific Officer
SELECT COUNT(*) AS total 
FROM Crime C
JOIN Officer O ON C.OfficerID = O.OfficerID
WHERE O.OfficerName = 'Officer Mike Johnson';

#Crimes Involving a Specific Victim
select c.CrimeType,c.Description from crime c
inner join victim v
on c.CrimeID=v.CrimeID
where v.VictimName='Anna Roberts';

#Crimes by Victim's Age Group
Select 
 CASE 
    WHEN year(curdate())-year(V.DateOfBirth)  BETWEEN 0 AND 17 THEN '0-17'
    WHEN year(curdate())-year(V.DateOfBirth)  BETWEEN 18 AND 35 THEN '18-35'
    WHEN year(curdate())-year(V.DateOfBirth)  BETWEEN 36 AND 50 THEN '36-50'
    ELSE '51+'
END AS age_group, count(*)Total
from Victim  V
Inner Join Crime C
On V.CrimeID=C.CrimeID
group by age_group;

#Average Number of Crimes Per Day
SELECT AVG(daily_crimes) AS average_crimes_per_day from
(Select Count(*)daily_crimes from crime group by day(datereported))AS daily_crime_counts;