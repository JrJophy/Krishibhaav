# Firebase Setup Instructions

1. Create a Firebase project in the Firebase Console.
2. Enable Authentication (Email/Password).
3. Enable Cloud Firestore.
4. Enable Firebase Cloud Messaging.
5. Register the Android app with your package name.
6. Download `google-services.json` and place it in `android/app/`.
7. Register the Web app and copy the Firebase config into `lib/firebase_options.dart`.
8. Run `flutterfire configure` to set up the project automatically.
