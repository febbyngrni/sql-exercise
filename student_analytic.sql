-- Session 1
-- Question 1
-- Display student information with Business Management major
select 
	m.id,
	m.first_name,
	m.last_name,
	m.email,
	m.phone 
from mahasiswa m 
where id_jurusan = 2

-- Question 2
-- Display student information with Business Management major
-- and has an email with domain containing 'pd'
select 
	m.id,
	m.first_name,
	m.last_name,
	m.email,
	m.phone 
from mahasiswa m 
where id_jurusan = 2 and email ilike '%@pd%'

-- Question 3
-- Show total registered students
select count(m.id) as total_mahasiswa 
from mahasiswa m

-- Question 4
-- Show total registered lecturers
select count(d.id) as total_dosen 
from dosen d

-- Question 5
-- Show total registered lecturers for each major
select
	d.id_jurusan,
	count(d.id) as total_dosen 
from dosen d 
group by 1
order by 1 asc

-- Question 6
-- Show comparison of total students per major and total student overall
select
	m.id_jurusan,
	count(m.id) as total_mahasiswa_per_jurusan,
	(select count(*) from mahasiswa m2) as total_mahasiswa
from mahasiswa m 
group by 1
order by 1 asc;

-- Question 7
-- Display the total credits taken by students in each semester for Business Management majors
select
	semester,
	sum(sks) as total_sks 
from mata_kuliah mk
where id_jurusan = 2
group by semester

-- Question 8 
-- Display the names of courses offered for Business Management majors for odd semester students
select nama as mata_kuliah_ganjil
from mata_kuliah mk 
where id_jurusan = 2 and semester in (1,3)

-- Question 9
-- Show total rooms used by new students
select count(distinct ruangan) as total_ruangan 
from mata_kuliah mk 
where semester in (1, 2)

-- Question 10
-- Show rooms most frequently used by new students
with max_ruangan as(
	select mk.ruangan, count(mk.ruangan) as total_ruangan
	from mata_kuliah mk
	where mk.semester in (1,2)
	group by 1
)
select ruangan
from max_ruangan
where total_ruangan = (
	select max(total_ruangan)
	from max_ruangan
)

-- Question 11
-- Display 10 student IDs per course ID with the highest attendance rate
select
	a.id_mata_kuliah,
	a.id_mahasiswa,
	sum(case a.is_hadir when true then 1 else 0 end) as total_attendance,
	sum(case a.is_hadir when true then 1 else 0 end)::float / count(a.id) as attendance_level
from attendance a
group by 1, 2
order by 4 desc
limit 10

-- Question 12
-- Show course id with student absence rate above 50%
-- simple way
select
	a.id_mata_kuliah,
	sum(case a.is_hadir when true then 0 else 1 end) as total_absence,
	sum(case a.is_hadir when true then 0 else 1 end)::float / count(a.is_hadir) as absence_level
from mata_kuliah mk 
join attendance a on a.id_mata_kuliah = mk.id 
group by 1
having sum(case a.is_hadir when true then 0 else 1 end)::float / count(a.is_hadir) > 0.5
order by 3 desc

-- more complex way
with absence as(
	select 
		id_mata_kuliah,
		count(id) as total_absence
	from attendance a 
	where is_hadir = false 
	group by 1
),
total_attendance as(
	select 
		id_mata_kuliah,
		count(id) as total_attend
	from attendance a
	group by 1
)
select 
	a.id_mata_kuliah,
	a.total_absence,
	a.total_absence / cast(ta.total_attend as decimal) as absence_level
from absence a
join total_attendance ta
	on a.id_mata_kuliah = ta.id_mata_kuliah
group by 1,2, ta.total_attend
having a.total_absence / cast(ta.total_attend as decimal) > 0.5
order by 3 desc

-- Question 13
-- Show total student attendance per lecture week for the course ID with the highest absence rate
with max_absence as(
	select 
		a.id_mata_kuliah ,
		sum(case a.is_hadir when true then 0 else 1 end) as total_absence,
		sum(case a.is_hadir when true then 0 else 1 end)::float / count(a.is_hadir) as absence_level 
	from attendance a 
	group by 1
	order by 3 desc
	limit 1
)
select 
	a.week_kuliah,
	sum(case a.is_hadir when true then 1 else 0 end) as total_attendance,
	sum(case a.is_hadir when true then 1 else 0 end)::float / count(a.is_hadir) as attendance_level
from max_absence ma
join attendance a on a.id_mata_kuliah = ma.id_mata_kuliah
group by 1
order by 1 asc

-- Question 14
-- Show all courses with more than 3 credits
select 
	mk.nama, mk.sks
from mata_kuliah mk 
where mk.sks > 3
order by 2 asc

-- Question 15
-- Display the minimum, maximum, and average scores obtained by all students
select 
	min(nv.nilai) as nilai_minimum,
	max(nv.nilai) as nilai_maximum,
	avg(nv.nilai) as nilai_ratarata
from nilai_v2 nv 


-- Session 2
-- Question 1
-- Show student information from the Informatics Engineering department
select
	m.id as id_mahasiswa,
	concat(m.first_name, ' ', m.last_name) as full_name,
	m.email,
	m.phone,
	j.jurusan 
from mahasiswa m 
join jurusan j on m.id_jurusan = j.id 
where j.jurusan = 'Teknik Informatika'

-- Question 2
-- Display courses for each department along with the total students per course
select distinct 
	j.jurusan,
	mk.nama,
	count(distinct e.id_mahasiswa) as total_mahasiswa
from mata_kuliah mk 
join enrollment e on e.id_mata_kuliah = mk.id
join jurusan j on j.id = mk.id_jurusan
group by 1,2
order by 1 asc, 3 desc

-- Question 3
-- Display the average grade for each course in each department
select distinct 
	j.jurusan,
	mk.nama,
	avg(nv.nilai) as ratarata_nilai
from enrollment e 
join jurusan j on j.id = e.id_jurusan 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join nilai_v2 nv on nv.id_enrollment = e.id 
group by 1,2
order by 1 asc, 3 desc

-- Question 4
-- Display the courses in the Informatics Engineering department along with the number of credits and semester
select
	j.jurusan,
	mk.nama as mata_kuliah,
	mk.semester,
	mk.sks
from mata_kuliah mk 
join jurusan j on j.id = mk.id_jurusan 
where j.jurusan = 'Teknik Informatika'

-- Question 5
-- Display information on students majoring in Informatics Engineering and enrolment in Artificial Intelligence courses
select
	m.id as id_mahasiswa,
	concat(m.first_name, ' ', m.last_name) as full_name,
	m.email, m.phone, j.jurusan, mk.nama 
from mahasiswa m 
join jurusan j on j.id = m.id_jurusan 
join mata_kuliah mk on mk.id_jurusan = j.id
where j.jurusan = 'Teknik Informatika' and mk.nama = 'Kecerdasan Buatan'

-- Question 6
-- Show lecturers who teach in Informatics Engineering department and especially for Artificial Intelligence course
select 
	j.jurusan, 
	mk.nama as mata_kuliah,
	d.nama as nama_dosen
from dosen d 
join jurusan j on d.id_jurusan = j.id 
join mata_kuliah mk on mk.id_jurusan = j.id 
where j.jurusan = 'Teknik Informatika' and mk.nama = 'Kecerdasan Buatan'

-- Question 7
-- Show 10 students with the highest score from the Informatics Engineering department 
-- and enrolment in Artificial Intelligence courses, if the scores are the same sort by student id in ascending order
select distinct 
	m.id as id_mahasiswa,
	concat(m.first_name, ' ', m.last_name) as full_name,
	j.jurusan,
	mk.nama as mata_kuliah,
	nv.nilai
from mahasiswa m 
join enrollment e on m.id = e.id_mahasiswa 
join jurusan j on j.id = e.id_jurusan 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join nilai_v2 nv on e.id = nv.id_enrollment 
where j.jurusan = 'Teknik Informatika' and mk.nama = 'Kecerdasan Buatan'
order by 5 desc
limit 10

-- Question 8
-- Show students with the highest score for each course in the Informatics Engineering department
with agg as(
	select
		m.id as id_mahasiswa,
		concat(m.first_name, ' ', m.last_name) as full_name,
		mk.nama as mata_kuliah,
		nv.nilai,
		max(nv.nilai) over(partition by mk.nama) as max_nilai
	from mahasiswa m 
	join enrollment e on m.id = e.id_mahasiswa 
	join jurusan j on j.id = e.id_jurusan 
	join mata_kuliah mk on mk.id = e.id_mata_kuliah 
	join nilai_v2 nv on e.id = nv.id_enrollment
	where j.jurusan = 'Teknik Informatika'
)
select
	id_mahasiswa,
	full_name,
	mata_kuliah,
	nilai
from agg
where nilai = max_nilai
order by 3, 1 asc

-- Question 9
-- Show students with total attendance and attendance rate from Informatics Engineering major and Artificial Intelligence course enrolment
select 
	mk.nama as mata_kuliah,
	concat(m.first_name, ' ', m.last_name) as full_name,
	sum(a.is_hadir::int) as total_attendace,
	sum(a.is_hadir::int)::numeric / count(a.*) as attendance_level
from attendance a
join mahasiswa m on m.id = a.id_mahasiswa 
join mata_kuliah mk on mk.id = a.id_mata_kuliah
where mk.nama = 'Kecerdasan Buatan'
group by 1, 2
order by 4 desc

-- Question 10
-- Show a comparison of the total attendance of each lecture week for the Artificial Intelligence course
with total_attendance as(
	select
		a.week_kuliah,
		sum(case a.is_hadir when true then 1 else 0 end) as total_attendance
	from attendance a 
	join mata_kuliah mk on mk.id = a.id_mata_kuliah 
	where mk.nama = 'Kecerdasan Buatan'
	group by 1
	order by 1
)
select 
	week_kuliah, 
	total_attendance,
	lead(total_attendance) over(order by week_kuliah) as next_week
from total_attendance

-- Question 11
-- Display the range of load scores (minimum, maximum, average, standard deviation, and total) 
-- given by each lecturer teaching in the Artificial Intelligence course
select
	distinct d.nama as nama_dosen,
	min(nv.nilai) as minimum,
	max(nv.nilai) as maksimum,
	avg(nv.nilai) as ratarata,
	stddev(nv.nilai) as standardeviasi,
	count(nv.nilai) as total 
from dosen d 
join enrollment e on d.id = e.id_dosen 
join jurusan j on j.id = e.id_jurusan 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join nilai_v2 nv on e.id = nv.id_enrollment 
where mk.nama = 'Kecerdasan Buatan'
group by 1

-- Question 12
-- Show the number of 0's given by each lecturer to their students in the Artificial Intelligence course
with zero_given as(
	select
		d.nama as nama_dosen,
		nv.nilai
	from dosen d 
	join enrollment e on e.id_dosen = d.id 
	join jurusan j on j.id = e.id_jurusan 
	join mata_kuliah mk on mk.id = e.id_mata_kuliah 
	join nilai_v2 nv on e.id = nv.id_enrollment 
	where nilai = 0 and mk.nama = 'Kecerdasan Buatan'
)
select 
	nama_dosen, 
	count(nilai) as zero_given
from zero_given
group by 1

-- Question 13
-- Show majors with courses that have a schedule on Friday along with the total students for each course
select 
	j.jurusan,
	mk.nama as mata_kuliah,
	count(distinct e.id_mahasiswa) as total_mahasiswa 
from jurusan j 
join mata_kuliah mk on mk.id_jurusan = j.id 
join enrollment e ON e.id_mata_kuliah = mk.id 
where mk.jadwal ilike 'Jum_at'
group by 1, 2

-- Question 14
-- Show students who have a schedule on Monday in the 3rd floor room
select distinct 
	m.id as id_mahasiswa,
	concat(m.first_name, ' ', m.last_name) as full_name,
	m.email,
	mk.nama as mata_kuliah,
	mk.jadwal,
	mk.ruangan
from mata_kuliah mk 
join enrollment e on e.id_mata_kuliah = mk.id 
join mahasiswa m on m.id = e.id_mahasiswa 
where mk.jadwal = 'Senin' and mk.ruangan = 'Lantai 3'
order by 4, 1 asc

-- Question 15
-- Show lecturers who have a schedule on Monday and Thursday in the 1st floor room
select
	d.nama as nama_dosen,
	mk.nama as mata_kuliah,
	mk.jadwal,
	mk.ruangan 
from dosen d 
join jurusan j on d.id_jurusan = j.id 
join mata_kuliah mk on mk.id_jurusan = j.id
where mk.jadwal in ('Senin', 'Kamis') and mk.ruangan = 'Lantai 1'
order by 3 desc


-- Session 3
-- Question 1
-- Find the average score of students from each course taken
select
	e.id_mahasiswa,
	concat(m.first_name, ' ', m.last_name) as full_name,
	mk.nama as mata_kuliah,
	avg(nv.nilai) over(partition by e.id_mahasiswa, mk.nama) 
from mahasiswa m 
join enrollment e on m.id = e.id_mahasiswa 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join nilai_v2 nv on nv.id_enrollment = e.id 
order by 1 asc

-- Question 2
-- Find students who are ranked 3rd in each department
select * from(
	select distinct 
		e.id_mahasiswa,
		concat(m.first_name, ' ', m.last_name) as full_name,
		e.id_jurusan,
		j.jurusan,
		nv.nilai,
		row_number() over(partition by j.jurusan order by nv.nilai desc) as rank_nilai
	from enrollment e 
	join nilai_v2 nv on nv.id_enrollment = e.id
	join jurusan j on j.id = e.id_jurusan 
	join mahasiswa m on m.id = e.id_mahasiswa
) as a
where rank_nilai = 3

-- Question 3
-- Find the average percentage of student attendance in each course
with total_attendance as(
	select
		a.id_mata_kuliah,
		mk.nama as mata_kuliah,
		count(a.id) as total_data, 
		sum(case is_hadir when true then 1 else 0 end) as total_hadir
	from mata_kuliah mk 
	join attendance a on a.id_mata_kuliah = mk.id 
	group by 1,2
	order by 1 asc
)
select *,
	round((total_hadir::numeric / total_data) * 100, 2) as percentage_kehadiran
from total_attendance

-- Question 4
-- Look for courses that have the most interest, 
-- the definition of a lot of interest is when the number of students who take the course is large
with total_mahasiswa as(
	select
		mk.id,
		mk.nama,
		count(id_mahasiswa) as jumlah_mahasiswa 
	from mata_kuliah mk 
	join enrollment e on e.id_mata_kuliah = mk.id 
	group by 1, 2
)
select *
from total_mahasiswa
where jumlah_mahasiswa >= (
	select max(jumlah_mahasiswa)
	from total_mahasiswa)
	
-- Question 5
-- Average scores generated by each lecturer and each course
select
	e.id_dosen, 
	d.nama as nama_dosen,
	mk.nama as mata_kuliah,
	round(avg(nv.nilai)::numeric, 2) as avg_nilai
from dosen d
join enrollment e on d.id = e.id_dosen 
join mata_kuliah mk on mk.id = e.id_mata_kuliah 
join nilai_v2 nv on nv.id_enrollment = e.id 
group by 1,2,3
order by 1 asc

-- Question 6
-- Of all the majors, the ones that have the 4th rank from the average score are
select * from(
	select
		e.id_jurusan,
		j.jurusan,
		round(avg(nv.nilai)::numeric, 2) as avg_nilai,
		rank() over(order by avg(nv.nilai) desc) as rank
	from jurusan j 
	join enrollment e on j.id = e.id_jurusan 
	join nilai_v2 nv on nv.id_enrollment = e.id 
	group by 1,2
) as a
where rank = 4

-- Question 7
-- Find courses and lecturers that have an attendance rate above 50% and take the top 5
select * from(
	select
		a.id_mata_kuliah,
		mk.nama as mata_kuliah,
		d.nama as nama_dosen,
		round((sum(case is_hadir when true then 1 else 0 end) / count(a.id)::numeric) * 100, 2) as percentage_kehadiran
	from dosen d 
	join jurusan j on d.id_jurusan = j.id 
	join mata_kuliah mk on mk.id_jurusan = j.id 
	join attendance a on a.id_mata_kuliah = mk.id 
	group by 1,2,3
) as attendance
where percentage_kehadiran > 50
order by 4 desc

-- Question 8
-- Find the lecturer with the most students, take the top 3
select
	d.nama as nama_dosen,
	count(e.id_mahasiswa) as jumlah_mahasiswa 
from dosen d 
join enrollment e on d.id = e.id_dosen 
group by 1
order by 2 desc 
limit 3

-- Question 9
-- Look up the week-to-week progress of students attending each course
select
	a.id_mata_kuliah,
	mk.nama as mata_kuliah,
	a.week_kuliah,
	sum(case is_hadir when true then 1 else 0 end) as mahasiswa_hadir
from mata_kuliah mk 
join attendance a on mk.id = a.id_mata_kuliah 
group by 1,2,3
order by 1 asc

-- Question 10
-- Which lecturer is number 7 in the number of credits held?
select * from(
	select
		d.id ,
		d.nama as nama_dosen,
		sum(mk.sks) as jumlah_sks,
		row_number() over(order by sum(mk.sks) desc) as rank_jumlah_sks
	from dosen d 
	join jurusan j on d.id_jurusan = j.id 
	join mata_kuliah mk on mk.id_jurusan = j.id 
	group by 1,2
) as a
where rank_jumlah_sks = 7