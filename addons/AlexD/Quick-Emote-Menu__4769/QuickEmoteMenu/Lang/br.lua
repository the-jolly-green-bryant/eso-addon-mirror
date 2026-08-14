local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "Categorias",
    SI_QUICKEMOTEMENU_FAVORITES            = "Favoritos",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(vazio)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "Alternar",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "Atraso hover submenu (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = abrir apenas no clique",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "Fechar menu após emote (clique esquerdo)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "Redefinir posição do botão",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FFCONTROLES|r
• Clique esquerdo no botão para abrir ou fechar o menu
• Clique direito e arraste o botão para movê-lo
• Clique esquerdo em um emote para reproduzi-lo
• Clique direito em um emote para adicionar ou remover dos Favoritos

|c3399FFMENUS|r
• Categorias — navegar emotes por categoria
• Favoritos — acesso rápido aos emotes salvos
• Submenus abrem no hover ou clique (ver atraso)
• Menus abrem acima/abaixo e esq./dir. conforme posição do botão

|c3399FFDICAS|r
• Use o atalho para alternar o menu
• /qempanel abre este painel de configurações
• Favoritos são salvos em toda a conta]],
}

for stringId, stringValue in pairs(strings) do
    SafeAddString(_G[stringId], stringValue, 2)
end
