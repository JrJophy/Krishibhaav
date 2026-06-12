# Firebase Setup Instructions

1. Create a Firebase project in the Firebase Console.
2. Enable Authentication (Email/Password).
3. Enable Cloud Firestore.
4. Enable Firebase Cloud Messaging.
5. Register the Android app with your package name.
6. Download `google-services.json` and place it in `android/app/`.
9. Register the Web app and copy the Firebase config into `lib/firebase_options.dart`.
10. Run `flutterfire configure` to set up the project automatically.
11. **Security**: A fresh clone requires manually generating and placing the service account JSON. Go to Firebase Console → Project settings → Service accounts → Generate new private key. Save it exactly as `assets/service_account.json`. Do not commit this file.
