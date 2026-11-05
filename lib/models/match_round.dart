/// Risultato di un singolo match
enum MatchOutcome {
  win('W', 'Vittoria'),
  loss('L', 'Sconfitta'),
  draw('D', 'Pareggio'),
  none('-', 'Non disputato');

  final String code;
  final String label;

  const MatchOutcome(this.code, this.label);

  static MatchOutcome fromCode(String? code) {
    switch (code) {
      case 'W':
        return MatchOutcome.win;
      case 'L':
        return MatchOutcome.loss;
      case 'D':
        return MatchOutcome.draw;
      default:
        return MatchOutcome.none;
    }
  }
}

/// Dati relativi a un singolo turno del torneo
class MatchRound {
  final int roundNumber;
  String opponentDeck;
  MatchOutcome outcome;

  MatchRound({
    required this.roundNumber,
    this.opponentDeck = '',
    this.outcome = MatchOutcome.none,
  });

  bool get isWin => outcome == MatchOutcome.win;
  bool get isLoss => outcome == MatchOutcome.loss;
  bool get isDraw => outcome == MatchOutcome.draw;
  bool get isPlayed => outcome != MatchOutcome.none;

  Map<String, dynamic> toJson() {
    return {
      'roundNumber': roundNumber,
      'opponentDeck': opponentDeck,
      'outcome': outcome.code,
    };
  }

  factory MatchRound.fromJson(Map<String, dynamic> json) {
    return MatchRound(
      roundNumber: json['roundNumber'] as int? ?? 1,
      opponentDeck: json['opponentDeck'] as String? ?? '',
      outcome: MatchOutcome.fromCode(json['outcome'] as String?),
    );
  }

  MatchRound copyWith({
    int? roundNumber,
    String? opponentDeck,
    MatchOutcome? outcome,
  }) {
    return MatchRound(
      roundNumber: roundNumber ?? this.roundNumber,
      opponentDeck: opponentDeck ?? this.opponentDeck,
      outcome: outcome ?? this.outcome,
    );
  }
}
