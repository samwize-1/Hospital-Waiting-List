USE HospitalWaitList;
GO

SET statistics io ON
GO


-- Patient age at referral and days waiting from referral date
SELECT p.[NHI], CONCAT(p.[PatFName], ' ',p.[PatLName] ) AS 'Patient Name', 
CAST(DATEDIFF(DAY,p.DOB,r.RefDate) /365.25 AS INT) AS 'Patient Age', 
DATEDIFF(day, r.[RefDate], r.[FSA]) AS 'Days Waiting'
FROM [dbo].[Referral] r
INNER JOIN [dbo].[Patient]p ON r.[NHI]=p.[NHI]
WHERE r.[HealthTarget] = 'Yes'


-- 1.How many people have been referred for cardiothoracic?
SELECT COUNT(r.[DepartmentNo]) AS 'Total Referred to Cardiothoracic'
FROM [dbo].[Referral] r
WHERE r.[DepartmentNo] = D2 AND r.[HealthTarget] = 'Yes'


-- 2. What is the average time taken (in days) to see a Surgeon by Department?
SELECT d.[Department] AS 'Department', r.[NHI], DATEDIFF(day, r.[RefDate], r.[FSA]) AS 'Days Waiting'
FROM [dbo].[Department] d
join [dbo].[Referral] r
on r.[D] = d.[DepartmentNo]
ORDER BY d.[Department] ASC


-- 3.Who has each Surgeon had on their list and how long have they been waiting or did they wait?
SELECT s.[SurgeonLName] AS 'Surgeon Name', 
CONCAT(p.[PatFName], ' ',p.[PatLName] ) AS 'Patient Name',
DATEDIFF(day, r.[RefDate], r.[FSA]) AS 'Days Waiting'
FROM [dbo].[Referral] r
INNER JOIN [dbo].[Patient] p ON p.[NHI] = r.[NHI]
INNER JOIN [dbo].[Surgeon] s ON s.[SurgeonNo] = r.[SurgeonNo]
WHERE r.[FSA] IS NOT NULL -- this removes the ones who didnt wait
ORDER BY s.SurgeonLName ASC


-- 4. Assuming that all patients under 18 need to be seen by Paediatric Surgery, are there any patients who need to be reassigned? 
SELECT p.[NHI] AS 'Patient NHI',
CONCAT(p.[PatFName], ' ', p.[PatLName]) AS 'Patient Name',
CAST(DATEDIFF(DAY,p.[DOB],r.[RefDate]) /365.25 AS INT) AS 'Patient Age',
d.[Department] AS 'Department Name'
FROM  [dbo].[Referral] r
INNER JOIN [dbo].[Patient] p ON p.[NHI]=r.[NHI]
INNER JOIN [dbo].[Department] d ON r.[DepartmentNo]=d.[DepartmentNo]
WHERE CAST(DATEDIFF(DAY,p.[DOB],r.[RefDate]) /365.25 AS INT) < 18 
AND r.[HealthTarget] = 'yes' -- 1 = yes 0 = no
AND d.[Department] !='Paediatric Surgery'


-- 5.What percentage of patient were seen within the target of 75 days by department?
SELECT d.[DepartmentNo] AS 'Department Name',
CAST(CAST(m.MetCount AS DECIMAL) / CAST(p.NoPatient AS DECIMAL) *100 AS DECIMAL) AS 'Percentage Met'
FROM
(
	SELECT r.[DepartmentNo], COUNT(*) AS MetCount 
	FROM  [dbo].[Referral] r
	WHERE DATEDIFF(DAY,r.[RefDate],r.[FSA]) < 76
	GROUP BY r.[DepartmentNo]
) AS m
RIGHT JOIN 
(
	SELECT r.[DepartmentNo], COUNT(*) AS NoPatient
	FROM  [dbo].[Referral] r
	GROUP BY r.[DepartmentNo]
) AS p ON p.[DepartmentNo]=m.[DepartmentNo]
INNER JOIN [dbo].[Department] d ON d.[DepartmentNo]=p.[DepartmentNo]