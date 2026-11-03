part of 'main.dart';

// ============================================================
// PALETA CLARO / ESCURO
// ============================================================
class Cores {
  final bool escuro;
  const Cores(this.escuro);

  Color get fundo =>
      escuro ? const Color(0xFF323232) : const Color(0xFFF3F0ED);
  Color get card => escuro ? const Color(0xFF383838) : Colors.white;
  Color get menu => escuro ? const Color(0xFF222222) : Colors.white;
  Color get texto => escuro ? Colors.white : const Color(0xFF1E1E1E);
  Color get texto2 => escuro ? Colors.white70 : const Color(0xFF4F4F4F);
  Color get texto3 => escuro ? Colors.white54 : const Color(0xFF858585);
  Color get borda =>
      escuro ? Colors.white.withValues(alpha: .13) : Colors.black.withValues(alpha: .10);
  Color get campo =>
      escuro ? Colors.white.withValues(alpha: .08) : Colors.black.withValues(alpha: .05);
  Color get iconeMenu => escuro ? const Color(0xFF7A1520) : vinho;
}

extension CoresContexto on BuildContext {
  Cores get cores => Cores(Theme.of(this).brightness == Brightness.dark);
}

/// Tema escolhido no menu: 'Automático' (segue o celular), 'Claro' ou 'Escuro'.
final ValueNotifier<String> temaEscolhido = ValueNotifier('Automático');

ThemeMode modoDoTema(String t) {
  switch (t) {
    case 'Claro':
      return ThemeMode.light;
    case 'Escuro':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

// ============================================================
// DADOS DO USUÁRIO, PREFERÊNCIAS E CONTAS (em memória)
// ============================================================
class Perfil extends ChangeNotifier {
  String usuario = '@isabelangt1';
  String email = 'isabela.ngt1@gmail.com';
  String nome = '';
  String cpf = '';
  int corAvatar = 0;
  DateTime desde = DateTime(2026, 8, 22);

  static const List<Color> coresAvatar = [
    Color(0xFF6B0F1A),
    Color(0xFF1F5FA8),
    Color(0xFF1E7F4F),
    Color(0xFF7B4BB5),
    Color(0xFFC46A12),
    Color(0xFF3A3A3A),
  ];

  Color get cor => coresAvatar[corAvatar % coresAvatar.length];

  String get iniciais {
    final p =
        nome.trim().split(RegExp(r'\s+')).where((e) => e.isNotEmpty).toList();
    if (p.length >= 2) return (p.first[0] + p.last[0]).toUpperCase();
    if (p.length == 1) {
      return p.first.substring(0, p.first.length >= 2 ? 2 : 1).toUpperCase();
    }
    return 'IN';
  }

  String get tempoDeMembro {
    final n = DateTime.now();
    final m = (n.year - desde.year) * 12 + n.month - desde.month;
    if (m < 1) return 'Membro há menos de 1 mês';
    return 'Membro há $m ${m == 1 ? 'mês' : 'meses'}';
  }

  void entrar(String email, String usuario, {bool novo = false}) {
    if (this.email != email) {
      nome = '';
      cpf = '';
    }
    this.email = email;
    this.usuario = usuario;
    if (novo) desde = DateTime.now();
    notifyListeners();
  }

  void atualizar(
      {String? usuario, String? email, String? nome, String? cpf, int? cor}) {
    if (usuario != null) this.usuario = usuario;
    if (email != null) this.email = email;
    if (nome != null) this.nome = nome;
    if (cpf != null) this.cpf = cpf;
    if (cor != null) corAvatar = cor;
    notifyListeners();
  }
}

final Perfil perfil = Perfil();

class Prefs extends ChangeNotifier {
  final Map<String, bool> _v = {
    'promocoes': true,
    'menorPreco': true,
    'lembretes': true,
    'comentarios': true,
    'emailResumo': false,
    'biometria': false,
    'doisFatores': false,
  };
  bool ler(String k) => _v[k] ?? false;
  void definir(String k, bool val) {
    _v[k] = val;
    notifyListeners();
  }
}

final Prefs prefs = Prefs();

class AuthStore {
  final Map<String, String> _senhas = {'isabela.ngt1@gmail.com': 'receita123'};
  final Map<String, String> _usuarios = {
    'isabela.ngt1@gmail.com': '@isabelangt1'
  };

  String normUsuario(String u) {
    final t = u.trim().toLowerCase().replaceAll(' ', '');
    return t.startsWith('@') ? t : '@$t';
  }

  String? entrar(String email, String senha) {
    if (!_senhas.containsKey(email)) {
      return 'Não encontramos uma conta com esse e-mail. Que tal criar uma?';
    }
    if (_senhas[email] != senha) return 'E-mail ou senha incorretos.';
    perfil.entrar(email, _usuarios[email]!);
    return null;
  }

  String? cadastrar(String usuario, String email, String senha) {
    if (_senhas.containsKey(email)) {
      return 'Esse e-mail já está cadastrado. Tente entrar.';
    }
    final u = normUsuario(usuario);
    if (_usuarios.containsValue(u)) return 'Esse nome de usuário já está em uso.';
    _senhas[email] = senha;
    _usuarios[email] = u;
    perfil.entrar(email, u, novo: true);
    return null;
  }

  String? trocarSenha(String email, String atual, String nova) {
    if (!_senhas.containsKey(email)) {
      return 'Não encontramos uma conta com esse e-mail.';
    }
    if (_senhas[email] != atual) return 'A senha atual está incorreta.';
    _senhas[email] = nova;
    return null;
  }

  void mudarEmail(String velho, String novo) {
    if (_senhas.containsKey(velho)) {
      _senhas[novo] = _senhas.remove(velho)!;
      _usuarios[novo] = _usuarios.remove(velho)!;
    }
  }

  void remover(String email) {
    _senhas.remove(email);
    _usuarios.remove(email);
  }
}

final AuthStore authStore = AuthStore();

/// Publicações salvas
class SalvosStore extends ChangeNotifier {
  void alternar(Promo p) {
    p.salvo = !p.salvo;
    notifyListeners();
  }

  List<Promo> get itens => todasAsPromos.where((p) => p.salvo).toList();
}

final SalvosStore salvosStore = SalvosStore();

List<Promo> get todasAsPromos => [...promosRecentes, ...promosDestaques];

// ============================================================
// VALIDAÇÕES E FORMATAÇÃO
// ============================================================
String? validarEmail(String? v) {
  final t = (v ?? '').trim();
  if (t.isEmpty) return 'Informe seu e-mail';
  if (!RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(t)) return 'E-mail inválido';
  return null;
}

String? validarUsuario(String? v) {
  final t = (v ?? '').trim().replaceFirst('@', '');
  if (t.length < 3 || t.length > 20) return 'Use de 3 a 20 caracteres';
  if (!RegExp(r'^[a-zA-Z0-9._]+$').hasMatch(t)) {
    return 'Só letras, números, ponto e _';
  }
  return null;
}

String? validarSenhaForte(String? v) {
  final t = v ?? '';
  if (t.length < 8) return 'Mínimo de 8 caracteres';
  if (!RegExp(r'[A-Za-z]').hasMatch(t) || !RegExp(r'\d').hasMatch(t)) {
    return 'Use letras e números';
  }
  return null;
}

int forcaSenha(String s) {
  var n = 0;
  if (s.length >= 8) n++;
  if (RegExp(r'[a-z]').hasMatch(s) && RegExp(r'[A-Z]').hasMatch(s)) n++;
  if (RegExp(r'\d').hasMatch(s)) n++;
  if (RegExp(r'[^A-Za-z0-9]').hasMatch(s)) n++;
  return n;
}

bool cpfValido(String cpf) {
  final d = cpf.replaceAll(RegExp(r'\D'), '');
  if (d.length != 11 || RegExp(r'^(\d)\1{10}$').hasMatch(d)) return false;
  int digito(int tamanho) {
    var soma = 0;
    for (var i = 0; i < tamanho; i++) {
      soma += int.parse(d[i]) * (tamanho + 1 - i);
    }
    final r = (soma * 10) % 11;
    return r == 10 ? 0 : r;
  }

  return digito(9) == int.parse(d[9]) && digito(10) == int.parse(d[10]);
}

class CpfFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue o, TextEditingValue n) {
    final d = n.text.replaceAll(RegExp(r'\D'), '');
    final s = d.length > 11 ? d.substring(0, 11) : d;
    final b = StringBuffer();
    for (var i = 0; i < s.length; i++) {
      if (i == 3 || i == 6) b.write('.');
      if (i == 9) b.write('-');
      b.write(s[i]);
    }
    final t = b.toString();
    return TextEditingValue(
        text: t, selection: TextSelection.collapsed(offset: t.length));
  }
}

String _dataHora(DateTime d) {
  String dois(int n) => n.toString().padLeft(2, '0');
  return '${dois(d.day)}/${dois(d.month)}/${d.year} ${dois(d.hour)}:${dois(d.minute)}';
}

void _aviso(BuildContext context, String texto) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
        content: Text(texto), duration: const Duration(seconds: 2)));
}

// ============================================================
// WIDGETS COMPARTILHADOS
// ============================================================
class _Pagina extends StatelessWidget {
  final String titulo;
  final Widget child;
  final PreferredSizeWidget? bottom;
  const _Pagina({required this.titulo, required this.child, this.bottom});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Scaffold(
      backgroundColor: c.fundo,
      appBar: AppBar(
        backgroundColor: c.fundo,
        foregroundColor: c.texto,
        elevation: 0,
        scrolledUnderElevation: 0,
        title: Text(titulo,
            style: TextStyle(
                color: c.texto, fontWeight: FontWeight.w800, fontSize: 20)),
        bottom: bottom,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 410), child: child),
        ),
      ),
    );
  }
}

class _Cartao extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  final EdgeInsets margin;
  const _Cartao(
      {required this.child,
      this.margin = const EdgeInsets.only(bottom: 12)}) : padding = const EdgeInsets.all(14);

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      width: double.infinity,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.borda),
      ),
      child: child,
    );
  }
}

class _BotaoPrimario extends StatelessWidget {
  final String texto;
  final VoidCallback? onTap;
  final IconData? icone;
  const _BotaoPrimario({required this.texto, required this.onTap, this.icone});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: vinho,
          foregroundColor: Colors.white,
          disabledBackgroundColor: vinho.withValues(alpha: .35),
          disabledForegroundColor: Colors.white54,
          elevation: 0,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icone != null) ...[Icon(icone, size: 18), const SizedBox(width: 8)],
            Text(texto,
                style:
                    const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
          ],
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  final String texto;
  final bool ativo;
  final VoidCallback onTap;
  const _Chip({required this.texto, required this.ativo, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
        decoration: BoxDecoration(
          color: ativo ? vinho : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ativo ? vinho : c.borda.withValues(alpha: .4)),
        ),
        child: Text(texto,
            style: TextStyle(
                color: ativo ? Colors.white : c.texto2,
                fontSize: 12.5,
                fontWeight: ativo ? FontWeight.w700 : FontWeight.w400)),
      ),
    );
  }
}

InputDecoration _deco(BuildContext context, String hint,
    {IconData? icone, Widget? sufixo}) {
  final c = context.cores;
  OutlineInputBorder borda(Color cor, [double w = 1]) => OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: cor, width: w));
  return InputDecoration(
    hintText: hint,
    hintStyle: TextStyle(color: c.texto3, fontSize: 14),
    filled: true,
    fillColor: c.campo,
    prefixIcon: icone == null ? null : Icon(icone, size: 20, color: c.texto3),
    suffixIcon: sufixo,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: borda(c.borda),
    enabledBorder: borda(c.borda),
    focusedBorder: borda(vermelhoDestaque, 1.5),
    errorBorder: borda(vermelhoDestaque),
    focusedErrorBorder: borda(vermelhoDestaque, 1.5),
    errorStyle: const TextStyle(color: vermelhoDestaque, fontSize: 11.5),
  );
}

class _AvatarPerfil extends StatelessWidget {
  final double tamanho;
  const _AvatarPerfil({required this.tamanho});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: perfil,
      builder: (_, _) => Container(
        width: tamanho,
        height: tamanho,
        decoration: BoxDecoration(color: perfil.cor, shape: BoxShape.circle),
        alignment: Alignment.center,
        child: Text(perfil.iniciais,
            style: TextStyle(
                color: Colors.white,
                fontSize: tamanho * .42,
                fontWeight: FontWeight.w300,
                letterSpacing: 1)),
      ),
    );
  }
}

// ============================================================
// LOGIN / CADASTRO (nova tela inicial do app)
// ============================================================
class LogoPrincipal extends StatelessWidget {
  final double altura;
  const LogoPrincipal({super.key, this.altura = 160});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return SizedBox(
      height: altura,
      width: double.infinity,
      child: Image.asset(
        assetLogoPrincipal,
        fit: BoxFit.contain,
        // Enquanto você não colocar a imagem, aparece este espaço reservado.
        errorBuilder: (_, _, _) => Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: c.borda, width: 1.5),
          ),
          alignment: Alignment.center,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.image_outlined, size: 36, color: c.texto3),
              const SizedBox(height: 6),
              Text('Espaço da imagem principal',
                  style: TextStyle(color: c.texto2, fontSize: 13)),
              Text(assetLogoPrincipal,
                  style: TextStyle(color: c.texto3, fontSize: 11)),
            ],
          ),
        ),
      ),
    );
  }
}

class AuthPage extends StatefulWidget {
  const AuthPage({super.key});

  @override
  State<AuthPage> createState() => _AuthPageState();
}

class _AuthPageState extends State<AuthPage> {
  final _form = GlobalKey<FormState>();
  final _usuario = TextEditingController();
  final _email = TextEditingController();
  final _senha = TextEditingController();
  final _confirma = TextEditingController();
  bool _cadastro = false;
  bool _ver = false;
  bool _aceito = false;
  String? _erro;

  @override
  void dispose() {
    _usuario.dispose();
    _email.dispose();
    _senha.dispose();
    _confirma.dispose();
    super.dispose();
  }

  void _modo(bool cadastro) => setState(() {
        _cadastro = cadastro;
        _erro = null;
      });

  void _irParaApp() {
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => telaAposLogin()),
      (_) => false,
    );
  }

  void _enviar() {
    setState(() => _erro = null);
    if (!(_form.currentState?.validate() ?? false)) return;
    if (_cadastro && !_aceito) {
      setState(() => _erro =
          'Aceite os Termos de Serviço e a Política de Privacidade para continuar.');
      return;
    }
    final email = _email.text.trim().toLowerCase();
    final erro = _cadastro
        ? authStore.cadastrar(_usuario.text, email, _senha.text)
        : authStore.entrar(email, _senha.text);
    if (erro != null) {
      setState(() => _erro = erro);
      return;
    }
    _irParaApp();
  }

  Future<void> _esqueci() async {
    final r = await showDialog<String>(
      context: context,
      builder: (_) => _DialogoEditar(
        titulo: 'Recuperar senha',
        inicial: _email.text.trim(),
        hint: 'Seu e-mail',
        teclado: TextInputType.emailAddress,
        botao: 'Enviar link',
        validar: validarEmail,
      ),
    );
    if (r != null && mounted) {
      _aviso(context,
          'Se o e-mail estiver cadastrado, você receberá as instruções em instantes.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Scaffold(
      backgroundColor: c.fundo,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned(
                top: -38,
                left: -38,
                child: _bola(105)),
            Positioned(right: -50, bottom: -42, child: _bola(130)),
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 410),
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
                  child: Form(
                    key: _form,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const LogoPrincipal(altura: 170),
                        const SizedBox(height: 22),
                        Text(
                            _cadastro
                                ? 'Crie sua conta'
                                : 'Bem-vindo de volta',
                            style: TextStyle(
                                color: c.texto,
                                fontSize: 24,
                                fontWeight: FontWeight.w800)),
                        const SizedBox(height: 4),
                        Text(
                            _cadastro
                                ? 'Leva menos de um minuto. Escaneou, entendeu, cuidou.'
                                : 'Entre para ver suas promoções e lembretes.',
                            style: TextStyle(color: c.texto2, fontSize: 13.5)),
                        const SizedBox(height: 18),
                        _seletor(c),
                        const SizedBox(height: 18),
                        if (_cadastro) ...[
                          TextFormField(
                            controller: _usuario,
                            validator: validarUsuario,
                            style: TextStyle(color: c.texto),
                            decoration: _deco(context, 'Nome de usuário',
                                icone: Icons.alternate_email),
                          ),
                          const SizedBox(height: 12),
                        ],
                        TextFormField(
                          controller: _email,
                          validator: validarEmail,
                          keyboardType: TextInputType.emailAddress,
                          style: TextStyle(color: c.texto),
                          decoration: _deco(context, 'E-mail',
                              icone: Icons.mail_outline),
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: _senha,
                          obscureText: !_ver,
                          onChanged: (_) => setState(() {}),
                          validator: _cadastro
                              ? validarSenhaForte
                              : (v) => (v ?? '').isEmpty
                                  ? 'Informe sua senha'
                                  : null,
                          style: TextStyle(color: c.texto),
                          decoration: _deco(context, 'Senha',
                              icone: Icons.lock_outline,
                              sufixo: IconButton(
                                icon: Icon(
                                    _ver
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 20,
                                    color: c.texto3),
                                onPressed: () => setState(() => _ver = !_ver),
                              )),
                        ),
                        if (_cadastro) ...[
                          const SizedBox(height: 8),
                          _forca(c),
                          const SizedBox(height: 12),
                          TextFormField(
                            controller: _confirma,
                            obscureText: !_ver,
                            validator: (v) => v != _senha.text
                                ? 'As senhas não conferem'
                                : null,
                            style: TextStyle(color: c.texto),
                            decoration: _deco(context, 'Confirmar senha',
                                icone: Icons.lock_reset),
                          ),
                          const SizedBox(height: 10),
                          _termos(c),
                        ] else
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: _esqueci,
                              child: const Text('Esqueci minha senha',
                                  style: TextStyle(
                                      color: vermelhoDestaque, fontSize: 12.5)),
                            ),
                          ),
                        if (_erro != null) ...[
                          const SizedBox(height: 6),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: vermelhoDestaque.withValues(alpha: .12),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                  color: vermelhoDestaque.withValues(alpha: .6)),
                            ),
                            child: Text(_erro!,
                                style: const TextStyle(
                                    color: vermelhoDestaque, fontSize: 12.5)),
                          ),
                        ],
                        const SizedBox(height: 14),
                        _BotaoPrimario(
                            texto: _cadastro ? 'Criar conta' : 'Entrar',
                            onTap: _enviar),
                        if (!_cadastro) ...[
                          const SizedBox(height: 18),
                          Center(
                            child: Text(
                                'Conta de teste: isabela.ngt1@gmail.com  ·  senha: receita123',
                                textAlign: TextAlign.center,
                                style:
                                    TextStyle(color: c.texto3, fontSize: 11)),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _bola(double s) => Container(
      width: s,
      height: s,
      decoration: const BoxDecoration(color: vinho, shape: BoxShape.circle));

  Widget _seletor(Cores c) {
    Widget aba(String t, bool ativo, VoidCallback onTap) => Expanded(
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(10),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 160),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: ativo ? vinho : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              alignment: Alignment.center,
              child: Text(t,
                  style: TextStyle(
                      color: ativo ? Colors.white : c.texto2,
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5)),
            ),
          ),
        );
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: c.campo,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.borda),
      ),
      child: Row(children: [
        aba('Entrar', !_cadastro, () => _modo(false)),
        aba('Cadastre-se', _cadastro, () => _modo(true)),
      ]),
    );
  }

  Widget _forca(Cores c) {
    final f = forcaSenha(_senha.text);
    const rotulos = ['Muito fraca', 'Fraca', 'Razoável', 'Boa', 'Forte'];
    final cores = [
      vermelhoDestaque,
      vermelhoDestaque,
      const Color(0xFFF2A93B),
      verdeOk,
      verdeOk
    ];
    final idx = _senha.text.isEmpty ? 0 : f;
    return Row(children: [
      for (var i = 0; i < 4; i++)
        Expanded(
          child: Container(
            height: 4,
            margin: const EdgeInsets.only(right: 4),
            decoration: BoxDecoration(
              color: (_senha.text.isNotEmpty && i < f)
                  ? cores[idx]
                  : c.borda,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ),
      const SizedBox(width: 6),
      Text(_senha.text.isEmpty ? 'Mín. 8 caracteres' : rotulos[idx],
          style: TextStyle(color: c.texto3, fontSize: 11)),
    ]);
  }

  Widget _termos(Cores c) {
    Widget link(String t, Widget pagina) => InkWell(
          onTap: () => Navigator.of(context)
              .push(MaterialPageRoute(builder: (_) => pagina)),
          child: Text(t,
              style: const TextStyle(
                  color: vermelhoDestaque,
                  fontSize: 12.5,
                  decoration: TextDecoration.underline)),
        );
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 28,
          child: Checkbox(
            value: _aceito,
            activeColor: vinho,
            side: BorderSide(color: c.texto3),
            onChanged: (v) => setState(() => _aceito = v ?? false),
          ),
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Wrap(
              children: [
                Text('Li e aceito os ',
                    style: TextStyle(color: c.texto2, fontSize: 12.5)),
                link('Termos de Serviço', DocumentoPage(doc: docTermos)),
                Text(' e a ',
                    style: TextStyle(color: c.texto2, fontSize: 12.5)),
                link('Política de Privacidade',
                    DocumentoPage(doc: docPrivacidade)),
                Text('.', style: TextStyle(color: c.texto2, fontSize: 12.5)),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DIÁLOGO GENÉRICO DE EDIÇÃO (um campo)
// ============================================================
class _DialogoEditar extends StatefulWidget {
  final String titulo;
  final String inicial;
  final String hint;
  final String botao;
  final TextInputType? teclado;
  final List<TextInputFormatter>? formatadores;
  final String? Function(String?) validar;
  const _DialogoEditar({
    required this.titulo,
    required this.inicial,
    required this.hint,
    required this.validar,
    this.botao = 'Salvar',
    this.teclado,
    this.formatadores,
  });

  @override
  State<_DialogoEditar> createState() => _DialogoEditarState();
}

class _DialogoEditarState extends State<_DialogoEditar> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _ctrl =
      TextEditingController(text: widget.inicial);

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return AlertDialog(
      backgroundColor: c.card,
      title: Text(widget.titulo,
          style: TextStyle(
              color: c.texto, fontSize: 17, fontWeight: FontWeight.w800)),
      content: Form(
        key: _form,
        child: TextFormField(
          controller: _ctrl,
          autofocus: true,
          keyboardType: widget.teclado,
          inputFormatters: widget.formatadores,
          validator: widget.validar,
          style: TextStyle(color: c.texto),
          decoration: _deco(context, widget.hint),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancelar', style: TextStyle(color: c.texto2))),
        TextButton(
          onPressed: () {
            if (_form.currentState?.validate() ?? false) {
              Navigator.pop(context, _ctrl.text.trim());
            }
          },
          child: Text(widget.botao,
              style: const TextStyle(
                  color: vermelhoDestaque, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ============================================================
// MENU LATERAL
// ============================================================
class MenuLateral extends StatefulWidget {
  const MenuLateral({super.key});

  @override
  State<MenuLateral> createState() => _MenuLateralState();
}

class _MenuLateralState extends State<MenuLateral> {
  bool _temasAberto = false;

  void _ir(Widget pagina) {
    final nav = Navigator.of(context);
    nav.pop(); // fecha o menu
    nav.push(MaterialPageRoute(builder: (_) => pagina));
  }

  Future<void> _sair() async {
    final nav = Navigator.of(context);
    final c = context.cores;
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        title: Text('Sair da conta?',
            style: TextStyle(color: c.texto, fontWeight: FontWeight.w800)),
        content: Text('Você precisará entrar novamente para ver suas promoções.',
            style: TextStyle(color: c.texto2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: Text('Cancelar', style: TextStyle(color: c.texto2))),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Sair',
                  style: TextStyle(
                      color: vermelhoDestaque, fontWeight: FontWeight.w700))),
        ],
      ),
    );
    if (ok == true) {
      nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthPage()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Drawer(
      width: 300,
      backgroundColor: c.menu,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.horizontal(right: Radius.circular(24)),
      ),
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
          children: [
            Align(
                alignment: Alignment.centerLeft,
                child: const _AvatarPerfil(tamanho: 58)),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: perfil,
              builder: (_, _) => Text(perfil.usuario,
                  style: TextStyle(
                      color: c.texto,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
            ),
            const SizedBox(height: 22),
            _MenuItem(
                icone: Icons.person,
                texto: 'Meu perfil',
                onTap: () => _ir(const PerfilPage())),
            _MenuItem(
              icone: Icons.wb_sunny_outlined,
              texto: 'Temas',
              trailing: Icon(
                  _temasAberto
                      ? Icons.keyboard_arrow_up
                      : Icons.keyboard_arrow_down,
                  color: c.texto,
                  size: 22),
              onTap: () => setState(() => _temasAberto = !_temasAberto),
            ),
            AnimatedSize(
              duration: const Duration(milliseconds: 180),
              curve: Curves.easeOut,
              alignment: Alignment.topCenter,
              child: _temasAberto
                  ? ValueListenableBuilder<String>(
                      valueListenable: temaEscolhido,
                      builder: (_, atual, _) => Column(children: [
                        _opcaoTema('Automático', Icons.brightness_auto,
                            'Segue o tema do celular', atual, c),
                        _opcaoTema('Claro', Icons.light_mode_outlined, null,
                            atual, c),
                        _opcaoTema('Escuro', Icons.dark_mode_outlined, null,
                            atual, c),
                      ]),
                    )
                  : const SizedBox(width: double.infinity),
            ),
            _MenuItem(
                icone: Icons.settings_outlined,
                texto: 'Configurações',
                onTap: () => _ir(const ConfiguracoesPage())),
            _MenuItem(
                icone: Icons.chat_bubble_outline,
                texto: 'Fale com a ReceitaCerta',
                onTap: () => _ir(const SuportePage())),
            AnimatedBuilder(
              animation: salvosStore,
              builder: (_, _) => _MenuItem(
                icone: Icons.bookmark_border,
                texto: 'Publicações Salvas',
                badge: salvosStore.itens.length,
                onTap: () => _ir(const SalvasPage()),
              ),
            ),
            _MenuItem(
                icone: Icons.groups_outlined,
                texto: 'Nossa equipe',
                onTap: () => _ir(const EquipePage())),
            _MenuItem(
                icone: Icons.feedback,
                texto: 'Deixe o seu feedback!',
                onTap: () => _ir(const FeedbackPage())),
            const SizedBox(height: 14),
            _MenuLink('Central de Ajuda', onTap: () => _ir(const AjudaPage())),
            _MenuLink('Termos de Serviços',
                onTap: () => _ir(DocumentoPage(doc: docTermos))),
            _MenuLink('Código de Conduta',
                onTap: () => _ir(DocumentoPage(doc: docConduta))),
            _MenuLink('Privacidade',
                onTap: () => _ir(DocumentoPage(doc: docPrivacidade))),
            _MenuLink('Regras da comunidade',
                onTap: () => _ir(DocumentoPage(doc: docComunidade))),
            _MenuLink('Sair', cor: Colors.red, onTap: _sair),
          ],
        ),
      ),
    );
  }

  Widget _opcaoTema(
      String t, IconData icone, String? sub, String atual, Cores c) {
    final sel = atual == t;
    return InkWell(
      onTap: () => temaEscolhido.value = t,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(36, 9, 6, 9),
        child: Row(children: [
          Icon(icone, size: 18, color: c.texto2),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(t,
                    style: TextStyle(
                        color: c.texto,
                        fontSize: 13,
                        fontWeight: sel ? FontWeight.w800 : FontWeight.w400)),
                if (sub != null)
                  Text(sub, style: TextStyle(color: c.texto3, fontSize: 10.5)),
              ],
            ),
          ),
          if (sel) const Icon(Icons.check, color: verdeOk, size: 18),
        ]),
      ),
    );
  }
}

class _MenuItem extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;
  final Widget? trailing;
  final int badge;
  const _MenuItem(
      {required this.icone,
      required this.texto,
      required this.onTap,
      this.trailing,
      this.badge = 0});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Row(children: [
          Icon(icone, size: 24, color: c.iconeMenu),
          const SizedBox(width: 12),
          Text(texto, style: TextStyle(color: c.texto, fontSize: 13.5)),
          if (badge > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 1),
              decoration: BoxDecoration(
                  color: vermelhoDestaque,
                  borderRadius: BorderRadius.circular(9)),
              child: Text('$badge',
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700)),
            ),
          ],
          if (trailing != null) ...[const SizedBox(width: 6), trailing!],
        ]),
      ),
    );
  }
}

class _MenuLink extends StatelessWidget {
  final String texto;
  final VoidCallback onTap;
  final Color? cor;
  const _MenuLink(this.texto, {required this.onTap, this.cor});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 9),
        child: Text(texto,
            style: TextStyle(color: cor ?? context.cores.texto, fontSize: 13)),
      ),
    );
  }
}

// ============================================================
// MEU PERFIL
// ============================================================
class PerfilPage extends StatefulWidget {
  const PerfilPage({super.key});

  @override
  State<PerfilPage> createState() => _PerfilPageState();
}

class _PerfilPageState extends State<PerfilPage> {
  Future<void> _abrir(Widget pagina) async {
    await Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => pagina));
    if (mounted) setState(() {});
  }

  void _trocarCor() {
    final c = context.cores;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cor do avatar',
                style: TextStyle(
                    color: c.texto, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 4),
            Text('Em breve você poderá enviar uma foto sua.',
                style: TextStyle(color: c.texto3, fontSize: 12)),
            const SizedBox(height: 16),
            Wrap(
              spacing: 14,
              runSpacing: 14,
              children: [
                for (var i = 0; i < Perfil.coresAvatar.length; i++)
                  GestureDetector(
                    onTap: () {
                      perfil.atualizar(cor: i);
                      Navigator.pop(ctx);
                    },
                    child: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: Perfil.coresAvatar[i],
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: perfil.corAvatar == i
                                ? vermelhoDestaque
                                : Colors.transparent,
                            width: 3),
                      ),
                      child: perfil.corAvatar == i
                          ? const Icon(Icons.check, color: Colors.white)
                          : null,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _compartilhar() {
    final c = context.cores;
    final link =
        'receitacerta.app/u/${perfil.usuario.replaceFirst('@', '')}'; // exemplo
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Compartilhar perfil',
                style: TextStyle(
                    color: c.texto, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                  color: c.campo, borderRadius: BorderRadius.circular(10)),
              child: Text(link, style: TextStyle(color: c.texto2)),
            ),
            const SizedBox(height: 14),
            _BotaoPrimario(
              texto: 'Copiar link',
              icone: Icons.copy,
              onTap: () {
                Clipboard.setData(ClipboardData(text: link));
                Navigator.pop(ctx);
                _aviso(context, 'Link copiado!');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final todas = todasAsPromos;
    final curtidas = todas.where((p) => p.curtiu).length;
    final comentarios = todas.fold<int>(
        0,
        (s, p) =>
            s + p.comentarios.where((x) => x.usuario == usuarioLogado).length);
    final salvos = salvosStore.itens.length;

    return Scaffold(
      backgroundColor: c.fundo,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 410),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                Row(children: [
                  IconButton(
                    icon: Icon(Icons.chevron_left, size: 34, color: c.texto2),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Spacer(),
                  InkWell(
                    onTap: _compartilhar,
                    customBorder: const CircleBorder(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: const Color(0xFF25D366).withValues(alpha: .15),
                        border: Border.all(color: c.borda),
                      ),
                      child: const Icon(Icons.share,
                          size: 20, color: Color(0xFF25D366)),
                    ),
                  ),
                ]),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      const _AvatarPerfil(tamanho: 120),
                      Positioned(
                        right: -4,
                        top: 0,
                        child: InkWell(
                          onTap: _trocarCor,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 38,
                            height: 38,
                            decoration: BoxDecoration(
                              color: c.card,
                              shape: BoxShape.circle,
                              border: Border.all(color: c.borda),
                            ),
                            child: Icon(Icons.photo_camera,
                                size: 19, color: c.texto2),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                AnimatedBuilder(
                  animation: perfil,
                  builder: (_, _) => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(perfil.usuario,
                          style: TextStyle(
                              color: c.texto,
                              fontSize: 28,
                              fontWeight: FontWeight.w800)),
                      if (perfil.nome.isNotEmpty)
                        Text(perfil.nome,
                            style: TextStyle(color: c.texto2, fontSize: 14)),
                      const SizedBox(height: 4),
                      Row(children: [
                        Icon(Icons.calendar_month_outlined,
                            size: 15, color: c.texto3),
                        const SizedBox(width: 5),
                        Text(perfil.tempoDeMembro,
                            style: TextStyle(color: c.texto3, fontSize: 12)),
                      ]),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 46,
                  child: OutlinedButton.icon(
                    onPressed: () => _abrir(const ConfiguracoesPage()),
                    icon: const Icon(Icons.edit_note,
                        size: 20, color: vermelhoDestaque),
                    label: const Text('Editar perfil',
                        style: TextStyle(
                            color: vermelhoDestaque,
                            fontWeight: FontWeight.w700)),
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: c.borda.withValues(alpha: .5)),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(23)),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Divider(color: c.borda),
                const SizedBox(height: 14),
                Text('Minha atividade',
                    style: TextStyle(
                        color: c.texto,
                        fontSize: 15,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 10),
                Row(children: [
                  _Estat('Curtidas', '$curtidas', Icons.thumb_up_alt_outlined),
                  const SizedBox(width: 10),
                  _Estat('Comentários', '$comentarios',
                      Icons.chat_bubble_outline),
                  const SizedBox(width: 10),
                  _Estat('Salvos', '$salvos', Icons.bookmark_border),
                ]),
                const SizedBox(height: 18),
                _AtalhoPerfil(
                    icone: Icons.bookmark_border,
                    texto: 'Publicações salvas',
                    onTap: () => _abrir(const SalvasPage())),
                _AtalhoPerfil(
                    icone: Icons.settings_outlined,
                    texto: 'Configurações da conta',
                    onTap: () => _abrir(const ConfiguracoesPage())),
                _AtalhoPerfil(
                    icone: Icons.feedback_outlined,
                    texto: 'Enviar feedback',
                    onTap: () => _abrir(const FeedbackPage())),
                _AtalhoPerfil(
                    icone: Icons.support_agent,
                    texto: 'Fale com a ReceitaCerta',
                    onTap: () => _abrir(const SuportePage())),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Estat extends StatelessWidget {
  final String rotulo;
  final String valor;
  final IconData icone;
  const _Estat(this.rotulo, this.valor, this.icone);

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: c.card,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: c.borda),
        ),
        child: Column(children: [
          Icon(icone, size: 20, color: vermelhoDestaque),
          const SizedBox(height: 6),
          Text(valor,
              style: TextStyle(
                  color: c.texto, fontSize: 20, fontWeight: FontWeight.w800)),
          Text(rotulo, style: TextStyle(color: c.texto3, fontSize: 11)),
        ]),
      ),
    );
  }
}

class _AtalhoPerfil extends StatelessWidget {
  final IconData icone;
  final String texto;
  final VoidCallback onTap;
  const _AtalhoPerfil(
      {required this.icone, required this.texto, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Icon(icone, color: c.iconeMenu),
      title: Text(texto, style: TextStyle(color: c.texto, fontSize: 14)),
      trailing: Icon(Icons.chevron_right, color: c.texto3),
      onTap: onTap,
    );
  }
}

// ============================================================
// CONFIGURAÇÕES (Meus dados / Notificações / Segurança)
// ============================================================
class ConfiguracoesPage extends StatelessWidget {
  const ConfiguracoesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Tab aba(IconData i, String t) => Tab(
          height: 46,
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(i, size: 16),
            const SizedBox(width: 5),
            Text(t),
          ]),
        );
    return DefaultTabController(
      length: 3,
      child: _Pagina(
        titulo: 'Configurações',
        bottom: TabBar(
          indicatorColor: vermelhoDestaque,
          labelColor: c.texto,
          unselectedLabelColor: c.texto3,
          dividerColor: c.borda,
          labelStyle:
              const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
          tabs: [
            aba(Icons.person_outline, 'Meus dados'),
            aba(Icons.notifications_none, 'Notificações'),
            aba(Icons.shield_outlined, 'Segurança'),
          ],
        ),
        child: const TabBarView(children: [
          _AbaDados(),
          _AbaNotificacoes(),
          _AbaSeguranca(),
        ]),
      ),
    );
  }
}

class _CampoEditavel extends StatelessWidget {
  final String rotulo;
  final String valor;
  final String vazio;
  final VoidCallback onEditar;
  const _CampoEditavel(
      {required this.rotulo,
      required this.valor,
      required this.vazio,
      required this.onEditar});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(rotulo, style: TextStyle(color: c.texto2, fontSize: 12)),
          const SizedBox(height: 5),
          InkWell(
            onTap: onEditar,
            borderRadius: BorderRadius.circular(14),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: c.borda.withValues(alpha: .5)),
              ),
              child: Row(children: [
                Expanded(
                  child: Text(valor.isEmpty ? vazio : valor,
                      style: TextStyle(
                          color: valor.isEmpty ? c.texto3 : c.texto,
                          fontSize: 16)),
                ),
                Icon(Icons.edit_note, color: c.texto2),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _AbaDados extends StatelessWidget {
  const _AbaDados();

  Future<String?> _pedir(BuildContext context,
      {required String titulo,
      required String inicial,
      required String hint,
      required String? Function(String?) validar,
      TextInputType? teclado,
      List<TextInputFormatter>? fmt}) {
    return showDialog<String>(
      context: context,
      builder: (_) => _DialogoEditar(
          titulo: titulo,
          inicial: inicial,
          hint: hint,
          validar: validar,
          teclado: teclado,
          formatadores: fmt),
    );
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return AnimatedBuilder(
      animation: perfil,
      builder: (_, _) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          Text('Meus dados',
              style: TextStyle(
                  color: c.texto, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 2),
          Text(
              'Toque no lápis para alterar. Para mudanças que não aparecem aqui, fale com o suporte.',
              style: TextStyle(color: c.texto3, fontSize: 11.5)),
          const SizedBox(height: 18),
          Row(children: [
            const Icon(Icons.person, color: vinho, size: 24),
            const SizedBox(width: 8),
            Text('Perfil',
                style: TextStyle(
                    color: c.texto, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          _CampoEditavel(
            rotulo: 'Nome de usuário na ReceitaCerta',
            valor: perfil.usuario.replaceFirst('@', ''),
            vazio: 'usuario',
            onEditar: () async {
              final r = await _pedir(context,
                  titulo: 'Nome de usuário',
                  inicial: perfil.usuario.replaceFirst('@', ''),
                  hint: 'Ex.: maria.silva',
                  validar: validarUsuario);
              if (r != null) perfil.atualizar(usuario: authStore.normUsuario(r));
            },
          ),
          _CampoEditavel(
            rotulo: 'E-mail',
            valor: perfil.email,
            vazio: 'seu@email.com',
            onEditar: () async {
              final r = await _pedir(context,
                  titulo: 'E-mail',
                  inicial: perfil.email,
                  hint: 'seu@email.com',
                  teclado: TextInputType.emailAddress,
                  validar: validarEmail);
              if (r != null) {
                final novo = r.toLowerCase();
                authStore.mudarEmail(perfil.email, novo);
                perfil.atualizar(email: novo);
              }
            },
          ),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.badge_outlined, color: vinho, size: 24),
            const SizedBox(width: 8),
            Text('Dados pessoais',
                style: TextStyle(
                    color: c.texto, fontWeight: FontWeight.w700, fontSize: 14)),
          ]),
          const SizedBox(height: 12),
          _CampoEditavel(
            rotulo: 'Nome completo',
            valor: perfil.nome,
            vazio: 'Nome completo',
            onEditar: () async {
              final r = await _pedir(context,
                  titulo: 'Nome completo',
                  inicial: perfil.nome,
                  hint: 'Nome e sobrenome',
                  validar: (v) => (v ?? '').trim().split(' ').length < 2
                      ? 'Informe nome e sobrenome'
                      : null);
              if (r != null) perfil.atualizar(nome: r);
            },
          ),
          _CampoEditavel(
            rotulo: 'CPF',
            valor: perfil.cpf,
            vazio: '000.000.000-00',
            onEditar: () async {
              final r = await _pedir(context,
                  titulo: 'CPF',
                  inicial: perfil.cpf,
                  hint: '000.000.000-00',
                  teclado: TextInputType.number,
                  fmt: [CpfFormatter()],
                  validar: (v) =>
                      cpfValido(v ?? '') ? null : 'CPF inválido');
              if (r != null) perfil.atualizar(cpf: r);
            },
          ),
          Text(
              'Seus dados pessoais são usados só para a sua conta e protegidos conforme a nossa Política de Privacidade.',
              style: TextStyle(color: c.texto3, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _AbaNotificacoes extends StatelessWidget {
  const _AbaNotificacoes();

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget linha(String k, String titulo, String sub, IconData i) =>
        SwitchListTile(
          value: prefs.ler(k),
          onChanged: (v) => prefs.definir(k, v),
          activeThumbColor: Colors.white,
          activeTrackColor: verdeOk,
          contentPadding: EdgeInsets.zero,
          secondary: Icon(i, color: c.iconeMenu),
          title: Text(titulo,
              style: TextStyle(
                  color: c.texto, fontSize: 14, fontWeight: FontWeight.w600)),
          subtitle:
              Text(sub, style: TextStyle(color: c.texto3, fontSize: 11.5)),
        );
    return AnimatedBuilder(
      animation: prefs,
      builder: (_, _) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          Text('Notificações',
              style: TextStyle(
                  color: c.texto, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _Cartao(
            child: Column(children: [
              linha('promocoes', 'Promoções perto de você',
                  'Descontos novos nas farmácias próximas', Icons.local_offer_outlined),
              linha('menorPreco', 'Menor preço encontrado',
                  'Quando um remédio salvo ficar mais barato', Icons.trending_down),
              linha('lembretes', 'Lembretes de medicamentos',
                  'Aviso na hora de tomar o remédio', Icons.alarm),
              linha('comentarios', 'Comentários',
                  'Respostas e novidades nas suas publicações', Icons.chat_bubble_outline),
              linha('emailResumo', 'Resumo por e-mail',
                  'Um resumo semanal das melhores ofertas', Icons.mail_outline),
            ]),
          ),
          Text(
              'Lembretes de medicamento são importantes para o seu tratamento. Se desativar, lembre-se de anotar os horários de outra forma.',
              style: TextStyle(color: c.texto3, fontSize: 11.5)),
        ],
      ),
    );
  }
}

class _AbaSeguranca extends StatelessWidget {
  const _AbaSeguranca();

  Future<void> _alterarSenha(BuildContext context) async {
    final ok = await showDialog<bool>(
        context: context, builder: (_) => const _DialogoSenha());
    if (ok == true && context.mounted) _aviso(context, 'Senha alterada com sucesso.');
  }

  void _dispositivos(BuildContext context) {
    final c = context.cores;
    showModalBottomSheet(
      context: context,
      backgroundColor: c.card,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Dispositivos conectados',
                style: TextStyle(
                    color: c.texto, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.smartphone, color: verdeOk),
              title: Text('Este aparelho',
                  style: TextStyle(color: c.texto, fontSize: 14)),
              subtitle: Text('Ativo agora',
                  style: TextStyle(color: c.texto3, fontSize: 12)),
            ),
            Text('Dados de exemplo. Na versão final, listaremos seus acessos reais.',
                style: TextStyle(color: c.texto3, fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Future<void> _excluir(BuildContext context) async {
    final c = context.cores;
    final nav = Navigator.of(context);
    final ctrl = TextEditingController();
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setS) => AlertDialog(
          backgroundColor: c.card,
          title: Text('Excluir conta',
              style: TextStyle(color: c.texto, fontWeight: FontWeight.w800)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  'Essa ação é permanente. Seus dados, comentários e publicações salvas serão removidos. Digite EXCLUIR para confirmar.',
                  style: TextStyle(color: c.texto2, fontSize: 13)),
              const SizedBox(height: 12),
              TextField(
                controller: ctrl,
                onChanged: (_) => setS(() {}),
                style: TextStyle(color: c.texto),
                decoration: _deco(ctx, 'EXCLUIR'),
              ),
            ],
          ),
          actions: [
            TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: Text('Cancelar', style: TextStyle(color: c.texto2))),
            TextButton(
                onPressed: ctrl.text.trim().toUpperCase() == 'EXCLUIR'
                    ? () => Navigator.pop(ctx, true)
                    : null,
                child: const Text('Excluir',
                    style: TextStyle(
                        color: vermelhoDestaque, fontWeight: FontWeight.w700))),
          ],
        ),
      ),
    );
    ctrl.dispose();
    if (ok == true) {
      authStore.remover(perfil.email);
      for (final p in todasAsPromos) {
        p.salvo = false;
        p.curtiu = false;
        p.naoCurtiu = false;
      }
      nav.pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const AuthPage()), (_) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    Widget acao(IconData i, String t, String sub, VoidCallback onTap,
            {Color? cor}) =>
        ListTile(
          contentPadding: EdgeInsets.zero,
          leading: Icon(i, color: cor ?? c.iconeMenu),
          title: Text(t,
              style: TextStyle(
                  color: cor ?? c.texto,
                  fontSize: 14,
                  fontWeight: FontWeight.w600)),
          subtitle:
              Text(sub, style: TextStyle(color: c.texto3, fontSize: 11.5)),
          trailing: Icon(Icons.chevron_right, color: c.texto3),
          onTap: onTap,
        );
    return AnimatedBuilder(
      animation: prefs,
      builder: (_, _) => ListView(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 32),
        children: [
          Text('Segurança',
              style: TextStyle(
                  color: c.texto, fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 14),
          _Cartao(
            child: Column(children: [
              acao(Icons.password, 'Alterar senha',
                  'Use uma senha forte e única', () => _alterarSenha(context)),
              SwitchListTile(
                value: prefs.ler('biometria'),
                onChanged: (v) => prefs.definir('biometria', v),
                activeThumbColor: Colors.white,
                activeTrackColor: verdeOk,
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.fingerprint, color: c.iconeMenu),
                title: Text('Entrar com biometria',
                    style: TextStyle(
                        color: c.texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                subtitle: Text('Digital ou rosto, quando o aparelho permitir',
                    style: TextStyle(color: c.texto3, fontSize: 11.5)),
              ),
              SwitchListTile(
                value: prefs.ler('doisFatores'),
                onChanged: (v) => prefs.definir('doisFatores', v),
                activeThumbColor: Colors.white,
                activeTrackColor: verdeOk,
                contentPadding: EdgeInsets.zero,
                secondary: Icon(Icons.verified_user_outlined, color: c.iconeMenu),
                title: Text('Verificação em duas etapas',
                    style: TextStyle(
                        color: c.texto,
                        fontSize: 14,
                        fontWeight: FontWeight.w600)),
                subtitle: Text('Pede um código extra ao entrar',
                    style: TextStyle(color: c.texto3, fontSize: 11.5)),
              ),
              acao(Icons.devices, 'Dispositivos conectados',
                  'Veja onde sua conta está aberta', () => _dispositivos(context)),
            ]),
          ),
          Text('Privacidade e dados',
              style: TextStyle(
                  color: c.texto, fontSize: 15, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          _Cartao(
            child: Column(children: [
              acao(Icons.download_outlined, 'Baixar meus dados',
                  'Direito de acesso previsto na LGPD', () {
                _aviso(context,
                    'Pedido registrado. Enviaremos seus dados para ${perfil.email}.');
              }),
              acao(Icons.policy_outlined, 'Política de Privacidade',
                  'Como cuidamos das suas informações', () {
                Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => DocumentoPage(doc: docPrivacidade)));
              }),
              acao(Icons.delete_forever_outlined, 'Excluir conta',
                  'Remove sua conta e seus dados', () => _excluir(context),
                  cor: vermelhoDestaque),
            ]),
          ),
        ],
      ),
    );
  }
}

class _DialogoSenha extends StatefulWidget {
  const _DialogoSenha();

  @override
  State<_DialogoSenha> createState() => _DialogoSenhaState();
}

class _DialogoSenhaState extends State<_DialogoSenha> {
  final _form = GlobalKey<FormState>();
  final _atual = TextEditingController();
  final _nova = TextEditingController();
  final _conf = TextEditingController();
  String? _erro;

  @override
  void dispose() {
    _atual.dispose();
    _nova.dispose();
    _conf.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return AlertDialog(
      backgroundColor: c.card,
      title: Text('Alterar senha',
          style: TextStyle(
              color: c.texto, fontSize: 17, fontWeight: FontWeight.w800)),
      content: SingleChildScrollView(
        child: Form(
          key: _form,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _atual,
              obscureText: true,
              validator: (v) =>
                  (v ?? '').isEmpty ? 'Informe a senha atual' : null,
              style: TextStyle(color: c.texto),
              decoration: _deco(context, 'Senha atual'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _nova,
              obscureText: true,
              validator: validarSenhaForte,
              style: TextStyle(color: c.texto),
              decoration: _deco(context, 'Nova senha'),
            ),
            const SizedBox(height: 10),
            TextFormField(
              controller: _conf,
              obscureText: true,
              validator: (v) =>
                  v != _nova.text ? 'As senhas não conferem' : null,
              style: TextStyle(color: c.texto),
              decoration: _deco(context, 'Confirmar nova senha'),
            ),
            if (_erro != null) ...[
              const SizedBox(height: 8),
              Text(_erro!,
                  style: const TextStyle(
                      color: vermelhoDestaque, fontSize: 12)),
            ],
          ]),
        ),
      ),
      actions: [
        TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text('Cancelar', style: TextStyle(color: c.texto2))),
        TextButton(
          onPressed: () {
            if (!(_form.currentState?.validate() ?? false)) return;
            final e = authStore.trocarSenha(perfil.email, _atual.text, _nova.text);
            if (e != null) {
              setState(() => _erro = e);
            } else {
              Navigator.pop(context, true);
            }
          },
          child: const Text('Alterar',
              style: TextStyle(
                  color: vermelhoDestaque, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }
}

// ============================================================
// FALE COM A RECEITACERTA (suporte)
// ============================================================
class Faq {
  final String cat;
  final String p;
  final String r;
  const Faq(this.cat, this.p, this.r);
}

const List<Faq> _faqs = [
  Faq('Conta', 'Como crio minha conta?',
      'Na tela inicial, toque em "Cadastre-se", escolha um nome de usuário, informe e-mail e senha e aceite os Termos.'),
  Faq('Conta', 'Esqueci minha senha. E agora?',
      'Na tela de entrada, toque em "Esqueci minha senha", informe seu e-mail e siga as instruções que enviaremos.'),
  Faq('Receitas', 'Como escaneio minha receita?',
      'Toque no botão "+" no centro da barra inferior, fotografe a receita com boa luz e sem sombras, e confira os medicamentos identificados.'),
  Faq('Receitas', 'O app identificou um medicamento errado. O que faço?',
      'A leitura automática pode errar, principalmente com letra manuscrita. Sempre confira com a receita original e, na dúvida, pergunte ao médico ou farmacêutico.'),
  Faq('Receitas', 'O Receita Certa substitui meu médico ou farmacêutico?',
      'Não. O app traz informação educativa para ajudar você a entender e organizar o tratamento. Dose, horário e troca de medicamento só com orientação profissional.'),
  Faq('Preços', 'Por que o preço na farmácia é diferente do app?',
      'Preços e promoções mudam e podem variar por loja. Os valores do app são referências, então confirme na farmácia antes de comprar.'),
  Faq('Preços', 'Como comparo preços entre farmácias?',
      'Em cada promoção, toque em "Ver mais" e abra "Comparar preços". O menor valor aparece destacado.'),
  Faq('Lembretes', 'Como crio um lembrete de medicamento?',
      'Abra a aba "Lembretes" na barra inferior, escolha o remédio e defina os horários. O app avisa na hora certa.'),
  Faq('Lembretes', 'Não estou recebendo as notificações.',
      'Confira em Configurações > Notificações se os lembretes estão ativados e, nos ajustes do celular, se o Receita Certa tem permissão para enviar avisos.'),
  Faq('Privacidade', 'Minhas receitas ficam salvas?',
      'Receitas contêm dados de saúde, que são sensíveis. Só tratamos esses dados com a sua autorização e para o funcionamento do app. Detalhes na Política de Privacidade.'),
  Faq('Privacidade', 'Como excluo minha conta e meus dados?',
      'Vá em Configurações > Segurança > Excluir conta. Você também pode pedir uma cópia dos seus dados na mesma tela.'),
];

class Chamado {
  final String protocolo;
  final String assunto;
  final String mensagem;
  final DateTime data;
  Chamado(this.protocolo, this.assunto, this.mensagem, this.data);
}

final List<Chamado> chamados = [];

class SuportePage extends StatefulWidget {
  const SuportePage({super.key});

  @override
  State<SuportePage> createState() => _SuportePageState();
}

class _SuportePageState extends State<SuportePage> {
  final _busca = TextEditingController();
  String _cat = 'Todas';
  static const _cats = [
    'Todas',
    'Conta',
    'Receitas',
    'Preços',
    'Lembretes',
    'Privacidade'
  ];

  @override
  void dispose() {
    _busca.dispose();
    super.dispose();
  }

  void _copiar(String texto, String msg) {
    Clipboard.setData(ClipboardData(text: texto));
    _aviso(context, msg);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    final q = normalizar(_busca.text.trim());
    final lista = _faqs
        .where((f) =>
            (_cat == 'Todas' || f.cat == _cat) &&
            (q.isEmpty || normalizar('${f.p} ${f.r}').contains(q)))
        .toList();

    return _Pagina(
      titulo: 'Fale com a ReceitaCerta',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('Como podemos ajudar?',
              style: TextStyle(
                  color: c.texto, fontSize: 22, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          TextField(
            controller: _busca,
            onChanged: (_) => setState(() {}),
            style: TextStyle(color: c.texto),
            decoration: _deco(context, 'Buscar uma dúvida...',
                icone: Icons.search,
                sufixo: _busca.text.isEmpty
                    ? null
                    : IconButton(
                        icon: Icon(Icons.close, size: 18, color: c.texto3),
                        onPressed: () => setState(_busca.clear))),
          ),
          const SizedBox(height: 16),
          Row(children: [
            _Canal(
                icone: Icons.smart_toy_outlined,
                titulo: 'Assistente',
                sub: 'Resposta na hora',
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => const ChatbotPage()))),
            const SizedBox(width: 8),
            _Canal(
                icone: Icons.mail_outline,
                titulo: 'E-mail',
                sub: 'Toque para copiar',
                onTap: () => _copiar(emailSuporte, 'E-mail copiado!')),
            const SizedBox(width: 8),
            _Canal(
                icone: Icons.phone_outlined,
                titulo: 'Telefone',
                sub: 'Toque para copiar',
                onTap: () => _copiar(telefoneSuporte, 'Telefone copiado!')),
          ]),
          const SizedBox(height: 10),
          Text('Atendimento humano: seg a sex, 9h às 18h.',
              style: TextStyle(color: c.texto3, fontSize: 11.5)),
          const SizedBox(height: 14),
          _BotaoPrimario(
            texto: 'Abrir um chamado',
            icone: Icons.edit_outlined,
            onTap: () async {
              await Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const NovoChamadoPage()));
              if (mounted) setState(() {});
            },
          ),
          const SizedBox(height: 20),
          Text('Dúvidas frequentes',
              style: TextStyle(
                  color: c.texto, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          SizedBox(
            height: 34,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final t in _cats)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: _Chip(
                        texto: t,
                        ativo: _cat == t,
                        onTap: () => setState(() => _cat = t)),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          if (lista.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 24),
              child: Column(children: [
                Icon(Icons.search_off, size: 44, color: c.texto3),
                const SizedBox(height: 8),
                Text('Nenhuma dúvida encontrada.',
                    style: TextStyle(color: c.texto2)),
                const SizedBox(height: 4),
                Text('Abra um chamado e nossa equipe responde.',
                    style: TextStyle(color: c.texto3, fontSize: 12)),
              ]),
            )
          else
            for (final f in lista) _FaqTile(faq: f),
          if (chamados.isNotEmpty) ...[
            const SizedBox(height: 18),
            Text('Meus chamados',
                style: TextStyle(
                    color: c.texto, fontSize: 16, fontWeight: FontWeight.w800)),
            const SizedBox(height: 10),
            for (final ch in chamados)
              _Cartao(
                margin: const EdgeInsets.only(bottom: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: [
                      Expanded(
                        child: Text(ch.assunto,
                            style: TextStyle(
                                color: c.texto,
                                fontWeight: FontWeight.w700,
                                fontSize: 14)),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFF2A93B).withValues(alpha: .16),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text('Em análise',
                            style: TextStyle(
                                color: Color(0xFFF2A93B),
                                fontSize: 10.5,
                                fontWeight: FontWeight.w600)),
                      ),
                    ]),
                    const SizedBox(height: 4),
                    Text('${ch.protocolo} · ${_dataHora(ch.data)}',
                        style: TextStyle(color: c.texto3, fontSize: 11.5)),
                  ],
                ),
              ),
          ],
        ],
      ),
    );
  }
}

class _Canal extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String sub;
  final VoidCallback onTap;
  const _Canal(
      {required this.icone,
      required this.titulo,
      required this.sub,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 6),
          decoration: BoxDecoration(
            color: c.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.borda),
          ),
          child: Column(children: [
            Icon(icone, color: vermelhoDestaque, size: 26),
            const SizedBox(height: 6),
            Text(titulo,
                style: TextStyle(
                    color: c.texto, fontSize: 13, fontWeight: FontWeight.w700)),
            Text(sub,
                textAlign: TextAlign.center,
                style: TextStyle(color: c.texto3, fontSize: 10.5)),
          ]),
        ),
      ),
    );
  }
}

class _FaqTile extends StatelessWidget {
  final Faq faq;
  const _FaqTile({required this.faq});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: c.card,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: c.borda),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          iconColor: vermelhoDestaque,
          collapsedIconColor: c.texto2,
          tilePadding: const EdgeInsets.symmetric(horizontal: 14),
          childrenPadding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
          expandedCrossAxisAlignment: CrossAxisAlignment.start,
          title: Text(faq.p,
              style: TextStyle(
                  color: c.texto, fontSize: 14, fontWeight: FontWeight.w600)),
          children: [
            Text(faq.r,
                style: TextStyle(color: c.texto2, fontSize: 13.5, height: 1.4)),
            const SizedBox(height: 10),
            Row(children: [
              Text('Isso ajudou?',
                  style: TextStyle(color: c.texto3, fontSize: 12)),
              const SizedBox(width: 8),
              InkWell(
                onTap: () => _aviso(context, 'Obrigado pelo retorno!'),
                child: Icon(Icons.thumb_up_alt_outlined,
                    size: 18, color: c.texto2),
              ),
              const SizedBox(width: 14),
              InkWell(
                onTap: () => _aviso(context,
                    'Que pena. Abra um chamado para falarmos com você.'),
                child: Icon(Icons.thumb_down_alt_outlined,
                    size: 18, color: c.texto2),
              ),
            ]),
          ],
        ),
      ),
    );
  }
}

class NovoChamadoPage extends StatefulWidget {
  const NovoChamadoPage({super.key});

  @override
  State<NovoChamadoPage> createState() => _NovoChamadoPageState();
}

class _NovoChamadoPageState extends State<NovoChamadoPage> {
  final _form = GlobalKey<FormState>();
  final _msg = TextEditingController();
  String _assunto = 'Dúvida sobre medicamento';
  static const _assuntos = [
    'Dúvida sobre medicamento',
    'Problema com a leitura da receita',
    'Preços e descontos',
    'Conta e acesso',
    'Privacidade e dados (LGPD)',
    'Outro assunto',
  ];

  @override
  void dispose() {
    _msg.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!(_form.currentState?.validate() ?? false)) return;
    final agora = DateTime.now();
    final prot =
        'RC-${agora.year}-${(agora.millisecondsSinceEpoch % 100000).toString().padLeft(5, '0')}';
    chamados.insert(0, Chamado(prot, _assunto, _msg.text.trim(), agora));
    final c = context.cores;
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: c.card,
        icon: const Icon(Icons.check_circle, color: verdeOk, size: 44),
        title: Text('Chamado aberto!',
            style: TextStyle(color: c.texto, fontWeight: FontWeight.w800)),
        content: Text(
            'Seu protocolo é $prot.\nResponderemos no e-mail ${perfil.email}.',
            textAlign: TextAlign.center,
            style: TextStyle(color: c.texto2)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK',
                  style: TextStyle(color: vermelhoDestaque)))
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return _Pagina(
      titulo: 'Novo chamado',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Form(
            key: _form,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Assunto',
                    style: TextStyle(color: c.texto2, fontSize: 12)),
                const SizedBox(height: 5),
                DropdownButtonFormField<String>(
                  initialValue: _assunto,
                  dropdownColor: c.card,
                  style: TextStyle(color: c.texto, fontSize: 14),
                  decoration: _deco(context, ''),
                  items: [
                    for (final a in _assuntos)
                      DropdownMenuItem(value: a, child: Text(a))
                  ],
                  onChanged: (v) => setState(() => _assunto = v ?? _assunto),
                ),
                const SizedBox(height: 14),
                Text('Mensagem',
                    style: TextStyle(color: c.texto2, fontSize: 12)),
                const SizedBox(height: 5),
                TextFormField(
                  controller: _msg,
                  minLines: 5,
                  maxLines: 8,
                  maxLength: 600,
                  validator: (v) => (v ?? '').trim().length < 15
                      ? 'Conte um pouco mais (mín. 15 caracteres)'
                      : null,
                  style: TextStyle(color: c.texto),
                  decoration: _deco(context, 'Descreva o que aconteceu...'),
                ),
                Text(
                    'Não envie fotos de receitas nem dados de saúde por aqui.',
                    style: TextStyle(color: c.texto3, fontSize: 11.5)),
                const SizedBox(height: 18),
                _BotaoPrimario(texto: 'Enviar chamado', onTap: _enviar),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PUBLICAÇÕES SALVAS
// ============================================================
class SalvasPage extends StatelessWidget {
  const SalvasPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return _Pagina(
      titulo: 'Publicações salvas',
      child: AnimatedBuilder(
        animation: salvosStore,
        builder: (_, _) {
          final itens = salvosStore.itens;
          if (itens.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.bookmark_border, size: 75, color: c.texto3),
                    const SizedBox(height: 14),
                    Text('Você não tem nenhuma publicação salva',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: c.texto,
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            height: 1.2)),
                    const SizedBox(height: 8),
                    Text('Salve publicações e as encontre rapidamente por aqui',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: c.texto2, fontSize: 13.5)),
                    const SizedBox(height: 22),
                    SizedBox(
                      width: 200,
                      child: _BotaoPrimario(
                          texto: 'Abrir publicações',
                          onTap: () => Navigator.pop(context)),
                    ),
                  ],
                ),
              ),
            );
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: itens.length + 1,
            separatorBuilder: (_, _) => const SizedBox(height: 14),
            itemBuilder: (_, i) {
              if (i == 0) {
                return Text(
                    '${itens.length} publicaç${itens.length == 1 ? 'ão salva' : 'ões salvas'}',
                    style: TextStyle(color: c.texto3, fontSize: 12));
              }
              return PromoCard(
                  key: ValueKey(itens[i - 1].produto), promo: itens[i - 1]);
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// FEEDBACK (estrelas, notas por categoria, NPS, tipo, texto)
// ============================================================
class EstrelasNota extends StatelessWidget {
  final int valor;
  final ValueChanged<int> onChanged;
  final double tamanho;
  const EstrelasNota(
      {super.key,
      required this.valor,
      required this.onChanged,
      this.tamanho = 36});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (var i = 1; i <= 5; i++)
          GestureDetector(
            onTap: () => onChanged(i == valor ? 0 : i),
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: tamanho * .08),
              child: Icon(
                i <= valor ? Icons.star_rounded : Icons.star_outline_rounded,
                size: tamanho,
                color: i <= valor ? const Color(0xFFF2A93B) : c.texto3,
              ),
            ),
          ),
      ],
    );
  }
}

final List<Map<String, dynamic>> feedbacksEnviados = [];

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  State<FeedbackPage> createState() => _FeedbackPageState();
}

class _FeedbackPageState extends State<FeedbackPage> {
  static const _rotulos = ['Toque nas estrelas', 'Muito ruim', 'Ruim', 'Regular', 'Bom', 'Excelente!'];
  static const _categorias = [
    'Facilidade de uso',
    'Leitura de receitas',
    'Preços e descontos',
    'Lembretes',
    'Visual do app',
  ];
  static const _tipos = ['Elogio', 'Sugestão', 'Problema', 'Nova ideia'];
  static const _gostou = [
    'Comparar preços',
    'Escanear receita',
    'Lembretes',
    'Descontos',
    'Comunidade',
    'Design',
  ];

  int _geral = 0;
  final Map<String, int> _notas = {};
  int? _nps;
  String _tipo = 'Elogio';
  final Set<String> _gostos = {};
  bool _contato = false;
  bool _enviado = false;
  final _txt = TextEditingController();

  @override
  void dispose() {
    _txt.dispose();
    super.dispose();
  }

  void _enviar() {
    if (_geral == 0) {
      _aviso(context, 'Escolha uma nota geral de 1 a 5 estrelas.');
      return;
    }
    feedbacksEnviados.add({
      'geral': _geral,
      'categorias': Map<String, int>.from(_notas),
      'nps': _nps,
      'tipo': _tipo,
      'gostou': _gostos.toList(),
      'texto': _txt.text.trim(),
      'contato': _contato,
      'data': DateTime.now(),
    });
    setState(() => _enviado = true);
  }

  void _novo() => setState(() {
        _geral = 0;
        _notas.clear();
        _nps = null;
        _tipo = 'Elogio';
        _gostos.clear();
        _contato = false;
        _txt.clear();
        _enviado = false;
      });

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    if (_enviado) {
      return _Pagina(
        titulo: 'Feedback',
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.favorite, size: 64, color: vermelhoDestaque),
                const SizedBox(height: 14),
                Text('Obrigado pelo seu feedback!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: c.texto,
                        fontSize: 22,
                        fontWeight: FontWeight.w800)),
                const SizedBox(height: 8),
                Text('É assim que o Receita Certa fica melhor a cada versão.',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: c.texto2, fontSize: 13.5)),
                const SizedBox(height: 14),
                EstrelasNota(valor: _geral, onChanged: (_) {}, tamanho: 28),
                const SizedBox(height: 24),
                _BotaoPrimario(
                    texto: 'Voltar', onTap: () => Navigator.pop(context)),
                TextButton(
                    onPressed: _novo,
                    child: Text('Enviar outro feedback',
                        style: TextStyle(color: c.texto2))),
              ],
            ),
          ),
        ),
      );
    }

    Widget titulo(String t, [String? sub]) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t,
                  style: TextStyle(
                      color: c.texto, fontSize: 14, fontWeight: FontWeight.w800)),
              if (sub != null)
                Text(sub, style: TextStyle(color: c.texto3, fontSize: 11.5)),
            ],
          ),
        );

    return _Pagina(
      titulo: 'Deixe o seu feedback!',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          _Cartao(
            child: Column(children: [
              Text('Como está sendo sua experiência?',
                  style: TextStyle(
                      color: c.texto,
                      fontSize: 16,
                      fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              EstrelasNota(
                  valor: _geral, onChanged: (v) => setState(() => _geral = v)),
              const SizedBox(height: 6),
              Text(_rotulos[_geral],
                  style: TextStyle(
                      color: _geral == 0 ? c.texto3 : const Color(0xFFF2A93B),
                      fontWeight: FontWeight.w700)),
            ]),
          ),
          _Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titulo('Avalie por área', 'Opcional'),
                for (final cat in _categorias)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(children: [
                      Expanded(
                          child: Text(cat,
                              style:
                                  TextStyle(color: c.texto2, fontSize: 13.5))),
                      EstrelasNota(
                          valor: _notas[cat] ?? 0,
                          tamanho: 22,
                          onChanged: (v) => setState(() => _notas[cat] = v)),
                    ]),
                  ),
              ],
            ),
          ),
          _Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titulo('Você recomendaria o Receita Certa?',
                    '0 = nada provável · 10 = com certeza'),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    for (var i = 0; i <= 10; i++)
                      InkWell(
                        onTap: () => setState(() => _nps = i),
                        borderRadius: BorderRadius.circular(8),
                        child: Container(
                          width: 31,
                          height: 34,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: _nps == i ? vinho : Colors.transparent,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: _nps == i
                                    ? vinho
                                    : c.borda.withValues(alpha: .5)),
                          ),
                          child: Text('$i',
                              style: TextStyle(
                                  color: _nps == i ? Colors.white : c.texto2,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600)),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
          _Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titulo('Sobre o que é o seu feedback?'),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final t in _tipos)
                    _Chip(
                        texto: t,
                        ativo: _tipo == t,
                        onTap: () => setState(() => _tipo = t)),
                ]),
                const SizedBox(height: 16),
                titulo('O que você mais gostou?', 'Pode marcar mais de uma'),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final g in _gostou)
                    _Chip(
                        texto: g,
                        ativo: _gostos.contains(g),
                        onTap: () => setState(() => _gostos.contains(g)
                            ? _gostos.remove(g)
                            : _gostos.add(g))),
                ]),
              ],
            ),
          ),
          _Cartao(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                titulo('Quer contar mais?', 'Opcional'),
                TextField(
                  controller: _txt,
                  minLines: 4,
                  maxLines: 6,
                  maxLength: 500,
                  style: TextStyle(color: c.texto),
                  decoration: _deco(context, 'Escreva aqui sua opinião ou ideia...'),
                ),
                Text('Não inclua dados de saúde ou de receitas.',
                    style: TextStyle(color: c.texto3, fontSize: 11.5)),
                const SizedBox(height: 6),
                CheckboxListTile(
                  value: _contato,
                  onChanged: (v) => setState(() => _contato = v ?? false),
                  activeColor: vinho,
                  contentPadding: EdgeInsets.zero,
                  controlAffinity: ListTileControlAffinity.leading,
                  title: Text('Podem entrar em contato comigo (${perfil.email})',
                      style: TextStyle(color: c.texto2, fontSize: 13)),
                ),
              ],
            ),
          ),
          _BotaoPrimario(
              texto: 'Enviar feedback', icone: Icons.send, onTap: _enviar),
        ],
      ),
    );
  }
}

// ============================================================
// CENTRAL DE AJUDA (tutoriais passo a passo)
// ============================================================
class Guia {
  final IconData icone;
  final String titulo;
  final List<String> passos;
  const Guia(this.icone, this.titulo, this.passos);
}

const List<Guia> _guias = [
  Guia(Icons.rocket_launch_outlined, 'Primeiros passos', [
    'Crie sua conta ou entre com seu e-mail e senha.',
    'Explore as abas Destaques e Recentes para ver as promoções.',
    'Toque em "Ver mais" para conhecer o medicamento, os avisos e os preços.',
    'Ative os lembretes para não esquecer seus horários.',
  ]),
  Guia(Icons.document_scanner_outlined, 'Escanear uma receita', [
    'Toque no botão "+" no centro da barra inferior.',
    'Deixe a receita aberta, reta e bem iluminada.',
    'Fotografe e aguarde a leitura.',
    'Confira cada medicamento com a receita original antes de confirmar.',
  ]),
  Guia(Icons.price_check, 'Comparar preços', [
    'Abra uma promoção e toque em "Ver mais".',
    'Role até "Comparar preços".',
    'O menor valor aparece destacado em verde.',
    'Confirme o preço na farmácia, pois ele pode variar.',
  ]),
  Guia(Icons.alarm, 'Criar lembretes', [
    'Abra a aba "Lembretes" na barra inferior.',
    'Escolha o medicamento e os horários.',
    'Permita notificações do app nos ajustes do celular.',
    'Tomar sempre no mesmo horário ajuda no tratamento.',
  ]),
  Guia(Icons.bookmark_border, 'Salvar publicações', [
    'No cartão da promoção, toque no ícone de marcador no canto superior.',
    'Acesse tudo em Menu > Publicações Salvas.',
    'Toque no marcador de novo para remover.',
  ]),
  Guia(Icons.groups_outlined, 'Comentar e avaliar', [
    'Use o polegar para curtir ou não curtir uma promoção.',
    'Toque no balão para ler e escrever comentários.',
    'Siga o Código de Conduta e não indique doses ou diagnósticos.',
  ]),
];

class AjudaPage extends StatelessWidget {
  const AjudaPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return _Pagina(
      titulo: 'Central de Ajuda',
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: vermelhoDestaque.withValues(alpha: .12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: vermelhoDestaque.withValues(alpha: .6)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(children: [
                  Icon(Icons.emergency_outlined,
                      color: vermelhoDestaque, size: 20),
                  SizedBox(width: 8),
                  Text('Emergência?',
                      style: TextStyle(
                          color: vermelhoDestaque,
                          fontWeight: FontWeight.w800,
                          fontSize: 14)),
                ]),
                const SizedBox(height: 6),
                Text(
                    'Ligue para o SAMU (192). Em caso de intoxicação por medicamento, o Disque-Intoxicação atende 24h no 0800 722 6001.',
                    style: TextStyle(color: c.texto2, fontSize: 13, height: 1.35)),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text('Guias rápidos',
              style: TextStyle(
                  color: c.texto, fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 10),
          for (final g in _guias)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              decoration: BoxDecoration(
                color: c.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: c.borda),
              ),
              child: Theme(
                data: Theme.of(context)
                    .copyWith(dividerColor: Colors.transparent),
                child: ExpansionTile(
                  iconColor: vermelhoDestaque,
                  collapsedIconColor: c.texto2,
                  leading: Icon(g.icone, color: c.iconeMenu),
                  title: Text(g.titulo,
                      style: TextStyle(
                          color: c.texto,
                          fontSize: 14,
                          fontWeight: FontWeight.w600)),
                  childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                  expandedCrossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (var i = 0; i < g.passos.length; i++)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              alignment: Alignment.center,
                              decoration: const BoxDecoration(
                                  color: vinho, shape: BoxShape.circle),
                              child: Text('${i + 1}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700)),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(g.passos[i],
                                  style: TextStyle(
                                      color: c.texto2,
                                      fontSize: 13.5,
                                      height: 1.35)),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 12),
          _AtalhoPerfil(
              icone: Icons.support_agent,
              texto: 'Não achou? Fale com a ReceitaCerta',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SuportePage()))),
        ],
      ),
    );
  }
}

// ============================================================
// DOCUMENTOS LEGAIS (Termos, Conduta, Privacidade, Comunidade)
// ============================================================
class ItemDoc {
  final String titulo;
  final String texto;
  const ItemDoc(this.titulo, this.texto);
}

class Documento {
  final String titulo;
  final String atualizado;
  final String intro;
  final List<ItemDoc> itens;
  const Documento(this.titulo, this.atualizado, this.intro, this.itens);
}

class DocumentoPage extends StatelessWidget {
  final Documento doc;
  const DocumentoPage({super.key, required this.doc});

  @override
  Widget build(BuildContext context) {
    final c = context.cores;
    return _Pagina(
      titulo: doc.titulo,
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
        children: [
          Text('Atualizado em ${doc.atualizado}',
              style: TextStyle(color: c.texto3, fontSize: 12)),
          const SizedBox(height: 10),
          _Cartao(
              child: Text(doc.intro,
                  style: TextStyle(color: c.texto2, fontSize: 13.5, height: 1.45))),
          for (var i = 0; i < doc.itens.length; i++) ...[
            const SizedBox(height: 8),
            Text('${i + 1}. ${doc.itens[i].titulo}',
                style: TextStyle(
                    color: c.texto, fontSize: 15, fontWeight: FontWeight.w800)),
            const SizedBox(height: 6),
            Text(doc.itens[i].texto,
                style: TextStyle(color: c.texto2, fontSize: 13.5, height: 1.5)),
          ],
          const SizedBox(height: 22),
          Divider(color: c.borda),
          _AtalhoPerfil(
              icone: Icons.support_agent,
              texto: 'Ficou com dúvida? Fale com a gente',
              onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SuportePage()))),
        ],
      ),
    );
  }
}

const String _dataDocs = '22 de outubro de 2026';

const Documento docTermos = Documento(
  'Termos de Serviço',
  _dataDocs,
  'Estes termos explicam as regras de uso do Receita Certa. Ao criar uma conta ou usar o app, você concorda com eles. Leia com calma.',
  [
    ItemDoc('Sobre o Receita Certa',
        'O Receita Certa é um aplicativo que ajuda você a entender receitas médicas, organizar o tratamento com lembretes e comparar preços de medicamentos em farmácias. Esta é uma versão de demonstração: farmácias, preços e promoções exibidos são exemplos.'),
    ItemDoc('Informação educativa, não atendimento médico',
        'O conteúdo do app tem caráter informativo e educativo. Ele não substitui a consulta, o diagnóstico, a prescrição nem a orientação de médicos e farmacêuticos. Nunca mude dose, horário ou interrompa um tratamento com base apenas no app.'),
    ItemDoc('Leitura de receitas',
        'A leitura automática de receitas pode conter erros, principalmente com letra manuscrita ou fotos ruins. Sempre confira o resultado com a receita original e, em caso de dúvida, pergunte ao profissional de saúde.'),
    ItemDoc('Conta e cadastro',
        'Você deve ter 18 anos ou mais, ou usar o app com o acompanhamento de um responsável legal. As informações do cadastro devem ser verdadeiras. Você é responsável por manter sua senha em segredo e por tudo o que acontece na sua conta.'),
    ItemDoc('Preços, promoções e farmácias',
        'Valores, descontos e disponibilidade são de responsabilidade das farmácias e podem mudar sem aviso. Mostramos esses dados como referência, e a compra é feita diretamente com a farmácia. Confirme preço e estoque antes de comprar.'),
    ItemDoc('Conteúdo publicado por você',
        'Comentários e avaliações continuam sendo seus, mas você nos autoriza a exibi-los no app. Você se responsabiliza pelo que publica e deve seguir o Código de Conduta e as Regras da Comunidade. Podemos remover conteúdos que violem essas regras.'),
    ItemDoc('Uso proibido',
        'É proibido usar o app para fraudar receitas, comprar ou vender medicamentos controlados de forma irregular, coletar dados de outros usuários, tentar invadir ou sobrecarregar o sistema, ou praticar qualquer ato ilegal.'),
    ItemDoc('Propriedade intelectual',
        'O nome, o logotipo, o design e o código do Receita Certa pertencem aos seus criadores. Marcas de farmácias e de medicamentos pertencem aos seus respectivos donos e aparecem apenas para identificação.'),
    ItemDoc('Suspensão e encerramento',
        'Você pode excluir sua conta a qualquer momento em Configurações > Segurança. Podemos suspender ou encerrar contas que violem estes termos, avisando o motivo sempre que possível.'),
    ItemDoc('Limitação de responsabilidade',
        'Empregamos esforços para manter o app correto e disponível, mas não garantimos que ele funcione sem interrupções ou erros. Não nos responsabilizamos por decisões de saúde tomadas apenas com base no app, nos limites da lei.'),
    ItemDoc('Mudanças nos termos',
        'Podemos atualizar estes termos. Quando a mudança for relevante, avisaremos pelo app. Continuar usando depois do aviso significa que você aceita a nova versão.'),
    ItemDoc('Lei aplicável e contato',
        'Estes termos seguem as leis do Brasil, incluindo o Código de Defesa do Consumidor. Dúvidas? Escreva para $emailSuporte.'),
  ],
);

const Documento docConduta = Documento(
  'Código de Conduta',
  _dataDocs,
  'O Receita Certa cuida de saúde, então pedimos mais cuidado do que o normal. Este código vale para todo mundo que usa o app: usuários, parceiros e a nossa equipe.',
  [
    ItemDoc('Respeito sempre',
        'Trate todos com educação. Não toleramos ofensas, discriminação, assédio, ameaças ou qualquer forma de preconceito.'),
    ItemDoc('Cuidado com a saúde dos outros',
        'Não indique doses, não receite e não diga a ninguém para parar ou trocar um tratamento. Compartilhe sua experiência pessoal, deixando claro que cada pessoa é diferente e que o médico ou farmacêutico deve ser consultado.'),
    ItemDoc('Honestidade',
        'Não publique informações falsas, promessas de cura, avaliações compradas ou perfis falsos. Se for profissional de saúde, identifique-se de forma verdadeira.'),
    ItemDoc('Privacidade das pessoas',
        'Não exponha dados pessoais ou de saúde de terceiros, nem os seus em excesso. Nunca publique fotos de receitas, CPF, endereço ou telefone.'),
    ItemDoc('Sem venda e sem spam',
        'Não use comentários para vender produtos, divulgar links, pedir doações ou fazer propaganda. Medicamentos controlados jamais podem ser oferecidos ou negociados.'),
    ItemDoc('Segurança e fraudes',
        'É proibido usar o app para falsificar receitas, burlar regras de venda ou tentar acessar contas de outras pessoas.'),
    ItemDoc('Denúncias',
        'Viu algo que vai contra este código? Avise pelo suporte em Fale com a ReceitaCerta. Analisamos cada denúncia com cuidado e sigilo.'),
    ItemDoc('O que pode acontecer',
        'Dependendo da gravidade, podemos remover o conteúdo, enviar um aviso, suspender a conta por um período ou encerrá-la de forma definitiva. Casos graves podem ser comunicados às autoridades.'),
  ],
);

const Documento docPrivacidade = Documento(
  'Política de Privacidade',
  _dataDocs,
  'Levamos a sua privacidade a sério, principalmente porque receitas e medicamentos revelam informações de saúde. Esta política segue a Lei Geral de Proteção de Dados (LGPD, Lei 13.709/2018) e explica quais dados usamos e por quê.',
  [
    ItemDoc('Quem é o responsável',
        'O Receita Certa é o controlador dos seus dados pessoais. Contato do encarregado de dados (DPO): privacidade@receitacerta.com.br.'),
    ItemDoc('Quais dados coletamos',
        'Dados de cadastro: nome de usuário, e-mail e, se você informar, nome completo e CPF. Dados de uso: promoções vistas, curtidas, comentários, itens salvos e preferências. Dados de saúde: medicamentos e receitas que você escolher escanear ou registrar (dados sensíveis). Localização aproximada, só se você permitir, para mostrar a farmácia mais próxima. Dados técnicos: modelo do aparelho, versão do app e registros de erro.'),
    ItemDoc('Para que usamos',
        'Para criar e manter sua conta, interpretar suas receitas, enviar lembretes, mostrar promoções e farmácias próximas, melhorar o app, prevenir fraudes e cumprir obrigações legais. Não usamos seus dados de saúde para publicidade.'),
    ItemDoc('Base legal',
        'Usamos seus dados para executar o serviço que você pediu, com o seu consentimento (principalmente para dados de saúde e localização), para cumprir a lei e, nos casos permitidos, por interesse legítimo, como a segurança do app. Você pode retirar o consentimento a qualquer momento.'),
    ItemDoc('Com quem compartilhamos',
        'Não vendemos seus dados. Compartilhamos apenas com prestadores que nos ajudam a operar o app (hospedagem, envio de notificações e análise de erros), que seguem nossas instruções, e com autoridades quando a lei exigir.'),
    ItemDoc('Segurança',
        'Usamos criptografia na transmissão, controle de acesso e boas práticas para proteger as informações. Nenhum sistema é 100% seguro, e, se houver um incidente relevante, avisaremos você e a ANPD conforme a lei.'),
    ItemDoc('Por quanto tempo guardamos',
        'Mantemos os dados enquanto sua conta existir ou for necessário para cumprir obrigações legais. Ao excluir a conta, apagamos ou anonimizamos seus dados, salvo o que a lei nos obrigar a guardar.'),
    ItemDoc('Seus direitos',
        'Você pode pedir: confirmação de que tratamos seus dados, acesso, correção, anonimização ou eliminação, portabilidade, informação sobre com quem compartilhamos, e a revogação do consentimento. Use Configurações > Segurança ou escreva para o encarregado.'),
    ItemDoc('Crianças e adolescentes',
        'O app é voltado a maiores de 18 anos. Menores só devem usar com acompanhamento e consentimento de um responsável legal.'),
    ItemDoc('Mudanças nesta política',
        'Podemos atualizar esta política. Sempre que mudar algo importante, avisaremos pelo app. Se não estiver satisfeito, você pode registrar reclamação na ANPD (gov.br/anpd).'),
  ],
);

const Documento docComunidade = Documento(
  'Regras da comunidade',
  _dataDocs,
  'A comunidade do Receita Certa existe para as pessoas trocarem experiências e economizarem juntas. Para manter o ambiente seguro e útil, siga estas regras.',
  [
    ItemDoc('Seja gentil e respeitoso',
        'Discorde com educação. Ofensas, deboches e provocações não têm espaço aqui.'),
    ItemDoc('Conte a sua experiência, não dê receita',
        'Você pode dizer como um remédio funcionou para você, mas nunca indique dose ou diga que serve para outra pessoa. Cada caso é um caso.'),
    ItemDoc('Nada de dados pessoais',
        'Não publique fotos de receitas, documentos, telefones, endereços ou informações de saúde de ninguém.'),
    ItemDoc('Sem propaganda e links suspeitos',
        'Comentários com venda, divulgação ou links externos serão removidos.'),
    ItemDoc('Avaliações verdadeiras',
        'Comente apenas sobre o que você realmente usou ou viu. Avaliações falsas ou combinadas prejudicam todo mundo.'),
    ItemDoc('Emergência não é assunto de comentário',
        'Em caso de mal-estar grave, ligue para o SAMU (192) ou procure um pronto-atendimento. Não peça ajuda médica nos comentários.'),
    ItemDoc('Denuncie quando precisar',
        'Encontrou algo que viola estas regras? Fale com a gente em Fale com a ReceitaCerta e analisaremos.'),
    ItemDoc('Consequências',
        'Conteúdos que violarem as regras serão removidos. Repetir a infração pode levar à suspensão ou ao encerramento da conta.'),
  ],
);