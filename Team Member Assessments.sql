SELECT 
    NULL AS EmployeeHrReferenceId,
    e.Id AS employeeId,
    ud.CodevId,
    trim(ud.FirstName) + ' ' + trim(ud.LastName) AS Name,
    eca.Score AS CodilityScore,
    eca.Report AS CodilityReport,
    e.RecordedInterview,
    et.Score AS TrueNorthScore,
    e.DeletedDate
FROM dbo.Employees e
INNER JOIN UserDetails ud ON ud.UserId = e.UserId
LEFT JOIN EmployeeCodilityAssessments eca ON eca.EmployeeId = e.Id
LEFT JOIN EmployeeTrueNorthAssessments et ON et.EmployeeId = e.Id
WHERE ud.CodevId IS NOT NULL