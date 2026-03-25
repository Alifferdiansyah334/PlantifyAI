# Plantify AI

Plantify AI is a Flutter mobile app for plant disease detection, focused on tomato and rice crops. The app combines on-device TensorFlow Lite classification with a guided camera flow, disease information, treatment recommendations, article content, and downloadable reports.

## Highlights

- On-device plant disease detection using TensorFlow Lite models
- Crop selection flow for tomato and rice
- Camera capture and gallery import with image cropping
- Detection result screen with confidence score, disease details, and treatment guidance
- Detection history saved locally on the device
- Article library and featured educational content
- PDF export and share support for reports
- Theme switching and bilingual experience for English and Indonesian

## Tech Stack

- Flutter
- Dart
- Provider for state management
- `camera` and `image_picker` for image acquisition
- `image_cropper` and `image` for preprocessing
- `tflite_flutter` for on-device inference
- `shared_preferences` for local persistence
- `pdf` and `share_plus` for report generation and sharing

## Supported Detection Scope

Current implementation is built around two crops:

- Tomato
- Rice

The app includes local model assets and disease metadata used to present:

- Predicted disease label
- Confidence score
- Description and symptoms
- Treatment and prevention suggestions
- Reference links for additional reading

## Project Structure

```text
lib/
  main.dart
  models/
  screens/
  services/
  theme/
  widgets/
assets/
  images/
  lottie/
  models/
test/
```

Key areas:

- `lib/screens/`: app flow such as onboarding, dashboard, camera, results, history, library, and settings
- `lib/services/tflite_service.dart`: model loading and image classification
- `lib/services/detection_history_service.dart`: local history management
- `lib/services/pdf_service.dart`: PDF report generation
- `lib/services/language_service.dart`: English and Indonesian language switching
- `lib/models/detection_result.dart`: disease metadata and treatment content

## Getting Started

### Prerequisites

Make sure you have:

- Flutter SDK installed
- Dart SDK included with Flutter
- Android Studio or VS Code
- Android emulator, physical Android device, or another supported Flutter target

Check your Flutter setup:

```bash
flutter doctor
```

### Installation

Clone the repository and install dependencies:

```bash
git clone https://github.com/Alifferdiansyah334/PlantifyAI.git
cd PlantifyAI
flutter pub get
```

### Run the App

```bash
flutter run
```

## Build

Build an Android APK:

```bash
flutter build apk
```

Build an Android App Bundle:

```bash
flutter build appbundle
```

## Testing

Run tests with:

```bash
flutter test
```

## Notes

- Model files are expected under `assets/models/`.
- Camera permission is required for live image capture.
- Detection runs on-device, so performance depends on the target device.
- This project currently uses local/static disease and article data bundled in the app.

## Roadmap Ideas

- Add more crop models and disease classes
- Improve model evaluation documentation
- Add offline-first sync for history and reports
- Add screenshots and demo GIFs to this README
- Add CI for formatting, analysis, and tests

## Contributing

Contributions are welcome through issues and pull requests. If you plan to make larger changes, open a discussion first so the scope stays aligned with the app direction.

## License

No license file is currently included in this repository. Add one if you want to define reuse terms explicitly.
