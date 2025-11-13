// Ignore for testing purposes
// ignore_for_file: prefer_const_constructors

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:xcards/app/di/injection.dart';
import 'package:xcards/features/generation/presentation/cubit/generation_cubit.dart';
import 'package:xcards/features/generation/presentation/view/generation_page.dart';
import 'package:xcards/features/generation/presentation/view/generation_view.dart';

import '../../../../helpers/helpers.dart';

class MockGenerationCubit extends MockCubit<GenerationState>
    implements GenerationCubit {}

void main() {
  group('GenerationPage', () {
    late GenerationCubit mockGenerationCubit;

    setUp(() {
      mockGenerationCubit = MockGenerationCubit();
      getIt.registerFactory<GenerationCubit>(() => mockGenerationCubit);
    });

    tearDown(() async {
      await getIt.unregister<GenerationCubit>();
    });

    testWidgets('renders GenerationView', (tester) async {
      when(() => mockGenerationCubit.state).thenReturn(const GenerationState());
      await tester.pumpApp(GenerationPage());
      expect(find.byType(GenerationView), findsOneWidget);
    });
  });
}
