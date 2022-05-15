SELECT location,date,total_cases,new_cases, total_deaths,population
FROM ['Covid Data deaths']
Where continent is NOT NULL
order by 1,2


--Looking at Total Cases vs Total Deaths:
--shows likelihood if you got covid in INDIA:

SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 AS DeathPercentage
FROM ['Covid Data deaths']
WHERE location like '%india%'
order by 1,2


--Looking at Total cases vs Population :
-- shows what percentage of population got covid:

SELECT location,date,population,total_cases,(total_cases/population)*100 AS PercentagePopulationInfected
FROM ['Covid Data deaths']
WHERE location like '%india%'
order by 1,2


--Looking at the countries with Highest Infection Rate compared to Population:

SELECT location,population,MAX(total_cases) AS HighestinfectionCount,MAX((total_cases/population))*100 AS PercentagePopulationInfected
FROM ['Covid Data deaths']
--WHERE location like '%india%'
WHERE continent is not null
group by location,population
order by PercentagePopulationInfected desc


--showing countries with highest death count per population:

SELECT location,population,MAX(cast(total_deaths as int)) as TotalDeathcount
FROM ['Covid Data deaths']
--WHERE location like '%india%'
WHERE continent is not null
group by location,population
order by TotalDeathcount desc


--lets see by continent:

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathcount
FROM ['Covid Data deaths']
--WHERE location like '%india%'
WHERE continent is not null
group by continent
order by TotalDeathcount desc


-- GLOBAL covid NUMBERS by date

SELECT date, SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int))as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Deathpercentage
FROM ['Covid Data deaths']
--WHERE location like '%india%'
WHERE continent is not null
Group by date
order by 1,2


--total deaths per total cases globally:

SELECT SUM(new_cases) as total_cases,SUM(CAST(new_deaths as int))as total_deaths,SUM(CAST(new_deaths as int))/SUM(new_cases)*100 AS Deathpercentage
FROM ['Covid Data deaths']
--WHERE location like '%india%'
WHERE continent is not null
--Group by date
order by 1,2



--Total Vaccination va Vaccinaion:
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
,SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) AS RollingPeopleVaccinated
from ['Covid Data deaths'] dea
join ['COVID Data vacc'] vacc
 on dea.date=vacc.date
 and dea.location=vacc.location
where dea.continent is not null
--WHERE dea.location like '%india%'
order by 2,3


---***** CTE TABLE ****

With PopvsVac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
,SUM(CONVERT(int,vacc.new_vaccinations)) OVER (Partition by dea.location order by dea.location,
dea.date) AS RollingPeopleVaccinated
from ['Covid Data deaths'] dea
join ['COVID Data vacc'] vacc
 on dea.date=vacc.date
 and dea.location=vacc.location
where dea.continent is not null
--WHERE dea.location like '%india%'
--order by 2,3
)
select*,(RollingPeopleVaccinated/population)*100
from PopvsVac


--Temp table:

DROP TABLE IF EXISTS #PercentagepopulationVaccinated
create table #PercentagepopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

INSERT into #PercentagepopulationVaccinated
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
,SUM(CAST(vacc.new_vaccinations as numeric)) OVER (Partition by dea.location order by dea.location,
dea.date) AS RollingPeopleVaccinated
from ['Covid Data deaths'] dea
join ['COVID Data vacc'] vacc
 on dea.date=vacc.date
 and dea.location=vacc.location
--where dea.continent is not null
--order by 2,3

select*,(RollingPeopleVaccinated/population)*100
from #PercentagepopulationVaccinated



---Creating View to store data for later visualisation: 
Create View PercentagepopulationVaccinated as
select dea.continent,dea.location,dea.date,dea.population,vacc.new_vaccinations
,SUM(CAST(vacc.new_vaccinations as numeric)) OVER (Partition by dea.location order by dea.location,
dea.date) AS RollingPeopleVaccinated
from ['Covid Data deaths'] dea
join ['COVID Data vacc'] vacc
 on dea.date=vacc.date
 and dea.location=vacc.location
where dea.continent is not null
--order by 2,3


SELECT *
from PercentagepopulationVaccinated










