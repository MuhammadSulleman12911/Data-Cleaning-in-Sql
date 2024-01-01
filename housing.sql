select * 
from project.dbo.[Nashville Housing]



--format date
select SaleDate, CONVERT(date, SaleDate) 
from project.dbo.[Nashville Housing] 

alter table [Nashville Housing]
add SaleDateConverted date;

update project.dbo.[Nashville Housing]
set SaleDateConverted = CONVERT(date, SaleDate)

select SaleDateConverted
from project.dbo.[Nashville Housing]



--populate property address by joinning table by itself
select  a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from project.dbo.[Nashville Housing] a
join project.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
where a.PropertyAddress is null 
and a.UniqueID <> b.UniqueID

update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress) 
from project.dbo.[Nashville Housing] a
join project.dbo.[Nashville Housing] b
on a.ParcelID = b.ParcelID
where a.PropertyAddress is null 
and a.UniqueID <> b.UniqueID



 
--split property address
--minus 1 remove comma at the end of substrin
--charindex defines delimiter where to break the column
select PropertyAddress, SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1) ,
--plus 1 remove comma at the start of new substring
SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)  +1, LEN(PropertyAddress))
from project.dbo.[Nashville Housing]

--this simple way to spilt column. parsename only works with dots so first you have to replace comma with dots
select PropertyAddress, 
parsename(replace (propertyaddress, ',', '.'), 2),
parsename(replace (propertyaddress, ',', '.'), 1)
from project.dbo.[Nashville Housing]



--add new coloumns
alter table project.dbo.[Nashville Housing]
add PropertyAddress1 Nvarchar(255); 

/*used to alter column 
ALTER TABLE project.dbo.[Nashville Housing]
ALTER COLUMN PropertyAddress1 NVARCHAR(255);*/

update project.dbo.[Nashville Housing]
set PropertyAddress1 = SUBSTRING(PropertyAddress, 1, CHARINDEX (',', PropertyAddress) -1)

alter table project.dbo.[Nashville Housing]
add PropertyAddress2 Nvarchar(255);

update project.dbo.[Nashville Housing]
set PropertyAddress2 = SUBSTRING(PropertyAddress, CHARINDEX (',', PropertyAddress)  +1, LEN(PropertyAddress))



--split owneraddress
select OwnerAddress, PARSENAME(replace( OwnerAddress, ',','.'), 3),
PARSENAME(replace( OwnerAddress, ',','.'), 2),
PARSENAME(replace( OwnerAddress, ',','.'), 1)
from  project.dbo.[Nashville Housing]




--add new coloumns
alter table project.dbo.[Nashville Housing]
add OwnerAddresss Nvarchar(255);

update project.dbo.[Nashville Housing]
set  OwnerAddresss= PARSENAME(replace( OwnerAddress, ',','.'), 3)


alter table project.dbo.[Nashville Housing]
add City Nvarchar(255);

update project.dbo.[Nashville Housing]
set City = PARSENAME(replace( OwnerAddress, ',','.'), 2)

alter table project.dbo.[Nashville Housing]
add State Nvarchar(255);

update project.dbo.[Nashville Housing]
set State = PARSENAME(replace( OwnerAddress, ',','.'), 1)


/*select SoldAsVacant, count(SoldAsVacant)
from project.dbo.[Nashville Housing] 
group by SoldAsVacant*/
/*alter table  project.dbo.[Nashville Housing]                                 
alter column soldasvacant varchar(255)*/

/*soldasvacant column has 0 and 1 values bits, that is converted to varchar to replace with yes and no
you can do that with both i and j method*/

--convert 0 and 1 as no and yes in soldasvacant column
select CAST(SoldAsVacant as varchar)                                                                    -------------j
from  project.dbo.[Nashville Housing]
update project.dbo.[Nashville Housing] 
set SoldAsVacant = CAST(SoldAsVacant as varchar)

/*--convert 0 and 1 as no and yes in soldasvacant column
select SoldAsVacant, case when SoldAsVacant = 0 then 'no' when SoldAsVacant = 1 then 'yes'              -------------i
else SoldAsVacant
end
from project.dbo.[Nashville Housing] 

update project.dbo.[Nashville Housing] 
set soldasvacant =  case when SoldAsVacant = 0 then 'no' when SoldAsVacant = 1 then 'yes'
else SoldAsVacant
end */




--remove duplicate
with rownumCTE as(
select *, ROW_NUMBER () over (
        partition by ParcelID,
                     LandUse,
					 PropertyAddress,
					 SalePrice,
					 LegalReference 
					 order by
					 uniqueid) as row_num
from project.dbo.[Nashville Housing]
)
/*check for duplicates
select * from rownumCTE
where row_num >1*/

delete 
from rownumCTE
where row_num >1




--remove unsued column
alter table project.dbo.[Nashville Housing]
drop column taxdistrict, propertyaddress, owneraddress, saledate


