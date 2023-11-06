SELECT DISTINCT
    ce.EmployeeId,
    ce.id AS customerEmployeesId,
	ce.CustomerId,
    emp.CoDevId,
    upper(CONCAT(TRIM(emp.FirstName),' ',TRIM(emp.LastName))) AS 'Team Member',
    ce.jobTitle AS 'Job Title',
    c.CompanyName,
    ce.DateStart,
	ce.DateStart AS ScheduleDate,
	ce.PartTimeDate,
    coalesce(ce.DateEnd, e.DeletedDate) AS DateEnd,
    CONCAT(TRIM(cb.FirstName) ,' ' ,TRIM(cb.LastName)) AS 'Created By',
    CONCAT(TRIM(mb.FirstName) ,' ' ,TRIM(mb.LastName)) AS 'Modified By',
    cs.Name AS 'Candidate Status',
	ROW_NUMBER() OVER(PARTITION BY ce.EmployeeId ORDER BY ce.DateStart) AS 'Sequence Number',
    (CASE WHEN LAG(ce.CustomerId) OVER (PARTITION BY ce.EmployeeId ORDER BY ce.DateStart) = 1 THEN 'Yes' ELSE 'No' END) AS 'placedFromBench' 
FROM Customers c 
LEFT JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
LEFT JOIN (SELECT emp.*,e.Id, e.CandidateStatusId FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = ce.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) mb ON mb.UserId = ce.LastModifiedBy
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) cb ON cb.UserId = ce.CreatedBy
LEFT JOIN Employees e ON e.Id = ce.EmployeeId AND e.Status = 3
LEFT JOIN CandidateStatuses cs ON cs.Id = emp.CandidateStatusId
WHERE LOWER(TRIM(emp.FirstName)) NOT LIKE '%demo%' AND LOWER(TRIM(emp.FirstName)) NOT LIKE '%test%'
	AND LOWER(TRIM(emp.LastName)) NOT LIKE '%demo%' AND LOWER(TRIM(emp.LastName)) NOT LIKE'%test%'
	AND ce.IsDeleted = 0
ORDER BY ce.EmployeeId DESC