-- База данных «Учет подписки на периодические печатные издания»

-- вывод всех таблиц с рашифровкой полей связанных таблиц

-- справочник видов изданий
select
   Id
   , [Name] as PubType
from
    PubTypes;
go


-- справочник улиц
select
    Id
    , [Name] as Street
from
    Streets;
go


-- подписчики 
select
    Subscribers.Id
    , Subscribers.Surname
    , Subscribers.[Name]
    , Subscribers.Patronymic
    , Subscribers.Passport
    , Streets.[Name]         as Street
    , Subscribers.Building
    , Subscribers.Flat
from
    Subscribers join Streets on Subscribers.IdStreet = Streets.Id;
go


-- издания
select
    Publications.Id
    , PubTypes.[Name]        as PubType
    , Publications.PubIndex
    , Publications.Title
    , Publications.Price
from 
    Publications join PubTypes on Publications.IdPubType = PubTypes.Id;
go

-- доставки
select
    Deliveries.Id

    , PubTypes.[Name]       as PubType
    , Publications.PubIndex
    , Publications.Title
    , Publications.Price

    , Subscribers.Surname
    , Subscribers.[Name]
    , Subscribers.Patronymic
    , Subscribers.Passport
    , Streets.[Name]        as  Street
    , Subscribers.Building
    , Subscribers.Flat

    , Deliveries.DateStart
    , Deliveries.Duration
from
    Deliveries 
        join (Publications join PubTypes on Publications.IdPubType = PubTypes.Id) 
             on Deliveries.IdPublication = Publications.Id
        join (Subscribers join Streets on Subscribers.IdStreet = Streets.Id) 
             on Deliveries.IdSubscriber = Subscribers.Id;
go


-- Выполнение запросов по заданию

-- 01 Запрос с параметром	
-- Выбирает из таблицы ИЗДАНИЯ информацию о доступных для подписки изданиях 
-- заданного типа, стоимость 1 экземпляра для которых меньше заданной
declare @pubType nvarchar(30) = N'журнал', @price int = 250;

select
    Publications.Id
    , Publications.PubIndex
    , PubTypes.[Name]       as PubType
    , Publications.Title
    , Publications.Price
from 
    Publications join PubTypes on Publications.IdPubType = PubTypes.Id
where
    PubTypes.[Name] = @pubType and Publications.Price < @price
go


-- 02 Запрос с параметром	
-- Выбирает из таблиц информацию о подписчиках, проживающих на заданной 
-- параметром улице и номере дома, которые оформили подписку на издание 
-- с заданным параметром наименованием
declare @street nvarchar(30) = N'ул. Садовая', @building nvarchar(10) = '118', 
        @title nvarchar(80) = N'Юный техник';

select
    Deliveries.Id
    , Subscribers.Surname + ' ' + Substring(Subscribers.[Name], 1, 1) + '.' + Substring(Subscribers.Patronymic, 1, 1) + '.' as Subscriber 
    , Subscribers.Passport
    , Streets.[Name] + N',  д. ' + Subscribers.Building + N', кв. ' + LTrim(Str(Subscribers.Flat, 5)) as [Address] 
    , Publications.Title
from
    Deliveries join (Subscribers join Streets on Subscribers.IdStreet = Streets.Id) on Deliveries.IdSubscriber = Subscribers.Id
               join Publications on Deliveries.IdPublication = Publications.Id
where
    Streets.[Name] = @street and Subscribers.Building = @building and Publications.Title = @title;

select  -- с учетом вида издания
    Deliveries.Id
    , Subscribers.Surname + ' ' + Substring(Subscribers.[Name], 1, 1) + '.' + Substring(Subscribers.Patronymic, 1, 1) + '.' as Subscriber 
    , Subscribers.Passport
    , Streets.[Name] + N',  д. ' + Subscribers.Building + N', кв. ' + LTrim(Str(Subscribers.Flat, 5)) as [Address] 
    , PubTypes.[Name]   as PubType
    , Publications.Title
from
    Deliveries join (Subscribers join Streets on Subscribers.IdStreet = Streets.Id) 
                    on Deliveries.IdSubscriber = Subscribers.Id
               join (Publications join PubTypes on Publications.IdPubType = PubTypes.Id) 
                    on Deliveries.IdPublication = Publications.Id
where
    Streets.[Name] = @street and Subscribers.Building = @building and Publications.Title = @title;
go


-- 03 Запрос с параметром	
-- Выбирает из таблицы ИЗДАНИЯ информацию об изданиях, для которых значение
-- в поле Цена 1 экземпляра находится в заданном диапазоне значений
declare @loPrice int = 100, @hiPrice int = 150;

select
    Publications.Id
    , PubTypes.[Name]       as PubType
    , Publications.PubIndex
    , Publications.Title
    , Publications.Price
from 
    Publications join PubTypes on Publications.IdPubType = PubTypes.Id
where
    Publications.Price between @loPrice and @hiPrice;
go


-- 04 Запрос с параметром	
-- Выбирает из таблиц информацию о подписчиках, подписавшихся на заданный 
-- параметром тип издания
declare @pubType nvarchar(30) = N'журнал';

select distinct
    Subscribers.Surname + ' ' + Substring(Subscribers.[Name], 1, 1) + '.' + Substring(Subscribers.Patronymic, 1, 1) + N'.' as Subscriber 
    , Subscribers.Passport
    , Streets.[Name] + N',  д. ' + Subscribers.Building + N', кв. ' + LTrim(Str(Subscribers.Flat, 5)) as [Address] 
    , PubTypes.[Name] as PubType
from
    Deliveries join (Subscribers join Streets on Subscribers.IdStreet = Streets.Id) 
                    on Deliveries.IdSubscriber = Subscribers.Id
               join (Publications join PubTypes on Publications.IdPubType = PubTypes.Id) 
                    on Deliveries.IdPublication = Publications.Id
where
    PubTypes.[Name] = @pubType
order by
    Subscriber;
go


-- 05 Запрос с параметром	
-- Выбирает из таблиц ИЗДАНИЯ и ДОСТАВКИ информацию обо всех оформленных 
-- подписках, для которых срок подписки есть значение из некоторого диапазона. 
-- Нижняя и верхняя границы диапазона задаются при выполнении запроса
declare @loDuration int = 3, @hiDuration int = 4;

select
    Deliveries.Id
    , Deliveries.IdSubscriber
    , PubTypes.[Name]     as PubType
    , Publications.Title
    , Deliveries.Duration
    , Deliveries.DateStart
from
    Deliveries join (Publications join PubTypes on Publications.IdPubType = PubTypes.Id) 
                    on Deliveries.IdPublication = Publications.Id
where
    Deliveries.Duration between @loDuration and @hiDuration
order by
    IdSubscriber;

-- вывод запроса расширяем данными о подписчике
select
    Deliveries.Id
    , Subscribers.Surname + ' ' + Substring(Subscribers.[Name], 1, 1) + '.' + Substring(Subscribers.Patronymic, 1, 1) + '.' as Subscriber 
    , Subscribers.Passport
    , Streets.[Name] + N',  д. ' + Subscribers.Building + N', кв. ' + LTrim(Str(Subscribers.Flat, 5)) as [Address] 
    , PubTypes.[Name]      as PubType
    , Publications.Title
    , Deliveries.Duration
    , Deliveries.DateStart
from
    Deliveries join (Subscribers join Streets on Subscribers.IdStreet = Streets.Id) 
                    on Deliveries.IdSubscriber = Subscribers.Id
               join (Publications join PubTypes on Publications.IdPubType = PubTypes.Id) 
                    on Deliveries.IdPublication = Publications.Id
where
    Deliveries.Duration between @loDuration and @hiDuration
order by
    Subscriber;
go


-- 06 Запрос с вычисляемыми полями	
-- Вычисляет для каждой оформленной подписки ее стоимость с доставкой и без НДС 
-- Включает поля Индекс издания, Наименование издания, Цена 1 экземпляра, Дата 
-- начала подписки, Срок подписки, Стоимость подписки без НДС. Сортировка по 
-- полю Индекс издания
select
    Deliveries.Id
    , Publications.PubIndex
    , Publications.Title
    , Publications.Price
    , Deliveries.DateStart
    , Deliveries.Duration
    -- стоимость подписки с доставкой (1%) и без НДС 
    , 1.01 * (Publications.Price * Deliveries.Duration) as SubscribeCost
from
    Deliveries join (Publications join PubTypes on Publications.IdPubType = PubTypes.Id) 
                    on Deliveries.IdPublication = Publications.Id
order by
    Publications.PubIndex;
go


-- 07 Итоговый запрос	
-- Выполняет группировку по полю Вид издания. Для каждого вида вычисляет 
-- максимальную и минимальную цену 1 экземпляра
select
    PubTypes.[Name]           as PubType
    , Count(Publications.Id)  as TotalPubType
    , Max(Publications.Price) as MaxPrice
    , Min(Publications.Price) as MinPrice
from
    Publications join PubTypes on Publications.IdPubType = PubTypes.Id
group by
    PubTypes.[Name];

go


-- 08 Итоговый запрос с левым соединением	
-- Выполняет группировку по полю Улица. Для всех улиц вычисляет количество 
-- подписчиков, проживающих на данной улице (итоги по полю Код получателя)
select
    Streets.[Name]                   as Street
    , Count(Subscribers.Id) as SubscriberAmount
from
    Streets left join Subscribers  on Streets.Id = Subscribers.IdStreet
group by
    Streets.[Name]
order by
    SubscriberAmount desc;
go

-- 09 Итоговый запрос с левым соединением	
-- Для всех изданий выводит количество оформленных подписок
select
    Publications.Id
    , Publications.PubIndex
    , Publications.Title
    , PubTypes.[Name]
    , Count(Deliveries.Id) as DeliveriesAmount
from
    (Publications join PubTypes on PubTypes.Id = Publications.IdPubType) 
    left join 
    Deliveries on Publications.Id = Deliveries.IdPublication
group by
    Publications.Id, Publications.PubIndex, Publications.Title, PubTypes.[Name]
order by
   DeliveriesAmount desc;
go

-- 10 Запрос на создание базовой таблицы	
-- Создает таблицу ПОДПИСЧИКИ_ЖУРНАЛЫ, содержащую информацию о подписчиках 
-- изданий, имеющих вид «журнал»
-- удалить старый вариант таблицы Subscribers_Magazines
drop table if exists  Subscribers_Magazines; 

select distinct
    Subscribers.Id
    , Subscribers.Surname
    , Subscribers.[Name]
    , Subscribers.Patronymic
    , Subscribers.Passport
    , Subscribers.IdStreet
    , Subscribers.Building
    , Subscribers.Flat
    into Subscribers_Magazines
from
    Deliveries join Subscribers on Deliveries.IdSubscriber = Subscribers.Id
               join (Publications join PubTypes on Publications.IdPubType = PubTypes.Id) 
                    on Deliveries.IdPublication = Publications.Id
where
    PubTypes.[Name] = N'журнал';

-- показать выбранные в таблицу Subscribers_Magazines данные 
select * from Subscribers_Magazines;
go


-- 11 Запрос на создание базовой таблицы	
-- Создает копию таблицы ПОДПИСЧИКИ с именем КОПИЯ_ПОДПИСЧИКИ		
drop table if exists Copy_Subscribers; 

-- создать новый вариант таблицы Copy_Subscribers
-- !!! огранчения не копируются !!!
select
    *
    into Copy_Subscribers
from
    Subscribers;

-- показать выбранные в таблицу Copy_Subscribers данные 
select * from Copy_Subscribers;
go


-- 12 Запрос на удаление	
-- Удаляет из таблицы КОПИЯ_ПОДПИСЧИКИ записи, в которых значение в поле Улица 
-- равно «Ореховая»
-- показать таблицу Copy_Subscribers до удалания записей 
declare @street nvarchar(30)=N'ул. Ореховая', @idStreet int;

-- покажем улицы, которые есть в таблице-копии до удаления
select distinct
    Copy_Subscribers.Id
    , Streets.[Name]     as Street 
from 
    Copy_Subscribers join Streets on Copy_Subscribers.IdStreet = Streets.Id;

-- получить idStreet по заданию
select
    @idStreet = Id
from
    Streets
where
    [Name] = @street;

-- удаление по заданию
delete from 
    Copy_Subscribers
where
    Copy_Subscribers.IdStreet = @idStreet;    -- до изучения подзапросов  

-- показать таблицу Copy_Subscribers после удалания записей
select distinct
    Copy_Subscribers.Id
    , Streets.[Name]     as Street 
from 
    Copy_Subscribers join Streets on Copy_Subscribers.IdStreet = Streets.Id;
go


-- 13 Запрос на обновление	
-- Увеличивает значение в поле Цена 1 экземпляра таблицы ИЗДАНИЯ на заданное 
-- параметром количество процентов для изданий, заданного параметром вида издания
declare @percent float=10, @pubType nvarchar(30)=N'газета', @idPubType int;

-- выведем данные до изменения
select
    Publications.Title
    , Publications.Price
    , PubTypes.[Name]     as PubType
from
    Publications join PubTypes on Publications.IdPubType = PubTypes.Id
where
    PubTypes.[Name] = @pubType;

-- получить id вида издания
select @idPubType = Id from PubTypes where [Name] = @pubType;

-- выполнить модификацию цены для заданного вида издания
update 
    Publications
set
    Price *= ((100 + @percent)/100)
where
    Publications.IdPubType = @idPubType;

-- данные после изменения цены
select
    Publications.Title
    , Publications.Price
    , PubTypes.[Name]    as PubType
from
    Publications join PubTypes on Publications.IdPubType = PubTypes.Id
where
    PubTypes.[Name] = @pubType;
go    


-- 14 Запрос на обновление	
-- В таблице ДОСТАВКА увеличить срок подписки на заданное параметром количество
-- месяцев
declare @param int = 3;

-- вывод данных таблицы ДОСТАВКА до изменения
select
    Id
    , Duration
from
    Deliveries;

-- модификация данных по заданию, с учетом ограничений таблицы
update
    Deliveries
set
    Duration += @param
where
   Duration + @param <= 12;

-- вывод данных таблицы ДОСТАВКА после изменения
select
    Id
    , Duration
from
    Deliveries;
go
