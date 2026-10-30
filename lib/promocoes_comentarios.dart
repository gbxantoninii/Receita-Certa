part of 'main.dart';

enum BrandType { raia, pagueMenos, saoPaulo }

class PromoCard extends StatefulWidget {
  final Promo promo;
  const PromoCard({super.key, required this.promo});

  @override
  State<PromoCard> createState() => _PromoCardState();
}

class _PromoCardState extends State<PromoCard> {
  Promo get p => widget.promo;

  Future<void> _abrirDetalhes() async {
    await Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => DetalhesPage(promo: p)),
    );
    if (mounted) setState(() {}); // atualiza curtidas e nº de comentários
  }

  Future<void> _abrirComentarios() async {
    await abrirComentarios(context, p);
    if (mounted) setState(() {});
  }

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
              _BrandBox(type: p.brandType),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.brand,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: .6),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      p.produto,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      p.descricao,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Salvar publicação
              InkWell(
                onTap: () => setState(() => salvosStore.alternar(p)),
                child: Icon(
                  p.salvo ? Icons.bookmark : Icons.bookmark_border,
                  size: 22,
                  color: p.salvo ? const Color(0xFFF2A93B) : Colors.white70,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Text(
                p.descontoTexto,
                style: const TextStyle(
                  color: vermelhoDestaque,
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const Spacer(),
              _Reaction(
                icon: Icons.thumb_up_alt_outlined,
                iconAtivo: Icons.thumb_up_alt,
                ativo: p.curtiu,
                corAtiva: verdeOk,
                onTap: () => setState(() {
                  p.curtiu = !p.curtiu;
                  if (p.curtiu) p.naoCurtiu = false;
                }),
              ),
              const SizedBox(width: 8),
              _Reaction(
                icon: Icons.thumb_down_alt_outlined,
                iconAtivo: Icons.thumb_down_alt,
                ativo: p.naoCurtiu,
                corAtiva: vermelhoDestaque,
                onTap: () => setState(() {
                  p.naoCurtiu = !p.naoCurtiu;
                  if (p.naoCurtiu) p.curtiu = false;
                }),
              ),
              const SizedBox(width: 10),
              _CommentPill(
                count: p.comentarios.length,
                onTap: _abrirComentarios,
              ),
              const SizedBox(width: 10),
              InkWell(
                onTap: _abrirDetalhes,
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 30,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white38),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Center(
                    child: Text(
                      'Ver mais',
                      style: TextStyle(fontSize: 12, color: Colors.white70),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BrandBox extends StatelessWidget {
  final BrandType type;
  final double size;

  const _BrandBox({required this.type, this.size = 72});

  String get _asset {
    switch (type) {
      case BrandType.raia:
        return 'assets/raia.png';
      case BrandType.pagueMenos:
        return 'assets/pague_menos.png';
      case BrandType.saoPaulo:
        return 'assets/sao_paulo.png';
    }
  }

  String get _fallbackText {
    switch (type) {
      case BrandType.raia:
        return 'Raia';
      case BrandType.pagueMenos:
        return 'PM';
      case BrandType.saoPaulo:
        return 'SP';
    }
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SizedBox(
        width: size,
        height: size,
        child: Image.asset(
          _asset,
          fit: BoxFit.cover,
          errorBuilder: (_, _, _) => Container(
            color: Colors.white12,
            child: Center(
              child: Text(
                _fallbackText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botão de curtir / não curtir: fica colorido quando ativo
class _Reaction extends StatelessWidget {
  final IconData icon;
  final IconData iconAtivo;
  final bool ativo;
  final Color corAtiva;
  final VoidCallback onTap;

  const _Reaction({
    required this.icon,
    required this.iconAtivo,
    required this.ativo,
    required this.corAtiva,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        width: 34,
        height: 30,
        decoration: BoxDecoration(
          color: ativo ? corAtiva.withValues(alpha: .18) : Colors.transparent,
          border: Border.all(color: ativo ? corAtiva : Colors.white24),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(
          ativo ? iconAtivo : icon,
          size: 16,
          color: ativo ? corAtiva : Colors.white70,
        ),
      ),
    );
  }
}

class _CommentPill extends StatelessWidget {
  final int count;
  final VoidCallback onTap;

  const _CommentPill({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 30,
        padding: const EdgeInsets.symmetric(horizontal: 10),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          children: [
            const Icon(Icons.chat_bubble_outline,
                size: 14, color: Colors.white70),
            const SizedBox(width: 4),
            Text('$count',
                style: const TextStyle(fontSize: 12, color: Colors.white70)),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// COMENTÁRIOS DE CADA REMÉDIO (janela que sobe de baixo)
// ============================================================
Future<void> abrirComentarios(BuildContext context, Promo promo) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: fundoCard,
    constraints: const BoxConstraints(maxWidth: 410),
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (_) => _ComentariosSheet(promo: promo),
  );
}

class _ComentariosSheet extends StatefulWidget {
  final Promo promo;
  const _ComentariosSheet({required this.promo});

  @override
  State<_ComentariosSheet> createState() => _ComentariosSheetState();
}

class _ComentariosSheetState extends State<_ComentariosSheet> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enviar() {
    final texto = _controller.text.trim();
    if (texto.isEmpty) return;
    setState(() {
      widget.promo.comentarios.insert(0, Comentario(usuarioLogado, texto));
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.promo;
    final teclado = MediaQuery.of(context).viewInsets.bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: teclado),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * .72,
        child: Column(
          children: [
            const SizedBox(height: 10),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      'Comentários · ${p.produto}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Text('${p.comentarios.length}',
                      style: const TextStyle(color: Colors.white54)),
                ],
              ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Expanded(
              child: p.comentarios.isEmpty
                  ? const Center(
                      child: Text(
                        'Ainda não há comentários.\nSeja o primeiro!',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54),
                      ),
                    )
                  : ListView.separated(
                      padding: const EdgeInsets.all(16),
                      itemCount: p.comentarios.length,
                      separatorBuilder: (_, _) => const SizedBox(height: 14),
                      itemBuilder: (_, i) {
                        final c = p.comentarios[i];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: const BoxDecoration(
                                  color: Colors.white10, shape: BoxShape.circle),
                              child: const Icon(Icons.person,
                                  size: 20, color: Colors.white54),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(c.usuario,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13)),
                                  const SizedBox(height: 2),
                                  Text(c.texto,
                                      style: TextStyle(
                                          color: Colors.white.withValues(alpha: .75),
                                          fontSize: 13.5,
                                          height: 1.3)),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            const Divider(height: 1, color: Colors.white12),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 10, 8, 14),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      onSubmitted: (_) => _enviar(),
                      textInputAction: TextInputAction.send,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Escreva um comentário...',
                        hintStyle: const TextStyle(color: Colors.white38),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha: .08),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14, vertical: 10),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _enviar,
                    icon: const Icon(Icons.send, color: vermelhoDestaque),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// TELA "VER MAIS" (detalhes do remédio)
// ============================================================
class DetalhesPage extends StatefulWidget {
  final Promo promo;
  const DetalhesPage({super.key, required this.promo});

  @override
  State<DetalhesPage> createState() => _DetalhesPageState();
}

class _DetalhesPageState extends State<DetalhesPage> {
  Promo get p => widget.promo;

  void _copiarEndereco() {
    Clipboard.setData(ClipboardData(text: p.endereco));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Endereço copiado!'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Lista de preços ordenada do menor para o maior
    final precos = <PrecoFarmacia>[
      PrecoFarmacia(p.brand, p.precoPromo),
      ...p.outrasFarmacias,
    ]..sort((a, b) => a.valor.compareTo(b.valor));

    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        title: const Text('Detalhes',
            style: TextStyle(fontWeight: FontWeight.w700)),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 410),
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
            children: [
              // Cabeçalho
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandBox(type: p.brandType, size: 84),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.brand,
                            style: TextStyle(
                                color: Colors.white.withValues(alpha: .6),
                                fontSize: 12)),
                        const SizedBox(height: 4),
                        Text(p.produto,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 8),
                        _Selo(
                          texto: p.requerReceita
                              ? 'Requer receita médica'
                              : 'Venda livre',
                          cor: p.requerReceita ? vermelhoDestaque : verdeOk,
                          icone: p.requerReceita
                              ? Icons.receipt_long
                              : Icons.check_circle_outline,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Preço
              _Secao(
                titulo: 'Preço',
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(reais(p.precoPromo),
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 26,
                            fontWeight: FontWeight.w800)),
                    const SizedBox(width: 10),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(reais(p.precoOriginal),
                          style: const TextStyle(
                              color: Colors.white38,
                              fontSize: 14,
                              decoration: TextDecoration.lineThrough)),
                    ),
                    const Spacer(),
                    Text(p.descontoTexto,
                        style: const TextStyle(
                            color: vermelhoDestaque,
                            fontSize: 20,
                            fontWeight: FontWeight.w800)),
                  ],
                ),
              ),

              _Secao(
                titulo: 'Sobre o medicamento',
                child: Text(p.descricaoDetalhada, style: _corpo),
              ),
              _Secao(
                titulo: 'Composição',
                child: Text(p.composicao, style: _corpo),
              ),
              _Secao(
                titulo: 'Como usar',
                child: Text(p.comoUsar, style: _corpo),
              ),
              _Secao(
                titulo: 'Avisos importantes',
                child: Text(p.avisos, style: _corpo),
              ),

              // Farmácia mais próxima
              _Secao(
                titulo: 'Farmácia mais próxima',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.brand,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 8),
                    _LinhaInfo(Icons.place_outlined, p.endereco),
                    _LinhaInfo(Icons.directions_walk, 'A ${p.distancia} de você'),
                    _LinhaInfo(Icons.access_time, p.horario),
                    _LinhaInfo(Icons.phone_outlined, p.telefone),
                    const SizedBox(height: 10),
                    OutlinedButton.icon(
                      onPressed: _copiarEndereco,
                      icon: const Icon(Icons.copy, size: 16),
                      label: const Text('Copiar endereço'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.white,
                        side: const BorderSide(color: Colors.white38),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Endereço de exemplo. Na versão final, será calculado pela sua localização.',
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: .4), fontSize: 11),
                    ),
                  ],
                ),
              ),

              // Comparação de preços
              _Secao(
                titulo: 'Comparar preços',
                child: Column(
                  children: [
                    for (var i = 0; i < precos.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 5),
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(precos[i].nome,
                                  style: const TextStyle(
                                      color: Colors.white70, fontSize: 14)),
                            ),
                            if (i == 0)
                              const Padding(
                                padding: EdgeInsets.only(right: 8),
                                child: _Selo(
                                    texto: 'Menor preço',
                                    cor: verdeOk,
                                    pequeno: true),
                              ),
                            Text(reais(precos[i].valor),
                                style: TextStyle(
                                    color: i == 0 ? verdeOk : Colors.white,
                                    fontWeight: FontWeight.w700)),
                          ],
                        ),
                      ),
                    const SizedBox(height: 4),
                    Text('Valores de exemplo.',
                        style: TextStyle(
                            color: Colors.white.withValues(alpha: .4), fontSize: 11)),
                  ],
                ),
              ),

              // Ações: curtir, não curtir, comentários
              Row(
                children: [
                  _Reaction(
                    icon: Icons.thumb_up_alt_outlined,
                    iconAtivo: Icons.thumb_up_alt,
                    ativo: p.curtiu,
                    corAtiva: verdeOk,
                    onTap: () => setState(() {
                      p.curtiu = !p.curtiu;
                      if (p.curtiu) p.naoCurtiu = false;
                    }),
                  ),
                  const SizedBox(width: 8),
                  _Reaction(
                    icon: Icons.thumb_down_alt_outlined,
                    iconAtivo: Icons.thumb_down_alt,
                    ativo: p.naoCurtiu,
                    corAtiva: vermelhoDestaque,
                    onTap: () => setState(() {
                      p.naoCurtiu = !p.naoCurtiu;
                      if (p.naoCurtiu) p.curtiu = false;
                    }),
                  ),
                  const SizedBox(width: 10),
                  _CommentPill(
                    count: p.comentarios.length,
                    onTap: () async {
                      await abrirComentarios(context, p);
                      if (mounted) setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Text(
                'Informação educativa. Não substitui a orientação do médico ou do farmacêutico.',
                style: TextStyle(
                    color: Colors.white.withValues(alpha: .4), fontSize: 11),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static const TextStyle _corpo =
      TextStyle(color: Colors.white70, fontSize: 14, height: 1.4);
}

class _Secao extends StatelessWidget {
  final String titulo;
  final Widget child;
  const _Secao({required this.titulo, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fundoCard,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: .13)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titulo,
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w700)),
          const SizedBox(height: 8),
          child,
        ],
      ),
    );
  }
}

class _LinhaInfo extends StatelessWidget {
  final IconData icone;
  final String texto;
  const _LinhaInfo(this.icone, this.texto);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icone, size: 16, color: Colors.white54),
          const SizedBox(width: 8),
          Expanded(
            child: Text(texto,
                style: const TextStyle(color: Colors.white70, fontSize: 13.5)),
          ),
        ],
      ),
    );
  }
}

class _Selo extends StatelessWidget {
  final String texto;
  final Color cor;
  final IconData? icone;
  final bool pequeno;
  const _Selo(
      {required this.texto,
      required this.cor,
      this.icone,
      this.pequeno = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8, vertical: pequeno ? 2 : 4),
      decoration: BoxDecoration(
        color: cor.withValues(alpha: .16),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: cor.withValues(alpha: .7)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icone != null) ...[
            Icon(icone, size: 13, color: cor),
            const SizedBox(width: 4),
          ],
          Text(texto,
              style: TextStyle(
                  color: cor,
                  fontSize: pequeno ? 10.5 : 12,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// ------------------------------------------------------------
// Utilitários
// ------------------------------------------------------------
String normalizar(String s) {
  const de = 'áàâãäéèêëíìîïóòôõöúùûüçñ';
  const para = 'aaaaaeeeeiiiiooooouuuucn';
  var r = s.toLowerCase();
  for (var i = 0; i < de.length; i++) {
    r = r.replaceAll(de[i], para[i]);
  }
  return r;
}

String _agora() {
  final n = TimeOfDay.now();
  return '${n.hour.toString().padLeft(2, '0')}:${n.minute.toString().padLeft(2, '0')}';
}

List<Promo> get _todasPromos => [...promosRecentes, ...promosDestaques];

