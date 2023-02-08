SELECT 
    jon.Id,
    jon.Number,
    c.CompanyName,
    ce.DateStart,
    jo.Name AS 'Job Opening Type'
FROM JobOpeningNumbers jon
INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
OUTER APPLY (
    SELECT TOP 1 * FROM CustomerEmployees ce 
		WHERE ce.JobOpeningPositionId = jop.Id
		ORDER BY DateStart ASC
    ) AS ce
INNER JOIN (
    SELECT jt.Name,j.Id 
    FROM JobOpenings j 
INNER JOIN JobOpeningTypes jt ON jt.Id = j.JobOpeningTypeId) jo ON jo.Id = jop.JobOpeningId
INNER JOIN INTERNALSERVICEDB.dbo.Customers c ON c.Id = ce.CustomerId
WHERE ce.DateStart IS NOT NULL
ORDER BY ce.DateStart DESC