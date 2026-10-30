part of 'main.dart';

void main() {
  runApp(const ReceitaCertaApp());
}

const Color vinho = Color(0xFF41090F);
const Color fundo = Color(0xFF323232);
const Color fundoCard = Color(0xFF383838);
const Color branco = Color(0xFFF7F7F7);
const Color vermelhoDestaque = Color(0xFFE5384A);
const Color verdeOk = Color(0xFF19A45B);

/// Usuário logado (muda quando o perfil muda)
String get usuarioLogado => perfil.usuario;

class ReceitaCertaApp extends StatelessWidget {
  const ReceitaCertaApp({super.key});

  ThemeData _tema(Brightness b) {
    final escuro = b == Brightness.dark;
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: escuro ? fundo : const Color(0xFFF3F0ED),
      fontFamily: 'Arial',
      colorScheme: ColorScheme.fromSeed(seedColor: vinho, brightness: b),
      // as telas antigas ainda são escuras, então o AppBar fica branco
      appBarTheme: const AppBarTheme(foregroundColor: Colors.white),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: temaEscolhido,
      builder: (_, tema, _) => MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Receita Certa',
        theme: _tema(Brightness.light),
        darkTheme: _tema(Brightness.dark),
        themeMode: modoDoTema(tema),
        home: const AuthPage(),
      ),
    );
  }
}

