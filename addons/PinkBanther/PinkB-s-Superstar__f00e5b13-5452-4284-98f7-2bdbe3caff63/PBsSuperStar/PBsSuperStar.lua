local P = PBsSuperStar

function P:Open()
    SCENE_MANAGER:Push(self.sceneName)
end

function P:InstallMenu()
    if self.menuInstalled or not ZO_MENU_ENTRIES then return end
    for _, entry in ipairs(ZO_MENU_ENTRIES) do
        if entry.data and entry.data.scene == self.sceneName then self.menuInstalled = true; return end
    end
    local name = "ステータス超詳細"
    local icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_character.dds"
    local entry = ZO_GamepadEntryData:New(name, icon)
    entry:SetIconTintOnSelection(true)
    entry:SetIconDisabledTintOnSelection(true)
    entry:SetEnabled(true)
    entry.id = self.name -- String key avoids colliding with built-in numeric category IDs.
    entry.data = {name = name, icon = icon, scene = self.sceneName}
    local insertAt = #ZO_MENU_ENTRIES + 1
    for index, menuEntry in ipairs(ZO_MENU_ENTRIES) do
        if menuEntry.data and menuEntry.data.scene == "gamepad_stats_root" then
            insertAt = index + 1
            break
        end
    end
    -- Keep the previous end-of-menu placement if the character entry is unavailable.
    table.insert(ZO_MENU_ENTRIES, insertAt, entry)
    self.menuInstalled = true
end

function P:Initialize()
    local U = self.UI
    self.scene = ZO_Scene:New(self.sceneName, SCENE_MANAGER)
    self.scene:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
    local binds = U:Keybinds()
    self.scene:RegisterCallback("StateChange", function(_, state)
        if state == SCENE_SHOWING then
            KEYBIND_STRIP:AddKeybindButtonGroup(binds)
            U:BeginCreate(function()
                U:Resize()
                U:Refresh()
                if not self.fragment then
                    self.fragment = ZO_FadeSceneFragment:New(U.root)
                    self.scene:AddFragment(self.fragment)
                end
                -- Poll only after construction and while visible.
                EVENT_MANAGER:RegisterForUpdate(self.name .. "Refresh", 1500, function() U:Refresh() end)
            end)
        elseif state == SCENE_HIDING then
            U:PauseCreate()
            EVENT_MANAGER:UnregisterForUpdate(self.name .. "Refresh")
            KEYBIND_STRIP:RemoveKeybindButtonGroup(binds)
        end
    end)
    self:InstallMenu()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:InstallMenu() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SCREEN_RESIZED, function() U:Resize() end)
    -- Development convenience on PC. Console entry point is the gamepad main menu.
    SLASH_COMMANDS["/pbss"] = function() self:Open() end
end

EVENT_MANAGER:RegisterForEvent(P.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= P.name then return end
    EVENT_MANAGER:UnregisterForEvent(P.name, EVENT_ADD_ON_LOADED)
    P:Initialize()
end)
