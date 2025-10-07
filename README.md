# Money Manager

Finance app to track income and expenses

## Getting Started

### Prerequisites

- Flutter SDK (latest stable version)
- Android Studio or VS Code with Flutter extensions
- Android device or emulator for testing

### Installation

1. Clone the repository:
   ```bash
   git clone <repository-url>
   cd MoneyManager
   ```

2. Install dependencies:
   ```bash
   flutter pub get
   ```

## Running the App

This app supports multiple build flavors for different environments:

### Available Flavors

- **Production** (`production`): Production environment with package name `in.manager.money`
- **Staging** (`staging`): Staging environment with package name `in.manager.money.stage`

### Command Line

#### Development (Debug Mode)
```bash
# Run production flavor (default)
flutter run --flavor production

# Run staging flavor
flutter run --flavor staging
```

#### Release Mode
```bash
# Run production release
flutter run --flavor production --release

# Run staging release
flutter run --flavor staging --release
```

### VS Code

Use the debug configurations in VS Code:

1. Open the project in VS Code
2. Go to Run and Debug (Ctrl+Shift+D)
3. Select from available configurations:
   - **MoneyManager**: Production flavor in debug mode
   - **MoneyManager (staging mode)**: Staging flavor in debug mode
   - **MoneyManager (profile mode)**: Production flavor in profile mode
   - **MoneyManager (release mode)**: Production flavor in release mode

### Building APKs

```bash
# Build production APK
flutter build apk --flavor production --release

# Build staging APK
flutter build apk --flavor staging --release

# Build both flavors
flutter build apk --flavor production --release && flutter build apk --flavor staging --release
```

### Package Names

- **Production**: `in.manager.money`
- **Staging**: `in.manager.money.stage`

Both versions can be installed simultaneously on the same device for testing purposes.

## Development Resources

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
