# Generation View – Implementation Plan

## 1. Purpose
UI for generating flashcards from text via OpenRouter LLM.
User flow: paste/enter text → press Generate → show loading → display proposals list (cards) → swipe/accept/edit → Save accepted → update Generation stats.

## 2. Functional Requirements (from PRD/API)
1. `source_text` 1 000–10 000 chars validation.
2. Call RPC `generate_flashcards` with model id + target_count.
3. Show proposals list as swipeable cards:
   • Swipe right = accept (unedited)  
   • Swipe up   = edit (open EditModal)  
   • Swipe left  = reject
4. Counters: accepted, edited, rejected (live).
5. Save → batch POST `/rest/v1/flashcards` (accepted list) + PATCH generation stats.
6. Error states: validation error, API error, timeout.

## 3. Widget Tree (high-level)
```
GenerationPage (Scaffold)
 ├─ AppBar (title: l10n.generationTitle)
 ├─ Body (BlocProvider<GenerationCubit>)
 │   ├─ Step1InputView (shows TextField + char counter + Generate button)
 │   ├─ Step2LoadingView (CircularProgressIndicator)
 │   ├─ Step3ProposalsView
 │   │    ├─ Stack
 │   │    │   └─ SwipeDeck(proposals)
 │   │    └─ BottomPanel (stats + Save button)
 │   └─ ErrorView (Retry)
 └─ EditFlashcardModal (showModalBottomSheet)
```

## 4. State Management
Cubit: `GenerationCubit` with states:
```
GenerationState {
  status: initial | validating | loading | ready | saving | success | failure;
  sourceText: String;
  proposals: List<FlashcardProposalEntity>;
  accepted: List<FlashcardProposalEntity>;
  edited: List<FlashcardProposalEntity>;
  error: AppFailure?;
}
```
Events => Cubit methods:
• generate(text)  
• swipeAccept(index)  
• swipeReject(index)  
• editProposal(index, newFront, newBack)  
• saveAccepted()

## 5. Use Cases
1. `ValidateSourceTextUseCase` → returns Failure or OK.
2. `GenerateFlashcardsUseCase` (calls Supabase Edge Function).
3. `SaveFlashcardsUseCase` (batch insert).
4. `UpdateGenerationStatsUseCase`.

## 6. API Integration
Repository `GenerationRepository`:
```dart
Future<Either<AppFailure, GenerationProposalEntity>> generate(String text, String model, int count);
Future<Either<AppFailure, Unit>> saveFlashcards(List<FlashcardProposalEntity>, String generationId);
Future<Either<AppFailure, Unit>> updateStats(String generationId, int accepted, int edited);
```

## 7. Validation Rules
• Disable Generate button until length ≥1 000.  
• Live char counter (red if >10 000).  
• Save button disabled if accepted list empty.

## 8. UI/UX Details
• Use `AppDimensions` for padding / spacing.  
• TextField multiline with maxLength 10 000.  
• SwipeDeck can use custom `DismissibleStack` with Draggable/Dismissible.  
• BottomPanel shows counters (accepted, edited, remaining).  
• FAB in proposals view opens Edit modal for current card alternative.  
• Snackbars for errors / success.

## 9. Navigation
• Presented as fullscreen dialog route (`GenerationRoute`).  
• Upon success → popUntil Dashboard and show snackbar "{n} flashcards saved".

## 10. Testing Strategy
Widget tests:
• Validate button enabling/disabling.  
• Swipe interactions update counters.  
• Error state renders correctly.
Cubit tests with mock repository.

## 12. Implementation Steps (3×3 workflow)
1. Create data layer (DTOs already exist) + repository + use cases.  
2. Implement Cubit + states + unit tests.  
3. Build Step1InputView UI + validation.  
--- feedback ---  
4. Add API integration + loading state.  
5. Build SwipeDeck UI & interactions.  
6. Counters + Save flow.  
--- feedback ---  
7. Edit modal + update lists.  
8. Success path (save + stats) + navigation.  
9. Error handling & polish + l10n strings.

_Last updated: 2025-11-12_
