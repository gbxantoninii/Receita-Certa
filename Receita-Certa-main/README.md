# Receita Certa

> **Escaneou, entendeu, cuidou.**

Aplicativo que ajuda as pessoas a entenderem a receita médica, organizarem o tratamento com lembretes e compararem preços de medicamentos em farmácias.

Projeto desenvolvido para a **Future Fest**, em parceria com a **Eurofarma**.

🔗 **Versão online:** https://receitacerta-2emfc.netlify.app

> ⚠️ Esta é uma versão de demonstração. Farmácias, preços e promoções exibidos são exemplos. O app tem caráter informativo e **não substitui** a orientação de médicos e farmacêuticos.

---

## Funcionalidades

- **Login e cadastro** com validação de e-mail, usuário e força da senha
- **Home** com as abas *Destaques*, *Recentes* e *Comentários*
- **Promoções** com curtir, não curtir, comentar, salvar e comparar preços
- **Escanear receita** pela câmera e confirmar os medicamentos identificados
- **Minhas receitas**, **Pedidos** e **Lembretes** de medicamentos
- **Busca, chat e notificações**
- **Perfil e configurações** (dados pessoais, notificações e segurança)
- **Fale com a ReceitaCerta**: FAQ, assistente virtual e abertura de chamados
- **Feedback** com estrelas, notas por área e NPS
- **Central de Ajuda** com guias passo a passo
- **Termos de Serviço, Código de Conduta, Privacidade e Regras da comunidade**
- **Tema** claro, escuro ou automático
- **Nossa equipe**, acessível pelo menu lateral

---

## Tecnologias

- [Flutter](https://flutter.dev) (Dart), com suporte a web, Android e iOS
- Pacotes: `image_picker`, `http`
- Backend em **Node.js** (pasta `backend`)
- Hospedagem web: **Netlify**

---

## Estrutura do projeto

O código do app é dividido em arquivos `part of 'main.dart'`, dentro de `lib/`:

| Arquivo | O que tem |
|---|---|
| `main.dart` | Imports e declaração dos módulos |
| `app_core.dart` | Cores, tema e `MaterialApp` |
| `modelos_dados.dart` | Modelos e dados de exemplo |
| `login_equipe.dart` | Página e cartões da equipe |
| `menu_principal.dart` | Home, abas e barra inferior |
| `promocoes_comentarios.dart` | Cartões de promoção e comentários |
| `busca_chat_notificacoes.dart` | Busca, chat e notificações |
| `perfil_configuracoes.dart` | Login/cadastro, menu lateral, perfil, configurações, suporte, feedback, ajuda e documentos legais |
| `receitas_lembretes.dart` | Escaneamento, receitas e lembretes |
| `pedidos.dart` | Pedidos |

Outras pastas importantes:

- `assets/`: imagens do app
- `web/`: arquivos da versão web (`index.html`, `manifest.json`, ícones)
- `backend/`: servidor Node.js (`server.js`)

---

## Como rodar

### Pré-requisitos

- [Flutter SDK](https://docs.flutter.dev/get-started/install)
- [Node.js](https://nodejs.org) (para o backend)

### App

```bash
# instalar dependências
flutter pub get

# rodar no navegador
flutter run -d chrome

# ou em um aparelho/emulador conectado
flutter run
```

### Backend

```bash
cd backend
npm install
node server.js
```

Crie um arquivo `.env` dentro de `backend/` com as variáveis necessárias (por exemplo, chaves de API). **Nunca envie o `.env` para o GitHub.** Confirme que ele está no `.gitignore`.

---

## Conta de teste

Para testar o login sem criar conta:

- **E-mail:** `isabela.ngt1@gmail.com`
- **Senha:** `receita123`

---

## Publicar a versão web

```bash
flutter build web --release
```

Depois, arraste a pasta **`build/web`** na aba *Deploys* do site no [Netlify](https://app.netlify.com).

> Se o backend estiver em outro endereço, ajuste a URL usada pelo app antes de gerar o build.

---

## Equipe

Veja a página **Nossa equipe** dentro do app (menu lateral).

---

## Aviso

O Receita Certa traz informação educativa. Nunca mude dose, horário ou interrompa um tratamento com base apenas no app. Em caso de dúvida, procure um médico ou farmacêutico. Em emergência, ligue para o **SAMU (192)**.
