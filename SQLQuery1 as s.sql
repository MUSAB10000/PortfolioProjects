


-- Total Cases vs Total Deaths in Saudi Arabia
Select Location, date, total_cases,total_deaths, (total_deaths/total_cases)*100 as DeathPercentage
From CovidDeaths
Where location like '%Saudi Arabia%'
and continent is not null 
order by 1,2


-- Total Cases vs Population in Saudi Arabia
Select Location, date, Population, total_cases,  (total_cases/population)*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%Saudi Arabia%'
order by 1,2


-- Countries with Highest Infection Rate compared to Population

Select Location, Population, MAX(total_cases) as HighestInfectionCount,  Max((total_cases/population))*100 as PercentPopulationInfected
From CovidDeaths
Where location like '%Saudi%'
Group by Location, Population
order by PercentPopulationInfected desc


-- Countries with Highest Death Count per Population

Select Location, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%Saudi%'
where continent is not null 
Group by Location
order by TotalDeathCount desc



-- BREAKING THINGS DOWN BY CONTINENT
Select continent, MAX(cast(Total_deaths as int)) as TotalDeathCount
From CovidDeaths
--Where location like '%Saudi%'
where continent is not null 
Group by continent
order by TotalDeathCount desc

--GLOBAL NUMBERS 
Select date, SUM(new_cases) AS Total_Cases ,SUM(CAST(new_deaths as int)) AS Total_Deaths, (SUM(CAST(new_deaths as int))/SUM(new_cases))*100 as DeathPercentage
From CovidDeaths
WHERE continent is not null 
group by date
order by 1,2

--Looking at Total Populatiion vs Vaccination
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
,(sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date)/cd.population)*100
from CovidVaccinations cv join CovidDeaths cd on cv.location=cd.location and cd.date=cv.date
WHERE cd.continent is not null 
order by 1,2,3
-- another solution to make code more clean 
-- USE CTE 
with pv(Continent,Location,Date,Population,New_Vaccinations,RollingPeopleVaccinated )
as
(
select cd.continent,cd.location,cd.date,cd.population,cv.new_vaccinations, 
sum(convert(int,cv.new_vaccinations)) over (partition by cd.location order by cd.location,cd.date) as RollingPeopleVaccinated
from CovidVaccinations cv join CovidDeaths cd on cv.location=cd.location and cd.date=cv.date
WHERE cd.continent is not null 
)
select * ,(RollingPeopleVaccinated/population)*100
from pv
-- USING TEMP TABLE 
DROP Table if exists #PercentPopulationVaccinated
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
Select cd.continent, cd.location, cd.date, cd.population, cv.new_vaccinations
, SUM(CONVERT(int,cv.new_vaccinations)) OVER (Partition by cd.Location Order by cd.location, cd.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths cd
Join CovidVaccinations cv
	On cd.location = cv.location
	and cd.date = cv.date
	WHERE cd.continent is not null 
Select *, (RollingPeopleVaccinated/Population)*100
From #PercentPopulationVaccinated
-- Creating View 

Create View PercentPopulationVaccinated as
Select dea.continent, dea.location, dea.date, dea.population, vac.new_vaccinations
, SUM(CONVERT(int,vac.new_vaccinations)) OVER (Partition by dea.Location Order by dea.location, dea.Date) as RollingPeopleVaccinated
--, (RollingPeopleVaccinated/population)*100
From CovidDeaths dea
Join CovidVaccinations vac
	On dea.location = vac.location
	and dea.date = vac.date
where dea.continent is not null 