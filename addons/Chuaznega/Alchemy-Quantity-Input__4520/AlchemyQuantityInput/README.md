# AlchemyQuantityInput — ESO Addon (Update 49)

Substitui o display de quantidade na mesa de alquimia por uma **caixa de texto editável**, permitindo digitar qualquer número diretamente (ex: 1 a 9999+).

## Instalação

1. Copie a pasta `AlchemyQuantityInput` para:
   ```
   C:\Users\<SeuUsuário>\Documents\Elder Scrolls Online\live\AddOns\
   ```
2. Abra o ESO → no menu de personagem clique em **Add-Ons** → ative **Alchemy Quantity Input**.
3. Faça login normalmente.

## Como usar

- Abra qualquer **mesa de alquimia**.
- O campo de número ao lado de `−` e `+` vira uma caixa de texto.
- **Clique** nela, **digite** o número desejado (ex: `500`) e pressione **Enter** ou clique fora.
- Os botões `−` e `+` continuam funcionando normalmente.

## Comandos de chat

| Comando | Descrição |
|---------|-----------|
| `/aqi`  | Debug: mostra no chat se o spinner foi encontrado. Útil após atualizações do jogo. |

## Resolução de problemas

### A caixa não aparece após uma atualização do jogo
A Zenimax pode renomear controles internos entre patches. Use `/aqi` no chat **dentro da estação de alquimia** para ver quais nomes estão disponíveis.

Se nenhum nome for encontrado:
1. Abra `AlchemyQuantityInput.lua`
2. Localize a tabela `SPINNER_CTRL_NAMES`
3. Adicione o novo nome do controle

### Como descobrir o nome correto do controle
Instale o addon **zgoo** (disponível no Minion/ESOUI) e use `/zgoo mouse` clicando no campo de quantidade para inspecionar o nome do controle em tempo real.

## Compatibilidade

- **ESO Update 49** (APIVersion 101049)
- Não conflita com outros addons de alquimia como AlchemyTooltips, pois apenas sobrepõe o display de quantidade.
