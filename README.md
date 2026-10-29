# NEXUS Battle Royale

Projeto de um Battle Royale mobile em primeira pessoa (FPS), com foco em combate competitivo, movimentação responsiva, eventos dinâmicos no mapa e otimização real de desempenho.

> **Status:** protótipo técnico inicial em preparação. Ainda não há APK confirmado nem versão jogável validada.

## Visão do jogo

- Partidas solo com até 50 jogadores.
- Câmera em primeira pessoa.
- Armas convencionais, sem poderes especiais nas armas.
- Movimentação com corrida, salto, agachamento e deslize.
- Evento dinâmico de apagão: luzes se apagam de forma abrupta, com áudio ambiental e mudanças táticas na visibilidade.
- Opções gráficas: **Suave**, **Padrão** e **Ultra**.
- Interface mobile com controles personalizáveis.
- Lobby principal com acesso ao perfil, modos de jogo e configurações.
- Pré-lobby 3D antes da contagem regressiva, no qual o jogador pode se movimentar e ver uma seleção limitada de outros participantes.

## Pré-lobby e desempenho

A proposta inicial é manter os participantes conectados à mesma sessão de partida, mas limitar por cliente a quantidade de personagens efetivamente renderizados. A seleção de personagens visíveis não deve alterar a participação real na sessão nem o estado dos jogadores.

O limite exato de personagens visíveis, a distância de renderização e as regras de matchmaking serão definidos e testados durante a implementação.

## Princípios técnicos

1. Priorizar qualidade de jogo e responsividade, não apenas um tamanho pequeno de instalação.
2. Medir FPS, uso de memória, temperatura e consumo de bateria em aparelhos reais.
3. Separar qualidade gráfica de lógica de gameplay sempre que possível.
4. Evitar prometer desempenho sem testes em dispositivos-alvo.
5. Implementar primeiro um protótipo jogável e evoluir por etapas.

## Roadmap inicial

- [x] Definir Unreal Engine 5.6 como motor do projeto.
- [ ] Configurar e executar um ambiente de compilação na nuvem.
- [ ] Criar a estrutura de pastas e a cena inicial.
- [ ] Implementar a tela principal e navegação entre telas.
- [ ] Criar o layout do perfil (dados e estatísticas serão definidos depois).
- [ ] Criar a tela de configurações gráficas.
- [ ] Prototipar movimentação em primeira pessoa, incluindo o deslize.
- [ ] Criar o cenário de pré-lobby e a contagem regressiva.
- [ ] Prototipar o evento de apagão com iluminação e áudio.
- [ ] Definir arquitetura de rede para partidas de 50 jogadores.
- [ ] Testar e otimizar em dispositivos móveis.

## Próximas etapas

1. Validar os arquivos do projeto.
2. Conseguir um ambiente de build compatível com Unreal 5.6 e Android.
3. Compilar o C++ e corrigir os erros encontrados.
4. Gerar o mapa de pré-lobby no Unreal Editor.
5. Empacotar e testar um APK no aparelho-alvo.

## Arquivos técnicos adicionados

- `Scripts/CreateNexusPreLobby.py`: script para gerar um mapa blockout do pré-lobby dentro do Unreal Editor.
- `.github/workflows/build-android.yml`: workflow manual de empacotamento Android.
- `Docs/Android_Build_Runner.md`: requisitos do ambiente de compilação.
- `Docs/Cloud_Build_Plan.md`: opções e etapas para conseguir compilação na nuvem.

**Atenção:** o script Python precisa ser executado dentro do Unreal Editor para criar o arquivo de mapa `.umap`. O workflow Android depende de um runner com Unreal Engine autorizada e Android SDK/NDK/JDK instalados. Ele ainda não comprova que o jogo compila nem gera APK enquanto esse runner não existir.
