# Таза Тіл 🌿

**Таза Тіл** — қазақ тілінің тазалық тексергіші. Мәтіндегі орыс калькаларын анықтап, таза қазақша баламаларын ұсынатын Flutter қолданбасы.

> A Flutter app for checking Kazakh language purity — detects Russian loanwords (кальки) and suggests native Kazakh alternatives.

**Нұсқа / Version:** `5.0.0`

---

## Мүмкіндіктер / Features

### 📖 Онбординг (Onboarding)
- Бірінші іске қосуда 3 беттік таныстыру экраны
- Қолданбаның мүмкіндіктерін визуалды түсіндіру
- Hive арқылы «бір рет ғана» логикасы

### 📚 Сөздік (Dictionary)
- **1 748 калька сөз** қазақша баламасымен
- Іздеу жолағы — нәтижелер нақты уақытта
- Санат бойынша сүзу: Күнделікті · Бизнес · Білім · Технология · Медицина
- Қиындық деңгейі: 🟢 Оңай · 🟡 Орташа · 🔴 Қиын
- Таңдаулы сөздер ❤️
- Карточканы ашқанда: анықтама, мысал, синонимдер

### 🔍 Анықтаушы (Detector)
- Мәтін енгізу — калькалар қызылмен белгіленеді
- Табылған калькалардың тізімі + қазақша баламасы
- ЖИ (Claude / Grok) арқылы мәтінді таза қазақшаға аудару 🤖
- Тексеру тарихы (соңғы 20)
- Нәтижені бөлісу 📤

### 🎮 Викторина (Quiz)
- 10 сұрақ — калька сөздің дұрыс қазақшасын таңдау
- Прогресс-бар, нақты уақыттағы ұпай
- Рекордты сақтау
- Конфетти 🎊 — 7+ ұпай жинағанда

### 🃏 Флеш-карточкалар (Flashcards)
- Swipe-карточка режимі — оңға: білемін ✅, солға: білмеймін ❌
- 3D айналу анимациясы (калька → қазақша)
- Серия есебі және прогресс жолағы
- Таңдаулылардан немесе барлық сөздерден дода жасау

### ☀️ Күн сөзі (Word of Day)
- Күнделікті жаңа сөз (Hive арқылы сақталады)
- Анықтама, мысал, синонимдер
- TTS дыбыстау 🔊 + бөлісу 📤

### ⚙️ Баптаулар (Settings)
- 🌙 Қараңғы / жарық тақырып
- 🤖 Claude API (Anthropic) + ⚡ Grok API (xAI)
- Статистика: таңдаулы, рекорд, жалпы сөздер
- Тексеру тарихын тазарту

---

## Технологиялар / Tech Stack

| Пакет | Мақсаты |
|-------|---------|
| `get ^4.6.6` | State management & navigation |
| `hive ^2.2.3` + `hive_flutter` | Local storage |
| `confetti ^0.7.0` | Confetti animation |
| `share_plus ^9.0.0` | Share results |
| `http ^1.2.1` | Claude & Grok API calls |
| `flutter_animate ^4.5.0` | Animations |

---

## Жоба құрылымы / Project Structure

```
lib/
├── main.dart
├── controllers/
│   └── word_controller.dart       # GetX — барлық state
├── models/
│   ├── word.dart                  # Word model + Hive adapter
│   └── quiz_question.dart
├── data/
│   └── words_data.dart            # 1 748 калька сөз
├── screens/
│   ├── onboarding_screen.dart     # Бірінші іске қосу
│   ├── home_screen.dart           # Bottom navigation (5 қойынды)
│   ├── dictionary_screen.dart
│   ├── detector_screen.dart
│   ├── quiz_screen.dart
│   ├── flashcard_screen.dart      # Swipe флеш-карточкалар
│   ├── word_of_day_screen.dart
│   └── settings_screen.dart
└── widgets/
    └── word_card.dart

test/
├── word_model_test.dart
├── detector_logic_test.dart
├── filter_logic_test.dart
├── flashcard_deck_test.dart
├── history_logic_test.dart
├── detector_edge_cases_test.dart
└── scroll_animation_test.dart
```

---

## Іске қосу / Getting Started

### Талаптар / Requirements
- Flutter SDK `^3.11.4`
- Android / iOS device or emulator

### Орнату / Installation

```bash
git clone https://github.com/MuratFaizulla/taza-til.git
cd taza-til
flutter pub get
flutter run
```

### Тесттерді іске қосу / Run Tests

```bash
flutter test
```

### APK жинау / Build APK

```bash
flutter build apk --release
```

Output: `build/app/outputs/flutter-apk/app-release.apk`

---

## ЖИ интеграциясы / AI Integration

Мәтінді таза қазақшаға аудару үшін API кілті қажет.  
Баптаулар → Жасанды интеллект бөлімінде енгізіңіз.

| Провайдер | Сілтеме | Модель |
|-----------|---------|--------|
| 🤖 Claude | [console.anthropic.com](https://console.anthropic.com) | claude-haiku-4-5 |
| ⚡ Grok | [console.x.ai](https://console.x.ai) | grok-3-fast |

---

## Түс схемасы / Color Scheme

| Түс | HEX | Қолдану |
|-----|-----|---------|
| Жасыл (негізгі) | `#2E7D32` | Primary, AppBar |
| Ашық жасыл | `#E8F5E9` | Қазақша бейдж |
| Қызыл | `#D32F2F` | Калька сөздер |

---

## Нұсқалар тарихы / Changelog

| Нұсқа | Жаңалықтар |
|-------|-----------|
| **5.0.0** | Онбординг экраны, флеш-карточка режимі, 7 unit-тест, баптаулар жақсартылды |
| **3.1.0** | Анықтаушы алгоритмі түзетілді, scroll анимациясы оңтайландырылды |
| **3.0.0** | Telegram + Grok AI деректерінен 1 748 сөз қосылды, өз иконкасы |

---

## Лицензия / License

MIT License © 2025 MuratFaizulla
