# Ter Market

Ter Market is a Flutter shopping app for groceries and everyday essentials in Turkmenistan. Customers can browse fresh food and household products, search the catalog, save favorites, place orders, and follow their order history.

[Get Ter Market on Google Play](https://play.google.com/store/apps/details?id=com.gurbanov.termarket)

## Features

- Browse categories, brands, offers, and product details.
- Search products and save favorites.
- Add products to a cart and choose delivery and payment options at checkout.
- Review previous orders and their status.
- Use the app in Turkmen or Russian.

The app uses the Ter Market API configured in [`lib/core/api/api_client.dart`](lib/core/api/api_client.dart). Network access and a working backend are required for catalog and order flows.

## Development

Install [Flutter](https://docs.flutter.dev/get-started/install) and the platform toolchain. Android builds use JDK 17 with this project's Gradle version. The package name inside the Flutter project is `atlas`; the Android application ID is `com.gurbanov.termarket`.

```sh
flutter pub get
flutter run
```

Firebase is used for push notifications. The Android Firebase configuration is in `android/app/google-services.json`. Keep release signing passwords and private keys outside Git.

The included `third_party/iconly` and `third_party/feather_icons` copies retain their original fonts and glyphs while making their icon definitions compatible with current Flutter versions.

## Checks

```sh
flutter analyze --no-fatal-infos
flutter build apk --debug
```

The analyzer still reports legacy style notices; warnings and errors fail the check. GitHub Actions runs these checks on pull requests and on `main`. This repository does not yet contain an automated test suite.

## Android releases

The version is set in [`pubspec.yaml`](pubspec.yaml). Android release builds require a local `android/upload/key.properties` file and an upload keystore. Copy [`android/upload/key.properties.example`](android/upload/key.properties.example) and fill it with the correct values. The properties file and keystore are ignored by Git. A release build fails if signing information is missing.

```sh
flutter build apk --release
```

Verify the APK's application ID, version, and signing certificate before distributing it. A source-only GitHub Release does not contain an installable APK. Before a Google Play update, confirm that the build number is newer than the version currently on Play.
