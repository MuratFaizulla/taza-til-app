# Инструкция: Telegram → words_data.dart

## Шаг 1: Экспорт из Telegram Desktop

1. Открой **Telegram Desktop** (не мобильный!)
2. Зайди в канал `t.me/kalkastop`
3. Нажми **⋮ (три точки)** → **Export chat history**
4. Настройки экспорта:
   - ✅ Format: **JSON**
   - ❌ Photos — выключи
   - ❌ Videos — выключи
   - ❌ Voice messages — выключи
5. Нажми **Export**
6. Получишь файл `result.json`

---

## Шаг 2: Запуск скрипта

Открой терминал в папке `tools/`:

```bash
cd flutter_application_1/tools
```

### Просто посмотреть результат (stdout):
```bash
python parse_telegram.py result.json
```

### Сохранить в файл:
```bash
python parse_telegram.py result.json --output new_words.txt
```

### Добавить прямо в words_data.dart:
```bash
python parse_telegram.py result.json --append
```

### Указать категорию вручную:
```bash
python parse_telegram.py result.json --category everyday --difficulty 2
```

---

## Категории
| Код          | Казахша      |
|--------------|--------------|
| `everyday`   | Күнделікті   |
| `business`   | Бизнес       |
| `education`  | Білім        |
| `technology` | Технология   |
| `medicine`   | Медицина     |

## Сложность
| Значение | Смысл   |
|----------|---------|
| `1`      | Легко   |
| `2`      | Средне  |
| `3`      | Сложно  |

---

## Формат сообщений в канале (поддерживается)

```
❌ бағдарламалық қамтамасыз ету

⁉️програмное обеспечение

✅ бағдарламалық жасақтама
```

Скрипт автоматически:
- Извлекает `❌` → поле `kalka`
- Извлекает `✅` → поле `kazakh` и `example`
- Извлекает `⁉️` → поле `definition`
- Определяет `category` по ключевым словам
