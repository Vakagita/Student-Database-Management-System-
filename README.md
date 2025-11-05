# Student Database Management System (SQL Server)

## Files
- `01_create_db.sql` — creates DB + tables + constraints + indexes
- `02_seed_data.sql` — sample data (students, courses, sections, enrollments)
- `03_views_procs.sql` — views and stored procedures (GPA, transcript, roster, etc.)
- `04_queries.sql` — example queries and proc calls

## How to run (SSMS)
1. Run `01_create_db.sql`
2. Run `02_seed_data.sql`
3. Run `03_views_procs.sql`
4. Run `04_queries.sql` to test

## Notes
- Grades allowed: `A,B,C,D,F,I,W` (I/W don’t impact GPA)
- One enrollment per student per section is enforced (unique constraint)
- Cascades: deleting a course -> deletes sections -> deletes enrollments; deleting a student -> deletes their enrollments
