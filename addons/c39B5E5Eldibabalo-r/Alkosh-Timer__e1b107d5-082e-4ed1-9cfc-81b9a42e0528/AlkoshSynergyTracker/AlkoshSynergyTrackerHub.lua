-- Shared Eldibabalo Tracking Tools hub (created once; used by all tracker addons).

function AST_EnsureTrackingToolsHub()
    if ELDIBABALO_TRACKING_TOOLS then
        return true
    end

    local ok = pcall(function()
        local TT = { entries = {}, sceneName = "eldibabaloTrackingToolsScene", selectedRow = 1, rows = {} }
        local ROW_H, MAX_ROWS = 60, 10

        local win = WINDOW_MANAGER:CreateTopLevelWindow("TT_HubWindow")
        win:SetDimensions(1200, 800)
        win:SetAnchor(CENTER)
        win:SetHidden(true)
        win:SetMouseEnabled(true)
        win:SetMovable(true)
        win:SetClampedToScreen(true)

        local bg = WINDOW_MANAGER:CreateControl("TT_HubBG", win, CT_TEXTURE)
        bg:SetAnchorFill()
        bg:SetColor(0.05, 0.05, 0.05, 0.97)

        local bdr = WINDOW_MANAGER:CreateControl("TT_HubBorder", win, CT_BACKDROP)
        bdr:SetAnchorFill()
        bdr:SetCenterColor(0, 0, 0, 0)
        bdr:SetEdgeColor(0.91, 0.75, 0.36, 1)
        bdr:SetEdgeTexture("", 2, 2, 2, 0)

        local ttl = WINDOW_MANAGER:CreateControl("TT_HubTitle", win, CT_LABEL)
        ttl:SetFont("$(BOLD_FONT)|36|soft-shadow-thick")
        ttl:SetColor(0.91, 0.75, 0.36, 1)
        ttl:SetAnchor(TOP, win, TOP, 0, 30)
        ttl:SetDimensions(800, 40)
        ttl:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
        ttl:SetText("Tracking Tools")

        local sep = WINDOW_MANAGER:CreateControl("TT_HubSep", win, CT_TEXTURE)
        sep:SetColor(0.91, 0.75, 0.36, 0.4)
        sep:SetAnchor(TOPLEFT, win, TOPLEFT, 20, 80)
        sep:SetDimensions(1160, 1)

        for i = 1, MAX_ROWS do
            local yOff = 100 + (i - 1) * ROW_H
            local pf = "TT_HubRow" .. i
            local row = WINDOW_MANAGER:CreateControl(pf, win, CT_CONTROL)
            row:SetDimensions(1160, ROW_H)
            row:SetAnchor(TOPLEFT, win, TOPLEFT, 20, yOff)
            row:SetMouseEnabled(true)

            local hl = WINDOW_MANAGER:CreateControl(pf .. "HL", row, CT_TEXTURE)
            hl:SetColor(0.91, 0.75, 0.36, 0.08)
            hl:SetAnchorFill()
            hl:SetHidden(true)

            local selHL = WINDOW_MANAGER:CreateControl(pf .. "SHL", row, CT_TEXTURE)
            selHL:SetColor(0.91, 0.75, 0.36, 0.22)
            selHL:SetAnchorFill()
            selHL:SetHidden(true)

            row:SetHandler("OnMouseEnter", function() hl:SetHidden(false) end)
            row:SetHandler("OnMouseExit", function() hl:SetHidden(true) end)
            local idx = i
            row:SetHandler("OnMouseUp", function(_, button)
                if button == MOUSE_BUTTON_INDEX_LEFT then
                    TT.selectedRow = idx
                    TT:OpenSelected()
                end
            end)

            local ic = WINDOW_MANAGER:CreateControl(pf .. "IC", row, CT_TEXTURE)
            ic:SetDimensions(40, 40)
            ic:SetAnchor(LEFT, row, LEFT, 20, 0)

            local lb = WINDOW_MANAGER:CreateControl(pf .. "LB", row, CT_LABEL)
            lb:SetFont("$(BOLD_FONT)|28|soft-shadow-thin")
            lb:SetColor(1, 1, 1, 1)
            lb:SetAnchor(LEFT, ic, RIGHT, 16, 0)
            lb:SetDimensions(900, ROW_H)
            lb:SetVerticalAlignment(TEXT_ALIGN_CENTER)

            TT.rows[i] = { control = row, highlight = hl, selectHL = selHL, icon = ic, label = lb }
        end

        function TT:Register(name, iconPath, scene)
            for _, e in ipairs(self.entries) do
                if e.scene == scene then
                    return
                end
            end
            table.insert(self.entries, { name = name, icon = iconPath, scene = scene })
        end

        function TT:RefreshList()
            for i = 1, MAX_ROWS do
                local slot, entry = self.rows[i], self.entries[i]
                slot.selectHL:SetHidden(i ~= self.selectedRow)
                if entry then
                    slot.control:SetHidden(false)
                    local iconPath = entry.icon
                    if type(iconPath) ~= "string" or iconPath == "" then
                        iconPath = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds"
                    end
                    pcall(function() slot.icon:SetTexture(iconPath) end)
                    slot.label:SetText(entry.name)
                else
                    slot.control:SetHidden(true)
                    slot.selectHL:SetHidden(true)
                end
            end
        end

        function TT:OpenSelected()
            local entry = self.entries[self.selectedRow]
            if entry and entry.scene and SCENE_MANAGER and SCENE_MANAGER.Show then
                pcall(function() SCENE_MANAGER:Show(entry.scene) end)
            end
        end

        local function TT_GetRawLeftStickY()
            local readers = {
                _G["GetGamepadLeftStickY"],
                _G["GetGamepadOrKeyboardLeftStickY"],
                _G["GetGamepadLeftStickDeltaY"],
            }
            for _, reader in ipairs(readers) do
                if type(reader) == "function" then
                    local okRead, value = pcall(reader)
                    if okRead and type(value) == "number" then
                        return value
                    end
                end
            end
            return nil
        end

        function TT:PollRawStickNavigation()
            local y = TT_GetRawLeftStickY()
            local direction = 0
            if type(y) == "number" then
                if y >= 0.35 then
                    direction = -1
                elseif y <= -0.35 then
                    direction = 1
                end
            end
            if direction == 0 then
                self.lastStickDirection = 0
                return
            end
            local nowMs = (type(GetFrameTimeMilliseconds) == "function" and GetFrameTimeMilliseconds())
                or (type(GetGameTimeMilliseconds) == "function" and GetGameTimeMilliseconds())
                or 0
            local repeatMs = 100
            local changedDirection = self.lastStickDirection ~= direction
            if changedDirection or not self.lastStickMoveMs or (nowMs - self.lastStickMoveMs) >= repeatMs then
                local newRow = zo_clamp((self.selectedRow or 1) + direction, 1, #self.entries)
                if newRow ~= self.selectedRow then
                    self.selectedRow = newRow
                    self:RefreshList()
                end
                self.lastStickMoveMs = nowMs
                self.lastStickDirection = direction
            end
        end

        local wf = ZO_SimpleSceneFragment:New(win)
        local sc = ZO_Scene:New(TT.sceneName, SCENE_MANAGER)
        sc:AddFragmentGroup(FRAGMENT_GROUP.GAMEPAD_DRIVEN_UI_WINDOW)
        sc:AddFragmentGroup(FRAGMENT_GROUP.FRAME_TARGET_GAMEPAD)
        if GAMEPAD_MENU_SOUND_FRAGMENT then
            sc:AddFragment(GAMEPAD_MENU_SOUND_FRAGMENT)
        end
        sc:AddFragment(wf)

        local kb = {
            alignment = KEYBIND_STRIP_ALIGN_LEFT,
            {
                keybind = "UI_SHORTCUT_NEGATIVE",
                name = (type(GetString) == "function" and GetString(SI_GAMEPAD_BACK_OPTION)) or "Back",
                callback = function()
                    if SCENE_MANAGER and SCENE_MANAGER.HideCurrentScene then
                        SCENE_MANAGER:HideCurrentScene()
                    end
                end,
                sound = SOUNDS and SOUNDS.GAMEPAD_MENU_BACK,
            },
            {
                keybind = "UI_SHORTCUT_PRIMARY",
                name = "Open",
                callback = function() TT:OpenSelected() end,
            },
            {
                keybind = "UI_SHORTCUT_LEFT_TRIGGER",
                name = "Up",
                callback = function()
                    if TT.selectedRow > 1 then
                        TT.selectedRow = TT.selectedRow - 1
                        TT:RefreshList()
                    end
                end,
            },
            {
                keybind = "UI_SHORTCUT_RIGHT_TRIGGER",
                name = "Down",
                callback = function()
                    if TT.selectedRow < #TT.entries then
                        TT.selectedRow = TT.selectedRow + 1
                        TT:RefreshList()
                    end
                end,
            },
        }

        sc:RegisterCallback("StateChange", function(_, newState)
            if newState == SCENE_SHOWING then
                TT.selectedRow = 1
                TT:RefreshList()
                pcall(function()
                    if KEYBIND_STRIP and KEYBIND_STRIP.AddKeybindButtonGroup then
                        KEYBIND_STRIP:AddKeybindButtonGroup(kb)
                    end
                end)
                EVENT_MANAGER:RegisterForUpdate("TT_HubStickNavPoll", 100, function()
                    TT:PollRawStickNavigation()
                end)
            elseif newState == SCENE_HIDDEN then
                pcall(function()
                    if KEYBIND_STRIP and KEYBIND_STRIP.RemoveKeybindButtonGroup then
                        KEYBIND_STRIP:RemoveKeybindButtonGroup(kb)
                    end
                end)
                EVENT_MANAGER:UnregisterForUpdate("TT_HubStickNavPoll")
            end
        end)

        local hubData = {
            name = "Tracking Tools",
            icon = "EsoUI/Art/MenuBar/Gamepad/gp_playerMenu_icon_settings.dds",
            scene = TT.sceneName,
        }
        local hubEntry = ZO_GamepadEntryData:New(hubData.name, hubData.icon)
        hubEntry:SetIconTintOnSelection(true)
        hubEntry:SetIconDisabledTintOnSelection(true)
        hubEntry.data = hubData
        hubEntry.id = 950

        local function PlaceHubEntry()
            if not ZO_MENU_ENTRIES then
                return
            end
            for i = #ZO_MENU_ENTRIES, 1, -1 do
                local e = ZO_MENU_ENTRIES[i]
                local scene = e and e.data and e.data.scene
                if (e and e.id == 950) or scene == TT.sceneName then
                    table.remove(ZO_MENU_ENTRIES, i)
                end
            end

            local insertPos = nil
            pcall(function()
                if ZO_MENU_MAIN_ENTRIES and ZO_MENU_MAIN_ENTRIES.JOURNAL then
                    for ix, v in ipairs(ZO_MENU_ENTRIES) do
                        if v.id == ZO_MENU_MAIN_ENTRIES.JOURNAL then
                            insertPos = ix + 3
                            break
                        end
                    end
                end
            end)
            if insertPos and insertPos >= 1 and insertPos <= #ZO_MENU_ENTRIES + 1 then
                table.insert(ZO_MENU_ENTRIES, insertPos, hubEntry)
            else
                table.insert(ZO_MENU_ENTRIES, hubEntry)
            end
        end

        PlaceHubEntry()
        if type(zo_callLater) == "function" then
            zo_callLater(PlaceHubEntry, 2500)
        end
        if MAIN_MENU_GAMEPAD then
            pcall(function()
                MAIN_MENU_GAMEPAD:RefreshLists()
                MAIN_MENU_GAMEPAD:UpdateEntryEnabledStates()
            end)
        end

        ELDIBABALO_TRACKING_TOOLS = TT
    end)

    return ok and ELDIBABALO_TRACKING_TOOLS ~= nil
end
