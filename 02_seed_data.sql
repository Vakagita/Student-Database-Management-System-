USE StudentDB;
GO

-- Students
INSERT INTO dbo.Students (FirstName, LastName, Email, DOB, Major) VALUES
('Ava','Nguyen','ava.nguyen@example.edu','2004-03-10','Data Science'),
('Leo','Patel','leo.patel@example.edu','2003-09-22','Computer Science'),
('Maya','Garcia','maya.garcia@example.edu','2004-12-02','Statistics');

-- Courses
INSERT INTO dbo.Courses (CourseCode, Title, Credits) VALUES
('CS-1A',   'Intro to Programming (Python)', 4),
('DATA-20', 'Data Science Principles',       4),
('MATH-24', 'Linear Algebra',                5);

-- Sections (e.g., Fall 2025)
INSERT INTO dbo.Sections (CourseID, Term, [Year], Instructor)
SELECT CourseID, 'Fall', 2025, 'Dr. Kim' FROM dbo.Courses WHERE CourseCode='CS-1A';
INSERT INTO dbo.Sections (CourseID, Term, [Year], Instructor)
SELECT CourseID, 'Fall', 2025, 'Prof. Lee' FROM dbo.Courses WHERE CourseCode='DATA-20';
INSERT INTO dbo.Sections (CourseID, Term, [Year], Instructor)
SELECT CourseID, 'Fall', 2025, 'Dr. Chen' FROM dbo.Courses WHERE CourseCode='MATH-24';

-- Enrollments
-- Ava -> CS-1A + DATA-20
INSERT dbo.Enrollments (StudentID, SectionID)
SELECT s.StudentID, sec.SectionID
FROM dbo.Students s
JOIN dbo.Sections sec ON sec.Term='Fall' AND sec.[Year]=2025
WHERE s.Email='ava.nguyen@example.edu' AND sec.SectionID IN (
    (SELECT SectionID FROM dbo.Sections sec JOIN dbo.Courses c ON c.CourseID=sec.CourseID WHERE c.CourseCode='CS-1A'   AND Term='Fall' AND [Year]=2025),
    (SELECT SectionID FROM dbo.Sections sec JOIN dbo.Courses c ON c.CourseID=sec.CourseID WHERE c.CourseCode='DATA-20' AND Term='Fall' AND [Year]=2025)
);

-- Leo -> MATH-24
INSERT dbo.Enrollments (StudentID, SectionID)
SELECT s.StudentID, sec.SectionID
FROM dbo.Students s
JOIN dbo.Sections sec ON sec.Term='Fall' AND sec.[Year]=2025
JOIN dbo.Courses c ON c.CourseID=sec.CourseID AND c.CourseCode='MATH-24'
WHERE s.Email='leo.patel@example.edu';

-- Set a couple grades
UPDATE e
SET Grade = 'A'
FROM dbo.Enrollments e
JOIN dbo.Students s ON s.StudentID=e.StudentID AND s.Email='ava.nguyen@example.edu';

UPDATE e
SET Grade = 'B'
FROM dbo.Enrollments e
JOIN dbo.Students s ON s.StudentID=e.StudentID AND s.Email='leo.patel@example.edu';
GO
