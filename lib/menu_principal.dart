part of 'main.dart';

// ============================================================
// HOME (abas: Destaques, Recentes, Comentários)
// ============================================================
enum HomeTab { destaques, recentes, comentarios }

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomeTab _tab = HomeTab.recentes;

  void _selectTab(HomeTab tab) {
    if (tab == _tab) return;
    setState(() => _tab = tab);
  }

  Widget _conteudo() {
    switch (_tab) {
      case HomeTab.destaques:
        return _PromoList(key: const ValueKey('destaques'), promos: promosDestaques);
      case HomeTab.recentes:
        return _PromoList(key: const ValueKey('recentes'), promos: promosRecentes);
      case HomeTab.comentarios:
        return const _ComentariosList(key: ValueKey('comentarios'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      drawer: const MenuLateral(),
      body: SafeArea(
        bottom: false,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final contentWidth =
                constraints.maxWidth > 430 ? 410.0 : constraints.maxWidth;

            return Center(
              child: SizedBox(
                width: contentWidth,
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    const _HomeHeader(),
                    const SizedBox(height: 18),
                    _TopTabs(selected: _tab, onSelect: _selectTab),
                    const SizedBox(height: 14),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 220),
                        child: _conteudo(),
                      ),
                    ),
                    const _BottomBar(),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _PromoList extends StatelessWidget {
  final List<Promo> promos;
  const _PromoList({super.key, required this.promos});

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const BouncingScrollPhysics(),
      itemCount: promos.length,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) => PromoCard(promo: promos[i]),
    );
  }
}

class _ComentariosList extends StatelessWidget {
  const _ComentariosList({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
      physics: const BouncingScrollPhysics(),
      children: const [
        CommentCard(
          avatar: 'assets/avatar_1.jpg',
          usuario: '@marina.souzaa',
          texto:
              'Muito bom!!! Indiquei para minha família toda, o melhor aplicativo de descontos e escaneamentos que eu já vi!',
        ),
        SizedBox(height: 14),
        CommentCard(
          avatar: 'assets/avatar_2.jpg',
          usuario: '@carlos.hmendes',
          texto:
              'Sensacional! 🚀 Indiquei para a família toda e todo mundo tá usando. É de longe o aplicativo mais prático de descontos e escaneamento que eu já vi. Vale muito a pena baixar!',
        ),
        SizedBox(height: 14),
        CommentCard(
          avatar: 'assets/avatar_3.jpg',
          usuario: '@anabeatriz_lima',
          texto:
              'Que aplicativo sensacional! 🙌 A facilidade de escanear e já conseguir descontos na hora é impressionante. Já fiz todo mundo aqui em casa instalar. É muito prático e ajuda a economizar de verdade. Nota 10!',
        ),
      ],
    );
  }
}

class CommentCard extends StatelessWidget {
  final String avatar;
  final String usuario;
  final String texto;
  final String tag;

  const CommentCard({
    super.key,
    required this.avatar,
    required this.usuario,
    required this.texto,
    this.tag = 'Comentários',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _AvatarCircle(path: avatar, size: 64),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 2),
                      child: Text(
                        usuario,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      texto,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .65),
                        fontSize: 13.5,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: .14),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                tag,
                style: const TextStyle(fontSize: 11, color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  final HomeTab selected;
  final ValueChanged<HomeTab> onSelect;

  const _TopTabs({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _TopTab('Destaques', selected == HomeTab.destaques,
              () => onSelect(HomeTab.destaques)),
          _TopTab('Recentes', selected == HomeTab.recentes,
              () => onSelect(HomeTab.recentes)),
          _TopTab('Comentários', selected == HomeTab.comentarios,
              () => onSelect(HomeTab.comentarios)),
        ],
      ),
    );
  }
}

class _TopTab extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _TopTab(this.text, this.selected, this.onTap);

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              text,
              style: TextStyle(
                color: selected ? Colors.white : Colors.white54,
                fontSize: 14,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
              ),
            ),
            const SizedBox(height: 6),
            Container(
              height: 2,
              width: 28,
              color: selected ? vermelhoDestaque : Colors.transparent,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// BARRA INFERIOR (Home, Receitas, + câmera, Farmácias, Lembretes)
// ============================================================
class _BottomBar extends StatelessWidget {
  /// 0 = Home, 1 = Receitas, 3 = Farmácias, 4 = Lembretes
  final int atual;
  const _BottomBar({this.atual = 0});

  bool _ehHome(Route<dynamic> r) => r.settings.name == 'home' || r.isFirst;

  void _abrirAba(NavigatorState nav, int i) {
    final Widget pagina = i == 1
        ? const MinhasReceitasPage()
        : i == 3
            ? const PedidosPage()
            : const LembretesPage();
    nav.popUntil(_ehHome); // volta para a Home e abre a aba por cima
    nav.push(MaterialPageRoute<void>(builder: (_) => pagina));
  }

  Future<void> _ir(BuildContext context, int i) async {
    if (i == atual) return;
    final nav = Navigator.of(context);
    if (i == 0) {
      nav.popUntil(_ehHome);
      return;
    }
    if (i == 2) {
      final ok = await nav.push<bool>(
          MaterialPageRoute(builder: (_) => const ScanPage()));
      if (ok == true) _abrirAba(nav, 1); // confirmou: vai para Minhas Receitas
      return;
    }
    _abrirAba(nav, i);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).padding.bottom;

    return Container(
      padding: EdgeInsets.only(bottom: bottomInset),
      decoration: const BoxDecoration(
        color: Color(0xFF252525),
        border: Border(top: BorderSide(color: Color(0xFF414141), width: .6)),
      ),
      child: SizedBox(
        height: 64,
        child: Row(
          children: [
            Expanded(
                child: _BottomItem(Icons.home_outlined, 'Home', atual == 0,
                    onTap: () => _ir(context, 0))),
            Expanded(
                child: _BottomItem(
                    Icons.receipt_long_outlined, 'Receitas', atual == 1,
                    onTap: () => _ir(context, 1))),
            Expanded(
              child: Center(
                child: GestureDetector(
                  onTap: () => _ir(context, 2),
                  child: Transform.translate(
                    offset: const Offset(0, -10),
                    child: Container(
                      width: 52,
                      height: 52,
                      decoration: const BoxDecoration(
                        color: vinho,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 2)),
                        ],
                      ),
                      child:
                          const Icon(Icons.add, size: 30, color: Colors.white),
                    ),
                  ),
                ),
              ),
            ),
            Expanded(
                child: _BottomItem(
                    Icons.shopping_basket_outlined, 'Pedidos', atual == 3,
                    onTap: () => _ir(context, 3))),
            Expanded(
                child: _BottomItem(Icons.access_time, 'Lembretes', atual == 4,
                    onTap: () => _ir(context, 4))),
          ],
        ),
      ),
    );
  }
}

class _BottomItem extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool selected;
  final VoidCallback? onTap;

  const _BottomItem(this.icon, this.text, this.selected, {this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = selected ? vermelhoDestaque : Colors.white60;
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 24, color: color),
          const SizedBox(height: 3),
          Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: color),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARD DE PROMOÇÃO (curtir / não curtir / comentários / ver mais / salvar)
// ============================================================
