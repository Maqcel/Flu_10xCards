# Schemat Bazy Danych PostgreSQL – 10x-cards

## 1. Tabele z Kolumnami, Typami Danych i Ograniczeniami

### 1.1 Tabela: `auth.users`
Zarządzana przez Supabase Auth.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| `id` | `UUID` | `PRIMARY KEY` | Unikalny identyfikator użytkownika |
| `email` | `VARCHAR(255)` | `NOT NULL`, `UNIQUE` | Adres email użytkownika |
| `encrypted_password` | `VARCHAR` | `NOT NULL` | Zaszyfrowane hasło |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT now()` | Data utworzenia konta |
| `confirmed_at` | `TIMESTAMPTZ` | `NULLABLE` | Data potwierdzenia email |

---

### 1.2 Tabela: `flashcards`
Przechowuje zaakceptowane fiszki (zarówno wygenerowane przez AI, jak i ręczne).

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| `id` | `UUID` | `PRIMARY KEY`, `DEFAULT gen_random_uuid()` | Unikalny identyfikator fiszki |
| `user_id` | `UUID` | `NOT NULL`, `FOREIGN KEY → auth.users(id)` | Właściciel fiszki |
| `front` | `VARCHAR(200)` | `NOT NULL` | Przód fiszki (pytanie) |
| `back` | `VARCHAR(500)` | `NOT NULL` | Tył fiszki (odpowiedź) |
| `source` | `VARCHAR` | `NOT NULL`, `CHECK (source IN ('ai-full', 'ai-edited', 'manual'))` | Źródło pochodzenia fiszki |
| `generation_id` | `UUID` | `NULLABLE`, `FOREIGN KEY → generations(id)` | Opcjonalne powiązanie z sesją generowania |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT now()` | Data utworzenia |
| `updated_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT now()` | Data ostatniej aktualizacji |

**Wartości `source`:**
- `'ai-full'` – Zaakceptowana bez edycji
- `'ai-edited'` – Zaakceptowana po edycji
- `'manual'` – Utworzona ręcznie

---

### 1.3 Tabela: `generations`
Przechowuje logi generowania fiszek przez AI dla celów metrycznych.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| `id` | `UUID` | `PRIMARY KEY`, `DEFAULT gen_random_uuid()` | Unikalny identyfikator generowania |
| `user_id` | `UUID` | `NOT NULL`, `FOREIGN KEY → auth.users(id)` | Użytkownik wykonujący generowanie |
| `model` | `VARCHAR` | `NOT NULL` | Nazwa użytego modelu LLM (np. 'gpt-4', 'claude-3') |
| `source_text_length` | `INTEGER` | `NOT NULL`, `CHECK (source_text_length BETWEEN 1000 AND 10000)` | Długość tekstu źródłowego w znakach |
| `source_text_hash` | `VARCHAR` | `NOT NULL` | Hash SHA-256 tekstu źródłowego |
| `generated_count` | `INTEGER` | `NOT NULL` | Liczba wygenerowanych fiszek |
| `accepted_unedited_count` | `INTEGER` | `NULLABLE` | Liczba zaakceptowanych bez edycji |
| `accepted_edited_count` | `INTEGER` | `NULLABLE` | Liczba zaakceptowanych po edycji |
| `generation_duration` | `INTEGER` | `NOT NULL` | Czas generowania w milisekundach |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT now()` | Data wykonania generowania |

---

### 1.4 Tabela: `generation_error_logs`
Przechowuje logi błędów podczas generowania fiszek przez AI.

| Kolumna | Typ | Ograniczenia | Opis |
|---------|-----|--------------|------|
| `id` | `UUID` | `PRIMARY KEY`, `DEFAULT gen_random_uuid()` | Unikalny identyfikator błędu |
| `user_id` | `UUID` | `NOT NULL`, `FOREIGN KEY → auth.users(id)` | Użytkownik, u którego wystąpił błąd |
| `model` | `VARCHAR` | `NOT NULL` | Nazwa modelu LLM, który zwrócił błąd |
| `source_text_hash` | `VARCHAR` | `NOT NULL` | Hash tekstu źródłowego |
| `source_text_length` | `INTEGER` | `NOT NULL`, `CHECK (source_text_length BETWEEN 1000 AND 10000)` | Długość tekstu źródłowego |
| `error_code` | `VARCHAR(100)` | `NOT NULL` | Kod błędu (np. 'TIMEOUT', 'INVALID_RESPONSE') |
| `error_message` | `TEXT` | `NOT NULL` | Szczegółowy komunikat błędu |
| `created_at` | `TIMESTAMPTZ` | `NOT NULL`, `DEFAULT now()` | Data wystąpienia błędu |

---

## 2. Relacje Między Tabelami

### 2.1 Diagram Relacji

```
auth.users
    │
    ├──[1:N]──> flashcards
    │              │
    ├──[1:N]──> generations ──[1:N]──┘
    │
    ├──[1:N]──> generation_error_logs
```

### 2.2 Szczegóły Relacji

| Z Tabeli | Do Tabeli | Typ | Klucz Obcy | Akcja ON DELETE |
|----------|-----------|-----|------------|-----------------|
| `flashcards` | `auth.users` | N:1 | `user_id → auth.users(id)` | `CASCADE` |
| `flashcards` | `generations` | N:1 | `generation_id → generations(id)` | `SET NULL` |
| `generations` | `auth.users` | N:1 | `user_id → auth.users(id)` | `CASCADE` |
| `generation_error_logs` | `auth.users` | N:1 | `user_id → auth.users(id)` | `CASCADE` |

**Strategia Usuwania:**
- Wszystkie dane użytkownika są automatycznie usuwane przy usunięciu konta (`ON DELETE CASCADE`)
- Usunięcie rekordu generowania ustawia `generation_id` na `NULL` w powiązanych fiszkach

---

## 3. Indeksy

| Nazwa Indeksu | Tabela | Kolumny | Typ | Cel |
|---------------|--------|---------|-----|-----|
| `idx_flashcards_user_id` | `flashcards` | `user_id` | B-tree | Filtrowanie fiszek po użytkowniku |
| `idx_flashcards_generation_id` | `flashcards` | `generation_id` | B-tree | Powiązanie fiszki z generowaniem |
| `idx_generations_user_id` | `generations` | `user_id` | B-tree | Metryki per użytkownik |
| `idx_generation_error_logs_user_id` | `generation_error_logs` | `user_id` | B-tree | Filtrowanie błędów po użytkowniku |

---

## 4. Zasady Row-Level Security (RLS)

### 4.1 Włączenie RLS

```sql
ALTER TABLE flashcards ENABLE ROW LEVEL SECURITY;
ALTER TABLE generations ENABLE ROW LEVEL SECURITY;
ALTER TABLE generation_error_logs ENABLE ROW LEVEL SECURITY;
```

### 4.2 Polityki dla Tabeli `flashcards`

```sql
CREATE POLICY "Users can view own flashcards"
  ON flashcards FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own flashcards"
  ON flashcards FOR INSERT
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can update own flashcards"
  ON flashcards FOR UPDATE
  USING (user_id = auth.uid())
  WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users can delete own flashcards"
  ON flashcards FOR DELETE
  USING (user_id = auth.uid());
```

### 4.3 Polityki dla Tabeli `generations`

```sql
CREATE POLICY "Users can view own generations"
  ON generations FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own generations"
  ON generations FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

### 4.4 Polityki dla Tabeli `generation_error_logs`

```sql
CREATE POLICY "Users can view own error logs"
  ON generation_error_logs FOR SELECT
  USING (user_id = auth.uid());

CREATE POLICY "Users can insert own error logs"
  ON generation_error_logs FOR INSERT
  WITH CHECK (user_id = auth.uid());
```

---

## 5. Dodatkowe Funkcje i Procedury

### 5.1 Funkcja Usuwania Użytkownika (RODO Compliance)

```sql
CREATE OR REPLACE FUNCTION delete_user_data(target_user_id UUID)
RETURNS void
LANGUAGE plpgsql
SECURITY DEFINER
AS $$
BEGIN
  -- Wszystkie dane zostaną usunięte przez CASCADE
  -- Ta funkcja może być rozszerzona o logikę soft-delete z retencją 30 dni
  
  -- Hard delete (natychmiastowe)
  DELETE FROM auth.users WHERE id = target_user_id;
  
  -- Alternatywnie: Soft delete z retencją
  -- UPDATE auth.users 
  -- SET deleted_at = now(), 
  --     email = 'deleted_' || id || '@deleted.local'
  -- WHERE id = target_user_id;
END;
$$;
```

### 5.2 Trigger Automatycznej Aktualizacji `updated_at`

```sql
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Zastosowanie dla tabeli flashcards
CREATE TRIGGER update_flashcards_updated_at
  BEFORE UPDATE ON flashcards
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at_column();
```

---

## 6. Dodatkowe Uwagi i Wyjaśnienia Decyzji Projektowych

### 6.1 Typ Klucza Głównego – UUID
- **Decyzja:** UUID zamiast BIGSERIAL
- **Powód:** Większe bezpieczeństwo (nieprzewidywalne ID), lepsze dla rozproszonych systemów
- **Trade-off:** Nieznacznie większe zużycie przestrzeni vs BIGSERIAL

### 6.2 Limitacja Długości Fiszek
- **front:** max 200 znaków (krótkie pytanie)
- **back:** max 500 znaków (dłuższa odpowiedź)
- **Powód:** Wymuszenie zwięzłości, zgodnie z best practices tworzenia fiszek edukacyjnych

### 6.3 Walidacja Długości Tekstu Źródłowego
- **Zakres:** 1000-10000 znaków
- **Powód:** Zgodne z wymaganiami PRD (US-003), optymalne dla jakości generowania przez LLM

### 6.4 Pola Metryczne w `generations`
- **model:** Umożliwia A/B testing różnych modeli LLM
- **generation_duration:** Monitoring wydajności API, identyfikacja timeoutów
- **accepted_*_count:** Oddzielne liczniki dla metryk jakości (edited vs unedited)

### 6.5 Połączenie flashcard ↔ generation
- **generation_id:** Opcjonalne (NULL dla ręcznie tworzonych)
- **ON DELETE SET NULL:** Zachowanie fiszek nawet po usunięciu logów generowania
- **Cel:** Analiza jakości poszczególnych sesji generowania

### 6.6 Logi Błędów
- **Zastosowanie:** Debugging, monitoring rate limitów API, analiza jakości promptów
- **Retencja:** Do rozważenia automatyczne czyszczenie logów starszych niż 90 dni

### 6.7 Metryki Sukcesu – Implementacja
- **≥75% acceptance rate:**
  ```sql
  SELECT 
    (accepted_unedited_count + accepted_edited_count)::FLOAT / generated_count * 100
  FROM generations;
  ```
- **≥75% fiszek z AI:**
  ```sql
  SELECT 
    COUNT(*) FILTER (WHERE source IN ('ai-full', 'ai-edited'))::FLOAT / COUNT(*) * 100
  FROM flashcards;
  ```

### 6.8 Soft-delete vs Hard-delete (RODO)
- **MVP:** Hard-delete z natychmiastowym usunięciem danych
- **Opcja przyszłości:** Dodanie kolumny `deleted_at TIMESTAMPTZ` + scheduled job

### 6.9 Wydajność i Skalowalność
- **Założenia MVP:**
  - < 100K użytkowników
  - < 5M fiszek
  - < 500K logów generowania
- **Monitoring:** Query performance, connection pooling (PgBouncer)
- **Future:** Read replicas, cache layer (Redis), partycjonowanie po user_id

---

## 7. Kolejność Wdrożenia

### Faza 1: Utworzenie Podstawowych Struktur
1. Włączenie rozszerzeń: `uuid-ossp`
2. Utworzenie tabel: `flashcards`, `generations`, `generation_error_logs`
3. Dodanie kluczy obcych i constraints

### Faza 2: Indeksy i Optymalizacja
1. Utworzenie wszystkich indeksów B-tree
2. Analiza planu zapytań (`EXPLAIN ANALYZE`)

### Faza 3: Bezpieczeństwo
1. Włączenie RLS na wszystkich tabelach
2. Utworzenie polityk RLS
3. Testy weryfikacyjne dostępu

### Faza 4: Automatyzacja
1. Trigger `updated_at` dla flashcards
2. Funkcja `delete_user_data`

### Faza 5: Monitoring i Testy
1. Testy obciążeniowe
2. Monitoring wydajności indeksów
3. Weryfikacja polityk RLS

---

## 8. Migracje – Checklist

- [ ] Utworzenie rozszerzenia `uuid-ossp`
- [ ] Utworzenie tabeli `flashcards`
- [ ] Utworzenie tabeli `generations`
- [ ] Utworzenie tabeli `generation_error_logs`
- [ ] Dodanie kluczy obcych
- [ ] Utworzenie indeksów
- [ ] Włączenie RLS i utworzenie polityk
- [ ] Utworzenie triggerów i funkcji
- [ ] Testy funkcjonalności CRUD
- [ ] Testy wydajnościowe
- [ ] Dokumentacja API (Supabase PostgREST)

---

**Data utworzenia schematu:** 2025-11-05  
**Wersja:** 2.0 MVP (Simplified)  
**Status:** Gotowy do implementacji migracji
