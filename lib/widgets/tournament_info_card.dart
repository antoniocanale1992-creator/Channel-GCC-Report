import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/deck_model.dart';
import '../models/location_model.dart';
import '../theme/app_theme.dart';

/// Card per l'inserimento delle informazioni generali del torneo (Data, Tipo evento, Mazzo)
class TournamentInfoCard extends StatelessWidget {
  final DateTime selectedDate;
  final ValueChanged<DateTime> onDateChanged;
  final TextEditingController eventTypeController;
  final TextEditingController locationController;
  final TextEditingController deckUsedController;
  final List<DeckModel> savedDecks;
  final List<LocationModel> savedLocations;

  const TournamentInfoCard({
    super.key,
    required this.selectedDate,
    required this.onDateChanged,
    required this.eventTypeController,
    required this.locationController,
    required this.deckUsedController,
    this.savedDecks = const [],
    this.savedLocations = const [],
  });

  // Tipi di evento predefiniti nel circuito ufficiale e amatoriale ('Local' per primo)
  static const List<String> eventPresets = [
    'Local',
    'League Challenge',
    'League Cup',
    'Torneo Amatoriale',
    'Pre-Release',
    'Special Event',
  ];

  // Mazzi contemporanei e più giocati nel meta attuale
  static const List<String> deckPresets = [
    'Charizard ex / Pidgeot ex',
    'Dragapult ex / Dusknoir',
    'Gardevoir ex',
    'Raging Bolt ex / Ogerpon',
    'Terapagos ex / Palkia',
    'Archaludon ex',
    'Miraidon ex / Iron Hands',
    'Regidrago VSTAR',
    'Lugia VSTAR',
    'Roaring Moon ex',
    'Gholdengo ex',
    'Ceruledge ex',
  ];

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2035),
      locale: const Locale('it', 'IT'),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: AppTheme.pokemonBlueLight,
              onPrimary: Colors.white,
              surface: AppTheme.darkSurface,
              onSurface: AppTheme.textPrimary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != selectedDate) {
      onDateChanged(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    // Formattazione data in italiano
    final dateFormatted = DateFormat('EEEE d MMMM yyyy', 'it_IT').format(selectedDate);
    final capitalizedDate = dateFormatted[0].toUpperCase() + dateFormatted.substring(1);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Titolo sezione con icona
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.pokemonBlue.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(
                    Icons.event_note,
                    color: AppTheme.pokemonBlueLight,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'Info Torneo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),

            // 1. Data dell'Evento
            const Text(
              "Data dell'evento",
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            InkWell(
              onTap: () => _pickDate(context),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppTheme.inputFill,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.darkBorder),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.calendar_month,
                      color: AppTheme.pokemonBlueLight,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        capitalizedDate,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.darkBorder.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Cambia',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 18),

            // 2. Tipo di Evento
            const Text(
              'Tipo di Evento',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: eventTypeController,
              decoration: const InputDecoration(
                hintText: 'es. League Challenge, Torneo Amatoriale...',
                prefixIcon: Icon(Icons.emoji_events_outlined, color: AppTheme.ultraBallGold, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Inserisci il tipo di evento';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // Chip suggerimenti tipo evento
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: eventPresets.map((preset) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text(preset),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: AppTheme.darkSurface,
                      onPressed: () {
                        eventTypeController.text = preset;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
            const SizedBox(height: 18),

            // Location (Fumetteria / Luogo dell'evento)
            const Text(
              'Location (Fumetteria / Negozio)',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            if (savedLocations.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Seleziona da "Le Mie Location"',
                  prefixIcon: Icon(Icons.storefront, color: AppTheme.pokemonBlueLight, size: 20),
                ),
                dropdownColor: AppTheme.darkSurface,
                items: savedLocations.map((loc) {
                  return DropdownMenuItem(
                    value: loc.name,
                    child: Text('${loc.name} (${loc.type})', overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    locationController.text = val;
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: locationController,
              decoration: const InputDecoration(
                hintText: 'es. Fumetteria Il Covo, Games Academy, Lega Roma...',
                prefixIcon: Icon(Icons.edit_location_alt_outlined, color: AppTheme.pokemonBlueLight, size: 20),
              ),
            ),
            const SizedBox(height: 18),

            // 3. Mazzo Utilizzato
            const Text(
              'Mazzo Utilizzato',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 6),
            if (savedDecks.isNotEmpty) ...[
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: 'Seleziona da "I Miei Mazzi"',
                  prefixIcon: Icon(Icons.style_rounded, color: AppTheme.ultraBallGold, size: 20),
                ),
                dropdownColor: AppTheme.darkSurface,
                items: savedDecks.map((deck) {
                  final cards = deck.totalCardsCount;
                  final label = cards > 0 ? '${deck.name} ($cards carte)' : deck.name;
                  return DropdownMenuItem(
                    value: deck.name,
                    child: Text(label, overflow: TextOverflow.ellipsis),
                  );
                }).toList(),
                onChanged: (val) {
                  if (val != null) {
                    deckUsedController.text = val;
                  }
                },
              ),
              const SizedBox(height: 8),
            ],
            TextFormField(
              controller: deckUsedController,
              decoration: const InputDecoration(
                hintText: 'es. Charizard ex / Pidgeot ex',
                prefixIcon: Icon(Icons.style_outlined, color: AppTheme.pokemonBlueLight, size: 20),
              ),
              validator: (val) {
                if (val == null || val.trim().isEmpty) {
                  return 'Inserisci il mazzo utilizzato';
                }
                return null;
              },
            ),
            const SizedBox(height: 8),
            // Chip suggerimenti mazzi meta
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: deckPresets.map((deck) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 6.0),
                    child: ActionChip(
                      label: Text(deck),
                      labelStyle: const TextStyle(fontSize: 12),
                      backgroundColor: AppTheme.darkSurface,
                      onPressed: () {
                        deckUsedController.text = deck;
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
