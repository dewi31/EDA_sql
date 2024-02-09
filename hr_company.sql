create database projects_hr;

use projects_hr;

select * from hr;

-- Data cleaning and preprocessing-- 

alter table hr 
change column ï»¿id emp_id varchar(20) null;

describe hr

-- mengubah format kolom birthdate, hire_date, dan termdate agar konsisten --
-- birthdate --
set sql_safe_updates = 0;

update hr
set birthdate = case
	when birthdate like '%/%' then date_format(str_to_date(birthdate, '%m/%d/%Y'), '%Y-%m-%d')
    when birthdate like '%-%' then date_format(str_to_date(birthdate, '%m-%d-%Y'), '%Y-%m-%d')
    else null
    end;
    
alter table hr
modify column birthdate date;

-- hire_date --
update hr
set hire_date = case
	when hire_date like '%/%' then date_format(str_to_date(hire_date, '%m/%d/%Y'), '%Y-%m-%d')
    when hire_date like '%-%' then date_format(str_to_date(hire_date, '%m-%d-%Y'), '%Y-%m-%d')
    else null
    end;
    
alter table hr
modify column hire_date date;

-- termdate --
update hr
set termdate = date(str_to_date(termdate, '%Y-%m-%d %H:%i:%s UTC'))
where termdate is not null and termdate !='';

update hr
set termdate = null
where termdate = '';

-- membuat kolom umur --
alter table hr
add column age int;

update hr
set age = timestampdiff(year, birthdate, curdate());

-- untuk mengetahui min umur dan max umur pegawai --
select min(age), max(age) from hr;

-- 1. Bagaimana pembagian jenis kelamin karyawan di perusahaan tersebut --
select * from hr;

select gender, count(*) as count
from hr
where termdate is null
group by gender;

-- 2. Bagaimana pembagian ras karyawan di perusahaan tersebut --
select race, count(*) as count
from hr
where termdate is null
group by race;

-- 3. Berapa sebaran usia karyawan di perusahaan tersebut --
select 
	case 
		when age >= 18 and age <= 24 then '18-24'
        when age >= 25 and age <= 34 then '25-34'
        when age >= 35 and age <= 44 then '35-44'
        when age >= 45 and age <= 54 then '45-54'
	    when age >= 55 and age <= 64 then '55-64'
        else '65+'
	end as age_group,
    count(*) as count
    from hr
    where termdate is null
    group by age_group
    order by age_group;
    
-- 4. Berapa banyak karyawan yang bekerja di kantor pusat vs jarak jauh --
select location, count(*) as count
from hr
where termdate is null
group by location;

-- 5. Berapa rata-rata masa kerja yang diberhentikan --
select round(avg(year(termdate) - year(hire_date)),0) as length_of_emp
from hr
where termdate is not null and termdate <= curdate()

-- 6. Bagaimana variasi distribusi gender antar departemen dan jabatan --
select * from hr;

select department, jobtitle, gender, count(*) as count
from hr
where termdate is not null
group by department, jobtitle, gender
order by department, jobtitle, gender;

select department, gender, count(*) as count
from hr
where termdate is not null
group by department, gender
order by department, gender;

-- 7. Bagaimana distribusi penyebaran jabatan di perusahaan
select jobtitle, count(*) as count
from hr
where termdate is null
group by jobtitle

-- 8. departemen mana yang memiliki tingkat turnover/pemutusan hubungan kerja yang lebih tinggi --
select * from hr;

select department,
	count(*) as total_count,
    count( case 
				when termdate is not null and termdate <= curdate() then 1
                end) as terminated_count,
	round((count( case 
				when termdate is not null and termdate <= curdate() then 1
                end)/count(*))*100,2) as termination_rate
	from hr
    group by department
    order by termination_rate desc;
    
-- 9. Bagaimana distribusi karyawan di seluruh location_state --
select location_state, count(*) as count
from hr
where termdate is null
group by location_state;

select location_city, count(*) as count
from hr
where termdate is null
group by location_city;

-- 10. Bagaimana jumlah karyawan perusahaan berubah dari waktu ke waktu berdasarkan tanggal perekrutan dan pemberhentian. --
select year,
	   hires,
       terminations,
       hires-terminations as net_change,
       (terminations/hires)*100 as change_percent
	from(
			select year(hire_date) as year,
            count(*) as hires,
            sum(case
					when termdate is not null and termdate <= curdate() then 1
                    end) as terminations
			from hr
            group by year(hire_date)) as subquery
group by year
order by year;

-- 11. Bagaimana pembagian masa jabatan antar departemen
select * from hr;

select department, round(avg(datediff(termdate, hire_date)/365),0) as avg_tenure
from hr
where termdate is not null and termdate <= curdate()
group by department;