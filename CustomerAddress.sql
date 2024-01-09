SELECT
    cx.Id AS customerId,
    cx.CompanyName AS Customer,
    cx.StreetAddress AS 'Street Address',
    cx.City,
    cx.State,
    c.Name AS Country,
    cx.Zip,
    at.Name AS 'Address Type'
FROM Customers cx
LEFT JOIN States s ON s.Id = cx.StateId
LEFT JOIN Countries c ON c.Id = cx.CountryId
LEFT JOIN AddressTypes at ON at.Id = cx.AddressTypeId
