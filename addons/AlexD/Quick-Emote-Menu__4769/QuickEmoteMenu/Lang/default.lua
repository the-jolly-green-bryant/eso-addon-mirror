local strings = {
    SI_QUICKEMOTEMENU_UNKNOWN_NAME         = "?",
    SI_QUICKEMOTEMENU_CATEGORIES           = "Categories",
    SI_QUICKEMOTEMENU_FAVORITES            = "Favorites",
    SI_QUICKEMOTEMENU_NO_FAVORITES         = "(empty)",
    SI_QUICKEMOTEMENU_BINDING_TOGGLE       = "Toggle",
    SI_QUICKEMOTEMENU_OPTION_HOVER         = "Submenu hover delay (ms)",
    SI_QUICKEMOTEMENU_OPTION_HOVER_TOOLTIP = "0 = open only on click",
    SI_QUICKEMOTEMENU_OPTION_CLOSE         = "Close menu after playing emote (left-click)",
    SI_QUICKEMOTEMENU_OPTION_RESET         = "Reset button position",
    SI_QUICKEMOTEMENU_OPTION_DESCRIPTION   = [[|c3399FFCONTROLS|r
• Left-click the button to open or close the menu
• Right-click and drag the button to move it
• Left-click an emote to play it
• Right-click an emote to add or remove it from Favorites

|c3399FFMENUS|r
• Categories — browse emotes by category
• Favorites — quick access to saved emotes
• Submenus open on hover or click (see delay setting)
• Menus open above/below and left/right based on button position

|c3399FFTIPS|r
• Use the keybind to toggle the menu
• /qempanel opens this settings panel
• Favorites are saved account-wide]],
}

for stringId, stringValue in pairs(strings) do
    ZO_CreateStringId(stringId, stringValue)
    SafeAddVersion(_G[stringId], 1)
end
