------------------------------TOP 6 States -Having more Vehicles-------------------------------------------------------------------------------------------------
SELECT 
    temp2.temp.hire_Vehicle_Count
    ,temp2.state
FROM 
    (SELECT 
        temp.state,
        temp.hire_Vehicle_Count
        DENSE_RANK() OVER ( ORDER BY temp.hire_Vehicle_Count DESC) rank 
    FROM
        (SELECT
            SUBSTRING("Base Address", LENGTH("Base Address") - 7, 2) AS state
            COUNT("Vehicle License Number") AS hire_Vehicle_Count
        FROM FHV_DATA
        GROUP BY state
        ORDER BY hire_Vehicle_Count) AS temp) AS temp2
WHERE temp2.rank <=6
ORDER BY temp2.rank  ASC

------------------------------Number of vehicals expire in next 6 months to trigger any alert notification-------------------------------------------------------------------------------------------------
SELECT "Vehicle License Number",
"Base Address",
"Base Telephone Number",
"Expiration Date" AS expiration_date
FROM FHV_DATA
WHERE date_format(expiration_date,'mm/dd/yyyy') >=date_format(DATE_ADD(CURRENT_DATE, INTERVAL 6 MONTH),'mm/dd/yyyy')
ORDER BY expiration_date
------------------------------Top 5 states - vehical average age is greater than 5 years-------------------------------------------------------------------------------------------------
SELECT
    SUBSTRING("Base Address", LENGTH("Base Address") - 7, 2) AS state
    AVG(YEAR(GETDATE()) - "Vehicle Year") AS avg_vehicle_age 
FROM FHV_DATA
WHERE 
    avg_vehicle_age >=5
GROUP BY avg_vehicle_age
ORDER BY avg_vehicle_age
------------------------------Count of vehicals expiring -  based on month and year-------------------------------------------------------------------------------------------------
SELECT 
    COUNT("Vehicle License Number") AS hire_Vehicle_Count
    MONTH("Expiration Date") AS extracted_month,
    YEAR("Expiration Date") AS extracted_year
FROM 
    FHV_DATA
GROUP BY extracted_month,extracted_year
ORDER BY extracted_month,extracted_year


