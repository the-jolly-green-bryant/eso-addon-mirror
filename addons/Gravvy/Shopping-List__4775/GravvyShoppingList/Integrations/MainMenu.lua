ShoppingListMainMenu = {}

local MainMenu = ShoppingListMainMenu

function MainMenu:Initialize(owner)
    local menu = LibMainMenu2
    menu:Init()
    menu:AddMenuItem("GravvyShoppingListMainMenu", {
        binding = "SHOPPING_LIST_TOGGLE",
        categoryName = SI_SHOPPING_LIST_TITLE,
        callback = function()
            owner:ToggleWindow()
        end,
        visible = function()
            return true
        end,
        normal = "EsoUI/Art/Journal/journal_quests_tabIcon_up.dds",
        pressed = "EsoUI/Art/Journal/journal_quests_tabIcon_down.dds",
        highlight = "EsoUI/Art/Journal/journal_quests_tabIcon_over.dds",
        disabled = "EsoUI/Art/Journal/journal_quests_tabIcon_disabled.dds",
    })
end
