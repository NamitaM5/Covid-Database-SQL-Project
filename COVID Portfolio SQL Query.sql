

SELECT *
FROM CovidVaccinations

--Select Data that are going to be using

SELECT location, date, total_cases,new_cases,total_deaths,population
FROM CovidDeaths
where continent is not NULL
order by 1,2

-- Total cases VS Total Deaths

ALTER TABLE CovidDeaths ALTER column total_cases int;
ALTER TABLE CovidDeaths ALTER column total_deaths int;
ALTER TABLE CovidDeaths ALTER column date date;

SELECT location, date, total_cases ,total_deaths ,(total_deaths*1.0/total_cases)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states' and continent is not NULL
order by 1,2

-- Infer: Shows the likelihood of dying if you contract Covid in your country

--Total cases VS Population

SELECT location, date, total_cases ,population ,(total_cases*1.0/population)*100 as DeathPercentage
FROM CovidDeaths
WHERE location like '%states' and continent is not NULL
order by 1,2

--Infer : Shows what percentage of population got Covid

-- Looking at countries with highest infection rate compared to population

SELECT location ,population, max(total_cases) as HighestInfectionCount,(max(total_cases)*1.0/population)*100 as PercentagePopulationInfected
FROM CovidDeaths
--WHERE location like '%states'
where continent is not NULL
GROUP by location, population 
order by PercentagePopulationInfected DESC

-- Showing countries with highest death count per population

SELECT location , max(total_deaths) as TotalDeathCount
FROM CovidDeaths
--WHERE location like '%states'
where continent is not NULL
GROUP by location
order by TotalDeathCount DESC

-- Lets break things down by continent
-- Showing the Continents with the highest Death count

SELECT continent , max(total_deaths) as TotalDeathCount
FROM CovidDeaths
where continent is not NULL
GROUP by continent
order by TotalDeathCount DESC

SELECT location , max(total_deaths) as TotalDeathCount
FROM CovidDeaths
where continent is NULL
GROUP by location
order by TotalDeathCount DESC

-- Global NUMBERS

SELECT date, sum(cast(new_cases as int)) as total_cases , sum(cast(new_deaths as int)) as total_deaths, (sum(cast(new_deaths as int))*1.0/sum(cast(new_cases as int)))*100 as DeathPercentage
FROM CovidDeaths
--WHERE location like '%states'
WHERE continent is not NULL
group BY [date]
ORDER by 1,2

-- Total population VS vaccinations

-- USE CTE

with PopVSVac (continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.[location] = vac.[location] and dea.date = vac.date
WHERE dea.continent is not null)
--ORDER by 2, 3)

SELECT *, (RollingPeopleVaccinated*1.0/population)*100
from PopVSVac

-- USE TEMP

drop table if EXISTS #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
    continent nvarchar(255),
    location nvarchar(255),
    Date datetime,
    population numeric,
    new_vaccinations numeric,
    RollingPeopleVaccinated numeric
    )

Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.[location] = vac.[location] and dea.date = vac.date
--WHERE dea.continent is not null
--ORDER by 2, 3

SELECT *, (RollingPeopleVaccinated*1.0/population)*100
from #PercentPopulationVaccinated

-- View : Store date for vizualization

Create View PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
sum(CONVERT(int, vac.new_vaccinations)) OVER(Partition by dea.location order by dea.location,dea.date) as RollingPeopleVaccinated
FROM CovidDeaths dea JOIN CovidVaccinations vac
ON dea.[location] = vac.[location] and dea.date = vac.date
WHERE dea.continent is not null
--ORDER by 2, 3

SELECT *
from PercentPopulationVaccinated 