ShoyruClassicCP = {}
ShoyruClassicCP.name = "ShoyruClassicCP"
ShoyruClassicCP.version = "1.0"

local ADDON_NAME = ShoyruClassicCP.name
local LOAD_EVENT_NAME = ADDON_NAME .. "_Loaded"
local ACTIVATED_EVENT_NAME = ADDON_NAME .. "_Activated"

local CHAMPION_ICON_TEXTURE = "EsoUI/Art/Champion/champion_icon.dds"

local defaults = {
    enabled = true,

    -- What to show on a champion-level target if the server doesn't send
    -- their CP value (Update 50 may withhold it in PvP zones in favor of
    -- veterancy rank):
    --   "hide" = show nothing where the rank used to be (clean frame)
    --   "star" = show the champion star icon without a number
    fallbackMode = "hide",

    debugLog = false,
}

local hooked = false

local function DebugLog(msg)
    local sv = ShoyruClassicCP.savedVariables
    if sv and sv.debugLog then
        d("|c66ccff[ClassicCP]|r " .. msg)
    end
end

-- Re-applies the pre-Update-50 rendering on top of whatever the game just
-- drew: champion star + CP number (or plain level for non-champions),
-- instead of the PvP veterancy rank icon.
local function ApplyClassicLevel(unitFrame)
    local sv = ShoyruClassicCP.savedVariables
    if not sv or not sv.enabled then return end
    if not unitFrame or not unitFrame.GetUnitTag then return end

    local unitTag = unitFrame:GetUnitTag()
    if not unitTag or unitTag == "" then return end

    local showLevel = true
    if unitFrame.ShouldShowLevel then
        showLevel = unitFrame:ShouldShowLevel()
    end

    local isChampion = IsUnitChampion and IsUnitChampion(unitTag)
    local unitLevel
    if isChampion then
        unitLevel = (GetUnitEffectiveChampionPoints and GetUnitEffectiveChampionPoints(unitTag))
            or (GetUnitChampionPoints and GetUnitChampionPoints(unitTag))
            or 0
    else
        unitLevel = GetUnitLevel and GetUnitLevel(unitTag) or 0
    end

    if sv.debugLog and unitTag == "reticleover" then
        DebugLog(string.format("tag=%s champion=%s level=%d", unitTag, tostring(isChampion), unitLevel))
    end

    local hasNumber = unitLevel and unitLevel > 0

    if unitFrame.levelLabel then
        if showLevel and hasNumber then
            unitFrame.levelLabel:SetText(tostring(unitLevel))
            unitFrame.levelLabel:SetHidden(false)
        else
            unitFrame.levelLabel:SetText("")
            unitFrame.levelLabel:SetHidden(true)
        end
    end

    if unitFrame.championIcon then
        -- Force the classic champion star back over whatever veterancy
        -- texture the game just applied.
        if unitFrame.championIcon.SetTexture then
            unitFrame.championIcon:SetTexture(CHAMPION_ICON_TEXTURE)
        end
        local showStar = showLevel and isChampion
        if isChampion and not hasNumber and sv.fallbackMode == "hide" then
            showStar = false
        end
        unitFrame.championIcon:SetHidden(not showStar)
    end

    -- Defensive: if Update 50 added a dedicated veterancy control alongside
    -- the champion icon, hide it under any of its plausible names.
    for _, member in ipairs({ "veterancyIcon", "veterancyRankIcon", "veterancyRankLabel" }) do
        local c = unitFrame[member]
        if c and c.SetHidden then
            c:SetHidden(true)
        end
    end
    if unitFrame.frame and unitFrame.frame.GetNamedChild then
        for _, childName in ipairs({ "VeterancyIcon", "VeterancyRankIcon" }) do
            local c = unitFrame.frame:GetNamedChild(childName)
            if c and c.SetHidden then
                c:SetHidden(true)
            end
        end
    end
end

-- The unit frame class table is local to ZOS code, but every frame instance
-- resolves methods through its metatable — grab the class from a live frame
-- and post-hook UpdateLevel there, covering all current and future frames.
local function TryHook()
    if hooked then return end
    if not ZO_UnitFrames_GetUnitFrame then return end

    local frame = ZO_UnitFrames_GetUnitFrame("reticleover")
    if not frame then return end

    local mt = getmetatable(frame)
    local class = mt and mt.__index
    if type(class) ~= "table" or not class.UpdateLevel then return end

    ZO_PostHook(class, "UpdateLevel", ApplyClassicLevel)
    hooked = true
    DebugLog("UpdateLevel hook installed")
end

local function RefreshTargetFrame()
    if not ZO_UnitFrames_GetUnitFrame then return end
    local frame = ZO_UnitFrames_GetUnitFrame("reticleover")
    if frame and frame.UpdateLevel then
        frame:UpdateLevel()
    end
end

function ShoyruClassicCP:CreateSettings()
    local LAM = LibAddonMenu2
    if not LAM then return end

    local panelData = {
        type = "panel",
        name = "Shoyru's Classic CP",
        displayName = "Shoyru's Classic CP",
        author = "Shoyru",
        version = ShoyruClassicCP.version,
        registerForRefresh = true,
        registerForDefaults = true,
    }

    LAM:RegisterAddonPanel("ShoyruClassicCPOptions", panelData)

    local optionsTable = {
        {
            type = "description",
            text = "Update 50 replaced the Champion Point display on PvP target frames (Cyrodiil, Imperial City, Battlegrounds) with the new Veterancy rank icon. This addon reverts that: targets show the classic champion star and CP number again, exactly like before the update.\n\nIf the game stops sending a target's CP value in PvP, the fallback below decides what to show instead of the veterancy rank.\n\nSlash command: /classiccp prints what the game reports for your current target (champion status, CP, veterancy rank) — useful for verifying what data is actually available in Cyrodiil.",
            width = "full",
        },
        {
            type = "checkbox",
            name = "Activate Addon",
            tooltip = "Show the classic CP display instead of the veterancy rank. Disabling restores the game's veterancy icon on the next target change.",
            getFunc = function()
                return ShoyruClassicCP.savedVariables.enabled
            end,
            setFunc = function(value)
                ShoyruClassicCP.savedVariables.enabled = value
                RefreshTargetFrame()
            end,
            default = defaults.enabled,
        },
        {
            type = "dropdown",
            name = "If CP value is unavailable",
            tooltip = "What to show on a champion-level target when the server doesn't send their CP number (it may withhold it in PvP zones). \"Show nothing\" keeps the frame clean; \"Champion star only\" shows the star without a number.",
            choices = { "Show nothing", "Champion star only" },
            choicesValues = { "hide", "star" },
            getFunc = function()
                return ShoyruClassicCP.savedVariables.fallbackMode or defaults.fallbackMode
            end,
            setFunc = function(value)
                ShoyruClassicCP.savedVariables.fallbackMode = value
                RefreshTargetFrame()
            end,
            default = defaults.fallbackMode,
        },
        {
            type = "header",
            name = "Debug",
        },
        {
            type = "checkbox",
            name = "Debug logging",
            tooltip = "Log what the addon applies to the reticle target frame to chat.",
            getFunc = function()
                return ShoyruClassicCP.savedVariables.debugLog
            end,
            setFunc = function(value)
                ShoyruClassicCP.savedVariables.debugLog = value
            end,
            default = defaults.debugLog,
        },
    }

    LAM:RegisterOptionControls("ShoyruClassicCPOptions", optionsTable)
end

local function RegisterSlashCommands()
    SLASH_COMMANDS["/classiccp"] = function()
        local tag = "reticleover"
        if not DoesUnitExist or not DoesUnitExist(tag) then
            d("|c66ccff[ClassicCP]|r no reticle target — aim at a player and try again")
            return
        end
        d(string.format(
            "|c66ccff[ClassicCP]|r %s — champion=%s effCP=%s cp=%s level=%s vetRank=%s",
            zo_strformat("<<1>>", GetUnitName(tag)),
            tostring(IsUnitChampion and IsUnitChampion(tag)),
            tostring(GetUnitEffectiveChampionPoints and GetUnitEffectiveChampionPoints(tag)),
            tostring(GetUnitChampionPoints and GetUnitChampionPoints(tag)),
            tostring(GetUnitLevel and GetUnitLevel(tag)),
            tostring(GetUnitVeterancyRank and GetUnitVeterancyRank(tag))
        ))
    end
end

local function OnPlayerActivated()
    TryHook()
    RefreshTargetFrame()
end

local function OnAddonLoaded(event, addonName)
    if addonName ~= ADDON_NAME then return end

    EVENT_MANAGER:UnregisterForEvent(LOAD_EVENT_NAME, EVENT_ADD_ON_LOADED)

    ShoyruClassicCP.savedVariables = ZO_SavedVars:NewAccountWide(
        "ShoyruClassicCPSavedVariables",
        1,
        nil,
        defaults
    )

    ShoyruClassicCP:CreateSettings()
    RegisterSlashCommands()
    TryHook()

    -- Unit frames may not exist until the world finishes loading; retry then.
    EVENT_MANAGER:RegisterForEvent(ACTIVATED_EVENT_NAME, EVENT_PLAYER_ACTIVATED, OnPlayerActivated)
end

EVENT_MANAGER:RegisterForEvent(LOAD_EVENT_NAME, EVENT_ADD_ON_LOADED, OnAddonLoaded)
