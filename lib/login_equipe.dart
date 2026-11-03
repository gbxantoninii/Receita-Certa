part of 'main.dart';

// ============================================================
// EQUIPE (acessada pelo menu lateral em "Nossa equipe")
// ============================================================

/// Círculo decorativo (antes ficava dentro da LoginPage; outras telas usam)
Widget _decorativeCircle(double size) {
  return Container(
    width: size,
    height: size,
    decoration: const BoxDecoration(color: vinho, shape: BoxShape.circle),
  );
}

class _AvatarCircle extends StatelessWidget {
  final String path;
  final double size;
  const _AvatarCircle({required this.path, required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: Colors.white24, width: 1.5),
      ),
      child: ClipOval(
        child: Image.asset(
          path,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: Colors.white10,
            child: Icon(Icons.person, size: size * .55, color: Colors.white54),
          ),
        ),
      ),
    );
  }
}

// ------------------------------------------------------------
// Página completa da Equipe
// ------------------------------------------------------------
class EquipePage extends StatelessWidget {
  const EquipePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        title: const Text('Nossa equipe',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 410),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            children: [
              const Text(
                'Quem faz o Receita Certa',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 6),
              Text(
                'Projeto da Future Fest em parceria com a Eurofarma. Escaneou, entendeu, cuidou.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: .6),
                    fontSize: 13.5,
                    height: 1.35),
              ),
              const SizedBox(height: 18),
              for (final m in equipe) ...[
                MembroCard(membro: m),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class MembroCard extends StatelessWidget {
  final Membro membro;
  const MembroCard({super.key, required this.membro});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: fundoCard,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              _AvatarCircle(path: membro.avatar, size: 104),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      membro.nome,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.w800),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      membro.usuario,
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 14),
                    ),
                    const SizedBox(height: 10),
                    _Selo(
                      texto: membro.funcao,
                      cor: vermelhoDestaque,
                      icone: Icons.badge_outlined,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            membro.descricao,
            style: const TextStyle(
                color: Colors.white70, fontSize: 14.5, height: 1.45),
          ),
          const SizedBox(height: 16),
          const Text(
            'Contribuições',
            style: TextStyle(
                color: Colors.white,
                fontSize: 13,
                fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final c in membro.contribuicoes)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .08),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    c,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}