SELECT
location,
population,
date,
total_cases,
new_cases,
total_deaths
FROM dbo.Covid_Deaths$
---------------------------------------------------------------
--Total cases Vs Total Deaths
----------------------------------------------------------------
SELECT
location,
date,
total_cases,
new_cases,
total_deaths,
(CONVERT(DECIMAL(15, 3), total_cases) / CONVERT(DECIMAL(15, 3), total_deaths))*100 as Death_Pcnt
FROM dbo.Covid_Deaths$
where location like '%states%'
order by 1,2

---------------------------------------------------------------
--Total cases Vs population % of population got covid
----------------------------------------------------------------
SELECT
location,
population,
date,
total_cases,
new_cases,
total_deaths,
(CONVERT(DECIMAL(15, 3), total_cases) / CONVERT(DECIMAL(15, 3), population))*100 AS 'pop_Pcnt_infected'
FROM dbo.Covid_Deaths$
where continent is not null
order by date

---------------------------------------------------------------
--countries with highest infections
----------------------------------------------------------------

SELECT
location,
population,
MAX(total_cases) Highest_Infection_count
FROM dbo.Covid_Deaths$
where continent is not null
group by
location,
population
--where location like '%states%'
order by Highest_Infection_count desc

---------------------------------------------------------------
--countries with highest Death count of population
----------------------------------------------------------------

SELECT
location,
MAX(total_deaths ) Highest_Infection_count
--MAX((CONVERT(DECIMAL(15, 3), total_deaths) / CONVERT(DECIMAL(15, 3), population))*100 )AS Highest_Death_Pcnt
FROM dbo.Covid_Deaths$
where continent is not null
group by
location
--where location like '%states%'
order by Highest_Infection_count desc



---------------------------------------------------------------
--continent with the highest count
----------------------------------------------------------------
SELECT
continent,
MAX(total_deaths ) Highest_Infection_count
--MAX((CONVERT(DECIMAL(15, 3), total_deaths) / CONVERT(DECIMAL(15, 3), population))*100 )AS Highest_Death_Pcnt
FROM dbo.Covid_Deaths$
where continent is not null
group by
continent
--where location like '%states%'
order by Highest_Infection_count desc

---------------------------------------------------------------
--Global Numbers
----------------------------------------------------------------

SET ANSI_WARNINGS OFF;
GO
SELECT
sum(CONVERT(DECIMAL(15, 3), new_cases)) as Total_Global_Cases,
sum(CONVERT(DECIMAL(15, 3), new_deaths)) as Total_Global_Deaths,
sum(CONVERT(DECIMAL(15, 3), new_deaths))/sum(NULLIF(CONVERT(DECIMAL(15, 3), new_cases),0))*100 as Global_Death_Pct
FROM dbo.Covid_Deaths$
where continent is not null
order by 1,2


---------------------------------------------------------------
-- New Vaccinations
----------------------------------------------------------------
 SELECT 
 d.location,
 d.population,
 d.date,
 v.new_vaccinations
 FROM dbo.Covid_Deaths$ d
 INNER JOIN dbo.Vacination$ v on d.location =v.location and d.date= v.date
 where d.continent is not null

 
---------------------------------------------------------------
--Using Rolling  count on  vaciination count
----------------------------------------------------------------
 SELECT
 distinct
 d.continent,
 d.location,
 d.population,
 d.date, 
 v.new_vaccinations,
 sum(CONVERT(DECIMAL(15, 3),v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as Rolling_Vac_Count 
 FROM dbo.Covid_Deaths$ d
 JOIN dbo.Vacination$ v on d.location =v.location and d.date= v.date
 where d.continent is not null
 order by  d.location,d.date

 --------------------------------------------------------------------
 --USE CTE
 --------------------------------------------------------------------
with pop_vacc (
continent,
location,
population,
date, 
new_vaccinations,
Rolling_Vac_Count) as(

 SELECT
 distinct
 d.continent,
 d.location,
 d.population,
 d.date, 
 v.new_vaccinations,
 sum(CONVERT(DECIMAL(15, 3),v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as Rolling_Vac_Count 
 FROM dbo.Covid_Deaths$ d
 JOIN dbo.Vacination$ v on d.location =v.location and d.date= v.date
 where d.continent is not null)

 SELECT *, (Rolling_Vac_Count/population)*100 as Total_Pop_Vacc
 FROM pop_vacc 
 ---------------------------------------------------------------------------
 --Create View for visualisation
 ----------------------------------------------------------------------------
 create view pcnt_pop_vacc as
  SELECT
 distinct
 d.continent,
 d.location,
 d.population,
 d.date, 
 v.new_vaccinations,
 sum(CONVERT(DECIMAL(15, 3),v.new_vaccinations)) over(partition by d.location order by d.location, d.date) as Rolling_Vac_Count 
 FROM dbo.Covid_Deaths$ d
 JOIN dbo.Vacination$ v on d.location =v.location and d.date= v.date
 where d.continent is not null

create view global_death as
  SELECT
sum(CONVERT(DECIMAL(15, 3), new_cases)) as Total_Global_Cases,
sum(CONVERT(DECIMAL(15, 3), new_deaths)) as Total_Global_Deaths,
sum(CONVERT(DECIMAL(15, 3), new_deaths))/sum(NULLIF(CONVERT(DECIMAL(15, 3), new_cases),0))*100 as Global_Death_Pct
FROM dbo.Covid_Deaths$
where continent is not null


create view Vaccinated as 
 SELECT 
 d.location,
 d.population,
 d.date,
 v.new_vaccinations
 FROM dbo.Covid_Deaths$ d
 INNER JOIN dbo.Vacination$ v on d.location =v.location and d.date= v.date
 where d.continent is not null

 create view Country_High_Death as 
 SELECT
continent,
MAX(total_deaths ) Highest_Infection_count
--MAX((CONVERT(DECIMAL(15, 3), total_deaths) / CONVERT(DECIMAL(15, 3), population))*100 )AS Highest_Death_Pcnt
FROM dbo.Covid_Deaths$
where continent is not null
group by
continent

create view country_high_vacc as
SELECT
location,
population,
MAX(total_cases) Highest_Infection_count
FROM dbo.Covid_Deaths$
where continent is not null
group by
location,
population

create view TotcasesVsTotDeath as
SELECT
location,
date,
total_cases,
new_cases,
total_deaths,
(CONVERT(DECIMAL(15, 3), total_cases) / CONVERT(DECIMAL(15, 3), total_deaths))*100 as Death_Pcnt
FROM dbo.Covid_Deaths$


