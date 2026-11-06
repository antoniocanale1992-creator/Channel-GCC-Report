/// Modello per il profilo utente autenticato (Google, Apple, Email o Ospite)
class UserProfile {
  final String id;
  final String displayName;
  final String email;
  final String? photoUrl;
  final String provider; // 'google', 'apple', 'email', 'guest'
  final DateTime createdAt;
  final DateTime? lastSyncAt;
  final bool isAnonymous;

  UserProfile({
    required this.id,
    required this.displayName,
    required this.email,
    this.photoUrl,
    required this.provider,
    required this.createdAt,
    this.lastSyncAt,
    this.isAnonymous = false,
  });

  UserProfile copyWith({
    String? id,
    String? displayName,
    String? email,
    String? photoUrl,
    String? provider,
    DateTime? lastSyncAt,
    bool? isAnonymous,
  }) {
    return UserProfile(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
      provider: provider ?? this.provider,
      createdAt: createdAt,
      lastSyncAt: lastSyncAt ?? this.lastSyncAt,
      isAnonymous: isAnonymous ?? this.isAnonymous,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'displayName': displayName,
      'email': email,
      'photoUrl': photoUrl,
      'provider': provider,
      'createdAt': createdAt.toIso8601String(),
      'lastSyncAt': lastSyncAt?.toIso8601String(),
      'isAnonymous': isAnonymous,
    };
  }

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as String? ?? 'guest_user',
      displayName: json['displayName'] as String? ?? 'Allenatore Pokémon',
      email: json['email'] as String? ?? '',
      photoUrl: json['photoUrl'] as String?,
      provider: json['provider'] as String? ?? 'guest',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
      lastSyncAt: json['lastSyncAt'] != null
          ? DateTime.tryParse(json['lastSyncAt'] as String)
          : null,
      isAnonymous: json['isAnonymous'] as bool? ?? false,
    );
  }

  /// Profilo di default per utente ospite (offline-first)
  factory UserProfile.guest() {
    return UserProfile(
      id: 'guest_${DateTime.now().millisecondsSinceEpoch}',
      displayName: 'Ospite / Locale',
      email: '',
      provider: 'guest',
      createdAt: DateTime.now(),
      isAnonymous: true,
    );
  }

  String get providerDisplayName {
    switch (provider) {
      case 'google':
        return 'Google';
      case 'apple':
        return 'Apple ID';
      case 'email':
        return 'Email';
      case 'guest':
      default:
        return 'Ospite Locale';
    }
  }
}
