SELECT
    cp.Id,
    cp.FirstName + ' ' + cp.LastName AS Candidate,
    posn.posnTeam AS Team,
    posn.posnType AS 'Type',
    posn.posnName AS Position,
    row_number() over(partition by posn.CandidateProfileInformationId  ORDER BY posn.CandidateProfileInformationId  ) AS RowNum
FROM CandidateProfileInformations cp 
INNER JOIN (
    SELECT
        qp.CandidateProfileInformationId,
        jp.Name AS posnName,
        jt.Name AS posnType,
        jteam.Name AS posnTeam
    FROM CandidateQualifiedPositions qp 
    INNER JOIN JobPositions jp ON jp.Id = qp.JobPositionId
    INNER JOIN JobTypes jt ON jt.Id = jp.JobTypeId
    INNER JOIN JobTeams jteam ON jteam.Id = jt.JobTeamId
) AS posn ON posn.CandidateProfileInformationId = cp.Id