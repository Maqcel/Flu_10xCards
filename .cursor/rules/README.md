# Cursor Rules Documentation

This project uses Cursor AI rules to maintain code consistency and best practices across the Flutter application.

## Overview

The rules are organized into modular files in `.cursor/rules/` directory:

- **shared.mdc** - Global rules, architecture patterns, tech stack
- **page.mdc** - UI layer rules (Pages, Views, Widgets)
- **cubit.mdc** - State management rules (Cubits, States)
- **service.mdc** - Data layer rules (Services, Data Sources, DTOs)
- **l10n.mdc** - Localization rules (ARB files, translations)
- **testing.mdc** - Testing guidelines (Mocking, Widget tests, Cubit tests)

## Key Concepts

### AppFailure

All errors in the application use `AppFailure` sealed class instead of throwing exceptions:

```dart
// Located at: lib/app/failures/app_failure.dart
@freezed
abstract class AppFailure with _$AppFailure {
  const factory AppFailure.network({String? message}) = _Network;
  const factory AppFailure.server({String? message}) = _Server;
  const factory AppFailure.validation({String? message}) = _Validation;
  const factory AppFailure.unauthorized({String? message}) = _Unauthorized;
  const factory AppFailure.notFound({String? message}) = _NotFound;
  const factory AppFailure.cache({String? message}) = _Cache;
  const factory AppFailure.unexpected({String? message}) = _Unexpected;
}

// Usage with localized messages
Text(failure.userMessage(context))
```

### AppDimensions

All UI dimensions use `AppDimensions` class for responsive design with flutter_screenutil:

```dart
// Located at: lib/presentation/styles/app_dimensions.dart
abstract class AppDimensions {
  static double get h64 => 64.h;
  static double get w200 => 200.w;
  static double get padding16 => 16.w;
  static double get fontSize24 => 24.sp;
  // ... more dimensions
}

// Usage in widgets:
Container(
  height: AppDimensions.h64,
  padding: EdgeInsets.all(AppDimensions.padding16),
  child: Text('Hello', style: TextStyle(fontSize: AppDimensions.fontSize24)),
)
```

**Never use magic numbers directly in UI code!**

### Localization (l10n)

All user-facing strings are defined in ARB files and accessed via context:

```dart
// ARB file structure (lib/l10n/arb/app_en.arb)
{
  "@@locale": "en",
  "@@@____LOGIN___START": {},
  "loginEmailLabel": "Email",
  "loginPasswordLabel": "Password",
  "loginSubmitButton": "Sign In",
  "@@@____LOGIN___END": {}
}

// Usage in code
final l10n = context.l10n;
Text(l10n.loginEmailLabel)
TextField(hintText: l10n.loginPasswordLabel)
ElevatedButton(
  onPressed: () {},
  child: Text(l10n.loginSubmitButton),
)

// With placeholders
Text(l10n.welcomeMessage('John'))
```

**Never hardcode strings in UI code!**

## Feature Structure

Each feature follows Clean Architecture with this structure:

```
features/
  feature_name/
    data/
      dto/              # DTOs with freezed + json_serializable
      data_source/      # Retrofit API clients
      service/          # Service implementations
    domain/
      model/            # Domain models with freezed
      usecase/          # Business logic
    presentation/
      cubit/            # State management
      view/             # UI Pages and Views
      widgets/          # Feature-specific widgets
```

### Data Layer (DTOs)

```dart
@freezed
abstract class FeatureDto with _$FeatureDto {
  const factory FeatureDto({
    required String id,
    required String name,
    @JsonKey(name: 'created_at') DateTime? createdAt,
  }) = _FeatureDto;

  factory FeatureDto.fromJson(Map<String, dynamic> json) =>
      _$FeatureDtoFromJson(json);
}
```

### Data Source (Retrofit)

```dart
@RestApi()
abstract class FeatureServiceDataSource {
  factory FeatureServiceDataSource(Dio dio, {String baseUrl}) =
      _FeatureServiceDataSource;

  @GET('/api/features/{id}')
  Future<FeatureDto> fetchFeature(@Path('id') String id);
}

@module
abstract class FeatureServiceModule {
  @LazySingleton()
  FeatureServiceDataSource provideDataSource(
    @Named('baseUrl') String baseUrl,
    @Named('mainDio') Dio dio,
  ) => FeatureServiceDataSource(dio, baseUrl: baseUrl);
}
```

### Service Layer

```dart
@LazySingleton(as: FeatureService)
class FeatureServiceImpl implements FeatureService {
  FeatureServiceImpl({required FeatureServiceDataSource dataSource})
      : _dataSource = dataSource;

  final FeatureServiceDataSource _dataSource;

  @override
  Future<FeatureModel> getFeature(String id) async {
    try {
      final dto = await _dataSource.fetchFeature(id);
      return dto.toDomain();
    } on DioException catch (e) {
      throw AppFailure.network(message: 'Failed: ${e.message}');
    }
  }
}
```

### Domain Layer

```dart
@freezed
abstract class FeatureModel with _$FeatureModel {
  const factory FeatureModel({
    required String id,
    required String name,
    DateTime? createdAt,
  }) = _FeatureModel;
}
```

### State Management

```dart
// Cubit
@injectable
class FeatureCubit extends Cubit<FeatureState> {
  FeatureCubit({required GetFeatureUseCase getFeature})
      : _getFeature = getFeature,
        super(const FeatureState.initial());

  final GetFeatureUseCase _getFeature;

  Future<void> loadData() async {
    emit(const FeatureState.loading());
    try {
      final data = await _getFeature();
      emit(FeatureState.loaded(data));
    } on AppFailure catch (failure) {
      emit(FeatureState.error(failure));
    }
  }
}

// State
part of 'feature_cubit.dart';

@freezed
abstract class FeatureState with _$FeatureState {
  const factory FeatureState.initial() = _Initial;
  const factory FeatureState.loading() = _Loading;
  const factory FeatureState.loaded(FeatureModel data) = _Loaded;
  const factory FeatureState.error(AppFailure failure) = _Error;
}
```

### Presentation Layer

```dart
// Page
@RoutePage()
class FeaturePage extends StatelessWidget
    implements AutoRouteWrapper, ExtensionMixin {
  const FeaturePage({super.key});

  @override
  Widget wrappedRoute(BuildContext context) => BlocProvider<FeatureCubit>(
    create: (context) => getIt<FeatureCubit>()..init(),
    child: this,
  );

  @override
  Widget build(BuildContext context) => const FeatureView();
}

// View (logic-free, uses l10n)
class FeatureView extends StatelessWidget {
  const FeatureView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    
    return Scaffold(
      appBar: AppBar(title: Text(l10n.featureTitle)),
      body: Padding(
        padding: EdgeInsets.all(AppDimensions.padding16),
        child: BlocBuilder<FeatureCubit, FeatureState>(
          builder: (context, state) {
            return state.when(
              initial: () => const CircularProgressIndicator(),
              loading: () => const CircularProgressIndicator(),
              loaded: (data) => FeatureContent(data: data),
              error: (failure) => ErrorWidget(
                message: failure.userMessage(context),
              ),
            );
          },
        ),
      ),
    );
  }
}
```

## Code Generation

After creating DTOs, Models, Cubits, Routes, or ARB files, run:

```bash
# For freezed, json_serializable, retrofit, injectable
dart run build_runner build --delete-conflicting-outputs

# For localization (ARB files)
flutter gen-l10n
```

This generates:
- `.freezed.dart` files for freezed models
- `.g.dart` files for json_serializable
- `.g.dart` files for retrofit
- `.config.dart` for injectable
- `.gr.dart` for auto_route
- `app_localizations*.dart` for l10n

## Best Practices

1. **No Magic Numbers**: Always use `AppDimensions`
2. **No Hardcoded Strings**: Always use `context.l10n`
3. **Error Handling**: Always use `AppFailure`, never throw raw exceptions
4. **Dependency Injection**: Use `@injectable` and get_it
5. **Navigation**: Use auto_route with `@RoutePage()`
6. **State Management**: Use Cubit with freezed states
7. **Immutability**: Use freezed for all data classes
8. **Views are Logic-Free**: Pass callbacks, don't implement logic in views
9. **Clean Architecture**: Respect layer boundaries (domain → data → presentation)
10. **Localization**: Organize ARB files with section markers
11. **Testing**: Mock all dependencies, register mocks in GetIt for Page tests

## Testing

### Mock Naming Conventions

- **Mock classes**: Prefix with `Mock` (e.g., `MockCounterCubit`, `MockAuthService`)
- **Mock instances**: Use `mock` prefix in camelCase (e.g., `mockCounterCubit`, `mockAuthService`)

### Testing Pages (with GetIt)

```dart
import 'package:xcards/app/di/injection.dart';

void main() {
  group('FeaturePage', () {
    late FeatureCubit mockFeatureCubit;

    setUp(() {
      mockFeatureCubit = MockFeatureCubit();
      getIt.registerFactory<FeatureCubit>(() => mockFeatureCubit);
    });

    tearDown(() {
      getIt.unregister<FeatureCubit>();
    });

    testWidgets('renders FeatureView', (tester) async {
      when(() => mockFeatureCubit.state).thenReturn(FeatureState.initial());
      await tester.pumpApp(const FeaturePage());
      expect(find.byType(FeatureView), findsOneWidget);
    });
  });
}
```

### Testing Views (without GetIt)

```dart
void main() {
  group('FeatureView', () {
    late FeatureCubit mockFeatureCubit;

    setUp(() {
      mockFeatureCubit = MockFeatureCubit();
    });

    testWidgets('displays data correctly', (tester) async {
      when(() => mockFeatureCubit.state)
          .thenReturn(FeatureState.loaded(data));
      
      await tester.pumpApp(
        BlocProvider.value(
          value: mockFeatureCubit,
          child: const FeatureView(),
        ),
      );
      
      expect(find.text('expected text'), findsOneWidget);
    });
  });
}
```

### Testing Cubits

```dart
blocTest<FeatureCubit, FeatureState>(
  'emits [loading, loaded] when loadData succeeds',
  build: () {
    when(() => mockGetFeatureData())
        .thenAnswer((_) async => mockData);
    return FeatureCubit(getFeatureData: mockGetFeatureData);
  },
  act: (cubit) => cubit.loadData(),
  expect: () => [
    const FeatureState.loading(),
    FeatureState.loaded(mockData),
  ],
);
```

**Key Testing Rules:**
- Always register mocks in `setUp()` with `getIt.registerFactory<T>()`
- Always unregister in `tearDown()` with `getIt.unregister<T>()`
- Mock cubit state before calling `pumpApp()`
- Test all state variations (initial, loading, loaded, error)
- Use `blocTest` for comprehensive cubit testing
- See **testing.mdc** for complete testing guidelines

## Additional Resources

- [freezed package](https://pub.dev/packages/freezed)
- [injectable package](https://pub.dev/packages/injectable)
- [auto_route package](https://pub.dev/packages/auto_route)
- [retrofit package](https://pub.dev/packages/retrofit)
- [flutter_screenutil package](https://pub.dev/packages/flutter_screenutil)
- [Flutter localization guide](https://docs.flutter.dev/development/accessibility-and-localization/internationalization)
