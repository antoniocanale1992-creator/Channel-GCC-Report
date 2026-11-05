/// Modello per un mazzo Pokémon GCC salvato dall'utente
class DeckModel {
  final String id;
  final String name; // Titolo del mazzo (es. "Slowking SCR / Mega Kangaskhan ex")
  final String decklist; // Lista completa in formato standard Pokémon TCG / Limitless
  final DateTime createdAt;
  final DateTime? updatedAt;

  DeckModel({
    required this.id,
    required this.name,
    required this.decklist,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Calcola il numero totale approssimativo di carte sommando le quantità indicate (es. "4 Slowpoke SCR" -> 4)
  int get totalCardsCount {
    if (decklist.trim().isEmpty) return 0;

    int total = 0;
    final lines = decklist.split('\n');
    final regExp = RegExp(r'^\s*(\d+)\s+');

    for (final line in lines) {
      final match = regExp.firstMatch(line);
      if (match != null) {
        final count = int.tryParse(match.group(1)!);
        if (count != null) {
          total += count;
        }
      }
    }

    return total;
  }

  /// Conteggio righe non vuote
  int get linesCount => decklist
      .split('\n')
      .where((line) => line.trim().isNotEmpty)
      .length;

  DeckModel copyWith({
    String? id,
    String? name,
    String? decklist,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return DeckModel(
      id: id ?? this.id,
      name: name ?? this.name,
      decklist: decklist ?? this.decklist,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'decklist': decklist,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  factory DeckModel.fromJson(Map<String, dynamic> json) {
    return DeckModel(
      id: json['id'] as String,
      name: json['name'] as String,
      decklist: (json['decklist'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'] as String)
          : null,
    );
  }
}
