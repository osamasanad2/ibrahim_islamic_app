# إبراهيم — Ibrahim Islamic Lifestyle App

<div align="center">
  <img src="assets/images/app_icon.png" alt="Ibrahim App Icon" width="120"/>
  <br><br>
  <p><strong>A comprehensive Islamic lifestyle application built with Flutter.</strong></p>
  <p>Prayer times · Quran · Azkar · AI Assistant · Mosque Map · Spiritual Journey · and more</p>
  <br>
</div>

---

## ✨ Features

### 🕌 Worship Essentials
| Feature | Description |
|---------|-------------|
| **Prayer Times** | Accurate prayer times calculation using the Adhan library with automatic location detection. Track prayer status (on time / late / missed / qada). Next prayer countdown. |
| **Qibla Direction** | Real-time compass-based Qibla direction finder with GPS-based calculation. |
| **Tasbeeh** | Digital counter with preset dhikr (SubhanAllah, Alhamdulillah, Allahu Akbar) and custom counts. |
| **Azkar** | Morning and evening azkar (adhkar) with Arabic text, transliteration, and translation. |

### 📖 Quran
| Feature | Description |
|---------|-------------|
| **Surah List** | Complete 114 surahs with revelation type, verse count, and search functionality. |
| **Surah Reader** | Ayah-by-ayah reader with Arabic text, translation, audio playback, and bookmarking. |
| **Mushaf Mode** | Page-based Quran viewing with page images, jump-to-page navigation, and tafsir sheets. |
| **Audio Player** | Full surah audio playback with play/pause, seek bar, and per-ayah audio buttons. |
| **Khatma Planner** | Plan and track Quran completion goals with daily page targets. |

### 🤖 AI Assistant
| Feature | Description |
|---------|-------------|
| **Gemini Chat** | Ask Islamic questions powered by Google's Gemini AI. |
| **Suggestions** | Quick prompt suggestions for common topics (prayer, fasting, zakat, etc.). |
| **Typing Indicator** | Real-time AI response status. |
| **API Key Config** | In-app Gemini API key configuration, persisted securely in local storage. |

### 📿 Dhikr & Du'a
| Feature | Description |
|---------|-------------|
| **99 Names of Allah** | All 99 names with Arabic, transliteration, translation, and meaning. Grid view with detail modal. |
| **Dua Engine** | Mood-based dua recommendations — select your feeling and get relevant supplications. |
| **Sadaqah Tracker** | Log charity by type (money, food, clothing, smile, etc.) with totals and history. |
| **Wird / Daily Routine** | 6 daily spiritual tasks with progress tracking and check-in streaks. |

### 🗺️ Community & Location
| Feature | Description |
|---------|-------------|
| **Mosque Map** | Google Maps integration with dark theme, showing nearby mosques and Islamic centers. |
| **Family Hub** | Family spiritual stats, group challenges, member level tracking. |
| **Spiritual Journey** | 6-level progression system with requirements and rewards. |

### 📚 Knowledge
| Feature | Description |
|---------|-------------|
| **Hadith Collection** | 40 Nawawi hadiths with Arabic and translation. |
| **Hajj & Umrah Guide** | Step-by-step guide covering all 7 stages of pilgrimage. |
| **Islamic Calendar** | Hijri calendar with Islamic events and holidays. |
| **Zakat Calculator** | Calculate zakat on cash, gold, and silver with nisab threshold check. |
| **Tafsir** | Verse-by-verse tafsir (explanation) fetched from alquran.cloud API. |

### ⚙️ Personalization
| Feature | Description |
|---------|-------------|
| **Onboarding** | 4-step welcome flow introducing key features, persisted in local storage. |
| **Profile** | User stats, theme toggle (dark/light), bookmarks management, about dialog. |
| **Prayer Notifications** | Automatic scheduling of prayer time notifications using flutter_local_notifications. |
| **Bookmark Sync** | Sync Quran bookmarks across devices via Firebase Firestore. |
| **Explore Screen** | Searchable content browser with filter chips (Quran, Azkar, Duas, Names, etc.). |

---

## 🖼️ Screenshots

| Home | Prayer Times | Quran Reader | AI Chat |
|------|-------------|--------------|---------|
| *Home dashboard with prayer countdown, daily verse, quick actions* | *Prayer list with status toggles and next prayer banner* | *Ayah-by-ayah Quran reader with audio and bookmarks* | *Gemini AI assistant with Islamic Q&A* |

| 99 Names | Azkar | Mosque Map | Profile |
|----------|-------|------------|---------|
| *Grid of Allah's 99 names with detail modal* | *Morning & evening adhkar with counters* | *Google Maps with dark theme mosque locator* | *Stats, theme, bookmarks, and settings* |

---

## 🛠️ Tech Stack

| Technology | Purpose |
|------------|---------|
| **Flutter 3.x** | Cross-platform framework |
| **Dart** | Programming language |
| **flutter_riverpod** | State management with code generation (riverpod_annotation) |
| **go_router** | Declarative routing with ShellRoute + bottom navigation |
| **Dio** | HTTP client with retry interceptor and error handling |
| **Hive** | Local storage for settings, bookmarks, progress, prayer data |
| **Firebase** | Firestore for bookmark sync |
| **just_audio** | Audio playback for Quran recitation |
| **google_maps_flutter** | Mosque map with custom dark theme |
| **flutter_compass** | Qibla direction compass |
| **Adhan** | Accurate prayer time calculation |
| **flutter_local_notifications** | Prayer notification scheduling |
| **Gemini API** | AI-powered Islamic assistant |
| **alquran.cloud API** | Quranic tafsir data |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (>=3.0.0)
- Dart SDK (>=3.0.0)
- Android Studio / VS Code
- An Android emulator or physical device

### Installation

```bash
# Clone the repository
git clone https://github.com/osamasanad2/ibrahim_islamic_app.git
cd ibrahim_islamic_app

# Install dependencies
flutter pub get

# Generate Riverpod code
flutter pub run build_runner build --delete-conflicting-outputs

# Run the app
flutter run
```

### API Keys

The app requires the following API keys at runtime:
- **Gemini API Key** — Configurable via in-app settings dialog, persisted in Hive
- **Google Maps API Key** — Required in `android/app/src/main/AndroidManifest.xml` for mosque map functionality

---

## 📂 Project Structure

```
lib/
├── core/
│   ├── constants/          # App colors, dimensions, strings, typography
│   ├── di/                 # Dependency injection providers
│   ├── network/            # API client with interceptors
│   ├── router/             # GoRouter configuration (24 routes)
│   ├── storage/            # Hive local storage wrapper
│   ├── theme/              # Dark/light themes and provider
│   ├── utils/              # Audio service, location, prayer calc, etc.
│   └── widgets/            # Shared widgets (scaffold, bottom nav)
├── features/
│   ├── ai_assistant/       # Gemini chat screen
│   ├── azkar/              # Azkar + Tasbeeh screens
│   ├── calendar/           # Hijri calendar
│   ├── dua/                # Mood-based dua engine
│   ├── explore/            # Searchable content browser
│   ├── family_hub/         # Family stats and challenges
│   ├── hadith/             # 40 Nawawi collection
│   ├── hajj/               # Hajj/Umrah guide
│   ├── home/               # Dashboard with widgets
│   ├── mosque_map/         # Google Maps mosque locator
│   ├── names_of_allah/     # 99 Names display
│   ├── onboarding/         # 4-step welcome flow
│   ├── prayer_times/       # Prayer list + countdown
│   ├── profile/            # User profile + settings
│   ├── qibla/              # Compass direction
│   ├── quran/              # Reader, mushaf, audio, khatma
│   ├── sadaqah/            # Charity tracker
│   ├── spiritual_journey/  # Progression system
│   ├── wird/               # Daily spiritual routine
│   └── zakat/              # Zakat calculator
└── main.dart               # Entry point
```

---

## 🔧 Commands

| Command | Description |
|---------|-------------|
| `flutter run` | Run on connected device/emulator |
| `flutter build apk --debug` | Build debug APK |
| `flutter build apk --release` | Build release APK |
| `flutter analyze` | Run static analysis (0 errors, 0 warnings) |
| `flutter test` | Run tests |
| `flutter pub run build_runner build` | Generate Riverpod code |
| `flutter pub run build_runner watch` | Auto-generate on file changes |

---

## 📊 Stats

- **40+** screens and widgets
- **24** GoRouter routes
- **13,000+** lines of Dart code
- **0** analyzer errors
- **0** analyzer warnings

---

## 📄 License

This project is for personal and educational use.

---

<div align="center">
  <p>Made with ❤️ for the Muslim community</p>
  <p>—— إبراهيم ——</p>
</div>
