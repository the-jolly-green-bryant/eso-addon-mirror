-------------------------------------------------------------------------------
-- RainbowReticle v1.7.0
-- Copyright 2016 Calia1120
-- See README for details
-------------------------------------------------------------------------------

local rr = {}
rr.name = "RainbowReticle"
rr.authors = table.concat({'Calia1120'}, ', ')
rr.version = '1.7.0'
rr.copyright = '2016'

local savedVars = {}

rr.defaults = {
    enableGuild = true,
    enableGroup = true,
    enableFriend = true,
    enableHostile = true,
    enableNonHostile = true,
    enableAll = true,
    enableLevel = true,
    enableHealth = true,
    enableHealthPercent = true,
    guildColor = 0,
    friendColor = 0,
    groupColor = 0,
    enemyColor = 0,
    whiteColor = 0,
    enableDebug = false,
}

-- Try to ensure checking/updating isn't too frequent (i.e. busy wait), by enforcing a delay
rr.delay_lastChecked = 0
local function DelayCheck(key, milliSeconds)
    -- ignore key at present, need if managing multiple events

    local now = GetFrameTimeMilliseconds()
    milliSeconds = milliSeconds or 1000   -- Default if milliSeconds is not specified

    -- Strongly suggest you don't decrease below 100 milliseconds
    -- users literally can't notice delays shorter than ~100-200ms
    if (now - rr.delay_lastChecked) < milliSeconds then
        return false;
    end
  
    rr.delay_lastChecked = now
 
    return true
end

-- Set the  color of the normal reticle and the stealth eye textures / text
local function SetReticleColor(r, g, b, a)
    if r ~= nil and g == nil and b == nil and a == nil then
        local temp = r
        r, g, b, a = temp:UnpackRGBA()
    end
    RETICLE.reticleTexture:SetColor(r, g, b, a)
    RETICLE.stealthIcon.stealthEyeTexture:SetColor(r, g, b, a)
end

-- If Reticle is hidden, then hide icons
local function OnReticleHidden(eventcode)
    -- SetReticleColor(savedVars.whiteColor:UnpackRGBA())
    -- RETICLE.stealthText:SetColor(savedVars.whiteColor:UnpackRGBA())
    RainbowReticleUnitName:SetHidden(true)
end

-- Returns Level or Champion Point level of target as a string
local function RainbowReticleUnitLevel(target)
    if not savedVars.enableLevel then return ""; end

    if IsUnitChampion(target) then
        return zo_strformat(" (<<1>> CP)", GetUnitChampionPoints(target))
    else 
        return zo_strformat(" (<<1>>)", GetUnitLevel(target))
    end
end


local function IsHumanPlayer(unitTag)
    return (GetUnitReaction(unitTag) == UNIT_REACTION_PLAYER_ALLY)
    -- TODO: This is only allied (human) players; what about enemy players? 
end

local function IsUnitHostile(unitTag)
    return (GetUnitReaction(unitTag) ==  UNIT_REACTION_HOSTILE)
end

local function IsNonHostile(unitTag)
    return (GetUnitReaction(unitTag) ~=  UNIT_REACTION_HOSTILE)
end

-- TODO: Optimize in the future.
local function IsGuildMate(unitTag)
    local displayName = GetUnitDisplayName(unitTag)
    for i = 1, GetNumGuilds() do
        local guildId = GetGuildId(i)
        if GetGuildMemberIndexFromDisplayName(guildId, displayName) ~= nil then 
            return true
        end
    end
    return false
end

local function IsPlayerHiding()
    -- if player is not in stealth or disguised, then don't show stealth text ("Detected")
    return ((GetUnitStealthState('player') ~= STEALTH_STATE_NONE) or
    (GetUnitDisguiseState('player') ~= DISGUISE_STATE_NONE))
end

-- find out if human player is friendly or not
local function IsHumanPlayer(unitTag) 
    return (GetUnitReaction(unitTag) == UNIT_REACTION_PLAYER_ALLY)
end

--------------------------------------------------------------------------------------------------
-- If target has changed; check it's a valid target, then find out if they are friend or guild-mate
local function OnTargetHasChanged(eventcode, input)
    local isguild = false
    local isfriend = false
    local isgroup = false
    local isenemy = false
    local isnonhostile = false
    local color = savedVars.whiteColor:Clone()
    local text = ""
    local showtext = false
    local target

    RainbowReticleUnitName:SetHidden(true)
    RainbowReticleUnitHealth:SetHidden(true)

    -- Get the reticle target
    if DoesUnitExist('reticleover') then
        target = GetUnitName('reticleover')
    else
        -- Reset reticle if not pointing at an unit anymore...
        color = savedVars.whiteColor:Clone()
        SetReticleColor(color:UnpackRGBA())
        RETICLE.stealthIcon.stealthText:SetColor(color:UnpackRGBA())
    
	if not IsPlayerHiding() then
		RETICLE.stealthIcon:HideStealthText()
    end

    RainbowReticleUnitName:SetColor(color:UnpackRGBA())
    RainbowReticleUnitName:SetText("")
    RainbowReticleUnitName:SetHidden(true)
    
        RainbowReticleUnitHealth:SetText("")
        RainbowReticleUnitHealth:SetColor(color:UnpackRGBA())
        RainbowReticleUnitHealth:SetHidden(true)
        return;
    end

    -- check if target is human player
    if IsHumanPlayer('reticleover') then
        -- friends list
        isfriend = IsUnitFriend('reticleover')
        -- member of common guild
        isguild = IsGuildMate('reticleover')
        -- group member
        isgroup = IsUnitGrouped('reticleover')

        -- FIXME: This logic needs to be adapted to adjust for cases where target is both friends and guild mate, or grouped and friend, etc.
        -- which color to prefer?
        if isguild == true and savedVars.enableGuild then
            color:SetRGB(savedVars.guildColor:UnpackRGBA())
            showtext = savedVars.enableGuild
        elseif isfriend == true and savedVars.enableFriend then
            color:SetRGB(savedVars.friendColor:UnpackRGBA()) -- color:SetRGB(.2,.2,1)
            showtext = savedVars.enableFriend
        elseif isgroup == true and savedVars.enableGroup then 
            color:SetRGB(savedVars.groupColor:UnpackRGBA()) --- color:SetRGB(.8235,.4117,.1176)
            showtext = savedVars.enableGroup
        elseif savedVars.enableAll == true then 
            color:SetRGB(GetUnitReactionColor('reticleover')) -- this includes all players too
            showtext = true  
        end
    else -- if isHuman 
  
    -------------------------------------------------
    -- now for NPC and non-trivial animals / monsters
    if IsUnitHostile('reticleover') then
      color:SetRGB(GetUnitReactionColor('reticleover'))
      showtext = true
    
    elseif savedVars.enableAll == true then
        -- this includes non-hostile NPCs and monsters
        color:SetRGB(GetUnitReactionColor('reticleover'))
        showtext = true
        if savedVars.enableDebug then
            d("Target (" .. target  .. RainbowReticleUnitLevel('reticleover') .. ") is " .. tonumber(GetUnitReaction('reticleover')) )
            end
        end -- elseif unitHostile & enableAll
    end -- if/else isHuman

    text = GetUnitName('reticleover') .. RainbowReticleUnitLevel('reticleover')

    -- display unit name (and possibly level if enabled)
    if showtext then
        RainbowReticleUnitName:SetColor(color:UnpackRGBA())
        RainbowReticleUnitName:SetText(text)
        RainbowReticleUnitName:SetHidden(false)
    end

    -- Health amount and/or percentage
    if savedVars.enableHealth == true or savedVars.enableHealthPercent == true then
        RainbowReticleUnitHealth:SetHidden(false)
        if isguild then
            color:SetRGB(savedVars.guildColor:UnpackRGBA())
        elseif isfriend then
            color:SetRGB(savedVars.friendColor:UnpackRGBA()) -- color:SetRGB(.2,.2,1)
        elseif isgroup then 
            color:SetRGB(savedVars.groupColor:UnpackRGBA()) --- color:SetRGB(.8235,.4117,.1176)
        else color:SetRGB(GetUnitReactionColor('reticleover'))
        end             
    end

    -- Actually Change UI Reticle color
    SetReticleColor(color:UnpackRGBA())

    -- Handle case of whether player is hiding (update stealthText color, only if it is visible)
    if IsPlayerHiding() then
        RETICLE.stealthIcon.stealthText:SetColor(color:UnpackRGBA())
        RETICLE.stealthIcon.stealthTextTimeline:PlayForward() -- ?? uncertain about this, maybe resumes display time timer
    end -- isPlayerHiding
end -- OnTargetHasChanged


-- Table of tables for the Config Panel ("Settings") toggle buttons
local buttons = {
    -- key, => {savedVars, sethidden}
    ["guild"] = {"enableGuild", true},
    ["friend"] = {"enableFriend", true},
    ["group"] = {"enableGroup", true},
    ["hostile"] = {"enableHostile", true},
    ["nonhostile"] = {"enableNonHostile", true},
    ["all"] = {"enableAll", false},
    ["level"] = {"enableLevel", false},
    ["health"] = {"enableHealth", false},
    ["percent"] = {"enableHealthPercent", false},
    ["debug"] = {"enableDebug", false},
}

local function ToggleButton(label)
    savedVars[buttons[label][1]] = not savedVars[buttons[label][1]]
    if buttons[label][2] then
        RainbowReticleUnitName:SetHidden(savedVars[buttons[label][1]] == false)
    end
end

---------------------------------------------------------------------------
local function updateHealthDisplay()
-- testing cleanup on this  
  -- local targetName = GetUnitName('reticleover')
    -- skip trivial neutral animals and friends
    --if CheckIsCritter(targetName) then
  --      return
  --  end
  
    -- get current health and calculate percent
    local unitcurrent, unitmax, _ = GetUnitPower('reticleover', POWERTYPE_HEALTH )
    local unitpercent = math.floor(unitcurrent / unitmax * 100)

    if (unitcurrent <= 0 and (savedVars.enableHealth or savedVars.enableHealthPercent)) then
        RainbowReticleUnitHealth:SetText("DEAD") -- to state the obvious
        return
    end

    local text = ""
    if savedVars.enableHealth == true then
        text = ("%s/%s"):format(unitcurrent, unitmax)
        RainbowReticleUnitHealth:SetText(text)
    end 
    if savedVars.enableHealthPercent == true then
        if savedVars.enableHealth == true then
            RainbowReticleUnitHealth:SetText(("%s (%d%%)"):format(text, unitpercent))
        else
            RainbowReticleUnitHealth:SetText(unitpercent .. "%")
        end -- enableHealth
    end -- enableHealthPercent
end -- end of function updateHealthDisplay()

---------------------------------------------------------------------
local function setupDefaultColors(savedVars) 
    savedVars.guildColor = ZO_ColorDef:New(0.2, 1, 0.2, 1) -- Green  (R, G, B, Alpha)
    savedVars.friendColor = ZO_ColorDef:New(0.2, 0.2, 1, 1) -- Blue
    savedVars.groupColor = ZO_ColorDef:New(0.8235, 0.4117, 0.1176, 1) -- Orange
    savedVars.enemyColor = ZO_ColorDef:New(1, 0.2, 0.2, 1) -- Red
    savedVars.whiteColor = ZO_ColorDef:New(1, 1, 1, 1) -- White :)
end -- setDefaultColors

---------------------------------------------------------------------

rr.panelData = {
	type = "panel",
	name = "Rainbow Reticle",
	displayName = "|c966BEDR|r|c5B9FE3a|r|c74D5EDi|r|c42A400n|r|cEDED51b|r|cFF9900o|r|cF54D3Bw|r Reticle",
	author = rr.authors,
	version = rr.version,
	registerForRefresh = true,	--boolean (optional) (will refresh all options controls when a setting is changed and when the panel is shown)
	registerForDefaults = false,	--boolean (optional) (will set all options controls back to default values) TODO
}

rr.optionsTable = {
	{
		type = "description",
		-- title = "Description",	--(optional)
		title = nil,	--(optional)
        text =  "Colors the reticle (cross-hairs) based on what it is pointing at. Options for showing target's level, health, and health percentage.",
		width = "full",	--or "half" (optional)
	},  
	{
		type = "header",
		name = "Show Names for ...",
		width = "full",
	},  
    {
        type = "checkbox",
        name = "Guild Members",
        tooltip = "Enable names for Guild members",
        width = "half",
        getFunc = function() return savedVars.enableGuild; end,
        setFunc = function() ToggleButton('guild'); end,
    },
    {
        type = "checkbox",
        name = "Friends",
        tooltip = "Enable names for Friends",
        width = "half",
        getFunc = function() return savedVars.enableFriend; end,
        setFunc = function() ToggleButton('friend'); end,
    },  
    {
        type = "checkbox",
        name = "Group Members",
        tooltip = "Enable names for Group members",
        width = "half",
        getFunc = function() return savedVars.enableGroup; end,
        setFunc = function() ToggleButton('group'); end,
    },
    -- I'm testing out some further refinement of options, so this is rem'd out for now.
--    {
--        type = "checkbox",
--        name = "Hostile",
--        tooltip = "Enable names for Hostile targets",
--        width = "half",
--        getFunc = function() return savedVars.enableHostile; end,
--        setFunc = function() ToggleButton('hostile'); end,
--    },
--    {
--        type = "checkbox",
--        name = "Non-Hostile (NPCs and other creatures",
--        tooltip = "Enable names for Non-Hostile targets",
--        width = "half",
--        getFunc = function() return savedVars.enableHostile; end,
--        setFunc = function() ToggleButton('nonhostile'); end,
--    },
    {
        type = "checkbox",
        name = "Enable All (Other players, NPCs and creatures)",
        tooltip = "Enable names for everyone and everything (non-trivial)",
        width = "full",
        getFunc = function() return savedVars.enableAll; end,
        setFunc = function() ToggleButton('all'); end,
    },
	{
		type = "header",
		name = "Show Level ...",
		width = "full",
	},
    {
        type = "checkbox",
        name = "Show Level",
        tooltip = "Show level, if name is shown",
        width = "full",
        getFunc = function() return savedVars.enableLevel; end,
        setFunc = function() ToggleButton('level'); end,
    },
	{
		type = "header",
		name = "Show Health ...",
		width = "full",
	},
    {
        type = "checkbox",
        name = "Show Health Values",
        tooltip = "If enabled targets health current and max values will be displayed",
        width = "half",
        getFunc = function() return savedVars.enableHealth; end,
        setFunc = function() ToggleButton('health'); end,
    },  
    {
        type = "checkbox",
        name = "Show Health Percentages",
        tooltip = "If enabled, target's current health as percentages will be displayed",
        width = "half",
        getFunc = function() return savedVars.enableHealthPercent; end,
        setFunc = function() ToggleButton('percent'); end,
    },
    {
        type = "header",
        name = "Advanced",
        width = "full"
    },
    {
        type = "checkbox",
        name = "Enable Debugging",
        tooltip = "Not necessary for normal usage",
        width = "full",
        getFunc = function() return savedVars.enableDebug; end,
        setFunc = function() ToggleButton('debug'); end,
    },
}

---------------------------------------------------------------------
-- RainbowReticleOnLoad - initalization of RainbowReticle
local function RainbowReticleOnLoad(eventCode, addOnName)
    if addOnName ~= rr.name then return; end -- if not our AddOn, exit

    local LAM2 = LibStub("LibAddonMenu-2.0")
    -- Check that libAddonMenu loaded, otherwise exit as things are broken
    if not LAM2 then d("Unable to load libAddonMenu for " .. addOnName); return; end
  
    LAM2:RegisterAddonPanel("RainbowReticleOptions", rr.panelData)
    LAM2:RegisterOptionControls("RainbowReticleOptions", rr.optionsTable)

    savedVars = ZO_SavedVars:NewAccountWide("RAINBOWRETICLE_DB", 1, nil, rr.defaults)

    setupDefaultColors(savedVars)

    -- Update event manager with the events we wish to act upon
    EVENT_MANAGER:RegisterForEvent("RainbowReticle", EVENT_RETICLE_TARGET_CHANGED, OnTargetHasChanged)
    EVENT_MANAGER:RegisterForEvent("RainbowReticles", EVENT_RETICLE_HIDDEN_UPDATE, OnReticleHidden)
    EVENT_MANAGER:UnregisterForEvent("RainbowReticle", EVENT_ADD_ON_LOADED) -- unregister the AddOnLoaded event, no longer needed

    if (savedVars.enableDebug == true) then
        d(rr.name .. ' ' .. tostring(rr.version) .. " loaded successfully\n" )
	-- d("API Version: " .. tostring( GetAPIVersion()))
        -- d('Lua Version: ' .. _VERSION)
    end
end


--------------------------------------------------------------------------------------------------
-- This initalization function is specified / registered in the XML
function RainbowReticleInit()
    -- register the add on loading 'event', and tell it to run function 'RainbowReticleOnLoad'
    EVENT_MANAGER:RegisterForEvent("RainbowReticle", EVENT_ADD_ON_LOADED, RainbowReticleOnLoad)
end

--------------------------------------------------------------------------------------------------
-- update the reticle text display
-- this function is registered / specified in the UI XML for to be called on 'OnUpdate' events.
function RainbowReticleUpdate()
    -- this is in essence a delay timer, to avoid being run too frequently
    if (DelayCheck("rainbowreticleupdatebuffer", 300) == false) then return; end

    -- don't waste time if no unit (under Reticle)
    if (not DoesUnitExist('reticleover')) then return; end

    -- safety check, Ignore blank targets
    if (GetUnitName('reticleover') == "") then return; end

    if (savedVars.enableHealth or savedVars.enableHealthPercent) then
        updateHealthDisplay()
    end -- if enableHealth or HealthPercent
end -- RainbowReticleUpdate
