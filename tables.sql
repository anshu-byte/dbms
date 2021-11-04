drop table if exists time_table;
create table time_table (
	course_name varchar NOT NULL,
	course_ID varchar NOT NULL,
    instructor_id varchar not null,
	timing  varchar NOT NULL,
    Primary key (course_id,instructor_id)
);

drop table if exists course_catalogue;
CREATE TABLE course_catalogue(
course_ID varchar NOT NULL, 
course_name varchar NOT NULL,
credit_of_course integer not null,
primary key(course_ID)
);

drop table if exists pre_requisite_courses;
create table pre_requisite_courses(
    course_id varchar not null,
    course_name varchar NOT NULL,
    prerequisite_course_id varchar not null,
    primary key(course_id,prerequisite_course_id)
);

drop table if exists eligible_departments;
create table eligible_departments(
    course_id varchar not null,
    course_name varchar NOT NULL,
    depart_name varchar not null,
    primary key(course_id,depart_name)
);

drop table if exists courses_offered;
create table courses_offered(
    course_Id varchar not null, 
    credit_of_course integer not null,
    year_ integer not null, 
    course_name varchar not NULL, 
    sem integer not null, 
    cgpa_required Dec(4,2) not NULL, 
    instructor_id varchar not NULL, 
    depart_name varchar not NULL,
    primary key (course_id,instructor_id)
);

-- primary key st_id and c_id and sem
drop table if exists takes;
create table takes(
    id serial,
    student_id varchar not null,
    student_name varchar not null,
    course_id varchar not null,
    grade_on_course integer not null,
	credit_of_course integer not null,
    depart_name varchar not null,
    year_ integer not null,
    timing varchar NOT NULL,
    sem integer not null,
    status integer not null,
    instructor_id varchar not null,
    primary key (id,student_id,course_id,sem)
);

drop table if exists ticket;
create table ticket(
    id serial,
    student_id varchar not null,
    student_name varchar not null,
    sem integer not null,
    year_ integer not null,
    depart_name varchar not null,
    course_id varchar not null,
    instructor_id varchar not null,
    course_name varchar not null,
    status_faculty integer not null,
    status_batch_advisor integer not null,
    status_dean_academics integer not null,
    primary key(id,student_id,course_id,instructor_id)
);

drop table if exists instructor;
create table instructor (
  instructor_id varchar not null,
  name_ varchar not null,
  PRIMARY KEY (instructor_id)
);

drop table if exists batch_advisor;
create table batch_advisor(
    instructor_id varchar not null,
    nam_ varchar not null,
    department_name varchar not null,
    primary key (department_name)
);

drop table if exists dean;
create table Dean (
    id serial primary key,
    dean_id varchar not null
);
