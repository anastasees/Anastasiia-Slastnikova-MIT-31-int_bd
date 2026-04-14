-- Лабораторна робота №3
-- З дисципліни: Бази даних та інформаційні системи
-- Студента групи МІТ-31: Анастасія Сластнікова

-----------------------------------------------------------
-- БЛОК 1: Логічні оператори та фільтрація (1-5)
-----------------------------------------------------------

-- 1. Студенти з конкретними доменами пошти (LIKE)
SELECT * FROM Students WHERE email LIKE '%@example.com';

-- 2. Курси, назва яких починається на 'Основи' або містить 'Python' (OR, LIKE)
SELECT * FROM Courses WHERE title LIKE 'Основи%' OR title LIKE '%Python%';

-- 3. Студенти, чий ID знаходиться в діапазоні 1-10 і ім'я не 'Admin' (BETWEEN, NOT)
SELECT * FROM Students WHERE student_id BETWEEN 1 AND 10 AND full_name <> 'Admin';

-- 4. Записи на курси, де оцінка не є порожньою (IS NOT NULL)
SELECT * FROM Enrollments WHERE final_grade IS NOT NULL;

-- 5. Курси викладачів з ID 1, 2 або 3 (IN)
SELECT * FROM Courses WHERE teacher_id IN (1, 2, 3);

-----------------------------------------------------------
-- БЛОК 2: Агрегатні функції та GROUP BY (6-10)
-----------------------------------------------------------

-- 6. Загальна кількість студентів (COUNT)
SELECT COUNT(*) AS total_students FROM Students;

-- 7. Середня оцінка по всій школі (AVG)
SELECT AVG(final_grade) AS overall_avg_grade FROM Enrollments;

-- 8. Сума всіх відвіданих вебінарів (SUM)
SELECT SUM(webinars_attended) FROM Enrollments;

-- 9. Максимальна та мінімальна оцінка на курсі №1 (MIN, MAX)
SELECT MIN(final_grade), MAX(final_grade) FROM Enrollments WHERE course_id = 1;

-- 10. Кількість курсів у кожного викладача (GROUP BY)
SELECT teacher_id, COUNT(*) FROM Courses GROUP BY teacher_id;

-----------------------------------------------------------
-- БЛОК 3: Усі типи JOIN (11-16)
-----------------------------------------------------------

-- 11. INNER JOIN: Список студентів та їх курсів
SELECT s.full_name, c.title 
FROM Students s 
INNER JOIN Enrollments e ON s.student_id = e.student_id
INNER JOIN Courses c ON e.course_id = c.course_id;

-- 12. LEFT JOIN: Усі викладачі та курси, які вони ведуть (навіть якщо курсів немає)
SELECT t.full_name, c.title FROM Teachers t LEFT JOIN Courses c ON t.teacher_id = c.teacher_id;

-- 13. RIGHT JOIN: Усі записи на курси та інформація про студентів
SELECT s.full_name, e.enrollment_id FROM Students s RIGHT JOIN Enrollments e ON s.student_id = e.student_id;

-- 14. FULL JOIN: Студенти та записи (включаючи тих, хто не записаний)
SELECT s.full_name, e.course_id FROM Students s FULL OUTER JOIN Enrollments e ON s.student_id = e.student_id;

-- 15. CROSS JOIN: Усі можливі комбінації студентів та курсів (декартовий добуток)
SELECT s.full_name, c.title FROM Students s CROSS JOIN Courses c;

-- 16. SELF JOIN: Викладачі з однаковою спеціалізацією
SELECT t1.full_name, t2.full_name, t1.specialization 
FROM Teachers t1 
JOIN Teachers t2 ON t1.specialization = t2.specialization AND t1.teacher_id < t2.teacher_id;

-----------------------------------------------------------
-- БЛОК 4: Підзапити (Subqueries) (17-21)
-----------------------------------------------------------

-- 17. Підзапит у WHERE: Студенти, чия оцінка вища за середню
SELECT full_name FROM Students WHERE student_id IN 
(SELECT student_id FROM Enrollments WHERE final_grade > (SELECT AVG(final_grade) FROM Enrollments));

-- 18. EXISTS: Викладачі, які ведуть хоча б один курс
SELECT full_name FROM Teachers t WHERE EXISTS 
(SELECT 1 FROM Courses c WHERE c.teacher_id = t.teacher_id);

-- 19. NOT EXISTS: Студенти, які не записані на жоден курс
SELECT full_name FROM Students s WHERE NOT EXISTS 
(SELECT 1 FROM Enrollments e WHERE e.student_id = s.student_id);

-- 20. Підзапит у FROM: Середня кількість вебінарів серед активних курсів
SELECT AVG(count_web) FROM (SELECT webinars_attended AS count_web FROM Enrollments WHERE webinars_attended > 0) AS active_sub;

-- 21. Підзапит у SELECT: Список курсів та кількість студентів на кожному
SELECT title, (SELECT COUNT(*) FROM Enrollments e WHERE e.course_id = c.course_id) AS st_count FROM Courses c;

-----------------------------------------------------------
-- БЛОК 5: Операції над множинами (22-24)
-----------------------------------------------------------

-- 22. UNION: Об'єднаний список імен усіх викладачів та студентів
SELECT full_name, 'Teacher' as role FROM Teachers
UNION
SELECT full_name, 'Student' FROM Students;

-- 23. INTERSECT: Знайти ID студентів, які є і в системі, і мають записи (якщо логіка дозволяє)
SELECT student_id FROM Students INTERSECT SELECT student_id FROM Enrollments;

-- 24. EXCEPT: Студенти, які є в базі, але не мають жодного запису на курс
SELECT student_id FROM Students EXCEPT SELECT student_id FROM Enrollments;

-----------------------------------------------------------
-- БЛОК 6: Common Table Expressions (CTE) (25-30)
-----------------------------------------------------------

-- 25. Простий CTE для вибірки відмінників
WITH TopStudents AS (
    SELECT student_id, final_grade FROM Enrollments WHERE final_grade >= 90
)
SELECT s.full_name, ts.final_grade FROM Students s JOIN TopStudents ts ON s.student_id = ts.student_id;

-- 26. CTE для підрахунку статистики курсів
WITH CourseStats AS (
    SELECT course_id, COUNT(*) as st_count, AVG(final_grade) as avg_g
    FROM Enrollments GROUP BY course_id
)
SELECT c.title, cs.st_count, cs.avg_g FROM Courses c JOIN CourseStats cs ON c.course_id = cs.course_id;

-- 27. Рекурсивний CTE (приклад ієрархії, якщо була б таблиця категорій курсів)
-- Тут просто приклад структури для логіки
WITH RECURSIVE NumberSeries AS (
    SELECT 1 AS n UNION ALL SELECT n + 1 FROM NumberSeries WHERE n < 5
)
SELECT * FROM NumberSeries;

-- 28. CTE для фільтрації викладачів з великим навантаженням
WITH TeacherLoad AS (
    SELECT teacher_id, COUNT(*) as c_count FROM Courses GROUP BY teacher_id
)
SELECT t.full_name FROM Teachers t JOIN TeacherLoad tl ON t.teacher_id = tl.teacher_id WHERE tl.c_count > 2;

-- 29. CTE для розрахунку відсотка відвіданих вебінарів (якщо план 20)
WITH WebinarProgress AS (
    SELECT student_id, (webinars_attended * 100 / 20) as progress FROM Enrollments
)
SELECT s.full_name, wp.progress FROM Students s JOIN WebinarProgress wp ON s.student_id = wp.student_id;

-- 30. Використання двох CTE в одному запиті
WITH ListA AS (SELECT student_id FROM Enrollments WHERE course_id = 1),
     ListB AS (SELECT student_id FROM Enrollments WHERE course_id = 2)
SELECT s.full_name FROM Students s JOIN ListA a ON s.student_id = a.student_id JOIN ListB b ON s.student_id = b.student_id;

-----------------------------------------------------------
-- БЛОК 7: Віконні функції (Window Functions) (31-40)
-----------------------------------------------------------

-- 31. RANK(): Рейтинг студентів за оцінками
SELECT student_id, final_grade, RANK() OVER (ORDER BY final_grade DESC) as rank_pos FROM Enrollments;

-- 32. DENSE_RANK(): Рейтинг без пропусків у нумерації
SELECT student_id, final_grade, DENSE_RANK() OVER (ORDER BY final_grade DESC) as dense_rank_pos FROM Enrollments;

-- 33. ROW_NUMBER(): Унікальний номер рядка для кожного запису на курс
SELECT ROW_NUMBER() OVER(PARTITION BY course_id ORDER BY enrollment_date) as num, student_id, course_id FROM Enrollments;

-- 34. AVG() OVER: Порівняння оцінки студента з середньою по цьому ж курсу
SELECT student_id, course_id, final_grade, AVG(final_grade) OVER(PARTITION BY course_id) as course_avg FROM Enrollments;

-- 35. SUM() OVER: Накопичувальна сума відвіданих вебінарів по курсу
SELECT student_id, course_id, webinars_attended, SUM(webinars_attended) OVER(PARTITION BY course_id ORDER BY enrollment_id) as running_total FROM Enrollments;

-- 36. LEAD(): Оцінка наступного за списком студента (для порівняння)
SELECT student_id, final_grade, LEAD(final_grade) OVER (ORDER BY final_grade DESC) as next_lower_grade FROM Enrollments;

-- 37. LAG(): Оцінка попереднього студента
SELECT student_id, final_grade, LAG(final_grade) OVER (ORDER BY final_grade DESC) as previous_higher_grade FROM Enrollments;

-- 38. FIRST_VALUE(): Найкраща оцінка на курсі поруч з кожним записом
SELECT student_id, course_id, final_grade, FIRST_VALUE(final_grade) OVER (PARTITION BY course_id ORDER BY final_grade DESC) as best_in_course FROM Enrollments;

-- 39. NTILE(4): Розподіл студентів на 4 групи за успішністю (квартилі)
SELECT student_id, final_grade, NTILE(4) OVER (ORDER BY final_grade DESC) as quartile FROM Enrollments;

-- 40. COUNT() OVER: Кількість студентів на курсі поруч з кожним ім'ям
SELECT s.full_name, c.title, COUNT(s.student_id) OVER(PARTITION BY c.course_id) as total_on_this_course
FROM Students s 
JOIN Enrollments e ON s.student_id = e.student_id
JOIN Courses c ON e.course_id = c.course_id;