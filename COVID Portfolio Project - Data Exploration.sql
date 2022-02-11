select * from PortfolioProject..CovidDeaths$
where continent is not null
order by 3,4

-- select * from PortfolioProject..CovidVaccinations$
-- order by 3,4

-- SELECT DATA THAT WE ARE GOING TO USE:

Select Location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject..CovidDeaths$
where continent is not null
order by 1,2

-- LOOKING AT TOTAL CASE Vs TOTAL DEATHS:
-- SHOWS LIKELIHOOD OF DYING IF YOU CONTRACT COVID IN YOUR COUNTRY:

Select Location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$ 
where location like '%states%'
and continent is not null
order by 1,2

-- LOOKING AT TOTAL CASES Vs POPULATION:
-- SHOWS WHAT PERCENTAGE OF POPULATION GOT COVID:

Select Location, date, population, total_cases, (total_cases/population)*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths$ 
-- where location like '%states%'
order by 1,2

-- LOOKING AT COUNTRIES WITH HIGHEST INFECTION RATE COMPARED TO POPULATION:

Select Location, population, max(total_cases) as Highest_Infection , max((total_cases/population))*100 as Percent_Population_Infected
from PortfolioProject..CovidDeaths$ 
group by location, population
order by Percent_Population_Infected desc

-- SHOWING COUNTRIES WITH HIGHEST DEATH COUNT PER POPULATION:

Select Location, max(cast(total_deaths as int)) as Highest_Death_Count 
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by location
order by Highest_Death_Count desc


-- LET'S BREAK THINGS BY LOCATION:

Select location, max(cast(total_deaths as int)) as Highest_Death_Count 
from PortfolioProject..CovidDeaths$ 
where continent is null
group by location
order by Highest_Death_Count desc


-- SHOWING THE CONTINENTS WITH HIGHEST DEATH COUNT PER POPULATION:

Select continent, max(cast(total_deaths as int)) as Highest_Death_Count 
from PortfolioProject..CovidDeaths$ 
where continent is not null
group by continent
order by Highest_Death_Count desc

-- GLOBAL NUMBERS

Select sum(new_cases) as New_Cases, sum(cast(new_deaths as int)) as New_deaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as DeathPercentage
from PortfolioProject..CovidDeaths$ 
-- where location like '%states%'
where continent is not null
--group by date
order by 1,2

-- LOOKING AT TOTAL POPULATION Vs VACCINATIONS:

select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date ) as RunningPeopleVaccinated
from PortfolioProject..CovidDeaths$ cd
join PortfolioProject..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
order by 2,3 


-- USING CTE:

With PopvsVac(continent, location, date, population, new_vaccinations, RollingPeopleVaccinated)
as
(
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date ) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ cd
join PortfolioProject..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
-- order by 2,3 
)
select *, (RollingPeopleVaccinated/population)*100
from PopvsVac

-- TEMP TABLE

create table #PercentPopulationVaccinated(
continent nvarchar(255),
location nvarchar(255),
date datetime,
population numeric,
new_vaccinations numeric,
RollingPeopleVaccinated numeric
)
Insert into #PercentPopulationVaccinated
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, cd.date ) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ cd
join PortfolioProject..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date = cv.date
-- where cd.continent is not null
-- order by 2,3 

select *, (RollingPeopleVaccinated/population)*100
from #PercentPopulationVaccinated

-- Creating view to store data for later visualizations:

create view PercentPopulation as
select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, sum(convert(bigint, cv.new_vaccinations)) OVER (partition by cd.location order by cd.location, 
  cd.date ) as RollingPeopleVaccinated
from PortfolioProject..CovidDeaths$ cd
join PortfolioProject..CovidVaccinations$ cv
	on cd.location = cv.location
	and cd.date = cv.date
where cd.continent is not null
--order by 2,3 








