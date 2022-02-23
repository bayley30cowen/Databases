-- Answer to the 2nd Database Assignment 2019/20
--
-- 184514
-- Please insert your candidate number in the line above.
-- Do NOT remove ANY lines of this template.


-- In each section below put your answer in a new line 
-- BELOW the corresponding comment.
-- Use ONE SQL statement ONLY per question.
-- If you don’t answer a question just leave 
-- the corresponding space blank. 
-- Anything that does not run in SQL you MUST put in comments.
-- Your code should never throw a syntax error.
-- Questions with syntax errors will receive zero marks.

-- DO NOT REMOVE ANY LINE FROM THIS FILE.

-- START OF ASSIGNMENT CODE


-- @@01
DROP TABLE IF EXISTS Hospital_MedicalRecord;
CREATE TABLE Hospital_MedicalRecord (
recNo SMALLINT UNSIGNED,
patient CHAR(9),
doctor CHAR(9),
enteredOn TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
diagnosis MEDIUMTEXT NOT NULL,
treatment VARCHAR(1000),
PRIMARY KEY (recNo, patient),
CONSTRAINT FK_patient 
FOREIGN KEY (patient) REFERENCES Hospital_Patient(NINumber) 
ON DELETE CASCADE,
CONSTRAINT FK_doctor 
FOREIGN KEY (doctor) REFERENCES Hospital_Doctor(NINumber) 
ON DELETE SET NULL
);

-- @@02
ALTER TABLE Hospital_MedicalRecord
ADD duration TIME;

-- @@03
UPDATE Hospital_Doctor
SET salary = salary * 0.9
WHERE expertise LIKE 'ear%' OR expertise LIKE '%,ear%';


-- @@04
SELECT fname, lname, REPLACE(CONCAT(YEAR(dateOfBirth)), ',', '') AS born
FROM Hospital_Patient
WHERE city LIKE BINARY '%right%'
ORDER BY lname, fname;



-- @@05
SELECT NINumber, fname, lname, ROUND((weight/(height/100)), 3) AS BMI
FROM Hospital_Patient
WHERE FLOOR(DATEDIFF(CURDATE(),dateOfBirth)/365.25) < 30;


-- @@06
SELECT COUNT(*) AS `number`
FROM Hospital_Doctor;


-- @@07
SELECT NINumber, lname, COUNT(doctor) AS operations
FROM Hospital_Doctor JOIN Hospital_CarriesOut
WHERE Hospital_Doctor.NINumber = Hospital_CarriesOut.doctor AND YEAR(startDateTime) = YEAR(CURDATE()) 
GROUP BY NINumber, lname
ORDER BY operations DESC;



-- @@08
SELECT B.NINumber, UPPER(LEFT(B.fname, 1)) AS init, B.lname
FROM Hospital_Doctor A JOIN Hospital_Doctor B
WHERE B.NINumber = A.mentored_by AND B.mentored_by IS NULL;


-- @@09
SELECT A.theatreNo AS theatre, CAST(A.startDateTime AS time) AS startTime1, CAST(B.startDateTime AS time) AS startTime2 
FROM Hospital_Operation A , Hospital_Operation B
WHERE A.startDateTime < (B.startDateTime + B.duration)
AND (A.startDateTime + A.duration) > B.startDateTime
AND A.startDateTime <> B.startDateTime
AND A.startDateTime < B.startDateTime;


-- @@10
SELECT * FROM
(SELECT theatreNo, DAY(startDateTime) AS dom, MONTHNAME(startDateTime) AS `month`, REPLACE(CONCAT(YEAR(startDateTime)), ',', '') AS `year`, COUNT(theatreNo) AS numOps
FROM Hospital_Operation
GROUP BY theatreNo, dom, `month`, `year`
ORDER BY theatreNo, `year`, `month`, dom)p
WHERE (p.theatreNo, p.numOps) IN
(SELECT a.theatreNo, MAX(a.numOps) FROM
(SELECT theatreNo, DAY(startDateTime) AS dom, MONTHNAME(startDateTime) AS `month`, REPLACE(CONCAT(YEAR(startDateTime)), ',', '') AS `year`, COUNT(theatreNo) AS numOps
FROM Hospital_Operation
GROUP BY theatreNo, dom, `month`, `year`
)a
GROUP BY a.theatreNo);

-- @@11 
SELECT a.theatreNo, IFNULL(lmay,0) AS lastMay, IFNULL(tmay,0) AS thisMay, (IFNULL(tmay,0) - IFNULL(lmay,0)) AS increase
FROM Hospital_Operation a
LEFT OUTER JOIN(
(SELECT (b.theatreNo), COUNT(*) AS lmay
FROM Hospital_Operation b
WHERE (YEAR(b.startDateTime) = 2018) AND MONTH(b.startDateTime) = 5
GROUP BY b.theatreNo) AS may2018)
ON (may2018.theatreNo = a.theatreNo)
INNER JOIN (
(SELECT (b.theatreNo), COUNT(*) AS tmay
FROM Hospital_Operation b
WHERE(YEAR(b.startDateTime) = 2019) AND MONTH(b.startDateTime) = 5
GROUP BY b.theatreNo) AS may2019)
ON (may2019.theatreNo = a.theatreNo)
WHERE((IFNULL(tmay,0) - IFNULL(lmay,0)) >0)
GROUP BY a.theatreNo
ORDER BY increase DESC;


-- @@12 HeiqiSQL detects SYNTAX Error but i cannot find it 
DELIMITER $$
CREATE FUNCTION usage_theatre (theatre TINYINT, `year` TINYINT) RETURNS TEXT
BEGIN
	DECLARE intResult INT;
	DECLARE stringResult TEXT;
	SET intResult = (SELECT SUM(TIME_TO_SEC(t1.duration))
FROM Hospital_Operation t1
WHERE(t1.theatreNo = theatre AND YEAR(t1.startDateTime)=`year`));
	SELECT CONCAT(
		FLOOR(TIME_FORMAT(SEC_TO_TIME(intResult), '%H') /24), 'days', MOD(TIME_FORMAT(SEC_TO_TIME(intResult), '%H'),24), 'hrs', TIME_FORMAT(SEC_TO_TIME(intResult), '%i')) INTO stringResult;
RETURN stringResult;
		END
$$

-- END OF ASSIGNMENT CODE
