SELECT
    jr.Id,
    jr.RecruiterId,
    CONCAT(TRIM(ud.FirstName),' ',TRIM(ud.LastName)) AS Recruiter,
    jr.JobOpeningId,
    CONCAT(TRIM(cb.FirstName),' ',TRIM(cb.LastName)) AS 'Created By',
    jr.Created,
	CONCAT(TRIM(mb.FirstName),' ',TRIM(mb.LastName)) AS 'Last Modified By',
    jr.LastModified,
    cur.JobTitle
  FROM JobOpeningRecruiters jr
  JOIN Employees e ON e.Id = jr.RecruiterId
  JOIN UserDetails ud ON ud.userId = e.userId
  JOIN UserDetails cb ON cb.userId = jr.CreatedBy
  OUTER APPLY (
    SELECT TOP 1 * FROM CustomerEmployees WHERE EmployeeId = jr.RecruiterId AND IsDeleted = 0 ORDER BY DateStart DESC
    ) AS cur
  LEFT JOIN UserDetails mb ON mb.userId = jr.LastModifiedBy