/// Modello per una location di gioco (Fumetteria, Sede Regional, Negozio, ecc.)
class LocationModel {
  final String id;
  final String name; // Nome della fumetteria o sede (es. "Games Academy Bergamo")
  final String type; // Tipo: "Fumetteria", "Sede Regional", "Negozio", "Circolo", "Altro"
  final String address; // Indirizzo fisico
  final String notes; // Note o dettagli logistici
  final DateTime createdAt;

  LocationModel({
    required this.id,
    required this.name,
    this.type = 'Fumetteria',
    this.address = '',
    this.notes = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  LocationModel copyWith({
    String? id,
    String? name,
    String? type,
    String? address,
    String? notes,
    DateTime? createdAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      address: address ?? this.address,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'type': type,
      'address': address,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory LocationModel.fromJson(Map<String, dynamic> json) {
    return LocationModel(
      id: json['id'] as String,
      name: json['name'] as String,
      type: (json['type'] as String?) ?? 'Fumetteria',
      address: (json['address'] as String?) ?? '',
      notes: (json['notes'] as String?) ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'] as String)
          : DateTime.now(),
    );
  }
}
