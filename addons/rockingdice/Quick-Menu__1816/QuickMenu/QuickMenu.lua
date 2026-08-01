------------------
--LOAD LIBRARIES--
------------------

--load LibAddonsMenu-2.0
local LAM2 = LibStub:GetLibrary("LibAddonMenu-2.0");

----------------------
--INITIATE VARIABLES--
----------------------

ZO_CreateStringId("SI_BINDING_NAME_QUICK_MENU", "Quick Menu") 

local function triggerAddonLoaded(eventCode, addonName)
  if  (addonName == QuickMenu.name) then
    EVENT_MANAGER:UnregisterForEvent(QuickMenu.name, EVENT_ADD_ON_LOADED);
    QuickMenu.acctSavedVariables = ZO_SavedVars:NewAccountWide('QuickMenuSavedVars', 1.0, nil, QuickMenu.presets12)
	QuickMenu.AddonMenuInit()
  end
end
 
function QuickMenu.ResetToDefaults()
	QuickMenu.acctSavedVariables.slots = QuickMenu.presets12.slots
	QuickMenu.acctSavedVariables.slotsCount = QuickMenu.presets12.slotsCount
end

function QuickMenu:CreateGamepadRadialMenu()
    self.gamepadMenu = ZO_RadialMenu:New(QuickMenu_Gamepad, "ZO_RadialMenuHUDEntryTemplate_Gamepad", "DefaultRadialMenuAnimation", "DefaultRadialMenuEntryAnimation", "RadialMenu")
    self.gamepadMenu:SetOnClearCallback(function() self:StopInteraction() end)
end 

function QuickMenu:CreateKeyboardRadialMenu()
    self.keyboardMenu = ZO_RadialMenu:New(QuickMenu_Keyboard, "ZO_PlayerToPlayerMenuEntryTemplate_Keyboard", "DefaultRadialMenuAnimation", "DefaultRadialMenuEntryAnimation", "RadialMenu")
    self.keyboardMenu:SetOnClearCallback(function() self:StopInteraction() end)
end

function QuickMenu:GetRadialMenu()
    if IsInGamepadPreferredMode() then
        if not self.gamepadMenu then
            self:CreateGamepadRadialMenu()
        end
        return self.gamepadMenu
    else
        if not self.keyboardMenu then
            self:CreateKeyboardRadialMenu()
        end
        return self.keyboardMenu
    end
end



function QuickMenu:AddMenuEntry(text, icons, enabled, selectedFunction, errorReason)
    local normalIcon = enabled and icons.enabledNormal or icons.disabledNormal
    local selectedIcon = enabled and icons.enabledSelected or icons.disabledSelected 
	if not enabled then
		selectedFunction = nil 
	end
    self:GetRadialMenu():AddEntry(text, normalIcon, selectedIcon, selectedFunction, errorReason)
end 

function QuickMenu:StartInteraction()
    if not SCENE_MANAGER:IsInUIMode() then
        if not self.isInteracting then 
			
			--add entries
			local platformIcons = IsInGamepadPreferredMode() and QuickMenu.GAMEPAD_MENU_ENTRIES or QuickMenu.KEYBOARD_MENU_ENTRIES
			  
			local function AddMenuEntry(menuEntryId)
				if menuEntryId then
					if type(menuEntryId) == "number" then
						local function SelectEntry(entryId)  
							local function CallbackSelectEntry()
								local entry = platformIcons[entryId]
								if entry then
									if entry.callback then
										entry.callback()
									else
										if entry.scene then  
											SCENE_MANAGER:Push(entry.scene)
										elseif entry.scenegroup and entry.descriptor then
											MAIN_MENU_KEYBOARD:ShowSceneGroup(entry.scenegroup, entry.descriptor)
										end
									end
								end
							end 
							return CallbackSelectEntry
						end 
						
						local enabled = true
						local name = GetString(menuEntryId)
						local callback = SelectEntry(menuEntryId)
						if menuEntryId == SI_MAIN_MENU_SKILLS and IsInGamepadPreferredMode() then
							if not GAMEPAD_SKILLS.categoryKeybindStripDescriptor then
								--not initialized yet, make it disabled
								enabled = false
								name = string.format("%s\n(Need Open Manually First)", name)
							end
						end
						if menuEntryId == SI_MAIN_MENU_INVENTORY and IsInGamepadPreferredMode() and not (BUI and BUI.Settings.Modules["Inventory"].m_enabled) then
							if not GAMEPAD_INVENTORY.initialized then
								enabled = false
								name = string.format("%s\n(Need Open Manually First)", name)
							end
						end
						
						if platformIcons[menuEntryId] then
							self:AddMenuEntry(name, platformIcons[menuEntryId], enabled, callback )
						else
							self:AddMenuEntry(GetString(SI_QUICKSLOTS_EMPTY), platformIcons[SI_QUICKSLOTS_EMPTY], true, nil )
						end
					elseif type(menuEntryId) == "string" then
						local entry = platformIcons[menuEntryId]
						if entry then
							local icon = entry.icon
							local name = entry.name
							local callback = entry.callback
							self:AddMenuEntry(name, entry, true, callback)
						else
							self:AddMenuEntry(GetString(SI_QUICKSLOTS_EMPTY), platformIcons[SI_QUICKSLOTS_EMPTY], true, nil )
						end
					end
				end
			end
			for i = 1, QuickMenu.acctSavedVariables.slotsCount do
				AddMenuEntry(QuickMenu.acctSavedVariables.slots[i])
			end
			AddMenuEntry(SI_RADIAL_MENU_CANCEL_BUTTON) 
			--[[
			AddMenuEntry(SI_JOURNAL_MENU_QUESTS)
			AddMenuEntry(SI_JOURNAL_MENU_CADWELLS_ALMANAC)
			AddMenuEntry(SI_JOURNAL_MENU_LORE_LIBRARY)
			AddMenuEntry(SI_JOURNAL_MENU_ACHIEVEMENTS)
			AddMenuEntry(SI_JOURNAL_MENU_LEADERBOARDS)
			AddMenuEntry(SI_MAIN_MENU_CHARACTER)
			AddMenuEntry(SI_MAIN_MENU_SKILLS) 
			AddMenuEntry(SI_MAIN_MENU_CHAMPION) 
			AddMenuEntry(SI_MAIN_MENU_MARKET) 
			AddMenuEntry(SI_MAIN_MENU_INVENTORY)
			AddMenuEntry(SI_MAIN_MENU_ALLIANCE_WAR) 
			AddMenuEntry(SI_MAIN_MENU_MAP)  
			AddMenuEntry(SI_WINDOW_TITLE_FRIENDS_LIST) 
			AddMenuEntry(SI_IGNORE_LIST_PANEL_TITLE) 
			AddMenuEntry(SI_MAIN_MENU_GUILDS)
			AddMenuEntry(SI_MAIN_MENU_MAIL)
			AddMenuEntry(SI_MAIN_MENU_NOTIFICATIONS)
			AddMenuEntry(SI_MAIN_MENU_GROUP)
			AddMenuEntry(SI_MAIN_MENU_COLLECTIONS)
			AddMenuEntry(SI_MAIN_MENU_ACTIVITY_FINDER) 
			AddMenuEntry(SI_MAIN_MENU_CROWN_CRATES)
			AddMenuEntry(SI_RADIAL_MENU_CANCEL_BUTTON)
			]]--
			
			local menu = self:GetRadialMenu()
			menu:Show()
			
			
			LockCameraRotation(true)
			RETICLE:RequestHidden(true)
			self.isInteracting = true 
			
        end
    end
end
 
function QuickMenu:StopInteraction()     
    if self.isInteracting then
        self.isInteracting = false
        RETICLE:RequestHidden(false)
        LockCameraRotation(false)
        self:GetRadialMenu():SelectCurrentEntry()
        self:GetRadialMenu():Clear()
    end 
end

function QuickMenu:ShowMenu() 
	self:StartInteraction()
end

function QuickMenu:HideMenu() 
	self:StopInteraction()
end
 
local function commandExec()
end
 
--== Slash command ==--
function QuickMenu.cmd( text )
	if text == nil then text = true end
    LAM2:OpenToPanel(QUICKMENU_ADDONMENU) 
	local addons = LAM2.addonList:GetChild(1)
	if addons:GetNumChildren() ~= 0 then
		for a=1,addons:GetNumChildren(),1 do 
			if addons:GetChild(a):GetText() == QuickMenu.settingName then
				addons:GetChild(a):SetSelected(true)
				break
			end	
		end
	end	
	--Second time's the charm
	if text then
		zo_callLater(function()QuickMenu.cmd(false)end,500)
	end
end
SLASH_COMMANDS["/qm"] = QuickMenu.cmd
EVENT_MANAGER:RegisterForEvent(QuickMenu.name, EVENT_ADD_ON_LOADED, triggerAddonLoaded);  