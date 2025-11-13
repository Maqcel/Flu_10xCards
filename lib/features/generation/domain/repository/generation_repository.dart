import 'package:dartz/dartz.dart';
import 'package:xcards/app/failures/app_failure.dart';
import 'package:xcards/app/networking/entities/responses/flashcard_proposal_entity.dart';

/// Contract for Generation feature data operations.
abstract class GenerationRepository {
  Future<Either<AppFailure, GenerationResponse>> generate({
    required String sourceText,
    int targetCount = 10,
  });

  Future<Either<AppFailure, Unit>> saveFlashcards({
    required String generationId,
    required List<FlashcardProposalEntity> accepted,
  });

  Future<Either<AppFailure, Unit>> updateStats({
    required String generationId,
    required int acceptedUnedited,
    required int acceptedEdited,
  });
}

/// Simple wrapper combining proposals and generationId returned by the backend.
class GenerationResponse {
  GenerationResponse({required this.generationId, required this.proposals});

  final String generationId;
  final List<FlashcardProposalEntity> proposals;
}
