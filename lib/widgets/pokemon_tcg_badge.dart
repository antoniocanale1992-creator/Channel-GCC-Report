import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Badge vettoriale ispirato al GCC Pokémon (Carta + Sfera bicolore)
/// 100% originale, pulito e privo di copyright
class PokemonTcgBadge extends StatelessWidget {
  final double size;
  final bool showCardBorder;

  const PokemonTcgBadge({
    super.key,
    this.size = 46.0,
    this.showCardBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    final width = size * 0.82;
    final height = size;

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(size * 0.16),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.ultraBallGold,
            AppTheme.pokedexRed,
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppTheme.ultraBallGold.withValues(alpha: 0.25),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: EdgeInsets.all(showCardBorder ? 2.0 : 0.0),
      child: Container(
        decoration: BoxDecoration(
          color: AppTheme.darkSurface,
          borderRadius: BorderRadius.circular(size * 0.14),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Linee sottili stile olografico sul fondo
            CustomPaint(
              size: Size(width, height),
              painter: _HoloLinesPainter(),
            ),
            // Sfera stilizzata centrale
            _buildCenterSphere(size * 0.52),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterSphere(double sphereSize) {
    return Container(
      width: sphereSize,
      height: sphereSize,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.darkBorder, width: 1.8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 4,
          ),
        ],
      ),
      child: ClipOval(
        child: Column(
          children: [
            // Metà superiore: Rosso Pokédex
            Expanded(
              child: Container(
                color: AppTheme.pokedexRed,
              ),
            ),
            // Banda centrale con bottone
            Container(
              height: sphereSize * 0.18,
              color: AppTheme.inputFill,
              alignment: Alignment.center,
              child: Container(
                width: sphereSize * 0.28,
                height: sphereSize * 0.28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  border: Border.all(
                    color: AppTheme.inputFill,
                    width: 1.2,
                  ),
                ),
              ),
            ),
            // Metà inferiore: Bianco argentato
            Expanded(
              child: Container(
                color: const Color(0xFFE2E8F0),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HoloLinesPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1.0;

    canvas.drawLine(
      Offset(0, size.height * 0.25),
      Offset(size.width, size.height * 0.15),
      paint,
    );
    canvas.drawLine(
      Offset(0, size.height * 0.85),
      Offset(size.width, size.height * 0.75),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
