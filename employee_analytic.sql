-- Session 1
-- Question 1
-- Display the information of active employees with the highest salary, make sure the salary displayed is the latest salary
select distinct 
	s.employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	e.gender,
	d.dept_name,
	first_value(s.amount) over(partition by s.employee_id order by s.to_date desc) as new_salary
from employee e
join salary s on e.id = s.employee_id 
join department_employee de on de.employee_id = e.id
join department d on d.id = de.department_id 
where de.to_date = '9999-01-01'
order by 5 desc

-- Question 2
-- Show total employees, total departments, and average salaries in the company, 
-- and also make sure to only take into account active employees and the most recent salary that the employee has
select
	count(distinct e.id) as total_employee,
	count(distinct de.department_id) as total_dept,
	avg(s.amount) as avg_salary
from employee e
join salary s on e.id = s.employee_id 
join department_employee de on de.employee_id = e.id
where de.to_date = '9999-01-01' and s.to_date = '9999-01-01'

-- Question 3
-- Show departments with the most active employees and include information on the most recent or active manager of the department
with total_employees as(
	select
		d.id,
		d.dept_name,
		count(distinct de.employee_id) as total_employee
	from employee e 
	join department_employee de on de.employee_id = e.id 
	join department d on d.id = de.department_id 
	where de.to_date = '9999-01-01'
	group by 1,2
),
list_manager as(
	select
		d.id,
		concat(e.first_name, ' ', e.last_name) as manager_name 
	from employee e 
	join department_manager dm on dm.employee_id = e.id 
	join department d on d.id = dm.department_id 
	where dm.to_date = '9999-01-01'
)
select
	te.dept_name,
	lm.manager_name,
	te.total_employee
from total_employees te
join list_manager lm on lm.id = te.id
order by 3 desc

-- Question 4
-- Show a comparison between the number of male and female employees for each department, making sure to only take into account active employees
select
	d.dept_name,
	e.gender,
	count(distinct de.employee_id) 
from employee e 
join department_employee de on de.employee_id = e.id 
join department d on d.id = de.department_id 
where de.to_date = '9999-01-01'
group by 1,2

-- Question 5
-- Show departments with the highest rate or ratio of active female employees to total active employees per department
select
	d.dept_name,
	sum(case when e.gender = 'F' then 1 else 0 end) as total_woman_employee,
	count(distinct de.employee_id) as total_employee,
	sum(case when e.gender = 'F' then 1 else 0 end) / count(distinct de.employee_id)::float as rate
from employee e 
join department_employee de on de.employee_id = e.id 
join department d on d.id = de.department_id 
where de.to_date = '9999-01-01'
group by 1
order by 4 desc

-- Question 6
-- Display the latest manager information on the department with the most employees
with number_employee as(
	select
		d.id,
		d.dept_name,
		count(distinct de.employee_id) as total_employee
	from department_employee de 
	join department d on d.id = de.department_id 
	where de.to_date = '9999-01-01'
	group by 1, 2
	order by 3 desc
),
manager as(
	select
		concat(e.first_name, ' ', e.last_name) as full_name,
		t.title as new_title,
		s.amount as new_salary,
		e.gender,
		e.hire_date,
		d.id,
		d.dept_name
	from employee e 
	join title t on t.employee_id = e.id 
	join salary s on s.employee_id = e.id
	join department_manager dm on dm.employee_id = e.id 
	join department d on d.id = dm.department_id 
	where t.to_date = '9999-01-01' and s.to_date = '9999-01-01' and dm.to_date = '9999-01-01'
)
select
	m.full_name,
	m.new_title,
	m.new_salary,
	m.gender,
	m.hire_date,
	m.dept_name,
	no.total_employee
from manager m
join number_employee no on no.id = m.id
order by no.total_employee desc
limit 1

-- Question 7
-- Show information of 10 active employees along with their latest job title and salary 
-- who have worked the longest in the company based on the date the employee was hired.
select
	e.id as employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	e.gender,
	e.hire_date,
	t.title as new_title,
	s.amount as new_salary,
	d.dept_name 
from employee e 
join title t on t.employee_id = e.id 
join salary s on s.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
join department d on d.id = de.department_id 
where t.to_date = '9999-01-01' and s.to_date = '9999-01-01' and de.to_date = '9999-01-01'
order by e.hire_date asc, new_salary desc
limit 10

-- Question 8
-- Show average salary comparisons for each employee position, making sure to only take into account 
-- the most recent job title and salary of employees still working for the company
select
	t.title,
	round(avg(s.amount)::numeric, 2) as avg_new_salary
from employee e 
join salary s on s.employee_id = e.id 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where s.to_date = '9999-01-01' and de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
group by 1
order by 2 desc

-- Question 9
-- Show a comparison of the number of male and female employees and how the average recent salary 
-- of the two gender groups compares, making sure to only include active employees
select
	e.gender,
	count(distinct de.employee_id) as total_employee,
	round(avg(s.amount)::numeric, 2) as avg_salary
from employee e 
join department_employee de on de.employee_id = e.id 
join salary s on s.employee_id = e.id 
where s.to_date = '9999-01-01' and de.to_date = '9999-01-01'
group by 1
order by 3 desc

-- Question 10
-- Show total employees hired per month for each year
select
	extract(month from e.hire_date) as month_hire,
	count(id) as total_hire
from employee e 
group by 1
order by 1 asc

-- Question 11
-- Display changes in the position or title of active employees from one period to the next
select
	concat(e.first_name, ' ', e.last_name) as employee_name,
	t.title as from_title,
	t.from_date,
	t.to_date,
	lead(t.title) over(partition by t.employee_id order by t.from_date) as to_title
from employee e 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where de.to_date = '9999-01-01'
order by 1, 3 asc

-- Question 12
-- Show new employee information and active employee status of the department with the manager who has the highest salary, make sure it is the latest salary.
with manager_highest_salary as(
	select
		d.id as department_id,
		d.dept_name,
		concat(e.first_name, ' ', e.last_name) as manager_name,
		s.amount as manager_salary
	from employee e 
	join salary s on s.employee_id = e.id 
	join department_manager dm on dm.employee_id = e.id 
	join department d on d.id = dm.department_id 
	where s.to_date = '9999-01-01' and dm.to_date = '9999-01-01'
	order by 4 desc 
	limit 1
),
employees as(
	select
		d.id as department_id,
		concat(e.first_name, ' ', e.last_name) as employee_name,
		e.hire_date 
	from employee e 
	join department_employee de on de.employee_id = e.id 
	join department d on d.id = de.department_id 
	where de.to_date = '9999-01-01'
	order by 3 desc
)
select
	mhs.department_id,
	mhs.dept_name,
	mhs.manager_name,
	mhs.manager_salary,
	emp.employee_name,
	emp.hire_date
from manager_highest_salary mhs
join employees emp on emp.department_id = mhs.department_id

-- Question 13
-- Show the average years required as well as the minimum and maximum years 
-- for an employee to be promoted from ‘Staff’ to ‘Senior Staff’ or ‘Assistant Engineer’ to ‘Engineer’ for each department.
with duration_promotion as(
	select * from(
		select
			de.employee_id,
			d.dept_name,
			t.title as from_title,
			t.from_date,
			t.to_date,
			lead(t.title) over(partition by t.employee_id order by t.from_date) as to_title,
			extract(day from (t.to_date::timestamp - t.from_date::timestamp)) / 365 as duration
		from employee e 
		join title t on t.employee_id = e.id 
		join department_employee de on de.employee_id = e.id 
		join department d on d.id = de.department_id 
		where de.to_date = '9999-01-01'
	) as temp_table
	where from_title in ('Staff', 'Assistant Engineer')
		and to_title in ('Senior Staff', 'Engineer')
)
select 
	dept_name,
	round(min(duration), 3) as min_years_needed,
	round(max(duration), 3) as max_years_needed,
	round(avg(duration), 3) as avg_years_needed
from duration_promotion
group by 1

-- Question 14
-- Show information on active employees who have been stuck in their career for the longest time, 
-- which means that they are still ‘Staff’ or ‘Assistant Engineer’ or other positions but there has been no change in position since they were recruited
with temp_table as(
	select 
		concat(e.first_name, ' ', e.last_name) as employee_name,
		t.title as from_title,
		lead(t.title) over(partition by t.employee_id order by t.from_date) as to_title,
		t.from_date,
		t.to_date
	from employee e 
	join title t on t.employee_id = e.id 
	join department_employee de on de.employee_id = e.id
	where de.to_date = '9999-01-01'
	order by 1 asc
) 
select * from(
	select *,
		count(employee_name) over(partition by employee_name) as order_title
	from temp_table
	group by 1,2,3,4,5
)
where order_title = 1 and to_title is null

-- Question 15
-- Display information on the most senior active employee in the context of having an older age than other employees
select
	de.employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	t.title,
	d.dept_name,
	e.gender,
	e.birth_date
from employee e 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
join department d on d.id = de.department_id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
order by 6, 1 asc


-- Session 2
-- Question 1
-- Display the most junior active employee information in the context of having a younger age than other employees
select
	de.employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	t.title,
	d.dept_name,
	e.gender,
	e.birth_date
from employee e 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
join department d on d.id = de.department_id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
order by 6 desc, 1 asc

-- Question 2
-- Show information on the youngest employee hired in the company's history
select
	e.id as employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	t.title,
	e.gender,
	round(extract(day from (e.hire_date::timestamp - e.birth_date::timestamp)) / 365, 2) as age_at_join
from employee e 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
join department d on d.id = de.department_id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01'
order by 5, 1 asc

-- Question 3
-- Display information on the 10 active employees with the longest promotion time
with list_employee as(
	select * from(
		select
			concat(e.first_name, ' ', e.last_name) as employee_name,
			t.title as from_title,
			t.from_date,
			t.to_date,
			lead(t.title) over(partition by concat(e.first_name, ' ', e.last_name) order by t.to_date) as to_title
		from employee e 
		join title t on t.employee_id = e.id 
		join department_employee de on de.employee_id = e.id 
		join department d on d.id = de.department_id 
		where de.to_date = '9999-01-01'
	) as temp_table
	where to_title is not null
)
select *,
	to_date::timestamp - from_date::timestamp as len_of_promotion
from list_employee
order by 6 asc, 4 desc
limit 10

-- Question 4
-- Show new employee information along with the latest title and salary, make sure to only retrieve active employees
select
	e.id as employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	e.gender,
	e.hire_date,
	t.title,
	s.amount
from employee e 
join salary s on s.employee_id = e.id 
join title t on t.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where de.to_date = '9999-01-01' and t.to_date = '9999-01-01' and s.to_date = '9999-01-01'
order by 4 desc

-- Question 5
-- Display the latest manager information from each department with the highest salary
select
	concat(e.first_name, ' ', e.last_name) as manager_name,
	e.gender,
	d.dept_name,
	s.amount as manager_salary
from employee e 
join salary s on s.employee_id = e.id 
join department_manager dm on dm.employee_id = e.id 
join department d on d.id = dm.department_id 
where s.to_date = '9999-01-01' and dm.to_date = '9999-01-01'
order by 4 desc 

-- Question 6
-- Show a comparison between the number of managers with male and female gender and 
-- how the average of the latest salaries of both gender groups of managers looks like
select
	e.gender,
	count(distinct dm.employee_id) as total_manager,
	round(avg(s.amount), 2) as avg_salary
from employee e 
join salary s on s.employee_id = e.id 
join department_manager dm on dm.employee_id = e.id 
where dm.to_date = '9999-01-01' 
group by 1

-- Question 7
-- Show the total number of employees who resigned per month for each year for any reason, self-decided or contract terminated by the company
with get_employee_active as(
	select de.*
	from employee e 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
),
get_employee_inactive as(
	select distinct e.*
	from employee e 
	left join get_employee_active gea on gea.employee_id = e.id
	where gea.id is null
),
get_last_period as(
	select 
		de.employee_id,
		concat(gei.first_name, ' ', gei.last_name) as employee_name,
		de.to_date,
		last_value(de.to_date) over(partition by de.employee_id order by de.to_date asc
			range between unbounded preceding and unbounded following) as last_period
	from get_employee_inactive gei
	join department_employee de on de.employee_id = gei.id
)
select 
	extract(month from last_period) as month_resign,
	count(distinct employee_id) as total_employee
from get_last_period
group by 1
order by 1 asc

-- Question 8
-- Show information on the employee with the shortest length of service (has resigned or quit) in days and include the last salary he/she earned
with get_employee_active as(
	select de.*
	from employee e 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
),
get_employee_inactive as(
	select distinct e.*
	from employee e 
	left join get_employee_active gea on gea.employee_id = e.id
	where gea.id is null
),
get_last_information as(
	select distinct
		de.employee_id,
		concat(gei.first_name, ' ', gei.last_name) as employee_name,
		gei.hire_date,
		last_value(de.to_date) over(partition by de.employee_id order by de.to_date asc
			range between unbounded preceding and unbounded following) as last_period,
		last_value(s.amount) over(partition by de.employee_id order by s.to_date asc
			range between unbounded preceding and unbounded following) as last_salary
	from get_employee_inactive gei
	join department_employee de on de.employee_id = gei.id
	join salary s on s.employee_id = gei.id
)
select 
	employee_id,
	employee_name,
	hire_date,
	last_period,
	extract(day from last_period::timestamp - hire_date::timestamp) as len_of_employee,
	last_salary
from get_last_information
order by 5 asc

-- Question 9
-- Show departments with the most manager changes so far
select
	d.dept_name,
	count(dm.employee_id) as total_manager_changest
from department_manager dm 
join department d on d.id = dm.department_id 
group by 1
order by 2 desc, 1 asc

-- Question 10
-- Show the information of the youngest manager hired in the company's history
select 
	concat(e.first_name, ' ', e.last_name) as manager_name,
	e.gender,
	e.hire_date,
	d.dept_name,
	round(extract(day from (e.hire_date::timestamp - e.birth_date::timestamp)) / 365, 2) as age_at_join
from employee e 
join department_manager dm on dm.employee_id = e.id 
join department d on d.id = dm.department_id 
order by 5 asc

-- Question 11
-- Show departments with the total cost of employee salaries borne by the company
select 
	d.id as department_id,
	d.dept_name,
	sum(s.amount) as total_salary
from employee e 
join salary s on s.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
join department d on d.id = de.department_id 
where de.to_date = '9999-01-01' and s.to_date = '9999-01-01'
group by 1,2
order by 1 asc

-- Question 12
-- Show changes in active employee salaries from one period to the next if there are changes, otherwise return null
select 
	e.id as employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	s.from_date, 
	s.to_date,
	s.amount as current_salary,
	lead(s.amount) over(partition by e.id order by s.from_date asc) as next_salary
from employee e 
join salary s on s.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where de.to_date = '9999-01-01'
order by 1, 3 asc

-- Question 13
-- Display the salary difference of each active employee's salary change from one period to the next if there is a change, otherwise return null
select 
	e.id as employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	s.from_date, 
	s.to_date,
	s.amount as current_salary,
	lead(s.amount) over(partition by e.id order by s.from_date asc) as next_salary,
	lead(s.amount) over(partition by e.id order by s.from_date asc) - s.amount as salary_diff
from employee e 
join salary s on s.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where de.to_date = '9999-01-01'
order by 2, 3 asc

-- Question 14
-- Display information on active employees who have experienced the largest salary decrease per period, then sort by employee id
select 
	e.id as employee_id,
	concat(e.first_name, ' ', e.last_name) as employee_name,
	s.from_date, 
	s.to_date,
	s.amount as current_salary,
	lead(s.amount) over(partition by e.id order by s.from_date asc) as next_salary,
	lead(s.amount) over(partition by e.id order by s.from_date asc) - s.amount as salary_diff
from employee e 
join salary s on s.employee_id = e.id 
join department_employee de on de.employee_id = e.id 
where de.to_date = '9999-01-01'
order by 7, 1 asc

-- Question 15
-- Show 10 information of employees who have the highest percentage of salary increase per period 
with salary_employee as(
	select 
		e.id as employee_id,
		concat(e.first_name, ' ', e.last_name) as employee_name,
		s.from_date, 
		s.to_date,
		s.amount as current_salary,
		lead(s.amount) over(partition by e.id order by s.from_date asc) as next_salary
	from employee e 
	join salary s on s.employee_id = e.id 
	join department_employee de on de.employee_id = e.id 
	where de.to_date = '9999-01-01'
)
select *,
	round(((next_salary - current_salary) / current_salary) * 100, 2) as percent_increase
from salary_employee
where next_salary is not null
order by 7 desc