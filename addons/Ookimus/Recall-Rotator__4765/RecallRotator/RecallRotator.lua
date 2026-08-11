-- Recall Rotator
-- Picks a random unlocked "Recall" Customized Action (COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE,
-- PLAYER_FX_OVERRIDE_ABILITY_TYPE_WAYSHRINE) and activates it on demand, via the "Reroll Recall
-- Style" keybind (Controls > Keybindings > General - unbound by default) or the /rr slash command.

RecallRotator = RecallRotator or {}
local RecallRotator = RecallRotator

RecallRotator.name = "RecallRotator"
RecallRotator.displayName = "Recall Rotator"
RecallRotator.version = "1.4.2"
RecallRotator.savedVarsVersion = 1
RecallRotator.slashCommand = "/rr"

local ACTOR = GAMEPLAY_ACTOR_CATEGORY_PLAYER
local PREFIX = "|c70C0F0Recall Rotator|r: "

-- How long we're willing to wait for the server to confirm a swap took effect
-- before giving up on it (and letting the next map-open try again).
local SETTLE_TIMEOUT_MS = 4000
local SETTLE_POLL_MS = 200

local defaults = {
    enabled = true,
    announce = true,
    showButton = true,
    buttonLocked = true,
    buttonSize = 64,
    disabledCollectibles = {},
}

-- Set while a UseCollectible() call is waiting to be confirmed active.
-- Guards against a second map-open re-triggering a reroll before the first
-- one has actually settled, which is what caused swaps to appear to silently
-- fail (the second call raced the first and neither state stuck).
RecallRotator.pendingCollectibleId = nil

local function Msg(text)
    if RecallRotator.savedVars and RecallRotator.savedVars.announce then
        d(PREFIX .. text)
    end
end

-- Only owned/unlocked Recall Customized Actions the player can currently use.
function RecallRotator:GetRecallCollectibles()
    local pool = {}
    local total = GetTotalCollectiblesByCategoryType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE)
    for index = 1, total do
        local collectibleId = GetCollectibleIdFromType(COLLECTIBLE_CATEGORY_TYPE_PLAYER_FX_OVERRIDE, index)
        if collectibleId and collectibleId ~= 0
            and GetCollectiblePlayerFxOverrideType(collectibleId) == PLAYER_FX_OVERRIDE_TYPE_ABILITY
            and GetCollectiblePlayerFxOverrideAbilityType(collectibleId) == PLAYER_FX_OVERRIDE_ABILITY_TYPE_WAYSHRINE
            and IsCollectibleUnlocked(collectibleId)
            and IsCollectibleUsable(collectibleId, ACTOR)
        then
            pool[#pool + 1] = collectibleId
        end
    end
    return pool
end

function RecallRotator:IsCollectibleDisabledByUser(collectibleId)
    local disabled = self.savedVars.disabledCollectibles
    return disabled ~= nil and disabled[collectibleId] == true
end

-- The pool actually eligible for rerolling: unlocked/usable recall styles,
-- minus whatever the user unchecked in the "Recall Styles" settings list.
-- Recomputed fresh every call so Reroll() always sees the latest choices.
function RecallRotator:GetEnabledRecallCollectibles()
    local pool = self:GetRecallCollectibles()
    local enabled = {}
    for _, collectibleId in ipairs(pool) do
        if not self:IsCollectibleDisabledByUser(collectibleId) then
            enabled[#enabled + 1] = collectibleId
        end
    end
    return enabled
end

function RecallRotator:GetActiveRecallId(pool)
    for _, collectibleId in ipairs(pool) do
        if IsCollectibleActive(collectibleId, ACTOR) then
            return collectibleId
        end
    end
    return nil
end

-- Random pick that avoids repeating the currently active style back-to-back.
function RecallRotator:PickNext(pool)
    local count = #pool
    if count == 0 then
        return nil
    end
    if count == 1 then
        return pool[1]
    end

    local currentId = self:GetActiveRecallId(pool)
    local candidates = {}
    for _, collectibleId in ipairs(pool) do
        if collectibleId ~= currentId then
            candidates[#candidates + 1] = collectibleId
        end
    end
    if #candidates == 0 then
        candidates = pool
    end

    return candidates[zo_random(#candidates)]
end

-- Polls (with a fast-path EVENT_COLLECTIBLE_UPDATED short-circuit) until the
-- collectible we just requested actually reports itself active, or we give up.
function RecallRotator:WatchForSettle(collectibleId, elapsedMs)
    elapsedMs = elapsedMs or 0

    if self.pendingCollectibleId ~= collectibleId then
        -- Superseded or already resolved elsewhere; stop watching.
        return
    end

    if IsCollectibleActive(collectibleId, ACTOR) then
        self:OnSwitchSettled(collectibleId)
        return
    end

    if elapsedMs >= SETTLE_TIMEOUT_MS then
        self:OnSwitchTimedOut(collectibleId)
        return
    end

    zo_callLater(function()
        self:WatchForSettle(collectibleId, elapsedMs + SETTLE_POLL_MS)
    end, SETTLE_POLL_MS)
end

function RecallRotator:OnSwitchSettled(collectibleId)
    self.pendingCollectibleId = nil
    local name = GetCollectibleInfo(collectibleId)
    Msg(string.format("Recall style set to |cFFFFFF%s|r.", name or "Unknown"))
    self:RefreshButtonIcon()

    -- UseCollectible() resolves almost instantly (client-predicted), so this
    -- fires right away rather than after a real wait. Start the cooldown here,
    -- once the new icon is already showing, instead of in Reroll() - starting
    -- it there meant it got wiped by RefreshButtonIcon() a frame later. This
    -- is also now the actual "don't let them spam it" guard, not just a visual.
    self.nextRerollAllowedTime = GetGameTimeMilliseconds() + SETTLE_TIMEOUT_MS
    self:StartButtonCooldown(SETTLE_TIMEOUT_MS)
end

function RecallRotator:OnSwitchTimedOut(collectibleId)
    self.pendingCollectibleId = nil
    local name = GetCollectibleInfo(collectibleId)
    Msg(string.format("|cFF6060Couldn't confirm the switch to %s (server didn't settle in time) - try again in a moment.|r", name or "Unknown"))
    self:StopButtonCooldown()
end

-- Called when the game confirms a collectible's active/unlock state actually
-- changed. Lets a settle finish immediately instead of waiting for the poll.
function RecallRotator:OnCollectibleUpdated(collectibleId)
    if self.pendingCollectibleId == collectibleId and IsCollectibleActive(collectibleId, ACTOR) then
        self:OnSwitchSettled(collectibleId)
    end
end

function RecallRotator:Reroll()
    if not self.savedVars.enabled then
        return
    end

    if GetGameTimeMilliseconds() < (self.nextRerollAllowedTime or 0) then
        -- Still cooling down from the last successful swap.
        return
    end

    if self.pendingCollectibleId then
        -- A previous swap hasn't been confirmed yet; don't stack another one
        -- on top of it, that's what caused swaps to appear to do nothing.
        return
    end

    local pool = self:GetEnabledRecallCollectibles()
    if #pool < 2 then
        return
    end

    local nextId = self:PickNext(pool)
    if not nextId or IsCollectibleActive(nextId, ACTOR) then
        return
    end

    self.pendingCollectibleId = nextId
    UseCollectible(nextId, ACTOR)
    self:WatchForSettle(nextId)
end

local function OnCollectibleUpdated(_, collectibleId)
    RecallRotator:OnCollectibleUpdated(collectibleId)
end

function RecallRotator:SetupSettings()
    local LAM = LibAddonMenu2
    if not LAM then
        return
    end

    local panelData = {
        type = "panel",
        name = self.displayName,
        displayName = self.displayName,
        author = "Ookimus",
        version = self.version,
        registerForRefresh = true,
    }
    LAM:RegisterAddonPanel(self.name .. "Options", panelData)

    local optionsData = {
        {
            type = "checkbox",
            name = "Enabled",
            tooltip = "Let the keybind and /rr command switch your Recall Customized Action. Turn off to freeze your current style.",
            getFunc = function() return self.savedVars.enabled end,
            setFunc = function(value) self.savedVars.enabled = value end,
        },
        {
            type = "checkbox",
            name = "Announce changes in chat",
            getFunc = function() return self.savedVars.announce end,
            setFunc = function(value) self.savedVars.announce = value end,
        },
        {
            type = "button",
            name = "Reroll Now",
            tooltip = "Pick a new random recall style immediately.",
            func = function() self:Reroll() end,
        },
        {
            type = "description",
            text = "Bind \"Rotate Recall Style\" under Controls > Keybindings > General to switch styles on demand, or use /rr. Only Recall Customized Actions you currently own and can use are eligible; if you own fewer than two, nothing changes.",
        },
        {
            type = "header",
            name = "On-Screen Button",
        },
        {
            type = "checkbox",
            name = "Show on-screen button",
            tooltip = "Shows a clickable icon (sized to match your action bar) that rerolls your recall style when clicked.",
            getFunc = function() return self.savedVars.showButton end,
            setFunc = function(value)
                self.savedVars.showButton = value
                self:UpdateButtonVisibility()
            end,
        },
        {
            type = "checkbox",
            name = "Lock button position",
            tooltip = "Uncheck to unlock the button so you can drag it to a new spot on screen. Re-check to lock it back in place.",
            getFunc = function() return self.savedVars.buttonLocked end,
            setFunc = function(value)
                self.savedVars.buttonLocked = value
                self:ApplyButtonLockState()
            end,
        },
        {
            type = "slider",
            name = "Button size",
            tooltip = "Match this to your action bar's icon size (Settings > HUD).",
            min = 32,
            max = 96,
            step = 4,
            getFunc = function() return self.savedVars.buttonSize end,
            setFunc = function(value)
                self.savedVars.buttonSize = value
                self:ApplyButtonSize()
            end,
        },
        {
            type = "submenu",
            name = "Recall Styles",
            controls = self:BuildRecallStyleControls(),
        },
    }
    LAM:RegisterOptionControls(self.name .. "Options", optionsData)
end

-- One checkbox per currently-unlocked recall style, so the user can pick
-- which ones are eligible for rerolling. Built fresh whenever settings open;
-- Reroll() itself always re-reads savedVars.disabledCollectibles directly,
-- so newly-unlocked styles are still included even if this list is stale
-- until the next /reloadui.
function RecallRotator:BuildRecallStyleControls()
    local pool = self:GetRecallCollectibles()

    if #pool == 0 then
        return {
            {
                type = "description",
                text = "No unlocked Recall Customized Actions found yet. Own at least one to see it listed here.",
            },
        }
    end

    local controls = {
        {
            type = "description",
            text = "Uncheck a style to exclude it from the rotation.",
        },
    }

    for _, collectibleId in ipairs(pool) do
        local name = GetCollectibleInfo(collectibleId) or ("Unknown (" .. collectibleId .. ")")
        controls[#controls + 1] = {
            type = "checkbox",
            name = name,
            getFunc = function() return not self:IsCollectibleDisabledByUser(collectibleId) end,
            setFunc = function(value)
                self.savedVars.disabledCollectibles = self.savedVars.disabledCollectibles or {}
                self.savedVars.disabledCollectibles[collectibleId] = (not value) or nil
            end,
        }
    end

    return controls
end

local function OnAddOnLoaded(_, addonName)
    if addonName ~= RecallRotator.name then
        return
    end
    EVENT_MANAGER:UnregisterForEvent(RecallRotator.name, EVENT_ADD_ON_LOADED)

    -- Deliberately NOT server-dependent (namespace left nil rather than
    -- GetWorldName()): every field here - button position, enabled/announce
    -- toggles, disabled-style list - is a client-side UI/behavior preference
    -- with no server-specific meaning, so it's fine (and preferable) for it
    -- to stay identical across EU/NA/PTS for the same @DisplayName.
    RecallRotator.savedVars = ZO_SavedVars:NewAccountWide("RecallRotator_SavedVariables", RecallRotator.savedVarsVersion, nil, defaults)

    EVENT_MANAGER:RegisterForEvent(RecallRotator.name, EVENT_COLLECTIBLE_UPDATED, OnCollectibleUpdated)

    SLASH_COMMANDS[RecallRotator.slashCommand] = function(argString)
        local arg = string.lower(zo_strtrim(argString or ""))
        if arg == "on" then
            RecallRotator.savedVars.enabled = true
            d(PREFIX .. "Enabled.")
        elseif arg == "off" then
            RecallRotator.savedVars.enabled = false
            d(PREFIX .. "Disabled.")
        elseif arg == "announce" then
            RecallRotator.savedVars.announce = not RecallRotator.savedVars.announce
            d(PREFIX .. "Announcements " .. (RecallRotator.savedVars.announce and "on" or "off") .. ".")
        elseif arg == "list" then
            local pool = RecallRotator:GetRecallCollectibles()
            d(PREFIX .. string.format("%d recall style(s) available:", #pool))
            for _, collectibleId in ipairs(pool) do
                local name = GetCollectibleInfo(collectibleId)
                local activeTag = IsCollectibleActive(collectibleId, ACTOR) and " |c70C0F0(active)|r" or ""
                local pendingTag = (RecallRotator.pendingCollectibleId == collectibleId) and " |cFFAA00(switch pending...)|r" or ""
                local disabledTag = RecallRotator:IsCollectibleDisabledByUser(collectibleId) and " |c777777(disabled)|r" or ""
                d(" - " .. (name or "?") .. activeTag .. pendingTag .. disabledTag)
            end
        else
            RecallRotator:Reroll()
        end
    end

    RecallRotator:SetupSettings()
    RecallRotator:CreateButton()
end

EVENT_MANAGER:RegisterForEvent(RecallRotator.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
