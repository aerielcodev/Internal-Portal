SELECT
    jp.Id,
    jp.Title,
    jp.IsUrgent,
    CONCAT(cb.FirstName,' ',cb.LastName) AS 'Created By',
    jp.Created,
    CONCAT(mb.FirstName,' ',mb.LastName) AS 'Modified By',
    jp.LastModified,
    jp.Number,
    jpo.JobOpeningId,
    jps.ValidUntil,
    IIF(jps.ValidUntil >= GETDATE(),'Y','N') AS isActive
FROM JobPostings jp
INNER JOIN JobPostingOpenings jpo ON jpo.JobPostingId = jp.Id
INNER JOIN JobPostingPublishSites jps  ON jps.JobPostingId = jp.Id
LEFT JOIN UserDetails cb ON cb.UserId = jp.CreatedBy
LEFT JOIN UserDetails mb ON mb.UserId = jp.CreatedBy
WHERE jp.Title NOT LIKE '%test%' AND jp.Title NOT LIKE '%demo%'
ORDER BY jpo.JobOpeningId DESC
