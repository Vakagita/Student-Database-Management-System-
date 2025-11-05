-- Create database (rename if you want)
IF DB_ID('StudentDB') IS NULL
    CREATE DATABASE StudentDB;
GO
USE StudentDB;
GO

-- Drop tables if re-running
IF OBJECT_ID('dbo.Enrollments','U') IS NOT NULL DROP TABLE dbo.Enrollments;
IF OBJECT_ID('dbo.Sections','U')   IS NOT NULL DROP TABLE dbo.Sections;
IF OBJECT_ID('dbo.Courses','U')    IS NOT NULL DROP TABLE dbo.Courses;
IF OBJECT_ID('dbo.Students','U')   IS NOT NULL DROP TABLE dbo.Students;
GO

-- Students
CREATE TABLE dbo.Students (
    StudentID     INT IDENTITY(1,1) PRIMARY KEY,
    FirstName     VARCHAR(50)  NOT NULL,
    LastName      VARCHAR(50)  NOT NULL,
    Email         VARCHAR(120) NOT NULL UNIQUE,
    DOB           DATE         NULL,
    Major         VARCHAR(80)  NULL,
    CreatedAt     DATETIME2    NOT NULL DEFAULT SYSUTCDATETIME()
);

-- Courses
CREATE TABLE dbo.Courses (
    CourseID      INT IDENTITY(1,1) PRIMARY KEY,
    CourseCode    VARCHAR(20)  NOT NULL UNIQUE,  -- e.g., MATH-24
    Title         VARCHAR(120) NOT NULL,
    Credits       TINYINT      NOT NULL CHECK (Credits BETWEEN 0 AND 6)
);

-- Sections (a course offered in a term)
CREATE TABLE dbo.Sections (
    SectionID     INT IDENTITY(1,1) PRIMARY KEY,
    CourseID      INT          NOT NULL,
    Term          VARCHAR(12)  NOT NULL CHECK (Term IN ('Winter','Spring','Summer','Fall')),
    [Year]        INT          NOT NULL CHECK ([Year] BETWEEN 2000 AND 2100),
    Instructor    VARCHAR(80)  NULL,
    CONSTRAINT FK_Sections_Courses
        FOREIGN KEY (CourseID) REFERENCES dbo.Courses(CourseID) ON DELETE CASCADE
);

-- Enrollments (student in a section + optional grade)
CREATE TABLE dbo.Enrollments (
    EnrollmentID  INT IDENTITY(1,1) PRIMARY KEY,
    StudentID     INT NOT NULL,
    SectionID     INT NOT NULL,
    EnrolledOn    DATE NOT NULL DEFAULT CAST(GETDATE() AS DATE),
    Grade         CHAR(1) NULL CHECK (Grade IN ('A','B','C','D','F','I','W')),
    CONSTRAINT FK_Enrollments_Students
        FOREIGN KEY (StudentID) REFERENCES dbo.Students(StudentID) ON DELETE CASCADE,
    CONSTRAINT FK_Enrollments_Sections
        FOREIGN KEY (SectionID) REFERENCES dbo.Sections(SectionID) ON DELETE CASCADE,
    CONSTRAINT UQ_Enrollments_OnePerSection UNIQUE (StudentID, SectionID)
);

-- Helpful indexes
CREATE INDEX IX_Students_LastFirst ON dbo.Students(LastName, FirstName);
CREATE INDEX IX_Sections_Course_Term ON dbo.Sections(CourseID, [Year], Term);
CREATE INDEX IX_Enrollments_Student ON dbo.Enrollments(StudentID);
GO
