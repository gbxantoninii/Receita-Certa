part of 'main.dart';

// ############################################################
// FLUXO DA RECEITA: scanner -> resultado -> orientações ->
// confirmar -> Minhas Receitas  (+ Farmácias e Lembretes)
// ############################################################

class ReceitaLida {
  final String nome;
  final String medicamento;
  final String posologia;
  final List<String> efeitos;
  final String atencao;
  final String explicacao;
  final DateTime data;

  ReceitaLida({
    required this.nome,
    required this.medicamento,
    required this.posologia,
    required this.efeitos,
    required this.atencao,
    required this.explicacao,
    required this.data,
  });

  /// Leitura de EXEMPLO (igual ao Figma). Troque por OCR/IA depois.
  factory ReceitaLida.exemplo() => ReceitaLida(
        nome: 'Amoxicilina',
        medicamento: 'Amoxicilina 500mg',
        posologia: 'Tomar 1 cápsula a cada 8 horas por 7 dias',
        efeitos: const [
          'Náusea',
          'Vômito',
          'Diarreia',
          'Dor de barriga',
          'Dor de cabeça',
          'Tontura',
          'Coceira ou manchas na pele',
          'Falta de ar',
          'Inchaço no rosto, lábios ou língua',
          'Reação alérgica forte',
          'Diarreia intensa ou com sangue',
        ],
        atencao: 'Verificar alergia a penicilina.\nTomar com alimentos.',
        explicacao:
            'Este medicamento é um antibiótico. Tome 1 cápsula a cada 8 horas '
            'durante 7 dias. Complete o tratamento mesmo se estiver se sentindo '
            'melhor. Pode tomar com alimentos.',
        data: DateTime.now(),
      );
}

class ReceitasStore extends ChangeNotifier {
  final List<ReceitaLida> itens = [];
  void adicionar(ReceitaLida r) {
    itens.insert(0, r);
    notifyListeners();
  }
}

final ReceitasStore receitasStore = ReceitasStore();

class Lembrete {
  String remedio;
  TimeOfDay hora;
  bool ativo;
  Lembrete(this.remedio, this.hora, [this.ativo = true]);
}

class LembretesStore extends ChangeNotifier {
  final List<Lembrete> itens = [
    Lembrete('Losartana 50mg', const TimeOfDay(hour: 8, minute: 0)),
  ];

  void adicionar(Lembrete l) {
    itens.add(l);
    itens.sort((a, b) => (a.hora.hour * 60 + a.hora.minute)
        .compareTo(b.hora.hour * 60 + b.hora.minute));
    notifyListeners();
  }

  void alternar(Lembrete l, bool v) {
    l.ativo = v;
    notifyListeners();
  }

  void remover(Lembrete l) {
    itens.remove(l);
    notifyListeners();
  }
}

final LembretesStore lembretesStore = LembretesStore();

class _TelaReceita extends StatelessWidget {
  final Widget child;
  final int? barra;
  const _TelaReceita({required this.child, this.barra});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        foregroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        toolbarHeight: 44,
      ),
      body: Stack(
        children: [
          Positioned(
              top: -38, left: -38, child: _decorativeCircle(105)),
          Positioned(
              right: -50, bottom: -42, child: _decorativeCircle(130)),
          Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410),
              child: Column(
                children: [
                  Expanded(child: child),
                  if (barra != null) _BottomBar(atual: barra!),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LogoReceita extends StatelessWidget {
  const _LogoReceita();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/capsula.png',
          width: 53,
          height: 43,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) =>
              const Icon(Icons.medication, size: 40, color: vermelhoDestaque),
        ),
        const SizedBox(width: 5),
        RichText(
          text: const TextSpan(
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
            children: [
              TextSpan(
                  text: 'Receita', style: TextStyle(color: vermelhoDestaque)),
              TextSpan(text: ' Certa', style: TextStyle(color: Colors.white70)),
            ],
          ),
        ),
      ],
    );
  }
}

class _BotaoContorno extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  const _BotaoContorno({required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          foregroundColor: Colors.white,
          backgroundColor: Colors.white.withValues(alpha: .04),
          side: const BorderSide(color: vinho, width: 2),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        child: Text(texto,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800)),
      ),
    );
  }
}

// ---------------- 1) SCANNER (botão +) ----------------
class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  bool _lendo = false;

  Future<void> _capturar(ImageSource origem) async {
    try {
      final foto =
          await ImagePicker().pickImage(source: origem, imageQuality: 85);
      if (foto == null) return;
    } catch (_) {
      if (!mounted) return;
      _aviso(context, 'Não consegui abrir a câmera. Usando uma receita de exemplo.');
    }
    await _ler();
  }

  Future<void> _ler() async {
    setState(() => _lendo = true);
    await Future.delayed(const Duration(milliseconds: 1800));
    if (!mounted) return;
    final ok = await Navigator.of(context).push<bool>(MaterialPageRoute(
      builder: (_) => ResultadoReceitaPage(receita: ReceitaLida.exemplo()),
    ));
    if (!mounted) return;
    setState(() => _lendo = false);
    if (ok == true) Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          foregroundColor: Colors.white,
          elevation: 0),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 410),
            child: Column(
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  color: Colors.white.withValues(alpha: .18),
                  child: const Text('Posicione a receita no lugar indicado',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 15,
                          fontWeight: FontWeight.w600)),
                ),
                Expanded(
                  child: Center(
                    child: _lendo
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              CircularProgressIndicator(color: vermelhoDestaque),
                              SizedBox(height: 16),
                              Text('Lendo a receita...',
                                  style: TextStyle(
                                      color: Colors.white70, fontSize: 15)),
                            ],
                          )
                        : AspectRatio(
                            aspectRatio: .78,
                            child: Container(
                              margin: const EdgeInsets.all(28),
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: const Color(0xFFF2C94C), width: 2),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(Icons.description_outlined,
                                  size: 84, color: Colors.white24),
                            ),
                          ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(24, 0, 24, 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        iconSize: 30,
                        color: Colors.white70,
                        tooltip: 'Galeria',
                        onPressed:
                            _lendo ? null : () => _capturar(ImageSource.gallery),
                        icon: const Icon(Icons.photo_library_outlined),
                      ),
                      GestureDetector(
                        onTap:
                            _lendo ? null : () => _capturar(ImageSource.camera),
                        child: Container(
                          width: 78,
                          height: 78,
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 3),
                          ),
                          child: Container(
                            decoration: const BoxDecoration(
                                color: Colors.white, shape: BoxShape.circle),
                          ),
                        ),
                      ),
                      const SizedBox(width: 48),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _lendo ? null : _ler,
                  child: const Text('Usar receita de exemplo',
                      style: TextStyle(color: Colors.white54, fontSize: 12.5)),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- 2) RECEITA LIDA COM SUCESSO ----------------
class ResultadoReceitaPage extends StatelessWidget {
  final ReceitaLida receita;
  const ResultadoReceitaPage({super.key, required this.receita});

  Widget _rotulo(String t) => Padding(
        padding: const EdgeInsets.only(top: 14, bottom: 4),
        child: Text(t,
            style: const TextStyle(
                color: vermelhoDestaque,
                fontSize: 14,
                fontWeight: FontWeight.w800)),
      );

  @override
  Widget build(BuildContext context) {
    return _TelaReceita(
      barra: -1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        children: [
          const _LogoReceita(),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('RECEITA LIDA COM SUCESSO!',
                textAlign: TextAlign.center,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700)),
          ),
          const SizedBox(height: 18),
          const Text('Medicamentos identificados:',
              style: TextStyle(color: Colors.white, fontSize: 13)),
          const SizedBox(height: 8),
          Row(children: [
            const Icon(Icons.medication, color: Color(0xFF4A90E2), size: 22),
            const SizedBox(width: 6),
            Text(receita.medicamento,
                style: const TextStyle(
                    color: vermelhoDestaque,
                    fontSize: 16,
                    fontWeight: FontWeight.w800)),
          ]),
          _rotulo('Posologia:'),
          Text(receita.posologia,
              style: const TextStyle(
                  color: Colors.white, fontSize: 13.5, height: 1.35)),
          _rotulo('Efeitos colaterais e cuidados:'),
          Text(receita.efeitos.join(', '),
              style: const TextStyle(
                  color: Colors.white, fontSize: 13.5, height: 1.4)),
          const SizedBox(height: 18),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_amber_rounded,
                    size: 44, color: Colors.white70),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Atenção!',
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700)),
                      const SizedBox(height: 4),
                      Text(receita.atencao,
                          style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                              height: 1.35)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          _BotaoContorno(
            texto: 'VER ORIENTAÇÕES PARA O CLIENTE',
            onTap: () async {
              final ok = await Navigator.of(context).push<bool>(
                MaterialPageRoute(
                    builder: (_) => OrientacaoPage(receita: receita)),
              );
              if (ok == true && context.mounted) {
                Navigator.of(context).pop(true);
              }
            },
          ),
          const SizedBox(height: 10),
          const Text(
              'A leitura automática pode errar. Confira com a receita original.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white38, fontSize: 11)),
        ],
      ),
    );
  }
}

// ---------------- 3) ORIENTAÇÕES + CONFIRMAR DISPENSAÇÃO ----------------
class OrientacaoPage extends StatelessWidget {
  final ReceitaLida receita;
  const OrientacaoPage({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    return _TelaReceita(
      barra: -1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
        children: [
          Align(
            alignment: Alignment.centerRight,
            child: InkWell(
              onTap: () => Navigator.of(context).push(MaterialPageRoute(
                  builder: (_) => const MinhasReceitasPage())),
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: .1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: vinho, width: 1.5),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.receipt_long, size: 18, color: Colors.white70),
                  SizedBox(width: 6),
                  Text('Minhas Receitas',
                      style: TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                          fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .14),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('Sugestão de explicação para o cliente:',
                style: TextStyle(color: Colors.white, fontSize: 15)),
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Column(
              children: [
                const Icon(Icons.support_agent, size: 72, color: Colors.white38),
                const SizedBox(height: 10),
                Text(receita.explicacao,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 14.5, height: 1.45)),
              ],
            ),
          ),
          const SizedBox(height: 8),
          const Align(
            alignment: Alignment.centerRight,
            child: Text('Verifique os sintomas antes de automedicar-se',
                style: TextStyle(color: Colors.white54, fontSize: 10.5)),
          ),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () {
                Clipboard.setData(ClipboardData(text: receita.explicacao));
                _aviso(context,
                    'Explicação copiada! Cole no WhatsApp para enviar ao cliente.');
              },
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: const Color(0xFF25D366),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: const [
                  Icon(Icons.chat, size: 16, color: Colors.white),
                  SizedBox(width: 6),
                  Text('ENVIAR EXPLICAÇÃO PELO WHATSAPP',
                      style: TextStyle(
                          color: Colors.white,
                          fontSize: 10.5,
                          fontWeight: FontWeight.w800)),
                ]),
              ),
            ),
          ),
          const SizedBox(height: 40),
          _BotaoContorno(
            texto: 'CONFIRMAR DISPENSAÇÃO',
            onTap: () {
              receitasStore.adicionar(receita);
              Navigator.of(context).pop(true);
            },
          ),
        ],
      ),
    );
  }
}

// ---------------- 4) MINHAS RECEITAS + INSTRUÇÕES ----------------
class MinhasReceitasPage extends StatelessWidget {
  final bool comBarra;
  const MinhasReceitasPage({super.key, this.comBarra = true});

  @override
  Widget build(BuildContext context) {
    return _TelaReceita(
      barra: comBarra ? 1 : null,
      child: AnimatedBuilder(
        animation: receitasStore,
        builder: (_, _) {
          final itens = receitasStore.itens;
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            children: [
              const Text('MINHAS RECEITAS',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: .5)),
              const SizedBox(height: 22),
              if (itens.isEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 40),
                  child: Column(children: const [
                    Icon(Icons.receipt_long_outlined,
                        size: 60, color: Colors.white38),
                    SizedBox(height: 12),
                    Text('Nenhuma receita ainda',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 17,
                            fontWeight: FontWeight.w700)),
                    SizedBox(height: 4),
                    Text('Toque no + para escanear uma receita.',
                        style: TextStyle(color: Colors.white54, fontSize: 13)),
                  ]),
                ),
              for (final r in itens)
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: InkWell(
                      onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                              builder: (_) => InstrucoesPage(receita: r))),
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 7),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9E4E4),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('VER INSTRUÇÕES DA ${r.nome.toUpperCase()}',
                                style: const TextStyle(
                                    color: vinho,
                                    fontSize: 11.5,
                                    fontWeight: FontWeight.w700)),
                            Text(_dataHora(r.data),
                                style: const TextStyle(
                                    color: Colors.black45, fontSize: 10)),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class InstrucoesPage extends StatelessWidget {
  final ReceitaLida receita;
  const InstrucoesPage({super.key, required this.receita});

  @override
  Widget build(BuildContext context) {
    return _TelaReceita(
      barra: 1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
        children: [
          const Text('MINHAS RECEITAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  letterSpacing: .5)),
          const SizedBox(height: 20),
          Align(
            alignment: Alignment.centerLeft,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
              decoration: BoxDecoration(
                color: const Color(0xFFE9E4E4),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text('INSTRUÇÕES DA ${receita.nome.toUpperCase()}',
                  style: const TextStyle(
                      color: vinho,
                      fontSize: 11.5,
                      fontWeight: FontWeight.w700)),
            ),
          ),
          const SizedBox(height: 16),
          Text(receita.medicamento,
              style: const TextStyle(
                  color: vermelhoDestaque,
                  fontSize: 15,
                  fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text('${receita.posologia}.\n\n${receita.explicacao}',
              style: const TextStyle(
                  color: Colors.white, fontSize: 14, height: 1.5)),
          const SizedBox(height: 16),
          Text('Atenção: ${receita.atencao.replaceAll('\n', ' ')}',
              style: const TextStyle(
                  color: Colors.white60, fontSize: 12.5, height: 1.4)),
        ],
      ),
    );
  }
}

// ---------------- 5) FARMÁCIAS ----------------
class FarmaciasPage extends StatelessWidget {
  const FarmaciasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final unicas = <String, Promo>{};
    for (final p in todasAsPromos) {
      unicas.putIfAbsent(p.brand, () => p);
    }
    final lista = unicas.values.toList();

    return _TelaReceita(
      barra: -1,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
        children: [
          const Text('FARMÁCIAS',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.w400,
                  letterSpacing: .5)),
          const SizedBox(height: 18),
          for (final p in lista)
            Container(
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
                  Row(children: [
                    _BrandBox(type: p.brandType, size: 52),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(p.brand,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700)),
                          Text('A ${p.distancia} de você',
                              style: const TextStyle(
                                  color: Colors.white54, fontSize: 12)),
                        ],
                      ),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  _LinhaInfo(Icons.place_outlined, p.endereco),
                  _LinhaInfo(Icons.access_time, p.horario),
                  _LinhaInfo(Icons.phone_outlined, p.telefone),
                  const SizedBox(height: 6),
                  OutlinedButton.icon(
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: p.endereco));
                      _aviso(context, 'Endereço copiado!');
                    },
                    icon: const Icon(Icons.copy, size: 16),
                    label: const Text('Copiar endereço'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                    ),
                  ),
                ],
              ),
            ),
          Text('Endereços de exemplo. Na versão final, serão calculados pela sua localização.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  color: Colors.white.withValues(alpha: .4), fontSize: 11)),
        ],
      ),
    );
  }
}

// ---------------- 6) LEMBRETES ----------------
class LembretesPage extends StatelessWidget {
  const LembretesPage({super.key});

  Future<void> _novo(BuildContext context) async {
    final nome = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEditar(
        titulo: 'Novo lembrete',
        inicial: '',
        hint: 'Nome do remédio',
        botao: 'Próximo',
        validar: (v) => (v ?? '').trim().isEmpty ? 'Informe o remédio' : null,
      ),
    );
    if (nome == null || !context.mounted) return;
    final hora = await showTimePicker(
        context: context, initialTime: const TimeOfDay(hour: 8, minute: 0));
    if (hora == null) return;
    lembretesStore.adicionar(Lembrete(nome, hora));
  }

  @override
  Widget build(BuildContext context) {
    return _TelaReceita(
      barra: 4,
      child: AnimatedBuilder(
        animation: lembretesStore,
        builder: (_, _) {
          final itens = lembretesStore.itens;
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              const Text('LEMBRETES',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.w400,
                      letterSpacing: .5)),
              const SizedBox(height: 18),
              if (itens.isEmpty)
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 30),
                  child: Text('Nenhum lembrete. Crie o primeiro abaixo.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white54)),
                ),
              for (final l in itens)
                Dismissible(
                  key: ObjectKey(l),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 20),
                    margin: const EdgeInsets.only(bottom: 10),
                    decoration: BoxDecoration(
                        color: vinho, borderRadius: BorderRadius.circular(12)),
                    child: const Icon(Icons.delete_outline, color: Colors.white),
                  ),
                  onDismissed: (_) => lembretesStore.remover(l),
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 10),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: fundoCard,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withValues(alpha: .13)),
                    ),
                    child: Row(children: [
                      const Icon(Icons.alarm, color: Color(0xFFF2A93B)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(l.hora.format(context),
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w800)),
                            Text(l.remedio,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 13)),
                          ],
                        ),
                      ),
                      Switch(
                        value: l.ativo,
                        activeThumbColor: Colors.white,
                        activeTrackColor: verdeOk,
                        onChanged: (v) => lembretesStore.alternar(l, v),
                      ),
                    ]),
                  ),
                ),
              const SizedBox(height: 6),
              _BotaoPrimario(
                  texto: 'Novo lembrete',
                  icone: Icons.add_alarm,
                  onTap: () => _novo(context)),
              const SizedBox(height: 10),
              const Text('Deslize para o lado para apagar.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white38, fontSize: 11)),
            ],
          );
        },
      ),
    );
  }
}

