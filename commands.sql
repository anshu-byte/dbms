-- DROP SCHEMA public CASCADE;
-- CREATE SCHEMA public;

-- first step
-- call fill_course_catalogue('cs203','dsa',3);
-- call fill_course_catalogue('cs201','os',4);
-- select * from course_catalogue;

-- second step
-- call fiLl_course_timing('dsa','cs203','puneetx123','4:00-4:30')
-- call fill_course_timing('os','cs201','sodhix123','4:00-4:30')
-- select * from time_table;

-- third step
-- call fill_pre_requisite_courses('cs203','dsa','cs201');
-- call fill_pre_requisite_courses('cs203','dsa','cs202');
-- select * from pre_requisite_courses;

-- fourth step
-- call fill_eligible_departments('cs203','dsa','mech');
-- call fill_eligible_departments('cs203','dsa','cse');
-- select * from eligible_departments;

-- fifth step
-- call instructor_offer('cs203','dsa',7.0,'cse',3,2,'puneetx123',1);
-- call instructor_offer('cs201','os',7.0,'cse',3,2,'sodhix123',1);
-- select * from courses_offered;

-- sixth step
-- select * from takes;

-- seventh step
-- call student_registration('2019csb1074','Anshu','cs201','os','sodhi','sodhix123',3,2,'cse',1);


-- eighth step
-- ticket raised
-- call student_registration('2019csb1074','Anshu','cs203','dsa','puneet','puneetx123',3,2,'cse',1); 

-- for surety purpose
-- select * from ticket;
-- select * from takes;

-- ninth step
-- call grade_entry('cs201','sodhix123',2,3,1);
-- select * from report_generation('2019csb1074');

-- tenth step
-- instructor check ticket
-- select * from preview_instructor('puneetx123');
-- call accept_ticket_instructor(1);
-- call reject_ticket_instructor(1);

-- select * from ticket;

-- eleventh step
-- batch advisor check ticket
-- select * from preview_batch_advisor('puneetx123','cse');
-- call accept_ticket_batch_advisor(1);
-- call reject_ticket_batch_advisor(1);

-- select * from ticket;

-- twelveth step
-- dean check ticket, final call will be of Dean
-- select * from preview_dean('dean hoon mai');
-- call accept_ticket_dean(1);
-- call reject_ticket_dean(1);

-- select * from ticket;
-- select * from takes;