# Próximo passo real: primeiro build Android do NEXUS

Atualizado em 2026-10-29.

## Resultado das validações

Os workflows `Validate NEXUS project files` e `Validate NEXUS scaffold` passaram na execução mais recente. Isso só verifica a estrutura e a documentação; não compila C++ da Unreal nem produz um APK.

- Validação do projeto: https://github.com/antoniasilva7011-lgtm/NEXUS-BETTLEROYALE/actions/workflows/validate-project.yml
- Validação do scaffold: https://github.com/antoniasilva7011-lgtm/NEXUS-BETTLEROYALE/actions/workflows/check-scaffold.yml

## Opção gerenciada investigada

O SpeedrunCI anuncia suporte a Unreal Engine 5.x e builds Android em runners na nuvem, com teste/piloto gratuito anunciado. A página de preços apresenta plano Starter de US$ 99/mês após o trial. Antes de enviar o projeto, confirme diretamente com o fornecedor se o trial cobre este projeto UE 5.6 em C++ e por quanto tempo, sem ativação automática de cobrança.

- Página principal: https://speedrun.ci/
- Uso mobile: https://speedrun.ci/en/uses/mobile-studios
- Preços: https://speedrun.ci/pricing

Nenhuma conta foi criada e nenhum plano foi contratado.

## Ações necessárias para sair do bloqueio

1. O proprietário do projeto abre o fornecedor e cria a conta/aceita os termos, se quiser prosseguir com o trial.
2. Conecta o repositório pelo fluxo oficial do serviço e concede apenas as permissões necessárias.
3. Confirma que a pipeline usa Unreal Engine 5.6 e Android, sem custo após trial sem autorização explícita.
4. Executa o primeiro build e obtém logs reais de compilação.
5. Corrige erros do C++ conforme os logs.
6. Gera o mapa `.umap` executando `Scripts/CreateNexusPreLobby.py` no Unreal Editor ou num pipeline que suporte execução de scripts de editor.
7. Faz novo empacotamento Android e instala o APK no dispositivo de teste.

## Limitações que não devem ser ocultadas

- GitHub-hosted runners comuns não incluem a Unreal Engine.
- O workflow `build-android.yml` atual exige runner self-hosted com etiquetas `unreal` e `android`; ele não é a pipeline gerenciada do SpeedrunCI.
- O projeto ainda não tem um APK confirmado nem um mapa binário `.umap` confirmado.
- Não colocar tokens, credenciais da Epic ou chaves de assinatura no repositório.
- Não afirmar que o jogo está compilado até existir um artefato APK de uma execução bem-sucedida.
