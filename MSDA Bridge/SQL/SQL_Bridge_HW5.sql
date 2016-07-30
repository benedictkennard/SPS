CREATE SCHEMA `BuildingEnergy`;
USE `BuildingEnergy`;

DROP TABLE IF EXISTS EnergyCategories;
DROP TABLE IF EXISTS EnergyTypes;
DROP TABLE IF EXISTS Buildings;
DROP TABLE IF EXISTS BuildingsEnergyTypes;

CREATE TABLE EnergyCategories (
  Category_ID INT PRIMARY KEY,
  Category VARCHAR(30) NOT NULL
  );
INSERT INTO EnergyCategories (Category_ID, Category) VALUES (1,'Fossil');
INSERT INTO EnergyCategories (Category_ID, Category) VALUES (2,'Renewable');  
  
  CREATE TABLE EnergyTypes (
  Type_ID INT PRIMARY KEY,
  EnergyType VARCHAR(30) NOT NULL,
  Category_ID INT NOT NULL REFERENCES EnergyCategories
  );
INSERT INTO EnergyTypes (Type_ID, EnergyType, Category_ID) VALUES (1,'Electricity',1);
INSERT INTO EnergyTypes (Type_ID, EnergyType, Category_ID) VALUES (2,'Gas',1);    
INSERT INTO EnergyTypes (Type_ID, EnergyType, Category_ID) VALUES (3,'Steam',1);
INSERT INTO EnergyTypes (Type_ID, EnergyType, Category_ID) VALUES (4,'Fuel Oil',1);
INSERT INTO EnergyTypes (Type_ID, EnergyType, Category_ID) VALUES (5,'Solar',2);
INSERT INTO EnergyTypes (Type_ID, EnergyType, Category_ID) VALUES (6,'Wind',2);  

SELECT C.Category, T.EnergyType
FROM EnergyTypes AS T
JOIN EnergyCategories AS C
ON T.Category_ID = C.Category_ID
ORDER BY C.Category, T.EnergyType;

  CREATE TABLE Buildings (
  Building_ID INT PRIMARY KEY,
  Building VARCHAR(50) NOT NULL
  );
INSERT INTO Buildings (Building_ID, Building) VALUES (1,'Empire State Building');
INSERT INTO Buildings (Building_ID, Building) VALUES (2,'Chrysler Building');
INSERT INTO Buildings (Building_ID, Building) VALUES (3,'Borough of Manhattan Community College');

  CREATE TABLE BuildingsEnergyTypes (
  Building_ID INT REFERENCES Buildings,
  Type_ID INT REFERENCES EnergyTypes,
  PRIMARY KEY (Building_ID, Type_ID)
  );
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (1,1);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (1,2);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (1,3);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (2,1);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (2,3);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (3,1);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (3,3);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (3,5);

SELECT B.Building, T.EnergyType
FROM Buildings AS B
JOIN BuildingsEnergyTypes AS BT
ON B.Building_ID = BT.Building_ID
JOIN EnergyTypes AS T
ON BT.Type_ID = T.Type_ID
ORDER BY B.Building, T.EnergyType;

INSERT INTO EnergyTypes (Type_ID, EnergyType, Category_ID) VALUES (7,'Geothermal',2);  
INSERT INTO Buildings (Building_ID, Building) VALUES (4,'Bronx Lion House');
INSERT INTO Buildings (Building_ID, Building) VALUES (5,'Brooklyn Childrens Museum');
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (4,7);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (5,1);
INSERT INTO BuildingsEnergyTypes (Building_ID, Type_ID) VALUES (5,7);

SELECT B.Building, T.EnergyType, C.Category
FROM Buildings AS B
JOIN BuildingsEnergyTypes AS BT
ON B.Building_ID = BT.Building_ID
JOIN EnergyTypes AS T
ON BT.Type_ID = T.Type_ID
JOIN EnergyCategories AS C
ON T.Category_ID = C.Category_ID
WHERE C.Category_ID = 2;

SELECT T.EnergyType, COUNT(T.EnergyType)
FROM Buildings AS B
JOIN BuildingsEnergyTypes AS BT
ON B.Building_ID = BT.Building_ID
JOIN EnergyTypes AS T
ON BT.Type_ID = T.Type_ID
GROUP BY T.EnergyType
ORDER BY COUNT(T.EnergyType) DESC;

ALTER TABLE EnergyTypes
ADD FOREIGN KEY (Category_ID)
REFERENCES EnergyCategories(Category_ID);

ALTER TABLE BuildingsEnergyTypes
ADD FOREIGN KEY (Building_ID)
REFERENCES Buildings(Building_ID);

ALTER TABLE BuildingsEnergyTypes
ADD FOREIGN KEY (Type_ID)
REFERENCES EnergyTypes(Type_ID);

DROP SCHEMA `BuildingEnergy`;