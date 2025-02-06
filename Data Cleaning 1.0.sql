/*

Cleaning Data in SQL Queries

*/


Select *
From dbo.NashvilleHousing

--------------------------------------------------------------------------------------------------------------------------

-- Standardize Date Format

Select SaleDate, try_CONVERT(date, SaleDate, 107) -- it's not working,  so we use try_parse
From dbo.NashvilleHousing

alter table dbo.NashvilleHousing add SaleDateConverted date;

select SaleDate, try_parse(SaleDate as date using 'en-US' ) from  dbo.NashvilleHousing 

UPDATE dbo.NashvilleHousing set SaleDateConverted = try_parse(SaleDate as DATE using 'en-US') 

select SaleDate, SaleDateConverted from dbo.NashvilleHousing


--------------------------------------------------------------------------------------------------------------------------

-- Populate Property Address data

Select *
From dbo.NashvilleHousing
where PropertyAddress is null

select a.PropertyAddress, a.ParcelID, b.PropertyAddress, b.ParcelID, NULLIF(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

UPDATE a
SET PropertyAddress = NULLIF(a.PropertyAddress, b.PropertyAddress)
from dbo.NashvilleHousing a 
JOIN dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

--------------------------------------------------------------------------------------------------------------------------

-- Breaking out Address into Individual Colums (Address, City, State)

Select PropertyAddress
From dbo.NashvilleHousing


select SUBSTRING(PropertyAddress,1, CHARINDEX(',', PropertyAddress) -1) as Address,           -- it's not working for me 
SUBSTRING(PropertyAddress,CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as State 
from dbo.NashvilleHousing


SELECT																						   -- so I use this one
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 
        THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
        ELSE PropertyAddress  
    END AS Address,
	CASE
		 WHEN CHARINDEX(',', PropertyAddress) > 0 
		 THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
		 ELSE NULL
	END AS City
FROM dbo.NashvilleHousing;


ALTER TABLE dbo.NashvilleHousing ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing SET PropertySplitAddress = 																				   -- so I use this one
    CASE 
        WHEN CHARINDEX(',', PropertyAddress) > 0 
        THEN SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) 
        ELSE PropertyAddress  
    END ;
	
	

ALTER TABLE dbo.NashvilleHousing ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing SET PropertySplitCity = 																				   -- so I use this one
    CASE
		 WHEN CHARINDEX(',', PropertyAddress) > 0 
		 THEN SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))
		 ELSE NULL
    END;




SELECT 
	PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)
	,PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)
FROM dbo.NashvilleHousing
	
ALTER TABLE dbo.NashvilleHousing ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),2)

ALTER TABLE dbo.NashvilleHousing ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),3)

ALTER TABLE dbo.NashvilleHousing ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),1)





--------------------------------------------------------------------------------------------------------------------------

-- Change Y and N to Yes and No in "Sold as vacant" field

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from dbo.NashvilleHousing
group by SoldAsVacant
order by 2


select 
	case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		when SoldAsVacant in ('Yes','No') then SoldAsVacant
		else null
	end
	FROM dbo.NashvilleHousing;

UPDATE dbo.NashvilleHousing SET SoldAsVacant = 
case 
		when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		when SoldAsVacant in ('Yes','No') then SoldAsVacant
		else null
	end;


--------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates




WITH RowNumCTE AS (
    SELECT *, 
           ROW_NUMBER() OVER (
               PARTITION BY ParcelID, SalePrice, LegalReference, OwnerName
               ORDER BY UniqueID
           ) AS rownum
    FROM dbo.NashvilleHousing
) 
Select *
FROM RowNumCTE 
WHERE rownum > 1;



--------------------------------------------------------------------------------------------------------------------------

-- Remove Unused Columns

select * from dbo.NashvilleHousing

ALTER TABLE dbo.NashvilleHousing DROP COLUMN SaleDate;