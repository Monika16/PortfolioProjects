Select * from PortfolioProject.covid_deaths
order by 3,4;

Select * from PortfolioProject.covid_vaccinations
order by 3,4;

select location, date, total_cases, new_cases, total_deaths, population
from PortfolioProject.covid_deaths
order by 1,2;

/*finding total death percentage*/
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 DeathPercentage
from PortfolioProject.covid_deaths
where location like 'India'
order by 1,2;

/*finding what percentage of population got covid*/

select location, date, total_cases, population, (total_cases/population)*100 covidPercentage
from PortfolioProject.covid_deaths
/*where location like '%india%'*/
order by 1,2;

/*Finding highest infection rate compared to population*/

select location, population, max(total_cases)as HighestInfectionCount, max((total_cases/population))*100 covidPercentage
from PortfolioProject.covid_deaths
group by location, population
order by 4 desc;

/*Countries with highest death count per population*/
select location, max(cast(total_deaths as unsigned)) HighestDeathCount
from PortfolioProject.covid_deaths
group by location
order by 2 desc;

/*Continents with highest death Count*/
select continent, max(cast(total_deaths as unsigned)) HighestDeathCount
from PortfolioProject.covid_deaths
where continent is not null
group by continent
order by 2 desc;

/*Finding global number of deaths by date*/
select date, sum(new_cases) totalCases, sum(new_deaths) as totalDeaths, (sum(new_deaths)/sum(new_cases))*100 covidPercentage
from PortfolioProject.covid_deaths
group by date
order by 1,2;

/*Finding global number of death percentage*/
select sum(new_cases) totalCases, sum(new_deaths) as totalDeaths, (sum(new_deaths)/sum(new_cases))*100 covidPercentage
from PortfolioProject.covid_deaths
order by 1,2;

/*delete t1 from covid_deaths t1
inner join covid_deaths t2
on t1.date = t2.date
and t1.location = t2.location;

delete t1 from covid_vaccinations t1
inner join covid_vaccinations t2
on t1.date = t2.date
and t1.location = t2.location;*/

/*Join two tables*/
Select * from
	PortfolioProject.covid_deaths dea
    join PortfolioProject.covid_vaccinations vacc
    on dea.location = vacc.location 
    and dea.date = vacc.date
    order by 3,4;
    
/*Total population vs Total vaccinations*/
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (partition by vacc.location order by dea.location, dea.date) PeopleVaccinated
from
	(select distinct * from PortfolioProject.covid_deaths) dea
       join (select distinct * from PortfolioProject.covid_vaccinations) vacc
    on dea.location = vacc.location 
	   and dea.date = vacc.date
/*where vacc.new_vaccinations <> ''*/
order by 2,3;

With PopVsVac (Continent, Location, Date, Population, NewVaccinations, PeopleVaccinated)
as
(
	Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
	sum(vacc.new_vaccinations) over (partition by vacc.location order by dea.location, dea.date) PeopleVaccinated
	from
		(select distinct * from PortfolioProject.covid_deaths) dea
		   join (select distinct * from PortfolioProject.covid_vaccinations) vacc
		on dea.location = vacc.location 
		   and dea.date = vacc.date
	/*where vacc.new_vaccinations <> ''*/
)
select *, (PeopleVaccinated/Population)*100 VaccinationPercentage from PopVsVac;

/*Create Temp table*/
create temporary table PercentPeopleVaccinated
(
	Continent nvarchar(255),
	Location nvarchar(255),
    Date datetime,
    Population numeric,
    new_vaccinations numeric,
    PeopleVaccinated numeric
);

Insert into PercentPeopleVaccinated
Select dea.continent, dea.location, dea.date, dea.population, vacc.new_vaccinations,
sum(vacc.new_vaccinations) over (partition by vacc.location order by dea.location, dea.date) PeopleVaccinated
from
	(select distinct * from PortfolioProject.covid_deaths) dea
       join (select distinct * from PortfolioProject.covid_vaccinations) vacc
    on dea.location = vacc.location 
	   and dea.date = vacc.date