CREATE SCHEMA `videos` ;

DROP TABLE IF EXISTS tbl_Videos;
DROP TABLE IF EXISTS tbl_Reviewers;

CREATE TABLE tbl_Videos
(
  video_id INT PRIMARY KEY,
  title VARCHAR(70) NOT NULL,
  length TIME NOT NULL,
  url TEXT NOT NULL
);
INSERT INTO tbl_Videos (video_id, title, length, url) VALUES (1,'SQL: Combining Multiple Tables','00:04:18',' https://www.youtube.com/watch?v=WrPnAByl7d0');
INSERT INTO tbl_Videos (video_id, title, length, url) VALUES (2,'Databases - Episode 6 - Joining Tables','00:05:39',' https://www.youtube.com/watch?v=79EBoVPUzkE');
INSERT INTO tbl_Videos (video_id, title, length, url) VALUES (3,'OneToMany','00:04:57',' https://www.youtube.com/watch?v=tX4_j-74lPQ');

CREATE TABLE tbl_Reviewers
(
  user_id INT NOT NULL,
  username VARCHAR(30) NOT NULL,
  rating INT NULL CHECK (rating BETWEEN 0 AND 5 OR rating IS NULL),
  review TEXT NOT NULL,
  vid_id INT NOT NULL REFERENCES tbl_Videos,
  PRIMARY KEY (user_id, vid_id)
);
INSERT INTO tbl_Reviewers (user_id, username, rating, review, vid_id) VALUES (1, 'John', 0, 'Hated it!',1);
INSERT INTO tbl_Reviewers (user_id, username, rating, review, vid_id) VALUES (2, 'Jane', 5, 'Loved it!',1);
INSERT INTO tbl_Reviewers (user_id, username, rating, review, vid_id) VALUES (2, 'Jane', 1, 'Disliked it.',2);
INSERT INTO tbl_Reviewers (user_id, username, rating, review, vid_id) VALUES (1, 'John', 4, 'Liked it.',2);
INSERT INTO tbl_Reviewers (user_id, username, review, vid_id) VALUES (1, 'John', 'Meh.',3);
INSERT INTO tbl_Reviewers (user_id, username, rating, review, vid_id) VALUES (2, 'Jane', 3, 'Okay.',3);

SELECT V.*, R.*
FROM tbl_Videos AS V
INNER JOIN  tbl_Reviewers AS R
ON V.video_id = R.vid_id
ORDER BY V.video_id, R.user_id;