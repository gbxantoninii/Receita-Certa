
import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const PORTA = 3000;

app.use(cors());
app.use(express.json({ limit: '1mb' }));

app.get('/', (req, res) => {
  res.json({ mensagem: 'Backend Receita Certa funcionando!' });
});

app.post('/chat', async (req, res) => {
  try {
    const { mensagem, medicamentos } = req.body;

    if (!mensagem || typeof mensagem !== 'string') {
      return res.status(400).json({
        erro: 'Envie uma pergunta válida.'
      });
    }

    if (!process.env.GEMINI_API_KEY) {
      return res.status(500).json({
        erro: 'A chave da API não foi configurada no backend.'
      });
    }

    const catalogo = Array.isArray(medicamentos)
      ? medicamentos.slice(0, 100)
      : [];

    const instrucao = `
Você é o assistente virtual do aplicativo Receita Certa.
Responda em português brasileiro, com clareza e educação.

Use os dados do catálogo fornecido para responder sobre produtos,
preços, descontos e informações disponíveis no aplicativo.

REGRAS IMPORTANTES:
- Não invente preços, descontos, estoques ou farmácias.
- Se uma informação não estiver no catálogo, diga que não está disponível.
- Não diagnostique doenças nem recomende doses ou alterações de medicamentos.
- Para dúvidas sobre uso, contraindicações ou interações medicamentosas,
  oriente a pessoa a consultar um farmacêutico ou médico.
- Não afirme que um medicamento está disponível em tempo real.
- Responda perguntas sobre as funcionalidades do Receita Certa.
- Se a pergunta não estiver relacionada ao aplicativo ou à saúde,
  tente responder brevemente e com segurança.
- Não solicite dados pessoais ou informações de receitas médicas.

CATÁLOGO DISPONÍVEL:
${JSON.stringify(catalogo)}
`;

    const respostaGemini = await fetch(
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-3.8-flash:generateContent',
      {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'x-goog-api-key': process.env.GEMINI_API_KEY
        },
        body: JSON.stringify({
          system_instruction: {
            parts: [{ text: instrucao }]
          },
          contents: [
            {
              role: 'user',
              parts: [{ text: mensagem }]
            }
          ],
          generationConfig: {
            temperature: 0.4,
            maxOutputTokens: 800
          }
        })
      }
    );

    const dados = await respostaGemini.json();

    if (!respostaGemini.ok) {
      console.error(
        'Erro da API Gemini:',
        respostaGemini.status,
        dados.error?.message
      );

      return res.status(502).json({
        erro: 'Não foi possível obter resposta da IA. Confira o terminal.'
      });
    }

    const texto = dados.candidates?.[0]?.content?.parts
      ?.map((parte) => parte.text || '')
      .join('')
      .trim();

    if (!texto) {
      return res.status(502).json({
        erro: 'A IA não retornou uma resposta válida.'
      });
    }

    return res.json({ resposta: texto });
  } catch (erro) {
    console.error('Erro no backend:', erro.message);
    console.error('Detalhe da conexão:', erro.cause);

    return res.status(500).json({
      erro: 'Ocorreu um erro ao processar a pergunta.'
    });
  }
});

app.listen(PORTA, '127.0.0.1', () => {
  console.log(`Receita Certa rodando em http://localhost:${PORTA}`);
});
