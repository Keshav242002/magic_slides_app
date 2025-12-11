# MagicSlides Flutter App

A Flutter mobile application for generating AI-powered presentations using the MagicSlides API.

## Features

- User authentication (signup/login) with Supabase
- Generate presentations from topics
- Choose from 10+ templates (Default/Editable)
- Customize slide count, language, AI model, and more
- Preview PDF in-app
- Download PowerPoint files
- Dark/Light theme toggle
- Persistent login sessions

## How to Run

### Prerequisites
- Flutter SDK (3.0.0 or higher)
- Android Studio or VS Code
- Supabase account
- MagicSlides API access ID

### Setup

1. **Clone the repository**
```bash
   git clone <repository-url>
   cd magic_slide
```

2. **Install dependencies**
```bash
   flutter pub get
```

3. **Configure Supabase**

   Open `lib/core/services/supabase_service.dart` and add your credentials:
```dart
   url:  'YOUR_SUPABASE_PROJECT_URL',
   anonKey: 'YOUR_SUPABASE_ANON_KEY',
```

4. **Configure MagicSlides API**

   Open `lib/core/constants/api_constants.dart` and add your access ID:
```dart
   static const String accessId = 'YOUR_ACCESS_ID_HERE';
```

5. **Run the app**
```bash
   flutter run
```

### Build APK
```bash
flutter build apk 
```

## Database Used

**Supabase (PostgreSQL)**

- Used for user authentication (email/password)
- Handles session management automatically
- Stores user data in `auth.users` table
- No manual database setup required - Supabase handles everything

**Local Storage**
- SharedPreferences for persistent login state
- Stores theme preferences

## Architecture

### Design Pattern: MVVM + BLoC
```
Presentation Layer (UI)
├── Screens (Views)
├── Widgets (Reusable components)
└── BLoC (Business logic & state management)

Data Layer
├── Models (DTOs)
└── Repositories (Data access)

Core Layer
├── Services (Supabase, Storage)
├── Network (API client with Dio)
└── Utils (Validators, helpers)
```

### State Management: BLoC Pattern

Each feature has its own BLoC with three states:
- **Loading**: Shows loading indicators
- **Success**: Shows data/UI
- **Error**: Shows error messages

Example flow:
```
User Action → Event → BLoC → API Call → State Change → UI Update
```

### Key Components

**Authentication**
- `AuthBloc`: Manages login/signup/logout
- `AuthRepository`: Handles Supabase auth calls
- `SupabaseService`: Supabase SDK wrapper

**Presentation Generation**
- `PptBloc`: Manages PPT generation and downloads
- `PptRepository`: API calls to MagicSlides
- `ApiHelper`: Centralized Dio HTTP client

**UI**
- Custom reusable widgets (buttons, text fields)
- Shimmer loading effects
- Theme management with Cubit

## Project Structure
```
lib/
├── main.dart
├── config/
│   ├── theme/          # App theming
│   └── routes/         # Navigation
├── core/
│   ├── constants/      # API & app constants
│   ├── network/        # HTTP client & response wrapper
│   ├── services/       # Supabase & storage services
│   └── utils/          # Validators & helpers
├── data/
│   ├── models/         # Request/response models
│   └── repositories/   # Data access layer
└── presentation/
    ├── screens/        # UI screens + BLoC
    └── widgets/        # Reusable components
```

## API Integration

**Endpoint**: `https://api.magicslides.app/public/api/ppt_from_topic`

**Parameters Supported**:
- Topic, template, language
- Slide count (1-50)
- AI model (GPT-4/GPT-3.5)
- Image options (AI images, Google images)
- Watermark configuration

**Response**: Returns both PowerPoint (.pptx) and PDF (.pdf) URLs

## Known Issues

### 1. Template Name Sensitivity
- Template names are case-sensitive
- Names with spaces work (e.g., "Custom gold 1")
- Use exact names from the template list

### 2. Generation Timeout
- Complex presentations (15+ slides with AI images) may take 5-10 minutes
- Increased timeout to 8 minutes to handle this
- Use simpler settings for faster results

### 3. Android File Access
- Files save to: `/Android/data/com.your.app/files/MagicSlides/`
- Android 10+ doesn't need special permissions
- Auto-opens after download

### 4. PDF Preview
- Only works if API returns `pdfUrl`
- Some templates may not generate PDF preview
- PowerPoint download still works

### 5. API Errors
- "Internal server error" sometimes occurs with certain templates
- Retry with a different template if this happens
- Tested working templates: `bullet-point1`, `ed-bullet-point1`

## Testing Credentials

For testing (create via signup):
```
Email: test@example.com
Password: test123
```

## Technology Stack

- **Flutter**: 3.0+
- **State Management**: flutter_bloc
- **Authentication**: Supabase
- **HTTP Client**: Dio
- **PDF Viewer**: Syncfusion
- **Local Storage**: SharedPreferences

## Performance Optimizations

- BLoC pattern prevents unnecessary widget rebuilds
- Shimmer effects for better loading UX
- Lazy loading of services
- Efficient list rendering
- Image caching

## Code Quality

- MVVM architecture with clear separation
- Type-safe throughout
- Comprehensive error handling
- Clean code principles (DRY, SOLID)
- No redundant code

## Development

**Run in debug mode**:
```bash
flutter run
```
## Troubleshooting

### "Package not found" error
```bash
flutter clean
flutter pub get
```

### "Supabase initialization failed"
- Check Supabase URL and anon key
- Ensure internet connection
- Verify credentials in supabase_service.dart

### "API timeout"
- Check internet connection
- Verify access ID is correct
- Try with fewer slides/simpler options

### Build fails
```bash
flutter clean
flutter pub get
flutter build apk
```

## Contact

For issues or questions, refer to:
- MagicSlides API docs: https://www.magicslides.app/docs-api
- Supabase docs: https://supabase.com/docs

---

**Note**: Replace `YOUR_SUPABASE_PROJECT_URL`, `YOUR_SUPABASE_ANON_KEY`, and `YOUR_ACCESS_ID_HERE` with actual values before running.