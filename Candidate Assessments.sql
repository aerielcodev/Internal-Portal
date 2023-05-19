SELECT    
    cp.Id AS CandidateProfileInformationId,
    ca.Report AS CodilityReport,
    ca.Score AS CodilityScore,
    ct.Score AS TrueNorthScore,
    cp.RecordedInterviewUrl  
FROM CandidateProfileInformations cp 
LEFT JOIN CandidateCodilityAssessments ca ON ca.CandidateProfileInformationId = cp.Id
LEFT JOIN CandidateTrueNorthAssessments ct ON ct.CandidateProfileInformationId = cp.Id
WHERE (cp.FirstName NOT LIKE '%demo%' AND cp.FirstName NOT LIKE '%test%' AND cp.LastName NOT LIKE '%demo%')
