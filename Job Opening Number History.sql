SELECT 
    jon.Id,
    jon.Number,
    c.CompanyName,
    ce.DateStart,
    jo.Name AS 'Job Opening Type'
FROM INTERNALSERVICEDB.dbo.JobOpeningNumbers jon
INNER JOIN INTERNALSERVICEDB.dbo.JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
OUTER APPLY (
    SELECT TOP 1 * FROM INTERNALSERVICEDB.dbo.CustomerEmployees ce 
		WHERE ce.JobOpeningPositionId = jop.Id AND ce.IsDeleted = 0
		ORDER BY DateStart ASC
    ) AS ce
INNER JOIN (
    SELECT jt.Name,j.Id 
    FROM INTERNALSERVICEDB.dbo.JobOpenings j 
INNER JOIN INTERNALSERVICEDB.dbo.JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId) jo ON jo.Id = jop.JobOpeningId
INNER JOIN INTERNALSERVICEDB.dbo.Customers c ON c.Id = ce.CustomerId
WHERE c.Id != 1 AND c.Id != 281 AND ce.Id IS NOT NULL AND (c.CompanyName NOT LIKE 'codev%' AND c.CompanyName NOT LIKE '%breakthrough%') AND ce.DateStart IS NOT NULL
ORDER BY ce.DateStart DESC