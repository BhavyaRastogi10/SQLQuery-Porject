select *
from PortfolioProject..CovidDeaths
where continent is not null

--Looking for Total Cases vs Total Deaths
-- showes the likelihood of dying if you had covid in your country
Select Location, date, total_Cases, total_deaths, (total_deaths/total_cases)*100 Death_Percenatge
From PortfolioProject..CovidDeaths
where location like '%CANADA%'
and continent is not null
ORDER BY 1,2

--Looking for Total Cases vs population
--Shows the percentage of population got covid
Select Location, date, POPULATION, total_Cases,  (total_cases/POPULATION)*100 covidecase_Percenatge
From PortfolioProject..CovidDeaths
where location like '%CANADA%'
and continent is not null
ORDER BY 1,2

--Countries with highest Covide cases compared to population
Select Location, POPULATION, MAX(total_Cases) as Highestcases,  MAX((total_cases/POPULATION))*100 Population_Infected_Percenatge
From PortfolioProject..CovidDeaths
--where location like '%CANADA%'
where continent is not null
Group by location, population
ORDER BY 4 desc

--Countries with highest death count per population
Select Location, MAX(cast(total_deaths as int)) as Death_Count,  POPULATION, MAX((total_deaths/POPULATION))*100 Death_Rate
From PortfolioProject..CovidDeaths
--where location like '%CANADA%'
where continent is not null
Group by location, population
ORDER BY 2 desc

--Cases by continent with their Death_rate
Select continent, MAX(cast(total_deaths as int)) as Death_Count, MAX((total_deaths/POPULATION))*100 Death_Rate
From PortfolioProject..CovidDeaths
--where location like '%CANADA%'
where continent is not null
Group by continent
ORDER BY 2 desc

--Contient with highest death count per population
Select continent, MAX(cast(total_deaths as int)) as Death_Count,   MAX((total_deaths/POPULATION))*100 Death_Rate
From PortfolioProject..CovidDeaths
--where location like '%CANADA%'
where continent is not null
Group by continent
ORDER BY 2 desc

--Number of infected cases by number of deaths
Select date,SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
Group By date
order by 1,2

--Globel number
Select SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_deaths, SUM(cast(new_deaths as int))/SUM(New_Cases)*100 as DeathPercentage
From PortfolioProject..CovidDeaths
where continent is not null 
order by 1,2


--Join both the Tables by Date and location
select *
from PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date


-- Total population VS population
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3


-- Shows Percentage of Population that has recieved at least one Covid Vaccine
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
order by 2,3

-- Using CTE to perform Calculation on Partition By in previous query
With PopvsVac (Continent, Location, Date, Population, New_Vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as Rolling_People_Vaccinated
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
--order by 2,3
)
Select *, (Rolling_People_Vaccinated/Population)*100 Recevied_Vaccination_Percent
From PopvsVac


-- Using Temp Table to perform Calculation on Partition By in previous query

--DROP Table if exists #PercentPopulationVaccinated
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
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
--where dea.continent is not null 
--order by 2,3

Select *, (RollingPeopleVaccinated/Population)*100 Recevied_Vaccination_Percent
From #PercentPopulationVaccinated


--later For Visualization Purposes
--#1
Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From PortfolioProject..CovidDeaths dea
Join PortfolioProject..CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 


--#2
create view Deaths_Per_Continent as
Select continent, MAX(cast(total_deaths as int)) as Death_Count, MAX((total_deaths/POPULATION))*100 Death_Rate
From PortfolioProject..CovidDeaths
--where location like '%CANADA%'
where continent is not null
Group by continent
--ORDER BY 2 desc
 
