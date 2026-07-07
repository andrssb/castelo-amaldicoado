import 'package:flutter/material.dart';

/// Um ponto da jornada mostrado no mapa.
class _MapNode {
  const _MapNode(this.title, this.tag, this.icon, this.color, this.description);
  final String title;
  final String tag;
  final IconData icon;
  final Color color;
  final String description;
}

const List<_MapNode> _nodes = [
  _MapNode(
    'Pátio Amaldiçoado',
    'Estágio 1',
    Icons.castle,
    Color(0xFF4FA3FF),
    'Onde tudo começa. Resolva o enigma dos arcanos: acenda os três pilares '
        'na ordem certa usando o fogo da sua espada.',
  ),
  _MapNode(
    'Guardião do Pátio',
    'Chefão',
    Icons.shield,
    Color(0xFF8A9098),
    'Um esqueleto viking colossal guarda a passagem. Ele fica protegido por um '
        'selo mágico até o enigma ser resolvido — então, ataque-o com fogo.',
  ),
  _MapNode(
    'Passagem Secreta',
    'Estágio 2',
    Icons.door_front_door,
    Color(0xFF3AE1FF),
    'Atravesse o portal para um corredor assombrado por fantasmas rumo ao trono.',
  ),
  _MapNode(
    'Rei Fantasma',
    'Chefão Final',
    Icons.whatshot,
    Color(0xFFB146E6),
    'O soberano das maldições, coroado e implacável. Derrote-o para libertar o '
        'castelo e completar o desafio do dia.',
  ),
];

/// Mapa interativo da jornada: toque num ponto para ver os detalhes.
class MapScreen extends StatefulWidget {
  const MapScreen({super.key, required this.canPlay, required this.onPlay});

  /// Se o desafio já carregou (habilita o botão Jogar).
  final bool canPlay;
  final VoidCallback onPlay;

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  int _selected = 0;

  @override
  Widget build(BuildContext context) {
    final node = _nodes[_selected];
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mapa da Jornada'),
        backgroundColor: Colors.transparent,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 12),
                itemCount: _nodes.length,
                itemBuilder: (context, i) => _nodeTile(i),
              ),
            ),
            _detailPanel(node),
          ],
        ),
      ),
    );
  }

  Widget _nodeTile(int i) {
    final node = _nodes[i];
    final selected = i == _selected;
    final isLast = i == _nodes.length - 1;
    return InkWell(
      onTap: () => setState(() => _selected = i),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: selected
                        ? node.color
                        : node.color.withValues(alpha: 0.25),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: selected ? Colors.white : Colors.white24,
                      width: selected ? 3 : 1,
                    ),
                  ),
                  child: Icon(node.icon, color: Colors.white, size: 26),
                ),
                if (!isLast)
                  Container(width: 3, height: 28, color: const Color(0xFF3C325C)),
              ],
            ),
            const SizedBox(width: 16),
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(node.tag.toUpperCase(),
                      style: TextStyle(
                          color: node.color,
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  Text(node.title,
                      style: TextStyle(
                          color: selected ? Colors.white : Colors.white70,
                          fontSize: 17,
                          fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _detailPanel(_MapNode node) => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: node.color.withValues(alpha: 0.5)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(node.title,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 6),
            Text(node.description,
                style: const TextStyle(color: Colors.white70, fontSize: 14)),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: widget.canPlay
                    ? () {
                        Navigator.of(context).pop();
                        widget.onPlay();
                      }
                    : null,
                child: const Text('Jogar o desafio de hoje'),
              ),
            ),
          ],
        ),
      );
}
