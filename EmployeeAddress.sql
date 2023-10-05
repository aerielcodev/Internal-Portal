/*Address Information saved in the Internal Portal*/
SELECT
    CONCAT(TRIM(ud.FirstName),' ',TRIM(ud.LastName)) AS Name,
    ud.CodevId,
    ea.Street,
    ea.City,
    s.Name AS State,
    ea.ZipCode,
    c.Name AS Country
FROM Employees e
JOIN UserDetails ud ON ud.UserId = e.UserId
LEFT JOIN EmployeeAddresses ea ON ea.EmployeeId = e.Id
LEFT JOIN States s ON s.Id = ea.StateId
LEFT JOIN Countries c ON c.Id = s.CountryId