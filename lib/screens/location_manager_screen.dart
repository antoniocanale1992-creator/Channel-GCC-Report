import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/location_model.dart';
import '../services/storage_service.dart';
import '../theme/app_theme.dart';
import '../widgets/tcg_playmat_background.dart';

/// Schermata per la gestione e consultazione delle location e fumetterie dove si disputano tornei
class LocationManagerScreen extends StatefulWidget {
  const LocationManagerScreen({super.key});

  @override
  State<LocationManagerScreen> createState() => _LocationManagerScreenState();
}

class _LocationManagerScreenState extends State<LocationManagerScreen> {
  List<LocationModel> _locations = [];
  bool _isLoading = true;

  static const List<String> locationTypes = [
    'Fumetteria',
    'Sede Regional / Cup',
    'Negozio',
    'Circolo / Associazione',
    'Altro',
  ];

  @override
  void initState() {
    super.initState();
    _loadLocations();
  }

  Future<void> _loadLocations() async {
    setState(() => _isLoading = true);
    final list = await StorageService.instance.getLocations();
    if (mounted) {
      setState(() {
        _locations = list;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteLocation(LocationModel location) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: AppTheme.darkBorder),
        ),
        title: const Text('Elimina Location', style: TextStyle(color: AppTheme.textPrimary)),
        content: Text(
          'Sei sicuro di voler eliminare "${location.name}"?',
          style: const TextStyle(color: AppTheme.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annulla'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.lossRed),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Elimina'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      await StorageService.instance.deleteLocation(location.id);
      _loadLocations();
    }
  }

  Future<void> _openMaps(LocationModel loc) async {
    final query = loc.address.trim().isNotEmpty ? loc.address.trim() : loc.name.trim();
    if (query.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nessun indirizzo o nome specificato per questa location.'),
            backgroundColor: AppTheme.drawYellow,
          ),
        );
      }
      return;
    }

    final uri = Uri.parse('https://www.google.com/maps/search/?api=1&query=${Uri.encodeComponent(query)}');
    try {
      final launched = await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (!launched && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Impossibile aprire Google Maps sul dispositivo.'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Errore apertura navigatore: $e'),
            backgroundColor: AppTheme.lossRed,
          ),
        );
      }
    }
  }

  Future<void> _openLocationDialog([LocationModel? existing]) async {
    final nameController = TextEditingController(text: existing?.name ?? '');
    final addressController = TextEditingController(text: existing?.address ?? '');
    final notesController = TextEditingController(text: existing?.notes ?? '');
    String selectedType = existing?.type ?? 'Fumetteria';
    if (!locationTypes.contains(selectedType)) {
      selectedType = locationTypes.first;
    }

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      useSafeArea: true,
      backgroundColor: AppTheme.darkSurface,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
        side: BorderSide(color: AppTheme.darkBorder, width: 1.2),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 16,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + MediaQuery.of(ctx).padding.bottom + 20,
              ),
              child: Form(
                key: formKey,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 44,
                          height: 5,
                          margin: const EdgeInsets.only(bottom: 16),
                          decoration: BoxDecoration(
                            color: AppTheme.darkBorder,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      Row(
                        children: [
                          const Icon(Icons.storefront_rounded, color: AppTheme.ultraBallGold, size: 22),
                          const SizedBox(width: 8),
                          Text(
                            existing != null ? 'Modifica Location' : 'Nuova Location',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Nome Location
                      TextFormField(
                        controller: nameController,
                        decoration: const InputDecoration(
                          labelText: 'Nome Location / Negozio *',
                          hintText: 'Es. Games Academy Bergamo',
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Inserisci il nome della location';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 14),

                      // Tipo Location (Dropdown)
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: const InputDecoration(
                          labelText: 'Tipo di Luogo',
                        ),
                        dropdownColor: AppTheme.darkSurface,
                        items: locationTypes.map((type) {
                          return DropdownMenuItem(
                            value: type,
                            child: Text(type),
                          );
                        }).toList(),
                        onChanged: (newVal) {
                          if (newVal != null) {
                            setModalState(() => selectedType = newVal);
                          }
                        },
                      ),
                      const SizedBox(height: 14),

                      // Indirizzo
                      TextFormField(
                        controller: addressController,
                        decoration: const InputDecoration(
                          labelText: 'Indirizzo (opzionale)',
                          hintText: 'Es. Via Angelo Maj 10, Bergamo',
                          prefixIcon: Icon(Icons.location_on_outlined, size: 20),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Note
                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        minLines: 2,
                        decoration: const InputDecoration(
                          labelText: 'Note (opzionale)',
                          hintText: 'Es. Parcheggio sul retro, orario tornei 15:30',
                          alignLabelWithHint: true,
                        ),
                      ),
                      const SizedBox(height: 18),

                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.ultraBallGold,
                          foregroundColor: const Color(0xFF0F172A),
                          padding: const EdgeInsets.symmetric(vertical: 14),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!.validate()) return;

                          final name = nameController.text.trim();
                          final address = addressController.text.trim();
                          final notes = notesController.text.trim();

                          final loc = LocationModel(
                            id: existing?.id ?? DateTime.now().millisecondsSinceEpoch.toString(),
                            name: name,
                            type: selectedType,
                            address: address,
                            notes: notes,
                            createdAt: existing?.createdAt,
                          );

                          await StorageService.instance.saveLocation(loc);
                          if (ctx.mounted) Navigator.pop(ctx);
                          _loadLocations();
                        },
                        child: Text(
                          existing != null ? 'Salva Modifiche' : 'Aggiungi Location',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Location'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_circle_outline_rounded, color: AppTheme.ultraBallGold, size: 28),
            tooltip: 'Aggiungi Location',
            onPressed: () => _openLocationDialog(),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        bottom: true,
        child: TcgPlaymatBackground(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _locations.isEmpty
                  ? _buildEmptyState()
                  : ListView.builder(
                      padding: EdgeInsets.fromLTRB(
                        16,
                        12,
                        16,
                        MediaQuery.of(context).padding.bottom + 24,
                      ),
                      itemCount: _locations.length,
                      itemBuilder: (context, index) {
                        final loc = _locations[index];
                        return _buildLocationCard(loc);
                      },
                    ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.ultraBallGold.withValues(alpha: 0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.storefront_rounded,
                size: 56,
                color: AppTheme.ultraBallGold,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Nessuna Location Salvata',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Aggiungi le fumetterie e i negozi in cui giochi abitualmente per ritrovarli subito compilando i report torneo!',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.ultraBallGold,
                foregroundColor: const Color(0xFF0F172A),
              ),
              onPressed: () => _openLocationDialog(),
              icon: const Icon(Icons.add),
              label: const Text('Aggiungi Prima Location', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard(LocationModel loc) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.pokedexRed.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppTheme.pokedexRed.withValues(alpha: 0.3)),
                  ),
                  child: const Icon(Icons.storefront_rounded, color: AppTheme.pokedexRed, size: 20),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        loc.name,
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.darkBorder,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          loc.type,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppTheme.ultraBallGold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.navigation_rounded, size: 20, color: AppTheme.winGreenLight),
                  tooltip: 'Naviga con Google Maps',
                  onPressed: () => _openMaps(loc),
                ),
                IconButton(
                  icon: const Icon(Icons.edit, size: 18),
                  tooltip: 'Modifica',
                  onPressed: () => _openLocationDialog(loc),
                ),
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18, color: AppTheme.lossRedLight),
                  tooltip: 'Elimina',
                  onPressed: () => _deleteLocation(loc),
                ),
              ],
            ),
            if (loc.address.isNotEmpty) ...[
              const SizedBox(height: 10),
              InkWell(
                onTap: () => _openMaps(loc),
                borderRadius: BorderRadius.circular(6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.near_me_rounded, size: 16, color: AppTheme.winGreenLight),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          loc.address,
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppTheme.textPrimary,
                            decoration: TextDecoration.underline,
                            decorationColor: AppTheme.winGreenLight,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      const Icon(Icons.open_in_new, size: 14, color: AppTheme.textMuted),
                    ],
                  ),
                ),
              ),
            ],
            if (loc.notes.isNotEmpty) ...[
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(Icons.notes_rounded, size: 16, color: AppTheme.textMuted),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      loc.notes,
                      style: const TextStyle(fontSize: 12, color: AppTheme.textMuted, fontStyle: FontStyle.italic),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
