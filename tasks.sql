--1--
SELECT 
  tutors.tt_id, 
  tutors.tt_name, 
  COUNT(DISTINCT education.ed_student) AS students_count 
FROM 
  tutors 
  LEFT JOIN education ON education.ed_tutor = tutors.tt_id 
GROUP BY tutors.tt_name, tutors.tt_id 
ORDER BY tutors.tt_id ASC;

--2--
SELECT 
  students.st_id, 
  students.st_name, 
  COUNT(DISTINCT education.ed_tutor) AS tutors_count 
FROM 
  students 
  JOIN education ON education.ed_student = students.st_id 
GROUP BY students.st_id, students.st_name 
ORDER BY students.st_id ASC;

--3--
SELECT 
  * 
FROM 
  (
    SELECT 
      tutors.tt_id, 
      tutors.tt_name, 
      COUNT(*) AS classes_count 
    FROM 
      tutors 
      JOIN education ON tutors.tt_id = education.ed_tutor 
    WHERE 
      education.ed_date BETWEEN TO_DATE('2012-09-01', 'yyyy/mm/dd') 
      AND 
      TO_DATE('2012-09-30', 'yyyy/mm/dd') 
    GROUP BY tutors.tt_id, tutors.tt_name 
    ORDER BY classes_count DESC
  ) 
WHERE ROWNUM <= 1;

--4--
SELECT 
  students.st_id, 
  students.st_name, 
  AVG(education.ed_mark) 
FROM students 
  LEFT JOIN education ON students.st_id = education.ed_student 
GROUP BY students.st_id, students.st_name;

--5--
SELECT 
  st,
  students.st_name, 
  LISTAGG(subjects.sb_name, ', ') WITHIN GROUP (ORDER BY subjects.sb_name), 
  mx 
FROM 
  education 
  LEFT JOIN 
    (
      SELECT 
        students.st_id AS st, 
        MAX(education.ed_mark) AS mx 
      FROM students 
        LEFT JOIN education ON education.ed_student = students.st_id 
      GROUP BY students.st_id
    ) ON st = education.ED_STUDENT 
  JOIN students ON students.st_id = education.ed_student 
  JOIN subjects ON education.ed_subject = subjects.sb_id 
WHERE mx = education.ed_mark 
GROUP BY st, students.st_name, mx;

--6--
SELECT 
  tt_name 
FROM education 
  JOIN tutors ON tutors.tt_id = education.ed_tutor 
  JOIN students ON students.st_id = education.ed_student 
WHERE 
  students.st_name = 'Соколов С.С.' 
  AND 
  education.ed_mark = 
    (
      SELECT 
        MIN(ed_mark) 
      FROM education
    );
    
--7--
SELECT 
  CASE COUNT(*) 
    WHEN 0 THEN '0' 
    ELSE '1' END AS answer 
  FROM 
    EDUCATION 
    JOIN classes_types ON education.ed_subject = classes_types.ct_id 
  WHERE 
    classes_types.ct_name NOT IN('Экзамен','Лабораторная работа') 
    AND 
    education.ed_mark IS NOT NULL;

--8--
SELECT short_date, LISTAGG(sbn, ', ') within group (order by sbn) as subjects_list, maxclasses as classes
FROM
(
  SELECT short_date, ed_subject, classes, maxclasses, subjects.sb_name AS sbn FROM 
  (
    SELECT ed_subject, short_date, COUNT(*) AS classes FROM 
    (
      SELECT ed_subject, TO_CHAR(ed_date, 'yyyymm') AS short_date 
      FROM EDUCATION 
      WHERE TO_CHAR(ed_date, 'yyyymm') LIKE '2012%'
    
    )
    GROUP BY short_date, ed_subject
  )
  
  LEFT JOIN
  (
    SELECT short_date1, MAX(classes) AS maxclasses FROM
    (
    
    SELECT ed_subject, short_date1, COUNT(*) AS classes FROM 
    (
      SELECT ed_subject, TO_CHAR(ed_date, 'yyyymm') AS short_date1 
      FROM EDUCATION 
      WHERE TO_CHAR(ed_date, 'yyyymm') LIKE '2012%'
    
    )
    GROUP BY short_date1, ed_subject
    
    )
    GROUP BY short_date1
  )
  ON short_date = short_date1
  
  JOIN SUBJECTS ON SUBJECTS.SB_ID = ed_subject
  
  WHERE classes = maxclasses
)
GROUP BY short_date, maxclasses
ORDER BY short_date DESC
;

--9--
SELECT
  students.st_id,
  students.st_name,
  AVG(education.ed_mark) AS avg
FROM
  education
  JOIN students ON education.ed_student = students.st_id
GROUP BY students.st_id, students.st_name
HAVING AVG(education.ed_mark) < (SELECT AVG(education.ed_mark) FROM education)
ORDER BY students.st_id ASC
;

--10--
SELECT
  st_id,
  st_name
FROM students
MINUS
SELECT DISTINCT
  students.st_id,
  students.st_name
FROM
  education
  JOIN students ON students.st_id = education.ed_student
  JOIN subjects ON subjects.sb_id = education.ed_subject
WHERE subjects.sb_name NOT IN ('Химия','Физика')
GROUP BY students.st_id, students.st_name
;