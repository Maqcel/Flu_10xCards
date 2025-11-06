import 'package:injectable/injectable.dart';
import 'package:xcards/app/networking/entities/entities.dart';
import 'package:xcards/features/flashcard/domain/model/flashcard_proposal_model.dart';

/// Mapper for converting between [FlashcardProposalEntity]
/// and [FlashcardProposalModel]
@injectable
class FlashcardProposalMapper {
  const FlashcardProposalMapper();

  /// Convert entity to domain model
  static FlashcardProposalModel toModel(FlashcardProposalEntity entity) =>
      FlashcardProposalModel(front: entity.front, back: entity.back);

  /// Convert domain model to entity
  static FlashcardProposalEntity toEntity(FlashcardProposalModel model) =>
      FlashcardProposalEntity(front: model.front, back: model.back);

  /// Convert list of entities to list of models
  static List<FlashcardProposalModel> toModelList(
    List<FlashcardProposalEntity> entities,
  ) => entities.map(toModel).toList();

  /// Convert list of models to list of entities
  static List<FlashcardProposalEntity> toEntityList(
    List<FlashcardProposalModel> models,
  ) => models.map(toEntity).toList();
}
