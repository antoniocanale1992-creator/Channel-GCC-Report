import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

/// Servizio di Autenticazione (Google, Apple, Email, Ospite) con supporto Firebase Auth & Cloud Firestore
class AuthService {
  static const String _userStorageKey = 'channel_gcc_current_user';
  static AuthService? _instance;

  AuthService._();
  static AuthService get instance => _instance ??= AuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final ValueNotifier<UserProfile?> currentUserNotifier = ValueNotifier<UserProfile?>(null);

  UserProfile? get currentUser => currentUserNotifier.value;
  bool get isAuthenticated => currentUser != null && !currentUser!.isAnonymous;

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  /// Restituisce l'UID ufficiale di Firebase Auth o l'ID locale del profilo
  String? get currentUid => _auth?.currentUser?.uid ?? currentUser?.id;

  /// Inizializza il servizio leggendo la sessione salvata
  Future<UserProfile?> init() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_userStorageKey);
      if (raw != null && raw.isNotEmpty) {
        final profile = UserProfile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
        // Se sul dispositivo è rimasto il vecchio account finto di test, ripuliscilo all'istante
        if (profile.email.toLowerCase().contains('allenatore.gcc') ||
            profile.email == 'apple.player@icloud.com') {
          await prefs.remove(_userStorageKey);
          currentUserNotifier.value = null;
          return null;
        }

        // Se Firebase Auth ha un utente attivo, sincronizza l'ID con l'UID ufficiale di Firebase
        final fbUser = _auth?.currentUser;
        if (fbUser != null) {
          final updated = profile.copyWith(id: fbUser.uid);
          currentUserNotifier.value = updated;
          return updated;
        }

        currentUserNotifier.value = profile;
        return profile;
      }
    } catch (_) {}
    return null;
  }

  /// Salva il profilo utente corrente in memoria locale
  Future<void> _persistUser(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userStorageKey, jsonEncode(profile.toJson()));
    currentUserNotifier.value = profile;
  }

  /// Tenta il login reale con Google (Web Popup o Native Mobile) con integrazione Firebase Auth
  Future<UserProfile?> loginWithGoogleNative() async {
    try {
      if (kIsWeb) {
        // Su Web / PWA usa il flusso popup ufficiale di Firebase Auth
        if (_auth == null) {
          throw Exception('Firebase Auth non inizializzato');
        }
        final googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        final userCredential = await _auth!.signInWithPopup(googleProvider);
        final user = userCredential.user;
        if (user == null) return null;

        final profile = UserProfile(
          id: user.uid,
          displayName: user.displayName?.isNotEmpty == true
              ? user.displayName!
              : (user.email?.split('@').first ?? 'Allenatore'),
          email: user.email ?? '',
          photoUrl: user.photoURL,
          provider: 'google',
          createdAt: DateTime.now(),
          lastSyncAt: DateTime.now(),
          isAnonymous: false,
        );

        await _persistUser(profile);
        return profile;
      } else {
        // Su Mobile (Android / iOS)
        final account = await _googleSignIn.signIn();
        if (account == null) {
          return null;
        }

        String uid = account.id;
        if (_auth != null) {
          try {
            final auth = await account.authentication;
            final credential = GoogleAuthProvider.credential(
              accessToken: auth.accessToken,
              idToken: auth.idToken,
            );
            final userCred = await _auth!.signInWithCredential(credential);
            if (userCred.user != null) {
              uid = userCred.user!.uid;
            }
          } catch (e) {
            debugPrint('Firebase Auth link via credential: $e');
          }
        }

        final profile = UserProfile(
          id: uid,
          displayName: account.displayName?.isNotEmpty == true
              ? account.displayName!
              : account.email.split('@').first,
          email: account.email,
          photoUrl: account.photoUrl,
          provider: 'google',
          createdAt: DateTime.now(),
          lastSyncAt: DateTime.now(),
          isAnonymous: false,
        );

        await _persistUser(profile);
        return profile;
      }
    } catch (e) {
      debugPrint('Google Sign-In Native: $e');
      rethrow;
    }
  }

  /// Login con Account Google fornendo l'email reale (fallback offline-first)
  Future<UserProfile> loginWithGoogle({required String email, String? displayName}) async {
    final cleanEmail = email.trim();
    final name = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : cleanEmail.split('@').first.replaceAll('.', ' ');

    String uid = _auth?.currentUser?.uid ?? 'google_${cleanEmail.hashCode.abs()}';

    if (_auth != null && _auth!.currentUser == null) {
      try {
        final anon = await _auth!.signInAnonymously();
        if (anon.user != null) {
          uid = anon.user!.uid;
        }
      } catch (_) {}
    }

    final profile = UserProfile(
      id: uid,
      displayName: name,
      email: cleanEmail,
      provider: 'google',
      createdAt: DateTime.now(),
      lastSyncAt: DateTime.now(),
      isAnonymous: false,
    );

    await _persistUser(profile);
    return profile;
  }

  /// Login con Apple ID con email reale
  Future<UserProfile> loginWithApple({required String email, String? displayName}) async {
    final cleanEmail = email.trim();
    final name = displayName?.trim().isNotEmpty == true ? displayName!.trim() : cleanEmail.split('@').first;

    String uid = _auth?.currentUser?.uid ?? 'apple_${cleanEmail.hashCode.abs()}';

    if (_auth != null && _auth!.currentUser == null) {
      try {
        final anon = await _auth!.signInAnonymously();
        if (anon.user != null) {
          uid = anon.user!.uid;
        }
      } catch (_) {}
    }

    final profile = UserProfile(
      id: uid,
      displayName: name,
      email: cleanEmail,
      provider: 'apple',
      createdAt: DateTime.now(),
      lastSyncAt: DateTime.now(),
      isAnonymous: false,
    );

    await _persistUser(profile);
    return profile;
  }

  /// Login con Email e Password
  Future<UserProfile> loginWithEmail(String email, String password, {String? displayName}) async {
    final cleanEmail = email.trim();
    final name = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : cleanEmail.split('@').first;

    String uid = 'email_${cleanEmail.hashCode.abs()}';
    if (_auth != null) {
      try {
        final userCred = await _auth!.signInWithEmailAndPassword(
          email: cleanEmail,
          password: password,
        );
        if (userCred.user != null) {
          uid = userCred.user!.uid;
        }
      } catch (_) {
        try {
          final userCred = await _auth!.createUserWithEmailAndPassword(
            email: cleanEmail,
            password: password,
          );
          if (userCred.user != null) {
            uid = userCred.user!.uid;
          }
        } catch (_) {}
      }
    }

    final profile = UserProfile(
      id: uid,
      displayName: name,
      email: cleanEmail,
      provider: 'email',
      createdAt: DateTime.now(),
      lastSyncAt: DateTime.now(),
      isAnonymous: false,
    );

    await _persistUser(profile);
    return profile;
  }

  /// Continua come Ospite (Offline-First puro)
  Future<UserProfile> continueAsGuest() async {
    String uid = 'guest_${DateTime.now().millisecondsSinceEpoch}';
    if (_auth != null) {
      try {
        final anon = await _auth!.signInAnonymously();
        if (anon.user != null) {
          uid = anon.user!.uid;
        }
      } catch (_) {}
    }

    final guest = UserProfile(
      id: uid,
      displayName: 'Ospite / Locale',
      email: '',
      provider: 'guest',
      createdAt: DateTime.now(),
      isAnonymous: true,
    );
    await _persistUser(guest);
    return guest;
  }

  /// Disconnetti account
  Future<void> logout() async {
    try {
      await _auth?.signOut();
    } catch (_) {}
    try {
      await _googleSignIn.signOut();
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userStorageKey);
    currentUserNotifier.value = null;
  }

  /// Aggiorna il timestamp dell'ultimo sync completato
  Future<void> updateLastSync(DateTime time) async {
    if (currentUser != null) {
      final updated = currentUser!.copyWith(lastSyncAt: time);
      await _persistUser(updated);
    }
  }

  /// Elimina account e tutti i dati locali e cloud
  Future<bool> deleteAccountAndData() async {
    try {
      try {
        await _auth?.currentUser?.delete();
      } catch (_) {}
      try {
        await _auth?.signOut();
      } catch (_) {}
      try {
        await _googleSignIn.signOut();
      } catch (_) {}
      await StorageService.instance.clearAll();
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userStorageKey);
      currentUserNotifier.value = null;
      return true;
    } catch (_) {
      return false;
    }
  }
}
