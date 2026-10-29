# NEXUS — Plano do protótipo de pré-lobby

## Objetivo
A primeira fatia jogável será uma área 3D de espera em primeira pessoa, onde o jogador poderá andar e olhar ao redor antes da contagem regressiva.

## Requisitos do protótipo
- Câmera em primeira pessoa.
- Movimento básico com parâmetros ajustáveis.
- Área compacta com chão, limites visíveis e objetos simples para avaliar escala.
- Estado de espera e contagem regressiva inicialmente local.
- Interface legível em tela de celular.
- Planejamento para perfis gráficos Suave, Padrão e Ultra.

## Critérios de aceite
1. O projeto abre numa versão definida da Unreal Engine.
2. O jogador aparece no ponto de início e permanece dentro do cenário.
3. Movimento e câmera funcionam com controles de toque.
4. O cenário é testado no aparelho-alvo e o desempenho é medido.
5. A automação informa claramente se a compilação Android terminou ou qual pré-requisito está faltando.

## Restrições reais
- Este documento não é uma cena jogável nem um APK.
- GitHub Actions hospedado não inclui Unreal Engine por padrão.
- Para empacotar Android, será necessário um runner com Unreal Engine instalada e autorizada, além de Android SDK/NDK e JDK compatíveis.
- Não colocar credenciais nem arquivos privados da engine no repositório.

## Ordem de implementação
1. Confirmar a versão da Unreal e criar o projeto base.
2. Adicionar mapa de pré-lobby e personagem.
3. Configurar os controles touch.
4. Preparar runner e empacotamento Android.
5. Gerar APK de desenvolvimento e testar no S10 Lite.
6. Só depois ampliar para armas, eventos e multiplayer.
