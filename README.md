<div align="center">
  <img src="assets/images/logo.png" alt="Plantify AI Logo" width="140" />
  <h1>Plantify AI</h1>
  <p><strong>Flutter-based plant disease detection app for tomato and rice crops.</strong></p>
  <p>On-device AI diagnosis, treatment guidance, article library, PDF reports, and bilingual support.</p>

  <p>
    <img src="https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white" alt="Flutter" />
    <img src="https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart&logoColor=white" alt="Dart" />
    <img src="https://img.shields.io/badge/TensorFlow%20Lite-On--Device%20Inference-FF6F00?logo=tensorflow&logoColor=white" alt="TensorFlow Lite" />
    <img src="https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-2E7D32" alt="Platforms" />
  </p>

  <p>
    <img src="https://img.shields.io/badge/State%20Management-Provider-5C6BC0" alt="Provider" />
    <img src="https://img.shields.io/badge/Camera-Capture%20%26%20Gallery-6D4C41" alt="Camera" />
    <img src="https://img.shields.io/badge/Reports-PDF%20Export-D32F2F" alt="PDF Export" />
    <img src="https://img.shields.io/badge/Language-English%20%26%20Indonesian-00897B" alt="Language" />
  </p>
</div>

## Overview

Plantify AI is a mobile app built with Flutter to help users identify plant diseases from leaf images. The app runs TensorFlow Lite models directly on-device, then presents a prediction with confidence score, disease explanation, treatment suggestions, and supporting references.

It currently focuses on two crops:

- Tomato
- Rice

## Preview

<p align="center">
  <img src="assets/images/rice_field.jpg" alt="Rice Field" width="31%" />
  <img src="assets/images/fresh_tomatoes.jpg" alt="Fresh Tomatoes" width="31%" />
  <img src="assets/images/tomato_pests.jpg" alt="Tomato Plant" width="31%" />
</p>

## Features

| Feature | Description |
| --- | --- |
| AI disease detection | Runs local TensorFlow Lite models for image classification |
| Crop-based flow | Lets users choose between tomato and rice before diagnosis |
| Camera and gallery input | Supports direct capture or selecting an existing image |
| Image cropping | Crops leaf photos before inference for better focus |
| Rich result screen | Shows disease label, confidence, symptoms, and treatment guidance |
| Detection history | Saves previous diagnoses locally on the device |
| Article library | Includes educational content related to crops and plant care |
| PDF export | Generates reports that can be shared externally |
| Bilingual support | English and Indonesian language experience |
| Theme support | Includes light and dark themes |

## Tech Stack

<p>
  <img src="https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white" alt="Flutter Framework" />
  <img src="https://img.shields.io/badge/Dart-Language-0175C2?logo=dart&logoColor=white" alt="Dart Language" />
  <img src="https://img.shields.io/badge/Provider-State%20Management-5C6BC0" alt="Provider" />
  <img src="https://img.shields.io/badge/TFLite-ML%20Inference-FF6F00?logo=tensorflow&logoColor=white" alt="TFLite" />
  <img src="https://img.shields.io/badge/Shared%20Preferences-Local%20Storage-7B1FA2" alt="Shared Preferences" />
  <img src="https://img.shields.io/badge/PDF-Report%20Generation-D32F2F" alt="PDF" />
  <img src="https://img.shields.io/badge/Share%20Plus-File%20Sharing-455A64" alt="Share Plus" />
</p>

Main packages used in this project:

- `provider`
- `camera`
- `image_picker`
- `image_cropper`
- `image`
- `tflite_flutter`
- `shared_preferences`
- `pdf`
- `share_plus`
- `toastification`

## Detection Pipeline

1. User selects a crop.
2. User captures or imports a leaf image.
3. The image is cropped and preprocessed.
4. A TensorFlow Lite model is loaded from `assets/models/`.
5. The app runs on-device inference.
6. The result screen displays diagnosis details and treatment suggestions.
7. The diagnosis can be saved into history or exported as a PDF report.

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

Important modules:

- `lib/screens/` contains the main app flow such as onboarding, dashboard, camera, result, history, library, and settings
- `lib/services/tflite_service.dart` handles model loading and image classification
- `lib/services/detection_history_service.dart` manages saved diagnosis history
- `lib/services/pdf_service.dart` generates PDF reports
- `lib/services/language_service.dart` manages English and Indonesian content
- `lib/models/detection_result.dart` stores disease metadata, recommendations, and references

## Getting Started

### Prerequisites

Make sure the following tools are available:

- Flutter SDK
- Dart SDK
- Android Studio or VS Code
- Emulator or physical device for testing

Check your environment:

```bash
flutter doctor
```

### Installation

```bash
git clone https://github.com/Alifferdiansyah334/PlantifyAI.git
cd PlantifyAI
flutter pub get
```

### Run

```bash
flutter run
```

## Build Commands

```bash
flutter build apk
flutter build appbundle
```

## Testing

```bash
flutter test
```

## Notes

- Model assets are expected under `assets/models/`
- Camera permission is required for live image capture
- Inference runs on-device, so performance depends on the target hardware
- Disease descriptions and article content are currently bundled locally in the app

## Future Improvements

- Add actual app screenshots or device mockups
- Expand support to more crops and disease classes
- Document model training and evaluation results
- Add CI for linting, testing, and release checks
- Improve offline content synchronization

## Contributing

Issues and pull requests are welcome. For larger changes, open an issue first so the implementation direction is clear before work begins.

## License

This repository does not currently include a license file. Add one if you want to define usage and distribution terms explicitly.
