create table time_table (
	course_name varchar NOT NULL,
	courseID varchar NOT NULL,
    day_ varhar not null,
	timing  varchar NOT NULL,
	primary key(timing)
);

CREATE TABLE course_catalogue(
courseID varchar NOT NULL, 
course_name varchar NOT NULL,
department_name varchar NOT NULL,
credit integer not null,
primary key(courseID)
);


create table pre_requisite_courses(
    course_id varchar not null,
    course_name varchar NOT NULL,
    prerequisite_course_id varchar not null,
    primary key(pre_requisite_course_id)
);

create table eligible_departments(
    course_id varchar not null,
    course_name varchar NOT NULL,
    depart_name varchar not null,
    primary key(depart_name)
);


create table courses_offered(
courseId varchar not null, 
year_ integer not null, 
course_name varchar not NULL, 
sem varchar not null, 
cgpa_required Dec(4,2) not NULL, 
instructor_id varchar not NULL, 
timing varchar not NULL, 
depart_name varchar not NULL,
primary key(courseid, instructor_name));
   
create table time_table (
	course_name varchar NOT NULL,
	courseID varchar NOT NULL,
    day_ varhar not null,
	timing  varchar NOT NULL,
	primary key(timing)
);

create table section(
    section_name varchar not null,
    course_id varchar not null,
    course_name varchar not null,
    instructor_id varchar not null,
    primary key(section_name)
);

create table takes(
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
    primary key(student_id)
);

create table ticket(
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
    primary key(student_id)
);

create table instructor (
  instructor_id varchar not null,
  name_ varchar not null,
  department_name varchar ,
  PRIMARY KEY (instructor_id)
);

create table batch_advisor(
    instructor_id varchar not null,
    nam_ varchar not null,
    department_name varchar not null,
    primary key (instructor_id)
)

create table Dean (
    dean_id varchar not null,  
    primary key (dean_id) 
)
