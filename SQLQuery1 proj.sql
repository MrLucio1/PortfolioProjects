Select *
From PortfolioProject..CovidDeaths
Order By 3,4

--Select *
--From PortfolioProject..CovidVacs
--Order By 3,4

--Select Needed Data to be Used
Select Location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
Where continent is not null
Order By 1,2

--Compare Total Cases vs Total Deaths
--Percentage of people who die or get infected
--Likelihood of Dying if you Contract Covid in your Country

Select Location, date, total_cases, total_deaths, (TRY_CAST(total_deaths AS NUMERIC(10, 2))/ NULLIF(TRY_CAST(total_cases AS NUMERIC(10, 2)), 0))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'  --for Precise location
Where continent is not null
Order By 1,2


--Looking at Total Case Vs Population
--Percentage of population that Contracted Covid
Select Location, date, population, total_cases, (TRY_CAST(total_cases AS NUMERIC(10, 2))/ NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0))*100 AS InfectedPercentage
From PortfolioProject..CovidDeaths
WHERE location like '%Nigeria%'  --for Precise location
Where continent is not null
Order By 1,2

--Counties with highest Infection rate per Population

Select Location, population, MAX(total_cases) AS HighestInfectionCount, MAX((TRY_CAST(total_cases AS NUMERIC(10, 2))/ NULLIF(TRY_CAST(population AS NUMERIC(10, 2)), 0)))*100 AS InfectedPercentage
From PortfolioProject..CovidDeaths
Where continent is not null
--WHERE location like '%Nigeria%'  --for Precise location
Group By population, location
Order By InfectedPercentage Desc

--Highest Death Count Per Population

Select Location, MAX(total_deaths) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
Where continent is not null
Group By location
Order By TotalDeathCount Desc

--BREAKING THINGS BY CONTINENT

Select continent, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%China%'
Where continent is not null
Group By continent
Order By TotalDeathCount Desc

--continent with the Highest Death Count per Population

Select location, MAX(cast(total_deaths as int)) AS TotalDeathCount
From PortfolioProject..CovidDeaths
--WHERE location like '%China%'
Where continent is null
Group By location
Order By TotalDeathCount Desc



-- GLOBAL NUMBERS

--sum of new cases each date
Select date, SUM(new_cases) --total_cases, total_deaths, (TRY_CAST(total_deaths AS NUMERIC(10, 2))/ NULLIF(TRY_CAST(total_cases AS NUMERIC(10, 2)), 0))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
WHERE continent is not null
Group By date
Order By 1,2

-- sum of new death
Select date, SUM(new_cases), SUM(cast(new_deaths as int))
From PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
WHERE continent is not null
Group By date
Order By 1,2

or

Select date, SUM(new_cases), SUM(new_deaths)
From PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
WHERE continent is not null
Group By date
Order By 1,2

--GLOBALLY

Select date, SUM(new_cases), SUM(new_deaths), SUM(new_deaths)/SUM(new_cases)*100
From PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
WHERE continent is not null
Group By date
Order By 1,2

SELECT date, SUM(new_cases) As TotalCases, SUM(new_deaths) As TotalDeath, 
    CASE WHEN SUM(new_cases) = 0 THEN NULL
         ELSE (SUM(new_deaths) * 100.0) / NULLIF(SUM(new_cases), 0)
    END AS death_rate
FROM PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
WHERE continent IS NOT NULL
GROUP BY date
ORDER BY 1,2


Select date, SUM(new_cases), SUM(cast(new_deaths as int)), (SUM(cast(new_deaths as int))/NULLIF(SUM(new_cases), 0)*100 DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
WHERE continent is not null
Group By date
Order By 1,2

Select date, SUM(new_cases), SUM(new_deaths)
,(TRY_CAST(new_deaths AS NUMERIC(3, 2))/ NULLIF(TRY_CAST(new_cases AS NUMERIC(3, 2)), 0))*100 AS DeathPercentage
From PortfolioProject..CovidDeaths
--WHERE location like '%Nigeria%'  --for Precise location
Where continent is not null
Group By date
Order By 1,2

--Total population Vs Vaccinations

Select *
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVacs Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date

Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVacs Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date
Where dea.continent is not null
Order By 2,3



--USING CTE

WITH PopvsVac (continent, Location, Date, Population, new_vaccinations, RollingPeopleVaccinated)
as
(
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By dea.location Order By dea.location, dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVacs Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date
Where dea.continent is not null
--Order By 2,3
)
Select *, (RollingPeopleVaccinated)*100
From PopvsVac


--TEMP TABLE

DROP TABLE if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
Continent nvarchar(255),
Location nvarchar(255),
Date datetime,
Population numeric,
New_vaccinations numeric,
RollingPeopleVaccinated numeric
)

Insert into #PercentPopulationVaccinated
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By Dea.location Order By Dea.location, Dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVacs Vac
	ON Dea.location = Vac.location
	and Dea.date = Vac.date
--Where dea.continent is not null
--Order By 2,3

Select *, (RollingPeopleVaccinated)*100
From #PercentPopulationVaccinated




--Creating views to store data for later visualization

Create View PercentPopulationVaccinated as
Select Dea.continent, Dea.location, Dea.date, Dea.population, vac.new_vaccinations
, SUM(CONVERT(int, vac.new_vaccinations)) OVER (Partition By Dea.location Order By Dea.location, Dea.date) AS RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths Dea
Join PortfolioProject..CovidVacs Vac
	ON Dea.location = vac.location
	and Dea.date = vac.date
Where dea.continent is not null
--Order By 2,3

select *
From PercentPopulationVaccinated