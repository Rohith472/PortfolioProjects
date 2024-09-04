SELECT * 
FROM PortfolioProject1Covid..CovidDeaths
where continent is not null
ORDER BY 3,4

--SELECT * 
--FROM PortfolioProject1Covid..CovidVaccinations
--ORDER BY 3,4

SELECT location,date,total_cases,new_cases,total_deaths,population
FROM PortfolioProject1Covid..CovidDeaths
order by 1,2

--Looking at Total Cases vs Total Deaths
--Shows the likelihood of dying if you contract covid in your country
SELECT location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
FROM PortfolioProject1Covid..CovidDeaths
where location like 'India'
order by 1,2

--Looking at the Total Cases vs Population
--Shows what percentage of population got Covid
SELECT location,date,population,total_cases,(total_cases/population)*100 as CovidPercentage
FROM PortfolioProject1Covid..CovidDeaths
--where location like '%states%'
order by 1,2

--Looking at Countries with highest Infection rate compared to Population

SELECT location,population,MAX(total_cases) as HighestInfectionCount,MAX((total_cases/population))*100 as PopulationInfected
FROM PortfolioProject1Covid..CovidDeaths
Group by location,population
--where location like '%states%'
order by 4 desc

--Showing Countries with Highest Death Count per Population

SELECT location, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1Covid..CovidDeaths
where continent is not null
Group by location
--where location like '%states%'
order by TotalDeathCount desc

-- LET'S BREAK THINGS DOWN BY CONTINENT

--Showing Continents with Highest Death Counts per Population

SELECT continent, MAX(cast(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject1Covid..CovidDeaths
where continent is not null
Group by continent
--where location like '%states%'
order by TotalDeathCount desc

--GLOBAL NUMBERS

SELECT SUM(new_cases) as Total_Cases, SUM(CAST(new_deaths as int)) as Total_Deaths, SUM(CAST(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
FROM PortfolioProject1Covid..CovidDeaths
--where location like 'India'
where continent is not null
--group by date
order by 1,2


-- Looking at Total Population vs Vaccinations
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCount
-- (RollingCount/popuation)*100
FROM PortfolioProject1Covid..CovidDeaths dea
Join  PortfolioProject1Covid..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
order by 2,3

-- USE CTE
With PopvsVac (continent,location,date,population,new_vaccinations,RollingCount)
as
(
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCount
-- (RollingCount/popuation)*100
FROM PortfolioProject1Covid..CovidDeaths dea
Join  PortfolioProject1Covid..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3
)
SELECT *, (RollingCount/population)*100
FROM PopvsVac

--TEMP TABLE

Drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_Vaccinations numeric,
RollingCount numeric
)

insert into #PercentPopulationVaccinated
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCount
-- (RollingCount/popuation)*100
FROM PortfolioProject1Covid..CovidDeaths dea
Join  PortfolioProject1Covid..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
--where dea.continent is not null
--order by 2,3
SELECT *, (RollingCount/population)*100
FROM #PercentPopulationVaccinated

-- Creating View for storing data for visualizatios

Create View PercentPopulationVaccinated as
SELECT dea.continent,dea.location,dea.date,dea.population,vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location, dea.date) as RollingCount
-- (RollingCount/popuation)*100
FROM PortfolioProject1Covid..CovidDeaths dea
Join  PortfolioProject1Covid..CovidVaccinations vac
on dea.location=vac.location
and dea.date=vac.date
where dea.continent is not null
--order by 2,3


Select *
from PercentPopulationVaccinated










