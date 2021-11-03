create or replace procedure instructor_offer(
  cid varchar,
  c_name varchar,
  cgpa_req Dec(4,2),
  course_instructor_id varchar,
  dept_name varchar,
  sem integer,
  y integer,
  time_ varchar,
  ins_id varchar
)
language plpgsql
as $$
declare
counter_ integer; 
begin 
  select count(*) into counter_ from course_catalogue as co where co.courseid=cid and co.instructor_id = ins_id;
  if counter_>0 then
    insert into courses_offered(courseid,year_,course_name,sem, cgpa_required,instructor_id,timing,depart_name)
    values(cid,y,c_name,sem, cgpa_req,ins_id,time_,dept_name);
end;$$

-- create or replace function report_generation(s_id varchar)
-- returns table(course_name varchar, course_id varchar, grade_on_course integer)
-- language plpgsql
-- as $$
-- begin
-- return
--     select
--         course_name,
--         course_id,
--         grade_on_course
--     From
--         takes
--     where
--         takes.status = 1 and  takes.student_id = s_id;
-- -- 	commit;
-- end; $$

-- SELECT * FROM report_generation('s_id'); (to call this function)

-- chances of mistake here
create or replace procedure cg_calculation(
    student_id varchar,
    INOUT cg DEC(4,2))
language plpgsql
as $$
declare  
    numerator integer;
    denominator integer;
begin
    select COALESCE sum (grade_on_course*credit_of_course) into numerator from  (select takes.grade_on_course, takes.credit_of_course from takes where takes.student_id = student_id and takes.status = 1) as numerator_multiplication
    (grade_on_course, credit_of_course);
    select COALESCE sum (credit_of_course) into denominator from  (select takes.credit_of_course from takes where takes.student_id = student_id and takes.status = 1) as denominator_sum
    (credit_of_course);
    CAST( numerator as DOUBLE);
    CAST(denominator as DOUBLE);
    cg := numerator/denominator
end; $$

create or replace procedure credit_limit(
    IN s_id varchar(30),
	IN current_sem integer,
    IN current_year integer,
	INOUT credit_limit DEC(4,2)
)
language plpgsql
as $$
declare
last_sem integer;
secondlast_sem integer;
begin
   select year_ into  current_year  from takes as t where t.status = 0 and  t.student_id = s_id;
  IF current_sem >=3 then
    If current_sem % 2 = 0 then
        select sum (credit_of_course) into last_sem from  (select takes.credit_of_course from takes where takes.student_id = s_id 
        and sem = current_sem - 1 and takes.status = 1 and year=current_year) as temp1
        (credit_of_course);
        select sum (credit_of_course) into secondlast_sem from  (select takes.credit_of_course from takes where takes.student_id = s_id 
        and sem = current_sem - 2 and takes.status = 1 and year = current_year - 1) as temp2 (credit_of_course);
        credit_limit = round(1.25 * (last_sem + secondlast_sem)/2,2);
    ELSE 
        select sum (credit_of_course) into last_sem from  (select takes.credit_of_course from takes where takes.student_id = s_id 
        and sem = current_sem - 1 and takes.status = 1 and  year=current_year-1) as temp1
        (credit_of_course);
        select sum (credit_of_course) into secondlast_sem from  (select takes.credit_of_course from takes where takes.student_id = s_id 
        and sem = current_sem - 2 and takes.status = 1 and year=current_year-1) as temp2 (credit_of_course);
        credit_limit = round(1.25 * (last_sem + secondlast_sem)/2,2);
    END IF;
  else
    set credit_limit = 24;
  END IF;
end; $$

create or replace procedure pre_requisite_check(
    c_id varchar(30),
    s_id varchar(30),
    INOUT result,
)
language plpgsql
as $$
declare
pre_status integer;
begin
    (select t.course_id from takes as t where t.status = 1 and t.student_id = s_id) as completed_courses (completed);
    (select pr.pre_requisite_course_id from pre_requisite_courses as pr where pr.course_id=c_id) as required_courses (required);
    select count(*) into pre_status from required_courses.required not exists (select completed_courses.completed from completed_courses);
    if pre_status = 0 then
        result = 1;
    ELSE
        result = 0;
    end if
end; $$

create or replace procedure student_department_allowed(
    c_id varchar(30),
    s_id varchar(30),
    INOUT result,
)
language plpgsql
as $$
declare
pre_status integer;
begin
    (select t.depart_name from takes as t where t.student_id = s_id) as current_departs (current);
    (select ed.depart_name from eligible_departments as ed where ed.course_id=c_id) as required_departs (required);
    select count(*) into pre_status from required_departs.required not exists (select current_departs.current from current_departs);
    if pre_status = 0 then
        result = 1
    ELSE
        result = 0
    end if
end; $$

create or replace procedure slot_free(
    IN s_id varchar(30),
    IN s_ integer,
    IN c_id varchar(30),
    IN y_ integer,
    INOUT result integer
)
as $$
declare
t_id varchar;
number_of_clashes integer;
begin
select co.timing into t_id
from courses_offered as co where co.course_id = c_id and co.year_ = y_ and co.sem = s_;
select count (*) into number_of_clashes
from takes as t, courses_offered as co
where t.student_id = s_id and t.course_id = co.course_id and t.year_ = co.year_ 
and t.sem = co.sem and t.timing = t_id and t.year_ = y_ and t.sem = s_;
if number_of_clashes = 0 then
    result = 1;
else 
    result = 0;
end if;
  
end; $$

create or replace procedure grade_entry(
    c_id varchar,
    i_id varchar
    y_ integer,
    s_ integer
)
language plpgsql
as $$
begin
    drop table if exists temp_table;
    create table temp_table(
    student_id varchar not null,
    student_name varchar not null,
    course_id varchar not null,
    grade_on_course integer not null,
    instructor_id  varchar not null,
    year_ integer not null,
    sem integer not null,
    status integer not null,
    primary key(student_id));
    COPY temp_table(student_id,student_name,course_id,grade_on_course,instructor_id,year_,sem,status)
    -- status is equal to 1 on csv file because grade entry is possible only after course completion
    FROM 'C:\Users\anshu\Desktop\Project\grade_sheet.csv'
    DELIMITER ','
    CSV HEADER;
    update takes 
    set takes.grade_on_course= ( select tt.grade_on_course from temp_table as tt
       where tt.year_ = y_ and tt.sem  = s_ and tt.course_id = c_id and tt.instructor_id = i_id and
            tt.status = 1),
        takes.status = (select tet.status from temp_table as tet 
          where tet.year_ = y_ and tet.sem  = s_ and tet.course_id = c_id and tet.instructor_id = i_id 
           tet.staus = 1)
    where takes.year_ = y_ and takes.sem  = s_ and takes.course_id = c_id and takes.instructor_id = i_id 
           takes.staus = 0;
end; $$

create or replace function preview_instructor(
    i_id varchar
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
        ticket.student_id,
        ticket.course_id,
        ticket.instructor_id,
        ticket.course_name,
        ticket.status_faculty,
        ticket.status_batch_advisor,
        ticket.status_dean_academics,
    From
        ticket
    where
        ticket.instructor_id = i_id and ticket.status_faculty = 0;
end; $$

-- 0 - pending
-- 1 - reject
-- 2- accept

create or replace procedure accept_ticket_instructor(
    i_id varchar 
)
language plpgsql
as $$
begin
    SELECT * into collect_  FROM preview_instructor(i_id); 

    update ticket
    set ticket.status_faculty = 2
    From collect_
    where ticket.course_id = collect_.course_id and ticket.instructor_id = collect_.instructor_id and 
    ticket.course_name = collect_.course_name and ticket.status_faculty=collect_.status_faculty and 
    ticket.status_batch_advisor=collect_.status_batch_advisor and ticket.status_dean_academics = collect_.status_dean_academics;
end; $$

create or replace procedure reject_ticket_instructor(
    i_id varchar 
)
language plpgsql
as $$
begin
    SELECT * into collect_  FROM preview_instructor(i_id); 

    update ticket
    set ticket.status_faculty = 1
    From collect_
    where ticket.course_id = collect_.course_id and ticket.instructor_id = collect_.instructor_id and 
    ticket.course_name = collect_.course_name and ticket.status_faculty=collect_.status_faculty and 
    ticket.status_batch_advisor=collect_.status_batch_advisor and ticket.status_dean_academics = collect_.status_dean_academics;
end; $$

create or replace function preview_batch_advisor(
    b_id varchar
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
        ticket, batch_advisor
    where
        (batch_advisor.instructor_id = b_id and ticket.depart_name = batch_advisor.depart_name and ticket.status_batch_advisor = 0 and ticket.status_faculty = 1)
         or (batch_advisor.instructor_id = b_id and ticket.depart_name = batch_advisor.depart_name and ticket.status_batch_advisor = 0 and ticket.status_faculty = 2);
end; $$

create or replace procedure accept_ticket_batch_advisor(
    b_id varchar 
)
language plpgsql
as $$
begin
    SELECT * into collect_  FROM preview_batch_advisor(b_id); 
    update ticket
    set ticket.status_batch_advisor = 2
    From collect_
    where ticket.course_id = collect_.course_id and ticket.instructor_id = collect_.instructor_id and 
    ticket.course_name = collect_.course_name and ticket.status_faculty=collect_.status_faculty and 
    ticket.status_batch_advisor=collect_.status_batch_advisor and ticket.status_dean_academics = collect_.status_dean_academics;
end; $$
 
create or replace procedure reject_ticket_batch_advisor(
    b_id varchar 
)
language plpgsql
as $$
begin
    SELECT * into collect_ FROM preview_batch_advisor(b_id); 
    update ticket
    set ticket.status_batch_advisor = 1
    From collect_
    where ticket.course_id = collect_.course_id and ticket.instructor_id = collect_.instructor_id and 
    ticket.course_name = collect_.course_name and ticket.status_faculty=collect_.status_faculty and 
    ticket.status_batch_advisor=collect_.status_batch_advisor and ticket.status_dean_academics = collect_.status_dean_academics;
end; $$

create or replace function preview_dean(
    d_id varchar
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
        ticket, dean
    where
        (ticket.status_dean = 0 and ticket.status_batch_advisor = 1 and dean.dean_id = d_id)
        or (and ticket.status_dean = 0 and ticket.status_batch_advisor = 2 and dean.dean_id = d_id);
end; $$

-- Yipee!
create or replace procedure accept_ticket_dean(
    d_id varchar 
)
language plpgsql
as $$
declare
y integer;
s integer;
sid varchar;
sn varchar;
ci varchar;
dn varchar;
ins_id varchar;
gc integer;
cc integer;
t integer;
begin
    SELECT * into collect_ FROM preview_dean(d_id); 
    update ticket
    set ticket.status_dean_academics = 2
    From collect_
    where ticket.course_id = collect_.course_id and ticket.instructor_id = collect_.instructor_id and 
    ticket.course_name = collect_.course_name and ticket.status_faculty=collect_.status_faculty and 
    ticket.status_batch_advisor=collect_.status_batch_advisor and ticket.status_dean_academics = collect_.status_dean_academics;

    -- // student registered for the course
    select year_, sem,student_id,student_name,course_id,depart_name,instructor_id into y,s,sid,sn,ci,dn,ins_id from ticket where ticket.status_dean_academics = 2;
    select grade_on_course,credit_of_course,timing into gc,cc,t from courses_offered as co where co.courseid = ci and co.instructor_id = ins_id ;
    insert into takes(student_id,student_name,course_id,grade_on_course,credit_of_course,depart_name,year_,timing,sem,status)
    values (sid,sn,ci,gc,cc,dn,y,t,s,0);
end; $$
 
create or replace procedure reject_ticket_dean(
    d_id varchar 
)
language plpgsql
as $$
begin
    SELECT * into collect_  FROM preview_dean(d_id); 
    update ticket
    set ticket.status_dean_academics = 1
    From collect_
    where ticket.course_id = collect_.course_id and ticket.instructor_id = collect_.instructor_id and 
    ticket.course_name = collect_.course_name and ticket.status_faculty=collect_.status_faculty and 
    ticket.status_batch_advisor=collect_.status_batch_advisor and ticket.status_dean_academics = collect_.status_dean_academics;
end; $$


create or replace procedure generate_ticket(
    s_id varchar,
    s_name varchar,
    s integer,
    y integer,
    d_name varchar,
    c_id varchar,
    i_id varchar,
    c_name varchar,
    status_faculty integer,
    status_batch_advisor integer,
    status_dean_academics integer
)
language plpgsql
as $$
begin
    insert into ticket(student_id,student_name,sem,year_,depart_name,course_id,instructor_id,course_name,status_faculty,status_batch_advisor,status_dean_academics)
    values (s_id,s_name,s,y,d_name,c_id,i_id,c_name,0,0,0);
end; $$


create or replace procedure student_registration(
	st_id varchar,
	st_name varchar,
	cID varchar,
    ce_name varchar,
	ir_name varchar,
    ir_id varchar,
	s_ integer,
	yea integer,
	dt_name varchar
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


gc integer,
cc integer,
t integer

credit_lim DEC(4,2)
cg DEC(4,2);
req_cg DEC(4,2);
current_sem_credit integer;
begin

    a1=0;
    s1 = 'call slot_free($1,$2,$3,$4,$5)';
    execute s1 using st_id,s_,cID,yea,a1 into a1;

    a2 = 0;
    s2 = 'call pre_requisite_check($1,$2,$3)';
    execute s2 using cid,st_id,o2 into a2;

    a3 = 0;
    s3 = 'call student_department_allowed($1,$2,$3)';
    execute s3 using cid,st_id,a3 into a3;

    credit_lim = 0;
    s4 = 'call credit_limit($1,$2)';
    execute s4 using st_id,credit_lim into credit_lim;

    select sum (credit_of_course) into current_sem_credit from (select takes.credit_of_course from takes where takes.student_id = student_id 
        and takes.sem =s_  and takes.status = 0 and takes.year_=yea) as temp1 (credit_of_course);
    if current_sem_credit <= credit_lim then
        a4 = 1;
    else
        a4 = 0;
    end if

    cg = 0;
    s5 = 'call cg_calculation($1,$2)';
    execute s5 using st_id,cg into cg;
    select cgpa_required into req_cg from courses_offered as co where co.courseid = cid and co.instructor_id = ir_id;

    if req_cg <= cg then
        a5 = 1;
    else
        a5 = 0; 
    end if
    
    if (a1 + a2 + a3 + a4 + a5) = 5 then
        select grade_on_course,credit_of_course,timing into gc,cc,t 
        from courses_offered as co 
        where co.courseid = cid and co.instructor_id = ir_id;;
        insert into takes(student_id,student_name,course_id,
        grade_on_course,credit_of_course,depart_name,year_,
        timing,sem,status)
        values (st_id,st_name,cid,gc,cc,dt_name,yea,t,s_,0);
    ELSE
        s6 = 'call generate_ticket($1,$2,$3,$4,$5,$6,$7)';
        execute s6 using st_id,st_name,s_,yea,dt_name,cID,ir_id,ce_name,0,0,0;
    end if
 
end; $$
