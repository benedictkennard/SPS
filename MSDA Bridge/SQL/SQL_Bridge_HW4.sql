CREATE SCHEMA `organization` ;
USE `organization` ;

DROP TABLE IF EXISTS tbl_Employees;

CREATE TABLE tbl_Employees (
  Employee_ID INT PRIMARY KEY,
  Employee_Name VARCHAR(30) NOT NULL,
  Supervisor_ID INT NULL,
  Title VARCHAR(30) NOT NULL
  );
  
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (1,'Jose',NULL,'CEO');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (2,'Maya',1,'Vice President');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (3,'Yara',1,'Vice President');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (4,'Jennette',1,'Assistant');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (5,'Yessenia',2,'Manager');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (6,'Isabella',3,'Manager');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (7,'Marlen',5,'Staff');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (8,'Jessie',5,'Staff');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (9,'Julie',6,'Staff');
INSERT INTO tbl_Employees (Employee_ID, Employee_Name, Supervisor_ID, Title) VALUES (10,'Gina',6,'Staff');

SELECT E.Employee_Name AS Employee, S.Employee_Name AS Supervisor
FROM tbl_Employees AS E
LEFT JOIN tbl_Employees AS S
ON S.Employee_ID=E.Supervisor_ID

DROP SCHEMA `organization` ;