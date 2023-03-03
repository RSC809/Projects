-- Exploratory Analysis

SELECT *
FROM PortfolioProject..CovidDeaths
ORDER BY 3,4

SELECT *
FROM PortfolioProject..CovidVaccinations
ORDER BY 3,4

-- Select Project Data for Exploratory Analysis
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs. Total Deaths. Filtered for Dominican Republic
SELECT location, date, total_cases, total_deaths,
(total_deaths/total_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%dominican%'
ORDER BY 1,2

--Looking at Total Cases vs Population. 
--Shows what percentage of population got COVID-19
SELECT location, date, total_cases, population,
(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
ORDER BY 1,2

--Looking at Total Cases vs Population. Filtered for Dominican Republic
--Shows what percentage of population got COVID-19
SELECT location, date, total_cases, population,
(total_cases/population)*100 AS InfectedPercentage
FROM PortfolioProject..CovidDeaths
WHERE location like '%dominican%'
ORDER BY 1,2

-- Looking at Countries with Highest Infection Rate Compared to Population
SELECT location, population,
MAX(total_cases) AS HighestInfectionCount,
MAX(total_cases/population)*100 AS PercentPopulationInfected
FROM PortfolioProject..CovidDeaths
GROUP BY location, population
ORDER BY PercentPopulationInfected DESC

-- Showing Countries with Highest Death Count per Population
SELECT location, 
MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Data Shows agregates World, High Income, Upper Middle Income etc
-- To filtered we add "WHERE continent IS NOT NULL"
SELECT location, 
MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing data by Continent
SELECT continent, 
MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--To return a more accurate data we return
--data by location where continent is NULL
SELECT location, 
MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

-- Showing the Continent with Highest Death Counts per Population
SELECT continent, 
MAX(cast(total_deaths AS INT)) AS TotalDeathCount
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

-- Global Numbers
-- We use SUM on new_cases to calculate Total_cases
-- We use SUM on new_deaths to calculate total_deaths
SELECT date, 
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_death,
    SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY date, SUM(new_cases)

--Showing Global Death Percentage 
SELECT
    SUM(new_cases) AS total_cases, 
    SUM(new_deaths) AS total_death,
    SUM(new_deaths)/SUM(new_cases)*100 AS DeathPercentage
FROM PortfolioProject..CovidDeaths
WHERE continent IS NOT NULL
ORDER BY 1, 2

--Covid Vaccination Data
SELECT *
FROM PortfolioProject..CovidVaccinations

--Joining the tables Deaths and Vaccinations
--We use alias "dea" for Covid Deaths and "vac" for Covid Vaccinations
--The purpose is make the query shorter
SELECT *
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date


--Using CTE to perform calculations
WITH PopvsVac (Continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated, PercentageVaccinated)
AS
(
--Looking at Total Population vs Vaccinations
--We filter to avoid continent null values
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated,
(SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date)/dea.population)*100 AS PercentageVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)
SELECT *
FROM PopvsVac;


--TEMP table alternative
DROP TABLE IF EXISTS #PercentPopulationVaccinated;
CREATE TABLE #PercentPopulationVaccinated
(
    Continent nvarchar(225),
    Location nvarchar(255),
    Date datetime,
    Population numeric,
    New_Vaccinations numeric,
    RollingPeopleVaccinated numeric,
    PercentageVaccinated AS (RollingPeopleVaccinated/population)*100
)

INSERT INTO #PercentPopulationVaccinated
--Looking at Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;

SELECT *
FROM #PercentPopulationVaccinated;

--Creating View to store date for later visualization

CREATE VIEW PercentPopulationVaccinatedView AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(vac.new_vaccinations) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) AS RollingPeopleVaccinated
FROM PortfolioProject..CovidDeaths AS dea
JOIN PortfolioProject..CovidVaccinations AS vac
    ON dea.location = vac.location
    AND dea.date = vac.date
WHERE dea.continent IS NOT NULL;
