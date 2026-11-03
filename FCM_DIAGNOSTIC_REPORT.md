# FCM Diagnostic Report — Car Wash Customer App

Date: 2026-09-30

This file summarizes the inspection of Firebase / FCM setup, findings, possible causes of `messaging/mismatched-credential (SenderId mismatch)`, and exact diagnostic steps and code snippets to add (no code changed here).

---

## A. Firebase initialization
- Where: `lib/main.dart` — `await Firebase.initializeApp();` (called in `main()` before `runApp()`).
- Background handler also calls `await Firebase.initializeApp()` in `_firebaseMessagingBackgroundHandler`.
- No `DefaultFirebaseOptions` or manual `FirebaseOptions` usage found — Android relies on `android/app/google-services.json`.

## B. FCM token generation
- Calls to `getToken()` found:
  - `lib/main.dart` in `_MyAppState.setupFCM()`:
    - `fcmToken = await messaging.getToken();` — called from `initState()` after app start (Firebase already initialized in `main()`).
  - `lib/app/controllers/auth/otp_controller.dart` in `OtpController.verifyOtp()`:
    - `String? fcmToken = await FirebaseMessaging.instance.getToken();` — called after OTP verification / login.
- Both calls occur after `Firebase.initializeApp()`.

## C. FCM token backend update
- Token upload function: `OtpController.sendFcmTokenToBackend(String token)`.
- API call: `PUT customers/fcm-token` with body `{ "fcmToken": "<token>" }`.
- `ApiService.put(... requireAuthToken: true)` — adds `Authorization: Bearer <accessToken>` if stored by `FlutterSecureStore`.
- Customer identifier is not in the request body; backend must identify the customer from the access token.
- When token is sent: only during OTP verification (first login flow) — not on token refresh.

## D. Token refresh handling
- `onTokenRefresh` is implemented in `lib/main.dart`:
  ```dart
  FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
    print("NEW TOKEN: $newToken");
    fcmToken = newToken;
  });
  ```
- Problem: refresh handler only logs and updates local var; it does NOT call the backend to update the token. So token rotation will leave the backend with stale token.

## E. Android Firebase configuration (files & values)
- `android/app/google-services.json` (app file) contains:
  - `project_number`: `827818532249`
  - `project_id`: `custcarappnotifications-f4e9b`
  - Two `client` entries:
    - `package_name`: `com.example.my_new_app` (unused)
    - `package_name`: `com.washgate4.carwash` (the actual app)
  - Ensure the build picks the `com.washgate4.carwash` client (it should if `applicationId` matches).
- Firebase libs / plugin usage:
  - `firebase_core` and `firebase_messaging` declared in `pubspec.yaml`.
  - `com.google.gms.google-services` plugin applied in `android/app/build.gradle.kts` and declared in `settings.gradle.kts`.

## F. Android package / applicationId
- `applicationId` and `namespace` in `android/app/build.gradle.kts`:
  - `namespace = "com.washgate4.carwash"`
  - `applicationId = "com.washgate4.carwash"`
- `MainActivity` package: `android/app/src/main/kotlin/com/washgate4/carwash/MainActivity.kt` — package `com.washgate4.carwash`.
- Conclusion: app package matches expected `com.washgate4.carwash`.

## G. Notification permissions & Android config
- `POST_NOTIFICATIONS` present in `android/app/src/main/AndroidManifest.xml`.
- Default app icon used as `@mipmap/ic_launcher`.
- Local notification channel created in `setupFCM()`.
- Background handler registered: `FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);`.

## H. Topic subscription
- App subscribes to `all_users` in `OtpController.verifyOtp()`:
  ```dart
  await FirebaseMessaging.instance.subscribeToTopic("all_users");
  ```
- No other topic subscriptions found.

## I. Potential causes of SenderId mismatch
1. Backend service account / credentials belong to a different Firebase project than the one the app used to generate the token (most likely). If backend uses a service account from another project, direct token sends will fail with `SenderId mismatch`.
2. Token is stale (app previously built with a different google-services.json / Firebase project) and backend still uses that token. App only uploads token at login, so rotation/stale tokens are possible.
3. Multiple google-services.json entries: not inherently an issue if `applicationId` matches the correct client, but a wrong file used at build time can cause tokens to belong to another project.

## J. Exact files that may need changes (client-side, if you choose to update)
- `lib/main.dart` — enhance `onTokenRefresh` to send token to backend when logged in.
- `lib/app/controllers/auth/otp_controller.dart` — consider centralizing `sendFcmTokenToBackend()` so it can be reused by token-refresh handler.

## K. Exact code changes recommended (no edits applied here)
1. Diagnostic prints (temporary) — add after `Firebase.initializeApp()` in `main()`:
```dart
final app = Firebase.app();
print('Firebase App name: ${app.name}');
print('Firebase Project ID: ${app.options.projectId}');
print('Firebase App ID: ${app.options.appId}');
```
2. Print token where retrieved (temporary):
- In `setupFCM()` after `getToken()`:
```dart
print('FCM Token (main): $fcmToken');
print('Firebase Project ID (main): ${Firebase.app().options.projectId}');
```
- In `OtpController.verifyOtp()` after `getToken()`:
```dart
print('FCM Token (otp verify): $fcmToken');
```
3. Send token to backend on refresh — example helper function (place in a shared service file):
```dart
Future<void> sendFcmTokenToBackendIfLoggedIn(String token) async {
  final tokenExists = await FlutterSecureStore().read(key: SharedPrefsHelper.accessToken);
  if (tokenExists != null && tokenExists.isNotEmpty) {
    await ApiService.put('customers/fcm-token', {'fcmToken': token}, requireAuthToken: true);
    print('FCM token updated on backend (refresh).');
  } else {
    print('User not logged in; skipping backend token update.');
  }
}
```
Then in `main.dart` replace `onTokenRefresh` body:
```dart
FirebaseMessaging.instance.onTokenRefresh.listen((newToken) {
  print('NEW TOKEN: $newToken');
  fcmToken = newToken;
  sendFcmTokenToBackendIfLoggedIn(newToken);
});
```
4. Optional: persist `latestFcmToken` in shared prefs for debugging:
```dart
await SharedPrefsHelper.setString('latestFcmToken', token);
```

## L. Exact testing steps
1. Add diagnostic prints (A.K.1 & A.K.2) and rebuild/install the app on device/emulator.
2. Check logs (adb logcat) for prints:
   - `Firebase Project ID:` should be `custcarappnotifications-f4e9b`.
   - `Firebase App ID:` should match the `mobilesdk_app_id` entry for `com.washgate4.carwash` in `google-services.json`.
   - `FCM Token:` values.
3. Perform OTP login flow and confirm `customers/fcm-token` PUT is called and backend logs token receipt.
4. On backend: verify the service account / Admin SDK credentials belong to `custcarappnotifications-f4e9b` (project id and project number `827818532249`). If backend credentials are for a different project → mismatch error expected.
5. Force token refresh (e.g., uninstall/reinstall or programmatic `deleteToken()` + `getToken()`), or wait for rotation; confirm `onTokenRefresh` triggers and (if change applied) backend receives updated token.
6. Attempt to send a direct push (not topic) from backend to the printed token. If `messaging/mismatched-credential` persists, confirm backend credentials.

---

## Additional notes & quick checks for you
- Confirm the backend's service account JSON `project_id` matches `custcarappnotifications-f4e9b`.
- Confirm that the token sent from the device is the same token the backend receives (log both sides). If they differ, a proxy/middleware may be replacing tokens.
- Topic messages may succeed across projects if the backend uses different endpoints/credentials or if you used a legacy server key; topic success does not guarantee direct-target success.

---

## Where I found key code (for quick reference)
- Firebase init & FCM setup: `lib/main.dart`
- OTP flow, token send and topic subscribe: `lib/app/controllers/auth/otp_controller.dart`
- ApiService: `lib/app/services/api_service.dart`
- Android google-services.json: `android/app/google-services.json`
- Android appId / namespace: `android/app/build.gradle.kts` and `android/app/src/main/kotlin/com/washgate4/carwash/MainActivity.kt`

---

If you want, I can now:
- A) Add the temporary diagnostic prints to `lib/main.dart` and `OtpController` and run the app logs for you, or
- B) Draft the exact patch to send token to backend on refresh (no edits applied until you approve), or
- C) Help confirm backend service account details (you can paste `project_id` from the service account JSON and I will compare)

Tell me which of A/B/C you want next.
