create ROLE dean
LOGIN
PASSWORD 'dean';

GRANT ALL
ON ALL TABLES
IN SCHEMA "public"
TO dean;

create role student 
LOGIN
PASSWORD 'student';

GRANT SELECT
ON course_catalogue
TO student;

GRANT SELECT
ON time_table
TO student;

GRANT SELECT
ON pre_requisite_courses
TO student;

GRANT SELECT
ON eligible_departments
TO student;

GRANT SELECT
ON courses_offered
TO student;

GRANT INSERT
ON takes
TO student;

GRANT INSERT
ON ticket
TO student;

create role instructor 
LOGIN
PASSWORD 'instructor';

GRANT UPDATE
ON ticket
TO instructor;

GRANT SELECT
ON course_catalogue
TO instructor;

GRANT SELECT
ON time_table
TO instructor;

GRANT INSERT, UPDATE, DELETE
ON pre_requisite_courses
TO instructor;

GRANT INSERT, UPDATE, DELETE
ON eligible_departments
TO instructor;

GRANT INSERT, UPDATE, DELETE
ON courses_offered
TO instructor;


create role batch_advisor 
login
PASSWORD 'batch_advisor';

GRANT UPDATE
ON ticket
TO batch_advisor;

GRANT SELECT
ON course_catalogue
TO batch_advisor;

GRANT SELECT
ON time_table
TO batch_advisor;


-- drop role student;
-- drop role instructor;
-- drop role batch_advisor;
-- drop role dean;


-- create user anshu with PASSWORD '123';

-- GRant student to anshu;

-- \c - anshe