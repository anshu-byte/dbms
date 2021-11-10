create or replace procedure fill_instructor(
    i_id varchar,
    na varchar
)
language plpgsql
as $$
begin
  insert into  instructor(instructor_id,name_)
  values (i_id,na);
end; $$;


create or replace procedure fill_batch_advisors(
    i_id varchar,
    na varchar,
    d_name varchar
)
language plpgsql
as $$
begin
  insert into  batch_advisor(i_id,na,d_name)
  values (i_id,na);
end; $$;



create or replace procedure fill_course_catalogue(
    c_ID varchar, 
    c_name varchar,
    cc integer
)
language plpgsql
as $$
begin
  insert into  course_catalogue(course_ID,course_name,credit_of_course)
  values (c_id,c_name,cc);
end; $$;

create or replace procedure fill_course_timing(
    c_name varchar,
	c_ID varchar,
    i_id varchar,
    t varchar
)
language plpgsql
as $$
begin
    insert into time_table(course_name,course_id,instructor_id,timing)
    values(c_name,c_id,i_id,t);
end; $$;


create or replace procedure fill_pre_requisite_courses(
    c_id varchar,
    c_name varchar,
    p_cid varchar
)
language plpgsql
as $$
begin
    insert into pre_requisite_courses(course_id,course_name,prerequisite_course_id)
    values(c_id,c_name,p_cid);
end; $$;

create or replace procedure fill_eligible_departments(
    c_id varchar,
    c_name varchar,
    d_name varchar
)
language plpgsql
as $$
begin
    insert into eligible_departments(course_id,course_name,depart_name)
    values(c_id,c_name,d_name);
end; $$;

create or replace procedure instructor_offer(
  cid varchar,
  c_name varchar,
  cgpa_req Dec(4,2),
  dept_name varchar,
  sem_ integer,
  y integer,
  ins_id varchar,
  sec integer
)
language plpgsql
as $$
declare
counter_ integer; 
coc integer;
begin 
  select count(*) into counter_ from course_catalogue as co where co.course_id=cid;
  select co.credit_of_course into coc from course_catalogue as co where co.course_id=cid;
  if counter_>0 then
    insert into courses_offered(course_id,credit_of_course,year_,course_name,sem, cgpa_required,instructor_id,depart_name,section)
    values(cid,coc,y,c_name,sem_, cgpa_req,ins_id,dept_name,sec);
   end if;
end; $$;

create or replace function report_generation(s_id varchar)
returns table(course_id varchar, grade_on_course integer)
language plpgsql as $$
begin
return 
    query select
        takes.course_id,
        takes.grade_on_course
    From
        takes
    where
        takes.status = 1 and  takes.student_id = s_id;
end; $$;


create or replace function preview_instructor(
    i_id varchar
)
returns table(
    tid integer,
    student_id varchar,
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
    query select
        ticket.id,
        ticket.student_id,
        ticket.course_id,
        ticket.instructor_id,
        ticket.course_name,
        ticket.status_faculty,
        ticket.status_batch_advisor,
        ticket.status_dean_academics
    From
        ticket
    where
        ticket.instructor_id = i_id and ticket.status_faculty = 0;
end; $$;

-- 0 - pending
-- 1 - reject
-- 2- accept

create or replace procedure accept_ticket_instructor(
    tid integer 
)
language plpgsql
as $$
begin
    update ticket
    set status_faculty = 2
    where id =tid;
end; $$;

create or replace procedure reject_ticket_instructor(
    tid integer 
)
language plpgsql
as $$
begin
    update ticket
    set status_faculty = 1
    where id = tid;
end; $$;

-- drop function preview_batch_advisor(varchar);
create or replace function preview_batch_advisor(
    b_id varchar,
    d_id varchar
)
returns table(
    tid integer,
    student_id varchar,
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
    query select
        ticket.id,
        ticket.student_id,
        ticket.course_id,
        ticket.instructor_id,
        ticket.course_name,
        ticket.status_faculty,
        ticket.status_batch_advisor,
        ticket.status_dean_academics
    From
        ticket
    where
        (ticket.depart_name = d_id and ticket.status_batch_advisor = 0 and ticket.status_faculty = 1) or (ticket.depart_name = d_id and ticket.status_batch_advisor = 0 and ticket.status_faculty = 2);
end; $$;

-- drop procedure accept_ticket_batch_advisor;
create or replace procedure accept_ticket_batch_advisor(
    t_id integer 
)
language plpgsql
as $$
begin
    update ticket
    set status_batch_advisor = 2
    where id = t_id;
end; $$;
 
create or replace procedure reject_ticket_batch_advisor(
    t_id integer
)
language plpgsql
as $$
begin
    update ticket
    set status_batch_advisor = 1
    where id = t_id;
    
end; $$;

create or replace function preview_dean(
    d_id varchar
)
returns table(
    tid integer,
    student_id varchar,
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
    query select
        ticket.id,
        ticket.student_id,
        ticket.course_id,
        ticket.instructor_id,
        ticket.course_name,
        ticket.status_faculty,
        ticket.status_batch_advisor,
        ticket.status_dean_academics
    From
        ticket
    where
        (ticket.status_dean_academics = 0 and ticket.status_batch_advisor = 1)
        or (ticket.status_dean_academics = 0 and ticket.status_batch_advisor = 2);
end; $$;

-- -- Yipee!
create or replace procedure accept_ticket_dean(
    t_id integer
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
cc integer;
t varchar;
sec integer;
begin
   
    update ticket
    set status_dean_academics = 2
    where id = t_id;

    -- // student registered for the course
    select year_, sem,student_id,student_name,course_id,depart_name,instructor_id,section into y,s,sid,sn,ci,dn,ins_id,sec from ticket where ticket.status_dean_academics = 2;
    select co.credit_of_course, co.timing into cc,t from courses_offered as co where co.course_id = ci and co.instructor_id = ins_id and co.section = sec;
    insert into takes(student_id,student_name,course_id,grade_on_course,credit_of_course,depart_name,year_,timing,sem,status,section)
    values (sid,sn,ci,0,cc,dn,y,t,s,0,sec);
end; $$;
 
create or replace procedure reject_ticket_dean(
    t_id integer
)
language plpgsql
as $$
begin
    update ticket
    set status_dean_academics = 1
    where id = t_id;
end; $$;


create or replace procedure pre_requisite_check(
    c_id varchar,
    s_id varchar,
    INOUT result_ integer
)
language plpgsql
as $$
declare
pre_status integer;
var_ integer;
begin
    select count(*) into var_ from pre_requisite_courses as pr where pr.course_id=c_id;
    select count(*) into pre_status from (select t.course_id as completed_courses from takes as t where t.status = 1 and t.student_id = s_id) as a_,(select pr.prerequisite_course_id as required_courses from pre_requisite_courses as pr where pr.course_id=c_id) as b_ where a_.completed_courses=b_.required_courses;
    if pre_status = var_ then
        result_ = 1;
    ELSE
        result_ = 0;
    end if;
end; $$;

create or replace procedure student_department_allowed(
     c_id varchar,
     s_id varchar,
     d_id varchar,
     INOUT result_ integer
 )
 language plpgsql
 as $$
 declare
 pre_status integer;
 begin
       select count(*) into pre_status from eligible_departments as ed where ed.course_ID = c_id and ed.depart_name = d_id;
        if pre_status = 1 then
            result_ = 1;
        ELSE
            result_ = 0;
        end if;
    
 end; $$;



create or replace procedure slot_free(
    IN s_id varchar,
    IN s_ integer,
    IN c_id varchar,
    IN y_ integer,
    IN inst_id varchar,
    sect integer,
    INOUT result integer
)
language plpgsql
as $$
declare
time_ varchar;

number_of_clashes integer;
begin
-- select tt.timing into time_ from time_table as tt where tt.course_ID = c_id and tt.instructor_id = inst_id;
select count (*) into number_of_clashes
from takes as t where t.student_id = s_id and t.year_ = y_ and t.sem = s_ and t.section = sect;
if number_of_clashes = 0 then
    result = 1;
else 
    result = 0;
end if;
  
end; $$;

-- DROP PROCEDURE cg_calculation(character varying,numeric);
create or replace procedure cg_calculation(
    st_id varchar,
    INOUT cg DEC(4,2))
language plpgsql
as $$
declare  
    numerator integer;
    denominator integer;
begin
    select  coalesce(sum(grade_on_course * credit_of_course),0) into numerator from takes where student_id = st_id and status = 1;
    select  coalesce(sum(credit_of_course),0) into denominator from takes where student_id = st_id and status = 1;
    
    if denominator = 0 then
        cg = 10.00;
    elsif numerator = 0 then
        cg = 10.00;
    else
        cg = round(numerator /denominator,2);
    end if;
    raise notice 'Value: cg %', cg;

end; $$;

create or replace procedure credit_limit(
    IN s_id varchar,
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
  IF current_sem >=3 then
    credit_limit = 0;
    If current_sem % 2 = 0 then
        select coalesce(sum(credit_of_course),0) into last_sem from takes where student_id = s_id 
        and sem = (current_sem - 1) and status = 1 and year_=current_year;
        
        select coalesce(sum(credit_of_course),0) into secondlast_sem from takes where student_id = s_id 
        and sem = (current_sem - 2) and status = 1 and year_ = (current_year - 1);
        
        credit_limit = round(1.25 * (last_sem + secondlast_sem)/2,2);
        if credit_limit = 0.00 then
            credit_limit = 21.00;
		end if;
    ELSE 
        select coalesce(sum(credit_of_course),0) into last_sem from takes where student_id = s_id 
        and sem = (current_sem - 1) and status = 1 and year_= (current_year-1);
        
        select coalesce(sum(credit_of_course),0) into secondlast_sem from takes where student_id = s_id 
        and sem = (current_sem - 2) and status = 1 and year_ = (current_year - 1);
        
        credit_limit = round(1.25 * (last_sem + secondlast_sem)/2,2);

        if credit_limit = 0.00 then
            credit_limit = 21.00;
		end if;
    END IF;
  else
     credit_limit = 21.00;
  END IF;
end; $$;


CREATE OR REPLACE PROCEDURE GRADE_ENTRY(C_ID varchar, I_ID varchar, Y_ integer, S_ integer, sec_ integer) LANGUAGE PLPGSQL AS $$
begin
    create table temp_table(
    student_id varchar not null,
    student_name varchar not null,
    course_id varchar not null,
    grade_on_course integer not null,
    instructor_id  varchar not null,
    year_ integer not null,
    sem integer not null,
    status integer not null,
    section integer not null,
    primary key(student_id,course_id,sem,section));
    COPY temp_table(student_id,student_name,course_id,grade_on_course,instructor_id,year_,sem,status,section)
    FROM 'C:\Users\anshu\Desktop\Project\grade_sheet.csv'
    DELIMITER ','  CSV HEADER ;
    update takes 
    set grade_on_course= ( select grade_on_course from temp_table 
       where year_ = y_ and sem  = s_ and course_id = c_id and instructor_id = i_id and
            status = 1 and section = sec_),
        status = (select tet.status from temp_table as tet 
          where year_ = y_ and sem  = s_ and course_id = c_id and instructor_id = i_id 
           and status = 1 and section = sec_)
    where year_ = y_ and sem  = s_ and course_id = c_id and 
           status = 0 and instructor_id = i_id;
    drop table temp_table;
end; $$;



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
    status_dean_academics integer,
    section_ integer
)
language plpgsql
as $$
begin
    insert into ticket(student_id,student_name,sem,year_,depart_name,course_id,instructor_id,course_name,status_faculty,status_batch_advisor,status_dean_academics,section)
    values (s_id,s_name,s,y,d_name,c_id,i_id,c_name,0,0,0,section_);
end; $$;

-- raise notice 'Value: %', value;
create or replace procedure student_registration(
	st_id varchar,
	st_name varchar,
	cID varchar,
    ce_name varchar,
	ir_name varchar,
    ir_id varchar,
	s_ integer,
	yea integer,
	dt_name varchar,
    sect integer
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
cc integer;
tim varchar;
credit_lim DEC(4,2);
cg DEC(4,2);
req_cg DEC(4,2);
current_sem_credit integer;
begin

    a1=0;
    s1 = 'call slot_free($1,$2,$3,$4,$5,$6,$7)';
    execute s1 using st_id,s_,cID,yea,ir_id,sect,a1 into a1;
    raise notice 'Value: a1 %', a1;
    a2 = 0;
    s2 = 'call pre_requisite_check($1,$2,$3)';
    execute s2 using cid,st_id,a2 into a2;
    raise notice 'Value: a2 %', a2;

    a3 = 0;
    s3 = 'call student_department_allowed($1,$2,$3,$4)';
    execute s3 using cid,st_id,dt_name,a3 into a3;
    raise notice 'Value: a3 %', a3;
    a3 =1;
    credit_lim = 0.00;
    s4 = 'call credit_limit($1,$2,$3,$4)';
    execute s4 using st_id,s_,yea,credit_lim into credit_lim;
    select coalesce(sum(credit_of_course),0) into current_sem_credit from takes where student_id = st_id 
        and sem =s_ and status = 0 and year_=yea;
    
    if current_sem_credit <= credit_lim then
        a4 = 1;
    else
        a4 = 0;
    end if;
    raise notice 'Value: a4 %', a4;

    cg = 0;
    s5 = 'call cg_calculation($1,$2)';

    execute s5 using st_id,cg into cg;
    select co.cgpa_required into req_cg from courses_offered as co where co.course_id = cid and co.instructor_id = ir_id and co.section = sect;
    raise notice 'Value: req_cg %', req_cg;
    if req_cg <= cg then
        a5 = 1;
    else
        a5 = 0; 
    end if;

    raise notice 'Value: a5 %', a5;

    if (a1 + a2 + a3 + a4 + a5) = 5 then
    -- if a4 =1 then
        select co.credit_of_course into cc
        from courses_offered as co 
        where co.course_id = cid and co.instructor_id = ir_id and co.section = sect;

        select tt.timing  into tim  from time_table as tt where tt.course_ID = cid and tt.instructor_id = ir_id;

        insert into takes(student_id,student_name,course_id,
        grade_on_course,credit_of_course,depart_name,year_,timing,sem,status,instructor_id,section)
            values (st_id,st_name,cid,0,cc,dt_name,yea,tim,s_,0,ir_id,sect);
    ELSE
        s6 = 'call generate_ticket($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)';
        execute s6 using st_id,st_name,s_,yea,dt_name,cID,ir_id,ce_name,0,0,0,sect;
    end if; 
end; $$;
