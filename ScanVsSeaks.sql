Use AdventureWorks2016CTP3

SELECT  e.BusinessEntityID,
        e.NationalIDNumber
FROM    HumanResources.Employee AS e
WHERE   e.NationalIDNumber = 112457891;


SELECT  e.BusinessEntityID,
        e.NationalIDNumber
FROM    HumanResources.Employee AS e
WHERE   e.NationalIDNumber = '112457891';