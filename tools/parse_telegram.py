#!/usr/bin/env python3
"""
Telegram Channel Parser → Dart Word() Generator
================================================
Парсит JSON экспорт из Telegram Desktop канала "Калькасыз қазақ тілі"
и генерирует Dart код для words_data.dart

Использование:
  python parse_telegram.py result.json
  python parse_telegram.py result.json --output output.txt
  python parse_telegram.py result.json --append  (добавляет прямо в words_data.dart)
  python parse_telegram.py result.json --category technology
"""

import json
import re
import sys
import argparse
from pathlib import Path
from datetime import datetime
from typing import Optional, List

# Windows PowerShell fix — поддержка Unicode в выводе
if sys.stdout.encoding and sys.stdout.encoding.lower() != 'utf-8':
    sys.stdout.reconfigure(encoding='utf-8', errors='replace')

# ─── Путь к words_data.dart ──────────────────────────────────────────────────
WORDS_DATA_PATH = Path(__file__).parent.parent / "lib" / "data" / "words_data.dart"

# ─── Автокатегоризация по ключевым словам ────────────────────────────────────
CATEGORY_KEYWORDS = {
    "technology": [
        "бағдарлам", "қолданба", "ғаламтор", "деректер", "жүктеп", "жүктеу",
        "сайт", "жүйе", "пароль", "код", "программ", "интернет", "телефон",
        "компьютер", "жүктеп көшір",
    ],
    "medicine": [
        "мұрын", "ауру", "дәрі", "дәрігер", "емхана", "аурухана", "денсаулық",
        "емдеу", "операция", "сынама", "диагноз",
    ],
    "business": [
        "кеңсе", "басқарушы", "жоба", "жоспар", "есеп", "келісім", "кездесу",
        "міндет", "бюджет", "тапсырыс", "қаражат", "серіктес",
    ],
    "education": [
        "мектеп", "сабақ", "емтихан", "баға", "мұғалім", "білім", "оқу",
        "студент", "университет", "дәріс", "тапсырма", "ғылым",
    ],
}

def detect_category(text: str) -> str:
    """Автоматически определяет категорию по тексту."""
    text_lower = text.lower()
    for category, keywords in CATEGORY_KEYWORDS.items():
        for kw in keywords:
            if kw in text_lower:
                return category
    return "everyday"


def extract_text(text_field) -> str:
    """
    Telegram экспорт может хранить text как:
    - строку: "❌ ..."
    - список: ["❌ ", {"type": "bold", "text": "..."}, "\n✅ ..."]
    """
    if isinstance(text_field, str):
        return text_field
    if isinstance(text_field, list):
        parts = []
        for item in text_field:
            if isinstance(item, str):
                parts.append(item)
            elif isinstance(item, dict):
                parts.append(item.get("text", ""))
        return "".join(parts)
    return ""


def clean_value(text: str) -> str:
    """
    Берёт только первую значимую строку и очищает её:
    - Убирает строки начинающиеся с эмодзи-пояснений
    - Снимает обрамляющие кавычки "..." и «...»
    - Убирает лишние пробелы по краям
    """
    SKIP_PREFIXES = ("❓", "❗", "‼", "😂", "😒", "⁉", "✅", "❌", "👇", "👆", "ℹ")
    result = ""
    for line in text.splitlines():
        line = line.strip()
        if not line:
            continue
        if any(line.startswith(p) for p in SKIP_PREFIXES):
            continue
        result = line
        break
    if not result and text.strip():
        result = text.strip().splitlines()[0].strip()

    # Убираем обрамляющие кавычки: "текст". → текст
    result = result.strip()
    for open_q, close_q in [('"', '"'), ('«', '»'), ('"', '"')]:
        if result.startswith(open_q) and (result.endswith(close_q) or result.endswith(close_q + '.')):
            result = result.lstrip(open_q).rstrip('.').rstrip(close_q).strip()
            break
    # Убираем trailing точку если она одна в конце (не часть многоточия)
    if result.endswith('.') and not result.endswith('..'):
        result = result[:-1].strip()

    return result


def parse_hint(text: str) -> str:
    """
    Собирает все строки с ⁉ / ⁉️ / ❓ как definition.
    Поддерживает оба варианта символа ⁉ (с и без вариантного селектора).
    """
    hints = []
    for line in text.splitlines():
        line = line.strip()
        # ⁉️ (U+2049 U+FE0F) и ⁉ (U+2049) — оба варианта
        if line.startswith(("⁉️", "⁉", "❓")):
            # Убираем сам символ и пробелы
            cleaned = re.sub(r'^[⁉️❓\s]+', '', line).strip()
            if cleaned:
                hints.append(cleaned)
    return ' '.join(hints) if hints else ""


def parse_message(text: str) -> Optional[dict]:
    """
    Парсит одно сообщение и извлекает:
      kalka   = ❌ неправильная форма  (первая строка, без кавычек)
      kazakh  = ✅ правильная форма    (первая строка, без кавычек)
      hint    = ⁉/⁉️/❓ подсказка — используется как definition
    """
    text = text.strip()

    # ⁉️ и ⁉ — оба варианта символа
    wrong_match   = re.search(r"❌\s*(.+?)(?=(?:⁉️|⁉|❓|✅)|\Z)", text, re.DOTALL)
    hint_block    = re.search(r"((?:⁉️|⁉|❓).+?)(?=✅|\Z)",        text, re.DOTALL)
    correct_match = re.search(r"✅\s*(.+)",                          text, re.DOTALL)

    if not wrong_match or not correct_match:
        return None

    kalka  = clean_value(wrong_match.group(1))
    kazakh = clean_value(correct_match.group(1))
    hint   = parse_hint(hint_block.group(1)) if hint_block else ""

    # Пропускаем пустые или слишком длинные (> 150 символов)
    if not kalka or not kazakh:
        return None
    if len(kalka) > 150 or len(kazakh) > 150:
        return None

    return {
        "kalka":      kalka,
        "kazakh":     kazakh,
        "definition": hint if hint else kazakh,
        "hint":       hint,
    }


def to_dart(entry: dict, category: Optional[str] = None, difficulty: int = 2) -> str:
    """Конвертирует запись в строку Dart Word(...)."""
    cat = category or detect_category(entry["kalka"] + " " + entry["kazakh"])

    def escape(s: str) -> str:
        # 1. Берём только первую строку (страховка от многострочных текстов)
        s = s.strip().splitlines()[0].strip() if s.strip() else s
        # 2. Экранируем обратный слеш и одинарную кавычку для Dart
        return s.replace("\\", "\\\\").replace("'", "\\'")

    kalka      = escape(entry["kalka"])
    kazakh     = escape(entry["kazakh"])
    definition = escape(entry["definition"])
    example    = escape(entry["kazakh"])   # пример = правильная форма

    return (
        f"    Word(\n"
        f"      kalka: '{kalka}',\n"
        f"      kazakh: '{kazakh}',\n"
        f"      definition: '{definition}',\n"
        f"      synonyms: [],\n"
        f"      example: '{example}',\n"
        f"      category: '{cat}',\n"
        f"      difficulty: {difficulty},\n"
        f"    ),"
    )


def parse_json_export(filepath: str) -> List[dict]:
    """Читает Telegram JSON и возвращает список распарсенных записей."""
    with open(filepath, "r", encoding="utf-8") as f:
        data = json.load(f)

    messages = data.get("messages", [])
    entries = []
    skipped = 0

    for msg in messages:
        if msg.get("type") != "message":
            continue
        text = extract_text(msg.get("text", ""))
        entry = parse_message(text)
        if entry:
            entry["date"] = msg.get("date", "")
            entries.append(entry)
        elif "❌" in text or "✅" in text:
            # Есть символы но не распарсилось — логируем
            skipped += 1
            print(f"  [SKIP] id={msg.get('id')} — не удалось распарсить")

    print(f"\n✅ Найдено записей:  {len(entries)}")
    print(f"⚠️  Пропущено:       {skipped}")
    return entries


def append_to_words_data(dart_blocks: List[str]):
    """Добавляет новые Word() блоки в конец списка words в words_data.dart."""
    content = WORDS_DATA_PATH.read_text(encoding="utf-8")

    # Ищем конец именно списка words — за ним идёт kalkaMap
    # Паттерн: `  ];\n\n  static Map<String, Word>`
    insert_marker = "  ];\n\n  static Map<String, Word>"
    idx = content.find(insert_marker)
    if idx == -1:
        # Запасной вариант — ищем `  ];\n\n  static Map`
        insert_marker_short = "  ];\n\n  static Map"
        idx = content.find(insert_marker_short)
    if idx == -1:
        print("❌ Не найден конец списка words в words_data.dart")
        print("   Убедись что файл не изменён вручную")
        return

    # Комментарий-разделитель
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M")
    separator = f"\n    // ─── КАЛЬКАСЫЗ ҚАЗАҚ ТІЛІ (импорт {timestamp}) ──────\n"

    new_block = separator + "\n".join(dart_blocks) + "\n"
    new_content = content[:idx] + new_block + content[idx:]

    WORDS_DATA_PATH.write_text(new_content, encoding="utf-8")
    print(f"\n✅ Добавлено {len(dart_blocks)} записей в {WORDS_DATA_PATH}")


def main():
    parser = argparse.ArgumentParser(
        description="Парсер Telegram → Dart Word()"
    )
    parser.add_argument("input", help="Путь к result.json (экспорт из Telegram)")
    parser.add_argument("--output",   help="Записать результат в файл (вместо stdout)")
    parser.add_argument("--append",   action="store_true",
                        help=f"Добавить прямо в {WORDS_DATA_PATH}")
    parser.add_argument("--category", default=None,
                        help="Принудительная категория (everyday/business/education/technology/medicine)")
    parser.add_argument("--difficulty", type=int, default=2, choices=[1, 2, 3],
                        help="Сложность: 1=легко, 2=средне, 3=сложно")
    args = parser.parse_args()

    print(f"📂 Читаю файл: {args.input}")
    entries = parse_json_export(args.input)

    if not entries:
        print("Нет данных для обработки.")
        return

    dart_blocks = [
        to_dart(e, category=args.category, difficulty=args.difficulty)
        for e in entries
    ]

    if args.append:
        append_to_words_data(dart_blocks)

    elif args.output:
        Path(args.output).write_text(
            "\n".join(dart_blocks), encoding="utf-8"
        )
        print(f"\n✅ Dart код сохранён в: {args.output}")

    else:
        print("\n" + "=" * 60)
        print("// DART КОД — скопируй в words_data.dart")
        print("=" * 60)
        print("\n".join(dart_blocks))

    # Показываем превью первых 3 записей
    print("\n─── Превью (первые 3 записи) ───────────────────────────────")
    for e in entries[:3]:
        print(f"  ❌ {e['kalka']}")
        print(f"  ✅ {e['kazakh']}")
        if e['hint']:
            print(f"  ⁉️  {e['hint']}")
        print()


if __name__ == "__main__":
    main()
