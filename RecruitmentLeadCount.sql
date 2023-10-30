SELECT
    count(*) AS jobOpenings,
    jr.JobOpeningId,
    max(cur.JobTitle) AS jobTitle
  FROM JobOpeningRecruiters jr
  JOIN Employees e ON e.Id = jr.RecruiterId
  JOIN UserDetails ud ON ud.userId = e.userId
  OUTER APPLY (
    SELECT TOP 1 * FROM CustomerEmployees WHERE EmployeeId = jr.RecruiterId AND IsDeleted = 0 ORDER BY DateStart DESC
    ) AS cur
  GROUP BY jr.JobOpeningId
HAVING 
  SUM(CASE WHEN cur.JobTitle = 'Recruitment Lead' THEN 1 ELSE 0 END) > 0
   AND SUM(CASE WHEN cur.JobTitle = 'Recruitment Specialist' THEN 1 ELSE 0 END) = 0