-- Looking at the data
SELECT * 
FROM [PortfolioProject].[dbo].[fifa21_raw_data]

SELECT * 
FROM [PortfolioProject].[dbo].[fifa21_raw_data_v2]

-- Fifa21_raw_data cleaning tasks:
-- Removing unecessary columns photoUrl, playerUrl, Name (redundant) *
-- splitting Positions into first position second position, third position *
-- Splitting Team_contract into team and contract, 
-- Splitting Contract into start contract and end contract, end contract will take loan date values in case where its null *
-- Formatting into numeric Weight, Value, Wage, Release_Clause, W_F, SM, IR
-- Formatting into date start contract and end contract,
-- Create a woring table name fifa21_clean_data
-- Create a final table name fifa21_data

-- Creating new table, for the cleaning from fifa21_raw_data
SELECT *
INTO [PortfolioProject].[dbo].[fifa21_clean_data]
FROM [PortfolioProject].[dbo].[fifa21_raw_data]

-- Removing Irrelevant columns: photoUrl, playerUrl, Name
ALTER TABLE fifa21_clean_data
DROP COLUMN [photoUrl];

ALTER TABLE fifa21_clean_data
DROP COLUMN [playerUrl];

ALTER TABLE fifa21_clean_data
DROP COLUMN [Name];

-- Splitting Positions into Position Position1, Position2, Position3 
ALTER TABLE [PortfolioProject].[dbo].[fifa21_clean_data]
ADD Position1 VARCHAR(50),
    Position2 VARCHAR(50),
    Position3 VARCHAR(50)

UPDATE [PortfolioProject].[dbo].[fifa21_clean_data]
SET Position1 = SUBSTRING(Positions, 1, CHARINDEX(' ', Positions + ' ') - 1),
    Position2 = CASE 
                   WHEN LEN(Positions) - LEN(REPLACE(Positions, ' ', '')) >= 1 THEN 
                       SUBSTRING(Positions, CHARINDEX(' ', Positions + ' ') + 1, CHARINDEX(' ', Positions + ' ', CHARINDEX(' ', Positions + ' ') + 1) - CHARINDEX(' ', Positions + ' ') - 1)
                   ELSE NULL
                END,
    Position3 = CASE 
                   WHEN LEN(Positions) - LEN(REPLACE(Positions, ' ', '')) = 2 THEN 
                       SUBSTRING(Positions, CHARINDEX(' ', Positions + ' ', CHARINDEX(' ', Positions + ' ') + 1) + 1, LEN(Positions))
                   ELSE NULL
                END


-- Extracting Team from Team_contract
SELECT Team_Contract,
    CASE 
        WHEN CHARINDEX(' 20', Team_Contract) > 0
            THEN SUBSTRING(Team_Contract, 5, CHARINDEX('20', Team_Contract) - 6)
        WHEN CHARINDEX(' 20', Team_Contract) = 0
            THEN SUBSTRING(Team_Contract, 3, LEN(Team_Contract)-4)
        ELSE ''
    END AS Team
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD Team Nvarchar(50);

UPDATE fifa21_clean_data
SET Team =  CASE 
        WHEN CHARINDEX(' 20', Team_Contract) > 0
            THEN SUBSTRING(Team_Contract, 5, CHARINDEX('20', Team_Contract) - 6)
        WHEN CHARINDEX(' 20', Team_Contract) = 0
            THEN SUBSTRING(Team_Contract, 3, LEN(Team_Contract)-4)
        ELSE ''
    END

SELECT Team_Contract, Loan_Date_End, Team -- Verifying changes. Team wasnt fully extract for case where Loan_Date_End isnt NA
FROM fifa21_clean_data
ORDER BY Loan_Date_End DESC

SELECT -- In order to fully extract Team from Team_Contract we need to take into account Loan_Date_End
    Start_Contract, 
    End_Contract, 
    Team_Contract, 
    CASE 
        WHEN Loan_Date_End != 'N/A' 
        THEN SUBSTRING(Team, 1, LEN(Team) - 8)
        ELSE Team 
    END AS Team
FROM 
    fifa21_clean_data
ORDER BY 
    Start_Contract DESC

UPDATE fifa21_clean_data
SET Team = CASE 
        WHEN Loan_Date_End != 'N/A' 
        THEN SUBSTRING(Team, 1, LEN(Team) - 8)
        ELSE Team 
    END

-- Extracting Contract from Team_contract
-- And adding Contract table
SELECT Team_Contract,
    CASE WHEN CHARINDEX(' 20', Team_Contract) > 0
         THEN SUBSTRING(Team_Contract, CHARINDEX('20', Team_Contract),11)
         ELSE ''
    END AS Contract
FROM fifa21_clean_data


ALTER TABLE fifa21_clean_data
ADD Contract Nvarchar(50);

UPDATE fifa21_clean_data
SET Contract =  CASE WHEN CHARINDEX(' 20', Team_Contract) > 0
         THEN SUBSTRING(Team_Contract, CHARINDEX('20', Team_Contract),11)
         ELSE ''
    END

-- Splitting contract into Start_Contract & End Contract
SELECT
    contract,
    LEFT(contract, 4) AS Start_Contract,
    RIGHT(contract, 4) AS End_Contract
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD Start_Contract NVARCHAR(50);

ALTER TABLE fifa21_clean_data
ADD End_Contract NVARCHAR(50);

UPDATE fifa21_clean_data
SET Start_Contract = LEFT(contract, 4)

UPDATE fifa21_clean_data
SET End_Contract = RIGHT(contract, 4)

-- Cleaning and Changing Format for End_Contract 
SELECT Start_Contract, End_Contract, Team_Contract, Loan_Date_End, Team
FROM fifa21_clean_data
ORDER BY Start_Contract DESC

SELECT 
    Start_Contract, 
    CASE WHEN End_Contract = 'Loa' THEN '' ELSE CONVERT(varchar, TRY_CONVERT(date, End_Contract), 101) END AS End_Contract, 
    Team_Contract, 
    Loan_Date_End, 
    Team
FROM fifa21_clean_data
ORDER BY Start_Contract DESC

UPDATE fifa21_clean_data
SET End_Contract = 
    CASE 
        WHEN End_Contract = 'Loa' THEN '' 
        WHEN End_Contract IS NULL THEN CONVERT(varchar, TRY_CONVERT(date, Loan_Date_End), 101)
        ELSE CONVERT(varchar, TRY_CONVERT(date, End_Contract), 101) 
    END

UPDATE fifa21_clean_data
SET End_Contract = NULL
WHERE YEAR(End_Contract) < 2000

--Cleaning and Changing Format for Start_Contract
SELECT 
    Start_Contract, 
    CONVERT(varchar, TRY_CONVERT(date, CASE WHEN End_Contract IS NULL THEN Loan_Date_End ELSE End_Contract END), 101) AS End_Contract, 
    Team_Contract, 
    Loan_Date_End, 
    Team
FROM fifa21_clean_data
ORDER BY Start_Contract DESC

UPDATE fifa21_clean_data
SET End_Contract = CONVERT(varchar, TRY_CONVERT(date, CASE WHEN End_Contract IS NULL THEN Loan_Date_End ELSE End_Contract END), 101)

SELECT Start_Contract, CAST(Start_contract AS DATE) 
FROM fifa21_clean_data

UPDATE fifa21_clean_data
SET Start_Contract = CAST(Start_contract AS DATE) 

UPDATE fifa21_clean_data
SET Start_Contract = NULL
WHERE YEAR(Start_Contract) < 2000

-- Removing lbs from Weight and Formatting as integer
SELECT Weight, REPLACE(Weight, 'lbs', '')
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD Weight_lbs int;

UPDATE fifa21_clean_data
SET Weight_lbs = REPLACE(Weight, 'lbs', '')

-- Removing Euro an M sign from Value and Formatting as Float
SELECT Value, REPLACE(REPLACE(Value, '€', ''), 'M', '')
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD Value_M_E VARCHAR(50);

UPDATE fifa21_clean_data
SET Value_M_E = REPLACE(REPLACE(Value, '€', ''), 'M', '')

SELECT Value_M_E = CAST(REPLACE(Value_M_E, ',', '') AS FLOAT)
FROM fifa21_clean_data
WHERE Value_M_E IS NOT NULL
AND TRY_CONVERT(FLOAT, REPLACE(Value_M_E, ',', '')) IS NOT NULL;

UPDATE fifa21_clean_data
SET Value_M_E = CAST(REPLACE(Value_M_E, ',', '') AS FLOAT)
WHERE Value_M_E IS NOT NULL
AND TRY_CONVERT(FLOAT, REPLACE(Value_M_E, ',', '')) IS NOT NULL;

SELECT Value_M_E, Value
FROM fifa21_clean_data
ORDER BY Value_M_E DESC

SELECT -- The transformation didnt work for cases where K was present instead of M as non numeric
    CASE 
        WHEN Value_M_E LIKE '%[^0-9.]%' 
        THEN CAST(SUBSTRING(Value_M_E, 1, LEN(Value_M_E)-1) AS DECIMAL(10,2))/1000
        ELSE CAST(Value_M_E AS DECIMAL(10,2))
    END AS Value_M_E,
    Value
FROM 
    fifa21_clean_data
ORDER BY 
    Value_M_E DESC

UPDATE fifa21_clean_data -- With this update values in K will take M formate
SET Value_M_E = CASE 
        WHEN Value_M_E LIKE '%[^0-9.]%' 
        THEN CAST(SUBSTRING(Value_M_E, 1, LEN(Value_M_E)-1) AS DECIMAL(10,2))/1000
        ELSE CAST(Value_M_E AS DECIMAL(10,2))
    END


-- Removing Euro an K sign from Wage and changing format
SELECT 
  CASE 
    WHEN CHARINDEX('K', Wage) > 0 
      THEN SUBSTRING(Wage, 2, CHARINDEX('K', Wage)-2)
    WHEN CHARINDEX('€', Wage) = 1
      THEN SUBSTRING(Wage, 2, LEN(Wage)-1)
    ELSE NULL 
  END,
  Wage
FROM 
  fifa21_clean_data;

ALTER TABLE fifa21_clean_data
ADD Wage_M_E FLOAT;

UPDATE fifa21_clean_data
SET Wage_M_E  = CASE 
    WHEN CHARINDEX('K', Wage) > 0 
      THEN SUBSTRING(Wage, 2, CHARINDEX('K', Wage)-2)
    WHEN CHARINDEX('€', Wage) = 1
      THEN SUBSTRING(Wage, 2, LEN(Wage)-1)
    ELSE NULL 
  END

SELECT Wage_M_E, CAST(Wage_M_E AS INT)
FROM fifa21_clean_data
ORDER BY Wage_M_E DESC

UPDATE fifa21_clean_data
SET Wage_M_E = CAST(Wage_M_E AS INT)

-- Removing Euro an M sign from Release_Clause
SELECT 
  CASE 
    WHEN CHARINDEX('M', Release_Clause) > 0 
      THEN SUBSTRING(Release_Clause, 2, CHARINDEX('M', Release_Clause)-2)
    WHEN CHARINDEX('€', Release_Clause) = 1
      THEN SUBSTRING(Release_Clause, 2, LEN(Release_Clause)-1)
    ELSE NULL 
  END,
  Release_Clause
FROM 
  fifa21_clean_data;

ALTER TABLE fifa21_clean_data
ADD Release_Clause_M_E VARCHAR(50);

UPDATE fifa21_clean_data
SET Release_Clause_M_E  = CASE 
    WHEN CHARINDEX('M', Release_Clause) > 0 
      THEN SUBSTRING(Release_Clause, 2, CHARINDEX('M', Release_Clause)-2)
    WHEN CHARINDEX('€', Release_Clause) = 1
      THEN SUBSTRING(Release_Clause, 2, LEN(Release_Clause)-1)
    ELSE NULL 
  END

-- Formatting Release Clause
SELECT Release_Clause_M_E, Release_Clause
FROM fifa21_clean_data
ORDER BY Release_Clause_M_E DESC

SELECT Release_Clause_M_E, LEFT(Release_Clause_M_E, LEN(Release_Clause_M_E) - 1)
FROM fifa21_clean_data
WHERE ISNUMERIC(Release_Clause_M_E) = 0
ORDER BY Release_Clause_M_E DESC

UPDATE fifa21_clean_data
SET Release_Clause_M_E = LEFT(Release_Clause_M_E, LEN(Release_Clause_M_E) - 1)
WHERE ISNUMERIC(Release_Clause_M_E) = 0

SELECT Release_Clause, -- Accounting for values with K instead of M
    CASE 
        WHEN Release_Clause LIKE '%K%' 
        THEN CAST(SUBSTRING(Release_Clause_M_E, 1, LEN(Value_M_E)-1) AS DECIMAL(10,2))/1000
        ELSE CAST(Release_Clause_M_E AS DECIMAL(10,2))
    END AS Release_Clause_M_E
FROM 
    fifa21_clean_data
ORDER BY 
    Release_Clause_M_E DESC

UPDATE fifa21_clean_data
SET Release_Clause_M_E = CASE 
        WHEN Release_Clause LIKE '%K%' 
        THEN CAST(SUBSTRING(Release_Clause_M_E, 1, LEN(Value_M_E)-1) AS DECIMAL(10,2))/1000
        ELSE CAST(Release_Clause_M_E AS DECIMAL(10,2))
    END

UPDATE fifa21_clean_data
SET Release_Clause_M_E = CAST(Release_Clause_M_E AS FLOAT)

-- Removing " *" sign from W_F
SELECT W_F, LEFT(W_F, 1)
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD W_F_new INT;

UPDATE fifa21_clean_data
SET W_F_new  = LEFT(W_F, 1)

-- Removing "*" sign SM
SELECT SM, LEFT(SM, 1)
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD SM_new INT;

UPDATE fifa21_clean_data
SET SM_new  = LEFT(SM, 1)

-- Removing " *" from IR
SELECT IR, LEFT(IR, 1)
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD IR_new INT;

UPDATE fifa21_clean_data
SET IR_new  = LEFT(IR, 1)

-- Removing first character from Hits
SELECT Hits, RIGHT(Hits, LEN(Hits)-1)
FROM fifa21_clean_data

ALTER TABLE fifa21_clean_data
ADD Hits_new VARCHAR(50);

UPDATE fifa21_clean_data
SET Hits_new  = RIGHT(Hits, LEN(Hits)-1)

--Formatting Hits_new as INT. 
SELECT Hits_new
FROM fifa21_clean_data
ORDER BY Hits_new 

SELECT Hits_new, LEFT(Hits_new, LEN(Hits_new) - 1)
FROM fifa21_clean_data
WHERE ISNUMERIC(Hits_new) = 0;

UPDATE fifa21_clean_data
SET Hits_new = LEFT(Hits_new, LEN(Hits_new) - 1)
WHERE ISNUMERIC(Hits_new) = 0;

UPDATE fifa21_clean_data
SET Hits_new = CAST(Hits_new AS FLOAT)

-- Formatting Loan_Date_End as Date
SELECT Loan_Date_End
FROM fifa21_clean_data
WHERE Loan_Date_End = 'N/A'

SELECT 
  CASE 
  WHEN Loan_Date_End = 'N/A' THEN ''
  ELSE CAST(Loan_Date_End AS DATE) 
  END AS Loan_Date_End_formatted
FROM fifa21_clean_data;

UPDATE fifa21_clean_data
SET Loan_Date_End = CASE 
  WHEN Loan_Date_End = 'N/A' THEN ''
  ELSE CAST(Loan_Date_End AS DATE) 
  END

UPDATE fifa21_clean_data
SET Loan_Date_End = NULL
WHERE YEAR(Loan_Date_End) < 2000

--NOTE Still the variable should be an INT but there are misspells or outliers

-- Creating final table, will be reorganizing and droping values from this final table
SELECT *
INTO [PortfolioProject].[dbo].[fifa21_data]
FROM [PortfolioProject].[dbo].[fifa21_clean_data]
































































