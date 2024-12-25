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

Notes:

- Disks:
    - Будем считать диски на год вперед;
    - Не берем HDD, если дисков слишком много, сложней будет поддерживать;

#### Posts

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
name           size
-----          -----
id             8B
created_at     8B
author_id      8B
text           text (max 3000)
location_id    8B
like_count     4B
dislike_count  4B
-----          -----
total          3040B (max)
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
3040B + 280B = 3320B
```

Traffic (write post):

```
traffic = ~15.5RPS * 3320B = 51 460B = ~51.5KBps
```

Traffic (read post):

```
traffic = ~1157.5RPS * 3320B = 3 842 900B = ~3,8MBps
```

Disks:

```
required capacity   = ~51.5KBps * 86 400 * 365 = 1 624 104 000KB = ~1.6TB
required throughput = ~51.5KBps + ~3.8MBps = ~3.9MBps
required iops       = ~15.5RPS + ~1157.5RPS = 1173RPS
```

HDD:

```
capacity   = ~1.6TB / (1 * 2TB) = 1 disk
throughput = ~3.9MBps / 100MBps = 1 disk
iops       = 1173RPS / 100 = 12 disks

count    = max(1, 1, 12) = 12
сapacity = ~1.6TB / 12 = ~133GB => 160GB

conclusion: need 12 HDDs with a capacity of 160GB
```

SSD(SATA):

```
capacity = ~1.6TB / (1 * 2TB) = 1 disk
throughput = ~3.9MBps / 500MBps = 1 disk
iops = 1173RPS / 1000 = 2 disks

count = max(1, 1, 2) = 2
сapacity = ~1.6TB / 2 = ~800GB => 1TB

conclusion: need 2 SSDs with a capacity of 1TB
```

Solution: 2 SSDs with a capacity of 1TB.

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

Disks:

```
required capacity   = ~157.4KBps * 86 400 * 365 = 4 963 766 400KB = ~5TB
required throughput = ~157.4KBps + ~1.6MBps = ~1.8MBps
required iops       = ~578.7RPS + ~5787RPS = ~6365.7RPS
```

HDD:

```
capacity   = ~5TB / (1 * 6TB) = 1 disk
throughput = ~1.8MBps / 100MBps = 1 disk
iops       = ~6365.7RPS / 100 = 64 disks

count    = max(1, 1, 64) = 64
capacity = ~5TB / 64 = ~78GB => 160GB

conclusion: need 64 HDDs with a capacity of 160GB
```

SSD(SATA):

```
capacity   = ~5TB / (1 * 6TB) = 1 disk
throughput = ~1.8MBps / 500MBps = 1 disk
iops       = ~6365.7RPS / 1000 = 7 disks

count    = max(1, 1, 7) = 7
capacity = ~5TB / 7 = ~714GB => 1TB

conclusion: need 7 SDDs (SATA) with a capacity of 1TB
```

SDD(nVME):

```
capacity   = ~5TB / (1 * 6TB) = 1 disk
throughput = ~1.8MBps / 3GBps = 1 disk
iops       = ~6365.7RPS / 10 000 = 1 disk

conclusion: need 1 SDD(nVME) with a capacity of 6TB
```

Solution: 7 SDDs (SATA) with a capacity of 1TB.

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

Disks:

```
required capacity   = ~30.6KBps * 86 400 * 365 = 965 001 600KB = ~965GB
required throughput = ~30.6KBps + ~76,5KBps = ~107.1KBps
required iops       = ~926RPS + ~2315RPS = 3241RPS
```

HDD:

```
capacity   = ~965GB / (1 * 1TB) = 1 disk
throughput = ~107.1KBps / 100MBps = 1 disk
iops       = 3241RPS / 100 = 33 disks

count    = max(1, 1, 33) = 33
capacity = ~965GB / 33 = 30GB => 160GB

conclusion: need 33 HDDs with a capacity of 160GB
```

SDD:

```
capacity   = ~965GB / (1 * 1TB) = 1 disk
throughput = ~107.1KBps / 500MBps = 1 disk
iops       = 3241RPS / 1000 = 4 disks

count    = max(1, 1, 4) = 4
capacity = ~965GB / 4 = 241.5GB => 250GB

conclusion: need 4 SSDs with a capacity of 250GB
```

Solution: need 4 SSDs with a capacity of 250GB.

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
text        text (max 1000)
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

Disks:

```
required capacity   = ~239KBps * 86 400 * 365 = 7 537 104 000KB = ~7.5TB
required throughput = ~239KBps + ~6MBps = ~6.3MPps
required iops       = ~231.5RPS + ~5787RPS = ~6018.5RPS
```

HDD:

```
capacity   = ~7.5TB / (2 * 4TB) = 2 disk
throughput = ~6.3MPps / 100MBps = 1 disk
iops       = ~6018.5RPS / 100 = 61 disks

count    = max(2, 1, 61) = 61
capacity = ~7.5TB / 61 = ~123GB => 160GB

conclusion: need 61 HDDs with a capacity of 160GB
```

SSD:

```
capacity   = ~7.5TB / (2 * 4TB) = 2 disk
throughput = ~6.3MPps / 500MBps = 1 disk
iops       = ~6018.5RPS / 1000 = 7 disks

count    = max(2, 1, 7) = 7
capacity = ~7.5TB / 7 = ~1.07TB => 1TB (возьмем чуть меньше capacity, увеличим count) count = 7 => 8

conclusion: need 8 SSDs with a capacity of 1TB
```

Solution: need 8 SSDs with a capacity of 1TB.

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
