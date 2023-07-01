SELECT * FROM covid_death
WHERE continent is NOT NULL;

SELECT location, date, total_cases, total_deaths, population
FROM covid_death
ORDER BY 1,2;

--  likely of dying when infected by infection 
SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_death
WHERE location like '%States%'
ORDER BY 1,2;

SELECT location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 AS death_percentage
FROM covid_death
WHERE location = 'India'
ORDER BY 1,2;

-- total cases and population 

SELECT location, date, total_cases, total_deaths, population ,(total_cases/population)*100 AS cases_per_population
FROM covid_death
ORDER BY 6;

-- cases by population in US  

SELECT location, date, total_cases, total_deaths, population ,(total_cases/population)*100 AS percent_pop_infected
FROM covid_death
WHERE location like '%States%'
ORDER BY 2;

-- Looking at countries with highest infection rates compared to population
SELECT location, MAX(total_cases), population ,MAX((total_cases/population))*100 AS percent_pop_infected
FROM covid_death
GROUP BY location, population
ORDER BY percent_pop_infected DESC;

-- Showing countries with highest death count 
SELECT location, MAX(CAST(total_deaths AS int)) AS max_deaths
FROM covid_death
WHERE continent is NOT NULL
GROUP BY location
ORDER BY max_deaths desc;

-- Let's break by continent

SELECT continent, MAX(total_deaths) FROM covid_death
WHERE total_deaths is NOT NULL and continent is NOT NULL
GROUP BY continent
ORDER BY 2 desc;

-- above numbers are not correct as they do not include canada in north america 

-- 
SELECT location, MAX(total_deaths) AS total_death_count
FROM covid_death
WHERE continent is NULL and location != 'International' and location != 'World'
GROUP BY location
ORDER BY 2 desc;

-- Global numbers of cases according to groups 

-- Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
-- From PortfolioProject..CovidDeaths
-- --Where location like '%states%'
-- where continent is not null 
-- --Group By date
-- order by 1,2

SELECT date, SUM(new_cases) as total_cases, SUM(new_deaths) as total_deaths, SUM(new_deaths)/ SUM(new_cases) * 100 as death_percentage
FROM covid_death
WHERE continent is not NULL
GROUP BY date
ORDER BY date;

--  Vaccinations
SELECT * FROM covid_vac LIMIT 1000;

--  total population vs vaccination 
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
FROM covid_death as dea
JOIN covid_vac as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null;

-- use CTE 

WITH popvsvac (location, date, population, new_vaccinations, rolling_people_vac)
as 
(
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
FROM covid_death as dea
JOIN covid_vac as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null	
)
SELECT *, (rolling_people_vac/population)*100  
FROM popvsvac;

-- Create temporary tables 

DROP TABLE IF exists pop_percent_vac;
CREATE TEMP TABLE pop_percent_vac AS 
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
FROM covid_death as dea
JOIN covid_vac as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null;

SELECT * FROM pop_percent_vac;

-- Create View 

CREATE VIEW pop_percent_vac AS 
SELECT dea.location, dea.date, dea.population, vac.new_vaccinations, 
SUM(vac.new_vaccinations) OVER (PARTITION by dea.location ORDER BY dea.location, dea.date) AS rolling_people_vac
FROM covid_death as dea
JOIN covid_vac as vac
ON dea.location = vac.location
and dea.date = vac.date
WHERE dea.continent is not null;





