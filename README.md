# NumCricket (Hand Job)

A real-time multiplayer "Hand Cricket" game built with Flutter and Firebase Realtime Database.

## Features

- **Real-time Multiplayer**: Compete against other players in real-time.
- **Toss System**: Interactive odd/even toss to decide batting or bowling.
- **Dynamic Gameplay**: 5 innings per match with alternating roles.
- **Smart Game Engine**: Handles runs, wickets (Outs), and wide balls (timeouts).
- **Responsive UI**: Fully optimized for various screen sizes.
- **Authentication**: Supports Google Sign-in and Guest login.
- **Profile & Stats**: Track your wins, losses, XP, and level.
- **Animated Experience**: Smooth transitions and result overlays using `flutter_animate`.

## Getting Started

1.  **Firebase Setup**:
    -   Create a Firebase project.
    -   Enable Authentication (Google & Anonymous).
    -   Enable Realtime Database (Singapore region recommended).
    -   Update `android/app/google-services.json` and `lib/firebase_options.dart`.

2.  **Run the Project**:
    ```bash
    flutter pub get
    dart run build_runner build --delete-conflicting-outputs
    flutter run
    ```

## Technology Stack

- **Flutter**: Frontend Framework.
- **Riverpod**: State management.
- **Firebase Realtime Database**: Real-time game state synchronization.
- **Firebase Auth**: User authentication.
- **GoRouter**: Declarative routing.
- **Flutter Animate**: UI animations.

## Game Rules

- Each match has 5 innings.
- Both players pick a number from 1-6 simultaneously.
- If numbers match → **OUT**.
- If numbers differ → Batsman scores their picked number in runs.
- Timeout (5s) → **WIDE** (no runs, no wicket).
