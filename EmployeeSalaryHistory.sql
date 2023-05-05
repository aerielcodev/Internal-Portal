SELECT
    e.Id,
    ud.CodevId,
    trim(ud.FirstName) + ' ' + trim(ud.LastName) AS Name,
    eh.BasePay,
    eh.Allowance,
    eh.EffectiveDate,
    cb.FirstName + ' ' + cb.LastName AS CreatedBy,
    row_number() over(partition by e.Id  ORDER BY eh.EffectiveDate) AS RowNum
FROM Employees e 
INNER JOIN EmployeeSalaryHistories eh ON eh.EmployeeId = e.Id
INNER JOIN userDetails ud ON ud.UserId = e.UserId
LEFT JOIN userDetails cb ON cb.UserId = e.CreatedBy
WHERE ud.CodevId IS NOT NULL 
