# REST API Plan - 10x-cards

## 1. Overview

This API plan is designed for the 10x-cards application, a flashcard learning system with AI-powered generation capabilities. The API leverages Supabase as the backend platform, which provides:
- Built-in authentication (JWT-based)
- PostgreSQL database with Row-Level Security (RLS)
- Auto-generated RESTful endpoints via PostgREST
- Real-time subscriptions

**Base URL:** `https://[project-ref].supabase.co`

**API Version:** v1 (implicit in Supabase routes)

## 2. Resources

### 2.1 Primary Resources

| Resource | Database Table | Description |
|----------|----------------|-------------|
| **Users** | `auth.users` | User accounts (managed by Supabase Auth) |
| **Flashcards** | `flashcards` | User-created and AI-generated flashcards |
| **Generations** | `generations` | AI generation session logs and metrics |
| **Generation Error Logs** | `generation_error_logs` | Error tracking for failed AI generations |

### 2.2 Resource Relationships

```
Users (auth.users)
  ├── Has Many → Flashcards
  ├── Has Many → Generations
  └── Has Many → Generation Error Logs

Generations
  └── Has Many → Flashcards (optional reference)
```

## 3. Authentication Endpoints

Supabase provides built-in authentication endpoints under `/auth/v1/`.

### 3.1 User Registration

**Endpoint:** `POST /auth/v1/signup`

**Description:** Register a new user account with email and password.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Success Response (200 OK):**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.MR6...",
  "user": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "created_at": "2025-11-06T10:00:00Z",
    "confirmed_at": "2025-11-06T10:00:00Z"
  }
}
```

**Error Responses:**
- **400 Bad Request:** Invalid email format or weak password
  ```json
  {
    "error": "invalid_request",
    "error_description": "Password should be at least 6 characters"
  }
  ```
- **422 Unprocessable Entity:** Email already registered
  ```json
  {
    "error": "email_exists",
    "error_description": "User already registered"
  }
  ```

### 3.2 User Login

**Endpoint:** `POST /auth/v1/token?grant_type=password`

**Description:** Authenticate user and obtain access token.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Content-Type: application/json
```

**Request Body:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123!"
}
```

**Success Response (200 OK):**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.MR6...",
  "user": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "created_at": "2025-11-06T10:00:00Z"
  }
}
```

**Error Responses:**
- **400 Bad Request:** Invalid credentials
  ```json
  {
    "error": "invalid_grant",
    "error_description": "Invalid login credentials"
  }
  ```

### 3.3 Token Refresh

**Endpoint:** `POST /auth/v1/token?grant_type=refresh_token`

**Description:** Refresh expired access token.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Content-Type: application/json
```

**Request Body:**
```json
{
  "refresh_token": "v1.MR6..."
}
```

**Success Response (200 OK):**
```json
{
  "access_token": "eyJhbGci...",
  "token_type": "bearer",
  "expires_in": 3600,
  "refresh_token": "v1.MR6..."
}
```

### 3.4 Logout

**Endpoint:** `POST /auth/v1/logout`

**Description:** Invalidate user session and tokens.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
```

**Success Response (204 No Content)**

### 3.5 Get Current User

**Endpoint:** `GET /auth/v1/user`

**Description:** Retrieve authenticated user information.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
```

**Success Response (200 OK):**
```json
{
  "id": "123e4567-e89b-12d3-a456-426614174000",
  "email": "user@example.com",
  "created_at": "2025-11-06T10:00:00Z",
  "confirmed_at": "2025-11-06T10:00:00Z"
}
```

### 3.6 Delete User Account

**Endpoint:** `DELETE /auth/v1/user`

**Description:** Permanently delete user account and all associated data (GDPR compliance).

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
```

**Success Response (200 OK):**
```json
{
  "message": "User account deleted successfully"
}
```

**Note:** This triggers CASCADE deletion of all user's flashcards, generations, and error logs via database constraints.

## 4. Flashcard Endpoints

All flashcard endpoints are accessed via PostgREST at `/rest/v1/flashcards`.

### 4.1 List User's Flashcards

**Endpoint:** `GET /rest/v1/flashcards`

**Description:** Retrieve paginated list of user's flashcards with optional filtering and sorting.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `select` | string | No | Columns to return (default: `*`) |
| `source` | enum | No | Filter by source: `ai-full`, `ai-edited`, `manual` |
| `order` | string | No | Sort order (e.g., `created_at.desc`) |
| `limit` | integer | No | Number of records (default: 50, max: 100) |
| `offset` | integer | No | Pagination offset (default: 0) |

**Example Request:**
```
GET /rest/v1/flashcards?select=*&order=created_at.desc&limit=20&offset=0
```

**Success Response (200 OK):**
```json
[
  {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "front": "What is the capital of France?",
    "back": "Paris",
    "source": "ai-full",
    "generation_id": "550e8400-e29b-41d4-a716-446655440000",
    "created_at": "2025-11-06T10:15:00Z",
    "updated_at": "2025-11-06T10:15:00Z"
  },
  {
    "id": "b2c3d4e5-f6a7-8901-bcde-f12345678901",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "front": "Define photosynthesis",
    "back": "The process by which plants convert light energy into chemical energy",
    "source": "manual",
    "generation_id": null,
    "created_at": "2025-11-06T09:30:00Z",
    "updated_at": "2025-11-06T09:30:00Z"
  }
]
```

**Response Headers:**
```
Content-Range: 0-19/45
```

**Error Responses:**
- **401 Unauthorized:** Missing or invalid token
- **416 Range Not Satisfiable:** Invalid pagination parameters

### 4.2 Get Single Flashcard

**Endpoint:** `GET /rest/v1/flashcards?id=eq.[flashcard_id]`

**Description:** Retrieve a specific flashcard by ID.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Accept: application/vnd.pgrst.object+json
```

**Success Response (200 OK):**
```json
{
  "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "front": "What is the capital of France?",
  "back": "Paris",
  "source": "ai-full",
  "generation_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2025-11-06T10:15:00Z",
  "updated_at": "2025-11-06T10:15:00Z"
}
```

**Error Responses:**
- **404 Not Found:** Flashcard doesn't exist or doesn't belong to user

### 4.3 Create Single Flashcard

**Endpoint:** `POST /rest/v1/flashcards`

**Description:** Create a new flashcard manually.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
Prefer: return=representation
```

**Request Body:**
```json
{
  "front": "What is React?",
  "back": "A JavaScript library for building user interfaces",
  "source": "manual"
}
```

**Validation Rules:**
- `front`: Required, 1-200 characters
- `back`: Required, 1-500 characters
- `source`: Required, must be `'manual'` for this endpoint
- `user_id`: Automatically set from JWT token

**Success Response (201 Created):**
```json
{
  "id": "c3d4e5f6-a7b8-9012-cdef-123456789012",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "front": "What is React?",
  "back": "A JavaScript library for building user interfaces",
  "source": "manual",
  "generation_id": null,
  "created_at": "2025-11-06T11:00:00Z",
  "updated_at": "2025-11-06T11:00:00Z"
}
```

**Error Responses:**
- **400 Bad Request:** Validation error
  ```json
  {
    "code": "PGRST204",
    "message": "front field exceeds 200 characters",
    "details": null,
    "hint": null
  }
  ```
- **401 Unauthorized:** Not authenticated

### 4.4 Batch Create Flashcards

**Endpoint:** `POST /rest/v1/flashcards`

**Description:** Create multiple flashcards in a single request (used after AI generation approval).

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
Prefer: return=representation
```

**Request Body:**
```json
[
  {
    "front": "What is the speed of light?",
    "back": "299,792,458 meters per second in vacuum",
    "source": "ai-full",
    "generation_id": "550e8400-e29b-41d4-a716-446655440000"
  },
  {
    "front": "What is gravity?",
    "back": "A force of attraction between objects with mass, edited for clarity",
    "source": "ai-edited",
    "generation_id": "550e8400-e29b-41d4-a716-446655440000"
  }
]
```

**Validation Rules:**
- Array must contain 1-50 flashcards
- Each flashcard follows standard validation rules
- `generation_id` must reference an existing generation owned by user

**Success Response (201 Created):**
```json
[
  {
    "id": "d4e5f6a7-b8c9-0123-def1-234567890123",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "front": "What is the speed of light?",
    "back": "299,792,458 meters per second in vacuum",
    "source": "ai-full",
    "generation_id": "550e8400-e29b-41d4-a716-446655440000",
    "created_at": "2025-11-06T11:05:00Z",
    "updated_at": "2025-11-06T11:05:00Z"
  },
  {
    "id": "e5f6a7b8-c9d0-1234-ef12-345678901234",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "front": "What is gravity?",
    "back": "A force of attraction between objects with mass, edited for clarity",
    "source": "ai-edited",
    "generation_id": "550e8400-e29b-41d4-a716-446655440000",
    "created_at": "2025-11-06T11:05:00Z",
    "updated_at": "2025-11-06T11:05:00Z"
  }
]
```

**Error Responses:**
- **400 Bad Request:** Validation error in one or more flashcards
- **413 Payload Too Large:** More than 50 flashcards in request

### 4.5 Update Flashcard

**Endpoint:** `PATCH /rest/v1/flashcards?id=eq.[flashcard_id]`

**Description:** Update an existing flashcard's content.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
Prefer: return=representation
```

**Request Body:**
```json
{
  "front": "What is the speed of light in a vacuum?",
  "back": "Approximately 299,792,458 m/s (exact value by definition)"
}
```

**Validation Rules:**
- Only `front` and `back` fields can be updated
- Same length constraints apply (200 and 500 chars)
- `source` and `generation_id` cannot be changed
- `updated_at` is automatically set via trigger

**Success Response (200 OK):**
```json
{
  "id": "d4e5f6a7-b8c9-0123-def1-234567890123",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "front": "What is the speed of light in a vacuum?",
  "back": "Approximately 299,792,458 m/s (exact value by definition)",
  "source": "ai-full",
  "generation_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2025-11-06T11:05:00Z",
  "updated_at": "2025-11-06T11:20:00Z"
}
```

**Error Responses:**
- **404 Not Found:** Flashcard doesn't exist or doesn't belong to user
- **400 Bad Request:** Validation error

### 4.6 Delete Flashcard

**Endpoint:** `DELETE /rest/v1/flashcards?id=eq.[flashcard_id]`

**Description:** Permanently delete a flashcard.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Prefer: return=representation
```

**Success Response (200 OK):**
```json
{
  "id": "d4e5f6a7-b8c9-0123-def1-234567890123",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "front": "What is the speed of light in a vacuum?",
  "back": "Approximately 299,792,458 m/s (exact value by definition)",
  "source": "ai-full",
  "generation_id": "550e8400-e29b-41d4-a716-446655440000",
  "created_at": "2025-11-06T11:05:00Z",
  "updated_at": "2025-11-06T11:20:00Z"
}
```

**Error Responses:**
- **404 Not Found:** Flashcard doesn't exist or doesn't belong to user

### 4.7 Get Flashcards Due for Review

**Endpoint:** `GET /rest/v1/flashcards`

**Description:** Retrieve flashcards due for spaced repetition review.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `select` | string | No | Columns to return |
| `limit` | integer | No | Number of cards for session (default: 20) |

**Note:** This endpoint returns flashcards in a format compatible with the spaced repetition library. The client-side library handles scheduling logic.

**Success Response (200 OK):**
```json
[
  {
    "id": "a1b2c3d4-e5f6-7890-abcd-ef1234567890",
    "front": "What is the capital of France?",
    "back": "Paris",
    "created_at": "2025-11-06T10:15:00Z"
  }
]
```

## 5. AI Generation Endpoints

These endpoints handle AI-powered flashcard generation via OpenRouter.ai integration.

### 5.1 Generate Flashcards from Text

**Endpoint:** `POST /rest/v1/rpc/generate_flashcards`

**Description:** Generate flashcard proposals from source text using LLM via OpenRouter.ai. This is a custom RPC function.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
```

**Request Body:**
```json
{
  "source_text": "Photosynthesis is the process by which plants convert light energy...",
  "model": "openai/gpt-4-turbo",
  "target_count": 10
}
```

**Validation Rules:**
- `source_text`: Required, 1,000-10,000 characters
- `model`: Required, valid OpenRouter model identifier
- `target_count`: Optional, 5-20 flashcards (default: 10)

**Success Response (200 OK):**
```json
{
  "generation_id": "550e8400-e29b-41d4-a716-446655440000",
  "model": "openai/gpt-4-turbo",
  "source_text_length": 5432,
  "source_text_hash": "a3c8b9d2e1f4567890abcdef12345678",
  "generated_count": 10,
  "generation_duration": 3450,
  "proposals": [
    {
      "front": "What is photosynthesis?",
      "back": "The process by which plants convert light energy into chemical energy stored in glucose"
    },
    {
      "front": "What organelle is responsible for photosynthesis?",
      "back": "Chloroplasts"
    },
    {
      "front": "What are the two main stages of photosynthesis?",
      "back": "Light-dependent reactions and the Calvin cycle (light-independent reactions)"
    }
  ]
}
```

**Response Fields:**
- `generation_id`: UUID for tracking this generation session
- `model`: LLM model used
- `source_text_length`: Character count of input
- `source_text_hash`: SHA-256 hash of source text
- `generated_count`: Number of flashcards generated
- `generation_duration`: Time in milliseconds
- `proposals`: Array of generated flashcard proposals (not yet saved)

**Error Responses:**

- **400 Bad Request:** Invalid source text length
  ```json
  {
    "error": "validation_error",
    "message": "Source text must be between 1000 and 10000 characters",
    "details": {
      "field": "source_text",
      "length": 543
    }
  }
  ```

- **429 Too Many Requests:** Rate limit exceeded
  ```json
  {
    "error": "rate_limit_exceeded",
    "message": "Maximum 10 generations per hour exceeded",
    "retry_after": 1800
  }
  ```

- **503 Service Unavailable:** LLM API error
  ```json
  {
    "error": "llm_service_error",
    "message": "Failed to generate flashcards",
    "error_log_id": "660f9511-f30c-52e5-b827-557766551111"
  }
  ```

**Implementation Notes:**
- This is a Postgres function that:
  1. Validates input parameters
  2. Calculates SHA-256 hash of source text
  3. Calls OpenRouter.ai API via Supabase Edge Function
  4. Logs generation to `generations` table
  5. Returns proposals without saving to `flashcards` table
  6. On error, logs to `generation_error_logs` table

### 5.2 Update Generation Acceptance Stats

**Endpoint:** `PATCH /rest/v1/generations?id=eq.[generation_id]`

**Description:** Update acceptance statistics after user reviews generated flashcards.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
Content-Type: application/json
```

**Request Body:**
```json
{
  "accepted_unedited_count": 7,
  "accepted_edited_count": 2
}
```

**Validation Rules:**
- `accepted_unedited_count + accepted_edited_count <= generated_count`
- Can only be updated once per generation

**Success Response (200 OK):**
```json
{
  "id": "550e8400-e29b-41d4-a716-446655440000",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "model": "openai/gpt-4-turbo",
  "source_text_length": 5432,
  "source_text_hash": "a3c8b9d2e1f4567890abcdef12345678",
  "generated_count": 10,
  "accepted_unedited_count": 7,
  "accepted_edited_count": 2,
  "generation_duration": 3450,
  "created_at": "2025-11-06T12:00:00Z"
}
```

**Error Responses:**
- **400 Bad Request:** Invalid counts
- **404 Not Found:** Generation doesn't exist or doesn't belong to user

## 6. Statistics Endpoints

### 6.1 Get Generation Statistics

**Endpoint:** `GET /rest/v1/rpc/get_generation_statistics`

**Description:** Retrieve aggregated statistics about AI generation performance.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `start_date` | ISO 8601 | No | Filter generations from this date |
| `end_date` | ISO 8601 | No | Filter generations until this date |

**Success Response (200 OK):**
```json
{
  "total_generations": 45,
  "total_flashcards_generated": 450,
  "total_flashcards_accepted": 360,
  "acceptance_rate": 80.0,
  "average_unedited_rate": 75.5,
  "average_generation_duration": 3250,
  "by_model": [
    {
      "model": "openai/gpt-4-turbo",
      "count": 30,
      "avg_acceptance_rate": 82.3
    },
    {
      "model": "anthropic/claude-3-opus",
      "count": 15,
      "avg_acceptance_rate": 75.1
    }
  ]
}
```

**Implementation Notes:**
- Calculates acceptance rate: `(accepted_unedited + accepted_edited) / generated * 100`
- Filters to only include generations where acceptance counts are not NULL
- Success metric: ≥75% acceptance rate

### 6.2 Get Flashcard Statistics

**Endpoint:** `GET /rest/v1/rpc/get_flashcard_statistics`

**Description:** Retrieve statistics about flashcard sources and usage.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
```

**Success Response (200 OK):**
```json
{
  "total_flashcards": 350,
  "by_source": {
    "ai-full": {
      "count": 200,
      "percentage": 57.14
    },
    "ai-edited": {
      "count": 80,
      "percentage": 22.86
    },
    "manual": {
      "count": 70,
      "percentage": 20.0
    }
  },
  "ai_total_percentage": 80.0,
  "created_last_7_days": 45,
  "created_last_30_days": 180
}
```

**Implementation Notes:**
- `ai_total_percentage` combines `ai-full` and `ai-edited`
- Success metric: ≥75% of flashcards from AI

### 6.3 Get Error Logs

**Endpoint:** `GET /rest/v1/generation_error_logs`

**Description:** Retrieve error logs for failed AI generation attempts.

**Request Headers:**
```
apikey: [SUPABASE_ANON_KEY]
Authorization: Bearer [ACCESS_TOKEN]
```

**Query Parameters:**
| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `order` | string | No | Sort order (default: `created_at.desc`) |
| `limit` | integer | No | Number of records (default: 50) |

**Success Response (200 OK):**
```json
[
  {
    "id": "770f9511-f30c-52e5-b827-557766551111",
    "user_id": "123e4567-e89b-12d3-a456-426614174000",
    "model": "openai/gpt-4-turbo",
    "source_text_hash": "b4d9c8e3f2a5678901bcdef23456789",
    "source_text_length": 7890,
    "error_code": "TIMEOUT",
    "error_message": "Request to LLM API timed out after 30 seconds",
    "created_at": "2025-11-06T13:45:00Z"
  }
]
```

**Common Error Codes:**
- `TIMEOUT`: API request timeout
- `INVALID_RESPONSE`: Malformed response from LLM
- `RATE_LIMIT`: OpenRouter rate limit exceeded
- `INSUFFICIENT_CREDITS`: User's OpenRouter credits depleted
- `VALIDATION_ERROR`: Generated content failed validation
- `NETWORK_ERROR`: Network connectivity issue

## 7. Authentication and Authorization

### 7.1 Authentication Mechanism

**Type:** JWT (JSON Web Tokens) - Supabase Auth

**Flow:**
1. User registers/logs in via `/auth/v1/signup` or `/auth/v1/token`
2. Supabase returns JWT access token and refresh token
3. Client stores tokens securely (flutter_secure_storage)
4. Client includes access token in `Authorization: Bearer [token]` header
5. Access token expires after 3600 seconds (1 hour)
6. Client refreshes token using refresh token before expiry

**Token Structure:**
```json
{
  "sub": "123e4567-e89b-12d3-a456-426614174000",
  "email": "user@example.com",
  "role": "authenticated",
  "iat": 1699270800,
  "exp": 1699274400
}
```

### 7.2 Authorization Strategy

**Row-Level Security (RLS):**

All data access is controlled by PostgreSQL RLS policies. The authenticated user's ID from JWT (`auth.uid()`) is automatically used to filter queries.

**RLS Policies:**

1. **Flashcards:**
   - SELECT: `user_id = auth.uid()`
   - INSERT: `user_id = auth.uid()`
   - UPDATE: `user_id = auth.uid()`
   - DELETE: `user_id = auth.uid()`

2. **Generations:**
   - SELECT: `user_id = auth.uid()`
   - INSERT: `user_id = auth.uid()`
   - UPDATE: `user_id = auth.uid()` (only acceptance stats)

3. **Generation Error Logs:**
   - SELECT: `user_id = auth.uid()`
   - INSERT: `user_id = auth.uid()` (via RPC function)

**Security Features:**
- Users can only access their own data
- `user_id` is automatically set from JWT token on INSERT
- No sharing or cross-user access
- Supabase anon key is safe to expose (client-side)
- Service role key is kept server-side only (for admin operations)

### 7.3 API Key Usage

**Two types of keys:**

1. **Anon Key (Public):**
   - Used by mobile app
   - Rate-limited per user
   - RLS policies enforced
   - Safe to embed in client

2. **Service Role Key (Private):**
   - Used for admin operations
   - Bypasses RLS
   - Never exposed to client
   - Used only in secure Edge Functions

## 8. Validation and Business Logic

### 8.1 Flashcard Validation

**Field-Level Validation:**

| Field | Rules |
|-------|-------|
| `front` | Required, String, 1-200 characters, Non-empty after trim |
| `back` | Required, String, 1-500 characters, Non-empty after trim |
| `source` | Required, Enum: `'ai-full'`, `'ai-edited'`, `'manual'` |
| `generation_id` | Optional, UUID, Must reference existing generation if provided |
| `user_id` | Auto-set from JWT, UUID |

**Database Constraints:**
```sql
CHECK (length(front) BETWEEN 1 AND 200)
CHECK (length(back) BETWEEN 1 AND 500)
CHECK (source IN ('ai-full', 'ai-edited', 'manual'))
```

**Business Rules:**
1. Flashcards with `source='manual'` must have `generation_id=NULL`
2. Flashcards with `source` starting with `'ai-'` should reference a valid generation
3. Users cannot create flashcards with future timestamps

### 8.2 Generation Validation

**Field-Level Validation:**

| Field | Rules |
|-------|-------|
| `source_text` | Required, 1,000-10,000 characters |
| `model` | Required, Valid OpenRouter model ID |
| `target_count` | Optional, Integer, 5-20 (default: 10) |

**Database Constraints:**
```sql
CHECK (source_text_length BETWEEN 1000 AND 10000)
```

**Business Rules:**
1. Maximum 10 generations per user per hour (rate limiting)
2. Source text hash is calculated server-side (SHA-256)
3. Generation duration is measured and logged
4. Acceptance counts can only be updated once
5. `accepted_unedited_count + accepted_edited_count <= generated_count`

### 8.3 Error Handling Strategy

**HTTP Status Codes:**

| Code | Usage |
|------|-------|
| 200 | Successful GET, PATCH, DELETE with return |
| 201 | Successful POST (resource created) |
| 204 | Successful DELETE without return |
| 400 | Validation error, malformed request |
| 401 | Authentication required or invalid token |
| 403 | Forbidden (authenticated but not authorized) |
| 404 | Resource not found or not owned by user |
| 409 | Conflict (e.g., duplicate) |
| 413 | Payload too large |
| 416 | Invalid range (pagination) |
| 429 | Rate limit exceeded |
| 500 | Internal server error |
| 503 | Service unavailable (LLM API down) |

**Error Response Format:**
```json
{
  "error": "error_code",
  "message": "Human-readable error message",
  "details": {
    "field": "field_name",
    "reason": "specific_reason"
  }
}
```

**Error Logging:**
- All LLM API errors logged to `generation_error_logs`
- Server errors logged to Supabase logs
- Client errors (4xx) not logged server-side
- Error logs retained for 90 days (configurable)

### 8.4 Business Logic Implementation

**Client-Side (Flutter):**
- Input validation (character counts, non-empty fields)
- Swipe gesture handling (accept/reject/edit flashcards)
- Spaced repetition algorithm using open-source library
- Token refresh logic
- Optimistic UI updates

**Server-Side (Supabase/PostgreSQL):**
- RLS policy enforcement
- Automatic timestamp management (triggers)
- Hash calculation for source text
- Foreign key constraint enforcement
- Cascade deletion on account removal

**Edge Functions (Supabase):**
- LLM API integration (OpenRouter.ai)
- Rate limiting enforcement
- Generation logging
- Error handling and retry logic
- Response parsing and validation

## 9. Rate Limiting

### 9.1 Rate Limits

| Endpoint | Limit | Window |
|----------|-------|--------|
| `/rest/v1/rpc/generate_flashcards` | 10 requests | 1 hour |
| All other authenticated endpoints | 100 requests | 1 minute |
| Authentication endpoints | 20 requests | 1 hour |

### 9.2 Rate Limit Headers

**Response Headers:**
```
X-RateLimit-Limit: 10
X-RateLimit-Remaining: 7
X-RateLimit-Reset: 1699274400
```

### 9.3 Rate Limit Exceeded Response

**Status:** 429 Too Many Requests

```json
{
  "error": "rate_limit_exceeded",
  "message": "Too many requests. Please try again later.",
  "retry_after": 3600
}
```

## 10. Pagination

### 10.1 Range-Based Pagination

Supabase uses range-based pagination with offset/limit.

**Request Headers:**
```
Range: 0-19
```

**Query Parameters:**
```
?limit=20&offset=0
```

**Response Headers:**
```
Content-Range: 0-19/156
```

**Interpretation:**
- `0-19`: Records returned (0-based indexing)
- `156`: Total count of records

### 10.2 Cursor-Based Pagination (Alternative)

For improved performance on large datasets:

**Query Parameters:**
```
?order=created_at.desc&limit=20&created_at=lt.2025-11-06T10:00:00Z
```

**Advantages:**
- Consistent results when data changes
- Better performance on large offsets
- Recommended for infinite scroll UX

## 11. Versioning Strategy

### 11.1 Current Approach

- Supabase PostgREST uses implicit versioning via `/rest/v1/`
- Breaking changes handled via database migrations
- New fields added as nullable columns
- Deprecated fields marked in API documentation

### 11.2 Future Considerations

If custom API layer is added:
- Use URL versioning: `/api/v2/flashcards`
- Maintain v1 for 12 months after v2 release
- Communicate deprecation via response headers:
  ```
  Deprecation: true
  Sunset: Sat, 31 Dec 2025 23:59:59 GMT
  ```

## 12. Performance Considerations

### 12.1 Database Indexes

As defined in db-plan.md:
- `idx_flashcards_user_id` (B-tree)
- `idx_flashcards_generation_id` (B-tree)
- `idx_generations_user_id` (B-tree)
- `idx_generation_error_logs_user_id` (B-tree)

### 12.2 Query Optimization

**Best Practices:**
1. Use `select` parameter to request only needed columns
2. Apply filters to reduce result set before pagination
3. Use appropriate indexes for sorting
4. Limit joins to 2-3 tables maximum

**Example Optimized Query:**
```
GET /rest/v1/flashcards?select=id,front,back,created_at&source=eq.ai-full&order=created_at.desc&limit=20
```

### 12.3 Caching Strategy

**Client-Side Caching:**
- Cache flashcard list for 5 minutes
- Invalidate cache on CREATE, UPDATE, DELETE
- Use ETags for conditional requests

**Server-Side Caching:**
- Supabase handles connection pooling
- Query results cached for anonymous queries
- Authenticated queries bypass cache for security

### 12.4 Connection Pooling

**PgBouncer Configuration:**
- Default pool size: 15 connections
- Max client connections: 200
- Pool mode: Transaction

## 13. Testing Strategy

### 13.1 API Testing Checklist

**Unit Tests:**
- [ ] Validation logic for all fields
- [ ] Hash calculation functions
- [ ] Rate limiting logic
- [ ] RLS policy tests

**Integration Tests:**
- [ ] End-to-end flashcard CRUD operations
- [ ] AI generation flow with mock LLM responses
- [ ] Authentication and token refresh flow
- [ ] Batch operations (create multiple flashcards)
- [ ] Statistics calculation accuracy

**Security Tests:**
- [ ] RLS policy enforcement (user isolation)
- [ ] JWT validation and expiry
- [ ] SQL injection prevention (handled by PostgREST)
- [ ] CORS configuration
- [ ] Rate limit enforcement

**Performance Tests:**
- [ ] Load test with 100 concurrent users
- [ ] Query performance under 100ms for list endpoints
- [ ] Generation endpoint under 5s for 10 flashcards
- [ ] Pagination with 10,000+ records per user

### 13.2 Mock Responses

For client-side testing, mock the following endpoints:

1. `/auth/v1/token` → Return mock JWT
2. `/rest/v1/flashcards` → Return sample flashcard list
3. `/rest/v1/rpc/generate_flashcards` → Return mock proposals

## 14. Documentation and SDK

### 14.1 OpenAPI Specification

Supabase automatically generates OpenAPI (Swagger) spec:
- Access at: `https://[project-ref].supabase.co/rest/v1/`
- Include `Accept: application/openapi+json` header

### 14.2 Client SDKs

**Official Supabase Flutter SDK:**
```dart
import 'package:supabase_flutter/supabase_flutter.dart';

final supabase = Supabase.instance.client;

// Create flashcard
final response = await supabase
  .from('flashcards')
  .insert({
    'front': 'What is Flutter?',
    'back': 'A UI toolkit by Google',
    'source': 'manual'
  })
  .select()
  .single();
```

### 14.3 Code Examples

Provided in separate repository: `10x-cards-examples`
- Authentication flows
- CRUD operations
- Error handling patterns
- Offline-first strategies with Drift

## 15. Migration and Rollback

### 15.1 Database Migrations

Use Supabase CLI for migrations:
```bash
supabase migration new add_flashcard_tags
supabase db push
```

**Migration Best Practices:**
1. Never drop columns in production
2. Add columns as nullable first
3. Backfill data in separate migration
4. Add NOT NULL constraint in third migration
5. Test rollback on staging first

### 15.2 API Changes

**Additive Changes (Safe):**
- New optional fields
- New endpoints
- New query parameters

**Breaking Changes (Require Version Bump):**
- Renaming fields
- Changing field types
- Removing endpoints
- Changing required fields

## 16. Monitoring and Observability

### 16.1 Metrics to Track

**API Performance:**
- Request duration (p50, p95, p99)
- Error rate (4xx, 5xx)
- Request rate per endpoint
- Database connection pool usage

**Business Metrics:**
- Daily/monthly active users
- Flashcards created per user
- AI acceptance rate (success metric: ≥75%)
- AI-generated flashcard percentage (success metric: ≥75%)
- Generation success/failure rate

### 16.2 Logging

**Structured Logging Format:**
```json
{
  "timestamp": "2025-11-06T14:30:00Z",
  "level": "INFO",
  "endpoint": "/rest/v1/flashcards",
  "method": "POST",
  "user_id": "123e4567-e89b-12d3-a456-426614174000",
  "duration_ms": 45,
  "status": 201
}
```

**Log Retention:**
- Access logs: 7 days
- Error logs: 90 days
- Generation logs: Indefinite (for analytics)

### 16.3 Alerts

**Critical Alerts:**
- Error rate > 5%
- Generation endpoint failure rate > 10%
- Database connection pool exhausted
- API response time p95 > 1000ms

**Warning Alerts:**
- Acceptance rate < 70% (below success metric)
- OpenRouter API errors increasing
- Rate limit hits increasing

## 17. GDPR Compliance

### 17.1 Data Subject Rights

**Right to Access:**
- User can export all their data via API
- Export includes: flashcards, generation logs, error logs
- Format: JSON

**Right to Deletion:**
- Implemented via `DELETE /auth/v1/user`
- Cascading deletion via foreign key constraints
- Irreversible (no soft delete in MVP)
- Completes within 30 days (instant in current implementation)

**Right to Rectification:**
- User can update flashcard content via PATCH endpoint
- User can update email via Supabase Auth endpoints

### 17.2 Data Retention

| Data Type | Retention Period | Rationale |
|-----------|------------------|-----------|
| User account | Until deletion request | Required for service |
| Flashcards | Until deletion request | User's learning data |
| Generations | Until deletion request | Analytics and metrics |
| Error logs | 90 days | Debugging, then auto-delete |
| Access logs | 7 days | Security monitoring |

### 17.3 Data Processing Agreement

- Source text temporarily processed by OpenRouter.ai
- OpenRouter.ai does not retain training data (per terms)
- User consents to AI processing during first generation
- Privacy policy must disclose third-party LLM usage

## 18. Future Enhancements

### 18.1 Planned Features (Post-MVP)

1. **Flashcard Tags/Categories:**
   - New table: `tags` (id, user_id, name)
   - Junction table: `flashcard_tags` (flashcard_id, tag_id)
   - New endpoints: `/rest/v1/tags`, filtering by tag

2. **Collaborative Flashcards:**
   - Sharing mechanism
   - Public deck library
   - Import/export formats

3. **Advanced Statistics:**
   - Learning streak tracking
   - Retention rate per flashcard
   - Optimal review interval analysis

4. **Multimedia Flashcards:**
   - Image upload for front/back
   - Audio pronunciation support
   - LaTeX/math equation rendering

5. **Offline Sync:**
   - Conflict resolution strategy
   - Local queue for offline-created flashcards
   - Sync status indicators

### 18.2 API Extensions

**GraphQL API:**
- Consider for complex nested queries
- Real-time subscriptions for live updates
- More efficient for mobile bandwidth

**Webhooks:**
- Notify external systems of events
- Integration with note-taking apps
- Automation workflows

## 19. Conclusion

This API plan provides a comprehensive foundation for the 10x-cards MVP, leveraging Supabase's built-in capabilities while allowing for future extensibility. The design prioritizes:

1. **Security:** RLS policies, JWT authentication, user data isolation
2. **Performance:** Proper indexing, pagination, caching strategies
3. **Developer Experience:** RESTful conventions, clear error messages, auto-generated docs
4. **Business Goals:** Tracking success metrics (≥75% acceptance rate, ≥75% AI-generated)
5. **Compliance:** GDPR-compliant data handling and deletion

The API is production-ready for MVP launch with clear paths for scaling and feature expansion.

---

**Document Version:** 1.0  
**Last Updated:** 2025-11-06  
**Status:** Ready for Implementation

