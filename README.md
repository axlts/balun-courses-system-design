# Social Network - System Design

**Описание**: Разработка социальной сети для путешественников.

---

### Functional Requirements:

- Создание и публикация постов с текстом;
- Добавление нескольких фотографий к посту;
- Привязка локации к посту;
- Возможность ставить лайки/дизлайки на посты других пользователей;
- Комментирование постов других пользователей;
- Подписка на посты других пользователей;
- Формирования списка топ-10 популярных локаций за последнюю неделю, основываясь на кол-ве лайков;
- Просмотр списка популярных локаций;
- Поиск постов по локации;
- Просмотр ленты постов любого пользователя в обратном хронологическом порядке;
- Клиентами будут мобильные устройства и веб-приложения.

### Non-Functional Requirements:

- DAU = 10 000 000;
- Только страны СНГ;
- Активность пользователей (в среднем):
    - 4 поста в месяц;
    - 5 фотографий на пост;
    - 20 просмотренных постов в день;
    - 8 лайков и/или дизлайков в день;
    - 2 комментария в день;
    - 1 просмотр списка популярных локаций в день;
    - 2 поисковых запросов по локации в день.
- Сезонность: летом/зимой количество трафика может увеличиваться в 5-10 раз;
- Данные: храним всегда;
- Лимиты:
    - Постов на пользователя: 10 000;
    - Символов в посте: 3 000;
    - Изображений в посте: до 10, размер каждого не более 1 MB;
    - Локаций на пост: 1;
    - Лайков/дизлайков на посте: до 10 000 000;
    - Символов в комментарии: 1 000;
    - Комментариев под одним постом: до 100 000;
- Тайминги:
    - Публикация поста: до 1 секунды;
    - Лайк/дизлайк: до 500 мс;
    - Добавление комментария: до 1 секунды;
    - Получение ленты пользователя: до 2 секунд;
    - Поиск постов по локации: до 2 секунд;
    - Список популярных локаций: до 2 секунд.
- Доступность приложения: не менее 99.9%;
- Надежность: MTBF > 10 000 часов.

### System Load Calculations

#### Post

RPS (write post):

```
post per day
4 / 30 = ~0.133

RPS (without seasonality) = 10 000 000 * 0.133 / 86 400 = ~15.5
RPS (with seasonality)    = ~15 * 10 = ~155
```

RPS (read posts):

```
one batch = 10 posts

RPS (without seasonality) = 10 000 000 * 10 / 86 400 = ~1157.5
RPS (with seasonality)    = ~1157 * 10 = ~11575
```

Post model:

```
name         size
-----        -----
id           8B
created_at   8B
author_id    8B
text         text (max 3KB)
location_id  8B
-----        -----
total        3032B (max)
```

Location model:

```
name        size
-----       -----
id          8B
place_name  256B
latitude    8B
longitude   8B
-----       -----
total       280B
```

Attachment model:

```
name        size
-----       -----
id          8B
post_id     8B
url         256B
-----       -----
total       272B
```

One post size:

```
3032B + (272B * 5) + 280B = 4672B
```

Traffic (write post):

```
traffic (without seasonality) = ~15.5RPS * 4672B = 72 416B = ~72.5KBps
traffic (with seasonality)    = ~72.5KBps * 10 = ~725KBps
```

Traffic (read post):

```
traffic (without seasonality) = ~1157.5RPS * 4672B = 5 407 840 B = ~5,4MBps
traffic (with seasonality)    = ~5,4MBps * 10 = ~54MBps
```

#### Reactions

##### Likes/Dislikes

RPS (write like/dislike):

```
RPS (without seasonality) = 10 000 000 * 8 / 86 400 = ~926
RPS (with seasonality)    = ~926 * 10 = ~9260
```

RPS (read like/dislike):

```
get count of likes and dislikes 2 times for each post

RPS (without seasonality) = 10 000 000 * 2 * 10 / 86 400 = ~2315
RPS (with seasonality)    = ~2315 * 10 = ~23150
```

Likes/dislikes model:

```
name        size
-----       -----
id          8B
created_at  8B
post_id     8B
user_id     8B
is_like     1B
-----       -----
total       33B
```

Traffic (write like/dislike):

```
traffic (without seasonality) = 926RPS * 33B = 30 558B = ~30.5KBps
traffic (with seasonality)    = ~30.5KBps * 10 = ~305KBps
```

Traffic (read like/dislike):

```
traffic (without seasonality) = 2315RPS * 33B = 76 395B = ~76,5KBps
traffic (with seasonality)    = ~76,5KBps * 10 = ~765KBps
```

##### Comments

RPS (write comment):

```
RPS (without seasonality) = 10 000 000 * 2 / 86 400 = ~231.5
RPS (with seasonality)    = ~231.5 * 10 = ~2315
```

RPS (read comment):

```
one batch = 5 comments

RPS (without seasonality) = 10 000 000 * 5 * 10 / 86 400 = ~5787
RPS (with seasonality)    = ~5787 * 10 = ~57870
```

Comment model:

```
name        size
-----       -----
id          8B
created_at  8B
post_id     8B
user_id     8B
text        text (max 1KB)
-----       -----
total       1032B (max)
```

Traffic (write comment):

```
traffic (without seasonality) = 231.5RPS * 1032B = 238 908B = ~239KBps
traffic (with seasonality)    = ~239KBps * 10 = 238 908B = ~2.4MBps
```

Traffic (read comment):

```
traffic (without seasonality) = 5787RPS * 1032B = 5 972 184B = ~6MBps
traffic (with seasonality)    = ~6MBps * 10 = ~60MBps
```

#### Locations

RPS (read top-10 locations):

```
one batch = 10 locations

RPS (without seasonality) = 10 000 000 * 1 * 10 / 86 400 = ~1157
RPS (with seasonality)    = ~1157 * 10 = ~11570
```

Traffic (read top-10 locations)

```
don't forget about likes

traffic (without seasonality) = 1157RPS * (280B + 33B) = 362 141B = ~362KBps
traffic (with seasonality)    = ~362KBps * 10 = ~3,6MBps
```

RPS (read posts by locations):

```
one batch = 10 posts

RPS (without seasonality) = 10 000 000 * 2 * 10 / 86 400 = ~2315
RPS (with seasonality)    = ~2315 * 10 = ~23150
```

Traffic (read posts by locations):

```
traffic (without seasonality) = 2315RPS * 4672B = 10 815 680B = ~10,8MBps
traffic (with seasonality)    = ~10,8MBps * 10 = ~108MBps
```
