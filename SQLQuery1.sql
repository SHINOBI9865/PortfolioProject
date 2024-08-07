
--Select data that we are going to be use
SELECT location,date,total_cases,new_cases,total_deaths,population
FROM portfolio.dbo.CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Total Deaths
--Shows likelihood of drying if you contract covid in your county
SELECT location,date,total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM portfolio.dbo.CovidDeaths
WHERE location LIKE '%states%'
ORDER BY 1,2

--Loocking at Total Cases vs Population
SELECT location,date,population,total_cases,(total_cases/population)*100 as PercentPopulationInfected
FROM portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
ORDER BY 1,2

--Looking at contries wuth Highest Infection Rate Compared to population
SELECT location,population,MAX(total_cases) AS HighestInfectionCount,MAX((total_cases/population))*100 as PercentPopulationInfected
FROM portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
GROUP BY location,population
ORDER BY PercentPopulationInfected DEsc



SELECT location,MAX(cast(total_deaths as int)) as TotalDeahCount
FROM portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY TotalDeahCount Desc

--Showing contintents with the highest death count per population
SELECT continent,MAX(cast(total_deaths as int)) as TotalDeahCount
FROM portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY TotalDeahCount Desc


--GLOBAL NUMBERS
SELECT SUM(new_cases)as total_cases,SUM(cast(new_deaths as int))as total_deaths,SUM(cast(new_deaths as int))/SUM(new_cases) *100 as Deathpercentage--total_cases,total_deaths,(total_deaths/total_cases)*100 as Deathpercentage
FROM portfolio.dbo.CovidDeaths
--WHERE location LIKE '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1,2

--Looking at Total population vs Vaccination

SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolio.dbo.CovidDeaths dea
JOIN portfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2,3

--USE CTE

with popvsvac(continent,location,date,population,new_vaccinations,RollingPeopleVaccinated)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolio.dbo.CovidDeaths dea
JOIN portfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3
)
SELECT *,(RollingPeopleVaccinated/population)*100
FROM popvsvac

--TEMP TABLE
DROP Table if exists #PercentPopulationVaccineted
CREATE Table #PercentPopulationVaccineted
(
continent nvarchar(255),
location nvarchar(255),
DATE datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccineted
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolio.dbo.CovidDeaths dea
JOIN portfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *,(RollingPeopleVaccinated/population)*100
FROM #PercentPopulationVaccineted

--Creat view to store data for later vizualization
Create View PercentPopulationVaccineted as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
,SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location Order by dea.location,dea.date) as RollingPeopleVaccinated
FROM portfolio.dbo.CovidDeaths dea
JOIN portfolio.dbo.CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2,3

SELECT *
FROM PercentPopulationVaccineted