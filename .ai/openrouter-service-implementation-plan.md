---
title: "Plan implementacji serwisu OpenRouter dla 10xCards"
project: "10xCards - Flutter Flashcard App"
created: "2024-11-13"
tech_stack: "Flutter, Dart, Dio, Freezed, Get_it, BLoC/Cubit"
---

# Plan implementacji serwisu OpenRouter

## 1. Przegląd i cel

### 1.1 Kontekst biznesowy
Integracja z OpenRouter pozwoli aplikacji 10xCards na wykorzystanie modeli AI do:
- Generowania fiszek na podstawie materiałów edukacyjnych
- Tłumaczenia i adaptacji treści
- Sugerowania powiązanych pojęć
- Analizy błędów w nauce i dostosowywania trudności

### 1.2 Wymagania techniczne
- Wykorzystanie OpenRouter jako proxy do różnych modeli AI (GPT-4o-mini, Gemini Flash, Claude, etc.)
- Obsługa structured outputs (JSON Schema)
- Bezpieczne przechowywanie klucza API
- Zgodność z Clean Architecture
- Obsługa błędów i timeout'ów
- Możliwość łatwej wymiany modeli

## 2. Architektura rozwiązania

### 2.1 Struktura katalogów
```
lib/
└── features/
    └── ai_integration/
        ├── data/
        │   ├── dto/
        │   │   ├── openrouter_request_dto.dart
        │   │   ├── openrouter_response_dto.dart
        │   │   └── openrouter_message_dto.dart
        │   ├── data_source/
        │   │   └── openrouter_data_source.dart
        │   └── service/
        │       └── openrouter_service.dart
        ├── domain/
        │   ├── model/
        │   │   ├── ai_message.dart
        │   │   ├── ai_response.dart
        │   │   └── ai_model_config.dart
        │   ├── usecase/
        │   │   └── generate_with_ai_usecase.dart
        │   └── helper/
        │       └── openrouter_chat_helper.dart  # Convenience layer
        └── presentation/
            └── (opcjonalnie - jeśli potrzebny będzie UI dla debugowania)
```

### 2.2 Warstwa Data Layer

#### 2.2.1 DTOs (Data Transfer Objects)
**openrouter_message_dto.dart**
- `role`: String (user, assistant, system)
- `content`: String
- Mapping to/from domain model

**openrouter_request_dto.dart**
- `model`: String (np. "openai/gpt-4o-mini")
- `messages`: List<OpenRouterMessageDto>
- `temperature`: double?
- `max_tokens`: int?
- `response_format`: Map<String, dynamic>? (dla structured outputs)
- `top_p`: double?

**openrouter_response_dto.dart**
- `id`: String
- `model`: String
- `choices`: List<Choice>
- `usage`: Usage (prompt_tokens, completion_tokens, total_tokens)
- `created`: int

#### 2.2.2 Data Source
**openrouter_data_source.dart**
```dart
@RestApi(baseUrl: 'https://openrouter.ai/api/v1')
abstract class OpenRouterDataSource {
  factory OpenRouterDataSource(Dio dio) = _OpenRouterDataSource;
  
  @POST('/chat/completions')
  Future<OpenRouterResponseDto> createChatCompletion(
    @Body() OpenRouterRequestDto request,
  );
}
```

#### 2.2.3 Service
**openrouter_service.dart**
- Abstrakcja nad data source
- Obsługa błędów specyficznych dla OpenRouter
- Konwersja DTO → Domain Models
- Logowanie requestów/responses (opcjonalnie)
- Retry logic dla failed requests

### 2.3 Warstwa Domain Layer

#### 2.3.1 Domain Models

**ai_message.dart**
```dart
@freezed
class AiMessage with _$AiMessage {
  const factory AiMessage({
    required AiMessageRole role,
    required String content,
  }) = _AiMessage;
}

enum AiMessageRole { user, assistant, system }
```

**ai_response.dart**
```dart
@freezed
class AiResponse with _$AiResponse {
  const factory AiResponse({
    required String id,
    required String content,
    required String model,
    required AiUsage usage,
  }) = _AiResponse;
}

@freezed
class AiUsage with _$AiUsage {
  const factory AiUsage({
    required int promptTokens,
    required int completionTokens,
    required int totalTokens,
  }) = _AiUsage;
}
```

**ai_model_config.dart**
```dart
@freezed
class AiModelConfig with _$AiModelConfig {
  const factory AiModelConfig({
    required String modelId,
    @Default(0.7) double temperature,
    @Default(2000) int maxTokens,
    Map<String, dynamic>? responseFormat,
  }) = _AiModelConfig;
  
  // Predefiniowane konfiguracje
  static const gpt4oMini = AiModelConfig(
    modelId: 'openai/gpt-4o-mini',
    temperature: 0.7,
    maxTokens: 2000,
  );
  
  static const geminiFlashFree = AiModelConfig(
    modelId: 'google/gemini-flash-1.5:free',
    temperature: 0.7,
    maxTokens: 2000,
  );
}
```

#### 2.3.2 Use Cases

**generate_with_ai_usecase.dart**
```dart
@injectable
class GenerateWithAiUseCase {
  final OpenRouterService _service;
  
  const GenerateWithAiUseCase(this._service);
  
  Future<Either<AppFailure, AiResponse>> call({
    required List<AiMessage> messages,
    AiModelConfig? config,
  }) async {
    // Implementacja z obsługą błędów
  }
}
```

#### 2.3.3 Convenience Helper (inspirowane planem nauczyciela)

**openrouter_chat_helper.dart**

Warstwa pomocnicza upraszczająca API podobnie do planu nauczyciela. Opcjonalna, ale ułatwia użycie.

```dart
/// Convenience helper dla uproszczonej komunikacji z OpenRouter
/// 
/// Inspirowane planem nauczyciela - oferuje prostsze API
/// z metodami typu setter/send podobnymi do web version.
@injectable
class OpenRouterChatHelper {
  final GenerateWithAiUseCase _generateWithAi;
  
  const OpenRouterChatHelper(this._generateWithAi);
  
  /// Odpowiednik setSystemMessage + setUserMessage + sendChatMessage z planu nauczyciela
  /// 
  /// Przykład użycia:
  /// ```dart
  /// final result = await helper.sendMessage(
  ///   systemMessage: "You are a helpful assistant",
  ///   userMessage: "Generate flashcards about Flutter",
  /// );
  /// ```
  Future<Either<AppFailure, AiResponse>> sendMessage({
    required String systemMessage,
    required String userMessage,
    AiModelConfig? config,
  }) async {
    final messages = [
      AiMessage(role: AiMessageRole.system, content: systemMessage),
      AiMessage(role: AiMessageRole.user, content: userMessage),
    ];
    
    return _generateWithAi(
      messages: messages,
      config: config ?? AiModelConfig.gpt4oMini,
    );
  }
  
  /// Zwraca builder dla chainable API (fluent interface)
  /// 
  /// Przykład użycia:
  /// ```dart
  /// final result = await helper.builder()
  ///   .systemMessage("You are an expert")
  ///   .userMessage("Generate content")
  ///   .withModel(AiModelConfig.geminiFlashFree)
  ///   .withResponseFormat(_buildSchema())
  ///   .send();
  /// ```
  OpenRouterRequestBuilder builder() => OpenRouterRequestBuilder(this);
  
  /// Internal method używana przez builder
  @internal
  Future<Either<AppFailure, AiResponse>> executeRequest({
    required List<AiMessage> messages,
    required AiModelConfig config,
  }) {
    return _generateWithAi(messages: messages, config: config);
  }
}

/// Builder pattern dla fluent API (chainable calls)
class OpenRouterRequestBuilder {
  final OpenRouterChatHelper _helper;
  String? _systemMessage;
  String? _userMessage;
  AiModelConfig _config = AiModelConfig.gpt4oMini;
  
  OpenRouterRequestBuilder(this._helper);
  
  /// Ustawia komunikat systemowy (odpowiednik setSystemMessage z planu nauczyciela)
  OpenRouterRequestBuilder systemMessage(String message) {
    _systemMessage = message;
    return this;
  }
  
  /// Ustawia komunikat użytkownika (odpowiednik setUserMessage z planu nauczyciela)
  OpenRouterRequestBuilder userMessage(String message) {
    _userMessage = message;
    return this;
  }
  
  /// Ustawia konfigurację modelu (odpowiednik setModel z planu nauczyciela)
  OpenRouterRequestBuilder withModel(AiModelConfig config) {
    _config = config;
    return this;
  }
  
  /// Ustawia response format (odpowiednik setResponseFormat z planu nauczyciela)
  OpenRouterRequestBuilder withResponseFormat(Map<String, dynamic> format) {
    _config = _config.copyWith(responseFormat: format);
    return this;
  }
  
  /// Ustawia temperature
  OpenRouterRequestBuilder withTemperature(double temperature) {
    _config = _config.copyWith(temperature: temperature);
    return this;
  }
  
  /// Wysyła request (odpowiednik sendChatMessage z planu nauczyciela)
  Future<Either<AppFailure, AiResponse>> send() async {
    // Walidacja
    if (_systemMessage == null || _userMessage == null) {
      return Left(
        AppFailure.validationError(
          message: 'Both system and user messages must be set',
        ),
      );
    }
    
    // Budowanie messages
    final messages = [
      AiMessage(role: AiMessageRole.system, content: _systemMessage!),
      AiMessage(role: AiMessageRole.user, content: _userMessage!),
    ];
    
    // Wykonanie przez helper
    return _helper.executeRequest(messages: messages, config: _config);
  }
}
```

**Porównanie z planem nauczyciela:**

| Plan nauczyciela (Web/TS) | Flutter implementation |
|---------------------------|------------------------|
| `service.setSystemMessage("...")` | `builder.systemMessage("...")` |
| `service.setUserMessage("...")` | `builder.userMessage("...")` |
| `service.setModel(name, params)` | `builder.withModel(AiModelConfig.gpt4oMini)` |
| `service.setResponseFormat(schema)` | `builder.withResponseFormat(schema)` |
| `await service.sendChatMessage()` | `await builder.send()` |
| `service.sendChatMessage(msg)` | `helper.sendMessage(...)` (shortcut) |

### 2.4 Konfiguracja Dependency Injection

**app/di/injection.dart** (rozszerzenie istniejącego)
```dart
@module
abstract class NetworkModule {
  // Istniejące deklaracje...
  
  @lazySingleton
  @Named('openrouter')
  Dio provideOpenRouterDio() {
    final dio = Dio(BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer ${Env.openRouterApiKey}',
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://10xcards.app', // Opcjonalne
        'X-Title': '10xCards', // Opcjonalne
      },
    ));
    
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    return dio;
  }
  
  @lazySingleton
  OpenRouterDataSource provideOpenRouterDataSource(
    @Named('openrouter') Dio dio,
  ) {
    return OpenRouterDataSource(dio);
  }
}
```

**Uwagi:**
- Dio dla OpenRouter jest oznaczony `@Named('openrouter')` aby odróżnić go od głównego Dio (dla Supabase)
- API key pobierany jest bezpośrednio z `Env.openRouterApiKey` (konfiguracja w sekcji 2.5)
- LogInterceptor pomaga w debugowaniu requestów/responses

### 2.5 Konfiguracja zmiennych środowiskowych

Projekt już wykorzystuje **envied** dla zarządzania sekretami (plik `lib/app/config/env.dart`). Rozszerzymy istniejącą konfigurację o `OPENROUTER_API_KEY`.

#### Krok 1: Dodaj klucz do plików .env

Dodaj `OPENROUTER_API_KEY` do wszystkich trzech plików środowiskowych:

**`.env.development`** (NIE COMMITOWAĆ!)
```bash
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
OPENROUTER_API_KEY=sk-or-v1-xxxxx  # Dodaj tę linię
```

**`.env.staging`** (NIE COMMITOWAĆ!)
```bash
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
OPENROUTER_API_KEY=sk-or-v1-xxxxx  # Dodaj tę linię
```

**`.env.production`** (NIE COMMITOWAĆ!)
```bash
SUPABASE_URL=...
SUPABASE_ANON_KEY=...
OPENROUTER_API_KEY=sk-or-v1-xxxxx  # Dodaj tę linię
```

**`.env.example`** (commitować jako template)
```bash
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
OPENROUTER_API_KEY=your_openrouter_api_key_here
```

#### Krok 2: Rozszerz `lib/app/config/env.dart`

```dart
import 'package:envied/envied.dart';

part 'env.g.dart';

// Development environment
@Envied(path: '.env.development', name: 'DevelopmentEnv', obfuscate: true)
abstract class DevelopmentEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _DevelopmentEnv.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _DevelopmentEnv.supabaseAnonKey;
  
  // Nowe pole dla OpenRouter
  @EnviedField(varName: 'OPENROUTER_API_KEY')
  static final String openRouterApiKey = _DevelopmentEnv.openRouterApiKey;
}

// Staging environment
@Envied(path: '.env.staging', name: 'StagingEnv', obfuscate: true)
abstract class StagingEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _StagingEnv.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _StagingEnv.supabaseAnonKey;
  
  // Nowe pole dla OpenRouter
  @EnviedField(varName: 'OPENROUTER_API_KEY')
  static final String openRouterApiKey = _StagingEnv.openRouterApiKey;
}

// Production environment
@Envied(path: '.env.production', name: 'ProductionEnv', obfuscate: true)
abstract class ProductionEnv {
  @EnviedField(varName: 'SUPABASE_URL')
  static final String supabaseUrl = _ProductionEnv.supabaseUrl;

  @EnviedField(varName: 'SUPABASE_ANON_KEY')
  static final String supabaseAnonKey = _ProductionEnv.supabaseAnonKey;
  
  // Nowe pole dla OpenRouter
  @EnviedField(varName: 'OPENROUTER_API_KEY')
  static final String openRouterApiKey = _ProductionEnv.openRouterApiKey;
}

// Unified Env class
class Env {
  static const bool isDevelopment = true;
  static const bool isStaging = false;

  static String get supabaseUrl {
    if (isDevelopment) return DevelopmentEnv.supabaseUrl;
    if (isStaging) return StagingEnv.supabaseUrl;
    return ProductionEnv.supabaseUrl;
  }

  static String get supabaseAnonKey {
    if (isDevelopment) return DevelopmentEnv.supabaseAnonKey;
    if (isStaging) return StagingEnv.supabaseAnonKey;
    return ProductionEnv.supabaseAnonKey;
  }
  
  // Nowy getter dla OpenRouter API key
  static String get openRouterApiKey {
    if (isDevelopment) return DevelopmentEnv.openRouterApiKey;
    if (isStaging) return StagingEnv.openRouterApiKey;
    return ProductionEnv.openRouterApiKey;
  }
}
```

#### Krok 3: Regeneruj pliki envied

Po dodaniu nowych pól uruchom build_runner:

```bash
dart run build_runner build --delete-conflicting-outputs
```

#### Krok 4: Użyj w DI configuration

W `app/di/injection.dart` użyj `Env.openRouterApiKey`:

```dart
@module
abstract class NetworkModule {
  // Istniejące deklaracje...
  
  @lazySingleton
  Dio provideOpenRouterDio() {  // Nie potrzebujemy @Named parameter
    final dio = Dio(BaseOptions(
      baseUrl: 'https://openrouter.ai/api/v1',
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 60),
      headers: {
        'Authorization': 'Bearer ${Env.openRouterApiKey}',  // Użyj Env
        'Content-Type': 'application/json',
        'HTTP-Referer': 'https://10xcards.app',
        'X-Title': '10xCards',
      },
    ));
    
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
    ));
    
    return dio;
  }
  
  @lazySingleton
  OpenRouterDataSource provideOpenRouterDataSource(
    @Named('openrouter') Dio dio,
  ) {
    return OpenRouterDataSource(dio);
  }
}
```

**Zalety tego podejścia:**
- ✅ Spójność z istniejącą architekturą
- ✅ Compile-time safety dzięki envied + obfuscation
- ✅ Różne klucze dla development/staging/production
- ✅ Klucze nie trafiają do repozytorium (.env pliki w .gitignore)
- ✅ Jednolity sposób dostępu przez `Env.openRouterApiKey`

## 3. Integracja z funkcją generowania fiszek

### 3.1 Rozszerzenie istniejącej funkcjonalności generation

**lib/features/generation/domain/usecase/generate_flashcards_usecase.dart**
```dart
@injectable
class GenerateFlashcardsUseCase {
  final GenerateWithAiUseCase _generateWithAi;
  
  const GenerateFlashcardsUseCase(this._generateWithAi);
  
  Future<Either<AppFailure, List<Flashcard>>> call({
    required String topic,
    required int count,
    String? additionalContext,
  }) async {
    // 1. Przygotowanie promptu systemowego
    final systemMessage = AiMessage(
      role: AiMessageRole.system,
      content: _buildSystemPrompt(),
    );
    
    // 2. Przygotowanie user message
    final userMessage = AiMessage(
      role: AiMessageRole.user,
      content: _buildUserPrompt(topic, count, additionalContext),
    );
    
    // 3. Konfiguracja z JSON Schema dla structured output
    final config = AiModelConfig.gpt4oMini.copyWith(
      responseFormat: _buildFlashcardsJsonSchema(),
    );
    
    // 4. Wywołanie AI
    final result = await _generateWithAi(
      messages: [systemMessage, userMessage],
      config: config,
    );
    
    // 5. Parsing odpowiedzi i konwersja do Flashcard models
    return result.fold(
      (failure) => Left(failure),
      (response) => _parseFlashcardsFromResponse(response),
    );
  }
  
  Map<String, dynamic> _buildFlashcardsJsonSchema() {
    return {
      'type': 'json_schema',
      'json_schema': {
        'name': 'flashcards_generation',
        'strict': true,
        'schema': {
          'type': 'object',
          'properties': {
            'flashcards': {
              'type': 'array',
              'items': {
                'type': 'object',
                'properties': {
                  'front': {'type': 'string'},
                  'back': {'type': 'string'},
                  'category': {'type': 'string'},
                  'difficulty': {
                    'type': 'string',
                    'enum': ['easy', 'medium', 'hard']
                  },
                },
                'required': ['front', 'back', 'category', 'difficulty'],
                'additionalProperties': false,
              },
            },
          },
          'required': ['flashcards'],
          'additionalProperties': false,
        },
      },
    };
  }
}
```

### 3.2 Aktualizacja Cubit

**lib/features/generation/presentation/cubit/generation_cubit.dart**
- Dodanie metody `generateFlashcardsWithAI()`
- Obsługa stanów: loading, success, failure
- Wyświetlanie informacji o zużyciu tokenów (opcjonalnie)

## 4. Obsługa błędów

### 4.1 Nowe typy błędów w AppFailure

**lib/app/failures/app_failure.dart** (rozszerzenie)
```dart
@freezed
class AppFailure with _$AppFailure {
  // Istniejące...
  
  // Nowe dla AI
  const factory AppFailure.aiRateLimitExceeded({
    required String message,
  }) = _AiRateLimitExceeded;
  
  const factory AppFailure.aiInsufficientCredits({
    required String message,
  }) = _AiInsufficientCredits;
  
  const factory AppFailure.aiModelUnavailable({
    required String model,
    required String message,
  }) = _AiModelUnavailable;
  
  const factory AppFailure.aiInvalidResponse({
    required String message,
  }) = _AiInvalidResponse;
  
  const factory AppFailure.aiTimeout({
    required String message,
  }) = _AiTimeout;
}
```

### 4.2 Error mapping w service layer

Mapowanie błędów HTTP z OpenRouter na AppFailure:
- 400 → `aiInvalidResponse`
- 401 → `unauthorized`
- 402 → `aiInsufficientCredits`
- 429 → `aiRateLimitExceeded`
- 503 → `aiModelUnavailable`
- Timeout → `aiTimeout`

## 5. Bezpieczeństwo

### 5.1 Przechowywanie kluczy API
- ✅ Użycie flutter_dotenv lub envied
- ✅ Dodanie .env do .gitignore
- ✅ Stworzenie .env.example jako template
- ✅ Dokumentacja w README jak skonfigurować klucze

### 5.2 Zabezpieczenia w kodzie
- ✅ Nigdy nie logować pełnego klucza API
- ✅ Używanie timeoutów dla requestów
- ✅ Rate limiting po stronie aplikacji (opcjonalnie)
- ✅ Validacja odpowiedzi z AI przed użyciem

### 5.3 Limity kosztów
- ✅ Ustawienie credit limit w OpenRouter dashboard
- ✅ Monitoring zużycia tokenów w aplikacji
- ✅ Cache dla często generowanych zapytań (opcjonalnie)

## 6. Testowanie

### 6.1 Unit testy
- `openrouter_service_test.dart` - mockowanie data source
- `generate_with_ai_usecase_test.dart` - mockowanie service
- `generate_flashcards_usecase_test.dart` - mockowanie AI usecase

### 6.3 Mock responses
Przygotowanie przykładowych odpowiedzi OpenRouter dla testów:
```dart
// test/fixtures/openrouter_response.json
{
  "id": "gen-123",
  "model": "openai/gpt-4o-mini",
  "choices": [{
    "message": {
      "role": "assistant",
      "content": "{\"flashcards\": [...]}"
    },
    "finish_reason": "stop"
  }],
  "usage": {
    "prompt_tokens": 100,
    "completion_tokens": 200,
    "total_tokens": 300
  }
}
```

## 7. Dokumentacja

### 7.1 README aktualizacje
- Sekcja "AI Integration" z opisem jak skonfigurować OpenRouter
- Instrukcje uzyskania API key
- Opis wspieranych modeli
- Oszacowanie kosztów

### 7.2 Code documentation
- Dartdoc comments dla publicznych API
- Przykłady użycia w use cases
- Opis JSON Schema dla structured outputs

## 8. Plan wdrożenia (etapy)

### Etap 1: Podstawowa infrastruktura (2-3h)
1. ✅ Rozszerzenie `lib/app/config/env.dart` o `OPENROUTER_API_KEY`
2. ✅ Dodanie klucza do plików `.env.development`, `.env.staging`, `.env.production`
3. ✅ Regeneracja envied: `dart run build_runner build --delete-conflicting-outputs`
4. ✅ Utworzenie struktury katalogów `lib/features/ai_integration/`
5. ✅ Implementacja DTOs z freezed (request, response, message)
6. ✅ Implementacja Data Source z retrofit
7. ✅ Konfiguracja Dio dla OpenRouter w `app/di/injection.dart`

### Etap 2: Domain layer (1-2h)
1. ✅ Utworzenie domain models
2. ✅ Implementacja OpenRouterService
3. ✅ Implementacja GenerateWithAiUseCase
4. ✅ Dodanie nowych typów AppFailure
5. ✅ Konfiguracja DI

### Etap 2.5: Convenience Layer (opcjonalnie, 1h)
1. ✅ Implementacja OpenRouterChatHelper
2. ✅ Implementacja OpenRouterRequestBuilder (fluent API)
3. ✅ Testy dla convenience layer
4. ✅ Dokumentacja przykładów użycia

### Etap 3: Integracja z generation feature (2-3h)
1. ✅ Implementacja GenerateFlashcardsUseCase
2. ✅ Przygotowanie JSON Schema
3. ✅ Aktualizacja GenerationCubit
4. ✅ Aktualizacja UI (dodanie przycisku "Generate with AI")
5. ✅ Handling błędów w UI

### Etap 4: Testy (2-3h)
1. ✅ Unit testy dla service
2. ✅ Unit testy dla use cases
3. ✅ Widget testy dla UI
4. ✅ Przygotowanie mocków i fixtures

### Etap 5: Dokumentacja i finalizacja (1h)
1. ✅ Aktualizacja README
2. ✅ Dodanie .env.example
3. ✅ Code review checklist
4. ✅ Manual testing z prawdziwym API

## 9. Zależności

### 9.1 Już zainstalowane (wykorzystujemy istniejące)
```yaml
dependencies:
  envied: ^0.5.4+1  # Dla bezpiecznego przechowywania kluczy ✅
  dio: ^5.x  # HTTP client ✅
  retrofit: ^4.x  # REST API client ✅
  freezed_annotation: ^2.x  # Immutable models ✅
  injectable: ^2.x  # Dependency Injection ✅
  dartz: ^0.10.x  # Either dla error handling ✅
  
dev_dependencies:
  envied_generator: ^0.5.4+1  ✅
  retrofit_generator: ^8.x  ✅
  freezed: ^2.x  ✅
  build_runner: ^2.x  ✅
```

### 9.2 Opcjonalne (do rozważenia w przyszłości)
```yaml
dependencies:
  # Dla cachowania odpowiedzi AI (future enhancement)
  # hive: ^2.2.3
  # hive_flutter: ^1.1.0
```

**Wniosek:** Nie trzeba dodawać nowych zależności - wszystkie potrzebne pakiety są już w projekcie! 🎉

## 10. Checklist przed rozpoczęciem

- [ ] Utworzenie konta na OpenRouter ([https://openrouter.ai](https://openrouter.ai/))
- [ ] Doładowanie konta ($1-5 dla testów) lub wybór darmowego modelu
- [ ] Wygenerowanie klucza API z limitem kredytowym (Settings → Keys)
- [ ] Konfiguracja ustawień prywatności ([Settings → Privacy](https://openrouter.ai/settings/privacy))
- [ ] Dodanie `OPENROUTER_API_KEY` do plików `.env.development`, `.env.staging`, `.env.production`
- [ ] Zaktualizowanie `.env.example` o nowe pole (dla innych developerów)
- [ ] Przetestowanie API przez curl/Postman (opcjonalnie)
- [ ] Przygotowanie przykładowych promptów dla generowania fiszek (patrz: sekcja Notatki dodatkowe)

## 11. Potencjalne rozszerzenia (future enhancements Aktualnie nie rozwazaj.)

- **Streaming responses** - dla długich generacji pokazywanie postępu
- **Caching** - zapisywanie popularnych zapytań lokalnie
- **Batch processing** - generowanie wielu zestawów fiszek naraz
- **Fine-tuning prompts** - A/B testing różnych promptów
- **Multi-model fallback** - jeśli jeden model nie działa, użyj innego
- **Cost tracking** - monitoring wydatków na API w aplikacji
- **User feedback loop** - uczenie się z feedbacku użytkowników o jakości fiszek

## 12. Metryki sukcesu

- ✅ Poprawne wygenerowanie fiszek w <10s
- ✅ Koszt generacji zestawu 10 fiszek <$0.01
- ✅ Rate success >95% (błędy tylko przy problemach z API)
- ✅ Structured outputs zawsze w poprawnym formacie
- ✅ Brak wycieków API key
- ✅ Testy pokrycia >80%

---

## Notatki dodatkowe

### Przykładowy system prompt dla generowania fiszek:
```
You are an expert educational content creator specializing in creating effective flashcards for spaced repetition learning. Your task is to generate high-quality flashcards that:
- Follow the minimum information principle (one concept per card)
- Use clear, concise language
- Include mnemonics when helpful
- Vary question formats for better retention
- Are appropriately categorized and difficulty-rated

Generate flashcards in Polish language unless specified otherwise.
```

### Przykładowy user prompt:
```
Generate 10 flashcards about: {topic}
Additional context: {additionalContext}

Requirements:
- Mix of different difficulty levels (3 easy, 5 medium, 2 hard)
- Include practical examples where applicable
- Categorize appropriately
- Ensure diversity in question formats
```

**Dokument utworzony:** 2024-11-13  

