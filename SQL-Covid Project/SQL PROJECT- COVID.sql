SELECT *
FROM CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM CovidVaccination
--ORDER BY 3,4;

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidDeaths
ORDER BY 1,2

--TOTAL CASES VS TOTAL DEATHS

SELECT location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 AS DeathPercentage 
FROM CovidDeaths
WHERE location LIKE '%India%'
ORDER BY 1,2

--Total Cases vs Population

SELECT location, date, total_cases, population, (total_cases/population)*100 As InfectionRate
FROM CovidDeaths
--WHERE location LIKE '%India%'
ORDER BY 1,2

--In India

SELECT location, date, total_cases, population, FORMAT(InfectionRate,'F4') AS InfectionRate
FROM
(SELECT location, date, total_cases, population, (total_cases/population)*100 AS InfectionRate
FROM CovidDeaths
WHERE location LIKE '%India%') x
Order by x.date

--Countries with the highest infection Rate as compared to population

SELECT location,population, MAX(total_cases) AS HighestInfectionCount, MAX((total_cases/population)*100) As PercentPopulationInfected
FROM CovidDeaths
GROUP BY location,population
ORDER BY PercentPopulationInfected DESC

--Countries with the Highest Death Counts per Population

SELECT location,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY TotalDeathCount DESC

--BY CONTINENTS

SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Continents with the highest death count per population

SELECT continent,MAX(CAST(total_deaths AS int)) AS TotalDeathCount
FROM CovidDeaths
WHERE continent IS not NULL
GROUP BY continent
ORDER BY TotalDeathCount DESC

--Global Numbers

SELECT date, SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage

from CovidDeaths
where continent is not null
GROUP BY date
order by 1,2

-- For Flash Data
SELECT SUM(new_cases) as Total_Cases, SUM(cast(new_deaths as int)) AS Total_Deaths, SUM(cast(new_deaths as int))/SUM(new_cases) *100 as DeathPercentage

from CovidDeaths
where continent is not null
--GROUP BY date
order by 1,2

--Covid Vaccinations Data

SELECT * 

FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location AND
dea.date = vac.date


--Total Population Vs Vaccination

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations

FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

--Rolling Sum of New Vaccinations

SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
As RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
ORDER BY 2,3

-- 

With PopvsVac
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
As RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3
)

SELECT *, (RollingPeopleVaccinated/population)*100
FROM PopvsVac

--TEMP TABLE
DROP TABLE IF EXISTS #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(continent NVARCHAR(255),
location NVARCHAR(255),
date datetime,
population numeric,
new_vaccinations nvarchar(255),
RollingPeopleVaccinated numeric)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations,
SUM(CONVERT(bigint, vac.new_vaccinations)) OVER(PARTITION BY dea.location ORDER BY dea.location, dea.date)
As RollingPeopleVaccinated
FROM CovidDeaths dea
JOIN CovidVaccination vac
ON dea.location = vac.location AND
dea.date = vac.date
WHERE dea.continent IS NOT NULL
--ORDER BY 2,3















