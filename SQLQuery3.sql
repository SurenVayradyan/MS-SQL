
-----------------------------------------------------------ПЕРВОЕ------ВТОРОЕ-------ТРЕТЬЕ-------ЗАДАНИЕ-------------------------
USE [suren]
GO
ALTER DATABASE [suren] SET COMPATIBILITY_LEVEL = 130

SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE sp_report_1
    @date_from date,
    @date_to date,
    @good_group_name nvarchar(MAX)
	
AS
BEGIN
    
    declare @date_from_int int
    declare @date_to_int int

    set @date_from_int = (select top 1 did from date where d = @date_from )
    set @date_to_int = (select top 1 did from date where d = @date_to )

select 
	   group_name as [Группа товаров]
	  ,sum(cheque.sale_grs) as [Продажи руб., с НДС]
	  ,sum(quantity) as [Продажи шт.]
	  ,(sum(cheque.cost_net)/NULLIF(sum(cheque.quantity),0)) as [Средняя цена закупки руб., без НДС]
	  ,(sum(cheque.sale_net)-sum(cheque.cost_net)) as [Маржа руб. без НДС]
	  ,((sum(cheque.sale_net)-sum(cheque.cost_net))/(NULLIF(sum(cheque.cost_net),0))*100) as [Наценка % без НДС]

from cheque 
	inner join goods on goods.good_id = cheque.good_id
	inner join date  on cheque.date_id = date.did
	join  STRING_SPLIT(@good_group_name,',') s on group_name = trim(s.value)
	
where date_id between @date_from_int and @date_to_int

group by 
group_name
        
END

exec sp_report_1 '2017-06-01', '2017-06-30', 'Биологически активные добавки, Косметические средства'

-- 1 783 203.83 руб. 6763.10 шт. получилось, а у них 1 782 949.10 руб. 6761.10 шт. Биологически активные добавки - первое задание 
 

--------------------------------------------------------------------ЧЕТВЕРТОЕ ЗАДАНИЕ--------------------------------------


GO
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
 
ALTER PROCEDURE sp_report_1
    @date_from date,
    @date_to date,
    @good_group_name nvarchar(MAX)
	
AS
BEGIN
            
    declare @date_from_int int
    declare @date_to_int int
    
    set @date_from_int = (select top 1 did from date where d = @date_from )
    set @date_to_int = (select top 1 did from date where d = @date_to )
       
	select 
		   date.d as [Дата]
		  ,store_name as [Аптека]
		  ,g.group_name as [Группа товара]
		  ,g.good_name as [Номенклатура]
		  ,sum(cheque.sale_grs) as [Продажи руб., с НДС]

	from cheque
		inner join date
        on date.did=cheque.date_id
        inner join (SELECT DISTINCT good_id, good_name, group_id, group_name
		from goods) as g
		on cheque.good_id=g.good_id
        inner join stores
        on stores.store_id=cheque.store_id
	    
	where date_id between @date_from_int and @date_to_int
        and group_name=@good_group_name

	group by  
		  date.d,
		  store_name, 
          g.group_name,
          g.good_name,
		  cheque.sale_grs

	order by 
		  cheque.sale_grs DESC
END

exec sp_report_1 '2017-06-01', '2017-06-30', 'Косметические средства' -- сюда пишем любой товар по которому надо узнать долю продаж с ндс




