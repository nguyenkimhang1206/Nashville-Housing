
select *
from nashville_housing
	
	
--Standardize Date Format (convert, cast)

Select saledate, cast (saledate as date) 
from nashville_housing

alter table nashville_housing
add saledateconverted date

update nashville_housing
set saledateconverted = cast (saledate as date)


--Populate property address data (isnull, coalesce)

SELECT a.parcelid, a.propertyaddress,b.parcelid, b.propertyaddress
,coalesce(a.propertyaddress,b.propertyaddress) 
from nashville_housing a
JOIN nashville_housing b
	ON a.parcelid = b.parcelid 
	AND a.uniqueid <> b.uniqueid
WHERE a.propertyaddress is null

UPDATE nashville_housing a
SET propertyaddress = coalesce(a.propertyaddress,b.propertyaddress)  
from nashville_housing b
WHERE a.parcelid = b.parcelid AND a.uniqueid <> b.uniqueid


--Breaking out address into Individual coulmns (address, city, State)

SELECT propertyaddress
from nashville_housing

SELECT 
split_part(propertyaddress,',',1) 
,split_part(propertyaddress,',',2) 
from nashville_housing

ALTER TABLE nashville_housing
ADD property_split_address varchar(255)

UPDATE nashville_housing
SET property_split_address = split_part(propertyaddress,',',1)

ALTER TABLE nashville_housing
ADD property_split_city varchar(255)

UPDATE nashville_housing
SET property_split_city = split_part(propertyaddress,',',2)


select owneraddress
,split_part(owneraddress,',',1) 
,split_part(owneraddress,',',2) 
,split_part(owneraddress,',',3)
from nashville_housing
where owneraddress is not null


ALTER TABLE nashville_housing
ADD owner_split_address varchar(255)

UPDATE nashville_housing
SET owner_split_address = split_part(owneraddress,',',1)

ALTER TABLE nashville_housing
ADD owner_split_city varchar(255)

UPDATE nashville_housing
SET owner_split_city = split_part(owneraddress,',',2)

ALTER TABLE nashville_housing
ADD owner_split_state varchar(255)

UPDATE nashville_housing
SET owner_split_state = split_part(owneraddress,',',3)


-- Change Y and N to Yes and No in "Sold as Vacant" field
	
select distinct soldasvacant, count(soldasvacant)
from nashville_housing
group by 1
order by 2

SELECT soldasvacant
,case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant 
		end 
from nashville_housing
	
UPDATE nashville_housing
SET soldasvacant = case when soldasvacant = 'Y' then 'Yes'
		when soldasvacant = 'N' then 'No'
		else soldasvacant 
		end 


-- Remove Duplicates
	
SELECT parcelid,
		propertyaddress,
		saleprice,
		saledate,
		legalreference, count (*)
FROM nashville_housing
GROUP BY 1,2,3,4,5
HAVING COUNT (*) > 1

DELETE FROM nashville_housing
WHERE ctid NOT IN
(
SELECT ctid
FROM
(
SELECT ctid,
ROW_NUMBER () OVER 
	(partition by parcelid,
					propertyaddress,
					saleprice,
					saledate,
					legalreference
	order by uniqueid) as row_num
from nashville_housing
)
WHERE row_num = 1)


-- Delete Unused Columns

ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


