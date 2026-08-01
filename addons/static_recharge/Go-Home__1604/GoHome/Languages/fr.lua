------------------------------------------
--	French language file for Go Home	--
------------------------------------------

--[[
Template stringID function
ZO_CreateStringId("GO_HOME_UniqueStringID", "Text")
]]--

--[[
HotkeyType translations
]]--
ZO_CreateStringId("GO_HOME_HotkeyTypePrimary", "Primaire")
ZO_CreateStringId("GO_HOME_HotkeyTypeSpecific", "Spécifique")
ZO_CreateStringId("GO_HOME_HotkeyTypeCharacter", "Personnage")
ZO_CreateStringId("GO_HOME_HotkeyTypeAccountName", "Nom du compte")
ZO_CreateStringId("GO_HOME_HotkeyTypeGuild", "Guilde")

--[[
GetCurrentHouseInfo() translations
]]--
ZO_CreateStringId("GO_HOME_PlayerNotInKnownHouse", "Vous n'êtes pas actuellement dans une maison connue.")
ZO_CreateStringId("GO_HOME_CurrentHouseDataTitle", "Données actuelles de la maison")
ZO_CreateStringId("GO_HOME_HouseIDLabel", "ID de la maison: ")
ZO_CreateStringId("GO_HOME_CollectibleIDLabel", "ID de collection: ")
ZO_CreateStringId("GO_HOME_HouseNameLabel", "Prénom: ")
ZO_CreateStringId("GO_HOME_HouseNicknameLabel", "Surnom: ")

--[[
Travel to house translations
]]--
ZO_CreateStringId("GO_HOME_TravelToPlayerPrimaryHouse", "Voyager vers votre maison principale, ")
ZO_CreateStringId("GO_HOME_TravelToTextStart", "Voyager vers ")
ZO_CreateStringId("GO_HOME_TravelToAccountPrimaryEnd", "'s La maison principale.")
ZO_CreateStringId("GO_HOME_TravelToAccountSpecificEnd", "'s ")
ZO_CreateStringId("GO_HOME_TravelToGuildEnd", "'s La maison de la guilde.")
ZO_CreateStringId("GO_HOME_TravelOutside", " (Dehors)")
ZO_CreateStringId("GO_HOME_TravelInside", " (À l'intérieur)")

--[[
Chat context menu translations
]]--
ZO_CreateStringId("GO_HOME_ContextTravelToPrimaryLabel", "Voyage à la maison primaire")

--[[
Settings menu translations
]]--
ZO_CreateStringId("GO_HOME_SettingsPrimaryHouseLabel", "Maison Primaire")
ZO_CreateStringId("GO_HOME_SettingsSetPrimaryHouseLabel", "Définir la maison primaire")
ZO_CreateStringId("GO_HOME_SettingsKeybindingsLabel", "Raccourcis clavier")
ZO_CreateStringId("GO_HOME_SettingsHotkeySubmenuLabel", "Hotkey ")
ZO_CreateStringId("GO_HOME_SettingsHouseTypeLabel", "Type de maison")
ZO_CreateStringId("GO_HOME_SettingsSpecificHouseLabel", "Maison spécifique")
ZO_CreateStringId("GO_HOME_SettingsCharacterHouseLabel", "Maison de caractère")
ZO_CreateStringId("GO_HOME_SettingsAccountNameLabel", "Nom du compte")
ZO_CreateStringId("GO_HOME_SettingsAccountHouseLabel", "Maison du compte")
ZO_CreateStringId("GO_HOME_SettingsAccountPrimaryHouseLabel", "Compte Maison Primaire")
ZO_CreateStringId("GO_HOME_SettingsGuildHouseLabel", "Maison de la guilde")
ZO_CreateStringId("GO_HOME_SettingsSettingsLabel", "Paramètres")
ZO_CreateStringId("GO_HOME_SettingsChatMessagesLabel", "Messages de chat")
ZO_CreateStringId("GO_HOME_SettingsHouseNicknamesLabel", "Surnoms de maison")
ZO_CreateStringId("GO_HOME_SettingsReloadUILabel", "Recharger l'interface utilisateur")
ZO_CreateStringId("GO_HOME_SettingsOutsideLabel", "Dehors")
ZO_CreateStringId("GO_HOME_SettingsClearHotkeyLabel", "Effacer la liaison des touches")

--[[
Hotkey translations
]]--
ZO_CreateStringId("GO_HOME_HotkeyLabel", "Raccourci")

--[[
Tooltip translations
]]--
ZO_CreateStringId("GO_HOME_TooltipSetPrimaryHouse", "Changer ce paramètre changera votre maison principale sans devoir d'abord y aller.")
ZO_CreateStringId("GO_HOME_TooltipHouseType", "Primaire = votre maison principale\nSpécifique = une maison spécifique de la vôtre\nCaractère = Maison spécifique au personnage\nNom du compte = voyager vers un nom de compte\nGuilde = La maison principale du chef de guilde")
ZO_CreateStringId("GO_HOME_TooltipSpecificHouse", "Si vous avez récemment acheté une maison, vous devrez la recharger pour voir toutes les options.")
ZO_CreateStringId("GO_HOME_TooltipAccountName", "Doit commencer par @.")
ZO_CreateStringId("GO_HOME_TooltipAccountHouse", "Si vous voulez vous rendre chez quelqu'un qui n'est pas le leur, sélectionnez-le dans la liste. L'addon ne peut pas dire quelles maisons ils possèdent, donc tous sont listés.")
ZO_CreateStringId("GO_HOME_TooltipAccountPrimaryHouse", "Remplacera l'option \"Compte maison\" et vous emmènera à leur maison principale à la place.")
ZO_CreateStringId("GO_HOME_TooltipGuildHouse", "Vous téléporte à la maison principale du chef de guilde. Si la maison de guilde est autre que le chef de guilde, utilisez plutôt l'option \"Nom du compte\".")
ZO_CreateStringId("GO_HOME_TooltipChatMessages", "Tous les messages de discussion seront désactivés si cette option est désactivée.")
ZO_CreateStringId("GO_HOME_TooltipHouseNicknames", "Si cette option est activée, les noms des maisons que vous possédez seront remplacés par leurs surnoms dans cet addon. Vous pouvez utiliser cette fonctionnalité pour \"renommer\" vos maisons.")
ZO_CreateStringId("GO_HOME_TooltipNeedToReloadUI", "Ce paramètre est spécifique au personnage.")
ZO_CreateStringId("GO_HOME_TooltipOutside", "Sélectionnez pour vous rendre à l'extérieur de la maison.")
ZO_CreateStringId("GO_HOME_TooltipHotkeySelection", "Sélectionnez le raccourci clavier à modifier.")