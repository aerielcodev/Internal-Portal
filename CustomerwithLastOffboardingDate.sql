SELECT
    c.Id AS CustomerId,
    max(ce.DateEnd) AS maxEnd
FROM Customers c
JOIN CustomerEmployees ce ON ce.CustomerId = c.Id
GROUP BY c.Id