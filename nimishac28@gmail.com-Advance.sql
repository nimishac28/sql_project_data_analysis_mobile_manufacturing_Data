--SQL Advance Case Study


--Q1--BEGIN 

select distinct l.State from FACT_TRANSACTIONS t
full join DIM_LOCATION l
on t.IDLocation=l.IDLocation
where year(date)>= 2005	


--Q1--END

--Q2--BEGIN

select top(1) l.State from DIM_LOCATION l
full join FACT_TRANSACTIONS t
on l.IDLocation= t.IDLocation
full join DIM_MODEL m
on t.IDModel=m.IDModel
full join DIM_MANUFACTURER Mn
on m.IDManufacturer= Mn.IDManufacturer
where Mn.Manufacturer_Name= 'Samsung' and l.Country= 'US'
group by l.State
order by sum(t.Quantity) desc


--Q2--END

--Q3--BEGIN      
	
select count(*) as num_transaction,m.Model_Name, l.ZipCode, l.State from FACT_TRANSACTIONS ft
full join DIM_MODEL m
on ft.IDModel= m.IDModel
full join DIM_LOCATION l
on ft.IDLocation=l.IDLocation
group by l.ZipCode, l.State, m.Model_Name


--Q3--END

--Q4--BEGIN

select top(1) m.Model_Name, m.Unit_price from DIM_MODEL m
full join FACT_TRANSACTIONS ft
on m.IDModel=ft.IDModel
order by m.Unit_price 

--Q4--END

--Q5--BEGIN

select  Man.Manufacturer_Name, sum(ft.Quantity) as total_sales, round(avg(ft.totalprice),2) as Average_price
from FACT_TRANSACTIONS ft
full join DIM_MODEL m
on ft.IDModel=m.IDModel
full join DIM_MANUFACTURER Man
on Man.IDManufacturer=m.IDManufacturer
group by Man.Manufacturer_Name
order by avg(ft.totalprice)


--Q5--END

--Q6--BEGIN

select c.Customer_Name, avg(ft.totalprice) as Average_price from DIM_CUSTOMER C
full join FACT_TRANSACTIONS ft
on c.IDCustomer=ft.IDCustomer
where year(date)= 2009
group by c.Customer_Name
having avg(ft.totalprice)>500

--Q6--END
	
--Q7--BEGIN  
WITH CTE
AS
(
  SELECT
       RN = ROW_NUMBER() OVER(PARTITION BY YEAR([date]) ORDER BY sum(Quantity) DESC),
       m.Model_Name,
       MyYear = YEAR([date]),
       [sum] = sum(Quantity)
    FROM Fact_Transactions ft
	full join DIM_MODEL M
	on ft.IDModel=m.IDModel
       WHERE YEAR([date]) IN (2008,2009,2010)
       GROUP BY 
          m.Model_Name,
          YEAR([date])
)
SELECT
    Model_Name
    FROM CTE
       WHERE RN <6
          GROUP BY Model_Name
          HAVING COUNT(*)=3


--Q7--END	
--Q8--BEGIN

WITH CTEA
AS
(
select 
rn= row_number() over (partition by year([date]) order by sum(totalPrice) desc), 
Man.Manufacturer_Name,sum(totalPrice) as Total_sales, 
[year]=year(ft.date) 
from FACT_TRANSACTIONS ft
full join DIM_Model m
on m.IDModel=ft.IDModel
full join DIM_MANUFACTURER Man
on m.IDManufacturer=Man.IDManufacturer
where year(ft.date) in (2009, 2010) 
group by Man.Manufacturer_Name,year(ft.date)
)
select Manufacturer_Name, [year]
from CTEA
where rn= 2
group by Manufacturer_name,[year]

--Q8--END
--Q9--BEGIN
select Man.Manufacturer_Name from FACT_TRANSACTIONS ft
full join DIM_MODEL M
on ft.IDModel=M.IDModel
full join DIM_MANUFACTURER Man
on M.IDManufacturer=Man.IDManufacturer
where year(ft.date) in(2009, 2010)
group by MAn.Manufacturer_Name

except

select MAn.Manufacturer_Name from FACT_TRANSACTIONS ft
full join DIM_MODEL M
on ft.IDModel=M.IDModel
full join DIM_MANUFACTURER Man
on M.IDManufacturer=Man.IDManufacturer
where  year (ft.date) =2009
group by MAn.Manufacturer_Name	


--Q9--END

--Q10--BEGIN

 if OBJECT_ID('tempdb..#tc') is not null
 drop table #tc, #top100
 
select
rn=row_number() over( partition by year(ft.Date) order by avg(ft.totalprice) desc), 
C.Customer_Name,  avg(ft.TotalPrice) as avg_spend, avg(ft.Quantity) as avg_qty, year(ft.date) as[year]
into #tc
from DIM_CUSTOMER c
full join FACT_TRANSACTIONS ft
on c.IDCustomer=ft.IDCustomer
group by c.Customer_Name, year(ft.date)

select top 100 *
into #top100
from #tc

select
    t100.Customer_Name,
    t100.Year,
    t100.avg_spend,
    t100.rn,
    tc.Year as [Year_next],
    tc.avg_spend as Average_Spend_next,
    tc.rn as rn_next,
    percent_change= 100*((t100.avg_spend-tc.avg_spend)/tc.avg_spend)
from #top100 as t100
left join #tc as tc
    on t100.Customer_Name = tc.Customer_Name
    where tc.[YEAR] = t100.[YEAR] + 1


--Q10--END
	