part of 'main.dart';

// ############################################################
// PEDIDOS (botão da cestinha na barra inferior)
// lista -> detalhe com andamento -> novo pedido
// ############################################################

enum StatusPedido { aguardando, separando, pronto, retirado, cancelado }

extension StatusPedidoInfo on StatusPedido {
  String get texto {
    switch (this) {
      case StatusPedido.aguardando:
        return 'Aguardando';
      case StatusPedido.separando:
        return 'Separando';
      case StatusPedido.pronto:
        return 'Pronto p/ retirar';
      case StatusPedido.retirado:
        return 'Retirado';
      case StatusPedido.cancelado:
        return 'Cancelado';
    }
  }

  Color get cor {
    switch (this) {
      case StatusPedido.aguardando:
        return const Color(0xFFF2A93B);
      case StatusPedido.separando:
        return const Color(0xFF4A90E2);
      case StatusPedido.pronto:
        return verdeOk;
      case StatusPedido.retirado:
        return Colors.white70;
      case StatusPedido.cancelado:
        return vermelhoDestaque;
    }
  }

  IconData get icone {
    switch (this) {
      case StatusPedido.aguardando:
        return Icons.hourglass_empty;
      case StatusPedido.separando:
        return Icons.inventory_2_outlined;
      case StatusPedido.pronto:
        return Icons.check_circle_outline;
      case StatusPedido.retirado:
        return Icons.shopping_bag_outlined;
      case StatusPedido.cancelado:
        return Icons.cancel_outlined;
    }
  }
}

class Pedido {
  final String codigo;
  final Promo promo;
  final int qtd;
  final String farmacia;
  final double precoUnit;
  final DateTime data;
  StatusPedido status;

  Pedido({
    required this.codigo,
    required this.promo,
    required this.qtd,
    required this.farmacia,
    required this.precoUnit,
    required this.data,
    this.status = StatusPedido.aguardando,
  });

  double get total => precoUnit * qtd;
  bool get emAndamento =>
      status == StatusPedido.aguardando ||
      status == StatusPedido.separando ||
      status == StatusPedido.pronto;
}

class PedidosStore extends ChangeNotifier {
  int _seq = 10483;

  final List<Pedido> itens = [
    Pedido(
      codigo: 'RC-10482',
      promo: promosRecentes[0],
      qtd: 1,
      farmacia: 'Drogaria Raia',
      precoUnit: promosRecentes[0].precoPromo,
      data: DateTime.now().subtract(const Duration(hours: 2)),
      status: StatusPedido.separando,
    ),
    Pedido(
      codigo: 'RC-10391',
      promo: promosDestaques[0],
      qtd: 2,
      farmacia: 'Farmácias Pague Menos',
      precoUnit: promosDestaques[0].precoPromo,
      data: DateTime.now().subtract(const Duration(days: 3)),
      status: StatusPedido.retirado,
    ),
  ];

  String novoCodigo() => 'RC-${_seq++}';

  void adicionar(Pedido p) {
    itens.insert(0, p);
    notifyListeners();
  }

  /// Só para a demonstração: avança a etapa do pedido.
  void avancar(Pedido p) {
    if (p.status == StatusPedido.aguardando) {
      p.status = StatusPedido.separando;
    } else if (p.status == StatusPedido.separando) {
      p.status = StatusPedido.pronto;
    } else if (p.status == StatusPedido.pronto) {
      p.status = StatusPedido.retirado;
    }
    notifyListeners();
  }

  void cancelar(Pedido p) {
    p.status = StatusPedido.cancelado;
    notifyListeners();
  }
}

final PedidosStore pedidosStore = PedidosStore();

BrandType _marcaDaFarmacia(String nome) {
  final n = normalizar(nome);
  if (n.contains('raia')) return BrandType.raia;
  if (n.contains('pague')) return BrandType.pagueMenos;
  return BrandType.saoPaulo;
}

Promo? _promoDaFarmacia(String nome) {
  for (final p in todasAsPromos) {
    if (p.brand == nome) return p;
  }
  return null;
}

/// Preço do remédio em cada farmácia, do menor para o maior
List<PrecoFarmacia> _opcoesDePreco(Promo p) =>
    <PrecoFarmacia>[PrecoFarmacia(p.brand, p.precoPromo), ...p.outrasFarmacias]
      ..sort((a, b) => a.valor.compareTo(b.valor));

// ---------------- LISTA DE PEDIDOS ----------------
class PedidosPage extends StatefulWidget {
  const PedidosPage({super.key});

  @override
  State<PedidosPage> createState() => _PedidosPageState();
}

class _PedidosPageState extends State<PedidosPage> {
  static const _filtros = ['Todos', 'Em andamento', 'Concluídos', 'Cancelados'];
  String _filtro = 'Todos';

  bool _passa(Pedido p) {
    switch (_filtro) {
      case 'Em andamento':
        return p.emAndamento;
      case 'Concluídos':
        return p.status == StatusPedido.retirado;
      case 'Cancelados':
        return p.status == StatusPedido.cancelado;
      default:
        return true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return _TelaReceita(
      barra: 3,
      child: AnimatedBuilder(
        animation: pedidosStore,
        builder: (_, _) {
          final lista = pedidosStore.itens.where(_passa).toList();
          final andamento =
              pedidosStore.itens.where((p) => p.emAndamento).length;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              const Text('PEDIDOS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: .5)),
              const SizedBox(height: 6),
              Text(
                  andamento == 0
                      ? 'Nenhum pedido em andamento'
                      : '$andamento ${andamento == 1 ? 'pedido em andamento' : 'pedidos em andamento'}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54, fontSize: 12.5)),
              const SizedBox(height: 16),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final f in _filtros)
                    _FiltroChip(
                        texto: f,
                        ativo: _filtro == f,
                        onTap: () => setState(() => _filtro = f)),
                ],
              ),
              const SizedBox(height: 16),
              if (lista.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 36),
                  child: Column(children: const [
                    Icon(Icons.shopping_basket_outlined,
                        size: 60, color: Colors.white38),
                    SizedBox(height: 12),
                    Text('Nenhum pedido por aqui',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Toque em "Novo pedido" para reservar um remédio.',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ]),
                ),
              for (final p in lista)
                _PedidoCard(
                  pedido: p,
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                      builder: (_) => PedidoDetalhePage(pedido: p))),
                ),
              const SizedBox(height: 6),
              _BotaoPrimario(
                texto: 'Novo pedido',
                icone: Icons.add_shopping_cart,
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const NovoPedidoPage())),
              ),
              const SizedBox(height: 6),
              Center(
                child: TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => const FarmaciasPage())),
                  icon: const Icon(Icons.local_pharmacy_outlined,
                      size: 18, color: Colors.white70),
                  label: const Text('Ver farmácias',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ),
              const Text(
                  'Pedidos de exemplo. Na versão final, serão enviados para a farmácia escolhida.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          );
        },
      ),
    );
  }
}

class _PedidoCard extends StatelessWidget {
  final Pedido pedido;
  final VoidCallback onTap;
  const _PedidoCard({required this.pedido, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final p = pedido;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: fundoCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.white.withValues(alpha: .13)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _BrandBox(type: _marcaDaFarmacia(p.farmacia), size: 52),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.promo.produto,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700)),
                    const SizedBox(height: 2),
                    Text('${p.qtd}x · ${p.farmacia}',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                            color: Colors.white54, fontSize: 12)),
                    const SizedBox(height: 6),
                    Text('#${p.codigo} · ${_dataHora(p.data)}',
                        style: const TextStyle(
                            color: Colors.white38, fontSize: 11)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  _Selo(
                      texto: p.status.texto,
                      cor: p.status.cor,
                      pequeno: true),
                  const SizedBox(height: 10),
                  Text(reais(p.total),
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.w800)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- DETALHE DO PEDIDO ----------------
class PedidoDetalhePage extends StatelessWidget {
  final Pedido pedido;
  const PedidoDetalhePage({super.key, required this.pedido});

  static const _etapas = [
    'Pedido recebido',
    'Separando na farmácia',
    'Pronto para retirada',
    'Retirado',
  ];

  int get _indice {
    switch (pedido.status) {
      case StatusPedido.aguardando:
        return 0;
      case StatusPedido.separando:
        return 1;
      case StatusPedido.pronto:
        return 2;
      case StatusPedido.retirado:
        return 3;
      case StatusPedido.cancelado:
        return -1;
    }
  }

  Future<void> _cancelar(BuildContext context) async {
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        title: Text('Cancelar pedido?',
            style: TextStyle(color: c.texto, fontWeight: FontWeight.w800)),
        content: Text('O pedido ${pedido.codigo} será cancelado.',
            style: TextStyle(color: c.texto2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Voltar', style: TextStyle(color: c.texto2))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Cancelar pedido',
                  style: TextStyle(
                      color: vermelhoDestaque, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true) {
      pedidosStore.cancelar(pedido);
      if (context.mounted) _aviso(context, 'Pedido cancelado.');
    }
  }

  Widget _linhaEtapa(int i) {
    final p = pedido;
    final feito = i < _indice || p.status == StatusPedido.retirado;
    final atual = i == _indice && p.status != StatusPedido.retirado;
    final cor = feito
        ? verdeOk
        : atual
            ? vermelhoDestaque
            : Colors.white24;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: feito ? verdeOk : Colors.transparent,
              shape: BoxShape.circle,
              border: Border.all(color: cor, width: 2),
            ),
            child: feito
                ? const Icon(Icons.check, size: 14, color: Colors.white)
                : atual
                    ? Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                            color: vermelhoDestaque, shape: BoxShape.circle))
                    : null,
          ),
          if (i < _etapas.length - 1)
            Container(
                width: 2,
                height: 24,
                color: i < _indice ? verdeOk : Colors.white24),
        ]),
        const SizedBox(width: 12),
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(_etapas[i],
              style: TextStyle(
                  color: feito || atual ? Colors.white : Colors.white38,
                  fontSize: 14,
                  fontWeight: atual ? FontWeight.w800 : FontWeight.w400)),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return _TelaReceita(
      barra: -1,
      child: AnimatedBuilder(
        animation: pedidosStore,
        builder: (_, _) {
          final p = pedido;
          final loja = _promoDaFarmacia(p.farmacia);
          final cancelado = p.status == StatusPedido.cancelado;
          final podeCancelar = p.status == StatusPedido.aguardando ||
              p.status == StatusPedido.separando;
          final podeAvancar = p.emAndamento;

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
            children: [
              const Text('PEDIDO',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: .5)),
              const SizedBox(height: 16),
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _BrandBox(type: _marcaDaFarmacia(p.farmacia), size: 72),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(p.promo.produto,
                            style: const TextStyle(
                                color: Colors.white,
                                fontSize: 17,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text('#${p.codigo} · ${_dataHora(p.data)}',
                            style: const TextStyle(
                                color: Colors.white54, fontSize: 12)),
                        const SizedBox(height: 8),
                        _Selo(
                            texto: p.status.texto,
                            cor: p.status.cor,
                            icone: p.status.icone),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              if (!cancelado)
                _Secao(
                  titulo: 'Andamento',
                  child: Column(children: [
                    for (var i = 0; i < _etapas.length; i++) _linhaEtapa(i),
                  ]),
                ),
              _Secao(
                titulo: 'Resumo',
                child: Column(children: [
                  _linhaValor('Quantidade', '${p.qtd}'),
                  _linhaValor('Preço unitário', reais(p.precoUnit)),
                  const Divider(color: Colors.white12, height: 18),
                  _linhaValor('Total', reais(p.total), destaque: true),
                ]),
              ),
              _Secao(
                titulo: 'Retirada',
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(p.farmacia,
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 15)),
                    const SizedBox(height: 8),
                    if (loja != null) ...[
                      _LinhaInfo(Icons.place_outlined, loja.endereco),
                      _LinhaInfo(Icons.access_time, loja.horario),
                      _LinhaInfo(Icons.phone_outlined, loja.telefone),
                    ],
                    if (p.promo.requerReceita) ...[
                      const SizedBox(height: 10),
                      const _Selo(
                          texto: 'Leve a receita original',
                          cor: vermelhoDestaque,
                          icone: Icons.receipt_long),
                    ],
                  ],
                ),
              ),
              Row(children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: p.codigo));
                      _aviso(context, 'Código copiado!');
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar código'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                ),
                if (podeCancelar) ...[
                  const SizedBox(width: 10),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _cancelar(context),
                      icon: const Icon(Icons.close, size: 16),
                      label: const Text('Cancelar'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: vermelhoDestaque,
                        side: const BorderSide(color: vermelhoDestaque),
                      ),
                    ),
                  ),
                ],
              ]),
              if (podeAvancar)
                Center(
                  child: TextButton(
                    onPressed: () => pedidosStore.avancar(p),
                    child: const Text('Avançar etapa (demonstração)',
                        style:
                            TextStyle(color: Colors.white54, fontSize: 12.5)),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _linhaValor(String rotulo, String valor, {bool destaque = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(children: [
        Expanded(
          child: Text(rotulo,
              style: TextStyle(
                  color: destaque ? Colors.white : Colors.white70,
                  fontSize: destaque ? 15 : 13.5,
                  fontWeight: destaque ? FontWeight.w700 : FontWeight.w400)),
        ),
        Text(valor,
            style: TextStyle(
                color: Colors.white,
                fontSize: destaque ? 18 : 13.5,
                fontWeight: destaque ? FontWeight.w800 : FontWeight.w600)),
      ]),
    );
  }
}

// ---------------- NOVO PEDIDO ----------------
class NovoPedidoPage extends StatefulWidget {
  const NovoPedidoPage({super.key});

  @override
  State<NovoPedidoPage> createState() => _NovoPedidoPageState();
}

class _NovoPedidoPageState extends State<NovoPedidoPage> {
  Promo? _promo;
  int _qtd = 1;
  String? _farm;
  bool _temReceita = false;

  double get _precoUnit {
    final p = _promo;
    if (p == null || _farm == null) return 0;
    return _opcoesDePreco(p).firstWhere((o) => o.nome == _farm).valor;
  }

  bool get _pode =>
      _promo != null &&
      _farm != null &&
      (!_promo!.requerReceita || _temReceita);

  void _escolher(Promo p) {
    setState(() {
      _promo = p;
      _qtd = 1;
      _farm = _opcoesDePreco(p).first.nome;
      _temReceita = false;
    });
  }

  void _confirmar() {
    final p = _promo!;
    final codigo = pedidosStore.novoCodigo();
    final msg = ScaffoldMessenger.of(context);
    pedidosStore.adicionar(Pedido(
      codigo: codigo,
      promo: p,
      qtd: _qtd,
      farmacia: _farm!,
      precoUnit: _precoUnit,
      data: DateTime.now(),
    ));
    Navigator.pop(context);
    msg
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
          content: Text('Pedido $codigo enviado!'),
          duration: const Duration(seconds: 2)));
  }

  Widget _titulo(String t) => Padding(
        padding: const EdgeInsets.only(top: 6, bottom: 10),
        child: Text(t,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700)),
      );

  Widget _opcaoRemedio(Promo p) {
    final sel = _promo == p;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap: () => _escolher(p),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: fundoCard,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
                color: sel
                    ? vermelhoDestaque
                    : Colors.white.withValues(alpha: .13),
                width: sel ? 1.5 : 1),
          ),
          child: Row(children: [
            _BrandBox(type: p.brandType, size: 44),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(p.produto,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.w700)),
                  const SizedBox(height: 2),
                  Text(
                      'a partir de ${reais(_opcoesDePreco(p).first.valor)}'
                      '${p.requerReceita ? ' · exige receita' : ''}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 12)),
                ],
              ),
            ),
            Icon(
                sel
                    ? Icons.radio_button_checked
                    : Icons.radio_button_unchecked,
                color: sel ? vermelhoDestaque : Colors.white38),
          ]),
        ),
      ),
    );
  }

  Widget _botaoQtd(IconData i, VoidCallback? onTap) {
    return InkWell(
      onTap: onTap,
      customBorder: const CircleBorder(),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border:
              Border.all(color: onTap == null ? Colors.white12 : Colors.white38),
        ),
        child: Icon(i,
            size: 18, color: onTap == null ? Colors.white24 : Colors.white70),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = _promo;
    return _TelaReceita(
      barra: -1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 4, 16, 24),
        children: [
          const Text('NOVO PEDIDO',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  letterSpacing: .5)),
          const SizedBox(height: 16),
          _titulo('1. Escolha o medicamento'),
          for (final r in todasAsPromos) _opcaoRemedio(r),
          if (p != null) ...[
            _titulo('2. Quantidade'),
            Row(children: [
              _botaoQtd(Icons.remove, _qtd > 1 ? () => setState(() => _qtd--) : null),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 18),
                child: Text('$_qtd',
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800)),
              ),
              _botaoQtd(Icons.add, _qtd < 10 ? () => setState(() => _qtd++) : null),
            ]),
            const SizedBox(height: 14),
            _titulo('3. Retirar em'),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: fundoCard,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha: .13)),
              ),
              child: Column(children: [
                for (final o in _opcoesDePreco(p))
                  InkWell(
                    onTap: () => setState(() => _farm = o.nome),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Row(children: [
                        Icon(
                            _farm == o.nome
                                ? Icons.radio_button_checked
                                : Icons.radio_button_unchecked,
                            size: 20,
                            color: _farm == o.nome
                                ? vermelhoDestaque
                                : Colors.white38),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(o.nome,
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 14)),
                        ),
                        if (o == _opcoesDePreco(p).first)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: _Selo(
                                texto: 'Menor preço',
                                cor: verdeOk,
                                pequeno: true),
                          ),
                        Text(reais(o.valor),
                            style: TextStyle(
                                color: o == _opcoesDePreco(p).first
                                    ? verdeOk
                                    : Colors.white,
                                fontWeight: FontWeight.w700)),
                      ]),
                    ),
                  ),
              ]),
            ),
            if (p.requerReceita) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
                decoration: BoxDecoration(
                  color: vermelhoDestaque.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: vermelhoDestaque.withValues(alpha: .6)),
                ),
                child: CheckboxListTile(
                  value: _temReceita,
                  onChanged: (v) => setState(() => _temReceita = v ?? false),
                  activeColor: vermelhoDestaque,
                  checkColor: Colors.white,
                  side: const BorderSide(color: Colors.white54),
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: const Text(
                      'Tenho a receita médica e vou levar a original na retirada.',
                      style: TextStyle(color: Colors.white70, fontSize: 13)),
                ),
              ),
            ],
            const SizedBox(height: 16),
            _Secao(
              titulo: 'Total',
              child: Row(children: [
                Expanded(
                  child: Text('$_qtd x ${reais(_precoUnit)}',
                      style: const TextStyle(
                          color: Colors.white54, fontSize: 13)),
                ),
                Text(reais(_precoUnit * _qtd),
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
              ]),
            ),
          ],
          _BotaoPrimario(
              texto: 'Confirmar pedido',
              icone: Icons.check,
              onTap: _pode ? _confirmar : null),
          if (p == null)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Escolha um medicamento para continuar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11.5)),
            ),
          if (p != null && p.requerReceita && !_temReceita)
            const Padding(
              padding: EdgeInsets.only(top: 8),
              child: Text('Marque que você tem a receita para confirmar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11.5)),
            ),
        ],
      ),
    );
  }
}