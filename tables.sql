create table time_table (
	course_name varchar(50) NOT NULL,
	courseID varchar(5) NOT NULL,
    day_ varhar(3) not null,
	timing  varchar(30) NOT NULL,
	primary key(timing)
);

CREATE TABLE course_catalogue(
courseID varchar(5) NOT NULL, 
course_name varchar(30) NOT NULL,
department_name varchar(6) NOT NULL,
credit integer not null,
primary key(courseID)
);


create table pre_requisite_courses(
    course_id varchar(5) not null,
    course_name varchar(30) NOT NULL,
    prerequisite_course_id varchar(5) not null,
    primary key(course_id,prerequisite_course_id)
);

create table eligible_departments(
    course_id varchar(5) not null,
    course_name varchar(30) NOT NULL,
    depart_name varchar(30) not null,
    primary key(course_id,depart_name)
);


create table courses_offered(
courseId varchar(5) not null, 
year_ integer not null, 
course_name varchar(30) not NULL, 
sem varchar(30) not null, 
cgpa_required Dec(4,2) not NULL, 
instructor_id varchar(30) not NULL, 
timing varchar(30) not NULL, 
depart_name varchar(30) not NULL,
primary key(courseid, instructor_name));
   
create table time_table (
	course_name varchar(50) NOT NULL,
	courseID varchar(5) NOT NULL,
    day_ varhar(3) not null,
	timing  varchar(30) NOT NULL,
	primary key(timing)
);

create table section(
    section_name varchar(2) not null,
    course_id varchar(30) not null,
    course_name varchar(30) not null,
    instructor_id varchar(30) not null,
    primary key(section_name)
);

create table takes(
    student_id varchar(30) not null,
    student_name varchar(30) not null,
    course_id varchar(30) not null,
    grade_on_course integer not null,
	credit_of_course integer not null,
    depart_name varchar(10) not null,
    year_ integer not null,
    timing varchar(30) NOT NULL,
    sem integer not null,
    status integer not null,
    primary key(student_id)
);

create table ticket(
    student_id varchar(30) not null,
    course_id varchar(30) not null,
    instructor_id varchar(30) not null,
    course_name varchar(30) not null,
    status_faculty integer not null,
    status_batch_advisor integer not null,
    status_dean_academics integer not null,
    primary key(student_id)
);

create table instructor (
  instructor_id varchar(30) not null,
  name_ varchar(50) not null,
  department_name varchar(30) ,
  PRIMARY KEY (instructor_id)
);

create table batch_advisor(
    instructor_id varchar(30) not null,
    nam_ varchar(30) not null,
    department_name varchar(30) not null,
    primary key (instructor_id)
)

create table Dean (
    dean_id varchar(30) not null,
    nam_ varchar(30) not null,    
    primary key (dean_id) 
)