-- Data Cleaning
-------------------------------------------------------------------------------------------------
select * from Portfolio_project..nashville

select SaleDate from Portfolio_project..nashville

--Standardize Date format [from the current DateTime]

Select SaleDATe, CONVERT (Date, SALEDATE) as DateConverted
from Portfolio_project..nashville

alter table nashville
add DateConverted date
Update Portfolio_project..nashville
set DateConverted = CONVERT (Date, SALEDATE)

-- SELF-JOIN to get rid of NULL in PropertyAddress

select PropertyAddress from nashville
where PropertyAddress is null

select * from nashville a
join nashville b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null
--------------------------------------------------------------------------------------------------------------

-- Populate Property Address Areas Using ISNULL

select a.ParcelID, b.ParcelID, a.PropertyAddress, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashville a
join nashville b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from nashville a
join nashville b
on a.ParcelID=b.ParcelID and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

select * from Portfolio_project..nashville

-- Break PropertyAddress into individual columns (Address, City) Using Sub-string

select substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1)
from Portfolio_project..nashville

select substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1) as Address,
substring(PropertyAddress, charindex(',',PropertyAddress) +1, LEN(PropertyAddress)) as City
from Portfolio_project..nashville

alter table nashville
add Property_Address nvarchar (255)
alter table nashville
add Property_City nvarchar (255)

update nashville
set Property_Address = substring(PropertyAddress, 1, charindex(',',PropertyAddress) -1)
update nashville
set Property_City = substring(PropertyAddress, charindex(',',PropertyAddress) +1, LEN(PropertyAddress))

--Break OwnerAddress into individual columns (OwnerAdddress, City, State) Using ParseName

select Reverse(PARSENAME(Replace(Reverse(OwnerAddress), ',', '.'), 1)) as Address
, Reverse(PARSENAME(Replace(Reverse(OwnerAddress), ',', '.'), 2)) as City
, Reverse(PARSENAME(Replace(Reverse(OwnerAddress), ',', '.'), 3)) as State
from portfolio_project..nashville

alter table nashville
add Owner_Address nvarchar (255)
alter table nashville
add Owner_City nvarchar (255)
alter table nashville
add Owner_State nvarchar (255)

update nashville
set Owner_Address = Reverse(PARSENAME(Replace(Reverse(OwnerAddress), ',', '.'), 1)) 
update nashville
set Owner_City = Reverse(PARSENAME(Replace(Reverse(OwnerAddress), ',', '.'), 2)) 
update nashville
set Owner_State = Reverse(PARSENAME(Replace(Reverse(OwnerAddress), ',', '.'), 3))
select * from nashville

--Break out OwnerName into individual columns (FirstName, LastName)

select Reverse(PARSENAME(Replace(Reverse(OwnerName), ',', '.'), 1)) as FirstName
, Reverse(PARSENAME(Replace(Reverse(OwnerName), ',', '.'), 2)) as MiddleName
, Reverse(PARSENAME(Replace(Reverse(OwnerName), '&', '.'), 3)) LastName
from portfolio_project..nashville

select distinct(SoldAsVacant), COUNT(SoldAsVacant)
from Portfolio_project.dbo.nashville
group by SoldAsVacant
order by 2

--Alter 'SoldAsVacant' : change Y and N to 'Yes' and 'No'

select SoldAsVacant
, Case when SoldAsVacant ='Y' Then 'Yes'
 when SoldAsVacant ='N' Then 'No'
 else SoldAsVacant
 End
from nashville

update nashville
set SoldAsVacant = Case when SoldAsVacant ='Y' Then 'Yes' when SoldAsVacant ='N' Then 'No'
 else SoldAsVacant
 End
---------------------------------------------------------------------------------------------------------------------------------
-- Delete Duplicates
select * ,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) 
				 row_num
from Portfolio_project..nashville
Order by ParcelID

-- Using CTE

With Row_NumCTE AS (
select * ,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) 
				 row_num
from Portfolio_project..nashville
)
select *
from Row_NumCTE
where row_num > 1
order by 1, 2, 3

-- Delete duplicate values and columns
 With Row_NumCTE AS (
select * ,
	row_number() over (
	partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 Order by UniqueID
				 ) 
				 row_num
from Portfolio_project..nashville
)
Delete
from Row_NumCTE
where row_num > 1

alter table nashville
drop column OwnerAddress, PropertyAddress, SaleDate
 
 select * from nashville

 ----------------------- E N D -------------------------------------------------------------------------------------------