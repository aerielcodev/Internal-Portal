/*List all skills searched in the Customer Portal*/
WITH SplitSkills AS (
  SELECT 
    Id,
    CAST(NULLIF(LEFT(SUBSTRING(SkillsSearch, 2, LEN(SkillsSearch) - 2), CHARINDEX(',', SUBSTRING(SkillsSearch, 2, LEN(SkillsSearch) - 2) + ',') - 1), '') AS INT) AS skill,
    SUBSTRING(SUBSTRING(SkillsSearch, 2, LEN(SkillsSearch) - 2), CHARINDEX(',', SUBSTRING(SkillsSearch, 2, LEN(SkillsSearch) - 2) + ',') + 1, LEN(SUBSTRING(SkillsSearch, 2, LEN(SkillsSearch) - 2))) AS remaining_skill
  FROM DiscoverAuditTrails
  WHERE SkillsSearch NOT LIKE '%null%'
  UNION ALL
  SELECT 
    Id,
    CAST(NULLIF(LEFT(remaining_skill, CHARINDEX(',', remaining_skill + ',') - 1), '') AS INT) AS skill,
    SUBSTRING(remaining_skill, CHARINDEX(',', remaining_skill + ',') + 1, LEN(remaining_skill))
  FROM SplitSkills
  WHERE remaining_skill != ''
)
SELECT 
    ss.Id, 
    s.Name
FROM SplitSkills ss
JOIN Skills s ON s.Id = ss.skill

