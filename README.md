# Smart Attendance System

A comprehensive QR-based attendance management system built with Flutter. This application allows teachers to generate QR codes for classes and students to scan them to mark their attendance. The system includes student management, subject management, analytics, and CSV export functionality.

## Features

### Core Features
- **QR Code Generation**: Teachers can generate QR codes for specific subjects
- **QR Code Scanning**: Students can scan QR codes to mark attendance
- **Student Management**: Add, edit, and delete student records
- **Subject Management**: Manage subjects with codes and descriptions
- **Attendance Tracking**: View all attendance records with filtering and search
- **Analytics Dashboard**: View statistics and charts for attendance data
- **CSV Export**: Export attendance data to CSV format
- **Duplicate Prevention**: Prevents students from marking attendance twice for the same session

### Technical Features
- **Cross-Platform**: Works on Android, iOS, Web, Windows, Linux, and macOS
- **Local Storage**: Uses Hive for efficient local data storage
- **State Management**: Provider pattern for reactive state management
- **Modern UI**: Material Design 3 with light/dark theme support
- **Real-time Updates**: Live updates using Provider state management

## Project Structure

```
lib/
├── models/              # Data models
│   ├── attendance_model.dart
│   ├── student_model.dart
│   ├── subject_model.dart
│   └── qr_session_model.dart
├── providers/           # State management
│   ├── attendance_provider.dart
│   ├── student_provider.dart
│   ├── subject_provider.dart
│   └── qr_provider.dart
├── screens/             # UI screens
│   ├── home_screen.dart
│   ├── generate_qr_screen.dart
│   ├── scan_qr_screen.dart
│   ├── attendance_list_screen.dart
│   ├── students_screen.dart
│   ├── subjects_screen.dart
│   └── analytics_screen.dart
├── services/            # Business logic
│   ├── storage_service.dart
│   ├── attendance_service.dart
│   └── qr_service.dart
├── helpers/             # Utility functions
│   ├── csv_helper.dart
│   └── storage_helper.dart
├── theme/               # App theming
│   └── app_theme.dart
└── main.dart            # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.2.0)
- Dart SDK
- Android Studio / VS Code with Flutter extensions
- For mobile development: Android SDK or Xcode (for iOS)

### Installation

1. Clone the repository:
```bash
git clone <repository-url>
cd myapp
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

### Building for Production

#### Android
```bash
flutter build apk --release
```

#### iOS
```bash
flutter build ios --release
```

#### Web
```bash
flutter build web
```

#### Windows
```bash
flutter build windows
```

## Usage Guide

### For Teachers

1. **Add Subjects**: Navigate to "Subjects" and add subjects you teach
2. **Add Students**: Go to "Students" and add student records
3. **Generate QR Code**: 
   - Go to "Generate QR"
   - Select a subject
   - Display the QR code to students
4. **View Attendance**: Check "View Attendance" to see all records
5. **Analytics**: View statistics in the "Analytics" screen
6. **Export Data**: Use the export button in attendance list to save as CSV

### For Students

1. **Scan QR Code**: 
   - Open "Scan QR"
   - Point camera at the QR code
   - Select your name from the dropdown
   - Mark attendance

## Dependencies

- `flutter`: Flutter SDK
- `provider`: State management
- `qr_flutter`: QR code generation
- `mobile_scanner`: QR code scanning (supports Windows)
- `hive` & `hive_flutter`: Local database
- `csv`: CSV file generation
- `path_provider`: File system paths
- `share_plus`: File sharing
- `intl`: Date formatting
- `fl_chart`: Charts and graphs
- `uuid`: Unique ID generation

## Architecture

The app follows a clean architecture pattern:

- **Models**: Data classes with Hive adapters
- **Services**: Business logic and data operations
- **Providers**: State management using Provider pattern
- **Screens**: UI components
- **Helpers**: Utility functions

## Data Storage

The app uses Hive for local storage. All data is stored locally on the device:
- Attendance records
- Student information
- Subject information
- QR session data

## Future Enhancements

- [ ] Cloud sync functionality
- [ ] User authentication
- [ ] Multiple class/group support
- [ ] Email notifications
- [ ] Attendance reports generation
- [ ] Biometric authentication
- [ ] Offline mode improvements
- [ ] Multi-language support

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

## License

This project is licensed under the MIT License.

## Support

For issues and questions, please open an issue on the repository.

## Version History

- **v2.0.0**: Major update with new architecture, analytics, and enhanced features
- **v1.0.0**: Initial release with basic QR attendance functionality
