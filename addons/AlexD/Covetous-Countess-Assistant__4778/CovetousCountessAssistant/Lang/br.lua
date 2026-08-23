local strings = {
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS
        = "Rastrear a Condessa Cobiçosa",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_COUNTESS_TOOLTIP
        = "Marcar tesouros utilizáveis nas caçadas da Condessa Cobiçosa.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW
        = "Rastrear o Tesoureiro de Tributos",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_TRACK_CROW_TOOLTIP
        = "Marcar tesouros utilizáveis nas caçadas do Tesoureiro de Tributos (Corvo).",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_SETTINGS
        = "Configurações",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_ON
        = "Rastreamento Condessa Cobiçosa: LIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_COUNTESS_OFF
        = "Rastreamento Condessa Cobiçosa: DESLIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_ON
        = "Rastreamento Tesoureiro de Tributos: LIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_CROW_OFF
        = "Rastreamento Tesoureiro de Tributos: DESLIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS
        = "Destacar itens de missão",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_HIGHLIGHT_QUEST_ITEMS_TOOLTIP
        = "Exibe os ícones em verde quando os itens correspondem às tags da missão ativa.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_ON
        = "Destaque de itens de missão: ATIVADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_HIGHLIGHT_OFF
        = "Destaque de itens de missão: DESATIVADO",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD
        = "Ignorar ofertas do Quadro de Dicas",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_TOOLTIP
        = "Fecha automaticamente as ofertas do Quadro de Dicas que não sejam da Condessa Cobiçosa.",
    SI_COVETOUSCOUNTESSASSISTANT_OPTION_AUTOSKIP_TIPBOARD_WARNING
        = "Isso fechará automaticamente os diálogos que não forem da Condessa.",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_ON
        = "Ignorar Quadro de Dicas: LIGADO",
    SI_COVETOUSCOUNTESSASSISTANT_MSG_AUTOSKIP_OFF
        = "Ignorar Quadro de Dicas: DESLIGADO",
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
