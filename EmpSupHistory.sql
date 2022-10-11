WITH cte_customEmp AS (
    SELECT 
    es.Id,
    emp.CodevId AS teamMemberCodevEmpNumber,
    sup.CodevId AS supCodevEmpNumber,
    emp.FirstName + ' ' + emp.LastName AS teamMember,
    sup.FirstName + ' ' + sup.LastName AS Supervisor,
    es.EffectiveDate AS EffectiveDate
FROM dbo.EmployeeSupervisors es
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = es.EmployeeId
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) sup ON sup.Id = es.SupervisorId
LEFT JOIN dbo.CustomerEmployees ce ON ce.Id = es.CustomerEmployeeId
)
SELECT
    a.EffectiveDate,
    DATEADD(DAY,-1,b.EffectiveDate) AS 'End Date',
    a.teamMemberCodevEmpNumber AS 'Team Member CoDev Emp Num',
    a.[Team Member],
    a.Supervisor    
FROM (
    SELECT
    EffectiveDate,
    teamMemberCodevEmpNumber,
    UPPER(trim(teamMember)) AS 'Team Member',
    Supervisor,
    ROW_NUMBER() OVER(PARTITION BY teamMemberCodevEmpNumber ORDER BY EffectiveDate) AS rn
FROM cte_customEmp) AS a
LEFT JOIN (
    SELECT
    EffectiveDate,
    teamMemberCodevEmpNumber,
    UPPER(trim(teamMember)) AS 'Team Member',
    Supervisor,
    ROW_NUMBER() OVER(PARTITION BY teamMemberCodevEmpNumber ORDER BY EffectiveDate) AS rn
FROM cte_customEmp) AS b ON b.teamMemberCodevEmpNumber = a.teamMemberCodevEmpNumber AND (a.rn + 1 = b.rn)