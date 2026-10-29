# Plano de compilação na nuvem — NEXUS

Atualizado em 2026-10-29.

## Estado verificado do repositório

- O projeto aponta para Unreal Engine 5.6 em `NEXUSBattleRoyale.uproject`.
- Existe um workflow GitHub Actions para empacotamento Android.
- Esse workflow exige um runner com as etiquetas `self-hosted`, `unreal` e `android`.
- O script `Scripts/CreateNexusPreLobby.py` ainda precisa ser executado no Unreal Editor para criar o mapa binário `.umap`.
- Não há APK confirmado no repositório neste momento.

## Caminho sem computador próprio

Uma máquina de compilação precisa executar Unreal Engine e as ferramentas Android compatíveis. O GitHub Actions padrão não inclui automaticamente a Unreal Engine; um runner próprio precisa de uma máquina configurada, conforme a documentação oficial do GitHub: https://docs.github.com/en/actions/reference/runners/self-hosted-runners

### Opção A — serviço gerenciado de build para Unreal

O SpeedrunCI anuncia builds na nuvem para Unreal e Android: https://speedrun.ci/ . A página pública informa teste gratuito e plano Starter a partir de US$ 99/mês para um projeto, com Android incluído. O plugin é gratuito, mas o serviço de build não é apresentado como gratuito de forma permanente. Fonte consultada em 2026-10-29: https://speedrun.ci/ e https://www.fab.com/listings/8a93b442-e39e-4ffa-94b6-cd754cd3c34a?lang=pt-br

Como não há orçamento autorizado, não contratar nem iniciar um plano pago. Antes de usar o teste, confirmar no próprio serviço:
1. Se aceita este projeto Unreal 5.6 em C++.
2. Como funciona a autorização/licença da Unreal Engine no ambiente gerenciado.
3. Se o teste gratuito cobre uma compilação Android completa.
4. Como conectar o repositório e obter o APK como artefato.

Não presumir que seja gratuito nem inserir credenciais da Epic, tokens privados ou chaves de assinatura no repositório.

### Opção B — runner GitHub próprio

Só é viável quando houver acesso a uma máquina compatível que possa receber a Unreal Engine e o Android SDK/NDK/JDK. Não existe runner configurado automaticamente por este repositório.

## Ordem correta para o primeiro APK

1. Validar a estrutura dos arquivos.
2. Compilar o módulo C++ na Unreal 5.6.
3. Corrigir erros reais de compilação.
4. Executar o script de criação do pré-lobby no Editor e salvar `L_NEXUS_PreLobby.umap`.
5. Empacotar um APK Android de desenvolvimento.
6. Instalar e testar no Samsung Galaxy S10 Lite.
7. Só então afirmar que há um protótipo jogável.

## Arquivos C++ essenciais

Foram adicionados os arquivos de implementação do módulo principal e da classe de modo de jogo, que estavam ausentes no repositório. O modo de jogo aponta para o personagem de pré-lobby. Isso corrige uma lacuna estrutural, mas a compilação ainda precisa confirmar se o código é aceito pela Unreal 5.6.

## Limitações atuais

A validação de arquivos não substitui compilação C++, geração de mapa, empacotamento ou teste no aparelho. Até essas etapas acontecerem, o projeto é um scaffold técnico inicial, não um Battle Royale jogável.
