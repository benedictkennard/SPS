CREATE SCHEMA `rooms` ;
USE `rooms` ;

DROP TABLE IF EXISTS tbl_Users;
DROP TABLE IF EXISTS tbl_Groups;
DROP TABLE IF EXISTS tbl_Rooms;
DROP TABLE IF EXISTS tbl_UsersGroups;
DROP TABLE IF EXISTS tbl_GroupsRooms;

CREATE TABLE tbl_Users (
  User_ID INT PRIMARY KEY,
  User_Name VARCHAR(30) NOT NULL
  );
INSERT INTO tbl_Users (User_ID, User_Name) VALUES (1,'Modesto');
INSERT INTO tbl_Users (User_ID, User_Name) VALUES (2,'Ayine');
INSERT INTO tbl_Users (User_ID, User_Name) VALUES (3,'Christopher');
INSERT INTO tbl_Users (User_ID, User_Name) VALUES (4,'Cheong woo');
INSERT INTO tbl_Users (User_ID, User_Name) VALUES (5,'Saulat');
INSERT INTO tbl_Users (User_ID, User_Name) VALUES (6,'Heidy');
  
CREATE TABLE tbl_Groups (
  Group_ID INT PRIMARY KEY,
  Group_Name VARCHAR(30) NOT NULL
  );
INSERT INTO tbl_Groups (Group_ID, Group_Name) VALUES (1,'I.T.');
INSERT INTO tbl_Groups (Group_ID, Group_Name) VALUES (2,'Sales');
INSERT INTO tbl_Groups (Group_ID, Group_Name) VALUES (3,'Administration');
INSERT INTO tbl_Groups (Group_ID, Group_Name) VALUES (4,'Operations');
  
CREATE TABLE tbl_Rooms (
  Room_ID INT PRIMARY KEY,
  Room_Name VARCHAR(30) NOT NULL
  );
INSERT INTO tbl_Rooms (Room_ID, Room_Name) VALUES (1,'101');
INSERT INTO tbl_Rooms (Room_ID, Room_Name) VALUES (2,'102');
INSERT INTO tbl_Rooms (Room_ID, Room_Name) VALUES (3,'Auditorium A');
INSERT INTO tbl_Rooms (Room_ID, Room_Name) VALUES (4,'Auditorium B');

CREATE TABLE tbl_UsersGroups (
  User_ID INT NOT NULL REFERENCES tbl_Users,
  Group_ID INT NOT NULL REFERENCES tbl_Groups, 
  PRIMARY KEY (User_ID, Group_ID)
  );
INSERT INTO tbl_UsersGroups (User_ID, Group_ID) VALUES (1,1);
INSERT INTO tbl_UsersGroups (User_ID, Group_ID) VALUES (2,1);
INSERT INTO tbl_UsersGroups (User_ID, Group_ID) VALUES (3,2);
INSERT INTO tbl_UsersGroups (User_ID, Group_ID) VALUES (4,2);
INSERT INTO tbl_UsersGroups (User_ID, Group_ID) VALUES (5,3);

CREATE TABLE tbl_GroupsRooms (
  Group_ID INT NOT NULL REFERENCES tbl_Groups, 
  Room_ID INT NOT NULL REFERENCES tbl_Rooms, 
  PRIMARY KEY (Group_ID, Room_ID)
  );
INSERT INTO tbl_GroupsRooms (Group_ID, Room_ID) VALUES (1,1);
INSERT INTO tbl_GroupsRooms (Group_ID, Room_ID) VALUES (1,2);
INSERT INTO tbl_GroupsRooms (Group_ID, Room_ID) VALUES (2,2);
INSERT INTO tbl_GroupsRooms (Group_ID, Room_ID) VALUES (2,3);

SELECT G.Group_Name, U.User_Name 
FROM tbl_Groups AS G
LEFT JOIN tbl_UsersGroups AS UG
ON G.Group_ID = UG.Group_ID
LEFT JOIN tbl_Users AS U
ON UG.User_ID = U.User_ID

SELECT R.Room_Name, G.Group_Name 
FROM tbl_Rooms AS R
LEFT JOIN tbl_GroupsRooms AS GR
ON R.Room_ID = GR.Room_ID
LEFT JOIN tbl_Groups AS G
ON GR.Group_ID = G.Group_ID

SELECT U.User_Name, G.Group_Name, R.Room_Name
FROM tbl_Users AS U
LEFT JOIN tbl_UsersGroups AS UG 
ON U.User_ID = UG.User_ID
LEFT JOIN tbl_Groups AS G 
ON UG.Group_ID = G.Group_ID
LEFT JOIN tbl_GroupsRooms AS GR 
ON UG.Group_ID = GR.Group_ID
LEFT JOIN tbl_Rooms AS R 
ON GR.Room_ID = R.Room_ID
ORDER BY U.User_Name, G.Group_Name, R.Room_Name

DROP SCHEMA `rooms` ;