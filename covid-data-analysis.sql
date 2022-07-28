--working with the file of covid deaths
Select *
from portfolio_project ..[owid-covid-data deaths]
order by 3,4

--working with the file of covid data 
Select *
from portfolio_project ..[owid-covid-data]
order by 3,4

--selecting the data I'm going to use
select location,date,total_cases,new_cases,total_deaths,population
from portfolio_project ..[owid-covid-data deaths]
order by 1,2

--looking at total_cases vs total_deaths
--showing the likelihood of dying with covid
select location,date,total_cases,total_deaths, (total_deaths/total_cases)*100 as death_percentage
from portfolio_project..[owid-covid-data deaths]
where location like '%states%'
order by 1,2

--looking at total cases vs population
--showing the percentage of population got covid
select location,date,total_cases,population, (total_cases/population)*100 as casesinfected_percentage
from portfolio_project..[owid-covid-data deaths]
where location like '%egypt%' 
order by 1,2

--looking for countries with highest infection rate to population
select location, population, MAX(total_cases) as heighest_infection , MAX((total_cases/population))*100 as casesinfected_percentage
from portfolio_project ..[owid-covid-data deaths]
group by location,population
order by casesinfected_percentage desc

--breaking things down by location
select location, MAX(cast(total_deaths as int)) as totaldeath_count
from portfolio_project ..[owid-covid-data deaths]
--where location like '%states%'
where continent is null
group by location
order by totaldeath_count desc

--breaking things down by continent

--showing contintents with the hieghst death count per population
select continent, MAX(cast(total_deaths as int)) as totaldeath_count
from portfolio_project ..[owid-covid-data deaths]
--where location like '%states%'
where continent is not null
group by continent
order by totaldeath_count desc


--global numbers
select date, SUM(new_cases) as total_cases, SUM(cast(new_deaths as int)) as total_death, SUM(cast(new_deaths as int))/SUM(new_cases)*100 as DeathPercentage
from portfolio_project..[owid-covid-data deaths]
--where location like '%states%'
where continent is not null
group by date
order by 1,2




--looking at total population vs vaccination
with PopvsVac (continent, location, Date, Population,new_vaccinations, rollingpeoplevaccinations)
as
(
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as rollingpeoplevaccinations
from portfolio_project..[owid-covid-data deaths] dea
join portfolio_project..[owid-covid-data] vac
  on dea.location = vac.location
  and dea.date = vac.date
where dea.continent is not null
--order by 2,3
)
select *, (rollingpeoplevaccinations/Population)*100
from PopvsVac


--time table

drop table if exists #PercentPopulationVaccinated
Create Table #PercentPopulationVaccinated
(
continet nvarchar(255),
location nvarchar(225),
date datetime,
population numeric,
new_vaccinations numeric,
rollingpeoplevaccinations numeric
)
Insert into #PercentPopulationVaccinated
select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations, SUM(CONVERT(int,vac.new_vaccinations)) OVER (partition by dea.location order by dea.location, dea.Date) as rollingpeoplevaccinations
from portfolio_project..[owid-covid-data deaths] dea
join portfolio_project..[owid-covid-data] vac
  on dea.location = vac.location
  and dea.date = vac.date
--where dea.continent is not null
--order by 2,3

select *, (rollingpeoplevaccinations/Population)*100
from #PercentPopulationVaccinated

-- Creating View to store data for later visualizations

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From portfolio_project..[owid-covid-data deaths] dea
Join portfolio_project..[owid-covid-data] vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 
