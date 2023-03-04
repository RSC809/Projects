/*

Cleaning Data in SQL Queries

*/

--Looking at the data
SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------

--Standarize Date Format
--Data sometimes updloads incorrectly into SQL
--If thats you case run the following query to remove timestamp
--Alternatively, you can run the following:
-- ALTER TABLE NashvilleHousing
-- ADD SaleDateConverted Date;
--UPDATE NashvilleHousing
--SET SaleDateConverted = CONVERT(Date, SaleDate)
SELECT SaleDate, CONVERT(Date, SaleDate)
FROM PortfolioProject..NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-------------------------------------------------------------------

--Populate Property Address data
--Showing the data
SELECT *
FROM PortfolioProject..NashvilleHousing
ORDER BY ParcelID


SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing
WHERE PropertyAddress IS NULL

--In order to fill out the NULLs or blanks we look for references.
--For this case we can use ParcelID and JOIN function 
--We use aliases "a" and "b" to make the query shorter
--We JOIN the tables using the following condition: "AND a.UniqueID <> b.UniqueID"
--The Idea is to fill in al Nulls using the Parcel ID as refence 
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--Query for Fixing the NULL
--We use the function "ISNULL(a.PropertyAddress, b.PropertyAddress)"
SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

--UPDATE query with ISNULL(a.PropertyAddress, b.PropertyAddress)
UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioProject..NashvilleHousing AS a
JOIN PortfolioProject..NashvilleHousing AS b
    ON a.ParcelID = b.ParcelID
    AND a.UniqueID <> b.UniqueID
WHERE a.PropertyAddress IS NULL

-------------------------------------------------------------------

--Splitting Address text into Individual Columns (Adress, City, State)
--City and Address are concadenated
SELECT PropertyAddress
FROM PortfolioProject..NashvilleHousing

--City and Address are concadenated
--To fix it we use SUBSTRING function
--And CHARINDEX to lookup an specific value or text
--In this case we look for the comma, ",", and include "-1" to exclude the comma in the first part of the address.
--To return the city we using the following: "SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))"
SELECT
  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) AS Address,
  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress)) AS Address2
FROM PortfolioProject..NashvilleHousing;

--Query to UPDATE the columns
ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitAddress =  SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET PropertySplitCity =  SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, LEN(PropertyAddress))

--Look at the new table
--Note we kept the original Property Adress and added to new columns
SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------

--As before City and Address are concadenated
--To fix it will use the PARSENAME function this time
--NOTE since PARSENAM function workds only with period
--we must REPLACE the comma, ",", in the address to make it work
--We may use a nested function execute
SELECT OwnerAddress
FROM PortfolioProject..NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2),
PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)
FROM PortfolioProject..NashvilleHousing

--Query to UPDATE the columns
ALTER TABLE NashvilleHousing
ADD OwnerSplitAdress Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAdress = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,3)

ALTER TABLE NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,2)

ALTER TABLE NashvilleHousing
ADD OwnerSplitAdressState Nvarchar(255);

UPDATE NashvilleHousing
SET OwnerSplitAdressState = PARSENAME(REPLACE(OwnerAddress, ',', '.') ,1)

--Look at the new table
--Note we kept the original Owner Address and added to new columns
SELECT *
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------
--Change Y and N to Yes and No in "Sold as Vacant" field
--With this query you can se the count misspells of Y and N
SELECT DISTINCT(SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioProject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

--To make the changes will be using statements CASE, THEN, ELSE END
SELECT SoldAsVacant,
CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No' 
     ELSE SoldAsVacant
     END
FROM PortfolioProject..NashvilleHousing

--Query to UPDATE the columns
UPDATE NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
     WHEN SoldAsVacant = 'N' THEN 'No' 
     ELSE SoldAsVacant
     END
FROM PortfolioProject..NashvilleHousing

-------------------------------------------------------------------

--Identify Duplicates
--To find duplicates we use the ROW_NUMBER statement along with PARTITION
--ALONG With a CTE or WITH function
WITH RowNumCTE AS
(
SELECT *,
    ROW_NUMBER() OVER 
    (
        PARTITION by ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY
        UniqueID
    ) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

--To Remove the duplicates. We only need to change the SELECT statement
--and use DELETE instead
WITH RowNumCTE AS
(
SELECT *,
    ROW_NUMBER() OVER 
    (
        PARTITION by ParcelID,
        PropertyAddress,
        SalePrice,
        SaleDate,
        LegalReference
        ORDER BY
        UniqueID
    ) row_num
FROM PortfolioProject..NashvilleHousing
--ORDER BY ParcelID
)
DELETE --ONLY CHANGE NEEDED
FROM RowNumCTE
WHERE row_num > 1

-------------------------------------------------------------------

--DELETE Unused Columns
SELECT *
FROM PortfolioProject..NashvilleHousing

ALTER TABLE PortfolioProject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

-------------------------------------------------------------------
