Select location,date,total_cases,new_cases,total_deaths,population
from CovidProject..CovidDeaths$
order by 1,2

--total cases vs total deaths

Select location,date,new_cases,total_deaths, (total_deaths/total_cases)*100 as percentage_infected_dead
from CovidProject..CovidDeaths$
order by 1,2

--likelihood of dying in your country
Select location,date,new_cases,total_deaths, (total_deaths/total_cases)*100 as percentage_infected_dead
from CovidProject..CovidDeaths$
where location like '%india%'
order by 1,2

-- total cases vs population
Select location,date,total_cases,population,(total_cases/population)*100 as percentage_infected
from CovidProject..CovidDeaths$
where location like '%india%'
order by 1,2

--countries with max infection rate
select location, max(total_cases) as highest_count, population, MAX((total_cases/population))*100 as highestinfectionPrecentage
from CovidProject..CovidDeaths$
group by location,population
order by highestinfectionPrecentage desc


-- countries with highest death rate
select location, max(total_deaths) as highest_count, population, MAX((total_deaths/population))*100 as highestdeathPrecentage
from CovidProject..CovidDeaths$
group by location,population
order by highestdeathPrecentage desc

--countries with highest death count
select location, max(cast(total_deaths as int)) as death_count
from CovidProject..CovidDeaths$
where continent is not null
group by location
order by death_count desc

-- continents with highest death count
select location, max(cast(total_deaths as int)) as death_count
from CovidProject..CovidDeaths$
where continent is null
group by location
order by death_count desc

--global numbers
select date, sum(new_cases) as totalcases, sum(cast(new_deaths as int)) as totaldeaths, sum(cast(new_deaths as int))/sum(new_cases)*100 as deathPercent
from CovidProject..CovidDeaths$
where continent is not null
group by date
order by 1,2

--total population vs vaccinatons
select dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as peopleVaccinatedByCountryANDbyDate
from CovidProject..CovidDeaths$ dea
join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null
order by 1,2

--temp table
drop table if exists #percentagePeopleVaccinated
create table #percentagePeopleVaccinated
(
location nvarchar(255),
date datetime,
population numeric,
newVaccinations numeric,
peopleVaccinatedByCountryANDbyDate numeric
)
 insert into #percentagePeopleVaccinated
 select dea.location, dea.date, dea.population, vac.new_vaccinations, sum(convert(int,vac.new_vaccinations)) over (partition by dea.location order by dea.location,dea.date) as peopleVaccinatedByCountryANDbyDate
from CovidProject..CovidDeaths$ dea
join CovidProject..CovidVaccinations$ vac
on dea.location = vac.location
and dea.date = vac.date
where dea.continent is not null

select*, (peopleVaccinatedByCountryANDbyDate/population)*100 as percentagePeopleVaccinatedByCountryANDbyDate
from #percentagePeopleVaccinated

--view to store data for later visualizations

create view
ContinentDeathCount as
select location, max(cast(total_deaths as int)) as death_count
from CovidProject..CovidDeaths$
where continent is null
group by location

select * 
from ContinentDeathCount
order by death_count desc