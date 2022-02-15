SELECT 
    YEAR(de.from_date) AS Calender_Year,
    e.gender AS Gender,
    COUNT(e.emp_no) AS Number_of_Employees
FROM
    t_employees e
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
GROUP BY Calender_Year , Gender
HAVING Calender_Year >= 1990
ORDER BY Calender_Year , Gender
;
#Task 2
SELECT 
    d.dept_name,
    ee.gender,
    dm.emp_no,
    dm.from_date,
    dm.to_date,
    e.calender_year,
    CASE
        WHEN
            YEAR(dm.from_date) <= e.calender_year
                AND YEAR(dm.to_date) >= e.calender_year
        THEN
            1
        ELSE 0
    END AS active
FROM
    (SELECT 
        YEAR(hire_date) AS calender_year
    FROM
        t_employees
    GROUP BY calender_year) e
        CROSS JOIN
    t_dept_manager dm
        JOIN
    t_departments d ON d.dept_no = dm.dept_no
        JOIN
    t_employees ee ON ee.emp_no = dm.emp_no
ORDER BY dm.emp_no , e.calender_year
;
#Task 3
SELECT 
    e.gender,
    d.dept_name,
    ROUND(AVG(s.salary), 2) AS Salary,
    YEAR(s.from_date) AS calender_year
FROM
    t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no
GROUP BY d.dept_no , e.gender , calender_year
HAVING calender_year <= 2002
ORDER BY d.dept_no ;

#Task 4
use employees_mod;
drop procedure if exists filter_salary;
Delimiter $$
Create procedure filter_salary (in p_min_salary float, in p_max_salary float)
begin
select d.dept_name , e.gender, Round(Avg(s.salary), 2) as avg_salary
from 
t_salaries s
        JOIN
    t_employees e ON s.emp_no = e.emp_no
        JOIN
    t_dept_emp de ON e.emp_no = de.emp_no
        JOIN
    t_departments d ON d.dept_no = de.dept_no 
where s.salary between p_min_salary and p_max_salary
group by d.dept_no, e.gender;
end$$
delimiter ;
call employees_mod.filter_salary(50000, 90000);

