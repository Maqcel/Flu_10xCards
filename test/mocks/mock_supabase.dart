import 'package:mocktail/mocktail.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class MockSupabaseClient extends Mock implements SupabaseClient {}

class MockGoTrueClient extends Mock implements GoTrueClient {}

class MockPostgrestClient extends Mock implements PostgrestClient {}

class MockPostgrestFilterBuilder extends Mock
    implements PostgrestFilterBuilder<dynamic> {}

class MockPostgrestBuilder extends Mock
    implements PostgrestBuilder<dynamic, dynamic, dynamic> {}
