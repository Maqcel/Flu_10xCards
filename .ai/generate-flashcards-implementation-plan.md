# API Endpoint Implementation Plan: POST /rpc/generate_flashcards

## 1. Przegląd punktu końcowego
Endpoint uruchamia proces generowania propozycji fiszek z dostarczonego tekstu źródłowego przy użyciu OpenRouter.ai. Odpowiada za:
1. Walidację wejścia (`source_text`, `model`, `target_count`).
2. Wywołanie usługi AI i parsowanie odpowiedzi.
3. Zapis metadanych do `tabela generations`.
4. Logowanie błędów do `tabela generation_error_logs` (jeśli wystąpią).
5. Zwrócenie listy propozycji fiszek bez ich zapisywania w `tabela flashcards`.

---

## 2. Szczegóły żądania
* **HTTP** `POST`
* **URL** `./generate_flashcards`
* **Body (JSON)**
```json
{
  "source_text": "<min 1000, max 10000 chars>"
}
```

### Walidacja
| Pole | Reguły |
|------|--------|
| source_text | 1000 ≤ len ≤ 10000 |

---

## 3. Wykorzystywane typy (DTO / Entities)
| Nazwa | Rola | Plik |
|-------|------|------|
| `GenerateFlashcardsRequestEntity` | DTO żądania | `lib/app/networking/entities/requests/generate_flashcards_request_entity.dart` |
| `GenerateFlashcardsResponseEntity` | DTO odpowiedzi | `.../responses/generate_flashcards_response_entity.dart` |
| `FlashcardProposalEntity` | pojedyncza propozycja | `.../responses/flashcard_proposal_entity.dart` |
| `GenerationEntity` | zapis metadanych | `.../database/generation_entity.dart` |

---

## 4. Szczegóły odpowiedzi
* **Sukces (HTTP 200)**
```json
{
  "generation_id": "uuid",
  "source_text_length": 5432,
  "source_text_hash": "sha256hash",
  "generated_count": 10,
  "generation_duration": 3450,
  "proposals": [
    { "front": "Q?", "back": "A", "source": "ai-full" }
  ]
}
```
* **Błędy**
| Kod | Kiedy | Przykład `error` |
|-----|-------|------------------|
| 400 | Walidacja | `validation_error` |
| 401 | Brak / nieważny JWT | `unauthorized` |
| 429 | Limit 10/h | `rate_limit_exceeded` |
| 503 | AI niedostępne / timeout | `llm_service_error` |
| 500 | Nieoczekiwane | `internal_error` |

---

## 5. Przepływ danych (Edge Function)
1. **Walidacja** parametrów; HTTP 400 przy błędzie.
2. **Rate limit** → `check_generation_rate_limit(uid)`; HTTP 429 gdy przekroczony.
3. **Hash źródła** = SHA-256(`source_text`).
4. **Wywołanie OpenRouter.ai** → json reply.
5. **Parsowanie & walidacja** JSON (front ≤ 200, back ≤ 500).
6. **INSERT** w `tabela generations` (bez transakcji z flashcards).
7. **Build response DTO** i `RETURN 200`.
8. **Catch errors** → INSERT do `generation_error_logs` + HTTP 503/500.

---

## 6. Względy bezpieczeństwa
* **Auth** JWT (Supabase Auth) – nagłówek `Authorization`.
* **RLS**
  * `generations` & `generation_error_logs` → `user_id = auth.uid()`.
* **Rate limit** 10 generacji / h.
* **Sanityzacja**
  * Trim + length check na `source_text`.

---

## 7. Obsługa błędów
| Typ | Log w DB | Kod HTTP |
|-----|----------|----------|
| Walidacja | – | 400 |
| Brak auth | – | 401 |
| Rate limit | – | 429 |
| Timeout / AI Error | ✔ (`generation_error_logs`) | 503 |
| Inne nieoczekiwane | ✔ | 500 |

**generation_error_logs**: `model`, `source_text_hash`, `source_text_length`, `error_code`, `error_message`.

---

## 8. Rozważania dotyczące wydajności
* **Timeout** dla OpenRouter → 30 s (przekroczenie = 503 + log).
* **Partial index** na `generations (user_id, created_at DESC)` → szybszy rate-limit.
* **GZIP** – domyślnie w Supabase.
* **Hash** – obliczany po stronie serwera (Edge Function).

---

## 9. Kroki wdrożenia (API Layer)
1. **Migration** rate-limit function.
2. **Edge Function** `generate-flashcards` – implementacja & `supabase functions deploy`.
3. **Secrets** `OPENROUTER_API_KEY`.
4. **Unit tests** Edge Function (happy-path, walidacja, rate-limit, timeout).
5. **Manual test** przez `supabase functions invoke`.
6. **Dokumentacja** (OpenAPI snippet + README).
7. **Monitoring** (logs, p95 duration, error rate).

---

## 10. Checklist końcowy

### Backend
- [ ] Edge Function `generate-flashcards` utworzona i zdeployowana
- [ ] Rate limit function w bazie danych
- [ ] OpenRouter.ai API key skonfigurowany w secrets
- [ ] Polityki RLS zweryfikowane
- [ ] Indeksy utworzone
- [ ] Migracje uruchomione

### Flutter - Data Layer
- [ ] `GenerationErrorLogEntity` utworzone i wygenerowane
- [ ] `GenerationDataSource` zaimplementowany
- [ ] `GenerationService` zaimplementowany
- [ ] Mappers zweryfikowane/utworzone
- [ ] Error handling zaimplementowany

### Flutter - Domain Layer
- [ ] `GenerateFlashcardsUseCase` utworzony
- [ ] Walidacja biznesowa zaimplementowana
- [ ] Modele domenowe zweryfikowane

### Flutter - Presentation Layer
- [ ] `GenerationState` utworzony
- [ ] `GenerationCubit` zaimplementowany
- [ ] `GenerationPage` utworzona
- [ ] `GenerationView` zaimplementowana
- [ ] BLoC listeners skonfigurowane

### Infrastructure
- [ ] Dependency Injection skonfigurowane
- [ ] Routing dodany
- [ ] Localization dodana (EN + PL)
- [ ] Code generation uruchomiona

### Testing
- [ ] Unit tests dla Use Case
- [ ] Unit tests dla Service
- [ ] Widget tests dla Page/View
- [ ] Integration tests

### Documentation
- [ ] Komentarze w kodzie
- [ ] API documentation
- [ ] README zaktualizowany

### Deployment
- [ ] Testy na urządzeniach fizycznych
- [ ] Edge Function zdeployowana na produkcję
- [ ] Monitoring skonfigurowany
- [ ] Analytics dodane

---

**Status:** Ready for Implementation  
**Priority:** High (Core Feature)  
**Dependencies:** Supabase, OpenRouter.ai
