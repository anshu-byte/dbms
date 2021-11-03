create or replace procedure instructor_offer(
  couresId varchar(5),
  course_name varchar(30),
  cgpa_required Dec(4,2),
  course_instructor_id varchar(30),
  depart_name varchar(5),
  sem integer,
  year_ integer,
  timing varchar(15),
  instructor_id varchar(30)
)
language plpgsql
as $$
declare
counter_ integer; 
begin 
  select count(*) into counter_ from course_catalogue as co where co.courseid=coureseid;
  if counter_>0 then
    insert into courses_offered(courseid,year_,course_name,sem, cgpa_required,instructor_id,timing,depart_name)
    values(courseid,year_,course_name,sem, cgpa_required,instructor_id,timing,depart_name);
end; $$

Create or replace function report_generation(
    @s_id varchar
)
returns table(course_name varchar, course_id varchar, grade_on_course integer)
language plpgsql
as $$
begin
  
return
    select
        course_name,
        course_id,
        grade_on_course,
    From
        takes
    where
        takes.status = 1 and  takes.student_id = @s_id;

end; $$

-- SELECT * FROM report_generation('s_id'); (to call this function)
create or replace procedure cg_calculation(
    student_id varchar(30),
    INOUT cg)
language plpgsql
as $$
declare  
    numerator integer,
    denominator integer,
    integer
begin
    select COALESCE sum (grade_on_course*credit_of_course) into numerator from  (select takes.grade_on_course, takes.credit_of_course from takes where takes.student_id = student_id and takes.status = 1) as numerator_multiplication
    (grade_on_course, credit_of_course);
    select COALESCE sum (credit_of_course) into denominator from  (select takes.credit_of_course from takes where takes.student_id = student_id and takes.status = 1) as denominator_sum
    (credit_of_course);
    CAST( numerator as DOUBLE);
    CAST(denominator as DOUBLE);
    cg := numerator/denominator
end;

create or replace procedure credit_limit(
    IN student_id varchar(30),
	IN current_sem integer,
	INOUT credit_limit DEC(4,2)
)
language plpgsql
as $$
declare
current_sem integer;
current_year integer;
last_sem integer;
secondlast_sem integer;
begin
   select sem, year_ into current_sem, current_year  from takes as t where t.status = 0 and  t.student_id = student_id;
  IF current_sem >=3 then
    If current_sem % 2 = 0 then
        select sum (credit_of_course) into last_sem from  (select takes.credit_of_course from takes where takes.student_id = student_id 
        and sem = current_sem - 1 and takes.status = 1 and year=current_year) as temp1
        (credit_of_course);
        select sum (credit_of_course) into secondlast_sem from  (select takes.credit_of_course from takes where takes.student_id = student_id 
        and sem = current_sem - 2 and takes.status = 1 and year = current_year - 1) as temp2 (credit_of_course);
        credit_limit = round(1.25 * (last_sem + secondlast_sem)/2,2);
    ELSE 
        select sum (credit_of_course) into last_sem from  (select takes.credit_of_course from takes where takes.student_id = student_id 
        and sem = current_sem - 1 and takes.status = 1 and  year=current_year-1) as temp1
        (credit_of_course);
        select sum (credit_of_course) into secondlast_sem from  (select takes.credit_of_course from takes where takes.student_id = student_id 
        and sem = current_sem - 2 and takes.status = 1 and year=current_year-1) as temp2 (credit_of_course);
        credit_limit = round(1.25 * (last_sem + secondlast_sem)/2,2);
    END IF;
  else
    set credit_limit = 24;
  END IF;
end; $$

create or replace procedure pre_requisite_check(
    course_id varchar(30),
    student_id varchar(30),
    INOUT result,
)
language plpgsql
as $$
declare
pre_status integer;
begin
    (select t.course_id from takes as t where t.status = 1 and t.student_id = student_id) as completed_courses (completed);
    (select pr.pre_requisite_course_id from pre_requisite_courses as pr where pr.course_id=course_id) as required_courses (required);
    select count(*) into pre_status from required_courses.completed not exists (select completed_courses.completed from completed_courses);
    if pre_status = 0 then
        result = 1
    ELSE
        result = 0
    end if
end; $$

create or replace procedure student_department_allowed(
    course_id varchar(30),
    student_id varchar(30),
    INOUT result,
)
language plpgsql
as $$
declare
pre_status integer;
begin
    (select t.depart_name from takes as t where t.student_id = student_id) as current_departs (current);
    (select ed.depart_name from eligible_departments as ed where ed.course_id=course_id) as required_departs (required);
    select count(*) into pre_status from required_departs.current not exists (select current_departs.current from current_departs);
    if pre_status = 0 then
        result = 1
    ELSE
        result = 0
    end if
end; $$
create or replace procedure slot_free(
    IN student_id varchar(30),
    IN s_ integer,
    IN course_id varchar(30),
    IN y_ integer,
    INOUT result smallint
)
as $$
declare
t_id varchar;
number_of_clashes integer;
begin
select timing into t_id
from courses_offered as co where co.course_id = course_id and co.year_ = y_ and co.sem = s_;
select count (*) into number_of_clashes
from takes as t, courses_offered as co
where t.student_id = student_id and t.course_id = co.course_id and t.year_ = co.year_ 
and t.sem = co.sem and t.timing = t_id and t.year_ = y_ and t.sem = s_;
if number_of_clashes = 0 then
    result = 1;
else 
    result = 0;
end if;
  
end; $$

create or replace grade_entry(
    course_id varchar(30),
    student_id varchar(30),
    instructor_id varchar(30),
    status integer
)
language plpgsql
as $$
begin
    create table temp_table(
    student_id varchar(30) not null,
    student_name varchar(30) not null,
    course_id varchar(30) not null,
    grade_on_course integer not null,
    instructor_id  varchar(30) not null,
    year_ integer not null,
    sem integer not null,
    status integer not null,
    primary key(student_id));
    COPY temp_table(student_id,student_name,course_id,grade_on_course,instructor_id,year_,sem,status)
    FROM 'C:\Users\anshu\Desktop\Project\grade_sheet.csv'
    DELIMITER ','
    CSV HEADER;
    update takes 
       set takes.grade_on_course= ( select grade_on_course from temp_table as tt 
       where tt.student_id = student_id and tt.course_id = course_id and tt.instructor_id = instructor_id),
            takes.status = 1;
     where takes.student_id = student_id and takes.course_id = course_id and takes.instructor_id = instructor_id
      and takes.status = 0;
end; $$

create or replace function preview_instructor(
    @s_id varchar,
    @i_id varchar
)
returns table(student_id varchar,
    course_id varchar,
    instructor_id varchar,
    course_name varchar,
    status_faculty integer,
    status_batch_advisor integer,
    status_dean_academics integer)
language plpgsql 
as $$
begin
  
return
    select
        ticket.course_id,
        ticket.instructor_id,
        ticket.course_name,
        ticket.status_faculty,
        ticket.status_batch_advisor,
        ticket.status_dean_academics,
    From
        ticket
    where
        ticket.student_id = @s_id and ticket.instructor_id = @i_id and ticket.status_faculty = 0;
end; $$


create or replace procedure accept_instructor(

    SELECT * into  FROM report_generation('s_id'); 
)
create or replace procedure reject_instructor(

)

create or replace function preview_batch_advisor(
    @s_id varchar,
    @b_id varchar
)
returns table(student_id varchar,
    course_id varchar,
    instructor_id varchar,
    course_name varchar,
    status_faculty integer,
    status_batch_advisor integer,
    status_dean_academics integer)
language plpgsql 
as $$
begin
  
return
    select
        ticket.course_id,
        ticket.instructor_id,
        ticket.course_name,
        ticket.status_faculty,
        ticket.status_batch_advisor,
        ticket.status_dean_academics,
    From
        ticket, batch_advisor , takes
    where
        ticket.student_id = @s_id and batch_advisor.instructor_id = @b_id and ticket.status_batch_advisor = 0 and takes.depart_name = batch_advisor.depart_name;
end; $$

create or replace procedure accept_batch_advisor(

)
 
create or replace procedure reject_batch_advisor(
    
)

create or replace function preview_dean(
    @s_id varchar,
    @i_id varchar
)
returns table(student_id varchar,
    course_id varchar,
    instructor_id varchar,
    course_name varchar,
    status_faculty integer,
    status_batch_advisor integer,
    status_dean_academics integer)
language plpgsql 
as $$
begin
  
return
    select
        ticket.course_id,
        ticket.instructor_id,
        ticket.course_name,
        ticket.status_faculty,
        ticket.status_batch_advisor,
        ticket.status_dean_academics,
    From
        ticket
    where
        ticket.student_id = @s_id and ticket.status_dean = 0;
end; $$

create or replace procedure accept_dean_acadmeic_office(

)

create or replace procedure reject_academic_office(
    
)

create or replace procedure generate_ticket(
    student_id varchar(30),
    course_id varchar(30),
    instructor_id varchar(30),
    course_name varchar(30),
    status_faculty integer,
    status_batch_advisor integer,
    status_dean_academics integer
)
language plpgsql
as $$
begin
    insert into ticket(student_id,course_id,instructor_id,course_name,status_faculty,status_batch_advisor,status_dean_academics)
    values (student_id,course_id,instructor_id,course_name,0,0,0)
end; $$



create or replace procedure student_registration(
	student_id varchar(30),
	student_name varchar(30),
	courseID varchar(30),
    course_name varchar(40),
	instructor_name varchar(30),
    instructor_id varchar(30),
	sem integer,
	year_ integer,
	depart_name varchar(5),
)
language plpgsql
as $$
declare
s1 varchar;
s2 varchar;
s3 varchar;
s4 varchar;
s5 varchar;
s6 varchar;
a1 integer;
a2 integer;
a3 integer;
a4 integer;
a5 integer;
credit_lim DEC(4,2)
cg DEC(4,2);
req_cg DEC(4,2);
current_sem_credit integer;
begin

    a1=0;
    s1 = 'call slot_free($1,$2,$3,$4,$5)';
    execute s1 using student_id,sem,courseID,year_,a1 into a1;

    a2 = 0;
    s2 = 'call pre_requisite_check($1,$2,$3)';
    execute s2 using courseid,student_id,o2 into a2;

    a3 = 0;
    s3 = 'call student_department_allowed($1,$2,$3)';
    execute s3 using courseid,student_id,a3 into a3;

    credit_lim = 0;
    s4 = 'call credit_limit($1,$2)';
    execute s4 using student_id,credit_lim into credit_lim;

    select sum (credit_of_course) into current_sem_credit from (select takes.credit_of_course from takes where takes.student_id = student_id 
        and takes.sem =sem  and takes.status = 1 and takes.year_=year_) as temp1 (credit_of_course);
    if current_sem_credit <= credit_lim then
        a4 = 1
    else
        a4 = 0
    end if

    cg = 0;
    s5 = 'call cg_calculation($1,$2)';
    execute s5 using student_id,cg into cg;
    select cgpa_required into req_cg from courses_offered as co where co.courseid = courseid and co.instructor_id = instructor_id;

    if req_cg <= cg then
        a5 = 1
    else
        a5 = 0
    end if

    
    if (a1 + a2 + a3 + a4 + a5) = 5 then

        insert into takes(student_id,student_name,course_id,grade_on_course,credit_of_course,depart_name,year_,timing,sem,status)
        values (student_id,student_name,course_id,grade_on_course,credit_of_course,depart_name,year_,timing,sem,0);
    ELSE
        sf = 0;
        sb = 0;
        sda = 0;
        s6 = 'call generate_ticket($1,$2,$3,$4,$5,$6,$7)';
        -- //glti hai idhr
        execute s6 using student_id,courseID,instructor_id,course_name,sf,sb,sda into sf,sb,sda;
    end if

end; $$
