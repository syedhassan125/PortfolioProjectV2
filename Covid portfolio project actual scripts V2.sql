Select*From
Coviddeaths


-- Select all columns from Covid vaccination table

Select * From
[Portfolio Project]..CovidVaccinations

-- Specify date and total cases for United states only

Select Location, date, total_cases
From [Portfolio Project]..Coviddeaths
Where
location = 'United States'

-- Looking into total number of deaths globally.

Select Sum(Cast(total_deaths as int)) as GlobalDeaths
From [Portfolio Project]..Coviddeaths

-- I was having issues with calculating total number of deaths globally, as the column was varchar so had to follow the below steps
SELECT COLUMN_NAME, DATA_TYPE
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'Coviddeaths' AND COLUMN_NAME = 'total_deaths';

SELECT SUM(CAST(total_deaths AS INT)) AS GlobalDeaths
FROM [Portfolio Project]..Coviddeaths;


SELECT SUM(CAST(total_deaths AS BIGINT)) AS GlobalDeaths
FROM [Portfolio Project]..Coviddeaths;


ALTER TABLE Coviddeaths
ALTER COLUMN total_deaths INT; -- Change INT to the appropriate data type

---- Looking into total vaccination and date for Pakistan.
Select Location, date, total_vaccinations
From [Portfolio Project]..CovidVaccinations
Where location = 'Pakistan'

-- Looking into summary statistics from the covid_deaths table

Select
Count (*) as totalnumberofrecords,
Sum(Cast(Total_deaths as bigint)) as total_deaths, AVG(Cast(Total_Deaths as bigint)) as averagedeaths
, Max (Cast (total_deaths as bigint)) as maxdeaths,Min(Cast(Total_deaths as bigint)) as minimumdeaths
From [Portfolio Project]..Coviddeaths

-- Looking into summary statistics from the covid_vaccination table
Select
COUNT (*) as totalnumberofrecords,
SUM(Cast(total_tests as bigint)) as totaltests, AVG(Cast(total_tests as bigint)) as averagetests, 
MAX(Cast(total_tests as bigint)) as maximumtests, Min(Cast(total_tests as bigint)) as minimumtests
From [Portfolio Project]..CovidVaccinations


-- Joining covid_vaccination and covid_death table

Select dea.continent, dea.location, dea.date, total_deaths,total_tests, positive_rate
From [Portfolio Project]..Coviddeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where 
total_deaths is not null and total_tests is not null 
Order by
total_deaths, total_tests Desc;

-- Looking into the ratio of total vaccination to total cases for each location and date

Select 
Case when vac.total_vaccinations = 0 then 0
Else
Cast(total_cases as bigint) /Cast(total_vaccinations as bigint) End as
Casepervaccination, dea.location, dea.date
From [Portfolio Project]..Coviddeaths dea
Join [Portfolio Project]..CovidVaccinations vac
On dea.location = vac.location
and dea.date = vac.date
where 
total_deaths is not null and total_tests is not null and total_vaccinations is not null

-- Calulcating daily percentage change in total deaths for each location
Select 
location,date,
Case
When Lag (Cast(total_deaths as numeric)) Over (Partition by location order by date) is not null
Then (Cast(total_deaths As numeric) - lag(Cast(total_deaths as numeric)) Over (Partition by location order by date))/ lag(cast(total_deaths as numeric)) over (Partition by location order by date)*100
Else Null
End as dailypercentagechange
From [Portfolio Project]..Coviddeaths

-- Write a SQL query to compute the daily percentage change in total cases for each location.
Select
Location, date,
CASE
When lag(Cast(total_cases as numeric)) Over (Partition by location order by date) is not null
Then (Cast(Total_cases as numeric) - lag(Cast(total_cases as numeric)) Over (Partition by location order by date))/ lag(cast(total_cases as numeric)) over (Partition by location order by date)*100
Else Null
End as dailypercentagechangeintotalcases
From [Portfolio Project]..Coviddeaths



--write a SQL query to find the monthly percentage change in total vaccinations for each location?
Select
Location, 
Extract (Year from date) as year,
Extract (Month from date) as month,
CASE
When lag(Cast(total_vaccinations as numeric)) Over (Partition by location, Extract (year from date), Extract(month from date) Order by Date) is not null
Then (Cast(Total_vaccinations as numeric) - lag(Cast(Total_vaccinations as numeric)) Over (Partition by location, Extract (year from date), Extract(month from date) order by date))/ lag(cast(Total_vaccinations as numeric)) over (Partition by location, EXTRACT(YEAR FROM date), EXTRACT(MONTH FROM date) ORDER BY date)*100
Else Null
End as dailypercentagechangeintotalcases
From [Portfolio Project]..CovidVaccinations


--Identifying peaks -- Lookinng at the dates when the number of cases peaked for each location
With Maxnewcasesperlocation as( 
Select
Location,
max(new_cases) as max_new_cases
from 
[Portfolio Project]..Coviddeaths
Group by 
location
)
Select
location,date as peak_date,
max_new_cases as peak_new_cases
From
[Portfolio Project]..Coviddeaths
Join
Maxnewcasesperlocation on [Portfolio Project]..Coviddeaths.location = maxnewcasesperlocation.location
and [Portfolio Project]max_new_cases= maxnewcasesperlocation.max_new_cases



--Comparing trends -- looking at trends of new cases and new vaccination over time for a specific location

Select[Portfolio Project]..Coviddeaths.date, [Portfolio Project]..Coviddeaths.Location,new_cases, Cast(new_vaccinations as integer) as new_vaccinations
From [Portfolio Project]..Coviddeaths
Join [Portfolio Project]..CovidVaccinations on [Portfolio Project]..Coviddeaths.location = [Portfolio Project]..CovidVaccinations.location
Where 
[Portfolio Project]..Coviddeaths.location= 'Pakistan' 
Order by 
[Portfolio Project]..Coviddeaths.date


-- Calculate the total number of COVID deaths for each location and continent:

With totaldeathsbylocation as (
Select 
Continent,
location, 
Sum(cast(total_deaths as bigint)) as total_deaths
From [Portfolio Project]..Coviddeaths
Group by
continent,location
)

Select
continent,
location,
total_deaths
From
totaldeathsbylocation



--Find the average number of new COVID cases per million people for each continent:

With permillion as (
Select
Continent,
AVG(new_cases_per_million) as avg_new_cases_per_million
From
[Portfolio Project]..Coviddeaths
Group by 
continent
)

Select
Continent,
avg_new_cases_per_million
From
permillion



--Identify countries with the highest vaccination rates per hundred people:

With Vaccinationrates As (

Select
location,
Max(cast(total_vaccinations_per_hundred as bigint)) as max_vaccination_rate
From
[Portfolio Project]..CovidVaccinations
Group by 
location

)

Select
location,
max_vaccination_rate
From
Vaccinationrates
Order by
max_vaccination_rate desc;



--Compare the total number of vaccinations administered in different countries over time:

With vaccinationadministered as (
Select
location,
Sum (Cast (total_vaccinations as int))  Over (Partition by location order by date) as total_vaccinations_administired
From

Group by 
location
)
Select
location,
total_vaccinations_administired
From
vaccinationadministered
Order by 
location


--Calculate the positivity rate of COVID tests for each continent:

With positiveratepercontinent as (

Select
continent,
 SUM(CONVERT(FLOAT, positive_rate)) AS total_positive_rate
From
[Portfolio Project]..CovidVaccinations
Where
date is not null
Group by
continent, positive_rate
)

Select
continent,
total_positive_rate
From
positiveratepercontinent




-- Temp tables

--Create a temporary table for Covid Deaths data with only the necessary columns.

CREATE TABLE #CovidDeaths (
    iso_code VARCHAR(255),
    continent VARCHAR(255),
    location VARCHAR(255),
    date DATE,
    total_deaths INT
);

INSERT INTO #CovidDeaths (iso_code, continent, location, date, total_deaths)
SELECT 
    iso_code, 
    continent, 
    location, 
    date, 
    total_deaths
FROM 
    [Portfolio Project]..CovidDeaths;

	Select * from 
	#CovidDeaths




--Create a temporary table for Covid Vaccination data with only the necessary columns.

Create table #covidvaccinationsss (
iso_code varchar (255),
continent varchar(255),
location varchar (255),
total_tests bigint,

);
Insert into #covidvaccinationsss (iso_code,continent,location,total_tests)
Select
iso_code,
continent,
location,
total_tests
From
[Portfolio Project]..CovidVaccinations

select * from
#covidvaccinationsss



--Calculate the total deaths for each location and store the results in a temporary table.

Create table #total_deathsy (
location varchar (255),
total_deaths Decimal (18,0)
);
Insert into #total_deathsy (location, total_deaths)
Select
Location,
sum (Cast(Total_deaths as decimal (18,0))) as total_death 
From
[Portfolio Project]..Coviddeaths
Group by 
location
);

Select * from
#total_deathsy


--Calculate the total vaccinations for each location and store the results in a temporary table.

Create table #total_vaccinationyy (
location varchar (255),
total_vaccination Decimal (18,0)
);
Insert into #total_vaccinationyy (location,total_vaccination)
Select
location,
SUM(CAST(total_vaccinations as Decimal (18,0))) as total_vaccination
From
[Portfolio Project]..CovidVaccinations
Group by 
location

Select * from 
#total_vaccinationyy


--Global numbers
Select
date,
Sum(new_cases) as new_cases,
sum(new_deaths) as new_deaths,
Sum(cast(new_deaths as int))/sum(cast(new_cases as int))*100 as death_percentage
From
[Portfolio Project]..Coviddeaths
--Where location like '%states%'
--where continent is not null
Group by date
order by 1,2



-- looking at total population vs vaccination

Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Cast (vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
From
[Portfolio Project]..Coviddeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null and vac.new_vaccinations is not null
order by 2,3

-- USE CTE
With popvsvac (Continent,location,date,population,new_vaccinations,rollingpeoplevaccinated)
as
(
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Cast (vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
From
[Portfolio Project]..Coviddeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
)

Select*,(rollingpeoplevaccinated/population)*100
from
popvsvac

-- Temp Table

Create table #percentpopulationvaccinated
(
Continent nvarchar (255),
Location nvarchar (255),
Date datetime,
Population numeric,
New_vaccinations numeric,
Rollingpeoplevaccinated numeric
)
Insert into #percentpopulationvaccinated
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Cast (vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
From
[Portfolio Project]..Coviddeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

Select * from #percentpopulationvaccinated



-- Creating View to store data for later visualizations

Create view percentpopulationvaccinatedss as
Select dea.continent, dea.location,dea.date,dea.population,vac.new_vaccinations
,Sum(Cast (vac.new_vaccinations as bigint)) Over (Partition by dea.location order by dea.location, dea.date) as rollingpeoplevaccinated
From
[Portfolio Project]..Coviddeaths dea
Join [Portfolio Project]..CovidVaccinations vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
--order by 2,3




