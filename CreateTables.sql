/*
 * База данных «Учет подписки на периодические печатные издания»
 *
 * База данных должна включать как минимум таблицы ИЗДАНИЯ, ПОДПИСЧИКИ, 
 * ДОСТАВКИ, содержащие следующую информацию:
 *     • Фамилия подписчика
 *     • Имя подписчика
 *     • Отчество подписчика
 *     • Номер паспорта подписчика
 *     • Улица
 *     • Номер дома
 *     • Номер квартиры
 *     • Индекс издания по каталогу
 *     • Вид издания (газета, журнал, каталог, …)
 *     • Наименование (название) издания
 *     • Цена 1 экземпляра
 *     • Дата начала подписки
 *     • Срок подписки (количество месяцев)
 *
 */

print(N'*** Старт скрипта создание таблиц базы данных ***' + char(13));

-- при повторном запуске скрипта удаляем старые варианты таблиц, не разбирая пустые они или нет
-- таблицы удаляем в порядке, обратном порядку создания
print(N'    Удаление предыдущих версий таблиц базы данных');
drop table if exists Deliveries;
drop table if exists Subscribers;
drop table if exists Publications;
drop table if exists Streets;
drop table if exists PubTypes;
print('    OK' + char(13));

-- виды изданий
print(N'    Создание таблицы справочника ВИДЫ ИЗДАНИЙ');
create table PubTypes (
	Id          int          not null primary key identity (1, 1),
	[Name]      nvarchar(30) not null    -- название типа издания
);
print('    OK' + char(13));
go

-- названия улиц
print(N'    Создание таблицы справочника НАЗВАНИЯ УЛИЦ');
create table Streets (
	Id          int          not null primary key identity (1, 1),
	[Name]      nvarchar(30) not null    -- название улицы
);
print('    OK' + char(13));
go

-- издания
print(N'    Создание таблицы справочника ИЗДАНИЯ');
create table Publications (
    Id          int          not null primary key identity (1, 1),
	IdPubType   int          not null,  -- вид издания
    PubIndex    nvarchar(12) not null,  -- индекс издания по каталогу
    Title       nvarchar(80) not null,  -- наименование (название) издания
    Price       int          not null,  -- цена 1 экземпляра

	-- ограничение на цену 1 экземпляра
	constraint CK_Publications_Price check (Price > 0),

	-- внешний ключ - связь M:1 к таблице PubTypes
	constraint FK_Publications_PubTypes foreign key (IdPubType) references dbo.PubTypes(Id)
);
print('    OK' + char(13));
go

-- подписчики
print(N'    Создание таблицы справочника ПОДПИСЧИКИ');
create table Subscribers (
	Id          int          not null primary key identity (1, 1),
	Surname     nvarchar(60) not null,    -- Фамилия подписчика
	[Name]      nvarchar(50) not null,    -- Имя подписчика
	Patronymic  nvarchar(60) not null,    -- Отчество подписчика
	Passport    nvarchar(15) not null,    -- Серия и номер подписчика
	IdStreet    int          not null,    -- улица
	Building    nvarchar(10) not null,    -- номер дома
	Flat        int          not null,    -- номер квартиры, 0 для частного сектора

	-- ограничение на номер квартиры
	constraint CK_Subscribers_Flat check (Flat >= 0),

	-- внешний ключ - связь 1:M к таблице Streets
	constraint FK_Subscribers_Streets foreign key (IdStreet) references dbo.Streets(Id)
);
print('    OK' + char(13));
go

-- доставки
print(N'    Создание таблицы регистра ДОСТАВКИ');
create table Deliveries (
    Id            int  not null primary key identity (1, 1),  
	IdSubscriber  int  not null,   -- кто подписался / кому доставлять издания
	IdPublication int  not null,   -- на какое издание / что доставлять
	DateStart     date not null,   -- начиная с какой даты
	Duration      int  not null,   -- длительность подписки, на какое количество месяцев

	-- ограничение на длительность подписки - от 1 до 12 месяцев
	constraint CK_Deliveries_Duration check (Duration between 1 and 12),

	-- внешний ключ - связь M:1 к таблице Subscribers
	constraint FK_Deliveries_Subscribers foreign key (IdSubscriber) references dbo.Subscribers(Id),

	-- внешний ключ - связь M:1 к таблице Publications
	constraint FK_Deliveries_Publications foreign key (IdPublication) references dbo.Publications(Id),
);
print('    OK' + char(13));
go

print(N'*** Финиш скрипта *** ');
