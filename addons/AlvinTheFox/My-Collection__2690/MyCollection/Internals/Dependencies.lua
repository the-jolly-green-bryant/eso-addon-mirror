local Dependencies = MyCollection.Internals.Dependencies

Dependencies.LibSavedVars = LibSavedVars -- https://www.esoui.com/downloads/info2161-LibSavedVars.html
--Dependencies.LibAddonMenu = LibAddonMenu2 -- https://www.esoui.com/downloads/info7-LibAddonMenu.html -- KEY: LibAddonMenu-2.0
Dependencies.LibMainMenu = LibMainMenu2 -- https://cdn.esoui.com/downloads/info2118-LibMainMenu-2.0.html
--Dependencies.LibDialog = LibDialog -- https://www.esoui.com/downloads/info1931-LibDialog-Customconfirmationdialogwith2buttons.html
Dependencies.LibSets = LibSets -- https://www.esoui.com/downloads/info2241-LibSets.html
if LibDebugLogger ~= nil then
  Dependencies.Logger = LibDebugLogger("MyCollection") -- https://www.esoui.com/downloads/info2275-LibDebugLogger.html
else
  Dependencies.Logger = nil
end

-- Zenimax API's
Dependencies.Officials = {}
Dependencies.Officials.EventManager = EVENT_MANAGER
Dependencies.Officials.SceneManager = SCENE_MANAGER
Dependencies.Officials.SlashCommands = SLASH_COMMANDS
Dependencies.Officials.SharedInventory = SHARED_INVENTORY -- http://esodata.uesp.net/100031/src/ingame/inventory/sharedinventory.lua.html
Dependencies.Officials.GetItemArmorType = GetItemArmorType -- https://wiki.esoui.com/GetItemArmorType
Dependencies.Officials.GetItemInfo = GetItemInfo -- https://wiki.esoui.com/GetItemInfo
Dependencies.Officials.GetItemLink = GetItemLink -- https://wiki.esoui.com/GetItemLink
Dependencies.Officials.GetItemLinkIcon = GetItemLinkIcon
Dependencies.Officials.GetItemTrait = GetItemTrait -- https://wiki.esoui.com/GetItemTrait
Dependencies.Officials.GetItemWeaponType = GetItemWeaponType -- https://wiki.esoui.com/GetItemWeaponType
Dependencies.Officials.GetCurrentCharacterId = GetCurrentCharacterId -- https://wiki.esoui.com/GetCurrentCharacterId

---- Possible Libs for future consideration
-- https://www.esoui.com/downloads/info808-LibItemInfo.html
-- https://www.esoui.com/downloads/info2423-111693.html
-- https://www.esoui.com/downloads/info989-LibMainMenu.html
-- https://www.esoui.com/downloads/info2125-LibAsync.html
-- https://www.esoui.com/downloads/info1146-LibCustomMenu.html