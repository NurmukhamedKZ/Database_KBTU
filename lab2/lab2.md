# Подробный пересказ лекции: DDL в PostgreSQL

Лекция посвящена языку определения данных (DDL) в PostgreSQL: как создавать и удалять базы данных, табличные пространства и таблицы, как менять структуру таблиц и какие типы данных доступны.

## 1. Создание базы данных

**CREATE DATABASE** создаёт новую базу данных. Для этого нужно быть суперпользователем или иметь специальную привилегию `CREATEDB`.

Общий синтаксис:

```sql
CREATE DATABASE name
    [ [ WITH ] [ OWNER [=] user_name ]
               [ TEMPLATE [=] template ]
               [ ENCODING [=] encoding ]
               [ LC_COLLATE [=] lc_collate ]
               [ LC_CTYPE [=] lc_ctype ]
               [ TABLESPACE [=] tablespace_name ]
               [ ALLOW_CONNECTIONS [=] allowconn ]
               [ CONNECTION LIMIT [=] connlimit ]
               [ IS_TEMPLATE [=] istemplate ] ]
```

**Параметры:**
- `name` — имя создаваемой базы.
- `user_name` — роль владельца новой базы (или `DEFAULT`).
- `template` — шаблон, из которого создаётся база (или `DEFAULT`).
- `encoding` — кодировка символов.
- `lc_collate` — порядок сортировки (collation).
- `lc_ctype` — классификация символов.
- `tablespace_name` — табличное пространство, с которым связана база.
- `allow_conn` — если `false`, к базе никто не сможет подключиться.
- `conn_limit` — максимальное число одновременных подключений; значение по умолчанию `-1` означает «без ограничений».
- `istemplate` — если `true`, базу может клонировать любой пользователь с правом `CREATEDB`; если `false` (по умолчанию), то только суперпользователь или владелец базы.

**Примеры:**

```sql
CREATE DATABASE lusiadas;

CREATE DATABASE sales
    OWNER salesapp
    TABLESPACE salesspace;

CREATE DATABASE music
    LC_COLLATE 'sv_SE.utf8'
    LC_CTYPE 'sv_SE.utf8'
    TEMPLATE template0;

CREATE DATABASE music2
    LC_COLLATE 'sv_SE.iso885915'
    LC_CTYPE 'sv_SE.iso885915'
    ENCODING LATIN9
    TEMPLATE template0;
```

Первый пример — самая простая форма. Второй задаёт владельца и табличное пространство. Третий и четвёртый показывают настройку локали (шведской) и кодировки; в четвёртом используется кодировка LATIN9.

## 2. Табличные пространства (TABLESPACE)

Табличное пространство связывает объекты базы данных с конкретным каталогом на диске.

```sql
CREATE TABLESPACE tablespace_name
    [ OWNER { new_owner | CURRENT_USER | SESSION_USER } ]
    LOCATION 'directory'
    [ WITH ( tablespace_option = value [, ... ] ) ]
```

**Примеры:**

```sql
CREATE TABLESPACE fastspace
    LOCATION '/ssd1/postgresql/data';

CREATE TABLESPACE indexspace
    OWNER genevieve
    LOCATION '/data/indexes';
```

Первое пространство размещается на быстром SSD-диске, второе предназначено для индексов и принадлежит пользователю `genevieve`.

## 3. Удаление базы данных

```sql
DROP DATABASE [ IF EXISTS ] name
```

Команда удаляет записи о базе из системного каталога и **удаляет каталог с данными**. Выполнить её может только владелец базы. Опция `IF EXISTS` позволяет не получить ошибку, если базы не существует.

## 4. Что такое DDL

**DDL (Data Definition Language)** — стандарт команд, определяющих структуры в базе данных. DDL-операторы создают, изменяют и удаляют объекты БД: таблицы, индексы, пользователей. Основные команды — **CREATE**, **ALTER** и **DROP**.

## 5. Основы таблиц

- Таблица состоит из строк и столбцов.
- Число и порядок столбцов фиксированы, у каждого столбца есть имя.
- Число строк переменное.
- У каждого столбца есть тип данных.

## 6. Создание таблиц

**CREATE TABLE** создаёт новую пустую таблицу в текущей базе данных. Владельцем становится пользователь, выполнивший команду.

```sql
CREATE TABLE [ IF NOT EXISTS ] table_name (
  { column_name data_type [ COLLATE collation ] [ column_constraint [ ... ] ]
    | table_constraint
    | LIKE source_table [ like_option ... ] }
  [, ... ]
)
[ INHERITS ( parent_table [, ... ] ) ]
[ TABLESPACE tablespace_name ]
```

**Параметры:**
- `IF NOT EXISTS` — не выдавать ошибку, если отношение с таким именем уже есть.
- `table_name` — имя таблицы, при желании с указанием схемы.
- `column_name`, `data_type` — имя и тип столбца (тип может включать указание массива).
- `COLLATE` — задаёт правила сортировки для столбца (только для типов, поддерживающих collation).
- `INHERITS` — таблица автоматически наследует все столбцы родительских таблиц (обычных или внешних).
- `LIKE source_table` — копирует имена столбцов, их типы и ограничения `NOT NULL` из другой таблицы.
- `CONSTRAINT constraint_name` — необязательное имя ограничения (столбца или таблицы).
- `TABLESPACE` — табличное пространство, в котором создаётся таблица.

**Примеры:**

Таблица с именованным первичным ключом и ограничениями `NOT NULL`:
```sql
CREATE TABLE films (
    code        char(5) CONSTRAINT firstkey PRIMARY KEY,
    title       varchar(40) NOT NULL,
    did         integer NOT NULL,
    date_prod   date,
    kind        varchar(10),
    len         interval hour to minute
);
```

Та же таблица, но с ограничением уникальности на уровне таблицы:
```sql
CREATE TABLE films (
    code        char(5),
    title       varchar(40),
    did         integer,
    date_prod   date,
    kind        varchar(10),
    len         interval hour to minute,
    CONSTRAINT production UNIQUE(date_prod)
);
```

Столбец-массив (двумерный):
```sql
CREATE TABLE array_int (
    vector int[][]
);
```

Первичный ключ можно задать двумя равноценными способами: как ограничение таблицы или как ограничение столбца.
```sql
CREATE TABLE distributors (
    did     integer,
    name    varchar(40),
    PRIMARY KEY(did)
);

CREATE TABLE distributors (
    did     integer PRIMARY KEY,
    name    varchar(40)
);
```

Значения по умолчанию:
```sql
CREATE TABLE products (
    product_no integer,
    name text,
    price numeric DEFAULT 9.99
);
```
Если при вставке строки цена не указана, подставится 9.99.

## 7. Изменение таблиц

**ALTER TABLE** меняет определение существующей таблицы:

```sql
ALTER TABLE [ IF EXISTS ] [ ONLY ] name [ * ]
    action [, ... ]
```

**Основные действия:**
- `ADD COLUMN` — добавить столбец (синтаксис как в `CREATE TABLE`).
- `DROP COLUMN` — удалить столбец; индексы и ограничения таблицы, связанные с ним, удаляются автоматически.
- `SET DATA TYPE` / `TYPE` — изменить тип столбца.
- `SET / DROP DEFAULT` — установить или убрать значение по умолчанию.
- `SET / DROP NOT NULL` — запретить или разрешить `NULL` в столбце.
- `ADD table_constraint` — добавить ограничение таблицы.

**Примеры:**

```sql
ALTER TABLE distributors ADD COLUMN address varchar(30);

ALTER TABLE distributors DROP COLUMN address RESTRICT;

ALTER TABLE distributors
    ALTER COLUMN address TYPE varchar(80),
    ALTER COLUMN name TYPE varchar(100);

ALTER TABLE distributors
    ALTER COLUMN address SET DATA TYPE varchar(80),
    ALTER COLUMN name SET DATA TYPE varchar(100);
```

Последние два примера равнозначны: `TYPE` и `SET DATA TYPE` — синонимы. Кроме того, в одной команде можно выполнить несколько действий через запятую.

## 8. Удаление таблиц

```sql
DROP TABLE [ IF EXISTS ] name [, ...] [ CASCADE | RESTRICT ]
```

Удалять таблицу могут только её владелец, владелец схемы и суперпользователь.

- **CASCADE** — автоматически удаляет зависимые объекты (например, представления), а также все объекты, зависящие от них.
- **RESTRICT** — отказывает в удалении, если от таблицы что-то зависит. Это поведение **по умолчанию**.

Пример:
```sql
DROP TABLE films, distributors CASCADE;
```

## 9. Типы данных

В PostgreSQL богатый набор встроенных типов. Пользователи могут добавлять собственные с помощью `CREATE TYPE`. Основные группы: числовые, символьные, двоичные, дата/время, логический тип и массивы.

**Целые числа:**
| Тип | Размер | Диапазон |
|---|---|---|
| `smallint` | 2 байта | от −32 768 до +32 767 |
| `integer` | 4 байта | от −2 147 483 648 до +2 147 483 647 (типичный выбор) |
| `bigint` | 8 байт | от −9 223 372 036 854 775 808 до +9 223 372 036 854 775 807 |

**Числа с плавающей точкой** (переменная точность, неточные):
- `real` — 4 байта, около 6 десятичных цифр точности;
- `double` (в PostgreSQL полное название — `double precision`) — 8 байт, около 15 десятичных цифр.

**Serial-типы** (автоинкрементные целые):
- `smallserial` — 2 байта, значения от 1 до 32 767;
- `serial` — 4 байта, значения от 1 до 2 147 483 647.

**Символьные типы:**
- `varchar(n)` — строка переменной длины с ограничением;
- `char(n)` — строка фиксированной длины, дополняется пробелами;
- `text` — строка переменной длины без ограничения.

**Двоичные данные:**
- `bytea` — двоичная строка переменной длины.

**Дата и время:**
- `timestamp [(p)] [without time zone]` — дата и время без часового пояса (8 байт);
- `timestamp [(p)] with time zone` — дата и время с часовым поясом (8 байт);
- `date` — только дата (4 байта);
- `time [(p)] [without time zone]` — только время суток (8 байт);
- `time [(p)] with time zone` — время суток с часовым поясом (12 байт);
- `interval [fields] [(p)]` — интервал времени (16 байт).

**Логический тип:**
- `boolean` — 1 байт, значения «истина» или «ложь».

**Массивы** — столбец можно объявить массивом любого типа, например `int[][]`.

## Итог

Лекция последовательно проходит путь от создания «контейнера» (базы данных и табличных пространств) к созданию, изменению и удалению таблиц, а затем к типам данных, из которых строятся столбцы. Главные идеи: DDL описывает структуру, а не данные; все три основные команды (`CREATE`, `ALTER`, `DROP`) имеют опции для безопасной работы (`IF [NOT] EXISTS`, `RESTRICT`/`CASCADE`); а ограничения (`PRIMARY KEY`, `UNIQUE`, `NOT NULL`, `DEFAULT`) можно задавать как на уровне столбца, так и на уровне таблицы.
