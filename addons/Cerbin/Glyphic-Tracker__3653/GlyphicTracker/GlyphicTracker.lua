-- First, we create a namespace for our addon by declaring a top-level table that will hold everything else.
GlyphicTracker = {}

GlyphicTracker.name = "GlyphicTracker"
GlyphicTracker.language = "FR"
GlyphicTracker.GlyphicSpawnTime = 0.0
GlyphicTracker.GlyphicActive = false
GlyphicTracker.ActiveGlyphicType = "None"

local GLYPHICTYPES = {REVITALIZING = 0, TIDES = 1, RESONATING = 2, NOTAGLYPHIC = -1}
local GLYPHICNAMES = {}
GLYPHICNAMES.Revitalizing = {}
GLYPHICNAMES.Revitalizing["EN"] = "Vitalizing Glyphic"
GLYPHICNAMES.Revitalizing["FR"] = "Glyphique vitalisant"
GLYPHICNAMES.Tides = {}
GLYPHICNAMES.Tides["EN"] = "Glyphic of the Tides"
GLYPHICNAMES.Tides["FR"] = "Glyphique des marées"
GLYPHICNAMES.Resonating = {} 
GLYPHICNAMES.Resonating["EN"] = "Resonating Glyphic"
GLYPHICNAMES.Resonating["FR"] = "Glyphique résonnateur"
local GLYPHICDURATION = 15.0
 
-- Next we create a function that will initialize our addon and restore indicator position
function GlyphicTracker.RestorePosition()
    local left = GlyphicTracker.savedVariables.left
    local top = GlyphicTracker.savedVariables.top
   
    GHT:ClearAnchors()
    GHT:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, left, top)
end

function GlyphicTracker.Initialize()
    GlyphicTracker.activeGlyphicTag = "none"

    GlyphicTracker.savedVariables = ZO_SavedVars:NewCharacterIdSettings("GlyphicTrackerSavedVariables", 1, nil, {debug = false})
    -- EVENT on Glyphic spawned
    EVENT_MANAGER:RegisterForEvent(GlyphicTracker.name, EVENT_UNIT_CREATED, GlyphicTracker.OnGlyphicSpawned)
    EVENT_MANAGER:AddFilterForEvent(GlyphicTracker.name, EVENT_UNIT_CREATED, REGISTER_FILTER_UNIT_TAG_PREFIX, "playerpet")

    -- EVENT on Glyphic despawned
    EVENT_MANAGER:RegisterForEvent(GlyphicTracker.name, EVENT_UNIT_DESTROYED, GlyphicTracker.OnGlyphicDestroyed)
    EVENT_MANAGER:AddFilterForEvent(GlyphicTracker.name, EVENT_UNIT_DESTROYED, REGISTER_FILTER_UNIT_TAG_PREFIX, "playerpet")

    -- EVENT on hud hide
    SCENE_MANAGER:GetScene("hud"):RegisterCallback("StateChange", GlyphicTracker.OnHudSceneChanged)
    SCENE_MANAGER:GetScene("hudui"):RegisterCallback("StateChange", GlyphicTracker.OnHudUISceneChanged)

    GlyphicTracker:RestorePosition()
end
 
-- Then we create an event handler function which will be called when the "addon loaded" event
-- occurs. We'll use this to initialize our addon after all of its resources are fully loaded.
function GlyphicTracker.OnAddOnLoaded(event, addonName)
  -- The event fires each time *any* addon loads - but we only care about when our own addon loads.
  if addonName == GlyphicTracker.name then
    GlyphicTracker.Initialize()
    --unregister the event again as our addon was loaded now and we do not need it anymore to be run for each other addon that will load
    EVENT_MANAGER:UnregisterForEvent(GlyphicTracker.name, EVENT_ADD_ON_LOADED) 
  end
end
 
-- Finally, we'll register our event handler function to be called when the proper event occurs.
-->This event EVENT_ADD_ON_LOADED will be called for EACH of the addns/libraries enabled, this is why there needs to be a check against the addon name
-->within your callback function! Else the very first addon loaded would run your code + all following addons too.
EVENT_MANAGER:RegisterForEvent(GlyphicTracker.name, EVENT_ADD_ON_LOADED, GlyphicTracker.OnAddOnLoaded)

----------

local function IsUnitGlyphic(unitName)
    local function IsIn(element, list) 
        for _, value in pairs(list) do
            if value == element then
                return true
            end
        end
        return false
    end
    if IsIn(unitName, GLYPHICNAMES.Revitalizing) then return true, GLYPHICTYPES.REVITALIZING
    elseif IsIn(unitName, GLYPHICNAMES.Tides) then return true, GLYPHICTYPES.TIDES
    elseif IsIn(unitName, GLYPHICNAMES.Resonating) then return true, GLYPHICTYPES.RESONATING
    else return false, GLYPHICTYPES.NOTAGLYPHIC
    end
end

----------

function GlyphicTracker.OnHealthUpdated(event, unitTag, powerIndex, powerType, powerValue, powerMax, powerEffectiveMax)
    GHTLabel:SetText(math.floor(100*powerValue/powerMax).." %")
    GHTStatusBar:SetValue(powerValue/powerMax)
    if ((os.time()-GlyphicTracker.GlyphicSpawnTime > 1.0) and ((GlyphicTracker.ActiveGlyphicType == GLYPHICTYPES.RESONATING and powerValue == 0.0) or powerValue == powerMax)) then
        GHTBackdrop:SetEdgeColor(0.8,0.0,0.6,1)
    end
end

function GlyphicTracker.OnGlyphicSpawned(eventCode, unitTag)
    local IsGlyphic, GlyphicType = IsUnitGlyphic(GetUnitName(unitTag))
    if (IsGlyphic) then
        
        GlyphicTracker.activeGlyphicTag = unitTag
        GlyphicTracker.ActiveGlyphicType = GlyphicType

        EVENT_MANAGER:RegisterForEvent(GlyphicTracker.name, EVENT_POWER_UPDATE, GlyphicTracker.OnHealthUpdated)
        EVENT_MANAGER:AddFilterForEvent(GlyphicTracker.name, EVENT_POWER_UPDATE, REGISTER_FILTER_UNIT_TAG, unitTag)
        EVENT_MANAGER:AddFilterForEvent(GlyphicTracker.name, EVENT_POWER_UPDATE, REGISTER_FILTER_POWER_TYPE, COMBAT_MECHANIC_FLAGS_HEALTH)

        if GlyphicType == GLYPHICTYPES.RESONATING then
            GHTBackdrop:SetEdgeColor(1, 0.6, 0, 1)
            GHTStatusBar:SetColor(1, 0.8, 0, 1)
        else
            GHTBackdrop:SetEdgeColor(0, 0.2, 0, 1)
            GHTStatusBar:SetColor(0, 0.8, 0, 1)
        end

        GlyphicTracker.GlyphicActive = true
        GlyphicTracker.GlyphicSpawnTime = os.time()

        LibAsync:While(function() return (os.time()-GlyphicTracker.GlyphicSpawnTime<=GLYPHICDURATION) end):Do(
            function()
                GHTTimeBar:SetValue((GLYPHICDURATION-(os.time()-GlyphicTracker.GlyphicSpawnTime))/GLYPHICDURATION)
            end)

        GHT:SetHidden(false)
    end
end

function GlyphicTracker.OnGlyphicDestroyed(eventCode, unitTag)
    if (unitTag == GlyphicTracker.activeGlyphicTag) then
        GlyphicTracker.activeGlyphicTag = "none"
        EVENT_MANAGER:UnregisterForEvent(GlyphicTracker.name, EVENT_POWER_UPDATE)

        GlyphicTracker.GlyphicActive = false
        GHT:SetHidden(true)
    end
end

----------

function GlyphicTracker.OnIndicatorMoveStop()
    GlyphicTracker.savedVariables.left = GHT:GetLeft()
    GlyphicTracker.savedVariables.top = GHT:GetTop()
end

function GlyphicTracker.OnHudSceneChanged(oldState, newState)
    if (newState == SCENE_SHOWN) then
        GHT:SetHidden(not GlyphicTracker.GlyphicActive and not GlyphicTracker.savedVariables.debug)
    elseif (newState == SCENE_HIDDEN) then
        GHT:SetHidden(true)
    end
end

function GlyphicTracker.OnHudUISceneChanged(oldState, newState)
    if (newState == SCENE_SHOWN) then
        GHT:SetHidden(not GlyphicTracker.savedVariables.debug and not GlyphicTracker.GlyphicActive)
    elseif (newState == SCENE_HIDDEN) then
        GHT:SetHidden(true)
    end
end

----------

local GTPanel = {
    type = "panel",
    name = "GlyphicTracker",
}

local GTOptions = {
    [1] = {
        type = "checkbox",
        name = "Debug",
        tooltip = "Toggle Debug.",
        getFunc = function() return GlyphicTracker.savedVariables.debug end,
        setFunc = function(value) GlyphicTracker.savedVariables.debug = value end,
   }
}

LibAddonMenu2:RegisterAddonPanel("GlyphicTrackerOptions", GTPanel)
LibAddonMenu2:RegisterOptionControls("GlyphicTrackerOptions", GTOptions)