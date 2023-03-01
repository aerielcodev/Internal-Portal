SELECT
    *
FROM 
(
    SELECT
        jd.StatusChangeDate,
        jd.JobOpeningPositionId,
        jo.Id AS jobOpeningId,
        jon.Number AS jobOpeningNumber,
        js.Name AS JoName
    FROM JobOpeningNumbers jon
    INNER JOIN JobOpeningPositions jop ON jop.JobOpeningNumberId = jon.Id
    INNER JOIN JobOpeningPositionStatusChangeDates jd ON jop.Id = jd.JobOpeningPositionId
    INNER JOIN JobOpeningStatuses js ON js.Id = jd.JobOpeningStatusId
    INNER JOIN JobOpenings jo ON jo.Id = jop.JobOpeningId
) AS src
PIVOT
(
    MAX(StatusChangeDate)
    FOR JoName IN ([Developing],[Verified],[Candidates Presented],[Interviewing],[Candidate Selected],
    [Service Order Signed],[Waiting for Onboarding],[Filled],[Cancelled],[Closed])
) AS pivot_table
