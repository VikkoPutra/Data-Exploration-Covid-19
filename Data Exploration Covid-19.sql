BEGIN --CHOOSE THE DATA
	SELECT Location, Date, Total_Cases, New_Cases, Total_Deaths, Population
	FROM [Portfolio Projects]..CovidDeaths
	WHERE Iso_Code NOT LIKE '%OWID%'
	ORDER BY 1,2
END


BEGIN --DEATH PERCENTAGE
	SELECT Location, Date, Total_Cases, Total_Deaths, Population,
	 (Total_Deaths/Total_Cases)*100 DeathPercentage
	FROM [Portfolio Projects]..CovidDeaths
	WHERE Iso_Code NOT LIKE '%OWID%'
	ORDER BY 1,2
END


BEGIN --INFECTED PERCENTAGE
	SELECT Location, Date, Population, Total_Cases, Total_Deaths,
	 (Total_Cases/Population)*100 InfectedPercentage
	FROM [Portfolio Projects]..CovidDeaths
	WHERE Iso_Code NOT LIKE '%OWID%'
	ORDER BY 1,2
END


BEGIN --HIGHEST INFECTION RATE
	SELECT Location, Population, MAX(Total_Cases) InfectionCount,
	 MAX((Total_Cases/Population))*100 InfectedCount
	FROM [Portfolio Projects]..CovidDeaths
	WHERE Iso_Code NOT LIKE '%OWID%'
	GROUP BY Location, Population
	ORDER BY InfectedCount desc
END


BEGIN --HIGHEST DEATH COUNT
	SELECT Location, MAX(CAST(Total_Deaths AS INT)) DeathCount
	FROM [Portfolio Projects]..CovidDeaths
	WHERE Iso_Code NOT LIKE '%OWID%'
	GROUP BY Location, Population
	ORDER BY DeathCount desc
END


BEGIN --GLOBAL NUMBERS EVERYDAY
	SELECT Date, SUM(New_Cases) TotalCases, SUM(CAST(New_Deaths AS INT)) TotalDeaths,
	 SUM(CAST(New_Deaths AS INT))/SUM(New_Cases)*100 DeathPercentage
	FROM [Portfolio Projects]..CovidDeaths
	WHERE Iso_Code NOT LIKE '%OWID%'
	GROUP BY Date
	ORDER BY 1,2
END


BEGIN --TOTAL VACCINATIONS EVERYDAY
	WITH CTE1 (Continent, Location, Date, Population, New_Vaccinations, Total_Vaccinations)
	AS (
		SELECT D.continent, D.location, D.date, D.population, V.new_vaccinations,
		 SUM(CAST(ROUND(V.new_vaccinations,0) AS BIGINT)) OVER (PARTITION BY D.location ORDER BY D.Location, D.Date)
		 AS total_vaccinations
		FROM [Portfolio Projects]..CovidDeaths D
		JOIN [Portfolio Projects]..CovidVaccinations V
			ON  D.Location = V.Location
			AND D.Date = V.Date
		WHERE D.Iso_Code NOT LIKE '%OWID%'
		)
	SELECT *, (total_vaccinations/Population)*100 VaccinationsPercentage
	FROM CTE1
END