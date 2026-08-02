
local PvPUA = {}
PvPUA.name = "PvPUA"

--------------------------------------------------
-- Config
--------------------------------------------------
PvPUA.config = {}
PvPUA.config.isClampedToScreen = true
PvPUA.config.imageWidth = 30
PvPUA.config.nameWidth = 165
PvPUA.config.flagWidth = 40
PvPUA.config.flagHeight = 8
PvPUA.config.flagFlipWidth = 40
PvPUA.config.underAttackForWidth = 50
PvPUA.config.width = 430
PvPUA.config.siegeWidth = 30
PvPUA.config.entryHeight = 32

--------------------------------------------------
-- ICON SIZES  <-- change icon sizes HERE, nowhere else
--------------------------------------------------
-- Every icon in the addon is sized by a multiplier in this one table.
-- 1.0 always means "the default size for that icon", whatever that icon's
-- own base happens to be, so you never have to think in pixels: 2.0 is
-- double, 0.5 is half, 1.25 is a quarter bigger.
--
-- Only these numbers need to change. Nothing else in the file has a
-- hardcoded icon size.
PvPUA.config.iconScale = {
    scrollCarrier = 1.65,  -- scroll pin on a moving scroll-carrier row
    scrollOnKeep  = 1.25,  -- small scroll drawn on top of a keep/town row
    volendrung    = 1.0,   -- hammer pin on the Volendrung row
    rank          = 1.25,  -- alliance/veterancy rank icon on the info row
    emperor       = 0.90,  -- emperor icon on the score row
    allianceScore = 1.0,   -- the three AD/DC/EP emblems on the score row
}

-- Height of the AP/veterancy progress bar on the info row, in pixels.
-- Not a multiplier: this one is a plain height, because the bar's WIDTH is
-- derived from the space left between the rank icon and the K:/D: block and
-- so isn't freely choosable. Bar is centred vertically in the row.
PvPUA.config.barHeight = 18

-- Font size for the two labels inside the progress bar (rank number on the
-- left, AP on the right).
--   0   = auto: sized to fill barHeight, so the text always scales with the
--         bar and you only ever have to change barHeight.
--   n   = force an exact pixel size, ignoring barHeight.
PvPUA.config.barFontSize = 0

-- Downward nudge, in pixels, for the text inside the bar.
-- Fonts reserve empty space at the BOTTOM of every line for descenders (the
-- tails on g, y, p). These labels are only digits and capitals, so that space
-- is always empty and the text reads as sitting high with a gap underneath,
-- even though the label box itself is perfectly centred. This shifts the text
-- down to sit optically centred instead of mathematically centred.
--   0 = mathematically centred (text will look high)
--   n = push down n pixels
PvPUA.config.barTextNudge = 2

--------------------------------------------------
-- K: / D: readout (right end of the info row)
--------------------------------------------------
-- Rendered as one right-aligned string, e.g. "K: 233 D: 233". The right edge
-- is pinned; adding digits grows the text leftward.
PvPUA.config.kdGap       = "  "  -- spacing between the K: and D: halves
PvPUA.config.kdRightPad  = 4     -- gap between D: and the right edge of the row
PvPUA.config.kdTextNudge = 2     -- push text down; same descender fix as the bar
PvPUA.config.kdFontSize  = 20    -- font size in pixels

-- Volendrung row icon colouring.
--   true  = tint the neutral hammer with THIS addon's alliance colours, so it
--           matches keeps, resources and the row text exactly.
--   false = use ZeniMax's own four alliance hammer pins, so it matches the
--           in-game map pin instead. Their palette is lighter than ours, which
--           is why the icon looked washed out next to everything else.
PvPUA.config.volendrungTintToHud = true
PvPUA.config.height = PvPUA.config.entryHeight * 10
PvPUA.config.backdropAlphaOdd = 0.25
PvPUA.config.backdropAlphaEven = 0.15
PvPUA.config.flagBackdropColor = { r = 0.1, g = 0.1, b = 0.1 }

--------------------------------------------------
-- Constants
--------------------------------------------------
PvPUA.constants = {}
PvPUA.constants.updateInterval = 1000
PvPUA.constants.siegeTimeout = 5000
PvPUA.constants.resourceType = { FARM = 1, MINE = 2, LUMBER = 3 }
PvPUA.constants.flipTimes = { KEEP = 20000, OUTPOST = 20000, RESOURCE = 20000 }

PvPUA.constants.textures = {}
PvPUA.constants.textures.KEEP = "/esoui/art/mappins/ava_largekeep_neutral.dds"
PvPUA.constants.textures.OUTPOST = "/esoui/art/mappins/ava_outpost_neutral.dds"
PvPUA.constants.textures.VILLAGE = "/esoui/art/mappins/ava_town_neutral.dds"
PvPUA.constants.textures.RESOURCE_MINE = "/esoui/art/compass/ava_mine_neutral.dds"
PvPUA.constants.textures.RESOURCE_FARM = "/esoui/art/compass/ava_farm_neutral.dds"
PvPUA.constants.textures.RESOURCE_LUMBER = "/esoui/art/compass/ava_lumbermill_neutral.dds"
PvPUA.constants.textures.BRIDGE_PASSABLE = "/esoui/art/mappins/ava_bridge_passable.dds"
PvPUA.constants.textures.BRIDGE_NOT_PASSABLE = "/esoui/art/mappins/ava_bridge_not_passable.dds"
PvPUA.constants.textures.MILEGATE_PASSABLE = "/esoui/art/mappins/ava_milegate_passable.dds"
PvPUA.constants.textures.MILEGATE_NOT_PASSABLE = "/esoui/art/mappins/ava_milegate_not_passable.dds"

-- Hardcoded player icon assignments (displayName lowercase -> settings table)
-- Add or remove players here to control who gets an icon.
--
-- Each entry:
--   texture      = path to the .dds  (required)
--   scale        = size multiplier   (optional, default 1.0)
--                    1.0 = current default size
--                    1.5 = 50% bigger, 0.75 = 25% smaller
--                  Grows proportionally; the icon keeps its shape.
--   heightOffset = vertical nudge    (optional, default 0)
--                    positive = floats HIGHER above the head
--                    negative = sits LOWER, closer to the head
--                  Same units as ICON_MARKER_DATA.Y (which is 3.75),
--                  so 0.5 is a modest nudge, 1.0 is noticeable.
--
-- Omit scale/heightOffset to use the shared defaults. Changing one player's
-- values never affects anyone else.
--
-- ============================================================
--  DEFAULTS -- if you forget what "normal" was, it is ALWAYS:
--        scale        = 1.0
--        heightOffset = 0
--        alpha        = 1.0   (1.0 = solid, 0.5 = half see-through, 0 = invisible)
--  Setting a player to those three values, or simply deleting the
--  fields from their line, restores them to the default look.
--  These never change no matter what anyone else is set to.
--  (The underlying numbers live in ICON_MARKER_DATA below:
--   scaleX/scaleY = 2, Y = 3.75. Edit THAT to move everyone.)
-- ============================================================
PvPUA.constants.userIcons = {
    -- default look (no overrides):
    --   ["@name"] = { texture = "PvPUA/Textures/icon_x.dds" },
    -- customised example:
    --   ["@name"] = { texture = "PvPUA/Textures/icon_x.dds", scale = 1.25, heightOffset = 0.5 },
    -- see-through example:
    --   ["@name"] = { texture = "PvPUA/Textures/icon_x.dds", alpha = 0.5 },
    ["@user562"]         = { texture = "PvPUA/Textures/icon_panda.dds", alpha = 0.65 },
    ["@sir gilson7"]     = { texture = "PvPUA/Textures/icon_werewolf.dds" },
    ["@get em nala"]     = { texture = "PvPUA/Textures/icon_hedgehog.dds" },
    ["@suzyqboston3383"] = { texture = "PvPUA/Textures/icon_trinity.dds", heightOffset = 1.0 },
    ["@suzibrew"]        = { texture = "PvPUA/Textures/icon_elephant.dds" },
    ["@im taiyo"]        = { texture = "PvPUA/Textures/icon_hello.dds" },
    ["@maddogmcree6157"] = { texture = "PvPUA/Textures/icon_devildog.dds" },
    ["@sgt bear78fh"]    = { texture = "PvPUA/Textures/icon_bear.dds", heightOffset = 1.0 },
}

--------------------------------------------------
PvPUA.state = {}
PvPUA.state.visibleControls = {}
PvPUA.state.resources = {}
PvPUA.state.keeps = {}
PvPUA.state.outposts = {}
PvPUA.state.villages = {}
PvPUA.state.destructibles = {}

PvPUA.controls = {}
PvPUA.savedVariables = nil
PvPUA.showInMenu = false
PvPUA.cachedFont = nil
PvPUA.volendrung = nil
PvPUA.initializedItems = false
PvPUA.registeredCyroEvents = false
PvPUA.creditCycle = 0

PvPUA.session = { killingBlows = 0, deaths = 0 }

local CREDIT_STATES = {}
local ALLIANCE_STR  = "Alliance!"
local CYCLE_COLORS  = { "2A6FFF", "E6C800", "CC2222" }
local totalSteps    = #ALLIANCE_STR * #CYCLE_COLORS
for step = 0, totalSteps - 1 do
    local colorIndex  = math.floor(step / #ALLIANCE_STR) + 1
    local letterIndex = (step % #ALLIANCE_STR) + 1
    local animated    = ""
    for i = 1, #ALLIANCE_STR do
        local ch = ALLIANCE_STR:sub(i, i)
        if i <= letterIndex then
            animated = animated .. "|c" .. CYCLE_COLORS[colorIndex] .. ch .. "|r"
        else
            local prevColor = colorIndex > 1 and CYCLE_COLORS[colorIndex - 1] or CYCLE_COLORS[#CYCLE_COLORS]
            animated = animated .. "|c" .. prevColor .. ch .. "|r"
        end
    end
    CREDIT_STATES[step] = "|c2A6FFFDC|r, |c00FF00the BEST|r " .. animated .. " - |c00FF00user562|r"
end

--------------------------------------------------
-- Combat Tracking Locals
--------------------------------------------------
local pvpPlayerName         = nil
local pvpRecentKBs          = { count = 0 }
local pvpIsCombatRegistered = false

local VOLENDRUNG_DESPAWN_GRACE = 10000

local wm = WINDOW_MANAGER



--------------------------------------------------
-- Player Icon System (OSI approach)
--------------------------------------------------
PvPUA.playerIcon = {}
local PI = PvPUA.playerIcon

PI.toplevel = nil   -- exact copy of AD3D.toplevel
PI.markers  = {}    -- displayName(lower) -> marker object (one persistent marker per hardcoded player)
PI.running  = false
PI.updateInterval = 10  -- exact copy of crown.updateInterval

-- Marker definition, equivalent to Artaeum's markerTypes.Crown.
-- scaleX/scaleY = 3 and Y = 4 are copied from Artaeum's Crown entry.
--
-- *** THIS IS THE SHARED DEFAULT BASELINE FOR EVERY ICON ***
-- Per-player scale/heightOffset in userIcons are applied ON TOP of these:
--     final size   = scaleX/scaleY * (player's scale or 1.0)
--     final height = Y             + (player's heightOffset or 0)
-- So a player with scale 1.0 and heightOffset 0 renders exactly as below.
-- Changing these numbers moves EVERYONE; changing userIcons moves one person.
local ICON_MARKER_DATA = {
    scaleX = 2,
    scaleY = 2,
    X = 0,
    Y = 3.75,
    Z = 0,
    depthBuffer = false,
}

--------------------------------------------------
-- create3D: EXACT copy of Artaeum AD3D.create3D (utils/AD_3D.lua),
-- only renamed (beam -> marker, AD3D.toplevel -> PI.toplevel).
--------------------------------------------------
local function PICreate3D(toplevel, data)
    local marker = wm:CreateControl(nil, toplevel, CT_TEXTURE)

    function marker:updateSize()
        self:Set3DLocalDimensions(self.size.X * self.scale, self.size.Y * self.scale)
    end

    function marker:updateMarkerData(data)
        self.offset = {
            X = data.X or 0,
            Y = data.Y or 0,
            Z = data.Z or 0
        }
        self.size = {
            X = data.scaleX or 1,
            Y = data.scaleY or 1
        }
        self.texture = data.texture or ""

        if data.depthBuffer == nil then self.depthBuffer = true else self.depthBuffer = data.depthBuffer end
        if data.facePlayer == nil then self.facePlayer = true else self.facePlayer = data.facePlayer end

        self:Set3DRenderSpaceUsesDepthBuffer(self.depthBuffer)
        self:SetTexture(self.texture)
        self:updateSize()
    end

    marker.scale = 1
    marker.userOffset = 0

    marker:Create3DRenderSpace()
    marker:SetDrawLevel(1)
    marker:Set3DRenderSpaceOrigin(0, 0, 0)
    marker:updateMarkerData(data)
    marker:SetHidden(true)

    function marker:setPos(X, Y, Z)
        if not self.enabled then return end
        self:turnToFace()
        self:Set3DRenderSpaceOrigin(X + self.offset.X, Y + self.offset.Y + self.userOffset, Z + self.offset.Z)
    end

    function marker:turnToFace()
        if not self.enabled then return end
        if self.facePlayer then
            local heading = GetPlayerCameraHeading()
            if heading > math.pi then
                heading = heading - 2 * math.pi
            end
            self:Set3DRenderSpaceOrientation(0, heading, 0)
        end
    end

    function marker:setColour(r, g, b, a)
        self:SetColor(r, g, b, a)
    end

    function marker:setUserOffset(offset)
        self.userOffset = offset
    end

    function marker:show()
        if self.enabled then
            self:SetTexture(self.texture)
            self:SetHidden(false)
        end
    end
    function marker:hide()
        self:SetTexture("")
        if self.enabled then
            self:SetHidden(true)
        end
    end

    function marker:enable()
        self.enabled = true
    end
    function marker:disable()
        self.enabled = false
        self:SetHidden(true)
        self:SetTexture("")
    end

    function marker:setScale(scale)
        self.scale = scale
        self:updateSize()
    end

    return marker
end

--------------------------------------------------
-- Init: equivalent to Artaeum's AD3D.toplevel creation + crown.createArrow (the pin part).
-- Difference from Artaeum: we create ONE marker per hardcoded player in userIcons,
-- instead of a single crown marker.
--------------------------------------------------
function PI.Init()
    PI.toplevel = wm:CreateTopLevelWindow("PvPUA_PIWin")
    PI.toplevel:SetDrawLayer(0)

    -- one persistent marker per hardcoded @name, each with that player's
    -- texture plus optional per-player scale / heightOffset overrides.
    for nameLower, info in pairs(PvPUA.constants.userIcons) do
        -- tolerate the old "name = texture string" format just in case
        if type(info) == "string" then info = { texture = info } end

        local scale  = info.scale or 1.0
        local hOff   = info.heightOffset or 0
        local alpha  = info.alpha or 1.0

        local data = {
            texture    = info.texture,
            scaleX     = ICON_MARKER_DATA.scaleX * scale,
            scaleY     = ICON_MARKER_DATA.scaleY * scale,
            X          = ICON_MARKER_DATA.X,
            Y          = ICON_MARKER_DATA.Y + hOff,
            Z          = ICON_MARKER_DATA.Z,
            depthBuffer = ICON_MARKER_DATA.depthBuffer,
        }
        local marker = PICreate3D(PI.toplevel, data)
        -- (1,1,1) is the neutral tint -- the icon keeps its own colours.
        -- Only the 4th value (alpha) does anything here: 1.0 = fully solid,
        -- 0.5 = half see-through. Anyone without an "alpha" field gets 1.0.
        marker:setColour(1, 1, 1, alpha)
        PI.markers[nameLower] = marker
    end
end

--------------------------------------------------
-- Resolve which unitTag currently belongs to a given hardcoded @name.
-- Returns the unitTag ("player" or "groupN") if that player is present, else nil.
--
-- IMPORTANT: a name match alone is NOT enough. When a group member logs off,
-- ESO keeps their groupN slot populated for a while -- GetUnitDisplayName still
-- returns their @name, and GetUnitRawWorldPosition still returns their LAST
-- known coords. Without the guard below the marker would sit frozen at the spot
-- where they disconnected. So we also require the unit to still exist and be
-- online. (Both APIs are the ones ArtaeumGroupTool uses in its group frames:
-- DoesUnitExist in frameObject:DeathLoop, IsUnitOnline in frameObject:SetOnline.)
--------------------------------------------------
local function PIFindUnitForName(nameLower)
    -- self (always present/online if this code is running)
    local selfName = GetDisplayName()
    if selfName and string.lower(selfName) == nameLower then
        return "player"
    end
    -- group members
    if IsUnitGrouped("player") then
        for i = 1, 12 do
            local unit = "group" .. i
            local dn = GetUnitDisplayName(unit)
            if dn and dn ~= "" and string.lower(dn) == nameLower then
                -- name matches -- but only track them if they are actually
                -- still in the world and connected (see note above)
                if DoesUnitExist(unit) and IsUnitOnline(unit) then
                    return unit
                end
                return nil
            end
        end
    end
    return nil
end

--------------------------------------------------
-- updateMarker: equivalent to Artaeum's crown.updateMarker, generalized to all markers.
-- For each hardcoded player, find their unit, read raw world position, convert, setPos.
--------------------------------------------------
function PI.updateMarker()
    local showSelf   = PvPUA.savedVariables and PvPUA.savedVariables.iconShowSelf
    local showOthers = PvPUA.savedVariables and PvPUA.savedVariables.iconShowOthers

    for nameLower, marker in pairs(PI.markers) do
        local unit = PIFindUnitForName(nameLower)

        -- apply self/others visibility toggles
        local allowed = false
        if unit == "player" then
            allowed = showSelf
        elseif unit then
            allowed = showOthers
        end

        if unit and allowed then
            if not marker.enabled then
                marker:enable()
                marker:show()
            end
            local _, Xw, Yw, Zw = GetUnitRawWorldPosition(unit)
            local X, Y, Z = WorldPositionToGuiRender3DPosition(Xw, Yw, Zw)
            marker:setPos(X, Y, Z)
        else
            if marker.enabled then
                marker:disable()
            end
        end
    end
end

--------------------------------------------------
-- Polling: equivalent to Artaeum registering crown.updateMarker on a timer.
-- Artaeum uses crown.updateInterval (10ms); we do the same. Wrapped in pcall so a
-- render error reports once instead of spamming every tick.
--------------------------------------------------
function PI.StartPolling()
    if PI.running then return end
    EVENT_MANAGER:RegisterForUpdate("PvPUA_PlayerIconUpdate", PI.updateInterval, function()
        local ok = pcall(PI.updateMarker)
        if not ok then
            EVENT_MANAGER:UnregisterForUpdate("PvPUA_PlayerIconUpdate")
            PI.running = false
        end
    end)
    PI.running = true
end

function PI.StopPolling()
    if not PI.running then return end
    EVENT_MANAGER:UnregisterForUpdate("PvPUA_PlayerIconUpdate")
    PI.running = false
    for _, marker in pairs(PI.markers) do
        marker:disable()
    end
end

--------------------------------------------------
-- Timer Colors
--------------------------------------------------
local function GetTimerColor()
    local c = PvPUA.savedVariables and PvPUA.savedVariables.timerColor
    if type(c) == "table" then
        return c.r or 1, c.g or 1, c.b or 1
    end
    -- fallback for old string-based saves
    return 1, 1, 1
end

function PvPUA:GetFont()
    if not self.cachedFont then
        local path = self.savedVariables and self.savedVariables.font or "EsoUI/Common/Fonts/FTN47.otf"
        local size = "25"
        self.cachedFont = path .. "|" .. size .. "|outline"
    end
    return self.cachedFont
end

function PvPUA:InvalidateFontCache()
    self.cachedFont = nil
end

--------------------------------------------------
-- Alliance Colors
--------------------------------------------------
local allianceColors = {
    [ALLIANCE_ALDMERI_DOMINION]    = { r = 0.9, g = 0.78, b = 0 },
    [ALLIANCE_DAGGERFALL_COVENANT] = { r = 0.16, g = 0.44, b = 1 },
    [ALLIANCE_EBONHEART_PACT]      = { r = 0.8, g = 0.13, b = 0.13 },
}
local noAllianceColor = { r = 1, g = 1, b = 1 }

local function GetColorForAlliance(alliance)
    return allianceColors[alliance] or noAllianceColor
end

-- Moved up from its original spot near FireKeepUA so GetScrollCarrierItems
-- (much earlier in the file) can also use it for the scroll-name/holder
-- color markup. Behavior is unchanged, only the definition point moved.
local function ToHex(r, g, b)
    return string.format("%02X%02X%02X", math.floor(r*255), math.floor(g*255), math.floor(b*255))
end

--------------------------------------------------
-- Volendrung Helpers
--------------------------------------------------
local function GetVolendrungTexture(pinType)
    if pinType and ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[pinType] then
        local tex = ZO_MapPin.PIN_DATA[pinType].texture
        if tex and type(tex) == "string" then return tex end
    end
    if pinType == MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_ALDMERI    then return "/esoui/art/mappins/ava_daedricartifact_volendrung_aldmeri.dds"    end
    if pinType == MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_DAGGERFALL  then return "/esoui/art/mappins/ava_daedricartifact_volendrung_daggerfall.dds"  end
    if pinType == MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_EBONHEART   then return "/esoui/art/mappins/ava_daedricartifact_volendrung_ebonheart.dds"   end
    return "/esoui/art/mappins/ava_daedricartifact_volendrung_neutral.dds"
end

local function GetVolendrungAlliance(pinType)
    if pinType == MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_ALDMERI    then return ALLIANCE_ALDMERI_DOMINION    end
    if pinType == MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_DAGGERFALL  then return ALLIANCE_DAGGERFALL_COVENANT  end
    if pinType == MAP_PIN_TYPE_AVA_DAEDRIC_ARTIFACT_VOLENDRUNG_EBONHEART   then return ALLIANCE_EBONHEART_PACT       end
    return 0
end

--------------------------------------------------
-- Zone Detection
--------------------------------------------------
local function IsInCyrodiilOrIC()
    if IsInCyrodiil() == true then
        return true
    elseif IsInCyrodiil() == false and IsPlayerInAvAWorld() == true and IsInAvAZone() == true and IsInImperialCity() == false and IsActiveWorldBattleground() == false then
        return true
    else
        return false
    end
end

--------------------------------------------------
-- Name Helpers
--------------------------------------------------
local function AdjustResourceName(name)
    name = name:gsub("Castle ", ""):gsub("[fF]ort ", ""):gsub("Keep ", ""):gsub("[Ll]umbermill", "Lumber")
    return name
end

local function AdjustKeepName(name)
    name = name:gsub(",..$", ""):gsub("Castle ", ""):gsub("[fF]ort ", ""):gsub("Keep ", ""):gsub("Keep", "")
    return name
end

local function AdjustOutpostName(name)
    name = name:gsub("Outpost", "")
    return name
end

--------------------------------------------------
-- Init Functions
--------------------------------------------------
function PvPUA:InitResources(gameTime)
    local resources = { 22, 23, 24, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54, 55, 56, 57,
                        61, 62, 63, 64, 65, 66, 67, 68, 69, 70, 71, 72, 73, 74, 75, 76, 77, 78, 79, 80, 81, 82, 83, 84, 85, 86, 87 }
    self.state.resources = {}
    for i = 1, #resources do
        local id = resources[i]
        self.state.resources[id] = {}
        self.state.resources[id].id = id
        self.state.resources[id].keepType = GetKeepType(id)
        self.state.resources[id].name = AdjustResourceName(zo_strformat("<<1>>", GetKeepName(id)))
        self.state.resources[id].isUnderAttack = GetKeepUnderAttack(id, BGQUERY_LOCAL)
        if self.state.resources[id].isUnderAttack == true then
            self.state.resources[id].interestingSince = gameTime
        else
            self.state.resources[id].interestingSince = nil
        end
        self.state.resources[id].attackStatusLostAt = 0
        self.state.resources[id].underAttackFor = 0
        self.state.resources[id].siegeWeapons = {}
        self.state.resources[id].siegeWeapons.AD = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
        self.state.resources[id].siegeWeapons.DC = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
        self.state.resources[id].siegeWeapons.EP = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
        self.state.resources[id].owningAlliance = GetKeepAlliance(id, BGQUERY_LOCAL)
    end
end

function PvPUA:InitKeeps(gameTime)
    self.state.keeps = {}
    for i = 3, 20 do
        self.state.keeps[i] = {}
        self.state.keeps[i].id = i
        self.state.keeps[i].keepType = GetKeepType(i)
        self.state.keeps[i].name = AdjustKeepName(zo_strformat("<<1>>", GetKeepName(i)))
        self.state.keeps[i].isUnderAttack = GetKeepUnderAttack(i, BGQUERY_LOCAL)
        if self.state.keeps[i].isUnderAttack == true then
            self.state.keeps[i].interestingSince = gameTime
        else
            self.state.keeps[i].interestingSince = nil
        end
        self.state.keeps[i].attackStatusLostAt = 0
        self.state.keeps[i].underAttackFor = 0
        self.state.keeps[i].siegeWeapons = {}
        self.state.keeps[i].siegeWeapons.AD = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
        self.state.keeps[i].siegeWeapons.DC = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
        self.state.keeps[i].siegeWeapons.EP = GetNumSieges(i, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
        self.state.keeps[i].owningAlliance = GetKeepAlliance(i, BGQUERY_LOCAL)
        self.state.keeps[i].resources = {}
        local farmId = GetResourceKeepForKeep(i, RESOURCETYPE_FOOD)
        local lumberId = GetResourceKeepForKeep(i, RESOURCETYPE_WOOD)
        local mineId = GetResourceKeepForKeep(i, RESOURCETYPE_ORE)
        if self.state.resources[farmId] then
            self.state.resources[farmId].rType = PvPUA.constants.resourceType.FARM
        end
        if self.state.resources[lumberId] then
            self.state.resources[lumberId].rType = PvPUA.constants.resourceType.LUMBER
        end
        if self.state.resources[mineId] then
            self.state.resources[mineId].rType = PvPUA.constants.resourceType.MINE
        end
    end
    -- Build per-alliance home keep lookup by matching known home keep name fragments
    local allianceHomeKeepNames = {
        [ALLIANCE_ALDMERI_DOMINION]    = { "Alessia", "Black Boot", "Bloodmayne", "Brindle", "Faregyl", "Roebeck" },
        [ALLIANCE_DAGGERFALL_COVENANT] = { "Aleswell", "Ash", "Dragonclaw", "Glademist", "Rayles", "Warden" },
        [ALLIANCE_EBONHEART_PACT]      = { "Arrius", "Blue Road", "Chalman", "Drakelowe", "Farragut", "Kingscrest" },
    }
    -- homeKeepIds[keepId] = alliance that owns that keep by default
    self.homeKeepIds = {}
    for i = 3, 20 do
        local rawName = zo_strformat("<<1>>", GetKeepName(i))
        for alliance, names in pairs(allianceHomeKeepNames) do
            for _, hkName in ipairs(names) do
                if rawName:find(hkName) then
                    self.homeKeepIds[i] = alliance
                    break
                end
            end
        end
    end
end

function PvPUA:InitOutposts(gameTime)
    local outposts = { 132, 133, 134, 163, 164, 165 }
    self.state.outposts = {}
    for i = 1, #outposts do
        local id = outposts[i]
        self.state.outposts[id] = {}
        self.state.outposts[id].id = id
        self.state.outposts[id].keepType = GetKeepType(id)
        self.state.outposts[id].name = AdjustOutpostName(zo_strformat("<<1>>", GetKeepName(id)))
        self.state.outposts[id].isUnderAttack = GetKeepUnderAttack(id, BGQUERY_LOCAL)
        if self.state.outposts[id].isUnderAttack == true then
            self.state.outposts[id].interestingSince = gameTime
        else
            self.state.outposts[id].interestingSince = nil
        end
        self.state.outposts[id].attackStatusLostAt = 0
        self.state.outposts[id].underAttackFor = 0
        self.state.outposts[id].siegeWeapons = {}
        self.state.outposts[id].siegeWeapons.AD = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
        self.state.outposts[id].siegeWeapons.DC = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
        self.state.outposts[id].siegeWeapons.EP = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
        self.state.outposts[id].owningAlliance = GetKeepAlliance(id, BGQUERY_LOCAL)
    end
end

function PvPUA:InitVillages(gameTime)
    local villages = { 149, 151, 152 }
    self.state.villages = {}
    for i = 1, #villages do
        local id = villages[i]
        self.state.villages[id] = {}
        self.state.villages[id].id = id
        self.state.villages[id].keepType = GetKeepType(id)
        self.state.villages[id].name = zo_strformat("<<1>>", GetKeepName(id))
        self.state.villages[id].isUnderAttack = GetKeepUnderAttack(id, BGQUERY_LOCAL)
        if self.state.villages[id].isUnderAttack == true then
            self.state.villages[id].interestingSince = gameTime
        else
            self.state.villages[id].interestingSince = nil
        end
        self.state.villages[id].attackStatusLostAt = 0
        self.state.villages[id].underAttackFor = 0
        self.state.villages[id].siegeWeapons = {}
        self.state.villages[id].siegeWeapons.AD = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
        self.state.villages[id].siegeWeapons.DC = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
        self.state.villages[id].siegeWeapons.EP = GetNumSieges(id, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
        self.state.villages[id].owningAlliance = GetKeepAlliance(id, BGQUERY_LOCAL)
    end
end

function PvPUA:InitDestructibles(gameTime)
    self.state.destructibles = {}
    for i = 154, 162 do
        self.state.destructibles[i] = {}
        self.state.destructibles[i].id = i
        self.state.destructibles[i].keepType = GetKeepType(i)
        self.state.destructibles[i].name = AdjustResourceName(zo_strformat("<<1>>", GetKeepName(i)))
        self.state.destructibles[i].isUnderAttack = GetKeepUnderAttack(i, BGQUERY_LOCAL)
        if self.state.destructibles[i].isUnderAttack == true then
            self.state.destructibles[i].interestingSince = gameTime
        else
            self.state.destructibles[i].interestingSince = nil
        end
        self.state.destructibles[i].attackStatusLostAt = 0
        self.state.destructibles[i].underAttackFor = 0
        self.state.destructibles[i].isPassable = IsKeepPassable(i, BGQUERY_LOCAL)
        self.state.destructibles[i].directionalAccess = GetKeepDirectionalAccess(i, BGQUERY)
    end
end

function PvPUA:InitState(hadVolendrung)
    local gameTime = GetGameTimeMilliseconds()
    self:InitResources(gameTime)
    self:InitKeeps(gameTime)
    self:InitOutposts(gameTime)
    self:InitVillages(gameTime)
    self:InitDestructibles(gameTime)
    self:AddObjectives()
    self:ScanForVolendrung()
    self:ScanForScrolls()
    if self.volendrung == nil and hadVolendrung then
        self.volendrung = hadVolendrung
        self.volendrung.despawnAt = GetGameTimeMilliseconds() + VOLENDRUNG_DESPAWN_GRACE
    end
end

--------------------------------------------------
-- ScanForVolendrung
--------------------------------------------------
function PvPUA:ScanForVolendrung()
    if not GetNumObjectives then return end
    local n = GetNumObjectives()
    if not n then return end
    for i = 1, n do
        local keepId, objectiveId = GetObjectiveIdsForIndex(i)
        if keepId and objectiveId then
            local objectiveName, objectiveType, objectiveState = GetObjectiveInfo(keepId, objectiveId, BGQUERY_LOCAL)
            if objectiveType == OBJECTIVE_DAEDRIC_WEAPON then
                local objectiveControlEvent = GetLastObjectiveControlEvent(keepId, objectiveId, BGQUERY_LOCAL)
                if objectiveState == OBJECTIVE_CONTROL_STATE_FLAG_DROPPED
                or objectiveState == OBJECTIVE_CONTROL_STATE_FLAG_HELD
                or objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED
                or (objectiveState ~= nil and objectiveState ~= OBJECTIVE_CONTROL_STATE_UNKNOWN) then
                    local pinType = GetObjectivePinInfo(keepId, objectiveId, BGQUERY_LOCAL)
                    self.volendrung = {
                        texture        = GetVolendrungTexture(pinType),
                        holderAlliance = GetVolendrungAlliance(pinType),
                        objectiveId    = objectiveId,
                        keepId         = keepId,
                        despawnAt      = nil,
                        spawnedAt      = GetGameTimeMilliseconds(),
                    }
                    return
                end
            end
        end
    end
end

--------------------------------------------------
-- Scroll Helpers (parallel to Volendrung; does NOT touch Volendrung).
--
-- Detection uses the base game's own approach (from esoui keeptooltip.lua):
-- ask each keep whether it currently holds a scroll via GetKeepArtifactObjectiveId,
-- then read that objective. This is keep-first and reports the scroll's CURRENT
-- keep, so it works whether the scroll is in its home temple or captured into an
-- enemy keep, and whether it was placed before login or moved while playing.
--
-- Scroll color is ALWAYS the scroll's own home alliance:
-- GetArtifactScrollObjectiveOriginalOwningAlliance gives that directly.
--------------------------------------------------
-- pinType -> AvA mappin texture, fallback only if ZO_MapPin.PIN_DATA is missing.
local SCROLL_TEXTURE_FALLBACK = {
    [MAP_PIN_TYPE_ARTIFACT_ALDMERI_OFFENSIVE]     = "/esoui/art/mappins/ava_artifact_altadoon.dds",
    [MAP_PIN_TYPE_ARTIFACT_ALDMERI_DEFENSIVE]     = "/esoui/art/mappins/ava_artifact_mnem.dds",
    [MAP_PIN_TYPE_ARTIFACT_EBONHEART_OFFENSIVE]   = "/esoui/art/mappins/ava_artifact_ghartok.dds",
    [MAP_PIN_TYPE_ARTIFACT_EBONHEART_DEFENSIVE]   = "/esoui/art/mappins/ava_artifact_chim.dds",
    [MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_OFFENSIVE]  = "/esoui/art/mappins/ava_artifact_nimohk.dds",
    [MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_DEFENSIVE]  = "/esoui/art/mappins/ava_artifact_almaruma.dds",
}

-- pinType -> the scroll's OWN alliance, used only as a fallback for color if the
-- original-owning-alliance API returns nothing.
local SCROLL_PINTYPE_ALLIANCE = {
    [MAP_PIN_TYPE_ARTIFACT_ALDMERI_OFFENSIVE]     = ALLIANCE_ALDMERI_DOMINION,
    [MAP_PIN_TYPE_ARTIFACT_ALDMERI_DEFENSIVE]     = ALLIANCE_ALDMERI_DOMINION,
    [MAP_PIN_TYPE_ARTIFACT_EBONHEART_OFFENSIVE]   = ALLIANCE_EBONHEART_PACT,
    [MAP_PIN_TYPE_ARTIFACT_EBONHEART_DEFENSIVE]   = ALLIANCE_EBONHEART_PACT,
    [MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_OFFENSIVE]  = ALLIANCE_DAGGERFALL_COVENANT,
    [MAP_PIN_TYPE_ARTIFACT_DAGGERFALL_DEFENSIVE]  = ALLIANCE_DAGGERFALL_COVENANT,
}

local function GetScrollTexture(pinType)
    if pinType and ZO_MapPin and ZO_MapPin.PIN_DATA and ZO_MapPin.PIN_DATA[pinType] then
        local tex = ZO_MapPin.PIN_DATA[pinType].texture
        if tex and type(tex) == "string" then return tex end
    end
    return SCROLL_TEXTURE_FALLBACK[pinType]
end

--------------------------------------------------
-- Scroll display, poll-based (CyrHUD's proven console pattern).
--------------------------------------------------
-- Paint scrolls onto keeps by POLLING every objective each tick (CyrHUD's proven
-- console pattern). A scroll is shown only when its state is FLAG_AT_ENEMY_BASE —
-- i.e. captured and stored in an enemy keep. When someone picks it up the state
-- flips to FLAG_HELD/FLAG_DROPPED and it stops being drawn on the next poll. A scroll
-- resting in its own home temple is FLAG_AT_BASE and is intentionally not shown.
-- Color = scroll's own (original owning) alliance.
function PvPUA:RefreshScrolls()
    local ok = pcall(function()
        for _, keep in pairs(self.state.keeps) do keep.scroll = nil end
        for _, town in pairs(self.state.villages) do town.scroll = nil end

        if not GetNumObjectives then return end
        local keysFn = GetAvAObjectiveKeysByIndex or GetObjectiveIdsForIndex
        local n = GetNumObjectives() or 0
        for i = 1, n do
            local keepId, objectiveId, ctx = keysFn(i)
            if keepId and objectiveId then
                local ctxUse = ctx or BGQUERY_LOCAL
                local _, oType, oState = GetObjectiveInfo(keepId, objectiveId, ctxUse)
                if (oType == OBJECTIVE_ARTIFACT_OFFENSIVE or oType == OBJECTIVE_ARTIFACT_DEFENSIVE)
                and oState == OBJECTIVE_CONTROL_STATE_FLAG_AT_ENEMY_BASE then
                    -- which enemy keep is it stored in?
                    local atKeep
                    if GetKeepThatHasCapturedThisArtifactScrollObjective then
                        atKeep = GetKeepThatHasCapturedThisArtifactScrollObjective(keepId, objectiveId, ctxUse)
                    end
                    local target
                    if atKeep and atKeep ~= 0 then
                        target = self.state.keeps[atKeep] or self.state.villages[atKeep]
                    end
                    if target then
                        local pinType = GetObjectivePinInfo(keepId, objectiveId, ctxUse)
                        local home
                        if GetArtifactScrollObjectiveOriginalOwningAlliance then
                            home = GetArtifactScrollObjectiveOriginalOwningAlliance(keepId, objectiveId, ctxUse)
                        end
                        if not home or home == 0 then home = SCROLL_PINTYPE_ALLIANCE[pinType] or 0 end
                        if pinType then
                            target.scroll = {
                                pinType         = pinType,
                                holdingAlliance = home,
                                objectiveId     = objectiveId,
                            }
                        end
                    end
                end
            end
        end
    end)
    if not ok then
        for _, keep in pairs(self.state.keeps) do keep.scroll = nil end
        for _, town in pairs(self.state.villages) do town.scroll = nil end
    end
end

-- Called once at init: the per-tick poll handles already-placed scrolls too.
function PvPUA:ScanForScrolls()
    self:RefreshScrolls()
end

--------------------------------------------------
-- Scroll CARRIERS (moving scrolls).
--
-- A scroll in FLAG_HELD / FLAG_DROPPED is in transit: it is no longer sitting
-- in a keep, so RefreshScrolls (AT_ENEMY_BASE only) stops drawing it on a keep
-- row on the same tick it appears here. The two cannot both show one scroll.
--
-- Entry layout:  [scroll icon]  Altadoon - Aleswell @Player          1:27
--   icon   = the scroll's own map pin (same GetScrollTexture used on keeps)
--   name   = scroll name, then nearest location, then carrier @name
--   timer  = how long it has been in transit
--
-- On drop we keep the entry for SCROLL_CARRIER_GRACE (30s; Volendrung uses its
-- own shorter 10s grace) showing the last holder, then remove it. A re-pickup
-- clears the grace.
--------------------------------------------------
local SCROLL_CARRIER_GRACE = 30000

-- Scroll icon sizing multipliers. Both default to 1.0 = the original size.
--
-- SCROLL_KEEP_ICON_SCALE: the scroll drawn ON TOP of a keep/town row icon.
--   This one is centred over the keep icon, so raising it eats into the keep
--   art underneath. Above roughly 1.4 the keep becomes hard to identify.
--
-- SCROLL_CARRIER_ICON_SCALE: the scroll on a moving-carrier row. This REPLACES
--   the row icon rather than overlapping it, so it can go larger safely; it is
--   only bounded by the row height (entryHeight).
-- These read from PvPUA.config.iconScale -- see the ICON SIZES block near the
-- top of the file. Do not put numbers here; change them there.
local SCROLL_KEEP_ICON_SCALE        = PvPUA.config.iconScale.scrollOnKeep
local SCROLL_CARRIER_ICON_SCALE     = PvPUA.config.iconScale.scrollCarrier
local VOLENDRUNG_CARRIER_ICON_SCALE = PvPUA.config.iconScale.volendrung

PvPUA.scrollCarriers = {}

-- Event-sourced holder lookup, keyed by scroll (artifact) name.
-- On console GetCarryableObjectiveHoldingCharacterInfo often returns empty, so
-- the reliable source of the carrier's name is EVENT_ARTIFACT_CONTROL_STATE,
-- which delivers the holder's displayName directly. We cache it here and prefer
-- it over the poll. Mirrors CyrHUD's ArtifactHolders table.
PvPUA.artifactHolders = {}      -- artifactName(lower) -> "displayName" (no @) | "" | "?"
PvPUA.artifactHolderAlliance = {} -- artifactName(lower) -> alliance

-- Shared key normalizer for artifactHolders / artifactHolderAlliance.
-- MUST be used on BOTH the store side (OnArtifactControlState) and the read
-- side (RefreshScrollCarriers). Previously the store side used the full name
-- ("elder scroll of altadoon") while the read side used the shortened display
-- name ("altadoon"), so the cache never hit and the carrier name fell through
-- to the console-unreliable polls and fell back to the "Held" placeholder.
local function ScrollKey(name)
    if not name then return "" end
    name = zo_strformat("<<1>>", name)
    name = name:gsub("^Elder Scroll of ", ""):gsub("^Scroll of ", "")
    return string.lower(name)
end

function PvPUA:OnArtifactControlState(_, artifactName, keepId, characterName, playerAlliance, objectiveControlEvent, objectiveControlState, campaignId, displayName)
    if campaignId == 0 then return end
    local key = artifactName and ScrollKey(artifactName) or nil
    if not key or key == "" then return end
    if objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_TAKEN then
        -- Strip the leading "@" here as well. This path does NOT go through
        -- pickHolder, and on console it is the primary name source, so without
        -- this most rows would still show "@Name" while the poll-sourced ones
        -- showed "Name".
        local nm = displayName or characterName or ""
        if type(nm) == "string" then
            local stripped = (nm:gsub("^@", ""))
            if stripped ~= "" then nm = stripped end
        end
        self.artifactHolders[key] = nm
        self.artifactHolderAlliance[key] = playerAlliance or 0
    elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_DROPPED then
        -- keep the last name so the dropped entry still shows who had it
    elseif objectiveControlEvent == OBJECTIVE_CONTROL_EVENT_FLAG_SPAWNED then
        self.artifactHolders[key] = ""
        self.artifactHolderAlliance[key] = 0
    end
end

local function ShortenScrollName(name)
    if not name then return "" end
    name = zo_strformat("<<1>>", name)
    name = name:gsub("^Elder Scroll of ", ""):gsub("^Scroll of ", "")
    return name
end

-- Shortens POI names the way CyrHUD does: drops the descriptive prefix/suffix
-- so a POI reads as just its place name, matching the short keep names.
-- Scroll temples included per request ("Scroll Temple of Alma Ruma" -> "Alma
-- Ruma"). Keep names are NOT run through this -- they are already shortened by
-- AdjustKeepName/etc. when stored.
local function ShortenPOIName(name)
    if not name then return "" end
    name = zo_strformat("<<1>>", name)
    -- Trims location names to match this addon's own map-row style (the Adjust*
    -- functions), so a place reads the same whether it's a map row or a scroll
    -- carrier's location. Differs from plain CyrHUD in two intended ways:
    --   * trailing "Keep"/"Outpost" are stripped (AdjustKeepName/AdjustOutpostName
    --     do this), so "Chalman Keep" -> "Chalman", matching the map row.
    --   * only the word "Scroll" is removed from scroll temples, leaving
    --     "Temple of Ghartok" -- this parallels "Gate of Ghartok" so the gate and
    --     its temple read as a matched pair instead of collapsing to "Ghartok".
    name = name:gsub(",..$", "")
                :gsub("%^.d$", "")
                :gsub(" Wayshrine", "")
                :gsub("District", "")
                :gsub("Castle ", "")
                :gsub("[fF]ort ", "")
                :gsub("[Ll]umber ?[Mm]ill", "Lumber")
                :gsub("^Scroll Temple of ", "Temple of ")
                :gsub("Keep ", "")
                :gsub("Keep$", "")
                :gsub("Outpost", "")
    -- collapse any doubled/leading/trailing spaces left by the removals
    name = name:gsub("%s+", " "):gsub("^%s+", ""):gsub("%s+$", "")
    return name
end

-- Per-map location cache. Matches CyrHUD: every named keep (IDs 1..200, no type
-- filter -- keeps, towns, resources, outposts, artifact gates, scroll temples,
-- milegates, bridges) plus every zone POI (temples, wayshrines, delves, etc.).
-- Built once per map and reused, since these are static. This replaces the old
-- approach of hitting GetKeepPinInfo for a fixed list of keeps every tick.
PvPUA.locationCache = PvPUA.locationCache or {}

function PvPUA:BuildLocationCache()
    local mapId = GetCurrentMapId and GetCurrentMapId() or 0
    if self.locationCache[mapId] then return self.locationCache[mapId] end

    local list = {}

    -- Keep-type locations: matches CyrHUD exactly -- scan keep IDs 1..200 and
    -- take EVERY named one, with no keepType filter. This deliberately includes
    -- keeps, towns, resources, outposts, border keeps, the artifact gates
    -- ("Gate of Alma Ruma") and artifact keeps (the scroll temples), and also
    -- milegates and bridges. Anything with a real name and a non-zero pin is a
    -- candidate; nearest wins. Names are shortened the same way as POIs so a
    -- gate/temple reads cleanly, rather than reusing the per-table Adjust* names.
    for keepId = 1, 200 do
        local _, nx, ny = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
        local keepName = GetKeepName and GetKeepName(keepId) or nil
        if nx and ny and not (nx == 0 and ny == 0)
           and keepName and keepName ~= "" then
            list[#list + 1] = { x = nx, y = ny, name = ShortenPOIName(keepName) }
        end
    end

    -- If the keep scan found nothing, the campaign data isn't ready yet. Don't
    -- cache an empty list -- the early-return above would then serve it forever.
    -- Return a transient empty result; the next call rebuilds once data exists.
    if #list == 0 then return {} end

    -- POIs: scroll temples, wayshrines, delves, etc. for the current zone.
    if GetNumPOIs and GetPOIMapInfo and GetPOIInfo then
        local zoneIndex = GetCurrentMapZoneIndex and GetCurrentMapZoneIndex() or nil
        if zoneIndex then
            local count = GetNumPOIs(zoneIndex) or 0
            for poiIndex = 1, count do
                local nx, ny = GetPOIMapInfo(zoneIndex, poiIndex)
                local poiName = GetPOIInfo(zoneIndex, poiIndex)
                if nx and ny and not (nx == 0 and ny == 0)
                   and poiName and poiName ~= "" then
                    list[#list + 1] = { x = nx, y = ny, name = ShortenPOIName(poiName) }
                end
            end
        end
    end

    self.locationCache[mapId] = list
    return list
end

-- Nearest tracked location (keep-type OR POI) to a normalized map position.
function PvPUA:GetClosestLocationName(x, y)
    if not x or not y then return "" end
    if x == 0 and y == 0 then return "" end

    local list = self:BuildLocationCache()
    local bestName, bestDistSq = "", math.huge
    for i = 1, #list do
        local v = list[i]
        local dx = v.x - x
        local dy = v.y - y
        local dsq = dx * dx + dy * dy
        if dsq < bestDistSq then
            bestDistSq = dsq
            bestName = v.name
        end
    end
    return bestName
end

function PvPUA:RefreshScrollCarriers()
    local ok = pcall(function()
        local now = GetGameTimeMilliseconds()
        local seen = {}

        if GetNumObjectives then
            local keysFn = GetAvAObjectiveKeysByIndex or GetObjectiveIdsForIndex
            local n = GetNumObjectives() or 0
            for i = 1, n do
                local keepId, objectiveId, ctx = keysFn(i)
                if keepId and objectiveId then
                    local ctxUse = ctx or BGQUERY_LOCAL
                    local oName, oType, oState = GetObjectiveInfo(keepId, objectiveId, ctxUse)
                    if (oType == OBJECTIVE_ARTIFACT_OFFENSIVE or oType == OBJECTIVE_ARTIFACT_DEFENSIVE)
                    and (oState == OBJECTIVE_CONTROL_STATE_FLAG_HELD
                      or oState == OBJECTIVE_CONTROL_STATE_FLAG_DROPPED) then

                        local key = tostring(keepId) .. ":" .. tostring(objectiveId)
                        seen[key] = true

                        local c = self.scrollCarriers[key]
                        if not c then
                            c = { startedAt = now }
                            self.scrollCarriers[key] = c
                        end

                        local pinType, px, py = GetObjectivePinInfo(keepId, objectiveId, ctxUse)
                        c.texture = GetScrollTexture(pinType)
                        c.scrollName = ShortenScrollName(oName)

                        -- the scroll's own alliance tints the icon
                        c.scrollAlliance = SCROLL_PINTYPE_ALLIANCE[pinType] or 0

                        -- carrier: prefer the event-sourced name (reliable on
                        -- console), then the live poll, then the last-holder poll.
                        -- Resolve the carrier name. On console the live poll
                        -- often returns empty for a scroll that was ALREADY being
                        -- carried when the addon loaded (we never saw the pickup
                        -- event). So we try, in order: event cache -> live poll ->
                        -- last-holder poll, and for the polls we scan every return
                        -- value and take the first non-empty string, rather than
                        -- assuming which position the name sits in. If all fail we
                        -- show a placeholder so the entry is still usable; the real
                        -- name drops in on the next tick once any source resolves.
                        local nameKey = ScrollKey(oName)
                        local holderName, holderAlliance

                        if self.artifactHolders[nameKey] and self.artifactHolders[nameKey] ~= "" then
                            holderName = self.artifactHolders[nameKey]
                            holderAlliance = self.artifactHolderAlliance[nameKey]
                        end

                        -- Official API (esoui ESOUIDocumentation.txt): both
                        -- Holding/LastHolding return rawCharacterName, displayName,
                        -- classId. We want displayName (the @account name), with
                        -- rawCharacterName as a fallback if displayName is empty.
                        --
                        -- The leading "@" is stripped: the row already uses "@" as
                        -- the "at <location>" separator, so keeping it here would
                        -- put two different meanings of "@" in one line. It also
                        -- makes the two sources render alike, since displayName
                        -- carries an "@" and rawCharacterName does not.
                        local function pickHolder(raw, display)
                            if type(display) == "string" and display ~= "" then
                                local stripped = (display:gsub("^@", ""))
                                -- a name of just "@" would strip to empty, which
                                -- would silently drop the holder segment
                                if stripped ~= "" then return stripped end
                            end
                            if type(raw) == "string" and raw ~= "" then return raw end
                            return nil
                        end

                        if (holderName == nil or holderName == "") and GetCarryableObjectiveHoldingCharacterInfo then
                            local raw, disp = GetCarryableObjectiveHoldingCharacterInfo(keepId, objectiveId, ctxUse)
                            holderName = pickHolder(raw, disp)
                        end
                        if (holderName == nil or holderName == "") and GetCarryableObjectiveLastHoldingCharacterInfo then
                            local raw, disp = GetCarryableObjectiveLastHoldingCharacterInfo(keepId, objectiveId, ctxUse)
                            holderName = pickHolder(raw, disp)
                        end
                        if (holderAlliance == nil or holderAlliance == 0) and GetCarryableObjectiveHoldingAllianceInfo then
                            local hA, lastA = GetCarryableObjectiveHoldingAllianceInfo(keepId, objectiveId, ctxUse)
                            holderAlliance = (hA and hA ~= 0) and hA or lastA
                        end

                        -- Status word in the carrier slot.
                        --
                        -- Dropped: the scroll is on the ground, so "who is
                        --   carrying it" has no answer. This overrides any name
                        --   we resolved -- showing the last holder's name would
                        --   imply they still have it.
                        -- Held: someone IS carrying it, but the name has not
                        --   resolved yet. On console the live/last-holder polls
                        --   often return empty, and the event cache is only
                        --   populated once a FLAG_TAKEN event has been seen, so
                        --   there is a brief gap right after a pickup (and a
                        --   permanent one for a scroll already carried when the
                        --   addon loaded). "Held" is accurate in both cases.
                        if oState == OBJECTIVE_CONTROL_STATE_FLAG_DROPPED then
                            holderName = "Dropped"
                        elseif holderName == nil or holderName == "" then
                            holderName = "Held"
                        end
                        c.holder = holderName
                        c.holderAlliance = holderAlliance or 0
                        c.location = self:GetClosestLocationName(px, py)

                        if oState == OBJECTIVE_CONTROL_STATE_FLAG_DROPPED then
                            c.droppedAt = c.droppedAt or now
                        else
                            c.droppedAt = nil
                        end
                    end
                end
            end
        end

        -- expire: gone from the scan, or dropped longer than the grace period
        for key, c in pairs(self.scrollCarriers) do
            if not seen[key] then
                self.scrollCarriers[key] = nil
            elseif c.droppedAt and (now - c.droppedAt) > SCROLL_CARRIER_GRACE then
                self.scrollCarriers[key] = nil
            end
        end
    end)
    if not ok then self.scrollCarriers = {} end
end

-- Build pseudo-items so carriers flow through the normal entry pipeline.
function PvPUA:GetScrollCarrierItems()
    local out = {}
    local now = GetGameTimeMilliseconds()
    for key, c in pairs(self.scrollCarriers) do
        local scrollName = c.scrollName or ""
        local loc         = c.location or ""
        local who         = c.holder or ""
        local isDropped   = (c.droppedAt ~= nil)
        -- Row reads "<scroll> @ <location> [<holder>]", e.g.
        -- "Altadoon @ Chalman [SomePlayer]". The "@" means "at", so the holder
        -- name has its own "@" stripped in pickHolder to avoid two meanings.
        -- The holder is bracketed because every segment can contain spaces
        -- (scroll names like "Alma Ruma", keep names, and character-name
        -- fallbacks like "Lydia Stormblade"), so whitespace alone does not show
        -- where the location ends and the holder begins. Brackets are applied to
        -- "Held" and "Dropped" too, so the column stays visually consistent.
        --
        -- Color is per-segment via |cRRGGBB..|r markup baked into the string
        -- itself (same markup the game uses for chat/tooltips elsewhere in
        -- this file -- see ToHex/FireKeepUA). The scroll's own name is always
        -- tinted to ITS home alliance (scrollAlliance) and never changes --
        -- Ghartok reads red whether AD, DC or EP is currently carrying it.
        -- "@ location" is left unmarked so it renders in the row's default
        -- color (set to white in UpdateEntries for scroll carrier rows).
        -- "[holder]" is tinted to whoever currently HAS it (holderAlliance),
        -- except on a drop, where it forces white -- "who dropped it" is not
        -- the same claim as "who is carrying it", and this mirrors the
        -- isScrollDropped-forces-white behavior the backdrop already uses.
        local sc = GetColorForAlliance(c.scrollAlliance or 0)
        local label = "|c" .. ToHex(sc.r, sc.g, sc.b) .. scrollName .. "|r"
        local hasPrefix = (scrollName ~= "")
        if loc ~= "" then
            label = label .. " @ " .. loc
            hasPrefix = true
        end
        if who ~= "" then
            local hc = GetColorForAlliance(c.holderAlliance or 0)
            local holderHex = isDropped and "FFFFFF" or ToHex(hc.r, hc.g, hc.b)
            local bracket = "|c" .. holderHex .. "[" .. who .. "]|r"
            label = hasPrefix and (label .. " " .. bracket) or bracket
        end
        out[#out + 1] = {
            isScrollCarrier = true,
            isScrollDropped = isDropped,
            id              = 0,
            name            = label,
            carrierTexture  = c.texture,
            scrollAlliance  = c.scrollAlliance or 0,
            owningAlliance  = c.holderAlliance or 0,
            isUnderAttack   = false,
            underAttackFor  = now - (c.startedAt or now),
            interestingSince = c.startedAt,
            siegeWeapons    = {},
        }
    end
    return out
end

--------------------------------------------------
-- Volendrung CARRIER row (mirrors the scroll-carrier pipeline above).
--
-- Differs from scroll carriers in three deliberate ways:
--
--  1. LIFETIME. A scroll not in transit still appears on a keep row, so the
--     carrier list only covers FLAG_HELD/FLAG_DROPPED. Volendrung has no keep
--     row, so this row covers the hammer's WHOLE life -- spawned-but-unheld,
--     held, and dropped. self.volendrung already tracks exactly that span
--     (spawn event -> state events -> PollVolendrungDespawn's 10s grace), so
--     this function only fills in the per-tick display fields and never
--     creates or destroys the entry.
--
--  2. HOLDER NAME. EVENT_ARTIFACT_CONTROL_STATE fires for Volendrung as well
--     as for scrolls -- it is keyed by artifact name with no type filter -- so
--     self.artifactHolders already holds the name. It just has to be looked up
--     under the hammer's own name, which comes from
--     GetDaedricArtifactDisplayName(daedricArtifactId). The poll loop has no
--     daedricArtifactId of its own, so the key is cached as
--
--  3. COLOR. A scroll has a permanent home alliance that tints its icon
--     independently of who is carrying it. Volendrung has no home alliance --
--     the pin colour IS the wielder's alliance -- so icon and text share one
--     value, and that value is forced to 0 (white) whenever the hammer is
--     unheld or dropped, matching the base game's own map pin.
--------------------------------------------------
local VOLENDRUNG_NEUTRAL_TEXTURE = "/esoui/art/mappins/ava_daedricartifact_volendrung_neutral.dds"

-- ScrollKey()'d display name of the current hammer, cached from the daedric
-- artifact events so the per-tick poll can read self.artifactHolders.
PvPUA.volendrungName    = nil

function PvPUA:RefreshVolendrungCarrier()
    local ok = pcall(function()
        -- POLL for the daedric weapon objective every tick, rather than trusting
        -- the spawn/state events to have fired. Events alone missed three cases:
        --   * the hammer spawning while already in Cyrodiil but before anyone
        --     picked it up (no state change had happened yet, so nothing built
        --     the entry and the row only appeared on the first pickup),
        --   * a /reloadui or addon update mid-life, which wipes self.volendrung
        --     and replays no events,
        --   * any single dropped event.
        -- This is the same poll-is-source-of-truth pattern RefreshScrolls and
        -- RefreshScrollCarriers already use for scrolls. The events are kept:
        -- they still repaint immediately and cache the artifact's display name.
        local fKeep, fObj, fCtx, oName, oState, pinType, px, py

        if GetNumObjectives then
            local keysFn = GetAvAObjectiveKeysByIndex or GetObjectiveIdsForIndex
            local n = GetNumObjectives() or 0
            for i = 1, n do
                local keepId, objectiveId, ctx = keysFn(i)
                if keepId and objectiveId then
                    local ctxUse = ctx or BGQUERY_LOCAL
                    local nm, ty, st = GetObjectiveInfo(keepId, objectiveId, ctxUse)
                    if ty == OBJECTIVE_DAEDRIC_WEAPON
                    and st ~= nil and st ~= OBJECTIVE_CONTROL_STATE_UNKNOWN then
                        fKeep, fObj, fCtx = keepId, objectiveId, ctxUse
                        oName, oState = nm, st
                        pinType, px, py = GetObjectivePinInfo(keepId, objectiveId, ctxUse)
                        break
                    end
                end
            end
        end

        -- The poll can CREATE the entry, not just refresh one the events made.
        --
        -- ALSO create it during the spawn window. Daedric weapon objectives
        -- start in OBJECTIVE_CONTROL_STATE_UNKNOWN with no information at all,
        -- and stay that way until a fixed delay after spawning or until someone
        -- picks the hammer up -- which is exactly why the row used to appear
        -- only on the first pickup. GetActiveDaedricArtifactId still reports a
        -- live artifact during that window, so it is what tells us the hammer
        -- exists before the objective will admit to anything.
        local activeId = GetActiveDaedricArtifactId and GetActiveDaedricArtifactId() or 0

        if fKeep or (activeId and activeId ~= 0) then
            local v = self.volendrung
            if not v then
                v = { spawnedAt = GetGameTimeMilliseconds() }
                self.volendrung = v
            end
            if fKeep then
                v.keepId, v.objectiveId, v.ctx = fKeep, fObj, fCtx
                v.texture = GetVolendrungTexture(pinType)
                v.holderAlliance = GetVolendrungAlliance(pinType) or 0
            end
            v.despawnAt = nil
            if activeId and activeId ~= 0 and GetDaedricArtifactDisplayName then
                local nm = GetDaedricArtifactDisplayName(activeId)
                if nm and nm ~= "" then self.volendrungName = zo_strformat("<<1>>", nm) end
            end
        end

        local v = self.volendrung
        if not v then return end

        -- Everything below is display-only. When the poll found nothing but an
        -- entry still exists, that is the "spawned but not revealed" window --
        -- the game has no objective for it yet, so the row is a bare white
        -- name with no location, which is all anyone actually knows.
        local isDropped = (oState == OBJECTIVE_CONTROL_STATE_FLAG_DROPPED)
        local isHeld    = (oState == OBJECTIVE_CONTROL_STATE_FLAG_HELD)

        -- Alliance: prefer the live holding-alliance poll (reliable for the
        -- hammer), fall back to the pin type. Deliberately does NOT use the
        -- lastHolder fallback the scroll path uses -- a stale last-holder
        -- colour would wrongly imply someone still has it.
        local alliance
        if fKeep and GetCarryableObjectiveHoldingAllianceInfo then
            alliance = GetCarryableObjectiveHoldingAllianceInfo(fKeep, fObj, fCtx)
        end
        if not alliance or alliance == 0 then
            alliance = GetVolendrungAlliance(pinType) or 0
        end

        -- Holder name. The ONLY source is the close-range poll below.
        --
        -- This used to try an event cache first. That was wrong: daedric
        -- artifacts do not fire EVENT_ARTIFACT_CONTROL_STATE at all -- that
        -- event is scrolls-only -- so artifactHolders can never contain an
        -- entry for the hammer. The one cheap key check is kept in case ZOS
        -- ever starts firing it, but it is expected to miss.
        --
        -- The server only sends the wielder's identity to clients in range, so
        -- there is no remote source to fall back on. Nothing in the API fixes
        -- this; it is a data limitation, not a missing call.
        local holder
        local objKey = oName and oName ~= "" and ScrollKey(oName) or nil
        if objKey and self.artifactHolders[objKey]
           and self.artifactHolders[objKey] ~= "" and self.artifactHolders[objKey] ~= "?" then
            holder = self.artifactHolders[objKey]
        end

        if (holder == nil or holder == "") and fKeep then
            local function pick(raw, display)
                if type(display) == "string" and display ~= "" then
                    local stripped = (display:gsub("^@", ""))
                    if stripped ~= "" then return stripped end
                end
                if type(raw) == "string" and raw ~= "" then return raw end
                return nil
            end
            if GetCarryableObjectiveHoldingCharacterInfo then
                holder = pick(GetCarryableObjectiveHoldingCharacterInfo(fKeep, fObj, fCtx))
            end
            if (holder == nil or holder == "") and GetCarryableObjectiveLastHoldingCharacterInfo then
                holder = pick(GetCarryableObjectiveLastHoldingCharacterInfo(fKeep, fObj, fCtx))
            end
        end

        -- LAST KNOWN WIELDER.
        --
        -- Since the name is only readable in range, walking past the carrier is
        -- the only way to ever learn it -- and without this, the name would
        -- vanish again the moment you moved away. So a name resolved up close
        -- is remembered and kept on the row, marked with "?" to show it is
        -- remembered rather than live.
        --
        -- It is dropped as soon as it might be wrong: when the hammer is
        -- dropped, and when the holding alliance changes (that IS visible
        -- remotely, via the pin colour). A hand-off between two players of the
        -- SAME alliance while you are out of range cannot be detected, so the
        -- "?" is doing real work -- treat it as "who had it last time we
        -- looked", not "who has it".
        if holder and holder ~= "" then
            v.knownHolder         = holder
            v.knownHolderAlliance = alliance or 0
        elseif isHeld and v.knownHolder
           and v.knownHolderAlliance == (alliance or 0) and (alliance or 0) ~= 0 then
            holder = v.knownHolder .. "?"
        end
        if isDropped or (alliance or 0) == 0
           or (v.knownHolderAlliance and v.knownHolderAlliance ~= (alliance or 0)) then
            if not (holder and holder ~= "") then
                v.knownHolder, v.knownHolderAlliance = nil, nil
            end
        end

        -- Resolve the three display states.
        if isDropped then
            -- On the ground: nobody holds it, so the colour goes white and the
            -- name is replaced rather than showing the last wielder (which
            -- would read as though they still had it).
            v.holder      = "Dropped"
            v.rowAlliance = 0
        elseif isHeld then
            v.holder      = (holder and holder ~= "") and holder or "Held"
            v.rowAlliance = alliance or 0
        else
            -- Spawned / revealed but unclaimed: no holder segment at all, white.
            v.holder      = nil
            v.rowAlliance = 0
        end

        -- Texture. When tinting to the HUD palette we must start from the
        -- NEUTRAL (grey) art, because tinting an already-coloured pin would
        -- multiply two colours together and muddy it. When not tinting, pick
        -- the alliance-specific pin and force neutral whenever nobody holds it.
        if self.config.volendrungTintToHud then
            v.rowTexture = VOLENDRUNG_NEUTRAL_TEXTURE
        elseif v.rowAlliance == 0 then
            v.rowTexture = VOLENDRUNG_NEUTRAL_TEXTURE
        else
            v.rowTexture = GetVolendrungTexture(pinType) or VOLENDRUNG_NEUTRAL_TEXTURE
        end

        v.isDropped = isDropped
        v.location  = self:GetClosestLocationName(px, py)
        v.rowName   = (oName and oName ~= "" and zo_strformat("<<1>>", oName))
                      or self.volendrungName or "Volendrung"
    end)

    if not ok and self.volendrung then
        local v = self.volendrung
        v.holder, v.location, v.isDropped = nil, "", false
        v.rowAlliance = 0
        v.rowTexture  = VOLENDRUNG_NEUTRAL_TEXTURE
        v.rowName     = self.volendrungName or "Volendrung"
    end
end

-- Pseudo-item so the hammer flows through the same entry pipeline as scroll
-- carriers. isScrollCarrier is set on purpose: it selects the carrier row
-- layout (pin-as-row-icon, full-width name, no progress bars or siege counts).
-- isVolendrung only distinguishes it for sorting.
function PvPUA:GetVolendrungCarrierItem()
    local v = self.volendrung
    if not v then return nil end

    local rowName   = v.rowName or self.volendrungName or "Volendrung"
    local loc       = v.location or ""
    local who       = v.holder or ""
    local isDropped = (v.isDropped == true)

    -- Volendrung has no fixed "home alliance" the way a scroll does (it's
    -- neutral), so there's no separate identity color to hold onto. Instead
    -- the name and [holder] both track the CURRENT carrier and share one
    -- color: that alliance's color while held, white the instant it's
    -- unheld or dropped. "@ location" is always white, same as scrolls.
    local carrierAlliance = (not isDropped) and (v.rowAlliance or 0) or 0
    local cc  = GetColorForAlliance(carrierAlliance)
    local hex = ToHex(cc.r, cc.g, cc.b)

    local label = "|c" .. hex .. rowName .. "|r"
    local hasPrefix = (rowName ~= "")
    if loc ~= "" then
        label = label .. " @ " .. loc
        hasPrefix = true
    end
    if who ~= "" then
        local bracket = "|c" .. hex .. "[" .. who .. "]|r"
        label = hasPrefix and (label .. " " .. bracket) or bracket
    end

    local now = GetGameTimeMilliseconds()
    return {
        isScrollCarrier  = true,
        isVolendrung     = true,
        isScrollDropped  = isDropped,
        id               = 0,
        name             = label,
        carrierTexture   = v.rowTexture or VOLENDRUNG_NEUTRAL_TEXTURE,
        carrierIconScale = VOLENDRUNG_CARRIER_ICON_SCALE,
        carrierTint      = (self.config.volendrungTintToHud == true),
        scrollAlliance   = v.rowAlliance or 0,
        owningAlliance   = v.rowAlliance or 0,
        isUnderAttack    = false,
        underAttackFor   = now - (v.spawnedAt or now),
        interestingSince = v.spawnedAt,
        siegeWeapons     = {},
    }
end

--------------------------------------------------
-- Per-alliance scroll TALLY (separate from RefreshScrolls).
--
-- RefreshScrolls answers "which scroll is sitting in which keep" and only shows
-- captured ones (FLAG_AT_ENEMY_BASE). This answers a different question: "how
-- many scrolls does each alliance currently hold", counting BOTH scrolls safe in
-- their own temple (FLAG_AT_BASE) and ones captured into an enemy keep
-- (FLAG_AT_ENEMY_BASE). Totals should sum to 6.
--
-- Method follows CyrHUD: for every objective ask which keep has captured it,
-- then credit that keep's owning alliance. Unlike CyrHUD we rebuild the counts
-- from scratch each pass, so a stale objectiveId can't linger and inflate a count.
--------------------------------------------------
PvPUA.constants.textures.SCROLL_TALLY = {
    [ALLIANCE_ALDMERI_DOMINION]    = "/esoui/art/campaign/overview_scrollicon_aldmeri.dds",
    [ALLIANCE_EBONHEART_PACT]      = "/esoui/art/campaign/overview_scrollicon_ebonheart.dds",
    -- NOTE: "daggefall" is the real base-game filename (missing 'r'). Do not "fix" it.
    [ALLIANCE_DAGGERFALL_COVENANT] = "/esoui/art/campaign/overview_scrollicon_daggefall.dds",
}

PvPUA.scrollCounts = { [ALLIANCE_ALDMERI_DOMINION] = 0, [ALLIANCE_DAGGERFALL_COVENANT] = 0, [ALLIANCE_EBONHEART_PACT] = 0 }

function PvPUA:UpdateScrollCounts()
    local ok = pcall(function()
        local ad, dc, ep = 0, 0, 0
        if GetNumObjectives and GetKeepThatHasCapturedThisArtifactScrollObjective then
            local keysFn = GetAvAObjectiveKeysByIndex or GetObjectiveIdsForIndex
            local n = GetNumObjectives() or 0
            for i = 1, n do
                local keepId, objectiveId, ctx = keysFn(i)
                if keepId and objectiveId then
                    local ctxUse = ctx or BGQUERY_LOCAL
                    local holdingKeep = GetKeepThatHasCapturedThisArtifactScrollObjective(keepId, objectiveId, ctxUse)
                    if holdingKeep and holdingKeep ~= 0 then
                        local state = GetObjectiveControlState and GetObjectiveControlState(keepId, objectiveId, ctxUse)
                        if state == nil
                        or state == OBJECTIVE_CONTROL_STATE_FLAG_AT_BASE
                        or state == OBJECTIVE_CONTROL_STATE_FLAG_AT_ENEMY_BASE then
                            local alliance = GetKeepAlliance(holdingKeep, ctxUse)
                            if alliance == ALLIANCE_ALDMERI_DOMINION then ad = ad + 1
                            elseif alliance == ALLIANCE_DAGGERFALL_COVENANT then dc = dc + 1
                            elseif alliance == ALLIANCE_EBONHEART_PACT then ep = ep + 1 end
                        end
                    end
                end
            end
        end
        self.scrollCounts[ALLIANCE_ALDMERI_DOMINION]    = ad
        self.scrollCounts[ALLIANCE_DAGGERFALL_COVENANT] = dc
        self.scrollCounts[ALLIANCE_EBONHEART_PACT]      = ep
    end)
    if not ok then
        self.scrollCounts[ALLIANCE_ALDMERI_DOMINION]    = 0
        self.scrollCounts[ALLIANCE_DAGGERFALL_COVENANT] = 0
        self.scrollCounts[ALLIANCE_EBONHEART_PACT]      = 0
    end
end

--------------------------------------------------
-- Refresh the three score-row scroll overlays from scrollCounts.
-- Layering mirrors the keep rows: emblem at layer 1, scroll icon over it at
-- layer 3, count on top at layer 4. Hidden entirely when an alliance holds none.
--------------------------------------------------
function PvPUA:RefreshScrollTally()
    local map = {
        { icon = self.controls.scoreDCScroll, txt = self.controls.scoreDCScrollTxt, alliance = ALLIANCE_DAGGERFALL_COVENANT },
        { icon = self.controls.scoreADScroll, txt = self.controls.scoreADScrollTxt, alliance = ALLIANCE_ALDMERI_DOMINION },
        { icon = self.controls.scoreEPScroll, txt = self.controls.scoreEPScrollTxt, alliance = ALLIANCE_EBONHEART_PACT },
    }
    for i = 1, #map do
        local e = map[i]
        if e.icon and e.txt then
            local count = self.scrollCounts[e.alliance] or 0
            -- Always visible, including 0 (matches CyrHUD).
            e.icon:SetHidden(false)
            e.txt:SetHidden(false)
            e.txt:SetText(tostring(count))
        end
    end
end

--------------------------------------------------
-- AddObjectives
--------------------------------------------------
function PvPUA:AddObjectives()
    local numObjectives = GetNumObjectives()
    for i = 1, numObjectives do
        local keepId, objectiveId, bgqueryType = GetObjectiveIdsForIndex(i)
        if bgqueryType == BGQUERY_ASSIGNED_AND_LOCAL or bgqueryType == BGQUERY_LOCAL then
            if self.state.keeps[keepId] ~= nil then
                self.state.keeps[keepId].objectives = self.state.keeps[keepId].objectives or {}
                if self.state.keeps[keepId].objectives[1] == nil then
                    self.state.keeps[keepId].objectives[1] = {}
                    self.state.keeps[keepId].objectives[1].id = objectiveId
                    self.state.keeps[keepId].objectives[1].state = 100
                    self.state.keeps[keepId].objectives[1].holdingAlliance = self.state.keeps[keepId].owningAlliance
                elseif self.state.keeps[keepId].objectives[2] == nil then
                    self.state.keeps[keepId].objectives[2] = {}
                    self.state.keeps[keepId].objectives[2].id = objectiveId
                    self.state.keeps[keepId].objectives[2].state = 100
                    self.state.keeps[keepId].objectives[2].holdingAlliance = self.state.keeps[keepId].owningAlliance
                end
            elseif self.state.resources[keepId] ~= nil then
                self.state.resources[keepId].objectives = self.state.resources[keepId].objectives or {}
                self.state.resources[keepId].objectives[1] = {}
                self.state.resources[keepId].objectives[1].id = objectiveId
                self.state.resources[keepId].objectives[1].state = 100
                self.state.resources[keepId].objectives[1].holdingAlliance = self.state.resources[keepId].owningAlliance
            elseif self.state.outposts[keepId] ~= nil then
                self.state.outposts[keepId].objectives = self.state.outposts[keepId].objectives or {}
                if self.state.outposts[keepId].objectives[1] == nil then
                    self.state.outposts[keepId].objectives[1] = {}
                    self.state.outposts[keepId].objectives[1].id = objectiveId
                    self.state.outposts[keepId].objectives[1].state = 100
                    self.state.outposts[keepId].objectives[1].holdingAlliance = self.state.outposts[keepId].owningAlliance
                else
                    self.state.outposts[keepId].objectives[2] = {}
                    self.state.outposts[keepId].objectives[2].id = objectiveId
                    self.state.outposts[keepId].objectives[2].state = 100
                    self.state.outposts[keepId].objectives[2].holdingAlliance = self.state.outposts[keepId].owningAlliance
                end
            elseif self.state.villages[keepId] ~= nil then
                self.state.villages[keepId].objectives = self.state.villages[keepId].objectives or {}
                if self.state.villages[keepId].objectives[1] == nil then
                    self.state.villages[keepId].objectives[1] = {}
                    self.state.villages[keepId].objectives[1].id = objectiveId
                    self.state.villages[keepId].objectives[1].state = 100
                    self.state.villages[keepId].objectives[1].holdingAlliance = self.state.villages[keepId].owningAlliance
                elseif self.state.villages[keepId].objectives[2] == nil then
                    self.state.villages[keepId].objectives[2] = {}
                    self.state.villages[keepId].objectives[2].id = objectiveId
                    self.state.villages[keepId].objectives[2].state = 100
                    self.state.villages[keepId].objectives[2].holdingAlliance = self.state.villages[keepId].owningAlliance
                else
                    self.state.villages[keepId].objectives[3] = {}
                    self.state.villages[keepId].objectives[3].id = objectiveId
                    self.state.villages[keepId].objectives[3].state = 100
                    self.state.villages[keepId].objectives[3].holdingAlliance = self.state.villages[keepId].owningAlliance
                end
            end
        end
    end
end

--------------------------------------------------
-- ResetObjectives
--------------------------------------------------
function PvPUA:ResetObjective(keeps)
    for key, keep in pairs(keeps) do
        if keep.objectives ~= nil then
            for i = 1, #keep.objectives do
                keep.objectives[i].state = 100
                keep.objectives[i].holdingAlliance = keep.owningAlliance
            end
        end
    end
end

function PvPUA:ResetObjectives()
    self:ResetObjective(self.state.keeps)
    self:ResetObjective(self.state.outposts)
    self:ResetObjective(self.state.resources)
    self:ResetObjective(self.state.villages)
end

--------------------------------------------------
-- GetItemByKeepId
--------------------------------------------------
function PvPUA:GetItemByKeepId(keepId)
    if keepId ~= nil then
        if self.state.resources[keepId] ~= nil then return self.state.resources[keepId]
        elseif self.state.keeps[keepId] ~= nil then return self.state.keeps[keepId]
        elseif self.state.outposts[keepId] ~= nil then return self.state.outposts[keepId]
        elseif self.state.villages[keepId] ~= nil then return self.state.villages[keepId]
        end
    end
    return nil
end

--------------------------------------------------
-- Flag State / Flip Logic
--------------------------------------------------
local function GetFlagStatePercent(state, owningAlliance, holdingAlliance)
    local percent = 99
    if state == OBJECTIVE_CONTROL_STATE_AREA_ABOVE_CONTROL_THRESHOLD then
        if holdingAlliance == owningAlliance then percent = 90 else percent = 51 end
    elseif state == OBJECTIVE_CONTROL_STATE_AREA_NO_CONTROL then
        if holdingAlliance == 0 then percent = 0 else percent = 10 end
    elseif state == OBJECTIVE_CONTROL_STATE_AREA_MAX_CONTROL then
        percent = 100
    elseif state == OBJECTIVE_CONTROL_STATE_AREA_BELOW_CONTROL_THRESHOLD then
        if holdingAlliance == owningAlliance then percent = 40 else percent = 10 end
    end
    return percent
end

local function GetFlipConstant(keepType)
    if keepType == KEEPTYPE_KEEP then return PvPUA.constants.flipTimes.KEEP
    elseif keepType == KEEPTYPE_OUTPOST then return PvPUA.constants.flipTimes.OUTPOST
    elseif keepType == KEEPTYPE_RESOURCE then return PvPUA.constants.flipTimes.RESOURCE
    else return 0 end
end

local function FlagsAtFlipState(objectives, owningAlliance)
    local flips = false
    if objectives ~= nil then
        local flipedFlags = 0
        for i = 1, #objectives do
            if objectives[i].holdingAlliance ~= owningAlliance and objectives[i].state > 50 then
                flipedFlags = flipedFlags + 1
            else
                break
            end
        end
        if flipedFlags == #objectives then
            if #objectives == 1 then
                flips = true
            elseif #objectives == 2 and objectives[1].holdingAlliance == objectives[2].holdingAlliance then
                flips = true
            elseif #objectives == 3 and objectives[1].holdingAlliance == objectives[2].holdingAlliance and objectives[1].holdingAlliance == objectives[3].holdingAlliance then
                flips = true
            end
        end
    end
    return flips
end

local function AdjustKeepFlipping(keep)
    local flipTime = GetFlipConstant(keep.keepType)
    if flipTime > 0 then
        if keep.flipsAt == nil and FlagsAtFlipState(keep.objectives, keep.owningAlliance) == true then
            keep.flipsAt = GetGameTimeMilliseconds() + flipTime
        elseif keep.flipsAt ~= nil and FlagsAtFlipState(keep.objectives, keep.owningAlliance) == true then
        else
            keep.flipsAt = nil
        end
    end
end

--------------------------------------------------
-- UpdateItem
--------------------------------------------------
local notifCooldowns = {}

local function FireKeepUA(keepId, name, owningAlliance)
    if not PvPUA.savedVariables or not PvPUA.savedVariables.alertsEnabled then return end
    if not CENTER_SCREEN_ANNOUNCE then return end

    -- Cooldown: don't repeat same keep within 30 seconds
    local now = GetGameTimeMilliseconds()
    if notifCooldowns[keepId] and now - notifCooldowns[keepId] < 30000 then return end
    notifCooldowns[keepId] = now

    local ac = GetColorForAlliance(owningAlliance)
    local nameHex = ToHex(ac.r, ac.g, ac.b)
    local msg = string.format("|c%s%s|r |cFF8C00UA!|r", nameHex, name)

    local params = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT, SOUNDS.NONE)
    params:SetText(msg)
    params:SetLifespanMS((PvPUA.savedVariables.alertLifespan or 10) * 1000)
    CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(params)
end

function PvPUA:UpdateItem(items, gameTime)
    local itemsOfInterest = {}
    for key, item in pairs(items) do
        local itemOfInterest = false
        local previousOwningAlliance = item.owningAlliance
        item.owningAlliance = GetKeepAlliance(key, BGQUERY_LOCAL)
        local previousAttackState = item.isUnderAttack
        item.isUnderAttack = GetKeepUnderAttack(key, BGQUERY_LOCAL)
        item.underAttackFor = 0

        if item.owningAlliance ~= previousOwningAlliance and self.state.destructibles[key] == nil then
            itemOfInterest = true
            if item.interestingSince == nil then item.interestingSince = gameTime end
            item.underAttackFor = gameTime - item.interestingSince
            if item.objectives ~= nil then
                for i = 1, #item.objectives do
                    item.objectives[i].state = 100
                    item.objectives[i].holdingAlliance = item.owningAlliance
                end
            end
            item.flipsAt = nil
        end
        if previousAttackState == false and item.isUnderAttack == true then
            if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + PvPUA.constants.siegeTimeout < gameTime then
                item.interestingSince = gameTime
            end
            -- Notify when a keep that natively belongs to your alliance goes UA
            -- regardless of who currently owns it
            local playerAlliance = GetUnitAlliance("player")
            if item.name ~= nil and self.state.keeps[key] ~= nil
               and PvPUA.homeKeepIds[key] == playerAlliance then
                FireKeepUA(key, item.name, item.owningAlliance)
            end
        elseif previousAttackState == true and item.isUnderAttack == false then
            item.attackStatusLostAt = gameTime
        end
        if item.isUnderAttack == true then
            itemOfInterest = true
            if item.interestingSince == nil then item.interestingSince = gameTime end
            item.underAttackFor = gameTime - item.interestingSince
        else
            if item.attackStatusLostAt ~= 0 and item.attackStatusLostAt + PvPUA.constants.siegeTimeout > gameTime then
                itemOfInterest = true
                if item.interestingSince == nil then item.interestingSince = gameTime end
                item.underAttackFor = gameTime - item.interestingSince
            end
        end
        if self.state.destructibles[key] == nil then
            item.siegeWeapons.AD = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_ALDMERI_DOMINION)
            item.siegeWeapons.DC = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_DAGGERFALL_COVENANT)
            item.siegeWeapons.EP = GetNumSieges(key, BGQUERY_LOCAL, ALLIANCE_EBONHEART_PACT)
            if item.siegeWeapons.AD > 0 or item.siegeWeapons.DC > 0 or item.siegeWeapons.EP > 0 then
                itemOfInterest = true
                if item.interestingSince == nil then item.interestingSince = gameTime end
                item.underAttackFor = gameTime - item.interestingSince
                item.lastSiegeWeaponSeen = gameTime
            elseif item.lastSiegeWeaponSeen ~= nil and item.lastSiegeWeaponSeen + PvPUA.constants.siegeTimeout > gameTime then
                itemOfInterest = true
                if item.interestingSince == nil then item.interestingSince = gameTime end
                item.underAttackFor = gameTime - item.interestingSince
            else
                item.lastSiegeWeaponSeen = nil
            end
        end
        if item.keepType == KEEPTYPE_BRIDGE or item.keepType == KEEPTYPE_MILEGATE then
            item.isPassable = IsKeepPassable(key, BGQUERY_LOCAL)
            item.directionalAccess = GetKeepDirectionalAccess(key, BGQUERY)
        end
        if itemOfInterest == true then
            -- Show in List filters: hide toggled-off types (keeps/outposts always show).
            local sv = PvPUA.savedVariables
            local hidden = false
            if sv then
                if item.keepType == KEEPTYPE_MILEGATE and sv.showMilegates == false then hidden = true
                elseif item.keepType == KEEPTYPE_BRIDGE and sv.showBridges == false then hidden = true
                elseif item.keepType == KEEPTYPE_TOWN and sv.showTowns == false then hidden = true
                elseif item.keepType == KEEPTYPE_RESOURCE and sv.showResources == false then hidden = true
                end
            end
            if hidden then
                item.interestingSince = nil
            else
                table.insert(itemsOfInterest, item)
            end
        else
            item.interestingSince = nil
        end
    end
    return itemsOfInterest
end

--------------------------------------------------
-- Sort
--------------------------------------------------
local function SortItemsOfInterest(itemA, itemB)
    if itemA == nil or itemB == nil then return true end
    -- Moving scrolls are the most time-critical thing on the list: always first.
    if itemA.isScrollCarrier and not itemB.isScrollCarrier then return true end
    if itemB.isScrollCarrier and not itemA.isScrollCarrier then return false end
    if itemA.isScrollCarrier and itemB.isScrollCarrier then
        -- Within the carrier block Volendrung sits above the scrolls: there is
        -- only ever one hammer, and it is the higher-priority target.
        if itemA.isVolendrung and not itemB.isVolendrung then return true end
        if itemB.isVolendrung and not itemA.isVolendrung then return false end
        return (itemA.interestingSince or 0) < (itemB.interestingSince or 0)
    end
    local playerAlliance = GetUnitAlliance("player")
    local aFriendly = GetKeepAlliance(itemA.id, BGQUERY_LOCAL) == playerAlliance
    local bFriendly = GetKeepAlliance(itemB.id, BGQUERY_LOCAL) == playerAlliance
    if aFriendly and not bFriendly then return true end
    if not aFriendly and bFriendly then return false end
    if not aFriendly and not bFriendly then
        local aSiege = itemA.siegeWeapons and (
            (playerAlliance == ALLIANCE_ALDMERI_DOMINION    and (itemA.siegeWeapons.AD or 0) > 0) or
            (playerAlliance == ALLIANCE_DAGGERFALL_COVENANT and (itemA.siegeWeapons.DC or 0) > 0) or
            (playerAlliance == ALLIANCE_EBONHEART_PACT      and (itemA.siegeWeapons.EP or 0) > 0)
        )
        local bSiege = itemB.siegeWeapons and (
            (playerAlliance == ALLIANCE_ALDMERI_DOMINION    and (itemB.siegeWeapons.AD or 0) > 0) or
            (playerAlliance == ALLIANCE_DAGGERFALL_COVENANT and (itemB.siegeWeapons.DC or 0) > 0) or
            (playerAlliance == ALLIANCE_EBONHEART_PACT      and (itemB.siegeWeapons.EP or 0) > 0)
        )
        if aSiege and not bSiege then return true end
        if not aSiege and bSiege then return false end
    end
    if itemA.interestingSince == nil or itemB.interestingSince == nil then return true end
    return itemA.interestingSince < itemB.interestingSince
end

--------------------------------------------------
-- Texture Helper
--------------------------------------------------
local function GetTextureAndOffsetForItem(keepType, rType, isPassable)
    if keepType == KEEPTYPE_KEEP then
        return PvPUA.constants.textures.KEEP, 3
    elseif keepType == KEEPTYPE_OUTPOST then
        return PvPUA.constants.textures.OUTPOST, 3
    elseif keepType == KEEPTYPE_RESOURCE then
        if rType == PvPUA.constants.resourceType.FARM then return PvPUA.constants.textures.RESOURCE_FARM, -1
        elseif rType == PvPUA.constants.resourceType.MINE then return PvPUA.constants.textures.RESOURCE_MINE, -1
        elseif rType == PvPUA.constants.resourceType.LUMBER then return PvPUA.constants.textures.RESOURCE_LUMBER, -1
        end
    elseif keepType == KEEPTYPE_TOWN then
        return PvPUA.constants.textures.VILLAGE, 2
    elseif keepType == KEEPTYPE_BRIDGE then
        if isPassable == true then return PvPUA.constants.textures.BRIDGE_PASSABLE, -2
        else return PvPUA.constants.textures.BRIDGE_NOT_PASSABLE, -2 end
    elseif keepType == KEEPTYPE_MILEGATE then
        if isPassable == true then return PvPUA.constants.textures.MILEGATE_PASSABLE, -2
        else return PvPUA.constants.textures.MILEGATE_NOT_PASSABLE, -2 end
    end
    return "", 0
end

--------------------------------------------------
-- Format Time
--------------------------------------------------
local function FormatUnderAttackTime(underAttackFor)
    if underAttackFor ~= nil or underAttackFor == 0 then
        local minutes = string.format("%d", underAttackFor / 60)
        local seconds = underAttackFor - minutes * 60
        if seconds > 0 and seconds < 10 then
            return string.format("%d:0%d", minutes, seconds)
        elseif seconds == 0 then
            return string.format("%d:00", minutes)
        else
            return string.format("%d:%d", minutes, seconds)
        end
    else
        return ""
    end
end

local function SetSiegeWeapons(control, weapons)
    if weapons ~= nil and weapons > 0 then
        control:SetText(weapons)
    else
        control:SetText("")
    end
end

--------------------------------------------------
-- Create Progress Bar
--------------------------------------------------
local function CreateProgressBar(parent)
    local control = wm:CreateControl(nil, parent, CT_CONTROL)
    control:SetDimensions(PvPUA.config.flagWidth, PvPUA.config.flagHeight)
    control:SetHidden(true)

    control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
    control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    control.backdrop:SetDimensions(PvPUA.config.flagWidth, PvPUA.config.flagHeight)
    -- Black border so the bar reads against busy terrain, same idea as the
    -- "outline" font style. Does not change the fill, its color or its width.
    control.backdrop:SetEdgeColor(0, 0, 0, 1)
    control.backdrop:SetCenterColor(PvPUA.config.flagBackdropColor.r, PvPUA.config.flagBackdropColor.g, PvPUA.config.flagBackdropColor.b, 1)

    control.progress = wm:CreateControl(nil, control, CT_STATUSBAR)
    control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, 1, 1)
    control.progress:SetDimensions(PvPUA.config.flagWidth - 2, PvPUA.config.flagHeight - 2)
    control.progress:SetMinMax(0, 100)
    control.progress:SetValue(0)
    return control
end

--------------------------------------------------
-- Create Entry Control
--------------------------------------------------
local function CreateEntryControl(parent)
    local controlFont = PvPUA:GetFont()

    local control = wm:CreateControl(nil, parent, CT_CONTROL)
    control:SetDimensions(PvPUA.config.width, PvPUA.config.entryHeight)
    control:SetHidden(true)

    control.backdrop = wm:CreateControl(nil, control, CT_BACKDROP)
    control.backdrop:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
    control.backdrop:SetDimensions(PvPUA.config.width, PvPUA.config.entryHeight)
    control.backdrop:SetDrawLayer(0)

    -- Black outline copy behind the under-attack burst. Same texture drawn 2px
    -- larger on a lower layer so it peeks out around the edges, giving the icon
    -- the same kind of dark edge that the "outline" font style gives text.
    -- NOTE: uaImage and uaOutline must be resized together -- the outline is the
    -- burst inflated by 2px per side, and that 2px IS the visible halo.
    control.uaOutline = wm:CreateControl(nil, control, CT_TEXTURE)
    control.uaOutline:SetAnchor(TOPLEFT, control, TOPLEFT, -5 - 2, -5 - 2)
    control.uaOutline:SetDimensions(PvPUA.config.imageWidth + 10 + 4, PvPUA.config.entryHeight + 10 + 4)
    control.uaOutline:SetTexture("/esoui/art/mappins/ava_attackburst_64.dds")
    control.uaOutline:SetColor(0, 0, 0, 1)
    control.uaOutline:SetHidden(true)
    control.uaOutline:SetDrawLayer(0)

    control.uaImage = wm:CreateControl(nil, control, CT_TEXTURE)
    control.uaImage:SetAnchor(TOPLEFT, control, TOPLEFT, -5, -5)
    control.uaImage:SetDimensions(PvPUA.config.imageWidth + 10, PvPUA.config.entryHeight + 10)
    control.uaImage:SetTexture("/esoui/art/mappins/ava_attackburst_64.dds")
    control.uaImage:SetHidden(true)
    control.uaImage:SetDrawLayer(1)

    -- Black outline copy behind the row icon (keeps, outposts, resources,
    -- villages, bridges, milegates). Texture/size/visibility are mirrored from
    -- control.image each tick in UpdateEntries.
    control.imageOutline = wm:CreateControl(nil, control, CT_TEXTURE)
    control.imageOutline:SetAnchor(TOPLEFT, control, TOPLEFT, -2 - 2, -2 - 2)
    control.imageOutline:SetDimensions(PvPUA.config.imageWidth + 4 + 4, PvPUA.config.entryHeight + 4 + 4)
    control.imageOutline:SetColor(0, 0, 0, 1)
    control.imageOutline:SetDrawLayer(1)

    control.image = wm:CreateControl(nil, control, CT_TEXTURE)
    control.image:SetAnchor(TOPLEFT, control, TOPLEFT, -2, -2)
    control.image:SetDimensions(PvPUA.config.imageWidth + 4, PvPUA.config.entryHeight + 4)
    control.image:SetDrawLayer(2)

    -- Scroll icon: drawn above the keep icon (layer 3), centered, slightly smaller.
    -- Anchor/size are set per-frame in UpdateEntries. Hidden unless the keep holds a scroll.
    control.scrollImage = wm:CreateControl(nil, control, CT_TEXTURE)
    control.scrollImage:SetDrawLayer(3)
    control.scrollImage:SetHidden(true)

    control.name = wm:CreateControl(nil, control, CT_LABEL)
    control.name:SetAnchor(TOPLEFT, control, TOPLEFT, PvPUA.config.imageWidth + 4, 0)
    control.name:SetDimensions(PvPUA.config.nameWidth, PvPUA.config.entryHeight)
    control.name:SetFont(controlFont)
    control.name:SetWrapMode(ELLIPSIS)
    control.name:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.name:SetHorizontalAlignment(TEXT_ALIGN_LEFT)

    control.progress = wm:CreateControl(nil, control, CT_CONTROL)
    control.progress:SetAnchor(TOPLEFT, control, TOPLEFT, PvPUA.config.imageWidth + 4 + PvPUA.config.nameWidth, 0)
    control.progress:SetDimensions(PvPUA.config.flagWidth, PvPUA.config.entryHeight)
    control.progress.bar1 = CreateProgressBar(control.progress)
    control.progress.bar2 = CreateProgressBar(control.progress)
    control.progress.bar3 = CreateProgressBar(control.progress)

    local siegeOffset = PvPUA.config.imageWidth + 4 + PvPUA.config.nameWidth + PvPUA.config.flagWidth
    control.dcSiege = wm:CreateControl(nil, control, CT_LABEL)
    control.dcSiege:SetAnchor(TOPLEFT, control, TOPLEFT, siegeOffset, 0)
    control.dcSiege:SetDimensions(PvPUA.config.siegeWidth, PvPUA.config.entryHeight)
    control.dcSiege:SetFont(controlFont)
    control.dcSiege:SetWrapMode(ELLIPSIS)
    control.dcSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.dcSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    control.adSiege = wm:CreateControl(nil, control, CT_LABEL)
    control.adSiege:SetAnchor(TOPLEFT, control, TOPLEFT, siegeOffset + PvPUA.config.siegeWidth, 0)
    control.adSiege:SetDimensions(PvPUA.config.siegeWidth, PvPUA.config.entryHeight)
    control.adSiege:SetFont(controlFont)
    control.adSiege:SetWrapMode(ELLIPSIS)
    control.adSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.adSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    control.epSiege = wm:CreateControl(nil, control, CT_LABEL)
    control.epSiege:SetAnchor(TOPLEFT, control, TOPLEFT, siegeOffset + PvPUA.config.siegeWidth * 2, 0)
    control.epSiege:SetDimensions(PvPUA.config.siegeWidth, PvPUA.config.entryHeight)
    control.epSiege:SetFont(controlFont)
    control.epSiege:SetWrapMode(ELLIPSIS)
    control.epSiege:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.epSiege:SetHorizontalAlignment(TEXT_ALIGN_CENTER)

    control.flipStatus = wm:CreateControl(nil, control, CT_LABEL)
    control.flipStatus:SetAnchor(TOPLEFT, control, TOPLEFT, siegeOffset + PvPUA.config.siegeWidth * 3 + 10, 0)
    control.flipStatus:SetDimensions(PvPUA.config.flagFlipWidth, PvPUA.config.entryHeight)
    control.flipStatus:SetFont(controlFont)
    control.flipStatus:SetWrapMode(ELLIPSIS)
    control.flipStatus:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.flipStatus:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    control.underAttackFor = wm:CreateControl(nil, control, CT_LABEL)
    control.underAttackFor:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)
    control.underAttackFor:SetDimensions(PvPUA.config.underAttackForWidth, PvPUA.config.entryHeight)
    control.underAttackFor:SetFont(controlFont)
    control.underAttackFor:SetWrapMode(ELLIPSIS)
    control.underAttackFor:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    control.underAttackFor:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    return control
end

function PvPUA:ApplyPosition()
    self.controls.TLW:ClearAnchors()
    self.controls.TLW:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT,
        self.savedVariables.posX or 1600,
        self.savedVariables.posY or 200)
end

--------------------------------------------------
-- Apply Scale
--
-- Scales the whole list as a unit via SetScale on the TLW. This does NOT touch
-- self.config or any anchors, so existing controls cannot desync from new layout
-- math -- children (including entries created later) inherit the scale
-- automatically at render time. Safe to call live while the list is updating.
--------------------------------------------------
function PvPUA:ApplyScale()
    if not self.controls.TLW then return end
    local scale = self.savedVariables and self.savedVariables.uiScale or 1.0
    self.controls.TLW:SetScale(scale)
end

--------------------------------------------------
-- Apply Size
--------------------------------------------------
function PvPUA:ApplyListSize()
    -- Single fixed layout. Sizing is handled live by the Size slider
    -- (savedVariables.uiScale) via ApplyScale/SetScale.
    self.config.entryHeight         = 34
    self.config.nameWidth           = 180
    self.config.width               = 510
    self.config.siegeWidth          = 38
    self.config.underAttackForWidth = 65
    self.config.flagFlipWidth       = 60
    self:InvalidateFontCache()
end

--------------------------------------------------
-- Create UI
--------------------------------------------------
function PvPUA:CreateUI()
    self.controls.TLW = wm:CreateTopLevelWindow("PvPUA_TLW")
    self.controls.TLW:SetClampedToScreen(self.config.isClampedToScreen)
    self.controls.TLW:SetDimensions(self.config.width, self.config.height + self.config.entryHeight * 2 + 20)
    self.controls.TLW:SetDrawLayer(DL_BACKGROUND)
    self.controls.TLW:SetDrawTier(DT_LOW)
    self.controls.TLW:SetHidden(true)

    self:ApplyPosition()
    self:ApplyScale()

    self.controls.TLW.rootControl = wm:CreateControl(nil, self.controls.TLW, CT_CONTROL)
    local rootControl = self.controls.TLW.rootControl
    rootControl:SetDimensions(self.config.width, self.config.height)
    rootControl:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT, 0, 20 + self.config.entryHeight * 2)

    self.state.visibleControls = {}
    for i = 1, 15 do
        local entry = CreateEntryControl(rootControl)
        entry:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, self.config.entryHeight * (i - 1))
        entry:SetHidden(true)
        table.insert(self.state.visibleControls, entry)
    end
    zo_callLater(function()
        for i = 16, 30 do
            local entry = CreateEntryControl(rootControl)
            entry:SetAnchor(TOPLEFT, rootControl, TOPLEFT, 0, self.config.entryHeight * (i - 1))
            entry:SetHidden(true)
            table.insert(self.state.visibleControls, entry)
        end
    end, 100)

    self.controls.creditLabel = wm:CreateControl(nil, self.controls.TLW, CT_LABEL)
    self.controls.creditLabel:SetFont("EsoUI/Common/Fonts/univers67.otf|15|outline")
    self.controls.creditLabel:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT, 0, 0)
    self.controls.creditLabel:SetDimensions(self.config.width, 20)
    self.controls.creditLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.controls.creditLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.creditLabel:SetText(CREDIT_STATES[0])
    self.controls.creditLabel:SetDrawLayer(2)
    self.controls.creditLabel:SetHidden(true)

    self.controls.infoBg = wm:CreateControl(nil, self.controls.TLW, CT_BACKDROP)
    self.controls.infoBg:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT, 0, 20)
    self.controls.infoBg:SetDimensions(self.config.width, self.config.entryHeight)
    self.controls.infoBg:SetCenterColor(0, 0, 0, 0.5)
    self.controls.infoBg:SetEdgeColor(0, 0, 0, 0)
    self.controls.infoBg:SetDrawLayer(0)
    self.controls.infoBg:SetHidden(true)

    local infoH      = self.config.entryHeight
    -- Base slot size (what scale 1.0 means for this icon). Layout is computed
    -- from the BASE, not the scaled size, so turning the icon up or down is
    -- purely visual -- it grows centred on its slot and never shoves the
    -- progress bar around. Same behaviour as the carrier row icons.
    local rankBase   = math.max(28, infoH - 2)
    local rankIconSz = math.floor(rankBase * self.config.iconScale.rank)
    local barPad     = 4
    -- The EMP icon moved to the score row (the old Volendrung slot), so the
    -- rank icon now starts hard against the left edge and the progress bar
    -- absorbs the width the EMP icon used to occupy.
    -- KB: starts at statsX + statW = (width - statW*3) + statW = width - statW*2
    -- K: and D: are fixed 75px wide, anchored from the right edge
    local kbStart    = self.config.width - 130
    local gapEnd     = kbStart - barPad
    local rankX      = 0
    local barLeft    = rankX + rankBase + barPad
    local barW       = gapEnd - barLeft

    -- Bar label font. Auto mode sets the font size equal to barHeight so the
    -- text fills the bar. The glyphs themselves are smaller than the em size
    -- (cap height is roughly 70% of it), so this reads as filling the bar
    -- rather than overflowing it. Change barHeight and the text follows.
    local barFontPx = self.config.barFontSize
    if not barFontPx or barFontPx <= 0 then
        barFontPx = math.max(10, math.floor(self.config.barHeight))
    end
    local barLabelFont = "EsoUI/Common/Fonts/FTN57.otf|" .. barFontPx .. "|outline"
    local barNudge = self.config.barTextNudge or 0

    local killFont = "EsoUI/Common/Fonts/FTN57.otf|" .. (self.config.kdFontSize or 20) .. "|outline"

    -- NOTE: infoEmpIcon is created further down, in the score row block -- it
    -- now lives on the score row and scoreRow does not exist yet at this point.

    -- Rank icon: far left of the info row, grown centred on its base slot.
    local rankGrow = math.floor((rankIconSz - rankBase) / 2)
    self.controls.infoRankIcon = wm:CreateControl(nil, self.controls.TLW, CT_TEXTURE)
    self.controls.infoRankIcon:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT,
        rankX - rankGrow,
        20 + math.floor((infoH - rankBase) / 2) - rankGrow)
    self.controls.infoRankIcon:SetDimensions(rankIconSz, rankIconSz)
    self.controls.infoRankIcon:SetDrawLayer(2)
    self.controls.infoRankIcon:SetHidden(true)

    local barH = self.config.barHeight
    self.controls.infoBarBg = wm:CreateControl(nil, self.controls.TLW, CT_BACKDROP)
    self.controls.infoBarBg:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT, barLeft, 20 + math.floor((infoH - barH) / 2))
    self.controls.infoBarBg:SetDimensions(barW, barH)
    self.controls.infoBarBg:SetCenterColor(0.1, 0.1, 0.1, 0.9)
    self.controls.infoBarBg:SetEdgeColor(0, 0, 0, 1)
    self.controls.infoBarBg:SetDrawLayer(1)
    self.controls.infoBarBg:SetHidden(true)

    self.controls.infoBar = wm:CreateControl(nil, self.controls.TLW, CT_STATUSBAR)
    self.controls.infoBar:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT, barLeft + 1, 20 + math.floor((infoH - barH) / 2) + 1)
    self.controls.infoBar:SetDimensions(barW - 2, barH - 2)
    self.controls.infoBar:SetMinMax(0, 100)
    self.controls.infoBar:SetValue(0)
    self.controls.infoBar:SetDrawLayer(2)
    self.controls.infoBar:SetHidden(true)

    self.controls.infoRankNum = wm:CreateControl(nil, self.controls.TLW, CT_LABEL)
    self.controls.infoRankNum:SetFont(barLabelFont)
    self.controls.infoRankNum:SetAnchor(LEFT, self.controls.infoBarBg, LEFT, 3, barNudge)
    -- Extra vertical headroom so an outlined font sized to barHeight isn't
    -- clipped. Both labels anchor by their vertical midpoint to the bar's, so
    -- growing the box expands evenly and the text stays centred on the bar.
    self.controls.infoRankNum:SetDimensions(math.floor(barW / 2), barH + 6)
    self.controls.infoRankNum:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.infoRankNum:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.controls.infoRankNum:SetColor(1, 1, 1, 1)
    self.controls.infoRankNum:SetDrawLayer(3)
    self.controls.infoRankNum:SetHidden(true)

    self.controls.infoAPText = wm:CreateControl(nil, self.controls.TLW, CT_LABEL)
    self.controls.infoAPText:SetFont(barLabelFont)
    self.controls.infoAPText:SetAnchor(RIGHT, self.controls.infoBarBg, RIGHT, -3, barNudge)
    self.controls.infoAPText:SetDimensions(barW - 3, barH + 6)
    self.controls.infoAPText:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.infoAPText:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.controls.infoAPText:SetColor(1, 1, 1, 1)
    self.controls.infoAPText:SetDrawLayer(3)
    self.controls.infoAPText:SetHidden(true)

    -- K: and D: are ONE label, not two.
    --
    -- They used to be two fixed-width boxes each centring its own text, which
    -- meant the pair could never grow as a unit -- and the boxes actually
    -- overlapped by 15px with mismatched widths (65 vs 80).
    --
    -- Now: a single label whose RIGHT edge is pinned to the row's right edge
    -- and whose text is right-aligned. The string only ever occupies the width
    -- it needs, so as the counts gain digits the whole thing grows leftward
    -- and the right edge never moves:
    --      K: 0 D: 0   ->   K: 13 D: 14   ->   K: 233 D: 233
    -- The per-part colours survive because they are inline colour codes in the
    -- string rather than properties of two separate controls.
    self.controls.infoKD = wm:CreateControl(nil, self.controls.TLW, CT_LABEL)
    self.controls.infoKD:SetFont(killFont)
    self.controls.infoKD:SetAnchor(TOPRIGHT, self.controls.TLW, TOPRIGHT,
        -(self.config.kdRightPad or 0), 20 + (self.config.kdTextNudge or 0))
    -- Box is deliberately wider than the text will ever be. It is transparent
    -- and right-aligned, so the extra width hangs off to the LEFT unused and
    -- costs nothing -- it just guarantees long counts are never clipped.
    self.controls.infoKD:SetDimensions(220, infoH)
    self.controls.infoKD:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.infoKD:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.controls.infoKD:SetDrawLayer(2)
    self.controls.infoKD:SetHidden(true)

    local scoreFont = "EsoUI/Common/Fonts/FTN57.otf|20|outline"
    local timerFont = PvPUA:GetFont()
    self.controls.scoreRow = wm:CreateControl(nil, self.controls.TLW, CT_CONTROL)
    self.controls.scoreRow:SetDimensions(self.config.width, self.config.entryHeight)
    self.controls.scoreRow:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT, 0, 20 + self.config.entryHeight)
    self.controls.scoreRow:SetHidden(true)

    self.controls.scoreRowBg = wm:CreateControl(nil, self.controls.scoreRow, CT_BACKDROP)
    self.controls.scoreRowBg:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT, 0, 0)
    self.controls.scoreRowBg:SetDimensions(self.config.width, self.config.entryHeight)
    self.controls.scoreRowBg:SetCenterColor(0, 0, 0, 0.5)
    self.controls.scoreRowBg:SetEdgeColor(0, 0, 0, 0)
    self.controls.scoreRowBg:SetDrawLayer(0)

    local iBase = math.max(16, self.config.entryHeight - 4)
    local iSize = math.floor(iBase * self.config.iconScale.allianceScore)
    local iGrow = math.floor((iSize - iBase) / 2)
    local dcColor = GetColorForAlliance(ALLIANCE_DAGGERFALL_COVENANT)
    local adColor = GetColorForAlliance(ALLIANCE_ALDMERI_DOMINION)
    local epColor = GetColorForAlliance(ALLIANCE_EBONHEART_PACT)

    -- EMP icon occupies the slot the Volendrung icon used to hold (Volendrung
    -- now has its own list row). Parented to scoreRow so it inherits that row's
    -- show/hide, and sized to the score row's icon slot, which is what the
    -- -2,-2 anchor offset was tuned against.
    -- Grey when nobody is emperor, colored by alliance when there is one.
    local empBaseW = PvPUA.config.imageWidth + 4
    local empBaseH = self.config.entryHeight + 4
    local empW     = math.floor(empBaseW * self.config.iconScale.emperor)
    local empH     = math.floor(empBaseH * self.config.iconScale.emperor)
    self.controls.infoEmpIcon = wm:CreateControl(nil, self.controls.scoreRow, CT_TEXTURE)
    self.controls.infoEmpIcon:SetTexture("esoui/art/campaign/gamepad/gp_overview_menuicon_emperor.dds")
    self.controls.infoEmpIcon:SetDimensions(empW, empH)
    self.controls.infoEmpIcon:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT,
        -2 - math.floor((empW - empBaseW) / 2),
        -2 - math.floor((empH - empBaseH) / 2))
    self.controls.infoEmpIcon:SetColor(0.35, 0.35, 0.35, 1)
    self.controls.infoEmpIcon:SetDrawLayer(1)
    self.controls.infoEmpIcon:SetHidden(true)

    -- Width of the leading icon slot; unchanged by the Volendrung -> EMP swap
    -- since both use the same dimensions.
    local volW = PvPUA.config.imageWidth + 4 + 8
    local timerW = self.config.underAttackForWidth
    local remaining = self.config.width - volW - timerW - 4
    local groupW = math.floor(remaining / 3)
    local ptsW = groupW - iBase     -- label gets the full remaining group width
    local col1 = volW
    local col2 = col1 + groupW
    local col3 = col1 + groupW * 2

    self.controls.scoreDCIcon = wm:CreateControl(nil, self.controls.scoreRow, CT_TEXTURE)
    self.controls.scoreDCIcon:SetTexture("/esoui/art/ava/ava_hud_emblem_daggerfall.dds")
    self.controls.scoreDCIcon:SetDimensions(iSize, iSize)
    self.controls.scoreDCIcon:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT, col1 - iGrow, -iGrow)
    self.controls.scoreDCIcon:SetDrawLayer(1)

    self.controls.scoreDCScroll = wm:CreateControl(nil, self.controls.scoreRow, CT_TEXTURE)
    self.controls.scoreDCScroll:SetTexture(PvPUA.constants.textures.SCROLL_TALLY[ALLIANCE_DAGGERFALL_COVENANT])
    self.controls.scoreDCScroll:SetDimensions(iBase, iBase)
    self.controls.scoreDCScroll:SetAnchor(CENTER, self.controls.scoreDCIcon, CENTER, 0, 0)
    self.controls.scoreDCScroll:SetDrawLayer(3)
    self.controls.scoreDCScroll:SetDrawTier(DT_MEDIUM)
    self.controls.scoreDCScroll:SetHidden(false)

    self.controls.scoreDCScrollTxt = wm:CreateControl(nil, self.controls.scoreRow, CT_LABEL)
    self.controls.scoreDCScrollTxt:SetFont(scoreFont)
    self.controls.scoreDCScrollTxt:SetAnchor(CENTER, self.controls.scoreDCIcon, CENTER, 0, 0)
    self.controls.scoreDCScrollTxt:SetDimensions(iBase, iBase)
    self.controls.scoreDCScrollTxt:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreDCScrollTxt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreDCScrollTxt:SetColor(1, 1, 1, 1)
    self.controls.scoreDCScrollTxt:SetDrawLayer(4)
    self.controls.scoreDCScrollTxt:SetDrawTier(DT_HIGH)
    self.controls.scoreDCScrollTxt:SetHidden(false)

    self.controls.scoreDCPts = wm:CreateControl(nil, self.controls.scoreRow, CT_LABEL)
    self.controls.scoreDCPts:SetFont(scoreFont)
    self.controls.scoreDCPts:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT, col1 + iBase + 4, 0)
    self.controls.scoreDCPts:SetDimensions(ptsW, self.config.entryHeight)
    self.controls.scoreDCPts:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreDCPts:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.controls.scoreDCPts:SetColor(dcColor.r, dcColor.g, dcColor.b, 1)

    self.controls.scoreADIcon = wm:CreateControl(nil, self.controls.scoreRow, CT_TEXTURE)
    self.controls.scoreADIcon:SetTexture("/esoui/art/ava/ava_hud_emblem_aldmeri.dds")
    self.controls.scoreADIcon:SetDimensions(iSize, iSize)
    self.controls.scoreADIcon:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT, col2 - iGrow, -iGrow)
    self.controls.scoreADIcon:SetDrawLayer(1)

    self.controls.scoreADScroll = wm:CreateControl(nil, self.controls.scoreRow, CT_TEXTURE)
    self.controls.scoreADScroll:SetTexture(PvPUA.constants.textures.SCROLL_TALLY[ALLIANCE_ALDMERI_DOMINION])
    self.controls.scoreADScroll:SetDimensions(iBase, iBase)
    self.controls.scoreADScroll:SetAnchor(CENTER, self.controls.scoreADIcon, CENTER, 0, 0)
    self.controls.scoreADScroll:SetDrawLayer(3)
    self.controls.scoreADScroll:SetDrawTier(DT_MEDIUM)
    self.controls.scoreADScroll:SetHidden(false)

    self.controls.scoreADScrollTxt = wm:CreateControl(nil, self.controls.scoreRow, CT_LABEL)
    self.controls.scoreADScrollTxt:SetFont(scoreFont)
    self.controls.scoreADScrollTxt:SetAnchor(CENTER, self.controls.scoreADIcon, CENTER, 0, 0)
    self.controls.scoreADScrollTxt:SetDimensions(iBase, iBase)
    self.controls.scoreADScrollTxt:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreADScrollTxt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreADScrollTxt:SetColor(1, 1, 1, 1)
    self.controls.scoreADScrollTxt:SetDrawLayer(4)
    self.controls.scoreADScrollTxt:SetDrawTier(DT_HIGH)
    self.controls.scoreADScrollTxt:SetHidden(false)

    self.controls.scoreADPts = wm:CreateControl(nil, self.controls.scoreRow, CT_LABEL)
    self.controls.scoreADPts:SetFont(scoreFont)
    self.controls.scoreADPts:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT, col2 + iBase + 4, 0)
    self.controls.scoreADPts:SetDimensions(ptsW, self.config.entryHeight)
    self.controls.scoreADPts:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreADPts:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.controls.scoreADPts:SetColor(adColor.r, adColor.g, adColor.b, 1)

    self.controls.scoreEPIcon = wm:CreateControl(nil, self.controls.scoreRow, CT_TEXTURE)
    self.controls.scoreEPIcon:SetTexture("/esoui/art/ava/ava_hud_emblem_ebonheart.dds")
    self.controls.scoreEPIcon:SetDimensions(iSize, iSize)
    self.controls.scoreEPIcon:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT, col3 - iGrow, -iGrow)
    self.controls.scoreEPIcon:SetDrawLayer(1)

    self.controls.scoreEPScroll = wm:CreateControl(nil, self.controls.scoreRow, CT_TEXTURE)
    self.controls.scoreEPScroll:SetTexture(PvPUA.constants.textures.SCROLL_TALLY[ALLIANCE_EBONHEART_PACT])
    self.controls.scoreEPScroll:SetDimensions(iBase, iBase)
    self.controls.scoreEPScroll:SetAnchor(CENTER, self.controls.scoreEPIcon, CENTER, 0, 0)
    self.controls.scoreEPScroll:SetDrawLayer(3)
    self.controls.scoreEPScroll:SetDrawTier(DT_MEDIUM)
    self.controls.scoreEPScroll:SetHidden(false)

    self.controls.scoreEPScrollTxt = wm:CreateControl(nil, self.controls.scoreRow, CT_LABEL)
    self.controls.scoreEPScrollTxt:SetFont(scoreFont)
    self.controls.scoreEPScrollTxt:SetAnchor(CENTER, self.controls.scoreEPIcon, CENTER, 0, 0)
    self.controls.scoreEPScrollTxt:SetDimensions(iBase, iBase)
    self.controls.scoreEPScrollTxt:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreEPScrollTxt:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreEPScrollTxt:SetColor(1, 1, 1, 1)
    self.controls.scoreEPScrollTxt:SetDrawLayer(4)
    self.controls.scoreEPScrollTxt:SetDrawTier(DT_HIGH)
    self.controls.scoreEPScrollTxt:SetHidden(false)

    self.controls.scoreEPPts = wm:CreateControl(nil, self.controls.scoreRow, CT_LABEL)
    self.controls.scoreEPPts:SetFont(scoreFont)
    self.controls.scoreEPPts:SetAnchor(TOPLEFT, self.controls.scoreRow, TOPLEFT, col3 + iBase + 4, 0)
    self.controls.scoreEPPts:SetDimensions(ptsW, self.config.entryHeight)
    self.controls.scoreEPPts:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreEPPts:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    self.controls.scoreEPPts:SetColor(epColor.r, epColor.g, epColor.b, 1)

    self.controls.scoreTimer = wm:CreateControl(nil, self.controls.scoreRow, CT_LABEL)
    self.controls.scoreTimer:SetFont(scoreFont)
    self.controls.scoreTimer:SetAnchor(TOPRIGHT, self.controls.scoreRow, TOPRIGHT, -2, 0)
    self.controls.scoreTimer:SetDimensions(timerW, self.config.entryHeight)
    self.controls.scoreTimer:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    self.controls.scoreTimer:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    self.controls.scoreTimer:SetColor(1, 1, 1, 1)

    self.controls.hudFragment = ZO_HUDFadeSceneFragment:New(self.controls.TLW)
end

--------------------------------------------------
-- UpdateHUDScenes
--------------------------------------------------
function PvPUA:UpdateHUDScenes()
    if not self.controls.hudFragment then return end
    local scenes = { "hud", "hudui" }
    local shouldShow = IsInCyrodiilOrIC() or self.showInMenu
    for _, name in ipairs(scenes) do
        local scene = SCENE_MANAGER:GetScene(name)
        if scene then
            local has = scene:HasFragment(self.controls.hudFragment)
            if shouldShow and not has then
                scene:AddFragment(self.controls.hudFragment)
            elseif not shouldShow and has then
                scene:RemoveFragment(self.controls.hudFragment)
            end
        end
    end
    if self.showInMenu then
        self.controls.TLW:SetHidden(false)
    else
        local cur = SCENE_MANAGER:GetCurrentScene()
        local hasFragment = cur and cur:HasFragment(self.controls.hudFragment)
        self.controls.TLW:SetHidden(not hasFragment)
    end
end

--------------------------------------------------
-- RefreshBackdropColors
--------------------------------------------------
function PvPUA:RefreshBackdropColors()
    local useAlliance = self.savedVariables and self.savedVariables.backdropStyle == "Alliance"
    local bc = self.savedVariables and self.savedVariables.backdropColor
    local br = bc and bc.r or 0
    local bg_c = bc and bc.g or 0
    local bb = bc and bc.b or 0
    -- score row and emp/info row
    if self.controls.scoreRowBg then
        if useAlliance then
            self.controls.scoreRowBg:SetCenterColor(0, 0, 0, 0.5)
        else
            self.controls.scoreRowBg:SetCenterColor(br, bg_c, bb, 0.5)
        end
    end
    if self.controls.infoBg then
        if useAlliance then
            self.controls.infoBg:SetCenterColor(0, 0, 0, 0.5)
        else
            self.controls.infoBg:SetCenterColor(br, bg_c, bb, 0.5)
        end
    end
    -- entry row backdrops
    if self.state and self.state.visibleControls then
        for i, control in ipairs(self.state.visibleControls) do
            if control and control.backdrop then
                local ac = { r = 0, g = 0, b = 0 }
                if useAlliance and self.state.lastItems and self.state.lastItems[i] then
                    ac = GetColorForAlliance(self.state.lastItems[i].owningAlliance)
                end
                if useAlliance then
                    -- Match the main draw path: dropped scroll rows go white.
                    local rr, rg, rb = ac.r, ac.g, ac.b
                    local li = self.state.lastItems and self.state.lastItems[i]
                    if li and li.isScrollDropped then rr, rg, rb = 1, 1, 1 end
                    if i % 2 == 0 then
                        control.backdrop:SetCenterColor(rr, rg, rb, self.config.backdropAlphaEven)
                    else
                        control.backdrop:SetCenterColor(rr, rg, rb, self.config.backdropAlphaOdd)
                    end
                else
                    if i % 2 == 0 then
                        control.backdrop:SetCenterColor(br, bg_c, bb, self.config.backdropAlphaEven)
                    else
                        control.backdrop:SetCenterColor(br, bg_c, bb, self.config.backdropAlphaOdd)
                    end
                end
            end
        end
    end
end

--------------------------------------------------
-- UpdateEntries
--------------------------------------------------
function PvPUA:UpdateEntries(itemsOfInterest)
    self.state.lastItems = itemsOfInterest
    local adColor = GetColorForAlliance(ALLIANCE_ALDMERI_DOMINION)
    local epColor = GetColorForAlliance(ALLIANCE_EBONHEART_PACT)
    local dcColor = GetColorForAlliance(ALLIANCE_DAGGERFALL_COVENANT)
    for i = 1, #itemsOfInterest do
        local item = itemsOfInterest[i]
        local control = self.state.visibleControls[i]
        if not control then break end
        control:ClearAnchors()
        control:SetAnchor(TOPLEFT, self.controls.TLW.rootControl, TOPLEFT, 0, self.config.entryHeight * (i - 1))
        control:SetHidden(false)
        local ac = GetColorForAlliance(item.owningAlliance)
        local useAlliance = self.savedVariables and self.savedVariables.backdropStyle == "Alliance"
        local bc = self.savedVariables and self.savedVariables.backdropColor
        local br = bc and bc.r or 0
        local bg_c = bc and bc.g or 0
        local bb = bc and bc.b or 0
        if useAlliance then
            -- Dropped scrolls get a white backdrop as a second "it's on the
            -- ground" cue, matching how Volendrung and unclaimed milegates/
            -- bridges already render (they resolve to alliance 0, which falls
            -- through to noAllianceColor = white). The TEXT keeps the carrier's
            -- alliance colour, so the row still shows who dropped it.
            -- Alpha is untouched, so this is the same translucent wash as every
            -- other row -- never solid white.
            -- Only applied in Alliance mode: in Custom mode every row uses the
            -- user's chosen colour, so forcing white there would look like the
            -- addon ignoring their setting rather than a status indicator.
            local rr, rg, rb = ac.r, ac.g, ac.b
            if item.isScrollDropped then rr, rg, rb = 1, 1, 1 end
            if i % 2 == 0 then
                control.backdrop:SetCenterColor(rr, rg, rb, self.config.backdropAlphaEven)
            else
                control.backdrop:SetCenterColor(rr, rg, rb, self.config.backdropAlphaOdd)
            end
        else
            if i % 2 == 0 then
                control.backdrop:SetCenterColor(br, bg_c, bb, self.config.backdropAlphaEven)
            else
                control.backdrop:SetCenterColor(br, bg_c, bb, self.config.backdropAlphaOdd)
            end
        end
        control.backdrop:SetEdgeColor(0, 0, 0, 0)
        if item.isUnderAttack == true then
            control.backdrop:SetHidden(false)
            control.uaImage:SetHidden(false)
            if control.uaOutline then control.uaOutline:SetHidden(item.isScrollCarrier == true) end
            control.image:SetHidden(false)
        else
            control.backdrop:SetHidden(false)
            control.uaImage:SetHidden(true)
            if control.uaOutline then control.uaOutline:SetHidden(true) end
            control.image:SetHidden(false)
        end
        local texture, offset = GetTextureAndOffsetForItem(item.keepType, item.rType, item.isPassable)
        if item.isScrollCarrier then
            -- Carrier rows use the scroll's own map pin as the row icon. Drawn at
            -- full white like the keep scrolls, so multi-color pins (e.g. Ghartok's
            -- orange) keep their detail instead of being crushed to one flat color.
            texture = item.carrierTexture or texture
            offset = 2
            local baseW = self.config.imageWidth + offset * 2
            local baseH = self.config.entryHeight + offset * 2
            -- Volendrung rows carry their own scale; scrolls use the shared one.
            local iconScale = item.carrierIconScale or SCROLL_CARRIER_ICON_SCALE
            local cw = baseW * iconScale
            local ch = baseH * iconScale
            -- Anchor is TOPLEFT, so growing the texture would push it down-right.
            -- Shift back by half the growth on each axis to keep it centred in
            -- the same slot the un-scaled icon occupied.
            local dx = (cw - baseW) / 2
            local dy = (ch - baseH) / 2
            control.image:SetTexture(texture)
            control.image:ClearAnchors()
            control.image:SetAnchor(TOPLEFT, control, TOPLEFT, -offset - dx, -offset - dy)
            control.image:SetDimensions(cw, ch)
            -- Scrolls stay flat white so multi-colour pins keep their detail.
            -- Volendrung opts into the alliance tint so it matches the keep
            -- icons and the row text rather than ZeniMax's lighter pin palette.
            if item.carrierTint then
                control.image:SetColor(ac.r, ac.g, ac.b, 1)
            else
                control.image:SetColor(1, 1, 1, 1)
            end
            if control.imageOutline then control.imageOutline:SetHidden(true) end
        else
            control.image:SetTexture(texture)
            control.image:ClearAnchors()
            control.image:SetAnchor(TOPLEFT, control, TOPLEFT, -offset, -offset)
            control.image:SetDimensions(self.config.imageWidth + offset * 2, self.config.entryHeight + offset * 2)
            control.image:SetColor(ac.r, ac.g, ac.b, 1)
            if control.imageOutline then
                local OL = 2   -- outline thickness in px
                control.imageOutline:SetTexture(texture)
                control.imageOutline:ClearAnchors()
                control.imageOutline:SetAnchor(TOPLEFT, control, TOPLEFT, -offset - OL, -offset - OL)
                control.imageOutline:SetDimensions(self.config.imageWidth + offset * 2 + OL * 2,
                                                   self.config.entryHeight + offset * 2 + OL * 2)
                control.imageOutline:SetColor(0, 0, 0, 1)
                control.imageOutline:SetHidden(texture == nil or texture == "")
            end
        end

        -- Scroll on top of the keep (same size as the keep icon, centered). Fully
        -- guarded: any failure here skips the scroll and leaves the row intact.
        if control.scrollImage then
            local okScroll = pcall(function()
                if item.isScrollCarrier then
                    control.scrollImage:SetHidden(true)
                elseif item.scroll and item.scroll.pinType then
                    local sTex = GetScrollTexture(item.scroll.pinType)
                    if sTex then
                        local sw = (self.config.imageWidth + offset * 2) * SCROLL_KEEP_ICON_SCALE
                        local sh = (self.config.entryHeight + offset * 2) * SCROLL_KEEP_ICON_SCALE
                        control.scrollImage:ClearAnchors()
                        control.scrollImage:SetAnchor(CENTER, control.image, CENTER, 0, 0)
                        control.scrollImage:SetDimensions(sw, sh)
                        control.scrollImage:SetTexture(sTex)
                        control.scrollImage:SetColor(1, 1, 1, 1)
                        control.scrollImage:SetHidden(false)
                    else
                        control.scrollImage:SetHidden(true)
                    end
                else
                    control.scrollImage:SetHidden(true)
                end
            end)
            if not okScroll then control.scrollImage:SetHidden(true) end
        end

        if item.isScrollCarrier then
            -- Carrier rows have no progress bar / siege counts / flip status, so
            -- the name spans all of that unused width. Both scroll and
            -- Volendrung carrier rows now bake their own per-segment |c..|r
            -- color markup into item.name (see GetScrollCarrierItems /
            -- GetVolendrungCarrierItem), so the row's base color stays white
            -- -- that's what any unmarked text (the "@ location" gap) renders in.
            local wideName = self.config.nameWidth + self.config.flagWidth
                           + self.config.siegeWidth * 3 + self.config.flagFlipWidth
            control.name:SetDimensions(wideName, self.config.entryHeight)
            control.name:SetColor(1, 1, 1, 1)
            control.name:SetText(item.name)
        else
            control.name:SetDimensions(self.config.nameWidth, self.config.entryHeight)
            control.name:SetColor(ac.r, ac.g, ac.b, 1)
            control.name:SetText(item.name)
        end

        local font = PvPUA:GetFont()
        control.name:SetFont(font)
        control.adSiege:SetFont(font)
        control.epSiege:SetFont(font)
        control.dcSiege:SetFont(font)
        control.flipStatus:SetFont(font)
        control.underAttackFor:SetFont(font)

        if self.controls.scoreTimer then
            -- scoreTimer font is fixed, not affected by user font setting
        end

        if item.siegeWeapons ~= nil then
            SetSiegeWeapons(control.dcSiege, item.siegeWeapons.DC)
            SetSiegeWeapons(control.adSiege, item.siegeWeapons.AD)
            SetSiegeWeapons(control.epSiege, item.siegeWeapons.EP)
            control.dcSiege:SetColor(dcColor.r, dcColor.g, dcColor.b, 1)
            control.adSiege:SetColor(adColor.r, adColor.g, adColor.b, 1)
            control.epSiege:SetColor(epColor.r, epColor.g, epColor.b, 1)
        else
            control.adSiege:SetText("")
            control.epSiege:SetText("")
            control.dcSiege:SetText("")
        end

        local underAttackFor = item.underAttackFor
        control.underAttackFor:SetText(FormatUnderAttackTime(underAttackFor / 1000))
        local tr, tg, tb = GetTimerColor()
        control.underAttackFor:SetColor(tr, tg, tb, 1)

        local objectives = item.objectives
        control.progress.bar1:ClearAnchors()
        control.progress.bar2:ClearAnchors()
        control.progress.bar3:ClearAnchors()
        if item.isScrollCarrier then
            control.progress.bar1:SetHidden(true)
            control.progress.bar2:SetHidden(true)
            control.progress.bar3:SetHidden(true)
            control.flipStatus:SetText("")
        elseif item.keepType == KEEPTYPE_KEEP or item.keepType == KEEPTYPE_OUTPOST then
            control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, self.config.entryHeight / 2 - self.config.flagHeight - 1)
            control.progress.bar2:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, self.config.entryHeight / 2 + 1)
            control.progress.bar1:SetHidden(false)
            control.progress.bar2:SetHidden(false)
            control.progress.bar3:SetHidden(true)
            if objectives ~= nil and objectives[1] ~= nil and objectives[2] ~= nil then
                control.progress.bar1.progress:SetValue(objectives[1].state)
                control.progress.bar2.progress:SetValue(objectives[2].state)
                control.progress.bar1.progress:SetColor(GetColorForAlliance(objectives[1].holdingAlliance).r, GetColorForAlliance(objectives[1].holdingAlliance).g, GetColorForAlliance(objectives[1].holdingAlliance).b)
                control.progress.bar2.progress:SetColor(GetColorForAlliance(objectives[2].holdingAlliance).r, GetColorForAlliance(objectives[2].holdingAlliance).g, GetColorForAlliance(objectives[2].holdingAlliance).b)
            else
                control.progress.bar1.progress:SetValue(100)
                control.progress.bar2.progress:SetValue(100)
            end
        elseif item.keepType == KEEPTYPE_TOWN then
            control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, self.config.entryHeight / 6 - self.config.flagHeight / 2)
            control.progress.bar2:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, self.config.entryHeight / 6 * 3 - self.config.flagHeight / 2)
            control.progress.bar3:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, self.config.entryHeight / 6 * 5 - self.config.flagHeight / 2)
            control.progress.bar1:SetHidden(false)
            control.progress.bar2:SetHidden(false)
            control.progress.bar3:SetHidden(false)
            if objectives ~= nil then
                control.progress.bar1.progress:SetValue(objectives[1].state)
                control.progress.bar2.progress:SetValue(objectives[2].state)
                control.progress.bar3.progress:SetValue(objectives[3].state)
                control.progress.bar1.progress:SetColor(GetColorForAlliance(objectives[1].holdingAlliance).r, GetColorForAlliance(objectives[1].holdingAlliance).g, GetColorForAlliance(objectives[1].holdingAlliance).b)
                control.progress.bar2.progress:SetColor(GetColorForAlliance(objectives[2].holdingAlliance).r, GetColorForAlliance(objectives[2].holdingAlliance).g, GetColorForAlliance(objectives[2].holdingAlliance).b)
                control.progress.bar3.progress:SetColor(GetColorForAlliance(objectives[3].holdingAlliance).r, GetColorForAlliance(objectives[3].holdingAlliance).g, GetColorForAlliance(objectives[3].holdingAlliance).b)
            end
        elseif item.keepType == KEEPTYPE_RESOURCE then
            control.progress.bar1:SetAnchor(TOPLEFT, control.progress, TOPLEFT, 0, self.config.entryHeight / 2 - self.config.flagHeight / 2)
            control.progress.bar1:SetHidden(false)
            control.progress.bar2:SetHidden(true)
            control.progress.bar3:SetHidden(true)
            if objectives ~= nil then
                control.progress.bar1.progress:SetValue(objectives[1].state)
                control.progress.bar1.progress:SetColor(GetColorForAlliance(objectives[1].holdingAlliance).r, GetColorForAlliance(objectives[1].holdingAlliance).g, GetColorForAlliance(objectives[1].holdingAlliance).b)
            end
        else
            control.progress.bar1:SetHidden(true)
            control.progress.bar2:SetHidden(true)
            control.progress.bar3:SetHidden(true)
        end

        if item.flipsAt ~= nil then
            local flipsIn = math.floor((item.flipsAt - GetGameTimeMilliseconds()) / 1000)
            if flipsIn >= 0 then
                control.flipStatus:SetText(flipsIn)
                if objectives ~= nil and objectives[1].holdingAlliance == GetUnitAlliance("player") then
                    control.flipStatus:SetColor(0, 1, 0, 1)
                else
                    control.flipStatus:SetColor(1, 0, 0, 1)
                end
            else
                control.flipStatus:SetText("")
            end
        else
            control.flipStatus:SetText("")
        end
    end
    for i = #itemsOfInterest + 1, #self.state.visibleControls do
        local c = self.state.visibleControls[i]
        c:SetHidden(true)
        if c.scrollImage then c.scrollImage:SetHidden(true) end
    end
end

--------------------------------------------------
-- Veterancy (Update 50 / API 101050)
--
-- Veterancy is NOT a dedicated rank API -- it rides on the reward-track system.
-- Call chain (verified against the PvPRanks U50 addon):
--   REWARD_TRACK_TYPE_AVA_VETERANCY
--   -> GetActiveReferenceTrackIdsForRewardTrackType(trackType)   -> trackId
--   -> GetReferenceTrackIndex(trackType, trackId)                -> trackIndex
--   -> GetInfoForRewardTrack(trackType, trackIndex)              -> ?, rank, progress
--   -> GetRewardTrackIdFromReferenceTrackId(trackType, trackId)  -> rewardTrackId
--   -> GetTotalProgressAtRewardTrackTier(rewardTrackId, rank)    -> total needed
--
-- The FIRST return of GetInfoForRewardTrack is discarded by PvPRanks. It may be
-- the track name or an icon path; we capture it and only use it as a texture if
-- it actually looks like one.
--------------------------------------------------
function PvPUA:GetVeterancyInfo()
    local info = { ok = false, rank = 0, progress = 0, total = 0, icon = nil, raw1 = nil, why = nil }
    local okCall = pcall(function()
        if REWARD_TRACK_TYPE_AVA_VETERANCY == nil then info.why = "no REWARD_TRACK_TYPE_AVA_VETERANCY" return end
        if not (GetActiveReferenceTrackIdsForRewardTrackType and GetReferenceTrackIndex
                and GetInfoForRewardTrack) then info.why = "reward track API missing" return end

        local trackType = REWARD_TRACK_TYPE_AVA_VETERANCY

        -- NOTE: the name is plural ("TrackIds") -- this returns a VARIABLE number
        -- of active track ids, not just one. Taking only the first return breaks
        -- whenever veterancy is not the first active track. Collect them all and
        -- use the first one that actually resolves to a usable track index.
        local ids = { GetActiveReferenceTrackIdsForRewardTrackType(trackType) }
        if #ids == 0 then info.why = "no active track ids" return end

        local trackId, trackIndex
        for i = 1, #ids do
            local candidate = ids[i]
            if type(candidate) == "number" then
                local idx = GetReferenceTrackIndex(trackType, candidate)
                if idx then
                    trackId, trackIndex = candidate, idx
                    break
                end
            end
        end
        if not trackIndex then info.why = "no resolvable track index" return end

        local first, currentRank, progressToNextRank = GetInfoForRewardTrack(trackType, trackIndex)
        info.raw1 = first

        -- Guard against a shifted return signature: if the value we think is the
        -- rank isn't a number, scan the returns and take the first numeric pair.
        if type(currentRank) ~= "number" then
            local rets = { GetInfoForRewardTrack(trackType, trackIndex) }
            for i = 1, #rets do
                if type(rets[i]) == "number" then
                    currentRank = rets[i]
                    progressToNextRank = (type(rets[i + 1]) == "number") and rets[i + 1] or 0
                    break
                end
            end
        end

        info.rank = currentRank or 0
        info.progress = progressToNextRank or 0

        -- Icon art only exists up to rank 100. The player can technically sit
        -- at 101 (reward track allows it), but there is no tier art for 101,
        -- so an unclamped lookup returns a bogus .dds path and the game shows
        -- a missing-texture question mark. Clamp ONLY the value used for icon
        -- lookups -- info.rank itself stays uncapped so the rank number label
        -- still reads 101, matching how the game's own player-inspect panel
        -- shows "101" next to the rank-100 icon.
        local iconRank = info.rank
        if iconRank > 100 then iconRank = 100 end

        if GetRewardTrackIdFromReferenceTrackId and GetTotalProgressAtRewardTrackTier then
            local rewardTrackId = GetRewardTrackIdFromReferenceTrackId(trackType, trackId)
            if rewardTrackId then
                info.total = GetTotalProgressAtRewardTrackTier(rewardTrackId, info.rank) or 0
            end
        end

        -- Only treat the first return as an icon if it looks like a texture path.
        if type(first) == "string" and first:lower():find("%.dds") then
            info.icon = first
        end

        -- The first return of GetInfoForRewardTrack is usually the track NAME,
        -- not a texture, so the check above almost never produces an icon. The
        -- veterancy rank icon comes from a dedicated function. Exact name is not
        -- in the public docs (they predate U50), so probe the plausible names
        -- that actually exist in this client and take the first .dds one gives.
        if not info.icon then
            local iconFns = {
                -- CONFIRMED in-game (Xbox, U50): GetVeterancyRankIcon(rank)
                -- takes the ABSOLUTE veterancy rank and resolves the tier art
                -- itself. e.g. rank 81 ("Brutal Marauder", the first step of the
                -- Marauder tier) -> /esoui/art/vengeance/ranks/season00/
                -- s00_marauder_rank0.dds. The trailing _rank0 is the sub-step
                -- WITHIN that tier, not a failure value. Keep this first.
                { fn = "GetVeterancyRankIcon",          args = { "rank" } },
                -- Fallbacks only, in case the name changes in a later update.
                { fn = "GetAvAVeterancyRankIcon",       args = { "rank" } },
                { fn = "GetRewardTrackTierIcon",        args = { "rewardTrackId", "rank" } },
                { fn = "GetRewardTrackRankIcon",        args = { "trackType", "rank" } },
                { fn = "GetLargeAvAVeterancyRankIcon",  args = { "rank" } },
            }
            local rewardTrackIdForIcon
            if GetRewardTrackIdFromReferenceTrackId then
                rewardTrackIdForIcon = GetRewardTrackIdFromReferenceTrackId(trackType, trackId)
            end
            local argValues = {
                rank          = iconRank,
                trackType     = trackType,
                rewardTrackId = rewardTrackIdForIcon,
                tier          = (type(first) == "number") and first or nil,
            }
            for i = 1, #iconFns do
                local entry = iconFns[i]
                local f = _G[entry.fn]
                if type(f) == "function" then
                    local callArgs, missing = {}, false
                    for a = 1, #entry.args do
                        local val = argValues[entry.args[a]]
                        if val == nil then
                            missing = true
                            break
                        end
                        callArgs[a] = val
                    end
                    if not missing then
                        local okIcon, res
                        if #callArgs == 1 then
                            okIcon, res = pcall(f, callArgs[1])
                        else
                            okIcon, res = pcall(f, callArgs[1], callArgs[2])
                        end
                        if okIcon and type(res) == "string" and res ~= ""
                           and res:lower():find("%.dds") then
                            -- NOTE: a "_rank0" suffix is NOT a failure/default.
                            -- Veterancy ranks are grouped into named tiers, and
                            -- _rank0 is the FIRST step of a tier. e.g. rank 81 is
                            -- "Brutal Marauder" -> s00_marauder_rank0.dds, 82-85
                            -- are Marauder I-IV. Do not filter these out.
                            info.icon = res
                            info.iconSource = entry.fn .. "(" .. table.concat(entry.args, ",") .. ")"
                            break
                        end
                    end
                end
            end
        end

        info.ok = true
    end)
    if not okCall then info.ok = false; info.why = info.why or "api call errored" end
    return info
end

--------------------------------------------------
-- RefreshRankLabel
--------------------------------------------------
function PvPUA:RefreshRankLabel()
    if not self.controls.infoRankNum then return end
    if self.savedVariables and self.savedVariables.barMode == "Veterancy" then
        local v = self:GetVeterancyInfo()
        -- ALWAYS write the label here. Previously this only called SetText when
        -- v.ok was true, so a failed veterancy lookup silently left the AP rank
        -- from the previous refresh on screen -- which looked exactly like
        -- "veterancy mode is showing my AP rank". Writing "--" on failure makes
        -- the failure visible instead of impersonating the AP value.
        if v.ok then
            self.controls.infoRankNum:SetText(tostring(v.rank))
        else
            self.controls.infoRankNum:SetText("--")
        end
        return
    end
    local rankNum  = ZO_CampaignAvARankRank and ZO_CampaignAvARankRank:GetText() or ""
    local rankName = ZO_CampaignAvARankName and ZO_CampaignAvARankName:GetText() or ""
    local grade    = rankName:match("GRADE %d+") or ""
    if rankNum ~= "" then
        self.controls.infoRankNum:SetText(rankNum .. (grade ~= "" and (" " .. grade) or ""))
    end
end

--------------------------------------------------
-- OnUiUpdate
--------------------------------------------------
function PvPUA:OnUiUpdate(itemsOfInterest)
    local rootControl = self.controls.TLW.rootControl

    rootControl:ClearAnchors()
    rootControl:SetAnchor(TOPLEFT, self.controls.TLW, TOPLEFT, 0, 20 + self.config.entryHeight * 2)

    if itemsOfInterest ~= nil then
        self:UpdateEntries(itemsOfInterest)
    else
        for i = 1, #self.state.visibleControls do
            self.state.visibleControls[i]:SetHidden(true)
        end
    end

    self.controls.creditLabel:SetHidden(false)
    self.creditCycle = (self.creditCycle + 1) % totalSteps
    self.controls.creditLabel:SetText(CREDIT_STATES[self.creditCycle])
    self.controls.infoBg:SetHidden(false)
    self.controls.infoRankIcon:SetHidden(false)
    self.controls.infoEmpIcon:SetHidden(false)
    self.controls.infoBarBg:SetHidden(false)
    self.controls.infoBar:SetHidden(false)
    self.controls.infoRankNum:SetHidden(false)
    self.controls.infoAPText:SetHidden(false)
    self.controls.infoKD:SetHidden(false)
    self.controls.scoreRow:SetHidden(false)

    local vetMode = self.savedVariables and self.savedVariables.barMode == "Veterancy"
    local vetIconShown = false
    PvPUA:RefreshRankLabel()

    if vetMode then
        local v = self:GetVeterancyInfo()
        -- Icon: GetVeterancyRankIcon(rank) resolves the tier art for the current
        -- veterancy rank. If it ever returns nothing (API renamed in a future
        -- update), fall back to the AP rank icon rather than an empty slot.
        if v.icon then
            self.controls.infoRankIcon:SetTexture(v.icon)
            self.controls.infoRankIcon:SetHidden(false)
            vetIconShown = true
        else
            local rankIconTex = ZO_CampaignAvARankIcon and ZO_CampaignAvARankIcon:GetTextureFileName() or ""
            if rankIconTex ~= "" then self.controls.infoRankIcon:SetTexture(rankIconTex) end
        end

        if v.ok and v.total and v.total > 0 then
            local pct = (v.progress / v.total) * 100
            if pct < 0 then pct = 0 elseif pct > 100 then pct = 100 end
            self.controls.infoBar:SetValue(pct)
            self.controls.infoAPText:SetText(
                ZO_CommaDelimitNumber(v.progress) .. " / " .. ZO_CommaDelimitNumber(v.total))
        else
            -- max rank, or the API had nothing for us
            self.controls.infoBar:SetValue(v.ok and 100 or 0)
            self.controls.infoAPText:SetText("")
        end
    else
        local currentXP = GetUnitAvARankPoints("player")
        local lastRankXP, nextRankXP = GetAvARankProgress(currentXP)
        local rankIconTex = ZO_CampaignAvARankIcon and ZO_CampaignAvARankIcon:GetTextureFileName() or ""
        if rankIconTex ~= "" then
            self.controls.infoRankIcon:SetTexture(rankIconTex)
        end
        if nextRankXP and nextRankXP > 0 then
            local apEarned   = currentXP - lastRankXP
            local apRequired = nextRankXP - lastRankXP
            local barPct     = apRequired > 0 and (apEarned / apRequired * 100) or 100
            self.controls.infoBar:SetValue(barPct)
            self.controls.infoAPText:SetText(
                ZO_CommaDelimitNumber(apEarned) .. " / " .. ZO_CommaDelimitNumber(apRequired))
        else
            self.controls.infoBar:SetValue(100)
            self.controls.infoAPText:SetText("")
        end
    end
    local pAlliance = GetUnitAlliance("player")
    local ac = GetColorForAlliance(pAlliance)
    self.controls.infoBar:SetColor(ac.r, ac.g, ac.b, 1)
    -- The AP rank icon is a monochrome glyph, so alliance-tinting it looks
    -- correct. A real veterancy icon is already coloured -- tinting it would
    -- wash it out -- so only tint when we are NOT showing a veterancy icon.
    if vetIconShown then
        self.controls.infoRankIcon:SetColor(1, 1, 1, 1)
    else
        self.controls.infoRankIcon:SetColor(ac.r, ac.g, ac.b, 1)
    end

    self:RefreshKDText()

    local campaignId = GetCurrentCampaignId()

    -- EMP icon color: grey when no emperor, alliance-colored when there is one
    if self.controls.infoEmpIcon then
        local empAlliance = GetCampaignEmperorInfo and GetCampaignEmperorInfo(campaignId) or 0
        if empAlliance and empAlliance ~= 0 then
            local ec = GetColorForAlliance(empAlliance)
            self.controls.infoEmpIcon:SetColor(ec.r, ec.g, ec.b, 1)
        else
            self.controls.infoEmpIcon:SetColor(0.35, 0.35, 0.35, 1)
        end
    end

    local secs = GetSecondsUntilCampaignScoreReevaluation(campaignId)
    local mins = math.floor(secs / 60)
    local s = secs - mins * 60
    self.controls.scoreTimer:SetText(string.format("%d:%02d", mins, s))
    local dcTotal = GetCampaignAllianceScore(campaignId, ALLIANCE_DAGGERFALL_COVENANT) or 0
    local adTotal = GetCampaignAllianceScore(campaignId, ALLIANCE_ALDMERI_DOMINION) or 0
    local epTotal = GetCampaignAllianceScore(campaignId, ALLIANCE_EBONHEART_PACT) or 0
    local dcPot = GetCampaignAlliancePotentialScore(campaignId, ALLIANCE_DAGGERFALL_COVENANT) or 0
    local adPot = GetCampaignAlliancePotentialScore(campaignId, ALLIANCE_ALDMERI_DOMINION) or 0
    local epPot = GetCampaignAlliancePotentialScore(campaignId, ALLIANCE_EBONHEART_PACT) or 0
    self.controls.scoreDCPts:SetText("[" .. dcTotal .. "] +" .. dcPot .. "p")
    self.controls.scoreADPts:SetText("[" .. adTotal .. "] +" .. adPot .. "p")
    self.controls.scoreEPPts:SetText("[" .. epTotal .. "] +" .. epPot .. "p")
    local dcColor = GetColorForAlliance(ALLIANCE_DAGGERFALL_COVENANT)
    local adColor = GetColorForAlliance(ALLIANCE_ALDMERI_DOMINION)
    local epColor = GetColorForAlliance(ALLIANCE_EBONHEART_PACT)
    self.controls.scoreDCIcon:SetColor(dcColor.r, dcColor.g, dcColor.b, 1)
    self.controls.scoreADIcon:SetColor(adColor.r, adColor.g, adColor.b, 1)
    self.controls.scoreEPIcon:SetColor(epColor.r, epColor.g, epColor.b, 1)


end

--------------------------------------------------
-- OnObjectiveControlState
--------------------------------------------------
function PvPUA:OnObjectiveControlState(eventCode, keepId, objectiveId, battlegroundContext, objectiveName, objectiveType, objectiveControlEvent, objectiveControlState, holdingAlliance, attackingAlliance, pinType)
    local keep = self:GetItemByKeepId(keepId)
    if keep ~= nil then
        local objectives = keep.objectives
        if objectives == nil then
            self:AddObjectives()
            objectives = keep.objectives
        end
        if objectives ~= nil then
            local objective = nil
            for i = 1, #objectives do
                if objectives[i].id == objectiveId then
                    objective = objectives[i]
                    break
                end
            end
            if objective ~= nil then
                objective.holdingAlliance = holdingAlliance
                if objective.holdingAlliance == 0 then
                    objective.holdingAlliance = attackingAlliance
                end
                objective.state = GetFlagStatePercent(objectiveControlState, keep.owningAlliance, holdingAlliance)
                AdjustKeepFlipping(keep)
            end
        end
    end
end

--------------------------------------------------
-- K:/D: text
--------------------------------------------------
-- One string, one label. Colour codes are inline so both halves keep their
-- own colour inside a single right-aligned control.
function PvPUA:RefreshKDText()
    local c = self.controls
    if not c or not c.infoKD then return end
    local gap = self.config.kdGap or " "
    c.infoKD:SetText("|cFF8C00K:|r " .. self.session.killingBlows
                     .. gap .. "|cCC2222D:|r " .. self.session.deaths)
end

--------------------------------------------------
-- CyroUpdateLoop
--------------------------------------------------
function PvPUA:CyroUpdateLoop()
    if IsInCyrodiilOrIC() == true then
        local itemsOfInterest = {}
        local gameTime = GetGameTimeMilliseconds()
        local function addItems(newItems)
            if newItems ~= nil then
                for i = 1, #newItems do
                    table.insert(itemsOfInterest, newItems[i])
                end
            end
        end
        addItems(self:UpdateItem(self.state.resources, gameTime))
        addItems(self:UpdateItem(self.state.keeps, gameTime))
        addItems(self:UpdateItem(self.state.outposts, gameTime))
        addItems(self:UpdateItem(self.state.villages, gameTime))
        addItems(self:UpdateItem(self.state.destructibles, gameTime))
        self:RefreshScrolls()
        self:UpdateScrollCounts()
        self:RefreshScrollTally()
        self:RefreshScrollCarriers()
        -- Show in List: Scroll Carriers. Gated here rather than in the keep
        -- filter above because carriers are pseudo-items with no keepType.
        if not (self.savedVariables and self.savedVariables.showScrollCarriers == false) then
            addItems(self:GetScrollCarrierItems())
        end
        -- Volendrung row. Same gating rationale as scroll carriers: it is a
        -- pseudo-item with no keepType, so the keep filters above can't reach it.
        self:RefreshVolendrungCarrier()
        if not (self.savedVariables and self.savedVariables.showVolendrungRow == false) then
            local volItem = self:GetVolendrungCarrierItem()
            if volItem then addItems({ volItem }) end
        end
        if #itemsOfInterest > 1 then
            table.sort(itemsOfInterest, SortItemsOfInterest)
        end
        self:OnUiUpdate(itemsOfInterest)
    end
end

--------------------------------------------------
-- Volendrung Events
--------------------------------------------------
-- Cache the hammer's display name and its artifactHolders key. The per-tick
-- poll has no daedricArtifactId, and EVENT_ARTIFACT_CONTROL_STATE stores the
-- holder under the artifact's NAME, so without this the name could never be
-- looked up and every row would fall back to the "Held" placeholder.
function PvPUA:CacheVolendrungName(daedricArtifactId)
    if not daedricArtifactId or not GetDaedricArtifactDisplayName then return end
    local nm = GetDaedricArtifactDisplayName(daedricArtifactId)
    if nm and nm ~= "" then
        self.volendrungName    = zo_strformat("<<1>>", nm)
    end
end

function PvPUA:OnVolendrungSpawned(eventCode, daedricArtifactId)
    self:CacheVolendrungName(daedricArtifactId)
    self.volendrung = {
        texture        = "/esoui/art/mappins/ava_daedricartifact_volendrung_neutral.dds",
        holderAlliance = 0,
        objectiveId    = nil,
        keepId         = nil,
        despawnAt      = nil,
        spawnedAt      = GetGameTimeMilliseconds(),
    }
    self:CyroUpdateLoop()
end

function PvPUA:OnVolendrungStateChanged(eventCode, objectiveKeepId, objectiveObjectiveId, battlegroundContext,
    objectiveControlEvent, objectiveControlState, holderAlliance, lastHolderAlliance, pinType,
    daedricArtifactId, lastObjectiveControlState)

    self:CacheVolendrungName(daedricArtifactId)

    if lastObjectiveControlState == OBJECTIVE_CONTROL_STATE_UNKNOWN
    and objectiveControlState ~= OBJECTIVE_CONTROL_STATE_UNKNOWN then
        self.volendrung = {
            texture        = GetVolendrungTexture(pinType),
            holderAlliance = GetVolendrungAlliance(pinType),
            objectiveId    = objectiveObjectiveId,
            keepId         = objectiveKeepId,
            despawnAt      = nil,
            spawnedAt      = (self.volendrung and self.volendrung.spawnedAt) or GetGameTimeMilliseconds(),
        }
        self:CyroUpdateLoop()
        return
    end

    if self.volendrung and objectiveControlState ~= OBJECTIVE_CONTROL_STATE_UNKNOWN then
        self.volendrung.texture        = GetVolendrungTexture(pinType)
        self.volendrung.holderAlliance = GetVolendrungAlliance(pinType)
        self.volendrung.objectiveId    = objectiveObjectiveId
        self.volendrung.keepId         = objectiveKeepId
        self.volendrung.despawnAt      = nil
        self:CyroUpdateLoop()
    end
end

--------------------------------------------------
-- Scroll State Event (parallel to Volendrung; does NOT touch Volendrung).
-- The per-tick poll in RefreshScrolls is the source of truth; this handler just
-- triggers an immediate repaint on scroll changes. Does NOT touch Volendrung.
--------------------------------------------------
function PvPUA:OnArtifactScrollStateChanged(...)
    -- The per-tick poll in RefreshScrolls is the source of truth; the event just
    -- triggers an immediate repaint so changes show without waiting for the tick.
    self:RefreshScrolls()
end

--------------------------------------------------
-- Volendrung Despawn Poll
--------------------------------------------------
function PvPUA:PollVolendrungDespawn()
    if not self.volendrung then return end

    if self.volendrung.despawnAt then
        if GetGameTimeMilliseconds() >= self.volendrung.despawnAt then
            self.volendrung = nil
            self:CyroUpdateLoop()
        end
        return
    end

    if self.volendrung.objectiveId and self.volendrung.keepId then
        local objectiveState = select(3, GetObjectiveInfo(
            self.volendrung.keepId,
            self.volendrung.objectiveId,
            BGQUERY_LOCAL
        ))
        if objectiveState == OBJECTIVE_CONTROL_STATE_UNKNOWN or objectiveState == nil then
            self.volendrung.despawnAt = GetGameTimeMilliseconds() + VOLENDRUNG_DESPAWN_GRACE
        end
    end
end

--------------------------------------------------
function PvPUA:RefreshStatLabels()
    local c = self.controls
    if not c.infoKD then return end
    self:RefreshKDText()
    c.infoKD:SetHidden(false)
end

--------------------------------------------------
-- UpdateKAD
--------------------------------------------------
local function UpdateKAD()
    if PvPUA.controls and PvPUA.controls.infoKD then
        PvPUA:RefreshKDText()
    end
end

--------------------------------------------------
-- OnPlayerActivated
--------------------------------------------------
-- Re-evaluates whether we're in Cyrodiil/IC and registers/unregisters the Cyro
-- event set + list visibility accordingly. Pulled out of OnPlayerActivated so
-- it can also run off EVENT_ZONE_CHANGED, which fires earlier than
-- EVENT_PLAYER_ACTIVATED (e.g. walking across a zone line with no loading
-- screen at all) -- that gap was why the list could get stuck showing after
-- leaving Cyrodiil until a full /reloadui or another zone load.
function PvPUA:ZoneCheck()
    if IsInCyrodiilOrIC() == true then
        if self.initializedItems == false then
            local hadVolendrung = self.volendrung
            self:InitState(hadVolendrung)
            self:ResetObjectives()
            self.initializedItems = true
        end
        if self.registeredCyroEvents == false then
            EVENT_MANAGER:RegisterForEvent(PvPUA.name, EVENT_OBJECTIVE_CONTROL_STATE,
                function(...) PvPUA:OnObjectiveControlState(...) end)
            EVENT_MANAGER:RegisterForEvent(PvPUA.name, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED,
                function(...) PvPUA:OnVolendrungSpawned(...) end)
            EVENT_MANAGER:RegisterForEvent(PvPUA.name, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED,
                function(...) PvPUA:OnVolendrungStateChanged(...) end)
            EVENT_MANAGER:RegisterForEvent(PvPUA.name, EVENT_ARTIFACT_SCROLL_STATE_CHANGED,
                function(...) PvPUA:OnArtifactScrollStateChanged(...) end)
            EVENT_MANAGER:RegisterForEvent(PvPUA.name .. "_ArtifactCtrl", EVENT_ARTIFACT_CONTROL_STATE,
                function(...) PvPUA:OnArtifactControlState(...) end)
            -- Veterancy progress: refresh the rank label the moment it ticks up.
            if EVENT_REWARD_TRACK_PROGRESS_GAINED then
                EVENT_MANAGER:RegisterForEvent(PvPUA.name .. "_VetTrack", EVENT_REWARD_TRACK_PROGRESS_GAINED,
                    function(_, trackType)
                        if trackType == REWARD_TRACK_TYPE_AVA_VETERANCY then
                            PvPUA:RefreshRankLabel()
                        end
                    end)
            end
            pvpRecentKBs = { count = 0 }
            EVENT_MANAGER:RegisterForUpdate(PvPUA.name, PvPUA.constants.updateInterval,
                function()
                    -- Wrapped in pcall: if a stray error fires mid-travel (stale
                    -- zone/keep data while the game hasn't fully caught up yet),
                    -- this stops the tick from repeating every second instead of
                    -- spamming an error each interval until the next full load.
                    local ok = pcall(function()
                        PvPUA:CyroUpdateLoop()
                        PvPUA:PollVolendrungDespawn()
                    end)
                    if not ok then
                        EVENT_MANAGER:UnregisterForUpdate(PvPUA.name)
                        PvPUA.registeredCyroEvents = false
                    end
                end)
            self.registeredCyroEvents = true
        end
    else
        if self.registeredCyroEvents == true then
            EVENT_MANAGER:UnregisterForEvent(PvPUA.name, EVENT_OBJECTIVE_CONTROL_STATE)
            EVENT_MANAGER:UnregisterForEvent(PvPUA.name, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_SPAWNED_BUT_NOT_REVEALED)
            EVENT_MANAGER:UnregisterForEvent(PvPUA.name, EVENT_DAEDRIC_ARTIFACT_OBJECTIVE_STATE_CHANGED)
            EVENT_MANAGER:UnregisterForEvent(PvPUA.name, EVENT_ARTIFACT_SCROLL_STATE_CHANGED)
            EVENT_MANAGER:UnregisterForUpdate(PvPUA.name)
            pvpRecentKBs  = { count = 0 }
            self.registeredCyroEvents = false
        end
        self.initializedItems = false
        self.volendrung = nil
        self.volendrungName    = nil
        self.controls.TLW:SetHidden(true)
        self.controls.creditLabel:SetHidden(true)
        self.controls.scoreRow:SetHidden(true)
        self.controls.infoBg:SetHidden(true)
        self.controls.infoRankIcon:SetHidden(true)
        self.controls.infoEmpIcon:SetHidden(true)
        self.controls.infoBarBg:SetHidden(true)
        self.controls.infoBar:SetHidden(true)
        self.controls.infoRankNum:SetHidden(true)
        self.controls.infoAPText:SetHidden(true)
        self.controls.infoKD:SetHidden(true)
    end
    PvPUA:UpdateHUDScenes()
end

function PvPUA:OnPlayerActivated()
    PI.StartPolling()
    pvpPlayerName = zo_strformat("<<1>>", GetUnitName("player"))

    self:ZoneCheck()

    zo_callLater(function() PvPUA:UpdateHUDScenes() end, 500)
    zo_callLater(function() PvPUA:RefreshRankLabel() end, 2000)
    if PvPUA_RefreshRespawnButtons then PvPUA_RefreshRespawnButtons() end
end

--------------------------------------------------
-- Auto Invite
--------------------------------------------------
PvPUA.aiListening = false

local function AIEcho(msg)
    CHAT_ROUTER:AddSystemMessage("|cFFFFFF[|r|c2A6FFFP|r|cE6C800v|r|cCC2222P|r|cFF8800 UA!|r|cFFFFFF]|r |cE6C800" .. msg)
end

local function AIEchoRed(msg)
    CHAT_ROUTER:AddSystemMessage("|cFFFFFF[|r|c2A6FFFP|r|cE6C800v|r|cCC2222P|r|cFF8800 UA!|r|cFFFFFF]|r |cCC2222" .. msg)
end

-- Map a guild chat channel to its guild slot (1-5); returns nil if not a guild channel.
local function AIGuildChannelToIndex(messageType)
    if messageType == CHAT_CHANNEL_GUILD_1 then return 1 end
    if messageType == CHAT_CHANNEL_GUILD_2 then return 2 end
    if messageType == CHAT_CHANNEL_GUILD_3 then return 3 end
    if messageType == CHAT_CHANNEL_GUILD_4 then return 4 end
    if messageType == CHAT_CHANNEL_GUILD_5 then return 5 end
    return nil
end

-- True if the channel is any zone chat variant.
local function AIIsZoneChannel(messageType)
    if messageType == CHAT_CHANNEL_ZONE then return true end
    if messageType == CHAT_CHANNEL_ZONE_LANGUAGE_1 then return true end
    if messageType == CHAT_CHANNEL_ZONE_LANGUAGE_2 then return true end
    if messageType == CHAT_CHANNEL_ZONE_LANGUAGE_3 then return true end
    return false
end

-- Resolve the sender to an invitable character name.
-- Whispers already carry a character name. Zone/guild senders arrive as an
-- @account name, so we look up their character. If the account setting prefers
-- @UserID, GroupInviteByName accepts the @account directly.
local function AIResolveInvitee(messageType, from)
    local raw = from or ""

    -- Strip ESO's grammatical-gender suffix (^M / ^F / ^Mx etc.) from any name.
    local function strip(n) return (n or ""):gsub("%^.+", "") end

    if ZO_ShouldPreferUserId and ZO_ShouldPreferUserId() then
        return strip(raw)
    end

    -- Whisper: name is already a character name.
    if messageType == CHAT_CHANNEL_WHISPER then
        return strip(raw)
    end

    local gIdx = AIGuildChannelToIndex(messageType)
    if gIdx then
        local guildId = GetGuildId(gIdx)
        if guildId and guildId > 0 then
            for i = 1, GetNumGuildMembers(guildId) do
                local acct = GetGuildMemberInfo(guildId, i)
                if acct == raw then
                    local hasChar, charName = GetGuildMemberCharacterInfo(guildId, i)
                    if hasChar then return strip(charName) end
                    return ""
                end
            end
        end
        return strip(raw)
    end

    -- Zone: try friends, then all guild rosters, to turn @account into a character.
    -- If that fails (a stranger), fall back to the raw name -- ESO will invite by
    -- @UserID when the account allows it, otherwise it silently no-ops.
    for i = 1, GetNumFriends() do
        local hasChar, cName = GetFriendCharacterInfo(i)
        local acct = GetFriendInfo(i)
        if acct == raw and hasChar then
            return strip(cName)
        end
    end
    for g = 1, 5 do
        local guildId = GetGuildId(g)
        if guildId and guildId > 0 then
            for i = 1, GetNumGuildMembers(guildId) do
                local acct = GetGuildMemberInfo(guildId, i)
                if acct == raw then
                    local hasChar, charName = GetGuildMemberCharacterInfo(guildId, i)
                    if hasChar then return strip(charName) end
                end
            end
        end
    end
    return strip(raw)
end

-- Parse the comma-separated Keyword box into a list of lowercased, trimmed words.
local function AIKeywordList()
    local raw = PvPUA.charVariables.aiKeyword
    if not raw or raw == "" then return nil end
    local list = {}
    for word in string.gmatch(raw, "[^,]+") do
        word = word:gsub("^%s+", ""):gsub("%s+$", "")  -- trim
        if word ~= "" then
            list[#list + 1] = string.lower(word)
        end
    end
    if #list == 0 then return nil end
    return list
end

-- Cached once at first use: our own character and account name, for the
-- self-invite check below. GetUnitName/GetUnitDisplayName are safe to call
-- lazily here since the chat callback only runs well after player activation.
local aiSelfName, aiSelfAccount
local function AIIsSelf(from, fromDisplayName)
    if not aiSelfName then
        aiSelfName = (GetUnitName("player") or ""):gsub("%^.+", "")
        aiSelfAccount = GetUnitDisplayName("player") or ""
    end
    local n = (from or ""):gsub("%^.+", "")
    if n ~= "" and n == aiSelfName then return true end
    if fromDisplayName and fromDisplayName ~= "" and fromDisplayName == aiSelfAccount then return true end
    return false
end

local function AIOnWhisper(_, messageType, from, message, isCustomerService, fromDisplayName)
    local keywords = AIKeywordList()
    if not keywords then return end

    -- Never invite ourselves: our own messages come back through this callback.
    if AIIsSelf(from, fromDisplayName) then return end

    -- Channel gate: each channel has its own toggle.
    local allowed = false
    if messageType == CHAT_CHANNEL_WHISPER then
        allowed = PvPUA.charVariables.aiWhisper
    elseif messageType == CHAT_CHANNEL_SAY then
        allowed = PvPUA.charVariables.aiSay
    elseif AIIsZoneChannel(messageType) then
        allowed = PvPUA.charVariables.aiZone
    else
        local gIdx = AIGuildChannelToIndex(messageType)
        if gIdx then
            -- Per-guild toggle, keyed by guild slot (1-5). Stable across guild
            -- name changes since it doesn't depend on the name string.
            local toggles = PvPUA.charVariables.aiGuildToggles
            if toggles and toggles[gIdx] then
                allowed = true
            end
        end
    end
    if not allowed then return end

    -- Match if the whole message equals any keyword exactly (case-insensitive).
    local lowerMsg = string.lower(message)
    local matched = false
    for _, kw in ipairs(keywords) do
        if lowerMsg == kw then
            matched = true
            break
        end
    end
    if not matched then return end

    if GetGroupSize() >= 12 then
        AIEcho("Group is full. |cCC2222Pausing|r auto invite.")
        PvPUA:AIStop(true)
        return
    end

    local name = AIResolveInvitee(messageType, from)
    if not name or name == "" then return end
    -- Final safety: strip any leftover gender suffix (^M/^F/^Mx) before use.
    name = name:gsub("%^.+", "")
    if name == "" then return end

    -- Display the @account on every channel; the invite still goes to the
    -- resolved character name, which works even when the target account
    -- disallows @UserID invites.
    local shown = fromDisplayName
    if not shown or shown == "" then shown = name end

    AIEcho("Auto Inviting |c00FF00" .. shown .. "|r")
    GroupInviteByName(name)
end

-- ============================================================================
-- Cyrodiil respawn buttons (nearest keep / nearest camp) on the death screen.
-- Always on in Cyrodiil only. Uses the game's Death binding layer so the
-- keybinds fire while dead; buttons are drawn above the native AvA revive UI.
-- ============================================================================

-- Find the nearest keep/town/outpost the player can respawn at. Returns keepId or nil.
local function RSFindNearestKeep()
    local selfX, selfY = GetMapPlayerPosition("player")
    local bestId, bestDist
    for i = 1, GetNumKeeps() do
        local keepId = GetKeepKeysByIndex(i)
        if CanRespawnAtKeep(keepId) then
            local _, kx, ky = GetKeepPinInfo(keepId, BGQUERY_LOCAL)
            if kx ~= 0 and ky ~= 0 then
                local dist = zo_distance3D(selfX, selfY, 0, kx, ky, 0)
                if not bestDist or dist < bestDist then
                    bestId, bestDist = keepId, dist
                end
            end
        end
    end
    return bestId
end

-- Find the nearest forward camp actually within its respawn radius.
-- Deliberately does NOT filter on the game's "usable" flag here -- per the
-- official ZOS client source, that flag is what gates whether
-- RespawnAtForwardCamp() itself is allowed to run, which folds in the
-- player's own personal respawn cooldown. Filtering on it here meant the
-- whole button vanished during your own cooldown even with a camp genuinely
-- in range, instead of showing with a countdown. Returns campIndex or nil.
local function RSFindNearestCamp()
    if GetNumForwardCamps(BGQUERY_LOCAL) == 0 then return nil end
    local selfX, selfY = GetMapPlayerPosition("player")
    local bestIndex, bestDist
    for i = 1, GetNumForwardCamps(BGQUERY_LOCAL) do
        local _, cx, cy, radius = GetForwardCampPinInfo(BGQUERY_LOCAL, i)
        if cx ~= 0 and cy ~= 0 and radius and radius > 0 then
            local dist = zo_distance3D(selfX, selfY, 0, cx, cy, 0)
            if dist < radius and (not bestDist or dist < bestDist) then
                bestIndex, bestDist = i, dist
            end
        end
    end
    return bestIndex
end

-- Returns " m:ss" (with leading space, ZOS-style formatting) if the player's
-- personal forward camp respawn cooldown is still active, or "" otherwise.
-- Uses the same official API ZOS's own map UI reads for this timer
-- (GetNextForwardCampRespawnTime), so it stays accurate without needing the
-- map to be open. Wrapped in pcall: if anything about this lookup fails for
-- any reason, we fall back to "" (button shows exactly as before this
-- feature existed) rather than letting an error here take the whole
-- respawn button down with it.
local function RSCampCooldownText()
    local ok, result = pcall(function()
        if not GetNextForwardCampRespawnTime then return "" end
        local nextRespawnMS = GetNextForwardCampRespawnTime()
        if not nextRespawnMS or nextRespawnMS == 0 then return "" end
        local remainingMS = nextRespawnMS - GetGameTimeMilliseconds()
        if remainingMS <= 0 then return "" end
        local totalSeconds = math.ceil(remainingMS / 1000)
        local minutes = math.floor(totalSeconds / 60)
        local seconds = totalSeconds % 60
        return string.format(" |cB4B2A9%d:%02d|r", minutes, seconds)
    end)
    if ok then return result end
    return ""
end

local function RSRespawnAtNearestKeep()
    local keepId = RSFindNearestKeep()
    if keepId then RespawnAtKeep(keepId) end
end

local function RSRespawnAtNearestCamp()
    local campIndex = RSFindNearestCamp()
    if campIndex then RespawnAtForwardCamp(campIndex) end
end

-- Apply the game's platform-appropriate death-button styling (correct font/size
-- on both keyboard and gamepad/console). Done once per button.
local function RSStyleButton(button)
    if button.rsStyled then return end
    button.rsStyled = true
    local template = ZO_GetPlatformTemplate("ZO_DeathKeybindButton")
    if template then
        ApplyTemplateToControl(button, template)
    end
    button:SetNormalTextColor(IsInGamepadPreferredMode() and ZO_SELECTED_TEXT or ZO_NORMAL_TEXT)
end

-- Refresh the two death buttons based on what's currently available.
-- Button1 = camp, Button2 = keep (matching the binding layer inheritance).
local function RSSetupDeathButtons()
    if not IsInCyrodiil() then return end

    local btnCamp = PvPUA_Death_ButtonsButton1
    local btnKeep = PvPUA_Death_ButtonsButton2
    if not btnCamp or not btnKeep then return end

    RSStyleButton(btnCamp)
    RSStyleButton(btnKeep)

    local aColor = GetUnitAlliance("player") == ALLIANCE_DAGGERFALL_COVENANT and "2A6FFF"
                or GetUnitAlliance("player") == ALLIANCE_ALDMERI_DOMINION    and "E6C800"
                or GetUnitAlliance("player") == ALLIANCE_EBONHEART_PACT      and "CC2222" or "FFFFFF"

    -- Suffix: [PvP UA!] with brand colors -- [ white, P blue, v yellow, P red, " UA!" orange, ] white
    local suffix = " |cFFFFFF[|r|c2A6FFFP|r|cE6C800v|r|cCC2222P|r|cFF8800 UA!|r|cFFFFFF]|r"

    -- Camp button
    local campIndex = RSFindNearestCamp()
    if campIndex then
        local cooldownText = RSCampCooldownText()
        btnCamp:SetKeybind("PVPUA_RESPAWN_AT_CAMP")
        btnCamp:SetText("Respawn at |c" .. aColor .. "Forward Camp|r" .. cooldownText .. suffix)
        btnCamp:SetCallback(RSRespawnAtNearestCamp)
        btnCamp:SetEnabled(true)
        btnCamp:SetKeybindEnabled(true)
        btnCamp:SetHidden(false)
    else
        btnCamp:SetKeybind(nil)
        btnCamp:SetText("")
        btnCamp:SetCallback(nil)
        btnCamp:SetHidden(true)
    end

    -- Keep button
    local keepId = RSFindNearestKeep()
    if keepId then
        local keepName = GetKeepName(keepId) or "Keep"
        btnKeep:SetKeybind("PVPUA_RESPAWN_AT_KEEP")
        btnKeep:SetText("Respawn at |c" .. aColor .. keepName .. "|r" .. suffix)
        btnKeep:SetCallback(RSRespawnAtNearestKeep)
        btnKeep:SetEnabled(true)
        btnKeep:SetKeybindEnabled(true)
        btnKeep:SetHidden(false)
    else
        btnKeep:SetKeybind(nil)
        btnKeep:SetText("")
        btnKeep:SetCallback(nil)
        btnKeep:SetHidden(true)
    end
end

local rsButtonsShown = false

-- The buttons should be visible only when ALL of: in Cyrodiil, dead, and the
-- current scene is the HUD (not a menu/map/inventory). We drive this explicitly
-- rather than via a HUD fragment, because a fragment would show the control
-- whenever the HUD is up -- including while alive.
local function RSShouldShow()
    if not IsInCyrodiil() then return false end
    if not IsUnitDead("player") then return false end
    local name = SCENE_MANAGER and SCENE_MANAGER:GetCurrentSceneName()
    return name == "hud" or name == "hudui"
end

local function RSApplyVisibility()
    local control = PvPUA_Death_Buttons
    if not control then return end

    if RSShouldShow() then
        control:SetHidden(false)
        RSSetupDeathButtons()
        if not rsButtonsShown then
            rsButtonsShown = true
            control:SetHandler("OnUpdate", function() RSSetupDeathButtons() end)
        end
    else
        control:SetHidden(true)
        if rsButtonsShown then
            rsButtonsShown = false
            control:SetHandler("OnUpdate", nil)
        end
    end
end

-- Hook scene changes once so opening/closing a menu or the map re-evaluates.
local rsSceneHooked = false
local function RSHookScenes()
    if rsSceneHooked or not SCENE_MANAGER then return end
    rsSceneHooked = true
    SCENE_MANAGER:RegisterCallback("SceneStateChanged", function()
        RSApplyVisibility()
    end)
end

-- Called on death/alive/activated to re-evaluate visibility.
local function RSOnDeathStateChanged()
    RSHookScenes()
    RSApplyVisibility()
end

-- Global entry point so functions defined earlier in the file (and any external
-- caller) can trigger a death-state refresh.
function PvPUA_RefreshRespawnButtons()
    RSOnDeathStateChanged()
end

-- True when we're allowed to send invites: either solo (about to form a group)
-- or the leader of the group we're in. GetGroupSize() returns 0 or 1 when solo,
-- and IsUnitGroupLeader is false in that case, so solo must be treated as
-- allowed or the feature would disable itself exactly when it's most useful.
local function AICanInvite()
    if GetGroupSize() > 1 and not IsUnitGroupLeader("player") then
        return false
    end
    return true
end

-- Fires on any leadership change, and stays registered while paused so a
-- leader-paused state can recover. AIStart/AIStop only manage the 1s tick,
-- which is torn down while paused -- so polling alone could never resume us.
local function AIOnLeaderUpdate()
    if not PvPUA.charVariables.aiEnabled then return end

    if not AICanInvite() then
        if PvPUA.aiListening then
            AIEcho("Not group leader. |cCC2222Pausing|r auto invite.")
            PvPUA:AIStop(true)
        end
        return
    end

    -- We can invite again. Only resume if we were paused, and not if the group
    -- is still full (the group-full pause owns that case).
    if PvPUA.aiListening then return end
    if GetGroupSize() >= 12 then return end

    local kw = PvPUA.charVariables.aiKeyword or ""
    if GetGroupSize() > 1 then
        AIEcho("You are now group leader. Listening again for keyword(s): |c00FF00" .. kw .. "|r")
    else
        AIEcho("Now solo. Listening again for keyword(s): |c00FF00" .. kw .. "|r")
    end
    PvPUA:AIStart(true)
end

local function AIOnGroupMemberLeft()
    if not PvPUA.charVariables.aiEnabled then return end
    if PvPUA.aiListening then return end
    -- Leaving members can drop us to solo, which is a leader-state change too.
    -- Let the leader handler own that message so we don't print both.
    if not AICanInvite() then return end
    if GetGroupSize() <= 1 then
        AIOnLeaderUpdate()
        return
    end
    AIEcho("Spot opened. Listening again for keyword(s): |c00FF00" .. (PvPUA.charVariables.aiKeyword or "") .. "|r")
    PvPUA:AIStart(true)
end

-- Polling backstop: the chat callback only checks group size when a keyword
-- arrives, so a manual invite that fills the group would otherwise go unnoticed.
-- This 1s tick catches the group hitting 12 by any means while listening, then
-- pauses via AIStop(true) so the existing spot-opened restart
-- (EVENT_GROUP_MEMBER_LEFT) still fires. Registered only while listening (in
-- AIStart) and torn down in AIStop, so it never polls while paused or disabled.
-- Also backstops the leader check in case EVENT_LEADER_UPDATE is ever missed.
local function AICheckGroupFull()
    if not PvPUA.aiListening then return end
    if GetGroupSize() >= 12 then
        AIEcho("Group is full. |cCC2222Pausing|r auto invite.")
        PvPUA:AIStop(true)
        return
    end
    if not AICanInvite() then
        AIEcho("Not group leader. |cCC2222Pausing|r auto invite.")
        PvPUA:AIStop(true)
    end
end

-- ============================================================================
-- Auto-kick offline group members.
-- Independent of the AutoInvite listening state: it runs whenever the setting
-- is on and we're the group leader, since a disconnected member should be
-- cleared out whether or not we're currently recruiting. Silent by design --
-- no chat output when someone is kicked.
-- ============================================================================
PvPUA.aiKickTable = {}

-- Snapshot who's currently offline. Called on login/zone so members who went
-- offline while we weren't watching still get a start time.
local function AIKickScanOffline()
    local now = GetTimeStamp()
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        if tag and tag ~= "" and not IsUnitOnline(tag) then
            local n = GetUnitName(tag)
            if n then n = n:gsub("%^.+", "") end
            if n and n ~= "" and PvPUA.aiKickTable[n] == nil then
                PvPUA.aiKickTable[n] = now
            end
        end
    end
end

-- GroupKick needs a unit tag, so resolve the stored name back to one. The
-- stored key is suffix-stripped, so strip the live name before comparing.
local function AIKickByName(name)
    PvPUA.aiKickTable[name] = nil
    for i = 1, GetGroupSize() do
        local tag = GetGroupUnitTagByIndex(i)
        local tagName = GetUnitName(tag)
        if tagName then tagName = tagName:gsub("%^.+", "") end
        if tag and tag ~= "" and tagName == name then
            local mins = PvPUA.charVariables.aiKickMinutes or 5
            -- Prefer the @account for the message; fall back to the character
            -- name if the offline member's display name comes back empty.
            local shown = GetUnitDisplayName(tag)
            if not shown or shown == "" then shown = name end
            AIEcho("|cCC2222Kicked|r |c00FF00" .. shown .. "|r — offline " .. mins .. " min.")
            GroupKick(tag)
            return
        end
    end
end

-- Connection status changes: start the timer on disconnect, clear on reconnect.
local function AIOnConnectedStatus(_, unitTag, isOnline)
    if not unitTag or unitTag == "" then return end
    local n = GetUnitName(unitTag)
    if not n or n == "" then return end
    -- Canonicalize: GetUnitName can return the gender-suffixed form (Bob^Mx)
    -- on one event and the bare form (Bob) on another. Keying the table by the
    -- raw value would let the same member occupy two slots, which double-fires
    -- the warning below and leaves a stale timer behind. Strip the suffix so
    -- one member is always one key.
    n = n:gsub("%^.+", "")
    if n == "" then return end
    if isOnline then
        PvPUA.aiKickTable[n] = nil
    elseif PvPUA.aiKickTable[n] == nil then
        PvPUA.aiKickTable[n] = GetTimeStamp()
        -- Warn once, only when we're the leader who could actually kick. This
        -- branch runs only on a fresh timer, so a flickering connection that
        -- re-sends "offline" won't re-print (the entry is already set).
        if PvPUA.charVariables.aiKickOffline
           and GetGroupSize() > 1
           and IsUnitGroupLeader("player") then
            local mins = PvPUA.charVariables.aiKickMinutes or 5
            local shown = GetUnitDisplayName(unitTag)
            if not shown or shown == "" then shown = n end
            AIEcho("|c00FF00" .. shown .. "|r went offline. |cCC2222Kicking|r in " .. mins .. " min.")
        end
    end
end

-- Clear departed members so a rejoin starts a fresh timer.
-- EVENT_GROUP_MEMBER_LEFT signature:
--   (eventCode, characterName, reason, isLocalPlayer, isLeader, displayName)
local function AIOnKickGroupLeft(_, characterName, _, isLocalPlayer)
    if isLocalPlayer then
        PvPUA.aiKickTable = {}
        return
    end
    if type(characterName) == "string" and characterName ~= "" then
        PvPUA.aiKickTable[(characterName:gsub("%^.+", ""))] = nil
    end
end

-- 1s tick. Kicking requires leadership, so bail early when we're not leader --
-- GroupKick would silently fail and we'd churn the table for nothing.
local function AIKickCheck()
    if not PvPUA.charVariables.aiKickOffline then return end
    if GetGroupSize() <= 1 then return end
    if not IsUnitGroupLeader("player") then return end

    local limit = (PvPUA.charVariables.aiKickMinutes or 5) * 60
    local now = GetTimeStamp()
    for n, t in pairs(PvPUA.aiKickTable) do
        if GetDiffBetweenTimeStamps(now, t) > limit then
            AIKickByName(n)
        end
    end
end

function PvPUA:AIKickStart()
    EVENT_MANAGER:RegisterForEvent(
        PvPUA.name .. "_AIKickStatus",
        EVENT_GROUP_MEMBER_CONNECTED_STATUS,
        AIOnConnectedStatus
    )
    EVENT_MANAGER:RegisterForEvent(
        PvPUA.name .. "_AIKickLeft",
        EVENT_GROUP_MEMBER_LEFT,
        AIOnKickGroupLeft
    )
    EVENT_MANAGER:RegisterForUpdate(PvPUA.name .. "_AIKickTick", 1000, AIKickCheck)
    AIKickScanOffline()
end

function PvPUA:AIKickStop()
    EVENT_MANAGER:UnregisterForEvent(PvPUA.name .. "_AIKickStatus", EVENT_GROUP_MEMBER_CONNECTED_STATUS)
    EVENT_MANAGER:UnregisterForEvent(PvPUA.name .. "_AIKickLeft", EVENT_GROUP_MEMBER_LEFT)
    EVENT_MANAGER:UnregisterForUpdate(PvPUA.name .. "_AIKickTick")
    PvPUA.aiKickTable = {}
end

function PvPUA:AIStart(internal)
    -- Turning the feature on while grouped and not leader: record the enabled
    -- state and print the pause notice, but don't actually listen. The leader
    -- handler will start us for real once we can invite.
    if not AICanInvite() then
        if not internal then
            PvPUA.charVariables.aiEnabled = true
            AIEcho("Not group leader. |cCC2222Pausing|r auto invite.")
        end
        return
    end

    EVENT_MANAGER:RegisterForEvent(
        PvPUA.name .. "_AI",
        EVENT_CHAT_MESSAGE_CHANNEL,
        AIOnWhisper
    )
    EVENT_MANAGER:RegisterForUpdate(PvPUA.name .. "_AIFullCheck", 1000, AICheckGroupFull)
    PvPUA.aiListening = true
    if not internal then
        PvPUA.charVariables.aiEnabled = true
        AIEcho("Listening for keyword(s): |c00FF00" .. (PvPUA.charVariables.aiKeyword or "") .. "|r")
    end
end

function PvPUA:AIStop(internal)
    EVENT_MANAGER:UnregisterForEvent(PvPUA.name .. "_AI", EVENT_CHAT_MESSAGE_CHANNEL)
    EVENT_MANAGER:UnregisterForUpdate(PvPUA.name .. "_AIFullCheck")
    PvPUA.aiListening = false
    if not internal then
        PvPUA.charVariables.aiEnabled = false
        EVENT_MANAGER:UnregisterForEvent(PvPUA.name .. "_AIGroup", EVENT_GROUP_MEMBER_LEFT)
        EVENT_MANAGER:UnregisterForEvent(PvPUA.name .. "_AILeader", EVENT_LEADER_UPDATE)
        AIEchoRed("|cE6C800Auto invite |cCC2222disabled|r.")
    end
end

--------------------------------------------------
-- Settings
--------------------------------------------------
-- Live list of the player's current guild names for the AutoInvite dropdown.
-- Rebuilt whenever the settings panel opens (guilds aren't loaded at addon-load
-- and can change as the player joins/leaves).
PvPUA.AIGuildChoices = {}

function PvPUA:AIRefreshGuildChoices()
    local choices = PvPUA.AIGuildChoices
    for i = #choices, 1, -1 do choices[i] = nil end
    for i = 1, 5 do
        local guildId = GetGuildId(i)
        if guildId and guildId > 0 then
            local gName = GetGuildName(guildId)
            if gName and gName ~= "" then
                choices[#choices + 1] = gName
            end
        end
    end

    -- One-time migration from the old single-guild dropdown to per-guild
    -- toggles. Must read the OLD selection before the clearing logic below can
    -- wipe aiGuildName, and must only mark itself done once guild data is
    -- actually loaded -- otherwise an early panel-open (before guilds load on
    -- console) would fail the name match and permanently skip the carry-over.
    if not PvPUA.charVariables.aiGuildMigrated then
        PvPUA.charVariables.aiGuildToggles = PvPUA.charVariables.aiGuildToggles or {}
        -- Is guild data available yet? If we're in at least one guild slot, yes.
        local guildDataReady = false
        for i = 1, 5 do
            local id = GetGuildId(i)
            if id and id > 0 then guildDataReady = true break end
        end
        if guildDataReady then
            if PvPUA.charVariables.aiGuild and PvPUA.charVariables.aiGuildName ~= "" then
                for i = 1, 5 do
                    local guildId = GetGuildId(i)
                    if guildId and guildId > 0
                       and GetGuildName(guildId) == PvPUA.charVariables.aiGuildName then
                        PvPUA.charVariables.aiGuildToggles[i] = true
                        break
                    end
                end
            end
            -- Only now is the migration trustworthy; mark it done.
            PvPUA.charVariables.aiGuildMigrated = true
        end
    end

    -- If the stored selection is no longer one of the current guilds, clear it.
    -- (Runs AFTER migration so it can't wipe the source value first.)
    local sel2 = PvPUA.charVariables.aiGuildName
    if sel2 and sel2 ~= "" then
        local found2 = false
        for _, n in ipairs(PvPUA.AIGuildChoices) do if n == sel2 then found2 = true break end end
        if not found2 then PvPUA.charVariables.aiGuildName = "" end
    end
end

function PvPUA:CreateSettings()
    local LAM = LibAddonMenu2
    self:AIRefreshGuildChoices()
    local panel = LAM:RegisterAddonPanel("PvPUA_Settings", {
        type = "panel", name = "PvPUA", displayName = "PvPUA",
        author = "user562", version = "4.5", registerForRefresh = true,
    })
    if panel then
        CALLBACK_MANAGER:RegisterCallback("LAM-PanelOpened", function(openedPanel)
            if openedPanel == panel then
                PvPUA:AIRefreshGuildChoices()
            end
        end)
    end
    LAM:RegisterOptionControls("PvPUA_Settings", {
        { type = "submenu",
          name = "|c2A6FFFAppearance|r",
          controls = {
        { type = "checkbox",
          name = "Show List Now",
          getFunc = function() return self.showInMenu end,
          setFunc = function(v)
              self.showInMenu = v
              self:UpdateHUDScenes()
          end },
        { type = "slider", name = "Size", min = 80, max = 150, step = 5,
          getFunc = function() return math.floor((self.savedVariables.uiScale or 1.0) * 100 + 0.5) end,
          setFunc = function(v) self.savedVariables.uiScale = v / 100; self:ApplyScale() end },
        { type = "slider", name = "Horizontal Position", min = 0, max = 3000, step = 5,
          getFunc = function() return self.savedVariables.posX end,
          setFunc = function(v) self.savedVariables.posX = v; self:ApplyPosition() end },
        { type = "slider", name = "Vertical Position", min = 0, max = 3000, step = 5,
          getFunc = function() return self.savedVariables.posY end,
          setFunc = function(v) self.savedVariables.posY = v; self:ApplyPosition() end },
        { type = "divider" },
        { type = "description",
          title = "Rank Display",
          text = "" },
        { type = "dropdown", name = "",
          choices = { "AP Progress Bar", "Veterancy Progress Bar" },
          getFunc = function()
              return (self.savedVariables.barMode == "Veterancy")
                  and "Veterancy Progress Bar" or "AP Progress Bar"
          end,
          setFunc = function(val)
              self.savedVariables.barMode = (val == "Veterancy Progress Bar") and "Veterancy" or "AP"
              self:RefreshRankLabel()
          end },
        { type = "divider" },
        { type = "description",
          title = "Background Color",
          text = "" },
        { type = "dropdown", name = "",
          choices = { "Alliance", "Custom" },
          getFunc = function() return self.savedVariables.backdropStyle end,
          setFunc = function(val)
              self.savedVariables.backdropStyle = val
              self:RefreshBackdropColors()
          end },
        { type = "colorpicker",
          tooltip = "Can only be changed when set to Custom.",
          disabled = function() return self.savedVariables.backdropStyle ~= "Custom" end,
          default = { r = 0, g = 0, b = 0, a = 1 },
          getFunc = function()
              local c = self.savedVariables.backdropColor
              if type(c) == "table" then
                  return c.r or 0, c.g or 0, c.b or 0, 1
              end
              return 0, 0, 0, 1
          end,
          setFunc = function(r, g, b, a)
              self.savedVariables.backdropColor = { r = r, g = g, b = b, a = a }
              self:RefreshBackdropColors()
          end,
        },
        { type = "divider" },
        { type = "description",
          title = "Font",
          text = "" },
        { type = "dropdown", name = "",
          choices = {
              "Gamepad Medium",
              "Gamepad Bold",
              "Gamepad Light",
              "Univers Regular",
              "Univers Bold",
              "Prose Antique",
              "Trajan Pro",
              "Handwritten",
          },
          choicesValues = {
              "EsoUI/Common/Fonts/FTN57.otf",
              "EsoUI/Common/Fonts/FTN87.otf",
              "EsoUI/Common/Fonts/FTN47.otf",
              "EsoUI/Common/Fonts/Univers57.otf",
              "EsoUI/Common/Fonts/univers67.otf",
              "EsoUI/Common/Fonts/ProseAntiquePSMT.otf",
              "EsoUI/Common/Fonts/TrajanPro-Regular.otf",
              "EsoUI/Common/Fonts/Handwritten_Bold.otf",
          },
          getFunc = function() return self.savedVariables.font end,
          setFunc = function(val) self.savedVariables.font = val; self:InvalidateFontCache() end,
        },
        { type = "divider" },
        { type = "description",
          title = "Timer Color",
          text = "" },
        { type = "colorpicker",
          tooltip = "Changes the UA! timer color.",
          default = { r = 1, g = 1, b = 1, a = 1 },
          getFunc = function()
              local c = self.savedVariables.timerColor
              if type(c) == "table" then
                  return c.r or 1, c.g or 1, c.b or 1, 1
              end
              return 1, 1, 1, 1
          end,
          setFunc = function(r, g, b, a)
              self.savedVariables.timerColor = { r = r, g = g, b = b, a = a }
          end,
        },
          } },
        { type = "submenu",
          name = "|cE6C800Show in List|r",
          controls = {
        { type = "checkbox", name = "Milegates",
          getFunc = function() return self.savedVariables.showMilegates end,
          setFunc = function(v) self.savedVariables.showMilegates = v end },
        { type = "checkbox", name = "Bridges",
          getFunc = function() return self.savedVariables.showBridges end,
          setFunc = function(v) self.savedVariables.showBridges = v end },
        { type = "checkbox", name = "Towns",
          getFunc = function() return self.savedVariables.showTowns end,
          setFunc = function(v) self.savedVariables.showTowns = v end },
        { type = "checkbox", name = "Resources",
          getFunc = function() return self.savedVariables.showResources end,
          setFunc = function(v) self.savedVariables.showResources = v end },
        { type = "checkbox", name = "Scroll Carriers",
          getFunc = function() return self.savedVariables.showScrollCarriers end,
          setFunc = function(v) self.savedVariables.showScrollCarriers = v end },
        { type = "checkbox", name = "Volendrung",
          getFunc = function() return self.savedVariables.showVolendrungRow end,
          setFunc = function(v) self.savedVariables.showVolendrungRow = v end },
          } },
        { type = "submenu",
          name = "|c00FF00AP in Chat|r",
          controls = {
        { type = "checkbox", name = "Enabled",
          getFunc = function() return self.savedVariables.enableAPChat end,
          setFunc = function(v) self.savedVariables.enableAPChat = v end },
        { type = "checkbox", name = "Consolidate",
          tooltip = "Consolidates Repair and Combat AP instead of printing each one individually.\nPrints after the last gain of that type based on the duration set below.",
          getFunc = function() return self.savedVariables.consolidateAPChat end,
          setFunc = function(v) self.savedVariables.consolidateAPChat = v end },
        { type = "slider", name = "Repair Duration", min = 5, max = 60, step = 1,
          tooltip = "How long to wait before printing consolidated Repair AP (seconds).",
          getFunc = function() return self.savedVariables.consolidateRepairDelay end,
          setFunc = function(v) self.savedVariables.consolidateRepairDelay = v end },
        { type = "slider", name = "Combat Duration", min = 5, max = 60, step = 1,
          tooltip = "How long to wait before printing consolidated Combat AP (seconds).",
          getFunc = function() return self.savedVariables.consolidateCombatDelay end,
          setFunc = function(v) self.savedVariables.consolidateCombatDelay = v end },
          } },
        { type = "submenu",
          name = "|cFF8800Alerts|r",
          controls = {
        { type = "checkbox", name = "Enabled",
          tooltip = "Shows a center-screen alert when a home keep comes under attack.",
          getFunc = function() return self.savedVariables.alertsEnabled end,
          setFunc = function(v) self.savedVariables.alertsEnabled = v end },
        { type = "slider", name = "Duration", min = 5, max = 30, step = 1,
          tooltip = "How long the alert stays on screen (seconds).",
          getFunc = function() return self.savedVariables.alertLifespan end,
          setFunc = function(v) self.savedVariables.alertLifespan = v end },
          } },
        { type = "submenu",
          name = "|cCC2222Auto Invite|r",
          controls = {
        { type = "checkbox",
          name = "Enabled",
          tooltip = "Pauses automatically when the group is full and un-pauses when a spot opens.",
          getFunc = function() return PvPUA.charVariables.aiEnabled end,
          setFunc = function(val)
              if val then
                  EVENT_MANAGER:RegisterForEvent(
                      PvPUA.name .. "_AIGroup",
                      EVENT_GROUP_MEMBER_LEFT,
                      AIOnGroupMemberLeft
                  )
                  EVENT_MANAGER:RegisterForEvent(
                      PvPUA.name .. "_AILeader",
                      EVENT_LEADER_UPDATE,
                      AIOnLeaderUpdate
                  )
                  PvPUA:AIStart()
              else
                  PvPUA:AIStop()
              end
          end },
        { type = "editbox",
          name = "Keyword",
          tooltip = "Words that trigger an invite. Separate multiple with commas (e.g., \"lfg, inv, x\"). Any ONE of them works on its own; a person is invited if their message is EXACTLY one of these words. Enable the channels below to choose where to listen.",
          getFunc = function() return PvPUA.charVariables.aiKeyword end,
          setFunc = function(val)
              if val == PvPUA.charVariables.aiKeyword then return end
              PvPUA.charVariables.aiKeyword = val
              if PvPUA.charVariables.aiEnabled then
                  AIEcho("Keyword(s) updated to: |c00FF00" .. val .. "|r")
              end
          end },
        { type = "checkbox",
          name = "Whisper",
          getFunc = function() return PvPUA.charVariables.aiWhisper end,
          setFunc = function(val) PvPUA.charVariables.aiWhisper = val end },
        { type = "checkbox",
          name = "Say Chat",
          getFunc = function() return PvPUA.charVariables.aiSay end,
          setFunc = function(val) PvPUA.charVariables.aiSay = val end },
        { type = "checkbox",
          name = "Zone Chat",
          getFunc = function() return PvPUA.charVariables.aiZone end,
          setFunc = function(val) PvPUA.charVariables.aiZone = val end },
        { type = "checkbox",
          name = function()
              local id = GetGuildId(1)
              return (id and id > 0) and ("Guild: " .. GetGuildName(id)) or "Guild 1"
          end,
          getFunc = function() return PvPUA.charVariables.aiGuildToggles[1] end,
          setFunc = function(val) PvPUA.charVariables.aiGuildToggles[1] = val end,
          disabled = function() local id = GetGuildId(1) return not (id and id > 0) end },
        { type = "checkbox",
          name = function()
              local id = GetGuildId(2)
              return (id and id > 0) and ("Guild: " .. GetGuildName(id)) or "Guild 2"
          end,
          getFunc = function() return PvPUA.charVariables.aiGuildToggles[2] end,
          setFunc = function(val) PvPUA.charVariables.aiGuildToggles[2] = val end,
          disabled = function() local id = GetGuildId(2) return not (id and id > 0) end },
        { type = "checkbox",
          name = function()
              local id = GetGuildId(3)
              return (id and id > 0) and ("Guild: " .. GetGuildName(id)) or "Guild 3"
          end,
          getFunc = function() return PvPUA.charVariables.aiGuildToggles[3] end,
          setFunc = function(val) PvPUA.charVariables.aiGuildToggles[3] = val end,
          disabled = function() local id = GetGuildId(3) return not (id and id > 0) end },
        { type = "checkbox",
          name = function()
              local id = GetGuildId(4)
              return (id and id > 0) and ("Guild: " .. GetGuildName(id)) or "Guild 4"
          end,
          getFunc = function() return PvPUA.charVariables.aiGuildToggles[4] end,
          setFunc = function(val) PvPUA.charVariables.aiGuildToggles[4] = val end,
          disabled = function() local id = GetGuildId(4) return not (id and id > 0) end },
        { type = "checkbox",
          name = function()
              local id = GetGuildId(5)
              return (id and id > 0) and ("Guild: " .. GetGuildName(id)) or "Guild 5"
          end,
          getFunc = function() return PvPUA.charVariables.aiGuildToggles[5] end,
          setFunc = function(val) PvPUA.charVariables.aiGuildToggles[5] = val end,
          disabled = function() local id = GetGuildId(5) return not (id and id > 0) end },
        { type = "checkbox",
          name = "Kick Offline Members",
          tooltip = "Automatically removes group members who have been offline longer than the time below.",
          getFunc = function() return PvPUA.charVariables.aiKickOffline end,
          setFunc = function(val)
              PvPUA.charVariables.aiKickOffline = val
              if val then PvPUA:AIKickStart() else PvPUA:AIKickStop() end
          end },
        { type = "slider", name = "Offline Minutes", min = 1, max = 30, step = 1,
          getFunc = function() return PvPUA.charVariables.aiKickMinutes end,
          setFunc = function(v) PvPUA.charVariables.aiKickMinutes = v end,
          disabled = function() return not PvPUA.charVariables.aiKickOffline end },
          } },
        { type = "submenu",
          name = "|c2A6FFFIcon|r",
          controls = {
        { type = "checkbox", name = "Show on Self",
          tooltip = "BETA\nExclusive to certain players.",
          getFunc = function() return PvPUA.savedVariables.iconShowSelf end,
          setFunc = function(v) PvPUA.savedVariables.iconShowSelf = v end },
        { type = "checkbox", name = "Show on Others",
          getFunc = function() return PvPUA.savedVariables.iconShowOthers end,
          setFunc = function(v) PvPUA.savedVariables.iconShowOthers = v end },
          } },
    })
end

--------------------------------------------------
-- Load
--------------------------------------------------
local function OnAddonLoaded(event, addonName)
    if addonName ~= PvPUA.name then return end

    PvPUA.savedVariables = ZO_SavedVars:NewAccountWide(
        "PvPUA_SavedVars", 27, nil,
        { posX = 100, posY = 450, timerColor = { r = 1, g = 1, b = 1, a = 1 }, enableAPChat = true, consolidateAPChat = false, consolidateRepairDelay = 5, consolidateCombatDelay = 10, alertsEnabled = false, alertLifespan = 10, font = "EsoUI/Common/Fonts/FTN57.otf", backdropStyle = "Alliance", backdropColor = { r = 0, g = 0, b = 0, a = 1 }, listSize = "Default", uiScale = 1.0, barMode = "AP", iconShowSelf = true, iconShowOthers = true, showMilegates = true, showBridges = true, showTowns = true, showResources = true, showScrollCarriers = true, showVolendrungRow = true }
    )

    PvPUA.charVariables = ZO_SavedVars:NewCharacterIdSettings(
        "PvPUA_CharVars", 1, nil,
        { aiKeyword = "", aiEnabled = false, aiWhisper = true, aiSay = false, aiZone = false, aiGuild = false, aiGuildName = "", aiGuildToggles = {}, aiGuildMigrated = false, aiGuildMigrationRepair = false, aiKickOffline = false, aiKickMinutes = 5 }
    )

    -- Safety: guarantee the per-guild toggle table exists even for saved-var
    -- profiles that predate it, so the settings checkboxes can index it freely.
    if type(PvPUA.charVariables.aiGuildToggles) ~= "table" then
        PvPUA.charVariables.aiGuildToggles = {}
    end

    -- Repair: an earlier build marked aiGuildMigrated=true even when guild data
    -- wasn't loaded, wiping the old selection and skipping the carry-over. Reset
    -- the flag ONCE (tracked by a separate key) so the corrected migration in
    -- AIRefreshGuildChoices re-runs for affected profiles. The old aiGuild /
    -- aiGuildName values are still in saved vars to migrate from.
    if not PvPUA.charVariables.aiGuildMigrationRepair then
        PvPUA.charVariables.aiGuildMigrated = false
        PvPUA.charVariables.aiGuildMigrationRepair = true
    end

    -- Migration: Compact preset removed in favour of the live Size slider.
    -- Force everyone onto the Default layout; the slider now covers sizing.
    PvPUA.savedVariables.listSize = "Default"

    -- Migration: update old backdropStyle values to new system
    local style = PvPUA.savedVariables.backdropStyle
    if style == "Alliance Colored" then
        PvPUA.savedVariables.backdropStyle = "Alliance"
    elseif style == "Black" then
        PvPUA.savedVariables.backdropStyle = "Custom"
        PvPUA.savedVariables.backdropColor = { r = 0, g = 0, b = 0, a = 1 }
    end

    PvPUA:ApplyListSize()
    PvPUA:CreateUI()
    PvPUA:RefreshBackdropColors()
    PvPUA:CreateSettings()

    -- Player Icon System (wrapped so any error here can't break the rest of the addon)
    pcall(PI.Init)

    EVENT_MANAGER:RegisterForEvent(PvPUA.name, EVENT_PLAYER_ACTIVATED,
        function() PvPUA:OnPlayerActivated() end)

    -- Fires as soon as the game registers a zone change, even without a full
    -- loading screen (e.g. walking across a zone border on foot). Re-runs the
    -- same Cyrodiil/IC check as OnPlayerActivated so the list doesn't get
    -- stuck showing until the next full load or /reloadui.
    EVENT_MANAGER:RegisterForEvent(PvPUA.name .. "_ZoneChanged", EVENT_ZONE_CHANGED,
        function() PvPUA:ZoneCheck() end)

    if not pvpIsCombatRegistered then

        EVENT_MANAGER:RegisterForEvent(PvPUA.name .. "_Combat", EVENT_COMBAT_EVENT,
            function(eventCode, result, isError, abilityName, abilityGraphic,
                     abilityActionSlotType, sourceName, sourceType,
                     targetName, targetType, hitValue, powerType, damageType,
                     log, sourceUnitId, targetUnitId, abilityId, overflow)

                if isError then return end
                if not (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then return end
                if result ~= ACTION_RESULT_KILLING_BLOW then return end
                if GetUnitName("player") ~= zo_strformat("<<1>>", sourceName) then return end

                local tName = zo_strformat("<<1>>", targetName)

                if abilityName ~= "" and GetUnitName("player") ~= tName then
                    PvPUA.session.killingBlows = PvPUA.session.killingBlows + 1
                    UpdateKAD()
                end
            end)

        EVENT_MANAGER:RegisterForEvent(PvPUA.name .. "_Death", EVENT_PLAYER_DEAD,
            function()
                RSOnDeathStateChanged()
                if not (IsPlayerInAvAWorld() or IsActiveWorldBattleground()) then return end
                PvPUA.session.deaths = PvPUA.session.deaths + 1
                pvpRecentKBs = { count = 0 }
                UpdateKAD()
            end)

        EVENT_MANAGER:RegisterForEvent(PvPUA.name .. "_Alive", EVENT_PLAYER_ALIVE,
            function() RSOnDeathStateChanged() end)

        pvpIsCombatRegistered = true
    end

    if PvPUA.charVariables.aiEnabled then
        EVENT_MANAGER:RegisterForEvent(
            PvPUA.name .. "_AIGroup",
            EVENT_GROUP_MEMBER_LEFT,
            AIOnGroupMemberLeft
        )
        EVENT_MANAGER:RegisterForEvent(
            PvPUA.name .. "_AILeader",
            EVENT_LEADER_UPDATE,
            AIOnLeaderUpdate
        )
        PvPUA:AIStart(true)
    end

    -- Independent of aiEnabled: kicking offline members is useful whether or
    -- not we're currently recruiting.
    if PvPUA.charVariables.aiKickOffline then
        PvPUA:AIKickStart()
    end

    EVENT_MANAGER:UnregisterForEvent(PvPUA.name, EVENT_ADD_ON_LOADED)
end

EVENT_MANAGER:RegisterForEvent(PvPUA.name, EVENT_ADD_ON_LOADED, OnAddonLoaded)

--------------------------------------------------
-- AP In Chat
--------------------------------------------------
local function FormatAP(amount)
    if amount >= 1000000 then return string.format("%.1fM", amount / 1000000)
    elseif amount >= 1000 then return string.format("%.1fK", amount / 1000)
    else return tostring(amount) end
end

local AP_REASONS = {
    [CURRENCY_CHANGE_REASON_KILL]                  = "Combat",
    [CURRENCY_CHANGE_REASON_OFFENSIVE_KEEP_REWARD] = "Capture",
    [CURRENCY_CHANGE_REASON_DEFENSIVE_KEEP_REWARD] = "D-Tick",
    [CURRENCY_CHANGE_REASON_KEEP_REPAIR]           = "Repair",
    [CURRENCY_CHANGE_REASON_PVP_RESURRECT]         = "Rez",
    [CURRENCY_CHANGE_REASON_MEDAL]                 = "Medal",
    [CURRENCY_CHANGE_REASON_BATTLEGROUND]          = "BG",
    [CURRENCY_CHANGE_REASON_QUESTREWARD]           = "Quest",
}

local apBuckets = {}

local function FlushAPBucket(reason)
    local bucket = apBuckets[reason]
    if not bucket or bucket.total <= 0 then return end
    local source = AP_REASONS[reason]
    local alliance = GetUnitAlliance("player")
    local aColor = alliance == ALLIANCE_DAGGERFALL_COVENANT and "2A6FFF"
                or alliance == ALLIANCE_ALDMERI_DOMINION    and "E6C800"
                or alliance == ALLIANCE_EBONHEART_PACT      and "CC2222" or "FFFFFF"
    local msg = "|c00FF00+" .. FormatAP(bucket.total) .. " AP|r"
    if source then msg = msg .. " |c" .. aColor .. "(" .. source .. ")|r" end
    d(msg)
    bucket.total = 0
end

local function OnAPGain(eventCode, alliancePoints, playSound, difference, reason)
    PvPUA:RefreshRankLabel()
    if reason == CURRENCY_CHANGE_REASON_BANK_WITHDRAWAL
    or reason == CURRENCY_CHANGE_REASON_VENDOR
    or reason == CURRENCY_CHANGE_REASON_TRADE
    or difference <= 0 then return end
    if not PvPUA.savedVariables or not PvPUA.savedVariables.enableAPChat then return end

    local source = AP_REASONS[reason]
    local alliance = GetUnitAlliance("player")
    local aColor = alliance == ALLIANCE_DAGGERFALL_COVENANT and "2A6FFF"
                or alliance == ALLIANCE_ALDMERI_DOMINION    and "E6C800"
                or alliance == ALLIANCE_EBONHEART_PACT      and "CC2222" or "FFFFFF"

    if PvPUA.savedVariables.consolidateAPChat
    and (reason == CURRENCY_CHANGE_REASON_KILL or reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR) then
        if not apBuckets[reason] then
            apBuckets[reason] = { total = 0 }
        end
        apBuckets[reason].total = apBuckets[reason].total + difference
        EVENT_MANAGER:UnregisterForUpdate("PvPUA_APFlush_" .. tostring(reason))
        local delay = (reason == CURRENCY_CHANGE_REASON_KEEP_REPAIR)
            and (PvPUA.savedVariables.consolidateRepairDelay or 5) * 1000
            or  (PvPUA.savedVariables.consolidateCombatDelay or 10) * 1000
        EVENT_MANAGER:RegisterForUpdate("PvPUA_APFlush_" .. tostring(reason), delay, function()
            EVENT_MANAGER:UnregisterForUpdate("PvPUA_APFlush_" .. tostring(reason))
            FlushAPBucket(reason)
        end)
    else
        local msg = "|c00FF00+" .. FormatAP(difference) .. " AP|r"
        if source then msg = msg .. " |c" .. aColor .. "(" .. source .. ")|r" end
        d(msg)
    end
end

EVENT_MANAGER:RegisterForEvent(PvPUA.name .. "_AP", EVENT_ALLIANCE_POINT_UPDATE, OnAPGain)
