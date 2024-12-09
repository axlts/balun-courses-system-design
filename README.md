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
- Сезонность: летом/зимой количество трафика может увеличиваться в 4 раза;
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

RPS = 10 000 000 * 0.133 / 86 400 = ~15.5
```

RPS (read posts):

```
one batch = 10 posts

RPS = 10 000 000 * 10 / 86 400 = ~1157.5
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

One post size (without media files):

```
3032B + 280B = 3312B
```

Traffic (write post):

```
traffic = ~15.5RPS * 3312B = 51 336B = ~51.3KBps
```

Traffic (read post):

```
traffic = ~1157.5RPS * 3312B = 3 833 640B = ~3,8MBps
```

#### Media

RPS (write media)

```
RPS = 10 000 000 * 5 / 86 400 = ~578.7
```

RPS (read media):

```
one batch = 10 posts

RPS = 10 000 000 * 5 * 10 / 86 400 = ~5787
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

Traffic (write media):

```
traffic = ~578.7RPS * 272B = 157 406B = ~157.4KBps
```

Traffic (read media):

```
traffic = ~5787RPS * 272B = 1 574 064B = ~1.6MBps
```

#### Reactions

##### Likes/Dislikes

RPS (write like/dislike):

```
RPS = 10 000 000 * 8 / 86 400 = ~926
```

RPS (read like/dislike):

```
get count of likes and dislikes 2 times for each post

RPS = 10 000 000 * 2 * 10 / 86 400 = ~2315
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
traffic = 926RPS * 33B = 30 558B = ~30.6KBps
```

Traffic (read like/dislike):

```
traffic = 2315RPS * 33B = 76 395B = ~76,5KBps
```

##### Comments

RPS (write comment):

```
RPS = 10 000 000 * 2 / 86 400 = ~231.5
```

RPS (read comment):

```
one batch = 5 comments

RPS = 10 000 000 * 5 * 10 / 86 400 = ~5787
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
traffic = 231.5RPS * 1032B = 238 908B = ~239KBps
```

Traffic (read comment):

```
traffic = 5787RPS * 1032B = 5 972 184B = ~6MBps
```

#### Locations

RPS (read top-10 locations):

```
one batch = 10 locations

RPS = 10 000 000 * 1 * 10 / 86 400 = ~1157
```

Traffic (read top-10 locations)

```
don't forget about likes

traffic = 1157RPS * (280B + 33B) = 362 141B = ~362KBps
```

RPS (read posts by locations):

```
one batch = 10 posts

RPS = 10 000 000 * 2 * 10 / 86 400 = ~2315
```

Traffic (read posts by locations):

```
traffic = 2315RPS * 4672B = 10 815 680B = ~10,8MBps
```
