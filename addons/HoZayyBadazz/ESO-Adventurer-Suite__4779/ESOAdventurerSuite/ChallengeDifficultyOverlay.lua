-- ESO Adventurer Suite
-- Current Challenge Difficulty icon overlay.
-- Toggleable, movable through HUD layout mode, and resizable through settings.

local EPC = ESOProgressionCoach
EPC.ChallengeDifficultyOverlay = EPC.ChallengeDifficultyOverlay or {}
local O = EPC.ChallengeDifficultyOverlay
local wm = WINDOW_MANAGER

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d
end

local function anchorWindow(control, leftKey, topKey, defaultX, defaultY)
    if not control then return end
    control:ClearAnchors()
    local left = tonumber(EPC.saved and EPC.saved[leftKey]) or -1
    local top = tonumber(EPC.saved and EPC.saved[topKey]) or -1
    if left >= 0 and top >= 0 then
        control:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
    else
        control:SetAnchor(TOP, GuiRoot, TOP, defaultX, defaultY)
    end
end

function O:GetShownDifficulty()
    local value = safe(GetOverlandDifficulty, nil)
    if value == nil and EPC.OverlandDifficulty then
        value = EPC.OverlandDifficulty.lastTarget
    end
    if value == nil and self.layoutMode then
        value = tonumber(EPC.saved and EPC.saved.overlandDifficultyOpenWorld) or 0
    end
    return tonumber(value)
end


function O:IsInDungeon()
    return safe(IsUnitInDungeon, false, "player") == true
end

function O:GetDungeonDifficultyIcon()
    if not self:IsInDungeon() then return nil end
    local difficulty = safe(ZO_GetEffectiveDungeonDifficulty, nil)
    if difficulty == nil then
        if safe(IsUnitUsingVeteranDifficulty, false, "player") == true then
            difficulty = rawget(_G, "DUNGEON_DIFFICULTY_VETERAN")
        else
            difficulty = rawget(_G, "DUNGEON_DIFFICULTY_NORMAL")
        end
    end
    if difficulty == nil then return nil end
    return safe(ZO_GetKeyboardDungeonDifficultyIcon, nil, difficulty), difficulty
end

function O:Anchor()
    anchorWindow(self.frame, "overlandDifficultyOverlayLeft", "overlandDifficultyOverlayTop", 0, 205)
end

function O:ApplyDrawOrder()
    if not self.frame then return end
    local layout = self.layoutMode == true
    pcall(function()
        if self.frame.SetTopLevel then self.frame:SetTopLevel(layout) end
        if self.frame.SetDrawTier then self.frame:SetDrawTier(layout and (DT_HIGH or DT_MEDIUM) or (DT_MEDIUM or DT_LOW)) end
        if self.frame.SetDrawLayer then self.frame:SetDrawLayer(DL_OVERLAY or DL_CONTROLS) end
        if self.frame.SetDrawLevel then self.frame:SetDrawLevel(layout and 5000 or 260) end
        if self.icon and self.icon.SetDrawLayer then self.icon:SetDrawLayer(DL_OVERLAY or DL_CONTROLS) end
        if self.icon and self.icon.SetDrawLevel then self.icon:SetDrawLevel(layout and 5010 or 270) end
        if layout and self.frame.BringWindowToTop then self.frame:BringWindowToTop() end
    end)
end

function O:Create()
    if self.frame then return end
    local frame = wm:CreateTopLevelWindow("EAS_ChallengeDifficultyOverlay")
    frame:SetDimensions(72, 72)
    frame:SetClampedToScreen(true)
    frame:SetMouseEnabled(false)
    frame:SetMovable(false)
    frame:SetHidden(true)

    local icon = wm:CreateControl("$(parent)Icon", frame, CT_TEXTURE)
    icon:SetAnchorFill(frame)
    icon:SetTexture("EsoUI/Art/ChallengeDifficulty/challengeDifficulty_basegame_down_over.dds")

    frame:SetHandler("OnMoveStop", function(control)
        if EPC.saved then
            EPC.saved.overlandDifficultyOverlayLeft = control:GetLeft()
            EPC.saved.overlandDifficultyOverlayTop = control:GetTop()
        end
    end)

    self.frame = frame
    self.icon = icon
    self:Anchor()
    self:ApplyDrawOrder()
end

function O:IsSuiteOpen()
    local journal = EPC.Journal and EPC.Journal.window
    if journal and type(journal.IsHidden) == "function" then
        local ok, hidden = pcall(journal.IsHidden, journal)
        if ok and hidden == false then return true end
    end
    return false
end

function O:Refresh()
    if not self.frame or not EPC.saved then return end

    local overlayEnabled = EPC.saved.overlandDifficultyShowOverlay == true
    local autoEnabled = EPC.saved.overlandDifficultyEnabled == true
    local inDungeon = self:IsInDungeon()

    -- Gameplay-only behavior: hide with normal ESO menus and while the
    -- Tamriel Codex/Suite is open. HUD layout mode is the only preview
    -- exception so the icon can still be positioned.
    local suppressed = false
    if self.layoutMode ~= true then
        if EPC.IsGameplayHudSuppressed and EPC:IsGameplayHudSuppressed() then suppressed = true end
        if self:IsSuiteOpen() then suppressed = true end
    end

    local texture = nil

    -- Dungeon difficulty has no reliable matching Challenge Difficulty symbol.
    -- Hide this overlay completely while inside a dungeon/trial and restore the
    -- normal overland symbol automatically after returning to the open world.
    if not inDungeon then
        if self.layoutMode == true then
            local value = self:GetShownDifficulty() or 0
            local keys = { [0] = "basegame", [1] = "journeyman", [2] = "adventurer", [3] = "veteran" }
            local key = keys[value] or "basegame"
            texture = string.format("EsoUI/Art/ChallengeDifficulty/challengeDifficulty_%s_down_over.dds", key)
        elseif not suppressed and overlayEnabled and autoEnabled then
            local value = self:GetShownDifficulty()
            if value ~= nil then
                local keys = { [0] = "basegame", [1] = "journeyman", [2] = "adventurer", [3] = "veteran" }
                local key = keys[value] or "basegame"
                texture = string.format("EsoUI/Art/ChallengeDifficulty/challengeDifficulty_%s_down_over.dds", key)
            end
        end
    end

    self.frame:SetScale(tonumber(EPC.saved.overlandDifficultyOverlayScale) or 1.0)
    if texture then self.icon:SetTexture(texture) end
    self:ApplyDrawOrder()
    self.frame:SetHidden(texture == nil)
end

function O:SetLayoutMode(active)
    self.layoutMode = active == true
    if self.frame then
        self.frame:SetMouseEnabled(self.layoutMode)
        self.frame:SetMovable(self.layoutMode)
        self:ApplyDrawOrder()
    end
    self:Refresh()
end

function O:ResetPosition()
    if not EPC.saved then return end
    EPC.saved.overlandDifficultyOverlayLeft = -1
    EPC.saved.overlandDifficultyOverlayTop = -1
    self:Anchor()
end

function O:Initialize()
    self.layoutMode = false
    self:Create()
    local prefix = (EPC.name or "EAS") .. "_ChallengeDifficultyOverlay"
    if EVENT_PLAYER_ACTIVATED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function() self:Refresh() end)
    end
    if EVENT_OVERLAND_DIFFICULTY_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Difficulty", EVENT_OVERLAND_DIFFICULTY_CHANGED, function() self:Refresh() end)
    end
    if EVENT_ZONE_CHANGED then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Zone", EVENT_ZONE_CHANGED, function(_, unitTag) if not unitTag or unitTag == "player" then self:Refresh() end end)
    elseif EVENT_ZONE_UPDATE then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Zone", EVENT_ZONE_UPDATE, function() self:Refresh() end)
    end
    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Pulse", 1500, function() self:Refresh() end)
    self:Refresh()
end
