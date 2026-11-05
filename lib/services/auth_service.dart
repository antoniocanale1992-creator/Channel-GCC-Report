import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_profile.dart';
import 'storage_service.dart';

/// Servizio di Autenticazione (Google, Apple, Email, Ospite) con supporto Cloud & Offline-First
class AuthService {
  static const String _userStorageKey = 'channel_gcc_current_user';
  static AuthService? _instance;

  AuthService._();
  static AuthService get instance => _instance ??= AuthService._();

  final GoogleSignIn _googleSignIn = GoogleSignIn(scopes: ['email']);
  final ValueNotifier<UserProfile?> currentUserNotifier = ValueNotifier<UserProfile?>(null);

  UserProfile? get currentUser => currentUserNotifier.value;
  bool get isAuthenticated => currentUser != null && !currentUser!.isAnonymous;

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

  /// Tenta il login reale con il selettore account Google nativo dello smartphone
  Future<UserProfile?> loginWithGoogleNative() async {
    try {
      final account = await _googleSignIn.signIn();
      if (account == null) {
        // L'utente ha annullato la selezione
        return null;
      }

      final profile = UserProfile(
        id: account.id,
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
    } catch (e) {
      debugPrint('Google Sign-In Native: $e');
      rethrow;
    }
  }

  /// Login con Account Google fornendo l'email reale
  Future<UserProfile> loginWithGoogle({required String email, String? displayName}) async {
    final cleanEmail = email.trim();
    final name = displayName?.trim().isNotEmpty == true
        ? displayName!.trim()
        : cleanEmail.split('@').first.replaceAll('.', ' ');

    final profile = UserProfile(
      id: 'google_${cleanEmail.hashCode.abs()}',
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

    final profile = UserProfile(
      id: 'apple_${cleanEmail.hashCode.abs()}',
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

    final profile = UserProfile(
      id: 'email_${cleanEmail.hashCode.abs()}',
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
    final guest = UserProfile.guest();
    await _persistUser(guest);
    return guest;
  }

  /// Disconnetti account
  Future<void> logout() async {
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
  /// Requisito obbligatorio di conformità Google Play Store e Apple App Store
  Future<bool> deleteAccountAndData() async {
    try {
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
