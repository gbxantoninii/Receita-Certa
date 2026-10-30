part of 'main.dart';

// ============================================================
// HEADER (lupa, sino e mensagem funcionando)
// ============================================================
class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Scaffold.of(context).openDrawer(),
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: vermelhoDestaque, width: 2),
              ),
              child: const Icon(Icons.person_outline,
                  size: 24, color: vermelhoDestaque),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: AnimatedBuilder(
              animation: perfil,
              builder: (_, _) => Text(
                usuarioLogado,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          // LUPA -> busca com sugestões
          _HeaderIcon(
            icon: Icons.search,
            tooltip: 'Buscar',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const BuscaPage()),
            ),
          ),
          const SizedBox(width: 14),
          // SINO -> central de notificações (com contador)
          AnimatedBuilder(
            animation: notificacoesStore,
            builder: (_, _) => _HeaderIcon(
              icon: Icons.notifications_none,
              tooltip: 'Notificações',
              badge: notificacoesStore.naoLidas,
              onTap: () => Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const NotificacoesPage()),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // MENSAGEM -> chatbot
          _HeaderIcon(
            icon: Icons.chat_bubble_outline,
            tooltip: 'Ajuda',
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const ChatbotPage()),
            ),
          ),
        ],
      ),
    );
  }
}

class _HeaderIcon extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final int badge;

  const _HeaderIcon({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.badge = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 22,
        child: Padding(
          padding: const EdgeInsets.all(4),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(icon, size: 24, color: Colors.white70),
              if (badge > 0)
                Positioned(
                  right: -5,
                  top: -4,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    constraints:
                        const BoxConstraints(minWidth: 15, minHeight: 15),
                    decoration: BoxDecoration(
                      color: vermelhoDestaque,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: fundo, width: 1.5),
                    ),
                    child: Center(
                      child: Text(
                        badge > 9 ? '9+' : '$badge',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// 1) BUSCA COM CAMPO DE TEXTO + SUGESTÕES
// ============================================================
class BuscaPage extends StatefulWidget {
  const BuscaPage({super.key});

  @override
  State<BuscaPage> createState() => _BuscaPageState();
}

class _BuscaPageState extends State<BuscaPage> {
  static final List<String> _recentes = [];

  static const List<String> _termos = [
    'dor de cabeça',
    'dor muscular',
    'febre',
    'azia',
    'refluxo',
    'pressão alta',
    'diabetes',
    'enxaqueca',
    'uso contínuo',
    'venda livre',
  ];

  final _controller = TextEditingController();
  final _focus = FocusNode();
  bool _resultados = false; // false = mostrando sugestões

  String get _q => normalizar(_controller.text.trim());

  @override
  void dispose() {
    _controller.dispose();
    _focus.dispose();
    super.dispose();
  }

  void _buscar(String termo) {
    final t = termo.trim();
    if (t.isEmpty) return;
    _controller.text = t;
    _controller.selection = TextSelection.collapsed(offset: t.length);
    _recentes.remove(t);
    _recentes.insert(0, t);
    if (_recentes.length > 5) _recentes.removeLast();
    _focus.unfocus();
    setState(() => _resultados = true);
  }

  bool _bate(Promo p, String q) {
    final texto = normalizar(
        '${p.produto} ${p.composicao} ${p.descricao} ${p.descricaoDetalhada} ${p.brand} '
        '${p.requerReceita ? 'uso continuo receita' : 'venda livre'}');
    return q.split(' ').where((e) => e.isNotEmpty).every(texto.contains);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fundo,
      appBar: AppBar(
        backgroundColor: fundo,
        foregroundColor: Colors.white,
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 12),
          child: TextField(
            controller: _controller,
            focusNode: _focus,
            autofocus: true,
            textInputAction: TextInputAction.search,
            cursorColor: vermelhoDestaque,
            style: const TextStyle(color: Colors.white, fontSize: 15),
            onChanged: (_) => setState(() => _resultados = false),
            onSubmitted: _buscar,
            decoration: InputDecoration(
              hintText: 'Buscar remédio, sintoma, farmácia...',
              hintStyle: const TextStyle(color: Colors.white38, fontSize: 14),
              filled: true,
              fillColor: Colors.white.withValues(alpha: .08),
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(22),
                borderSide: const BorderSide(color: vermelhoDestaque),
              ),
              suffixIcon: _controller.text.isEmpty
                  ? null
                  : IconButton(
                      icon: const Icon(Icons.close,
                          size: 18, color: Colors.white54),
                      onPressed: () {
                        _controller.clear();
                        setState(() => _resultados = false);
                        _focus.requestFocus();
                      },
                    ),
            ),
          ),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 410),
          child: _q.isEmpty
              ? _vazio()
              : (_resultados ? _listaResultados() : _sugestoes()),
        ),
      ),
    );
  }

  // Campo vazio: recentes + populares
  Widget _vazio() {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recentes.isNotEmpty) ...[
          const Text('Buscas recentes',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 14)),
          const SizedBox(height: 4),
          for (final r in _recentes)
            ListTile(
              dense: true,
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.history, color: Colors.white54, size: 20),
              title: Text(r, style: const TextStyle(color: Colors.white70)),
              onTap: () => _buscar(r),
            ),
          const SizedBox(height: 14),
        ],
        const Text('Sugestões',
            style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final t in _termos)
              ActionChip(
                label: Text(t,
                    style: const TextStyle(
                        color: Colors.white70, fontSize: 12.5)),
                backgroundColor: Colors.white.withValues(alpha: .08),
                side: BorderSide(color: Colors.white.withValues(alpha: .15)),
                onPressed: () => _buscar(t),
              ),
          ],
        ),
      ],
    );
  }

  // Digitando: sugere remédios e termos
  Widget _sugestoes() {
    final q = _q;
    final prods = _todasPromos
        .where((p) =>
            normalizar(p.produto).contains(q) ||
            normalizar(p.composicao).contains(q) ||
            normalizar(p.brand).contains(q))
        .take(4)
        .toList();
    final termos =
        _termos.where((t) => normalizar(t).contains(q)).take(4).toList();

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ListTile(
          leading: const Icon(Icons.search, color: vermelhoDestaque),
          title: Text('Buscar por "${_controller.text.trim()}"',
              style: const TextStyle(color: Colors.white)),
          onTap: () => _buscar(_controller.text),
        ),
        for (final t in termos)
          ListTile(
            leading:
                const Icon(Icons.north_west, color: Colors.white38, size: 18),
            title: Text(t, style: const TextStyle(color: Colors.white70)),
            onTap: () => _buscar(t),
          ),
        for (final p in prods)
          ListTile(
            leading: _BrandBox(type: p.brandType, size: 40),
            title:
                Text(p.produto, style: const TextStyle(color: Colors.white)),
            subtitle: Text('${p.brand} · ${p.descontoTexto}',
                style: const TextStyle(color: Colors.white54)),
            onTap: () => _buscar(p.produto),
          ),
      ],
    );
  }

  Widget _listaResultados() {
    final achados = _todasPromos.where((p) => _bate(p, _q)).toList();

    if (achados.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.search_off, size: 56, color: Colors.white38),
              const SizedBox(height: 12),
              Text('Nada encontrado para "${_controller.text.trim()}"',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700)),
              const SizedBox(height: 6),
              const Text('Tente o nome do remédio ou um sintoma, como "azia".',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white54, fontSize: 13)),
            ],
          ),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: achados.length + 1,
      separatorBuilder: (_, _) => const SizedBox(height: 14),
      itemBuilder: (_, i) {
        if (i == 0) {
          return Text(
            '${achados.length} resultado${achados.length == 1 ? '' : 's'}',
            style: const TextStyle(color: Colors.white54, fontSize: 12),
          );
        }
        return PromoCard(promo: achados[i - 1]);
      },
    );
  }
}

// ============================================================
// 2) CHATBOT DE AJUDA
// ============================================================
class MensagemChat {
  final String texto;
  final bool deUsuario;
  final String hora;
  const MensagemChat(this.texto, this.deUsuario, this.hora);
}

const Color _chatFundo = Color(0xFFEFE9E1);
const Color _chatTopo = Color(0xFFFBF8F5);
const Color _chatBolhaUsuario = Color(0xFFF3E1A6);
const Color _chatTexto = Color(0xFF2B2B2B);
const Color _chatEnviar = Color(0xFF2ECC71);

/// Cérebro do bot: respostas por palavras-chave.
/// Depois você pode trocar esta função por uma chamada a uma API de IA
/// (feita por um servidor seu, nunca com a chave dentro do app).
String responderBot(String entrada) {
  final t = normalizar(entrada);
  bool tem(List<String> ks) => ks.any(t.contains);

  // 1) Emergência sempre vem primeiro
  if (tem([
    'overdose',
    'tomei demais',
    'tomei muito',
    'intoxic',
    'envenen',
    'falta de ar',
    'nao consigo respirar',
    'desmai',
    'convuls',
    'reacao alergica',
  ])) {
    return '⚠️ Isso pode ser urgente. Não espere: ligue agora para o SAMU (192) '
        'ou vá ao pronto-atendimento mais próximo.\n\n'
        'Em caso de intoxicação por medicamento, o Disque-Intoxicação '
        'atende 24h no 0800 722 6001.';
  }

  // 2) Pergunta sobre um remédio que existe no app
  for (final p in _todasPromos) {
    final nome = normalizar(p.produto.split(' ').first);
    if (t.contains(nome)) {
      return '💊 ${p.produto}\n\n'
          '• Composição: ${p.composicao}\n'
          '• Para que serve: ${p.descricaoDetalhada}\n'
          '• Preço: ${reais(p.precoPromo)} (${p.descontoTexto}) na ${p.brand}\n'
          '• ${p.requerReceita ? 'Venda sob receita médica' : 'Venda livre'}\n\n'
          'Atenção: ${p.avisos}\n\n'
          'Para dose e horários, siga a bula ou a orientação do médico/farmacêutico. '
          'Veja mais na tela "Ver mais" do medicamento.';
    }
  }

  // 3) Segurança: dose, interação, gravidez...
  if (tem([
    'dose',
    'quanto tomar',
    'quantos comprimidos',
    'efeito colateral',
    'reacao',
    'interacao',
    'misturar',
    'tomar junto',
    'gravida',
    'gestante',
    'amament',
    'crianca',
    'bebida',
    'alcool',
  ])) {
    return 'Dose, interações e uso na gravidez, amamentação ou em crianças '
        'dependem de cada pessoa, e eu não posso substituir a bula nem '
        'um profissional.\n\n'
        '👉 Leia a bula do medicamento\n'
        '👉 Pergunte ao farmacêutico da farmácia\n'
        '👉 Se tiver receita, siga exatamente o que o médico indicou';
  }

  if (tem(['oi', 'ola', 'bom dia', 'boa tarde', 'boa noite', 'e ai'])) {
    return 'Oi! 😊 Como posso ajudar? Você pode me perguntar sobre '
        'medicamentos, escaneamento de receitas, preços, lembretes ou farmácias.';
  }

  if (tem(['escane', 'receita', 'foto', 'camera', 'ler'])) {
    return '📷 Para entender sua receita:\n\n'
        '1. Toque no botão "+" no centro da barra inferior\n'
        '2. Fotografe a receita com boa luz, sem sombras\n'
        '3. Confira os medicamentos identificados\n'
        '4. Ative lembretes para não esquecer os horários\n\n'
        'Dica: deixe a receita aberta e bem reta para o texto ficar nítido.';
  }

  if (tem(['preco', 'desconto', 'barato', 'promo', 'compar', 'oferta'])) {
    return '💸 Para economizar:\n\n'
        '• Veja as promoções nas abas Destaques e Recentes\n'
        '• Toque em "Ver mais" para comparar o preço do mesmo remédio '
        'em outras farmácias; o menor preço aparece destacado\n'
        '• Medicamentos de uso contínuo costumam ter descontos maiores\n\n'
        'Os valores podem variar, então confirme na farmácia.';
  }

  if (tem(['lembrete', 'horario', 'alarme', 'esquec', 'avisar'])) {
    return '⏰ Os lembretes ficam na aba "Lembretes", na barra inferior. '
        'Você define o remédio e os horários, e o app avisa na hora certa. '
        'Tomar sempre no mesmo horário ajuda no tratamento.';
  }

  if (tem(['farmacia', 'perto', 'proxim', 'endereco', 'aberta', 'telefone'])) {
    return '📍 Em "Ver mais" de cada promoção você encontra a farmácia mais '
        'próxima, com endereço, distância, horário e telefone, e pode copiar '
        'o endereço. Em "Pedidos", o botão "Ver farmácias" mostra todas as opções.';
  }

  if (tem(['conta', 'senha', 'login', 'privacidade', 'dados', 'excluir', 'sair'])) {
    return '🔒 Sobre conta e privacidade: você entra com e-mail e senha, Apple ou Google e '
        'seus dados ficam protegidos. No menu do perfil você acessa '
        'Configurações, Termos de Serviço e Privacidade.';
  }

  if (tem(['dor', 'febre', 'tosse', 'gripe', 'azia', 'enjoo', 'gastrite', 'enxaqueca'])) {
    return 'Sinto muito que você não esteja bem. 💛 Não consigo diagnosticar '
        'nem indicar tratamento, mas posso ajudar a:\n\n'
        '• Buscar remédios relacionados (toque na lupa e digite o sintoma)\n'
        '• Mostrar bula e avisos importantes\n\n'
        'Se os sintomas forem fortes, durarem vários dias ou piorarem, '
        'procure um médico ou fale com o farmacêutico.';
  }

  if (tem(['obrigad', 'valeu', 'brigad'])) {
    return 'De nada! 😊 Se surgir outra dúvida, é só chamar.';
  }

  return 'Não tenho certeza se entendi. 🤔 Posso ajudar com:\n\n'
      '• Dúvidas sobre medicamentos\n'
      '• Escanear receitas\n'
      '• Preços e descontos\n'
      '• Lembretes\n'
      '• Farmácias próximas\n\n'
      'Toque em um dos atalhos abaixo ou escreva de outro jeito.';
}


Future<String> perguntarReceitaCertaIA(String pergunta) async {
  final medicamentos = _todasPromos.map((p) {
    return {
      'nome': p.produto,
      'composicao': p.composicao,
      'descricao': p.descricaoDetalhada,
      'preco': p.precoPromo.toString(),
      'desconto': p.descontoTexto,
      'farmacia': p.brand,
      'requerReceita': p.requerReceita,
      'avisos': p.avisos,
    };
  }).toList();

  final resposta = await http
      .post(
        Uri.parse('http://localhost:3000/chat'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'mensagem': pergunta,
          'medicamentos': medicamentos,
        }),
      )
      .timeout(const Duration(seconds: 40));

  if (resposta.statusCode != 200) {
    throw Exception('A IA retornou um erro.');
  }

  final dados = jsonDecode(resposta.body) as Map<String, dynamic>;
  final texto = dados['resposta'] as String?;

  if (texto == null || texto.trim().isEmpty) {
    throw Exception('A IA retornou uma resposta vazia.');
  }

  return texto;
}


class ChatbotPage extends StatefulWidget {
  const ChatbotPage({super.key});

  @override
  State<ChatbotPage> createState() => _ChatbotPageState();
}

class _ChatbotPageState extends State<ChatbotPage> {
  final _controller = TextEditingController();
  final _scroll = ScrollController();
  bool _digitando = false;

  final List<MensagemChat> _msgs = [
    MensagemChat(
      'Olá! Eu sou o assistente do Receita Certa 💊\n'
      'Posso ajudar com medicamentos, receitas, preços, lembretes e farmácias. '
      'Sobre o que você quer falar?',
      false,
      _agora(),
    ),
  ];

  static const _atalhos = <String, String>{
    'Dúvida sobre medicamento': 'Tenho uma dúvida sobre meus medicamentos',
    'Escanear receita': 'Como escanear minha receita?',
    'Preços e descontos': 'Como funcionam os descontos?',
    'Lembretes': 'Como criar lembretes?',
    'Farmácia mais próxima': 'Onde fica a farmácia mais próxima?',
    'Conta e privacidade': 'Dúvida sobre minha conta e privacidade',
  };

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _rolar() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  
Future<void> _enviar([String? atalho]) async {
  final texto = (atalho ?? _controller.text).trim();
  if (texto.isEmpty || _digitando) return;

  setState(() {
    _msgs.add(MensagemChat(texto, true, _agora()));
    _digitando = true;
    _controller.clear();
  });
  _rolar();

  String resposta;

  try {
    resposta = await perguntarReceitaCertaIA(texto);
  } catch (e) {
    debugPrint('ERRO AO CONECTAR COM A IA: $e');

    resposta =
        '${responderBot(texto)}\n\n'
        'Estou usando a resposta local porque não consegui '
        'conectar à IA agora.';
  }

  if (!mounted) return;

  setState(() {
    _msgs.add(MensagemChat(resposta, false, _agora()));
    _digitando = false;
  });

  _rolar();
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _chatFundo,
      appBar: AppBar(
        backgroundColor: _chatTopo,
        foregroundColor: _chatTexto,
        elevation: 1,
        titleSpacing: 0,
        title: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration:
                  const BoxDecoration(color: vinho, shape: BoxShape.circle),
              child:
                  const Icon(Icons.medication, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text('RECEITACERTA',
                    style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: _chatTexto)),
                Text('assistente virtual',
                    style: TextStyle(fontSize: 11, color: Colors.black54)),
              ],
            ),
          ],
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 410),
          child: Column(
            children: [
              Expanded(
                child: ListView.builder(
                  controller: _scroll,
                  padding: const EdgeInsets.fromLTRB(12, 14, 12, 8),
                  itemCount: _msgs.length + (_digitando ? 1 : 0),
                  itemBuilder: (_, i) {
                    if (i == _msgs.length) return const _Digitando();
                    return _Bolha(msg: _msgs[i]);
                  },
                ),
              ),
              SizedBox(
                height: 40,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                    for (final e in _atalhos.entries)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ActionChip(
                          label: Text(e.key,
                              style: const TextStyle(
                                  fontSize: 12, color: vinho)),
                          backgroundColor: Colors.white,
                          side: const BorderSide(color: vinho),
                          onPressed: () => _enviar(e.value),
                        ),
                      ),
                  ],
                ),
              ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(12, 8, 12, 10),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          padding: const EdgeInsets.only(left: 14, right: 4),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _controller,
                                  onSubmitted: (_) => _enviar(),
                                  textInputAction: TextInputAction.send,
                                  minLines: 1,
                                  maxLines: 3,
                                  style: const TextStyle(
                                      color: _chatTexto, fontSize: 14),
                                  decoration: const InputDecoration(
                                    hintText:
                                        'Oi, estou com dúvida sobre meus medicamentos, pode me ajudar?',
                                    hintStyle: TextStyle(
                                        color: Colors.black38, fontSize: 12.5),
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding:
                                        EdgeInsets.symmetric(vertical: 12),
                                  ),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.attach_file,
                                    color: Colors.black54),
                                onPressed: () =>
                                    ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                        'Em breve: enviar foto da receita'),
                                    duration: Duration(seconds: 2),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _enviar,
                        child: Container(
                          width: 46,
                          height: 46,
                          decoration: const BoxDecoration(
                              color: _chatEnviar, shape: BoxShape.circle),
                          child: const Icon(Icons.send,
                              color: Colors.white, size: 22),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Bolha extends StatelessWidget {
  final MensagemChat msg;
  const _Bolha({required this.msg});

  @override
  Widget build(BuildContext context) {
    final u = msg.deUsuario;
    return Align(
      alignment: u ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.fromLTRB(12, 8, 12, 6),
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * .78),
        decoration: BoxDecoration(
          color: u ? _chatBolhaUsuario : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(14),
            topRight: const Radius.circular(14),
            bottomLeft: Radius.circular(u ? 14 : 3),
            bottomRight: Radius.circular(u ? 3 : 14),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: Text(msg.texto,
                  style: const TextStyle(
                      color: _chatTexto, fontSize: 14, height: 1.35)),
            ),
            const SizedBox(height: 2),
            Text(msg.hora,
                style: const TextStyle(color: Colors.black45, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}

class _Digitando extends StatelessWidget {
  const _Digitando();

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Text('digitando...',
            style: TextStyle(
                color: Colors.black45,
                fontSize: 12.5,
                fontStyle: FontStyle.italic)),
      ),
    );
  }
}

// ============================================================
// 3) CENTRAL DE NOTIFICAÇÕES
// ============================================================
class Notificacao {
  final String id;
  final String titulo;
  final String texto;
  final String tempo;
  final IconData icone;
  final Color cor;
  final Promo? promo; // se tiver, abre os detalhes ao tocar
  bool lida;

  Notificacao({
    required this.id,
    required this.titulo,
    required this.texto,
    required this.tempo,
    required this.icone,
    required this.cor,
    this.promo,
    this.lida = false,
  });
}

class NotificacoesStore extends ChangeNotifier {
  final List<Notificacao> itens = [
    Notificacao(
      id: 'n1',
      titulo: 'Promoção nova perto de você',
      texto: 'Dorflex com 20% OFF na Drogaria Raia.',
      tempo: 'há 5 min',
      icone: Icons.local_offer_outlined,
      cor: vermelhoDestaque,
      promo: promosRecentes[0],
    ),
    Notificacao(
      id: 'n2',
      titulo: 'Hora do seu remédio',
      texto: 'Losartana 50mg: tomar agora, como combinado.',
      tempo: 'há 1 h',
      icone: Icons.alarm,
      cor: const Color(0xFFF2A93B),
    ),
    Notificacao(
      id: 'n3',
      titulo: 'Menor preço encontrado',
      texto: 'Omeprazol 20mg está 30% mais barato na Drogaria Raia.',
      tempo: 'há 3 h',
      icone: Icons.trending_down,
      cor: verdeOk,
      promo: promosDestaques[1],
    ),
    Notificacao(
      id: 'n4',
      titulo: '@rafaela.mt comentou',
      texto: 'Uso quando bate dor nas costas depois de um dia inteiro...',
      tempo: 'ontem',
      icone: Icons.chat_bubble_outline,
      cor: const Color(0xFF4A90E2),
      promo: promosRecentes[0],
      lida: true,
    ),
    Notificacao(
      id: 'n5',
      titulo: 'Bem-vindo ao Receita Certa',
      texto: 'Escaneou, entendeu, cuidou. Explore as promoções e ative seus lembretes.',
      tempo: '2 dias',
      icone: Icons.waving_hand_outlined,
      cor: Colors.white70,
      lida: true,
    ),
  ];

  int get naoLidas => itens.where((n) => !n.lida).length;

  void marcarLida(Notificacao n) {
    if (n.lida) return;
    n.lida = true;
    notifyListeners();
  }

  void marcarTodas() {
    for (final n in itens) {
      n.lida = true;
    }
    notifyListeners();
  }

  void remover(Notificacao n) {
    itens.remove(n);
    notifyListeners();
  }
}

final NotificacoesStore notificacoesStore = NotificacoesStore();

class NotificacoesPage extends StatefulWidget {
  const NotificacoesPage({super.key});

  @override
  State<NotificacoesPage> createState() => _NotificacoesPageState();
}

class _NotificacoesPageState extends State<NotificacoesPage> {
  bool _soNaoLidas = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: notificacoesStore,
      builder: (context, _) {
        final lista = notificacoesStore.itens
            .where((n) => !_soNaoLidas || !n.lida)
            .toList();

        return Scaffold(
          backgroundColor: fundo,
          appBar: AppBar(
            backgroundColor: fundo,
            title: const Text('Notificações',
                style: TextStyle(fontWeight: FontWeight.w700)),
            actions: [
              TextButton(
                onPressed: notificacoesStore.naoLidas == 0
                    ? null
                    : notificacoesStore.marcarTodas,
                child: const Text('Marcar todas',
                    style: TextStyle(fontSize: 12.5)),
              ),
            ],
          ),
          body: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 4, 16, 10),
                    child: Row(
                      children: [
                        _FiltroChip(
                          texto: 'Todas',
                          ativo: !_soNaoLidas,
                          onTap: () => setState(() => _soNaoLidas = false),
                        ),
                        const SizedBox(width: 8),
                        _FiltroChip(
                          texto: 'Não lidas'
                              '${notificacoesStore.naoLidas > 0 ? ' (${notificacoesStore.naoLidas})' : ''}',
                          ativo: _soNaoLidas,
                          onTap: () => setState(() => _soNaoLidas = true),
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: lista.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: const [
                                Icon(Icons.notifications_off_outlined,
                                    size: 56, color: Colors.white38),
                                SizedBox(height: 12),
                                Text('Tudo em dia por aqui',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 16,
                                        fontWeight: FontWeight.w700)),
                                SizedBox(height: 4),
                                Text('Você não tem notificações.',
                                    style: TextStyle(
                                        color: Colors.white54,
                                        fontSize: 13)),
                              ],
                            ),
                          )
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                            itemCount: lista.length,
                            separatorBuilder: (_, _) =>
                                const SizedBox(height: 10),
                            itemBuilder: (_, i) {
                              final n = lista[i];
                              return Dismissible(
                                key: ValueKey(n.id),
                                direction: DismissDirection.endToStart,
                                background: Container(
                                  alignment: Alignment.centerRight,
                                  padding: const EdgeInsets.only(right: 20),
                                  decoration: BoxDecoration(
                                    color: vinho,
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(Icons.delete_outline,
                                      color: Colors.white),
                                ),
                                onDismissed: (_) =>
                                    notificacoesStore.remover(n),
                                child: _NotificacaoTile(
                                  n: n,
                                  onTap: () {
                                    notificacoesStore.marcarLida(n);
                                    if (n.promo != null) {
                                      Navigator.of(context).push(
                                        MaterialPageRoute(
                                          builder: (_) =>
                                              DetalhesPage(promo: n.promo!),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback onTap;
  const _FiltroChip(
      {required this.texto, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: ativo ? vinho : Colors.transparent,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ativo ? vinho : Colors.white38),
        ),
        child: Text(texto,
            style: TextStyle(
                color: Colors.white,
                fontSize: 12.5,
                fontWeight: ativo ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}

class _NotificacaoTile extends StatelessWidget {
  final Notificacao n;
  final VoidCallback onTap;
  const _NotificacaoTile({required this.n, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: n.lida ? fundoCard : fundoCard.withValues(alpha: 1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: n.lida
                ? Colors.white.withValues(alpha: .1)
                : vermelhoDestaque.withValues(alpha: .6),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: n.cor.withValues(alpha: .16),
                shape: BoxShape.circle,
              ),
              child: Icon(n.icone, size: 20, color: n.cor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(n.titulo,
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: n.lida
                                    ? FontWeight.w500
                                    : FontWeight.w800)),
                      ),
                      if (!n.lida)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                              color: vermelhoDestaque,
                              shape: BoxShape.circle),
                        ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(n.texto,
                      style: TextStyle(
                          color: Colors.white.withValues(alpha: .65),
                          fontSize: 13,
                          height: 1.3)),
                  const SizedBox(height: 6),
                  Text(n.tempo,
                      style:
                          const TextStyle(color: Colors.white38, fontSize: 11)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ############################################################
// A PARTIR DAQUI: TELAS NOVAS (menu, perfil, configurações,
// suporte, salvas, feedback, ajuda, documentos, login/cadastro)
// ############################################################
// ATENÇÃO: os textos legais (Termos, Privacidade etc.) são modelos
// para o protótipo. Antes de publicar o app de verdade, peça a
// revisão de um advogado e preencha os dados reais da empresa.

// ------------------------------------------------------------
// CONFIGURAÇÕES FÁCEIS DE TROCAR
// ------------------------------------------------------------
/// Imagem principal (logo) da tela de login. Coloque o arquivo em
/// assets/logo_principal.png (e confirme que a pasta assets está no pubspec.yaml).
const String assetLogoPrincipal = 'assets/logo_principal.png';

/// Dados de contato de EXEMPLO. Troque pelos reais.
const String emailSuporte = 'suporte@receitacerta.com.br';
const String telefoneSuporte = '(11) 4000-0000';

/// Tela para onde o usuário vai depois de entrar/cadastrar.
/// Hoje é a tela inicial antiga (LoginPage). Para ir direto à home,
/// troque por: const HomePage()
Widget telaAposLogin() => const LoginPage();

