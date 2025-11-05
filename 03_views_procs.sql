USE StudentDB;
GO

-- View: Student schedule with course + section info
IF OBJECT_ID('dbo.vw_StudentSchedule','V') IS NOT NULL DROP VIEW dbo.vw_StudentSchedule;
GO
CREATE VIEW dbo.vw_StudentSchedule AS
SELECT
    s.StudentID,
    s.FirstName, s.LastName,
    c.CourseCode, c.Title, c.Credits,
    sec.SectionID, sec.Term, sec.[Year], sec.Instructor,
    e.EnrolledOn, e.Grade
FROM dbo.Enrollments e
JOIN dbo.Students s ON s.StudentID = e.StudentID
JOIN dbo.Sections sec ON sec.SectionID = e.SectionID
JOIN dbo.Courses c ON c.CourseID = sec.CourseID;
GO

-- View: GPA per student (A=4, B=3, C=2, D=1, F=0; I/W ignored)
IF OBJECT_ID('dbo.vw_StudentGPA','V') IS NOT NULL DROP VIEW dbo.vw_StudentGPA;
GO
CREATE VIEW dbo.vw_StudentGPA AS
WITH Graded AS (
    SELECT
        e.StudentID,
        c.Credits,
        CASE e.Grade
            WHEN 'A' THEN 4.0
            WHEN 'B' THEN 3.0
            WHEN 'C' THEN 2.0
            WHEN 'D' THEN 1.0
            WHEN 'F' THEN 0.0
            ELSE NULL
        END AS Points
    FROM dbo.Enrollments e
    JOIN dbo.Sections sec ON sec.SectionID = e.SectionID
    JOIN dbo.Courses c ON c.CourseID = sec.CourseID
    WHERE e.Grade IN ('A','B','C','D','F')
)
SELECT
    s.StudentID,
    s.FirstName, s.LastName,
    CAST(SUM(Points * Credits) / NULLIF(SUM(Credits),0) AS DECIMAL(4,2)) AS GPA
FROM dbo.Students s
LEFT JOIN Graded g ON g.StudentID = s.StudentID
GROUP BY s.StudentID, s.FirstName, s.LastName;
GO

-- Stored proc: Add student
IF OBJECT_ID('dbo.usp_AddStudent','P') IS NOT NULL DROP PROCEDURE dbo.usp_AddStudent;
GO
CREATE PROCEDURE dbo.usp_AddStudent
    @FirstName VARCHAR(50),
    @LastName  VARCHAR(50),
    @Email     VARCHAR(120),
    @DOB       DATE       = NULL,
    @Major     VARCHAR(80)= NULL
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Students (FirstName, LastName, Email, DOB, Major)
    VALUES (@FirstName, @LastName, @Email, @DOB, @Major);

    SELECT SCOPE_IDENTITY() AS NewStudentID;
END
GO

-- Stored proc: Enroll student into a section
IF OBJECT_ID('dbo.usp_EnrollStudent','P') IS NOT NULL DROP PROCEDURE dbo.usp_EnrollStudent;
GO
CREATE PROCEDURE dbo.usp_EnrollStudent
    @StudentID INT,
    @SectionID INT
AS
BEGIN
    SET NOCOUNT ON;
    INSERT INTO dbo.Enrollments (StudentID, SectionID)
    VALUES (@StudentID, @SectionID);

    SELECT SCOPE_IDENTITY() AS NewEnrollmentID;
END
GO

-- Stored proc: Record or update a grade
IF OBJECT_ID('dbo.usp_RecordGrade','P') IS NOT NULL DROP PROCEDURE dbo.usp_RecordGrade;
GO
CREATE PROCEDURE dbo.usp_RecordGrade
    @StudentID INT,
    @SectionID INT,
    @Grade     CHAR(1)
AS
BEGIN
    SET NOCOUNT ON;
    UPDATE dbo.Enrollments
    SET Grade = @Grade
    WHERE StudentID=@StudentID AND SectionID=@SectionID;

    SELECT * FROM dbo.Enrollments WHERE StudentID=@StudentID AND SectionID=@SectionID;
END
GO

-- Stored proc: Transcript (by student)
IF OBJECT_ID('dbo.usp_GetTranscript','P') IS NOT NULL DROP PROCEDURE dbo.usp_GetTranscript;
GO
CREATE PROCEDURE dbo.usp_GetTranscript
    @StudentID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT
        c.CourseCode, c.Title, c.Credits,
        sec.Term, sec.[Year], e.Grade
    FROM dbo.Enrollments e
    JOIN dbo.Sections sec ON sec.SectionID = e.SectionID
    JOIN dbo.Courses c ON c.CourseID = sec.CourseID
    WHERE e.StudentID = @StudentID
    ORDER BY [Year], Term, CourseCode;

    SELECT GPA FROM dbo.vw_StudentGPA WHERE StudentID=@StudentID;
END
GO

-- Stored proc: Section roster
IF OBJECT_ID('dbo.usp_GetRoster','P') IS NOT NULL DROP PROCEDURE dbo.usp_GetRoster;
GO
CREATE PROCEDURE dbo.usp_GetRoster
    @SectionID INT
AS
BEGIN
    SET NOCOUNT ON;
    SELECT s.StudentID, s.FirstName, s.LastName, s.Email, e.EnrolledOn, e.Grade
    FROM dbo.Enrollments e
    JOIN dbo.Students s ON s.StudentID=e.StudentID
    WHERE e.SectionID=@SectionID
    ORDER BY s.LastName, s.FirstName;
END
GO
