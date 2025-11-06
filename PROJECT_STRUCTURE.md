# Med Just Flutter Project Structure

This project follows a clean architecture pattern with feature-based organization.

## Key Features Implemented:

### 🏗️ Core Architecture
- **Constants**: Colors, text styles, and app constants
- **Models**: Data models for all entities (User, Year, Subject, etc.)
- **Services**: Firebase, Authentication, and Storage services
- **Utils**: Validators and helper functions
- **Routes**: Centralized routing configuration

### 🎨 UI Components
- **Themes**: Light and dark theme support
- **Widgets**: Custom buttons, text fields, and loading indicators

### 🔐 Authentication
- Login and registration pages
- BLoC pattern for state management
- Form validation and error handling

### 🏠 Home Dashboard
- Grid-based navigation menu
- Feature access points
- Responsive design

### 📚 Educational Features (Placeholders)
- Years management
- Subjects organization
- Lectures and videos
- File management
- Quizzes system

### 👨‍⚕️ Additional Features (Placeholders)
- Professors directory
- News and updates
- Store functionality
- GPA calculator
- University map

## Architecture Pattern:
```
lib/
├── core/           # Shared business logic
├── features/       # Feature-specific modules
│   └── [feature]/
│       ├── data/       # Repositories
│       ├── bloc/       # State management
│       ├── presentation/ # UI screens
│       └── widgets/    # Feature widgets
└── shared/         # Shared UI components
```

## Next Steps:
1. Add proper dependencies in pubspec.yaml
2. Implement actual Firebase integration
3. Add proper BLoC package integration
4. Implement remaining features
5. Add unit and widget tests
6. Set up CI/CD pipeline

## Dependencies Needed:
- flutter_bloc
- firebase_core
- firebase_auth
- cloud_firestore
- shared_preferences
- http
- cached_network_image
- flutter_launcher_icons