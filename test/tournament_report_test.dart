import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_gcc_tracker/models/match_round.dart';
import 'package:pokemon_gcc_tracker/models/tournament_report.dart';

void main() {
  group('TournamentReport & MatchRound Tests', () {
    test('Calcolo corretto dello score W-L-D e della Win Rate', () {
      final rounds = [
        MatchRound(roundNumber: 1, opponentDeck: 'Gardevoir ex', outcome: MatchOutcome.win),
        MatchRound(roundNumber: 2, opponentDeck: 'Charizard ex', outcome: MatchOutcome.win),
        MatchRound(roundNumber: 3, opponentDeck: 'Dragapult ex', outcome: MatchOutcome.loss),
        MatchRound(roundNumber: 4, opponentDeck: 'Lugia VSTAR', outcome: MatchOutcome.draw),
      ];

      final report = TournamentReport(
        id: 'test_1',
        eventDate: DateTime(2026, 11, 4),
        eventType: 'League Challenge',
        deckUsed: 'Miraidon ex',
        roundsCount: 4,
        rounds: rounds,
        finalPlacement: '2° posto',
        pointsEarned: '15 CP',
      );

      expect(report.winsCount, 2);
      expect(report.lossesCount, 1);
      expect(report.drawsCount, 1);
      expect(report.calculatedScore, '2 - 1 - 1');
      expect(report.finalScoreDisplay, '2 - 1 - 1');
      expect(report.playedRoundsCount, 4);
      expect(report.winRate, 50.0);
      expect(report.winRateDisplay, '50%');
    });

    test('Supporto per score personalizzato / manuale', () {
      final report = TournamentReport(
        id: 'test_2',
        eventDate: DateTime(2026, 11, 4),
        eventType: 'League Cup',
        deckUsed: 'Raging Bolt ex',
        roundsCount: 3,
        rounds: [
          MatchRound(roundNumber: 1, opponentDeck: 'Charizard', outcome: MatchOutcome.win),
          MatchRound(roundNumber: 2, opponentDeck: 'Gardevoir', outcome: MatchOutcome.win),
          MatchRound(roundNumber: 3, opponentDeck: 'Lugia', outcome: MatchOutcome.win),
        ],
        isScoreManual: true,
        manualScore: '3 - 0 - 0 (Top 4 Bye)',
      );

      expect(report.calculatedScore, '3 - 0 - 0');
      expect(report.finalScoreDisplay, '3 - 0 - 0 (Top 4 Bye)');
    });

    test('Serializzazione e deserializzazione JSON', () {
      final original = TournamentReport(
        id: 'test_3',
        eventDate: DateTime(2026, 11, 4),
        eventType: 'Torneo Amatoriale',
        deckUsed: 'Gholdengo ex',
        roundsCount: 2,
        rounds: [
          MatchRound(roundNumber: 1, opponentDeck: 'Charizard', outcome: MatchOutcome.win),
          MatchRound(roundNumber: 2, opponentDeck: 'Miraidon', outcome: MatchOutcome.loss),
        ],
        finalPlacement: '3° posto',
        pointsEarned: '1 Busta',
        whatWorked: 'Accelerazione energie ottima con Metal Maker',
        toImprove: 'Migliorare la gestione dei supporter di pescata',
      );

      final json = original.toJson();
      final restored = TournamentReport.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.deckUsed, original.deckUsed);
      expect(restored.eventType, original.eventType);
      expect(restored.rounds.length, 2);
      expect(restored.rounds[0].outcome, MatchOutcome.win);
      expect(restored.rounds[1].outcome, MatchOutcome.loss);
      expect(restored.whatWorked, original.whatWorked);
      expect(restored.toImprove, original.toImprove);
    });

    test('Logica colore dello score (Top 8 verde, winrate >= 40% giallo, altrimenti rosso)', () {
      // 1. Top 8 -> Verde indipendentemente dalla winrate
      final top8Report = TournamentReport(
        id: 'top8',
        eventDate: DateTime.now(),
        eventType: 'Local',
        deckUsed: 'Charizard ex',
        roundsCount: 3,
        rounds: [
          MatchRound(roundNumber: 1, outcome: MatchOutcome.loss),
          MatchRound(roundNumber: 2, outcome: MatchOutcome.win),
          MatchRound(roundNumber: 3, outcome: MatchOutcome.loss),
        ],
        finalPlacement: 'Top 8 (su 24)',
      );
      expect(top8Report.isTop8, true);
      expect(top8Report.scoreColor, equals(const Color(0xFF22C55E)));

      // 2. Fuori dalla Top 8 ma win rate >= 40% -> Giallo
      final yellowReport = TournamentReport(
        id: 'yellow',
        eventDate: DateTime.now(),
        eventType: 'Local',
        deckUsed: 'Dragapult ex',
        roundsCount: 4,
        rounds: [
          MatchRound(roundNumber: 1, outcome: MatchOutcome.win),
          MatchRound(roundNumber: 2, outcome: MatchOutcome.win),
          MatchRound(roundNumber: 3, outcome: MatchOutcome.loss),
          MatchRound(roundNumber: 4, outcome: MatchOutcome.loss),
        ],
        finalPlacement: '9° posto',
      );
      expect(yellowReport.isTop8, false);
      expect(yellowReport.winRate, 50.0);
      expect(yellowReport.scoreColor, equals(const Color(0xFFFBBF24)));

      // 3. Fuori dalla Top 8 con win rate < 40% -> Rosso
      final redReport = TournamentReport(
        id: 'red',
        eventDate: DateTime.now(),
        eventType: 'Local',
        deckUsed: 'Lugia VSTAR',
        roundsCount: 4,
        rounds: [
          MatchRound(roundNumber: 1, outcome: MatchOutcome.win),
          MatchRound(roundNumber: 2, outcome: MatchOutcome.loss),
          MatchRound(roundNumber: 3, outcome: MatchOutcome.loss),
          MatchRound(roundNumber: 4, outcome: MatchOutcome.loss),
        ],
        finalPlacement: '14° posto',
      );
      expect(redReport.isTop8, false);
      expect(redReport.winRate, 25.0);
      expect(redReport.scoreColor, equals(const Color(0xFFEF4444)));
    });

    test('Location e relativePlacementDisplay con numero di partecipanti', () {
      final report = TournamentReport(
        id: 'placement_test',
        eventDate: DateTime.now(),
        eventType: 'Local',
        location: 'Games Academy',
        deckUsed: 'Charizard ex',
        roundsCount: 3,
        rounds: [],
        participantsCount: 22,
        finalPlacement: '15°',
      );

      expect(report.location, 'Games Academy');
      expect(report.relativePlacementDisplay, '15/22');

      final top4Su24 = TournamentReport(
        id: 'p2',
        eventDate: DateTime.now(),
        eventType: 'Local',
        deckUsed: 'Dragapult ex',
        roundsCount: 3,
        rounds: [],
        participantsCount: 24,
        finalPlacement: 'Top 4',
      );
      expect(top4Su24.relativePlacementDisplay, 'Top 4 / 24');

      final explicitSlash = TournamentReport(
        id: 'p3',
        eventDate: DateTime.now(),
        eventType: 'Local',
        deckUsed: 'Lugia VSTAR',
        roundsCount: 3,
        rounds: [],
        participantsCount: 30,
        finalPlacement: '8/30',
      );
      expect(explicitSlash.relativePlacementDisplay, '8/30');
    });

    test('getWinRateColor: rosso < 40%, giallo 40%-60%, verde > 60%', () {
      // < 40% -> Rosso
      expect(TournamentReport.getWinRateColor(35.0), equals(const Color(0xFFEF4444)));
      expect(TournamentReport.getWinRateColor(0.0), equals(const Color(0xFFEF4444)));

      // 40% - 60% -> Giallo
      expect(TournamentReport.getWinRateColor(40.0), equals(const Color(0xFFFBBF24)));
      expect(TournamentReport.getWinRateColor(50.0), equals(const Color(0xFFFBBF24)));
      expect(TournamentReport.getWinRateColor(60.0), equals(const Color(0xFFFBBF24)));

      // > 60% -> Verde
      expect(TournamentReport.getWinRateColor(61.0), equals(const Color(0xFF22C55E)));
      expect(TournamentReport.getWinRateColor(100.0), equals(const Color(0xFF22C55E)));
    });
  });
}
