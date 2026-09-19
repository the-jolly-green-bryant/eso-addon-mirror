local P = PBsUltraDetailedStats

function P:Open()
    SCENE_MANAGER:Push(self.sceneName)
end

-- While the screen is open the game's keybind strip (戻る・再取得・…) is made shorter and moved
-- down, so it sits below the description pane rather than over it. KEYBIND_STRIP:SetStyle is
-- the strip's own public way to restyle it; the previous style comes back when the screen
-- closes, and only if nothing else has restyled the strip in the meantime.
local STRIP_DROP = 30
function P:CompactKeybindStrip()
    if self.savedStripStyle or not (KEYBIND_STRIP and KEYBIND_STRIP.GetStyle and KEYBIND_STRIP.SetStyle) then return end
    local style = KEYBIND_STRIP:GetStyle()
    if not style then return end
    local compact = {}
    for key, value in pairs(style) do compact[key] = value end
    compact.nameFont = "ZoFontGamepad27"
    compact.yAnchorOffset = (style.yAnchorOffset or 0) + STRIP_DROP
    self.savedStripStyle, self.compactStripStyle = style, compact
    KEYBIND_STRIP:SetStyle(compact)
    local background = ZO_KeybindStripGamepadBackground
    if background then
        self.savedStripHeight = background:GetHeight()
        background:SetHeight(math.max(0, self.savedStripHeight - STRIP_DROP))
    end
end

function P:RestoreKeybindStrip()
    if not self.savedStripStyle then return end
    if KEYBIND_STRIP:GetStyle() == self.compactStripStyle then KEYBIND_STRIP:SetStyle(self.savedStripStyle) end
    if self.savedStripHeight and ZO_KeybindStripGamepadBackground then
        ZO_KeybindStripGamepadBackground:SetHeight(self.savedStripHeight)
    end
    self.savedStripStyle, self.compactStripStyle, self.savedStripHeight = nil, nil, nil
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
            self:CompactKeybindStrip()
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
            self:RestoreKeybindStrip()
        end
    end)
    self:InstallMenu()
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_PLAYER_ACTIVATED, function() self:InstallMenu() end)
    EVENT_MANAGER:RegisterForEvent(self.name, EVENT_SCREEN_RESIZED, function() U:Resize() end)
    -- Development convenience on PC. Console entry point is the gamepad main menu.
    SLASH_COMMANDS["/pbuds"] = function() self:Open() end
end

EVENT_MANAGER:RegisterForEvent(P.name, EVENT_ADD_ON_LOADED, function(_, addonName)
    if addonName ~= P.name then return end
    EVENT_MANAGER:UnregisterForEvent(P.name, EVENT_ADD_ON_LOADED)
    P:Initialize()
end)
