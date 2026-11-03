part of 'main.dart';

// ============================================================
// MODELOS DE DADOS
// ============================================================
class Comentario {
  final String usuario;
  final String texto;
  const Comentario(this.usuario, this.texto);
}

class PrecoFarmacia {
  final String nome;
  final double valor;
  const PrecoFarmacia(this.nome, this.valor);
}

class Membro {
  final String nome;
  final String usuario;
  final String avatar;
  final String funcao;
  final String descricao;
  final List<String> contribuicoes;
  const Membro({
    required this.nome,
    required this.usuario,
    required this.avatar,
    required this.funcao,
    required this.descricao,
    required this.contribuicoes,
  });
}

class Promo {
  final String brand;
  final BrandType brandType;
  final String produto;
  final String descricao; // descrição curta (card)
  final int desconto; // em %
  final double precoOriginal;

  // Detalhes (tela "Ver mais")
  final String composicao;
  final String descricaoDetalhada;
  final String comoUsar;
  final String avisos;
  final bool requerReceita;

  // Farmácia mais próxima (dados de exemplo)
  final String endereco;
  final String distancia;
  final String horario;
  final String telefone;

  // Comparação de preços (dados de exemplo)
  final List<PrecoFarmacia> outrasFarmacias;

  // Estado que muda durante o uso
  final List<Comentario> comentarios;
  bool curtiu = false;
  bool naoCurtiu = false;
  bool salvo = false;

  Promo({
    required this.brand,
    required this.brandType,
    required this.produto,
    required this.descricao,
    required this.desconto,
    required this.precoOriginal,
    required this.composicao,
    required this.descricaoDetalhada,
    required this.comoUsar,
    required this.avisos,
    required this.requerReceita,
    required this.endereco,
    required this.distancia,
    required this.horario,
    required this.telefone,
    required this.outrasFarmacias,
    required this.comentarios,
  });

  double get precoPromo => precoOriginal * (100 - desconto) / 100;
  String get descontoTexto => '$desconto% OFF';
}

String reais(double v) => 'R\$ ${v.toStringAsFixed(2).replaceAll('.', ',')}';

// ------------------------------------------------------------
// Dados de exemplo (listas globais: mantêm curtidas/comentários
// enquanto o app está aberto)
// ------------------------------------------------------------
final List<Promo> promosRecentes = [
  Promo(
    brand: 'Drogaria Raia',
    brandType: BrandType.raia,
    produto: 'Dorflex 10 comprimidos',
    descricao:
        'Alívio para dores musculares e de cabeça. 20% OFF na Drogaria Raia.',
    desconto: 20,
    precoOriginal: 18.90,
    composicao: 'Dipirona + orfenadrina + cafeína',
    descricaoDetalhada:
        'Associação de analgésico com relaxante muscular, indicada para o alívio de dores musculares, inclusive as associadas a contraturas, e de dores de cabeça causadas por tensão.',
    comoUsar:
        'Uso oral, com água. A quantidade e o intervalo entre as doses devem seguir a bula e a orientação do médico ou farmacêutico.',
    avisos:
        'Não use em caso de alergia à dipirona ou a outros componentes. Pode causar sonolência. Evite bebida alcoólica. Gestantes, lactantes e pessoas com glaucoma devem consultar o médico antes.',
    requerReceita: false,
    endereco: 'Rua Augusta, 1200 – Consolação, São Paulo – SP',
    distancia: '350 m',
    horario: 'Seg a Dom, 7h às 22h',
    telefone: '(11) 3000-0001',
    outrasFarmacias: const [
      PrecoFarmacia('Farmácias Pague Menos', 16.20),
      PrecoFarmacia('Drogaria São Paulo', 15.90),
    ],
    comentarios: [
      const Comentario('@rafaela.mt',
          'Uso quando bate dor nas costas depois de um dia inteiro sentada. Alivia rápido.'),
      const Comentario(
          '@lucas.pfarma', 'Lembrando: não misture com outros analgésicos sem falar com o farmacêutico.'),
    ],
  ),
  Promo(
    brand: 'Farmácias Pague Menos',
    brandType: BrandType.pagueMenos,
    produto: 'Neosaldina 20 comprimidos',
    descricao:
        'Alívio para dores de cabeça e enxaqueca. 15% OFF na Pague Menos.',
    desconto: 15,
    precoOriginal: 29.90,
    composicao: 'Dipirona + isometepteno + cafeína',
    descricaoDetalhada:
        'Medicamento indicado para o tratamento de dores de cabeça, incluindo cefaleia tensional e enxaqueca. A cafeína ajuda a potencializar o efeito analgésico.',
    comoUsar:
        'Uso oral. Tome conforme a bula ou a orientação do seu médico. Se a dor de cabeça for frequente ou muito forte, procure atendimento médico.',
    avisos:
        'Contraindicado para alérgicos à dipirona. Pessoas com glaucoma, problemas no coração ou pressão alta devem consultar o médico. A cafeína pode causar agitação ou insônia.',
    requerReceita: false,
    endereco: 'Av. Paulista, 900 – Bela Vista, São Paulo – SP',
    distancia: '600 m',
    horario: 'Seg a Sáb, 8h às 21h',
    telefone: '(11) 3000-0002',
    outrasFarmacias: const [
      PrecoFarmacia('Drogaria Raia', 24.90),
      PrecoFarmacia('Drogaria São Paulo', 25.40),
    ],
    comentarios: [
      const Comentario('@bia.nunes',
          'Minha enxaqueca some em pouco tempo com ela. Sempre tenho uma caixa em casa.'),
      const Comentario('@tiago.rs',
          'Achei o preço na Pague Menos melhor que nas outras. Vale comparar pelo app.'),
      const Comentario('@dani.ferr',
          'Dá um pouquinho de agitação por causa da cafeína, então evito à noite.'),
    ],
  ),
  Promo(
    brand: 'Drogaria São Paulo',
    brandType: BrandType.saoPaulo,
    produto: 'Tylenol 750mg – 20 comprimidos',
    descricao: 'Alívio para dores e febre. 18% OFF na Drogaria São Paulo.',
    desconto: 18,
    precoOriginal: 24.90,
    composicao: 'Paracetamol 750 mg',
    descricaoDetalhada:
        'Analgésico e antitérmico indicado para reduzir a febre e aliviar dores leves a moderadas, como dor de cabeça, dor de dente, dor muscular e dores do resfriado.',
    comoUsar:
        'Uso oral. Respeite o intervalo e a dose máxima diária da bula ou da orientação médica. Não tome outros remédios com paracetamol ao mesmo tempo.',
    avisos:
        'O excesso de paracetamol pode causar danos ao fígado. Pessoas com doenças no fígado ou que consomem álcool com frequência devem falar com o médico antes de usar.',
    requerReceita: false,
    endereco: 'Rua da Consolação, 2100 – Consolação, São Paulo – SP',
    distancia: '850 m',
    horario: 'Aberta 24 horas',
    telefone: '(11) 3000-0003',
    outrasFarmacias: const [
      PrecoFarmacia('Drogaria Raia', 21.50),
      PrecoFarmacia('Farmácias Pague Menos', 20.90),
    ],
    comentarios: [
      const Comentario('@vitor.alm',
          'Ótimo para febre. Já ajudou muito quando meu filho ficou gripado (sempre seguindo a bula).'),
      const Comentario('@camila.ro',
          'A caixa de 20 comprimidos rende bastante e o desconto compensa.'),
    ],
  ),
];

final List<Promo> promosDestaques = [
  Promo(
    brand: 'Farmácias Pague Menos',
    brandType: BrandType.pagueMenos,
    produto: 'Losartana 50mg – 30 comprimidos',
    descricao:
        'Controle da pressão arterial. 35% OFF para uso contínuo na Pague Menos.',
    desconto: 35,
    precoOriginal: 22.50,
    composicao: 'Losartana potássica 50 mg',
    descricaoDetalhada:
        'Anti-hipertensivo usado no tratamento da pressão alta e na proteção do coração e dos rins em pessoas com indicação médica. É um medicamento de uso contínuo.',
    comoUsar:
        'Tome sempre no mesmo horário, conforme a prescrição. Não interrompa o tratamento nem altere a dose sem falar com o médico, mesmo se a pressão estiver controlada.',
    avisos:
        'Venda sob prescrição médica. Não use na gravidez. Pode causar tontura, principalmente no início do tratamento. Informe ao médico os outros remédios que você usa.',
    requerReceita: true,
    endereco: 'Av. Paulista, 900 – Bela Vista, São Paulo – SP',
    distancia: '600 m',
    horario: 'Seg a Sáb, 8h às 21h',
    telefone: '(11) 3000-0002',
    outrasFarmacias: const [
      PrecoFarmacia('Drogaria Raia', 16.90),
      PrecoFarmacia('Drogaria São Paulo', 17.50),
    ],
    comentarios: [
      const Comentario('@seu.jorge56',
          'Tomo todo dia de manhã. O lembrete do app me ajuda a não esquecer.'),
      const Comentario('@helena.cs',
          'Com receita e desconto de uso contínuo fica bem mais em conta.'),
    ],
  ),
  Promo(
    brand: 'Drogaria Raia',
    brandType: BrandType.raia,
    produto: 'Omeprazol 20mg – 28 cápsulas',
    descricao: 'Alívio para azia e refluxo. 30% OFF na Drogaria Raia.',
    desconto: 30,
    precoOriginal: 31.90,
    composicao: 'Omeprazol 20 mg',
    descricaoDetalhada:
        'Reduz a produção de ácido no estômago. É indicado para tratar azia, refluxo, gastrite e úlceras, conforme avaliação médica.',
    comoUsar:
        'Geralmente tomado em jejum, cerca de 30 minutos antes do café da manhã, com água. A duração do tratamento deve ser definida pelo médico.',
    avisos:
        'O uso prolongado sem orientação não é recomendado. Procure o médico se tiver dor ao engolir, perda de peso sem motivo, vômitos com sangue ou fezes escuras.',
    requerReceita: false,
    endereco: 'Rua Augusta, 1200 – Consolação, São Paulo – SP',
    distancia: '350 m',
    horario: 'Seg a Dom, 7h às 22h',
    telefone: '(11) 3000-0001',
    outrasFarmacias: const [
      PrecoFarmacia('Farmácias Pague Menos', 23.50),
      PrecoFarmacia('Drogaria São Paulo', 24.00),
    ],
    comentarios: [
      const Comentario('@paulo.gast',
          'Resolveu minha azia. O médico mandou tomar em jejum e fez toda a diferença.'),
      const Comentario('@nina.sou',
          'Boa promoção! Comprei duas caixas porque o tratamento do meu pai é longo.'),
    ],
  ),
  Promo(
    brand: 'Drogaria São Paulo',
    brandType: BrandType.saoPaulo,
    produto: 'Metformina 850mg – 30 comprimidos',
    descricao: 'Controle da glicemia. 28% OFF na Drogaria São Paulo.',
    desconto: 28,
    precoOriginal: 19.90,
    composicao: 'Cloridrato de metformina 850 mg',
    descricaoDetalhada:
        'Antidiabético oral usado no controle do diabetes tipo 2, ajudando o corpo a usar melhor a insulina e reduzindo a glicose no sangue.',
    comoUsar:
        'Costuma ser tomado junto das refeições para diminuir o desconforto no estômago. Siga exatamente a dose e os horários prescritos.',
    avisos:
        'Venda sob prescrição médica. Pode causar náuseas e diarreia no início. Avise o médico se tiver problemas nos rins ou fígado, ou antes de exames com contraste.',
    requerReceita: true,
    endereco: 'Rua da Consolação, 2100 – Consolação, São Paulo – SP',
    distancia: '850 m',
    horario: 'Aberta 24 horas',
    telefone: '(11) 3000-0003',
    outrasFarmacias: const [
      PrecoFarmacia('Drogaria Raia', 15.20),
      PrecoFarmacia('Farmácias Pague Menos', 14.90),
    ],
    comentarios: [
      const Comentario('@marta.diab',
          'Tomo no almoço e no jantar. Com o app organizei os horários direitinho.'),
      const Comentario('@edu.santos',
          'Demorei a me acostumar, mas tomando com comida o estômago não incomoda.'),
    ],
  ),
];

const List<Membro> equipe = [
  Membro(
    nome: 'Isabela',
    usuario: '@isabelangt1',
    avatar: 'assets/isa.jpg',
    funcao: 'Coordenação geral',
    descricao:
        'Isabela atuou nas coisas gerais do Receita Certa, acompanhando o projeto de ponta a ponta. Ajudou a manter a equipe alinhada, a organizar as tarefas e a garantir que tudo o que foi prometido no pitch da Future Fest, em parceria com a Eurofarma, chegasse pronto para a apresentação.',
    contribuicoes: [
      'Organização geral',
      'Alinhamento da equipe',
      'Acompanhamento das entregas',
      'Revisão do projeto',
      'Apoio ao pitch',
    ],
  ),
  Membro(
    nome: 'João',
    usuario: '@joaog.duarte',
    avatar: 'assets/joao.jpg',
    funcao: 'Projeção e ideias',
    descricao:
        'João foi responsável pela projeção do nosso projeto e pelas ideias. Ele ajudou a transformar o problema de entender receitas médicas e organizar o tratamento em uma proposta clara, pensando no público, nos diferenciais e em como o Receita Certa pode ajudar quem usa medicamentos de forma contínua.',
    contribuicoes: [
      'Projeção do projeto',
      'Geração de ideias',
      'Definição do público-alvo',
      'Diferenciais da solução',
      'Construção do pitch',
    ],
  ),
  Membro(
    nome: 'Pedro',
    usuario: '@ph.rosanb12',
    avatar: 'assets/pedro.jpg',
    funcao: 'Desenvolvedor',
    descricao:
        'Pedro trabalhou no código do Receita Certa. Participou do desenvolvimento do aplicativo em Flutter e Dart, ajudando a transformar o design do Figma em telas que funcionam de verdade, com navegação, botões e as informações dos medicamentos.',
    contribuicoes: [
      'Código em Flutter e Dart',
      'Telas a partir do Figma',
      'Navegação do app',
      'Funcionalidades da home',
      'Testes e correções',
    ],
  ),
  Membro(
    nome: 'Biel',
    usuario: '@g.antoninii',
    avatar: 'assets/biel.jpg',
    funcao: 'Desenvolvedor',
    descricao:
        'Biel trabalhou no código do Receita Certa. Atuou na construção do aplicativo em Flutter e Dart, cuidando da implementação das telas, dos detalhes de cada medicamento e das interações, como curtir, comentar e comparar preços.',
    contribuicoes: [
      'Código em Flutter e Dart',
      'Telas a partir do Figma',
      'Detalhes dos medicamentos',
      'Curtidas e comentários',
      'Testes e correções',
    ],
  ),
  Membro(
    nome: 'Kauan',
    usuario: '@k.bitencourtt',
    avatar: 'assets/kauan.jpg',
    funcao: 'Desenvolvedor',
    descricao:
        'Kauan trabalhou no código do Receita Certa. Contribuiu no desenvolvimento do aplicativo em Flutter e Dart, ajudando a deixar o visual fiel ao design e as funcionalidades estáveis para a apresentação.',
    contribuicoes: [
      'Código em Flutter e Dart',
      'Visual fiel ao design',
      'Organização do código',
      'Funcionalidades do app',
      'Testes e correções',
    ],
  ),
  Membro(
    nome: 'Gui',
    usuario: '@gui_almeidas',
    avatar: 'assets/gui.jpg',
    funcao: 'Desenvolvedor',
    descricao:
        'Gui trabalhou no código do Receita Certa. Ajudou no desenvolvimento do aplicativo em Flutter e Dart, participando da criação das telas e das funções que ligam o escaneamento, os lembretes e as informações de preços e descontos.',
    contribuicoes: [
      'Código em Flutter e Dart',
      'Criação das telas',
      'Preços e descontos',
      'Integração das funções',
      'Testes e correções',
    ],
  ),
];

