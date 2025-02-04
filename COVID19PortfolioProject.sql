SELECT *
FROM TestdB..CovidDeaths$
WHERE continent is not null
ORDER BY 3, 4

--SELECT *
--FROM TestdB..CovidVaccinations
--ORDER BY 3, 4


--Select the data we will be using
SELECT location, date, total_cases, new_cases, total_deaths, population
FROM TestdB..CovidDeaths$
WHERE continent is not null
ORDER BY 1, 2


--Total Cases, Total Deaths, and Death Percentage in the United States
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM TestdB..CovidDeaths$
WHERE location like '%states%'
and continent is not null
ORDER BY 1, 2


--Total Cases vs Population 
--COVID-19 contraction rate
SELECT location, date, population, total_cases, (total_cases/population)*100 AS percent_population_infected
FROM TestdB..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
ORDER BY 1, 2


--Countries with the Highest Infection Rate Compared to Population
SELECT location, population, MAX(total_cases) AS highest_infection_count, MAX((total_cases/population))*100 AS percent_population_infected
FROM TestdB..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location, population
ORDER BY percent_population_infected DESC


--Showing Countries with Highest Death Count per Population
SELECT location, MAX(cast(total_deaths as float)) AS total_death_count
FROM TestdB..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY location
ORDER BY total_death_count DESC


--Showing Continents with Highest Death Count per Population
SELECT continent, MAX(cast(total_deaths as float)) AS total_death_count
FROM TestdB..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
GROUP BY continent
ORDER BY total_death_count DESC



--Global Cases, Deaths, and Death Percentgae
SELECT SUM(new_cases) AS total_cases, SUM(cast(new_deaths as float)) AS total_deaths, SUM(cast(new_deaths as float))/SUM(new_cases)*100 AS death_percentage
FROM TestdB..CovidDeaths$
--WHERE location like '%states%'
WHERE continent is not null
--GROUP BY date
ORDER BY 1, 2



--Total Population vs Vaccinations
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS Rolling_People_Vaccinated
--, (Rolling_Person_Vaccinated/population)*100

FROM TestdB..CovidDeaths$ dea
JOIN TestdB..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
ORDER BY 2, 3



--Rolling Number of Vaccinations Using CTE
WITH PopVsVac (continent, location, date, population, new_vaccinations, Rolling_People_Vaccinated)
AS
(
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS Rolling_People_Vaccinated
--, (Rolling_Person_Vaccinated/population)*100
FROM TestdB..CovidDeaths$ dea
JOIN TestdB..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
)

SELECT *, (Rolling_People_Vaccinated/population)*100
FROM PopVsVac



--Temp Table
DROP TABLE if exists #PercentPopulationVaccinated
CREATE TABLE #PercentPopulationVaccinated
(
Continent nvarchar(255),
location nvarchar(255),
Date datetime,
Population numeric,
new_vaccinations numeric,
Rolling_People_Vaccinated numeric
)

INSERT INTO #PercentPopulationVaccinated
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS Rolling_People_Vaccinated
--, (Rolling_Person_Vaccinated/population)*100
FROM TestdB..CovidDeaths$ dea
JOIN TestdB..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3
 
 SELECT *, (Rolling_People_Vaccinated/population)*100
FROM #PercentPopulationVaccinated





--Creating a View to store data for late visualizations

CREATE VIEW PercentPopulationVaccinated AS
SELECT dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations 
, SUM(CONVERT(float, vac.new_vaccinations)) OVER (PARTITION BY dea.location ORDER BY dea.location, dea.date) 
AS Rolling_People_Vaccinated
--, (Rolling_Person_Vaccinated/population)*100
FROM TestdB..CovidDeaths$ dea
JOIN TestdB..CovidVaccinations$ vac
	ON dea.location = vac.location
	and dea.date = vac.date
WHERE dea.continent is not null
--ORDER BY 2, 3

SELECT * 
FROM PercentPopulationVaccinated