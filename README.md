# Bockaire

A smart shipping optimizer for planning and calculating shipments from China to Germany. Built with Flutter for cross-platform support.

## Features

- 📦 **Shipment Management**: Create and manage shipments with detailed carton information
- 💰 **Multi-Carrier Quotes**: Get instant quotes from DHL, UPS, and FedEx
- 🎯 **Intelligent Optimization**: AI-powered recommendations for optimal shipping routes
- 🗣️ **Voice Input**: Add shipment details using voice commands (Gemini & Whisper support)
- 🌍 **Multi-Language**: Support for English, German, Spanish, French, and Chinese
- 💱 **Multi-Currency**: Display costs in EUR, USD, or GBP
- 🎨 **Theme Support**: Light, dark, and system theme modes
- 📊 **Cost Breakdown**: Detailed analysis of shipping costs and fees

## Technology Stack

- **Frontend**: Flutter 3.x
- **State Management**: Riverpod
- **Database**: SQLite (Drift)
- **AI Integration**:
  - Gemini API for audio transcription and parsing
  - Local Whisper server for offline transcription
- **Localization**: flutter_localizations with arb files

## Getting Started

### Prerequisites

- Flutter SDK 3.9.2 or higher
- Dart SDK 3.9.2 or higher

### Installation

1. Clone the repository:
```bash
git clone https://github.com/yourusername/bockaire.git
cd bockaire
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Configuration

#### AI Services

To use voice input features, configure your AI provider:

1. **Gemini API** (Cloud-based):
   - Get an API key from [Google AI Studio](https://makersuite.google.com/app/apikey)
   - Add the key in Settings > AI Settings

2. **Whisper Server** (Local):
   - See `whisper_server/README.md` for setup instructions
   - Configure base URL in Settings > AI Settings

## Project Structure

```
lib/
├── classes/          # Data models (Shipment, Carton, Quote, etc.)
├── database/         # SQLite database schema and migrations
├── features/         # Feature modules
│   └── settings/    # Settings pages and UI
├── pages/           # Main app pages
├── providers/       # Riverpod state providers
├── services/        # Business logic and API services
│   ├── ai_provider_interfaces.dart
│   ├── gemini_audio_transcription_service.dart
│   ├── location_voice_parser_service.dart
│   └── carton_voice_parser_service.dart
├── widgets/         # Reusable UI components
└── l10n/           # Localization files (ARB)
```

## Voice Input

Bockaire supports voice input for quick shipment entry:

- **Location Input**: "From Shanghai to Hamburg"
- **Carton Dimensions**: "50 by 30 by 20 centimeters, 5 kilos, quantity 10, laptops"

The app uses AI to parse natural language and extract structured data automatically.

## Testing

Run all tests:
```bash
flutter test
```

Run specific test suites:
```bash
flutter test test/services/
flutter test test/database/
flutter test test/widgets/
```

## Localization

The app supports multiple languages. To add a new language:

1. Create a new ARB file in `lib/l10n/`
2. Add translations for all keys
3. Update `l10n.yaml` if needed
4. Run `flutter gen-l10n`

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is private and proprietary.
