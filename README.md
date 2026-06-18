# 🐌 SnailyWhim

SnailyWhim is a Flutter-based mobile application designed to provide an engaging and seamless user experience through modern UI design, real-time backend integration, and personalized content management. The application leverages Supabase as its backend service and adopts scalable state management using BLoC architecture.

---

## ✨ Features

* User Authentication
* User Profile Management
* Infinite Scroll Pagination
* Push Notifications
* Persistent Local Storage
* External URL Integration
* WebView Support
* Custom Splash Screen
* Custom App Icon
* Responsive User Interface

---

## 🛠 Tech Stack

### Frontend

* Flutter SDK 3.10+
* Dart

### State Management

* flutter_bloc
* provider

### Backend

* Supabase

### Local Storage

* Shared Preferences

### Notifications

* Flutter Local Notifications
* App Badge Plus

### UI Libraries

* Flutter SVG
* Lucide Icons
* Badges
* Smooth Page Indicator

---

## 📂 Project Structure

```text
lib/
├── core/
│   ├── constants/
│   ├── theme/
│   ├── utils/
│   ├── services/
│   └── widgets/
│
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
│
├── bloc/
│   ├── auth/
│   ├── user/
│   ├── notification/
│   └── content/
│
├── providers/
│
├── screens/
│   ├── auth/
│   ├── onboarding/
│   ├── dashboard/
│   ├── profile/
│   └── settings/
│
├── routes/
│
├── app.dart
└── main.dart
```

---

## 🚀 Getting Started

### Prerequisites

Before running this project, ensure you have:

* Flutter SDK 3.10+
* Dart SDK
* Android Studio / VS Code
* Android SDK

Check installation:

```bash
flutter doctor
```

---

## 📦 Installation

Clone repository:

```bash
git clone https://github.com/your-username/snailywhim.git
```

Navigate to project folder:

```bash
cd snailywhim
```

Install dependencies:

```bash
flutter pub get
```

---

## ⚙ Environment Configuration

Create a `.env` file in the root project:

```env
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

---

## ▶ Running the Application

Debug mode:

```bash
flutter run
```

Specific device:

```bash
flutter run -d emulator-5554
```

---

## 🏗 Build Release

### Android APK

```bash
flutter build apk --release
```

### Android App Bundle

```bash
flutter build appbundle --release
```

### iOS

```bash
flutter build ios --release
```

---

## 🧪 Testing

Run unit and widget tests:

```bash
flutter test
```

---

## 📚 State Management

The application uses a hybrid state management approach:

### BLoC

Used for:

* Authentication
* User Session
* Notifications
* Business Logic

### Provider

Used for:

* Lightweight UI State
* Theme Management
* Temporary Application States

---

## 🔐 Backend Architecture

SnailyWhim utilizes Supabase services:

* Authentication
* PostgreSQL Database
* Storage
* Realtime Services

---

## 🎨 Assets

Project assets include:

```text
assets/
├── fonts/
│   ├── ArtPostBlack.ttf
│   └── Cakewalk.ttf
│
├── gif/
│   └── success.gif
│
└── img/
    ├── logo.png
    ├── logo.svg
    ├── logotanpateks.png
    ├── flower.png
    └── kumbang.png
```

---

## 👨‍💻 Development Team

Developed using Flutter and Supabase.

---

## 📄 License

This project is intended for educational and development purposes.

All rights reserved.
