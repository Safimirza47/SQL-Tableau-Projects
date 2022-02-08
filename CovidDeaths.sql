
Select * 
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--Select * 
--From PortfolioProject..CovidVaccinations
--order by 3,4;

-- Select data that we are going to be using

Select location, date, total_cases, new_cases, total_deaths, population
From PortfolioProject..CovidDeaths
where continent is not null
order by 3,4;

--Looking at Total Cases vs Total Deaths
-- Shows likelihood of dying if you contract in your country
Select location, date, total_cases, total_deaths, Round((total_deaths/total_cases)* 100, 4) as Death_Percentage
From PortfolioProject..CovidDeaths
where location like '%states%' and continent is not null
order by 1,2; 

--Looking at Total Cases vs the Population
-- what percentage of population diagnosed with COVID
Select location, date, Population, total_cases, (total_cases/Population)* 100 as Covid_Percentage
From PortfolioProject..CovidDeaths 
--where location like '%states%'
order by 1,2; 


--Looking at Countries with highest infection rate compared to population

Select location, Population, Max(total_cases) as Highest_Infection, Max((total_cases/Population))* 100 as Covid_Percentage
From PortfolioProject..CovidDeaths 
--where location like '%states%'
group by location, Population
order by Covid_Percentage desc; 


-- Showing Countries with highest death count per population

Select location, Max(cast(total_deaths as int)) as Highest_death_count
From PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by location
order by Highest_death_count desc;


-- Let's break things down by continent 

Select continent, Max(cast(total_deaths as int)) as Highest_death_count
From PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent 
order by Highest_death_count desc;


-- Showing continents with the highest death count per population

Select continent, Max(cast(total_deaths as int)) as Highest_death_count
From PortfolioProject..CovidDeaths 
--where location like '%states%'
where continent is not null
group by continent 
order by Highest_death_count desc;

-- Global Numbers 

Select sum(new_cases) as Total_cases, sum(cast(new_deaths as int)) as Total_deaths, (sum(cast(new_deaths as int))/sum(new_cases))* 100 as Death_Percentage
From PortfolioProject..CovidDeaths
--where location like '%states%' 
where continent is not null
order by 1,2; 


Select * 
From PortfolioProject..CovidVaccinations;


--Looking at Total Population vs Vaccinations

Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated --, (Rolling_People_Vaccinated/population) * 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations Vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
order by 2,3; 

--Use CTE

With PopvsVac (Continent, location, date, population, New_vaccinations, Rolling_People_Vaccinated)
as
(
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated --, (Rolling_People_Vaccinated/population) * 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations Vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3; 
)
Select *, (Rolling_People_Vaccinated/population) * 100 as Vaccinated_Population
from PopvsVac

--Temp Table
Drop table if exists #PercentPopulationVaccinated;

Create table #PercentPopulationVaccinated 
( 
continent nvarchar(255),
location nvarchar(255), 
date datetime,
population numeric,
New_vaccinations numeric,
Rolling_People_Vaccinated numeric 
);

insert into #PercentPopulationVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated --, (Rolling_People_Vaccinated/population) * 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations Vac
on dea.location = vac.location 
and dea.date = vac.date
--where dea.continent is not null
--order by 2,3; 


Select *, (Rolling_People_Vaccinated/population) * 100 as Vaccinated_Population
from #PercentPopulationVaccinated;

--Creating  view to store data for later visualizations 
drop view if exists PercentPopulationVaccinated;
create view PercentPopulationVaccinated
as 
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(bigint,vac.new_vaccinations)) over 
(Partition by dea.location order by dea.location, dea.date) as Rolling_People_Vaccinated --, (Rolling_People_Vaccinated/population) * 100 
from PortfolioProject..CovidDeaths dea
join PortfolioProject..CovidVaccinations Vac
on dea.location = vac.location 
and dea.date = vac.date
where dea.continent is not null
--order by 2,3; 


Select * 
From PercentPopulationVaccinated;
