--Data source: https://ourworldindata.org/covid-deaths
--Dataset was separated into 2 datasets: CovidDeaths and CovidVaccinations

-- See CovidDeaths dataset for United States
--SELECT *
--FROM Portfolio..CovidDeaths
--WHERE location like '%states'
--ORDER BY date DESC

SELECT date, location, new_cases, new_deaths
FROM Portfolio..CovidDeaths
WHERE continent <> ''
ORDER BY date DESC

-- New cases in selected countries
SELECT date, location, new_cases_smoothed
FROM Portfolio..CovidDeaths
WHERE continent <> ''
AND location IN ('United States', 'United Kingdom', 'French', 'Germany', 'Australia', 'Singapore', 'India', 'Indonesia')
ORDER BY date DESC

-- New cases and new deaths percentages
SELECT location, date, new_cases, new_deaths, population
, new_cases/NULLIF(population,0)*100 AS new_cases_vs_pop
, new_deaths/NULLIF(population,0)*100 AS new_deaths_vs_pop
, (new_deaths/NULLIF(new_cases,0))*100 AS new_deaths_per_new_cases
FROM Portfolio..CovidDeaths
WHERE continent <> ''
ORDER BY 2 DESC

-- CONTINENTS with highest total deaths
SELECT location, MAX(total_deaths) as num_deaths
FROM Portfolio..CovidDeaths
WHERE continent = ''
AND location NOT LIKE '%income%'
AND location NOT LIKE 'World'
GROUP BY location
ORDER BY num_deaths DESC

-- Hospitalization/ICU Rate
SELECT location, population, date, new_cases, icu_patients, hosp_patients
, (icu_patients/NULLIF(new_cases,0))*100 AS icu_per_new_cases
, (hosp_patients/NULLIF(new_cases,0))*100 AS hosp_per_new_cases
FROM Portfolio..CovidDeaths
WHERE continent <> ''
ORDER BY 3 DESC, 4 DESC

SELECT dea.date, dea.location
, MAX(dea.total_cases) AS total_cases
, MAX(vac.people_vaccinated)/NULLIF(dea.population,0)*100 AS percent_vaccinated
, MAX(vac.stringency_index) AS stringency_index
FROM Portfolio..CovidDeaths dea
JOIN Portfolio..CovidVaccinations vac
	ON dea.location = vac.location
	AND	dea.date = vac.date
WHERE dea.continent <> ''
GROUP BY dea.date, dea.location, dea.population
ORDER BY 1 DESC, 2

