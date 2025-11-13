# UI Architecture Plan – 10xCards (Flutter)

## 1. Overview
Mobile-first flashcard app using Clean Architecture. Key goals:
• Smooth creation (manual & AI) and spaced-repetition learning
• Simple, modern Material UI
• Portrait-only; ScreenUtil for future tablet scaling

## 2. Navigation Map
Primary navigation via BottomNavigationBar (Material 3):
1. Dashboard
2. Learn
3. Stats
4. Settings

Global AppBar (on Dashboard & Learn) with trailing "➕" (Icons.add) opening **GenerationPage**.

Route hierarchy (auto_route):
```
SplashPage -> (AuthFlow) -> MainShell
MainShell (BottomBar) children:
  ├── DashboardRouter
  │     └── DashboardPage
  ├── LearnRouter
  │     └── LearningSessionPage
  ├── StatsRouter
  │     └── StatisticsPage
  └── SettingsRouter
        └── SettingsPage
GenerationPage (fullscreen dialog route)
FlashcardEditorPage (modal route)
```

## 3. Screens & Responsibilities
| Screen | Purpose |
|--------|---------|
| **DashboardPage** | List of decks, quick statistics, CTA to start learning |
| **LearningSessionPage** | Swipe-based study session using SR algorithm |
| **GenerationPage** | Text input → call API → review proposals → save flashcards |
| **StatisticsPage** | Generation stats only (pulled from BE) |
| **SettingsPage** | Profile, delete account, theme toggle |
| **FlashcardEditorPage** | CRUD single card |
| **Auth Pages** | Sign-in / sign-up |

## 4. Reusable Widgets (presentation/common_widgets)
• PrimaryButton, SecondaryButton, IconButton  
• CardContainer, StatCard, EmptyState  
• AppBarTitle, BottomNavBar  
• TextField, MultilineInput with validation  
• LoadingIndicator, ErrorView, RetryButton

_All widgets **must** use spacing from `AppDimensions` and text styles from `AppTextStyles`._

## 5. Design System
### 5.1 Color Scheme Extension
Create `ColorSchemeExtension` extending `ThemeExtension<ColorSchemeExtension>`:
```dart
@immutable
class ColorSchemeExtension extends ThemeExtension<ColorSchemeExtension> {
  final Color mainWhite;
  final Color mainBlack;
  final Color accentBlue;
  // ... add as needed

  const ColorSchemeExtension({required this.mainWhite, required this.mainBlack, required this.accentBlue});

  @override
  ColorSchemeExtension copyWith({Color? mainWhite, Color? mainBlack, Color? accentBlue}) =>
      ColorSchemeExtension(
        mainWhite: mainWhite ?? this.mainWhite,
        mainBlack: mainBlack ?? this.mainBlack,
        accentBlue: accentBlue ?? this.accentBlue,
      );

  @override
  ColorSchemeExtension lerp(ThemeExtension<ColorSchemeExtension>? other, double t) {
    if (other is! ColorSchemeExtension) return this;
    return ColorSchemeExtension(
      mainWhite: Color.lerp(mainWhite, other.mainWhite, t)!,
      mainBlack: Color.lerp(mainBlack, other.mainBlack, t)!,
      accentBlue: Color.lerp(accentBlue, other.accentBlue, t)!,
    );
  }

  // Light & Dark presets
  static const light = ColorSchemeExtension(
    mainWhite: Color(0xFFFFFFFF),
    mainBlack: Color(0xFF000000),
    accentBlue: Color(0xFF0066FF),
  );

  static const dark = ColorSchemeExtension(
    mainWhite: Color(0xFF1B1B1B),
    mainBlack: Color(0xFFFFFFFF),
    accentBlue: Color(0xFF4C8DFF),
  );
}
```

### 5.2 ThemeData Factories
Create helpers in `presentation/styles/app_theme.dart`:
```dart
ThemeData lightTheme() => ThemeData(
  brightness: Brightness.light,
  extensions: const [ColorSchemeExtension.light],
  useMaterial3: true,
);

ThemeData darkTheme() => ThemeData(
  brightness: Brightness.dark,
  extensions: const [ColorSchemeExtension.dark],
  useMaterial3: true,
);
```

### 5.3 Typography & Spacing
• Declare text styles in `AppTextStyles` using Google Fonts / Material styles  
• Spacing tokens in `AppDimensions` (already exists) – always reference via `AppDimensions.h16`, etc.

## 6. Responsiveness & Orientation
• Initialize `ScreenUtil` in `app.dart` root; design size reference 375×812.  
• Widgets use `.w` `.h` `.sp`.  
• Application locked to portrait in `bootstrap.dart` (`SystemChrome.setPreferredOrientations`).

## 7. Package Dependencies
```yaml
dependencies:
  flutter:
    sdk: flutter
  flutter_screenutil: ^5.8.4
  flutter_bloc: ^8.1.3
  equatable: ^2.0.5
  get_it: ^7.6.0
  auto_route: ^7.8.4
  google_fonts: ^6.1.0
```

## 8. Next Steps
1. Solidify color palette (update `ColorSchemeExtension`).
2. Scaffold navigation shell with BottomBar & AppBar action.
3. Implement GenerationPage plan (separate doc).
4. Build base widgets & integrate ScreenUtil.

---
_Last updated: 2025-11-12_
