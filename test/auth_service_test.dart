import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_gcc_tracker/models/deck_model.dart';
import 'package:pokemon_gcc_tracker/services/auth_service.dart';
import 'package:pokemon_gcc_tracker/services/storage_service.dart';
import 'package:pokemon_gcc_tracker/services/sync_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('AuthService & SyncService Tests', () {
    test('Login con Google salva profilo e aggiorna notifier', () async {
      final auth = AuthService.instance;
      final user = await auth.loginWithGoogle(email: 'ash.ketchum@pokemon.com', displayName: 'Ash Ketchum');

      expect(user.displayName, equals('Ash Ketchum'));
      expect(user.email, equals('ash.ketchum@pokemon.com'));
      expect(user.provider, equals('google'));
      expect(auth.isAuthenticated, isTrue);
      expect(auth.currentUser?.email, equals('ash.ketchum@pokemon.com'));
    });

    test('Login con Apple salva profilo', () async {
      final auth = AuthService.instance;
      final user = await auth.loginWithApple(email: 'player@icloud.com', displayName: 'Apple Champion');

      expect(user.displayName, equals('Apple Champion'));
      expect(user.provider, equals('apple'));
      expect(auth.isAuthenticated, isTrue);
    });

    test('Logout rimuove utente autenticato', () async {
      final auth = AuthService.instance;
      await auth.loginWithGoogle(email: 'test@gmail.com');
      expect(auth.isAuthenticated, isTrue);

      await auth.logout();
      expect(auth.isAuthenticated, isFalse);
      expect(auth.currentUser, isNull);
    });

    test('SyncService esegue sync quando utente autenticato', () async {
      final auth = AuthService.instance;
      await auth.loginWithGoogle(email: 'sync.tester@gmail.com');

      final syncSuccess = await SyncService.instance.syncNow();
      expect(syncSuccess, isTrue);
      expect(auth.currentUser?.lastSyncAt, isNotNull);
    });

    test('deleteAccountAndData rimuove account e pulisce lo storage (GDPR compliance)', () async {
      final auth = AuthService.instance;
      final storage = StorageService.instance;

      await auth.loginWithGoogle(email: 'to.delete@gmail.com');
      await storage.saveDeck(DeckModel(id: 'deck_del', name: 'Temporary Deck', decklist: ''));

      expect((await storage.getDecks()).length, equals(1));
      expect(auth.isAuthenticated, isTrue);

      final deleted = await auth.deleteAccountAndData();
      expect(deleted, isTrue);
      expect(auth.isAuthenticated, isFalse);
      expect((await storage.getDecks()).isEmpty, isTrue);
    });
  });
}
