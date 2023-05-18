/*Standardize Date Format*/

select saledate, convert (str_to_date(saledate,"%d/%m/%Y"),date) as SaleDate from nashvillehousing;

update nashvillehousing
set saledate = convert (str_to_date(saledate,"%d/%m/%Y"),date);

/*Populate Address Data*/

update nashvillehousing
set PropertyAddress = if(PropertyAddress='', Null,PropertyAddress);

select t1.UniqueID, t1.ParcelID, t1.PropertyAddress, t2.ParcelID, t2.PropertyAddress,
		ifnull(t1.PropertyAddress,t2.PropertyAddress)
from nashvillehousing t1
	join nashvillehousing t2
    on t1.ParcelID = t2.ParcelID
    And t1.UniqueID <> t2.UniqueID
where t1.PropertyAddress is Null;

update nashvillehousing t1
	join nashvillehousing t2
		on t1.ParcelID = t2.ParcelID
			And t1.UniqueID <> t2.UniqueID
set t1.PropertyAddress = ifnull(t1.PropertyAddress,t2.PropertyAddress)
where t1.PropertyAddress is Null;

/*Property Address breaking into different columns (Address, city, state)*/

select PropertyAddress, 
	substring(PropertyAddress,1,locate(',',PropertyAddress)-1) Address,
    substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress)) city
from nashvillehousing;

Alter table nashvillehousing
add PropAddress nvarchar(255);

update nashvillehousing
set PropAddress = substring(PropertyAddress,1,locate(',',PropertyAddress)-1);

Alter table nashvillehousing
add PropCity nvarchar(255);

update nashvillehousing
set PropCity = substring(PropertyAddress,locate(',',PropertyAddress)+1,length(PropertyAddress));

select OwnerAddress,substring_index(OwnerAddress,',',1) as Address,
		substring_index(substring_index(OwnerAddress,',',2),',',-1) as City,
        substring_index(substring_index(OwnerAddress,',',3),',',-1) as State
from nashvillehousing;

Alter table nashvillehousing
add OwnerAddr nvarchar(255);

update nashvillehousing
set OwnerAddr = substring_index(OwnerAddress,',',1);

Alter table nashvillehousing
add OwnerCity nvarchar(255);

update nashvillehousing
set OwnerCity = substring_index(substring_index(OwnerAddress,',',2),',',-1);

Alter table nashvillehousing
add OwnerState nvarchar(255);

update nashvillehousing
set OwnerState = substring_index(substring_index(OwnerAddress,',',3),',',-1);

/*Convert Y or N to Yes or No */

Select distinct(SoldAsVacant), count(SoldAsVacant) 
from nashvillehousing
group by SoldAsVacant
order by 2;

Select distinct(SoldAsVacant), count(SoldAsVacant) ,
	Case when SoldAsVacant='Y' then 'Yes'
		when SoldAsVacant='N' then 'No'
		Else SoldAsVacant
	End
from nashvillehousing
group by SoldAsVacant
order by 2;

update nashvillehousing
set SoldAsVacant = Case when SoldAsVacant='Y' then 'Yes'
						when SoldAsVacant='N' then 'No'
						Else SoldAsVacant
					End;
                    
/* Remove Duplicates */

WITH CTE_RowNum as(
Select ParcelID, PropertyAddress, SaleDate, SalePrice, LegalReference,
	row_number() over(
		partition by ParcelID,
					PropertyAddress,
                    SaleDate,
                    SalePrice,
                    LegalReference
                    order by UniqueID
        )row_num
 from nashvillehousing)
 /*delete nh from nashvillehousing as nh
		join CTE_RowNum as cr
	on nh.ParcelID = cr.ParcelID
		and nh.PropertyAddress = cr.PropertyAddress
        and nh.SaleDate = cr.SaleDate
        and nh.SalePrice = cr.SalePrice
        and nh.LegalReference = cr.LegalReference
 where cr.row_num > 1;*/
 select * from CTE_RowNum
 where row_num > 1;
 
 /* Delete Unused column */
 
 Alter table nashvillehousing
 drop column PropertyAddress, 
 drop column OwnerAddress,
 drop column TaxDistrict;
 
 /* Giving row numbers */
 
 select row_number() over(
		order by UniqueID
        )row_num,
        UniqueID,
        OwnerName
  from nashvillehousing
  order by UniqueID;