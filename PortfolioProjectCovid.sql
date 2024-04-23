--Selecting the data we are going to be using

SELECT *
FROM PortfolioProject2..CovidDeaths
WHERE continent is NOT NULL
ORDER BY 3,4

SELECT Location, Date, Total_Cases, Total_Deaths
FROM PortfolioProject2..CovidDeaths
WHERE Continent IS NOT NULL
ORDER BY 1,2

-- Looking at total cases vs total deaths
-- Likelihood of dying if you contract covid at your country
SELECT Location, Date, Total_Cases, Total_Deaths, (CONVERT(float, total_deaths) / NULLIF(CONVERT(float, total_cases),0))* 100 AS DeathPercentage
FROM PortfolioProject2..CovidDeaths
WHERE Location LIKE '%States%' AND continent is not null
ORDER BY 1,2


-- Looking at total cases vs population

SELECT Location, Date, Total_Cases, (total_cases / population)* 100 AS PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths
WHERE Location LIKE '%States%' AND Continent is NOT NULL
ORDER BY 1,2


-- Looking at countries with highest infection rate compared to population
SELECT Location, Population, MAX(Total_Cases) as HighestInfectionCount, ((NULLIF(CONVERT(float, MAX(total_cases)),0)) / population)*100 AS PercentPopulationInfected
FROM PortfolioProject2..CovidDeaths
--WHERE Location LIKE '%States%'
WHERE Continent IS NOT NULL
GROUP BY Location, Population
ORDER BY PercentPopulationInfected DESC

-- Looking at countries with highest death count compared to population

SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
--WHERE Location LIKE '%States%'
WHERE Continent IS NOT NULL
GROUP BY Location
ORDER BY TotalDeathCount DESC

-- LET'S BREAK DOWN THINGS BY CONTINENT
-- Showing the continents with the highest death count per population
SELECT Continent, MAX(CAST(total_deaths as int)) as TotalDeathCount
FROM PortfolioProject2..CovidDeaths
--WHERE Location LIKE '%States%'
WHERE Continent IS NOT NULL
GROUP BY Continent
ORDER BY TotalDeathCount DESC

--SELECT Location, MAX(CAST(total_deaths as int)) as TotalDeathCount FROM PortfolioProject2..CovidDeaths WHERE Location LIKE '%States%' WHERE Continent IS NULL GROUP BY Location ORDER BY TotalDeathCount DESC

-- GLOBAL NUMBERS

SELECT date, sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(SUM(cast(new_deaths as int)) 
/ SUM(new_cases)) * 100 AS DeathPercentage--SELECT Date, SUM(CAST(new_cases as bigint)), SUM(CAST(new_deaths as BIGINT)) 
FROM PortfolioProject2..CovidDeaths
--WHERE Location LIKE '%States%' 
WHERE continent is not null--WHERE new_cases
GROUP BY date
HAVING sum(new_cases)!= 0
ORDER BY 1,2

-- ALL TOGETHER

SELECT sum(new_cases) as total_cases, sum(cast(new_deaths as int)) as total_deaths, 
(SUM(cast(new_deaths as int)) 
/ SUM(new_cases)) * 100 AS DeathPercentage--SELECT Date, SUM(CAST(new_cases as bigint)), SUM(CAST(new_deaths as BIGINT)) 
FROM PortfolioProject2..CovidDeaths
--WHERE Location LIKE '%States%' 
WHERE continent is not null--WHERE new_cases
--GROUP BY date
HAVING sum(new_cases)!= 0
ORDER BY 1,2

-- Looking at total population vs vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is NOT NULL
order by 2,3


-- USE CTE

WITH PopvsVac (Continent, Location, Date, Population,New_Vaccinations, RollingPeopleVaccinated)
as
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is NOT NULL
--order by 2,3
)
Select *, (RollingPeopleVaccinated/Population)*100
FROM PopvsVac

-- TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)


Insert into #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is NOT NULL
--order by 2,3

SELECT *, (RollingPeopleVaccinated/Population)*100
FROM #PercentPopulationVaccinated

--  CREATING VIEWS TO STORE DATA FOR LATER VISUALS


CREATE VIEW PercentPopulationVaccinated as
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(Cast(vac.new_vaccinations as bigint)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) as RollingPeopleVaccinated
FROM PortfolioProject2..CovidDeaths dea
JOIN PortfolioProject2..CovidVaccinations vac
	ON dea.location = vac.location
	and dea.date = vac.date 
WHERE dea.continent is NOT NULL
--order by 2,3

Select *
FROM PercentPopulationVaccinated