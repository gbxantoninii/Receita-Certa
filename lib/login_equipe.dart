part of 'main.dart';

// ============================================================
// LOGIN (tela inicial antiga) + EQUIPE na parte de baixo
// ============================================================
class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final width = constraints.maxWidth;
            final contentWidth = width > 430 ? 410.0 : width;

            return Center(
              child: SizedBox(
                width: contentWidth,
                height: constraints.maxHeight,
                child: Stack(
                  clipBehavior: Clip.hardEdge,
                  children: [
                    Positioned(
                      top: -38,
                      left: -38,
                      child: _decorativeCircle(105),
                    ),
                    Positioned(
                      right: -50,
                      bottom: -42,
                      child: _decorativeCircle(130),
                    ),
                    SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(18, 18, 18, 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 2),
                              Row(
                                children: [
                                  Image.asset(
                                    'assets/capsula.png',
                                    width: 53,
                                    height: 43,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, _, _) => const Icon(
                                      Icons.medication,
                                      size: 40,
                                      color: vermelhoDestaque,
                                    ),
                                  ),
                                  const SizedBox(width: 5),
                                  RichText(
                                    text: const TextSpan(
                                      style: TextStyle(
                                        fontSize: 22,
                                        fontWeight: FontWeight.w700,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: 'Receita',
                                          style:
                                              TextStyle(color: vermelhoDestaque),
                                        ),
                                        TextSpan(
                                          text: ' Certa',
                                          style: TextStyle(color: Colors.white70),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 18),
                              const Text(
                                'Olá, Farmacêutico!\nVamos começar?',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  height: 1.18,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const SizedBox(height: 18),
                              ClipRRect(
                                child: AspectRatio(
                                  aspectRatio: 1.58,
                                  child: Image.asset(
                                    'assets/equipe.jpg',
                                    fit: BoxFit.cover,
                                    errorBuilder: (_, _, _) => Container(
                                      color: fundoCard,
                                      child: const Icon(
                                        Icons.groups,
                                        size: 60,
                                        color: Colors.white38,
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 31),
                              Center(
                                child: Text(
                                  'INICIAR COM',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: .72),
                                    fontSize: 11,
                                    letterSpacing: 1,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Expanded(
                                    child: _loginButton(
                                      icon: Icons.apple,
                                      text: 'Apple',
                                      onTap: () => _goHome(context),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: _loginButton(
                                      icon: Icons.g_mobiledata,
                                      text: 'Google',
                                      onTap: () => _goHome(context),
                                      google: true,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Center(
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 6,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: .09),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(
                                        Icons.verified_user_outlined,
                                        size: 14,
                                        color: Colors.white.withValues(alpha: .55),
                                      ),
                                      const SizedBox(width: 6),
                                      Text(
                                        'Atendimento mais seguro e rápido.',
                                        style: TextStyle(
                                          color: Colors.white.withValues(alpha: .65),
                                          fontSize: 11,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),
                              _EquipeResumo(
                                onTap: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const EquipePage()),
                                ),
                              ),
                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  static Widget _decorativeCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(color: vinho, shape: BoxShape.circle),
    );
  }

  static Widget _loginButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    bool google = false,
  }) {
    return SizedBox(
      height: 44,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white.withValues(alpha: .31),
          foregroundColor: Colors.white,
          elevation: 0,
          padding: EdgeInsets.zero,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (google)
              const Text(
                'G',
                style: TextStyle(
                  color: Color(0xFF4285F4),
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              )
            else
              Icon(icon, size: 20),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  static void _goHome(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
          settings: const RouteSettings(name: 'home'),
          builder: (_) => const HomePage()),
    );
  }
}

/// Resumo da equipe (parte de baixo da tela inicial)
class _EquipeResumo extends StatelessWidget {
  final VoidCallback onTap;
  const _EquipeResumo({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: .05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white.withValues(alpha: .1)),
        ),
        child: Column(
          children: [
            Text(
              'EQUIPE',
              style: TextStyle(
                color: Colors.white.withValues(alpha: .72),
                fontSize: 11,
                letterSpacing: 1,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 12,
              children: [
                for (final m in equipe)
                  SizedBox(
                    width: 108,
                    child: Column(
                      children: [
                        _AvatarCircle(path: m.avatar, size: 84),
                        const SizedBox(height: 6),
                        Text(
                          m.nome,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w700),
                        ),
                        Text(
                          m.funcao,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                              color: Colors.white54, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              'Toque para conhecer quem faz parte',
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .45), fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }
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
        title: const Text('Equipe',
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

