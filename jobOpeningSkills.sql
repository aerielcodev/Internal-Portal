SELECT 
    pivotTbl.JobOpeningId,
    pivotTbl.[1] AS 'Technical Skills',
    pivotTbl.[2] AS 'Additional Tech Skills'
FROM (SELECT
    js.JobOpeningId,
    string_agg(concat(iif(js.OtherSkill IS NULL,s.Name,js.OtherSkill),' (' , CAST(js.YearsOfExperience AS int),')' ),' , ') AS skillExp,
    js.SkillTypeId AS skillType
FROM JobOpeningSkills js
INNER JOIN Skills s ON js.SkillId = s.id
GROUP BY js.JobOpeningId, js.SkillTypeId) AS t
PIVOT
    (max(t.skillExp) FOR t.skillType IN ([1],[2])) AS pivotTbl
