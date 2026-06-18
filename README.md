# 🐌 SnailyWhim

![Flutter](https://img.shields.io/badge/Flutter-3.10+-02569B?style=flat-square&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.10+-0175C2?style=flat-square&logo=dart)
![Supabase](https://img.shields.io/badge/Supabase-Backend-3ECF8E?style=flat-square&logo=supabase)
![License](https://img.shields.io/badge/License-Private-red?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-Android-green?style=flat-square)

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

### Framework & Language

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge\&logo=dart\&logoColor=white)

### State Management

![Flutter Bloc](https://img.shields.io/badge/Flutter_BLoC-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Provider](https://img.shields.io/badge/Provider-4285F4?style=for-the-badge\&logo=google\&logoColor=white)

### Backend & Database

![Supabase](https://img.shields.io/badge/Supabase-3ECF8E?style=for-the-badge\&logo=supabase\&logoColor=white)
![PostgreSQL](https://img.shields.io/badge/PostgreSQL-336791?style=for-the-badge\&logo=postgresql\&logoColor=white)

### Notifications

![Flutter Local Notifications](https://img.shields.io/badge/Local_Notifications-FF9800?style=for-the-badge\&logo=android\&logoColor=white)
![App Badge](https://img.shields.io/badge/App_Badge-4CAF50?style=for-the-badge)

### Storage

![Shared Preferences](https://img.shields.io/badge/Shared_Preferences-607D8B?style=for-the-badge)

### UI & Utilities

![Flutter SVG](https://img.shields.io/badge/Flutter_SVG-02569B?style=for-the-badge\&logo=flutter\&logoColor=white)
![Lucide Icons](https://img.shields.io/badge/Lucide_Icons-F56565?style=for-the-badge)
![Infinite Pagination](https://img.shields.io/badge/Infinite_Pagination-7B61FF?style=for-the-badge)
![URL Launcher](https://img.shields.io/badge/URL_Launcher-00C853?style=for-the-badge)
![WebView](https://img.shields.io/badge/WebView-2196F3?style=for-the-badge)
![Image Picker](https://img.shields.io/badge/Image_Picker-FF5722?style=for-the-badge)

### Development Tools

![Android Studio](https://img.shields.io/badge/Android_Studio-3DDC84?style=for-the-badge\&logo=androidstudio\&logoColor=white)
![VS Code](https://img.shields.io/badge/VS_Code-007ACC?style=for-the-badge\&logo=visualstudiocode\&logoColor=white)
![Git](https://img.shields.io/badge/Git-F05032?style=for-the-badge\&logo=git\&logoColor=white)
![GitHub](https://img.shields.io/badge/GitHub-181717?style=for-the-badge\&logo=github\&logoColor=white)


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
