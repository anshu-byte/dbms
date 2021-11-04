--DROP SCHEMA public CASCADE;
--CREATE SCHEMA public;



--call fill_course_catalogue('cs203','dsa',3);
--call fill_course_catalogue('cs201','os',4);
--call fiLl_course_timing('dsa','cs203','puneetx123','4:00-4:30')
--call fill_course_timing('os','cs201','sodhix123','4:00-4:30')
--call fill_pre_requisite_courses('cs203','dsa','cs201');
--call fill_pre_requisite_courses('cs203','dsa','cs202');
--call fill_eligible_departments('cs203','dsa','mech');
--call fill_eligible_departments('cs203','dsa','cse');
--select * from eligible_departments;

--call instructor_offer('cs203','dsa',7.0,'cse',3,2,'puneetx123');
--call instructor_offer('cs201','os',7.0,'cse',3,2,'sodhix123');
--select * from courses_offered;

--call student_registration('2019csb1074','Anshu','cs203','dsa','puneet','puneetx123',3,2,'cse');
--call student_registration('2019csb1074','Anshu','cs201','os','sodhi','sodhix123',3,2,'cse');
--select * from ticket;

--select * from takes;
--call grade_entry('cs203','puneetx123',2,3);
--select * from report_generation('2019csb1074');

--select * from preview_instructor('puneetx123');
-- call accept_ticket_instructor(1);
--call reject_ticket_instructor(1);
--select * from ticket;
-- insert into batch_advisor(instructor_id,nam_,department_name)
-- values('puneetx123','puneet','cse');
--select * from preview_batch_advisor('puneetx123','cse');
--drop function preview_batch_advisor;
-- drop function preview_batch_advisor(varchar);
--call accept_ticket_batch_advisor(1);
--call reject_ticket_batch_advisor(1);
--select * from ticket;
--select * from preview_dean('dean hoon mai');
--call accept_ticket_dean(1);
--call reject_ticket_dean(1);
--select * from ticket;
--select * from  takes;


