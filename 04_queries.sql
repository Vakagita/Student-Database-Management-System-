USE StudentDB;
GO

-- Quick examples

-- 1) All students
SELECT * FROM dbo.Students ORDER BY LastName, FirstName;

-- 2) Ava Nguyen's current schedule
SELECT * FROM dbo.vw_StudentSchedule
WHERE StudentID = (SELECT StudentID FROM dbo.Students WHERE Email='ava.nguyen@example.edu');

-- 3) GPA report (all)
SELECT * FROM dbo.vw_StudentGPA ORDER BY LastName, FirstName;

-- 4) Parameterized calls
DECLARE @sid INT = (SELECT StudentID FROM dbo.Students WHERE Email='maya.garcia@example.edu');
EXEC dbo.usp_AddStudent @FirstName='Noah', @LastName='Ramirez', @Email='noah.ramirez@example.edu', @Major='Data Science';
EXEC dbo.usp_GetTranscript @StudentID = @sid;

-- 5) Find students failing something
SELECT DISTINCT s.StudentID, s.FirstName, s.LastName
FROM dbo.Enrollments e
JOIN dbo.Students s ON s.StudentID=e.StudentID
WHERE e.Grade='F';

-- 6) Section roster by CourseCode
DECLARE @section INT =
(
    SELECT TOP 1 sec.SectionID
    FROM dbo.Sections sec
    JOIN dbo.Courses c ON c.CourseID=sec.CourseID
    WHERE c.CourseCode='CS-1A' AND sec.Term='Fall' AND sec.[Year]=2025
    ORDER BY sec.SectionID
);
EXEC dbo.usp_GetRoster @SectionID=@section;
