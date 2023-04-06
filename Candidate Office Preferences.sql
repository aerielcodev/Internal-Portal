SELECT
        CandidatePreferredOfficeLocations.CandidateProfileInformationId,
        o.Location,
        c.Name
FROM CandidatePreferredOfficeLocations
LEFT JOIN Offices AS o ON o.Id = CandidatePreferredOfficeLocations.OfficeId
LEFT JOIN Countries c ON c.Id = o.CountryId