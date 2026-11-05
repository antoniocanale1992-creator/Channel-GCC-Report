import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'match_round.dart';

/// Report completo di partecipazione a un torneo Pokémon GCC Local
class TournamentReport {
  final String id;
  final DateTime eventDate;
  final String eventType;
  final String location;
  final String deckUsed;
  final int roundsCount;
  final List<MatchRound> rounds;
  final bool isScoreManual;
  final String? manualScore;
  final int? participantsCount;
  final String finalPlacement;
  final String pointsEarned;
  final String whatWorked;
  final String toImprove;
  final DateTime createdAt;

  TournamentReport({
    required this.id,
    required this.eventDate,
    required this.eventType,
    this.location = '',
    required this.deckUsed,
    required this.roundsCount,
    required this.rounds,
    this.isScoreManual = false,
    this.manualScore,
    this.participantsCount,
    this.finalPlacement = '',
    this.pointsEarned = '',
    this.whatWorked = '',
    this.toImprove = '',
    DateTime? createdAt,
  }) : createdAt = createdAt ?? DateTime.now();

  int get winsCount =>
      rounds.where((r) => r.outcome == MatchOutcome.win).length;

  int get lossesCount =>
      rounds.where((r) => r.outcome == MatchOutcome.loss).length;

  int get drawsCount =>
      rounds.where((r) => r.outcome == MatchOutcome.draw).length;

  int get playedRoundsCount =>
      rounds.where((r) => r.outcome != MatchOutcome.none).length;

  String get calculatedScore => '$winsCount - $lossesCount - $drawsCount';

  String get finalScoreDisplay {
    if (isScoreManual && manualScore != null && manualScore!.trim().isNotEmpty) {
      return manualScore!.trim();
    }
    return calculatedScore;
  }

  double get winRate {
    if (playedRoundsCount == 0) return 0.0;
    return (winsCount / playedRoundsCount) * 100;
  }

  String get winRateDisplay {
    if (playedRoundsCount == 0) return '0%';
    return '${winRate.toStringAsFixed(0)}%';
  }

  /// Restituisce la posizione in relazione al numero di partecipanti (es. "15/22")
  String get relativePlacementDisplay {
    if (finalPlacement.trim().isEmpty) return '';
    final p = finalPlacement.trim();

    if (participantsCount != null && participantsCount! > 0) {
      // Se è già formattato come "X/Y"
      if (p.contains('/')) return p;

      // Se è formattato come "15° su 22" o "15 su 22"
      final suMatch = RegExp(r'^(\d+)(?:°)?\s*(?:posto)?\s*\(?su\s*(\d+)\)?', caseSensitive: false).firstMatch(p);
      if (suMatch != null) {
        return '${suMatch.group(1)}/${suMatch.group(2)}';
      }

      // Estrae il numero iniziale della posizione (es. "15° posto", "15°", "15")
      final numMatch = RegExp(r'^(\d+)').firstMatch(p);
      if (numMatch != null) {
        return '${numMatch.group(1)}/$participantsCount';
      }

      // Se è una parola chiave come "Top 4" o "Top 8"
      if (p.toLowerCase().contains('top')) {
        return '$p / $participantsCount';
      }

      return '$p/$participantsCount';
    }

    return p;
  }

  /// Verifica se il giocatore è arrivato almeno in Top 8
  bool get isTop8 {
    final p = finalPlacement.toLowerCase().trim();
    if (p.isEmpty) return false;

    // Parole chiave esplicite per Top 4, Top 8, podio
    if (p.contains('top 4') ||
        p.contains('top 8') ||
        p.contains('top4') ||
        p.contains('top8') ||
        p.contains('vincitore') ||
        p.contains('primo') ||
        p.contains('secondo') ||
        p.contains('terzo')) {
      return true;
    }

    // Estrae il numero della posizione evitando falsi positivi (es. "14°" non deve matchare "4°")
    final match = RegExp(r'\b(\d+)(?:°|st|nd|rd|th)?\b').firstMatch(p);
    if (match != null) {
      final num = int.tryParse(match.group(1)!);
      if (num != null && num >= 1 && num <= 8) {
        return true;
      }
    }
    return false;
  }

  /// Colore dello score del singolo torneo:
  /// - Verde solo se si è arrivati almeno in Top 8
  /// - Giallo se win rate >= 40% (e non in Top 8)
  /// - Rosso altrimenti (win rate < 40%)
  Color get scoreColor {
    if (isTop8) {
      return AppTheme.winGreenLight;
    }
    if (winRate >= 40.0) {
      return AppTheme.drawYellowLight;
    }
    return AppTheme.lossRedLight;
  }

  /// Colore per il Win Rate % nel riepilogo globale:
  /// - Rosso se sotto il 40% (< 40%)
  /// - Giallo tra 40% e 60%
  /// - Verde se superiore al 60% (> 60%)
  static Color getWinRateColor(double winRateVal) {
    if (winRateVal < 40.0) {
      return AppTheme.lossRedLight;
    } else if (winRateVal <= 60.0) {
      return AppTheme.drawYellowLight;
    } else {
      return AppTheme.winGreenLight;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'eventDate': eventDate.toIso8601String(),
      'eventType': eventType,
      'location': location,
      'deckUsed': deckUsed,
      'roundsCount': roundsCount,
      'rounds': rounds.map((r) => r.toJson()).toList(),
      'isScoreManual': isScoreManual,
      'manualScore': manualScore,
      'participantsCount': participantsCount,
      'finalPlacement': finalPlacement,
      'pointsEarned': pointsEarned,
      'whatWorked': whatWorked,
      'toImprove': toImprove,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory TournamentReport.fromJson(Map<String, dynamic> json) {
    return TournamentReport(
      id: json['id'] as String? ?? DateTime.now().millisecondsSinceEpoch.toString(),
      eventDate: json['eventDate'] != null
          ? DateTime.tryParse(json['eventDate'] as String) ?? DateTime.now()
          : DateTime.now(),
      eventType: json['eventType'] as String? ?? 'Local',
      location: json['location'] as String? ?? '',
      deckUsed: json['deckUsed'] as String? ?? '',
      roundsCount: json['roundsCount'] as int? ?? 3,
      rounds: (json['rounds'] as List<dynamic>?)
              ?.map((item) => MatchRound.fromJson(item as Map<String, dynamic>))
              .toList() ??
          [],
      isScoreManual: json['isScoreManual'] as bool? ?? false,
      manualScore: json['manualScore'] as String?,
      participantsCount: json['participantsCount'] as int?,
      finalPlacement: json['finalPlacement'] as String? ?? '',
      pointsEarned: json['pointsEarned'] as String? ?? '',
      whatWorked: json['whatWorked'] as String? ?? '',
      toImprove: json['toImprove'] as String? ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  TournamentReport copyWith({
    String? id,
    DateTime? eventDate,
    String? eventType,
    String? location,
    String? deckUsed,
    int? roundsCount,
    List<MatchRound>? rounds,
    bool? isScoreManual,
    String? manualScore,
    int? participantsCount,
    String? finalPlacement,
    String? pointsEarned,
    String? whatWorked,
    String? toImprove,
    DateTime? createdAt,
  }) {
    return TournamentReport(
      id: id ?? this.id,
      eventDate: eventDate ?? this.eventDate,
      eventType: eventType ?? this.eventType,
      location: location ?? this.location,
      deckUsed: deckUsed ?? this.deckUsed,
      roundsCount: roundsCount ?? this.roundsCount,
      rounds: rounds ?? this.rounds,
      isScoreManual: isScoreManual ?? this.isScoreManual,
      manualScore: manualScore ?? this.manualScore,
      participantsCount: participantsCount ?? this.participantsCount,
      finalPlacement: finalPlacement ?? this.finalPlacement,
      pointsEarned: pointsEarned ?? this.pointsEarned,
      whatWorked: whatWorked ?? this.whatWorked,
      toImprove: toImprove ?? this.toImprove,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
