SELECT 
    emp.Id AS EmployeeId,
    emp.CoDevId,
    upper(trim(emp.FirstName) + ' ' + trim(emp.LastName)) AS 'Team Member',
    pivotTbl.[1] AS 'Primary Skills',
    pivotTbl.[2] AS 'Secondary Skills'
FROM (SELECT
    es.EmployeeId AS eId,
    string_agg(concat(iif(es.OtherSkill IS NULL,s.Name,es.OtherSkill),' (' , CAST(es.YearsOfExperience AS int),')' ),' , ') AS skillExp,
    es.SkillTypeId AS skillType
FROM EmployeeSkills es
INNER JOIN Skills s ON es.SkillId = s.id
GROUP BY es.EmployeeId, es.SkillTypeId) AS t
PIVOT
    (max(t.skillExp) FOR t.skillType IN ([1],[2])) AS pivotTbl
LEFT JOIN (SELECT emp.*,e.Id FROM Employees e INNER JOIN UserDetails emp ON emp.UserId = e.UserId) emp ON emp.Id = pivotTbl.eId
