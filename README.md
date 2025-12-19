# 🚗 UniPool - University Carpooling App

A cross-platform carpooling application designed for university students to share rides, reduce commuting costs, and minimise their environmental footprint.

## Overview

UniPool connects students travelling to and from campus, making it easy to find or offer rides. Whether you're a driver looking to share fuel costs or a passenger seeking a convenient commute, UniPool streamlines the process of coordinating shared transportation within the university community.

## Tech Stack

**Frontend**
- Flutter (Dart) - Cross-platform mobile and web development
- Supports Android, iOS, Web, Windows, Linux, and macOS

**Backend**
- Firebase Cloud Functions - Serverless backend logic
- Cloud Firestore - Real-time NoSQL database
- Firebase Realtime Database - Live data synchronisation
- Firebase Storage - File and media storage
- Firebase Authentication - User management and security

## Project Structure


```
final_carpool/
├── lib/                    # Main Flutter application code
├── android/                # Android-specific configuration
├── ios/                    # iOS-specific configuration
├── web/                    # Web app configuration
├── windows/                # Windows desktop configuration
├── linux/                  # Linux desktop configuration
├── macos/                  # macOS desktop configuration
├── test/                   # Unit and widget tests
├── backend/
│   ├── functions/          # Firebase Cloud Functions
│   ├── firestore.rules     # Firestore security rules
│   ├── storage.rules       # Storage security rules
│   └── database.rules      # Realtime Database rules
└── pubspec.yaml            # Flutter dependencies
```

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later)
- [Firebase CLI](https://firebase.google.com/docs/cli)
- [Node.js](https://nodejs.org/) (for Firebase Functions)
- Android Studio / Xcode (for mobile development)

### Frontend Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/Frostie2k23/final_carpool.git
   cd final_carpool
   ```

2. Install Flutter dependencies:
   ```bash
   flutter pub get
   ```

3. Run the app:
   ```bash
   flutter run
   ```

### Backend Setup

1. Navigate to the backend directory:
   ```bash
   cd backend/backend
   ```

2. Install Firebase CLI (if not already installed):
   ```bash
   npm install -g firebase-tools
   ```

3. Login to Firebase:
   ```bash
   firebase login
   ```

4. Install Cloud Functions dependencies:
   ```bash
   cd functions
   npm install
   ```

5. Deploy to Firebase:
   ```bash
   firebase deploy
   ```

## Features

- **Ride Posting** - Drivers can post available rides with route details, timing, and seat availability
- **Ride Search** - Passengers can search for rides matching their route and schedule
- **Real-time Updates** - Live synchronisation of ride availability and booking status
- **User Profiles** - Verified university student accounts
- **In-app Messaging** - Coordinate pickup details with your carpool group
- **Cross-platform** - Access from mobile devices or web browsers

## Contributing

This project was developed as a university coursework project. Feel free to fork and adapt for your own institution.

## License

This project is available for educational purposes.

---

*Built with Flutter & Firebase*
