WITH SplitSkills AS (
    SELECT
        Id,
        CONVERT(NVARCHAR(MAX), NULL) AS Skill,
        SUBSTRING(SkillsSearch, 2, LEN(SkillsSearch) - 2) AS RemainingSkills
    FROM DiscoverAuditTrails
    WHERE SkillsSearch NOT LIKE '%null%'
    UNION ALL
    SELECT
        Id,
        CASE
            WHEN CHARINDEX(',', RemainingSkills) > 0
                THEN LEFT(RemainingSkills, CHARINDEX(',', RemainingSkills) - 1)
            ELSE RemainingSkills
        END AS Skill,
        CASE
            WHEN CHARINDEX(',', RemainingSkills) > 0
                THEN SUBSTRING(RemainingSkills, CHARINDEX(',', RemainingSkills) + 1, LEN(RemainingSkills))
            ELSE ''
        END AS RemainingSkills
    FROM SplitSkills
    WHERE RemainingSkills != ''
)
SELECT
    ss.Id,
    s.Name AS Skill
FROM SplitSkills ss
JOIN Skills s ON s.Id = ss.skill
WHERE ss.Skill != ''
OPTION (MAXRECURSION 0);
