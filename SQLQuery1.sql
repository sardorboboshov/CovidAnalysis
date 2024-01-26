SELECT * FROM PortfolioProject..CovidDeaths
order by 3,4

SELECT * FROM PortfolioProject..CovidVaccinations
order by 3,4

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;


-- Select Data that we are going to be using
Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths
order by 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract covid in your country

Select Location, date, total_cases, total_deaths, 
ROUND((total_deaths/total_cases)*100, 3) as DeathPercentage
from PortfolioProject..CovidDeaths
WHERE location = 'Uzbekistan'
order by 1,2;


-- Looking at Total Cases vs Population
-- Shows what percentage of population got Covid 

Select Location, date, Population, total_cases, total_deaths, 
ROUND((total_cases/population)*100, 3) as PercentPopulationInfected
from PortfolioProject..CovidDeaths
WHERE location = 'Uzbekistan'
order by 1,2;

-- Looking at Countries with Highest Infection Rate compared to Population

Select 
	Location, Population, 
	MAX(total_cases) as HighestInfectionCount, 
	MAX((total_cases/population)) * 100 as PercentPopulationInfected
from PortfolioProject..CovidDeaths
-- WHERE location = 'Uzbekistan'
GROUP BY Location, Population
order by PercentPopulationInfected DESC;


-- Showing Countries with Highest Death Count per Population
Select 
	Location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is not null
GROUP BY Location
order by TotalDeathCount DESC;


-- LET'S BREAK THINGS DOWN BY CONTINENT
-- Showing continents with the highest death count per population
Select 
	location, MAX(CAST(Total_deaths as int)) as TotalDeathCount
from PortfolioProject..CovidDeaths
where continent is null
GROUP BY location
order by TotalDeathCount DESC;

-- Global Numbers

SELECT 
	SUM(new_cases) as total_cases,
	SUM(CAST(new_deaths as int)) as total_deaths,
	SUM(CAST(new_deaths as int)) / SUM(new_cases) * 100 as DeathPercentage
FROM PortfolioProject..CovidDeaths
where continent is not null
--GROUP BY date
order by 1,2


-- Lookintg at Total Population vs Vaccinations

SELECT 
	dea.continent, dea.location, dea.date, dea.population, 
	vac.new_vaccinations,
	SUM(CAST(vac.new_vaccinations AS int)) OVER 
		(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
--	(RollingPeopleVaccinated / population) * 100
from PortfolioProject..CovidDeaths as dea
join PortfolioProject..CovidVaccinations as vac
on	
	dea.location = vac.location and
	dea.date = vac.date
where dea.continent is not null
order by 2, 3
--order by dea.location, dea.date

-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population, NewVaccinations, RollingPeopleVaccinated)
as (
	SELECT 
		dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS int)) OVER 
			(PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
	--	(RollingPeopleVaccinated / population) * 100
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccinations as vac
	on	
		dea.location = vac.location and
		dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3
)

SELECT *, (RollingPeopleVaccinated / Population) * 100 
from PopvsVac;



-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE  #PercentPopulationVaccinated 
(
	Continent nvarchar(255),
	Location nvarchar(255),
	Date datetime,
	Population numeric,
	New_vaccinations numeric,
	RollingPeopleVaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
	SELECT 
		dea.continent, dea.location, dea.date, dea.population, 
		COALESCE(vac.new_vaccinations, 0),
		COALESCE(SUM(CAST(vac.new_vaccinations AS int)) OVER 
			(PARTITION BY dea.location ORDER BY dea.location, dea.date), 0) 
			AS RollingPeopleVaccinated
	--	(RollingPeopleVaccinated / population) * 100
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccinations as vac
	on	
		dea.location = vac.location and
		dea.date = vac.date
	where dea.continent is not null
	--order by 2, 3

SELECT *, ROUND((RollingPeopleVaccinated/Population)*100, 3)  as RollingPeopleVaccinatedPercentage
from #PercentPopulationVaccinated;



-- Creating View to store data for later visualizations

CREATE VIEW PercentPopulationVaccinated as
	SELECT 
		dea.continent, dea.location, dea.date, dea.population, 
		vac.new_vaccinations,
		SUM(CAST(vac.new_vaccinations AS int)) OVER 
			(PARTITION BY dea.location ORDER BY dea.location, dea.date) 
			AS RollingPeopleVaccinated
	--	(RollingPeopleVaccinated / population) * 100
	from PortfolioProject..CovidDeaths as dea
	join PortfolioProject..CovidVaccinations as vac
	on	
		dea.location = vac.location and
		dea.date = vac.date
	where dea.continent is not null
	-- order by 2, 3


select * from PercentPopulationVaccinated;