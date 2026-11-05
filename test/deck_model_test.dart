import 'package:flutter_test/flutter_test.dart';
import 'package:pokemon_gcc_tracker/models/deck_model.dart';
import 'package:pokemon_gcc_tracker/models/location_model.dart';
import 'package:pokemon_gcc_tracker/services/storage_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  group('DeckModel Tests', () {
    test('Calcolo corretto del totale carte e righe da decklist standard PTCG', () {
      const sampleList = '''
Pokémon: 22
4 Slowpoke SCR 57
3 Slowking SCR 58
4 Mega Kangaskhan ex MEG 104
2 Latias ex SSP 76
2 Metagross CRI 61
2 Kyurem SFA 47
1 Fezandipiti ex ASC 142
1 Zeraora DRI 78
1 Lillie's Clefairy ex JTG 56
1 Meowth ex POR 62
1 Mew ex 30C 66

Trainer: 28
4 Ciphermaniac's Codebreaking TEF 145
4 Lillie's Determination MEG 119
4 Ultra Ball MEG 131
4 Poké Pad POR 81
3 Wondrous Patch PFL 94
2 Night Stretcher ASC 196
1 Switch MEG 130
1 Secret Box TWM 163
1 Lucky Helmet TWM 158
4 Academy at Night SFA 54

Energy: 10
4 Psychic Energy MEE 13
4 Telepathic Psychic Energy POR 88
2 Boomerang Energy TWM 166
''';

      final deck = DeckModel(
        id: 'deck_1',
        name: 'Slowking SCR / Mega Kangaskhan ex',
        decklist: sampleList,
      );

      expect(deck.name, 'Slowking SCR / Mega Kangaskhan ex');
      expect(deck.totalCardsCount, 60);
      expect(deck.linesCount, 27);
    });

    test('Serializzazione e deserializzazione JSON DeckModel', () {
      final original = DeckModel(
        id: 'deck_json_test',
        name: 'Charizard ex / Pidgeot ex',
        decklist: '4 Charmander MEW 4\n3 Charizard ex OBF 125',
      );

      final json = original.toJson();
      final restored = DeckModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.decklist, original.decklist);
      expect(restored.totalCardsCount, 7);
    });

    test('Salvataggio, recupero ed eliminazione mazzi in StorageService', () async {
      final storage = StorageService.instance;
      expect(await storage.getDecks(), isEmpty);

      final deck = DeckModel(
        id: 'storage_deck_1',
        name: 'Dragapult ex',
        decklist: '4 Dreepy TWM\n3 Dragapult ex TWM',
      );

      final saved = await storage.saveDeck(deck);
      expect(saved, true);

      final loadedList = await storage.getDecks();
      expect(loadedList.length, 1);
      expect(loadedList.first.name, 'Dragapult ex');

      final deleted = await storage.deleteDeck('storage_deck_1');
      expect(deleted, true);

      final emptyList = await storage.getDecks();
      expect(emptyList, isEmpty);
    });
  });

  group('LocationModel Tests', () {
    test('Serializzazione e deserializzazione JSON LocationModel', () {
      final original = LocationModel(
        id: 'loc_1',
        name: 'Games Academy Bergamo',
        type: 'Fumetteria',
        address: 'Via Angelo Maj 10',
        notes: 'Parcheggio sul retro',
      );

      final json = original.toJson();
      final restored = LocationModel.fromJson(json);

      expect(restored.id, original.id);
      expect(restored.name, original.name);
      expect(restored.type, 'Fumetteria');
      expect(restored.address, 'Via Angelo Maj 10');
      expect(restored.notes, 'Parcheggio sul retro');
    });

    test('Salvataggio, recupero ed eliminazione location in StorageService', () async {
      final storage = StorageService.instance;
      expect(await storage.getLocations(), isEmpty);

      final loc = LocationModel(
        id: 'loc_storage_1',
        name: 'Il Covo del Nerd',
        type: 'Fumetteria',
        address: 'Via Nazionale 12',
      );

      final saved = await storage.saveLocation(loc);
      expect(saved, true);

      final loadedList = await storage.getLocations();
      expect(loadedList.length, 1);
      expect(loadedList.first.name, 'Il Covo del Nerd');

      final deleted = await storage.deleteLocation('loc_storage_1');
      expect(deleted, true);

      final emptyList = await storage.getLocations();
      expect(emptyList, isEmpty);
    });
  });
}
