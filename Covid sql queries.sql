SELECT *
FROM CovidPortfolioProject..CovidDeaths
ORDER BY 3,4;

--SELECT *
--FROM CovidPortfolioProject..CovidVaccinations
--ORDER BY 3,4;

-- Select Data to use

SELECT location, date, total_cases, new_cases, total_deaths, population
FROM CovidPortfolioProject..CovidDeaths
ORDER BY 1,2;

-- Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract Covid in your country

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS Death_Percentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at Total Cases vs Population
-- Shows what percentage of population has gotten Covid in country

SELECT location, date, population, total_cases, (total_cases/population)*100 AS Covid_Infection_Percentage
FROM CovidPortfolioProject..CovidDeaths
WHERE location like '%states%'
ORDER BY 1,2;

-- Looking at Countries with Highest Infection Rate cmpared to population

SELECT location, population, MAX(total_cases) AS Highest_Infection_Count, MAX((total_cases/population))*100 AS Covid_Infection_Percentage
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like '%states%'
GROUP BY location, population
ORDER BY Covid_Infection_Percentage DESC;

--Showing countries with highest death count 

SELECT location, MAX(cast(total_deaths as int)) AS Highest_Death_Count
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC;

-- Breaking things down by continent (Not totally accurate as it appears it's only taking numbers from certain countries...
-- Not all countries were associated with a continent

SELECT continent, MAX(cast(total_deaths as int)) AS Highest_Death_Count
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY continent
ORDER BY Highest_Death_Count DESC;

-- More accurate numbers than above

SELECT location, MAX(cast(total_deaths AS int)) AS Highest_Death_Count
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NULL
GROUP BY location
ORDER BY Highest_Death_Count DESC;

-- Global Numbers by Each Day

SELECT date, SUM(new_cases) AS Sum_New_Cases, SUM(CAST (new_deaths AS int)) AS Sum_New_Deaths, SUM(CAST (new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2;

-- Global Numbers Total

SELECT SUM(new_cases) AS TotalCases, SUM(CAST (new_deaths AS int)) AS TotalDeaths, SUM(CAST (new_deaths AS int))/SUM(new_cases)*100 AS Death_Percentage
FROM CovidPortfolioProject..CovidDeaths
-- WHERE location like '%states%'
WHERE continent IS NOT NULL
--GROUP BY date
ORDER BY 1,2;

-- Join the Two tables on location and date

SELECT *
FROM CovidPortfolioProject..CovidDeaths cd
JOIN CovidPortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date;

-- Looking at total population vs vaccinations

SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST (cv.new_vaccinations AS int)) OVER (Partition By cd.location Order By cd.location, 
  cd.date) AS Rolling_People_Vaccinated
, (Rolling_People_Vaccinated/population)*100
FROM CovidPortfolioProject..CovidDeaths cd
JOIN CovidPortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
ORDER by 2,3;

-- Use Common Table Expression

WITH POPvsVAC (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS 
(
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST (cv.new_vaccinations AS int)) OVER (Partition By cd.location Order By cd.location, 
  cd.date) AS Rolling_People_Vaccinated
-- , (Rolling_People_Vaccinated/population)*100
FROM CovidPortfolioProject..CovidDeaths cd
JOIN CovidPortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL
)
SELECT *, (Rolling_People_Vaccinated/population)*100
FROM POPvsVAC
ORDER BY date DESC;

-- Temp Table

DROP Table If Exists #PercentPopulationVaccinated

CREATE TABLE #PercentPopulationVaccinated
(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST (cv.new_vaccinations AS int)) OVER (Partition By cd.location Order By cd.location, 
  cd.date) AS Rolling_People_Vaccinated
-- , (Rolling_People_Vaccinated/population)*100
FROM CovidPortfolioProject..CovidDeaths cd
JOIN CovidPortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM #PercentPopulationVaccinated

-- Creating View to store data for later visualization

CREATE VIEW PercentPopulationVaccinated AS
SELECT cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CAST (cv.new_vaccinations AS int)) OVER (Partition By cd.location Order By cd.location, 
  cd.date) AS Rolling_People_Vaccinated
-- , (Rolling_People_Vaccinated/population)*100
FROM CovidPortfolioProject..CovidDeaths cd
JOIN CovidPortfolioProject..CovidVaccinations cv
	ON cd.location = cv.location
	AND cd.date = cv.date
WHERE cd.continent IS NOT NULL

SELECT *
FROM PercentPopulationVaccinated;
