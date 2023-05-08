SELECT
    es.EmployeeId,
    emp.CodevId AS CoDevId,
    trim(emp.FirstName) + ' ' + trim(emp.LastName) AS 'Team Member',
    iif(es.OtherSkill IS NULL,s.Name,es.OtherSkill) AS Skill,
    CAST(es.YearsOfExperience AS int) AS 'Years of Experience',
    iif(es.SkillTypeId = 1 ,'Primary', 'Secondary') AS skillType
FROM EmployeeSkills es
INNER JOIN Skills s ON es.SkillId = s.id
LEFT JOIN (
    SELECT 
        emp.FirstName,
        emp.LastName,
        emp.CodevId,
        e.Id 
    FROM Employees e 
    INNER JOIN UserDetails emp ON emp.UserId = e.UserId
    ) emp ON emp.Id = es.EmployeeId
