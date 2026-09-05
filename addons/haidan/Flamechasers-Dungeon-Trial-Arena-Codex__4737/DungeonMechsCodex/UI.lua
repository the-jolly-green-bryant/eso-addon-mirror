-- Flamechasers Dungeon, Trial & Arena Codex UI
-- Compact branded layout with native ESO scroll containers and per-boss notes.

local DMC = DungeonMechsCodex
local wm = WINDOW_MANAGER

local UI = {
    selectedDungeonId = nil,
    selectedBossId = nil,
    selectedChatLine = nil,
    searchText = "",
    roleFilter = "all",
    mode = "hm",
    activityType = "dungeon",
    dungeonButtons = {},
    bossButtons = {},
    dungeonPasteButtons = {},
    bossPasteButtons = {},
    notePasteButtons = {},
    mechanicRows = {},
    noteOriginal = "",
    noteLoading = false,
    noteLoadedDungeonId = nil,
    noteLoadedBossId = nil,
    noteLoadedMode = nil,
    themeColorBindings = {},
    themeFontControls = {},
    themeIconParts = {},
    themeButtons = {},
}
DMC.ui = UI

-- Settings.lua owns this palette and mutates each RGBA table in place. Keeping
-- one shared reference lets all state renderers pick up a new theme immediately.
local C = DMC.themeColors

local WINDOW_WIDTH = 1260
local WINDOW_HEIGHT = 860
local WINDOW_INSET = 7
local LEFT_X = 18
local CONTENT_Y = 68
local LEFT_WIDTH = 276
local CONTENT_HEIGHT = 774
local RIGHT_X = 306
local RIGHT_WIDTH = 936
local DUNGEON_CONTENT_WIDTH = 232
local DUNGEON_TITLE_X = 52
local MECHANIC_CONTENT_WIDTH = 874
local FONT_BODY = "body"
local FONT_META = "meta"
local FONT_META_BOLD = "metaBold"
local FONT_BOSS_ROW = "bossRow"
local FONT_SECTION = "section"
local FONT_SECTION_SMALL = "sectionSmall"
local FONT_UI = "ui"
local FONT_UI_BOLD = "uiBold"
local FONT_UI_SMALL = "uiSmall"
local FONT_H2 = "h2"
local FONT_H3 = "h3"
local FONT_HINT = "hint"

-- Activity Finder remains a fallback for future dungeon modules. Every current
-- supported activity uses an explicit, verified client loading-screen texture
-- below so artwork never depends on Finder data being populated first.
local activityArtworkCatalog
local activityArtworkCache = {}

-- These are ESO-owned files, not bundled addon assets. Keeping the catalog
-- keyed by our stable activity IDs makes it independent of client language,
-- queue category enumeration, and Activity Finder initialization timing.
local INSTANCE_LOADSCREENS = {
    imperial_city_prison = "/esoui/art/loadingscreens/loadscreen_imperialcity_prison_veteran_01.dds",
    white_gold_tower = "/esoui/art/loadingscreens/loadscreen_whitegoldtower_veteran_01.dds",
    cradle_of_shadows = "/esoui/art/loadingscreens/loadscreen_cradleofshadows_veteran_01.dds",
    ruins_of_mazzatun = "/esoui/art/loadingscreens/loadscreen_mazzatun_veteran_01.dds",
    black_drake_villa = "/esoui/art/loadingscreens/loadscreen_blackdrake_veteran_01.dds",
    black_gem_foundry = "/esoui/art/loadingscreens/loadscreen_black_gem_foundry_veteran_01.dds",
    bloodroot_forge = "/esoui/art/loadingscreens/loadscreen_bloodrootforge_veteran_01.dds",
    falkreath_hold = "/esoui/art/loadingscreens/loadscreen_falkreathsdemise_veteran_01.dds",
    fang_lair = "/esoui/art/loadingscreens/loadscreen_fanglair_veteran_01.dds",
    scalecaller_peak = "/esoui/art/loadingscreens/loadscreen_scalecaller_veteran_01.dds",
    moon_hunter_keep = "/esoui/art/loadingscreens/loadscreen_moonhunterkeep_veteran_01.dds",
    march_of_sacrifices = "/esoui/art/loadingscreens/loadscreen_marchofsacrifices_veteran_01.dds",
    frostvault = "/esoui/art/loadingscreens/loadscreen_frostvault_01.dds",
    depths_of_malatar = "/esoui/art/loadingscreens/loadscreen_depthsofmalatar_veteran_01.dds",
    moongrave_fane = "/esoui/art/loadingscreens/loadscreen_moongravefane_veteran_01.dds",
    lair_of_maarselok = "/esoui/art/loadingscreens/loadscreen_lairofmaarselok_veteran_01.dds",
    icereach = "/esoui/art/loadingscreens/loadscreen_icereach_veteran_01.dds",
    unhallowed_grave = "/esoui/art/loadingscreens/loadscreen_unhallowedgrave_veteran_01.dds",
    stone_garden = "/esoui/art/loadingscreens/loadscreen_stonegarden_veteran_01.dds",
    castle_thorn = "/esoui/art/loadingscreens/loadscreen_castlethorn_veteran_01.dds",
    the_cauldron = "/esoui/art/loadingscreens/loadscreen_thecauldron_veteran_01.dds",
    red_petal_bastion = "/esoui/art/loadingscreens/loadscreen_redpetalbastion_veteran_01.dds",
    the_dread_cellar = "/esoui/art/loadingscreens/loadscreen_dreadcellar_veteran_01.dds",
    coral_aerie = "/esoui/art/loadingscreens/loadscreen_coralaerie_veteran_01.dds",
    shipwrights_regret = "/esoui/art/loadingscreens/loadscreen_shipwrights_regret_veteran_01.dds",
    earthen_root_enclave = "/esoui/art/loadingscreens/loadscreen_earthenrootenclave_veteran_01.dds",
    graven_deep = "/esoui/art/loadingscreens/loadscreen_gravendeep_veteran_01.dds",
    bal_sunnar = "/esoui/art/loadingscreens/loadscreen_bal_sunnar_veteran.dds",
    scriveners_hall = "/esoui/art/loadingscreens/loadscreen_scriveners_hall_veteran.dds",
    oathsworn_pit = "/esoui/art/loadingscreens/loadscreen_oathswornpit_veteran_01.dds",
    bedlam_veil = "/esoui/art/loadingscreens/loadscreen_bedlamveil_veteran_01.dds",
    exiled_redoubt = "/esoui/art/loadingscreens/loadscreen_exiledredoubt_veteran_01.dds",
    lep_seclusa = "/esoui/art/loadingscreens/loadscreen_lepseclusa_veteran_01.dds",
    naj_caldeesh = "/esoui/art/loadingscreens/loadscreen_naj_caldeesh_veteran_01.dds",
    aetherian_archive = "/esoui/art/loadingscreens/loadscreen_aetherianarchive_veteran_01.dds",
    hel_ra_citadel = "/esoui/art/loadingscreens/loadscreen_helracitadel_veteran_01.dds",
    sanctum_ophidia = "/esoui/art/loadingscreens/loadscreen_serpenttrial_veteran_01.dds",
    maw_of_lorkhaj = "/esoui/art/loadingscreens/loadscreen_maw_of_lorkaj_veteran_01.dds",
    halls_of_fabrication = "/esoui/art/loadingscreens/loadscreen_hallsoffabrication_veteran_01.dds",
    asylum_sanctorium = "/esoui/art/loadingscreens/loadscreen_asylumsanctorium_veteran_01.dds",
    cloudrest = "/esoui/art/loadingscreens/loadscreen_cloudrest_veteran_01.dds",
    sunspire = "/esoui/art/loadingscreens/loadscreen_sunspire_veteran_01.dds",
    kynes_aegis = "/esoui/art/loadingscreens/loadscreen_kynesaegis_veteran_01.dds",
    rockgrove = "/esoui/art/loadingscreens/loadscreen_rockgrove_veteran_01.dds",
    dreadsail_reef = "/esoui/art/loadingscreens/loadscreen_dreadsail_reef_trial_veteran_01.dds",
    sanitys_edge = "/esoui/art/loadingscreens/loadscreen_sanitysedge_veteran_01.dds",
    lucent_citadel = "/esoui/art/loadingscreens/loadscreen_lucentcitadel_veteran_01.dds",
    ossein_cage = "/esoui/art/loadingscreens/loadscreen_ossein_cage_veteran_01.dds",
    dragonstar_arena = "/esoui/art/loadingscreens/loadscreen_dragonstararena_veteran_01.dds",
    blackrose_prison_arena = "/esoui/art/loadingscreens/loadscreen_blackrose_prison_veteran_01.dds",
    maelstrom_arena = "/esoui/art/loadingscreens/loadscreen_maelstromarena_veteran_01.dds",
    vateshran_hollows = "/esoui/art/loadingscreens/loadscreen_vateshranhollows_veteran_01.dds",
}

local function validTexture(texture)
    return type(texture) == "string" and texture ~= ""
end

local function getFinderArtwork(activityId)
    local smallTexture, largeTexture
    if type(GetActivityKeyboardDescriptionTextures) == "function" then
        smallTexture, largeTexture = GetActivityKeyboardDescriptionTextures(activityId)
    end
    if validTexture(smallTexture) then return smallTexture end
    if validTexture(largeTexture) then return largeTexture end
    if type(GetActivityGamepadDescriptionTexture) == "function" then
        local gamepadTexture = GetActivityGamepadDescriptionTexture(activityId)
        if validTexture(gamepadTexture) then return gamepadTexture end
    end
    return nil
end

local function buildActivityArtworkCatalog(forceRefresh)
    if activityArtworkCatalog and not forceRefresh then return activityArtworkCatalog end
    activityArtworkCatalog = {byName = {}, byZone = {}}

    if type(GetNumActivitiesByType) ~= "function"
        or type(GetActivityIdByTypeAndIndex) ~= "function" then
        return activityArtworkCatalog
    end

    local activityTypes, seenTypes = {}, {}
    local function addType(activityType)
        if activityType ~= nil and not seenTypes[activityType] then
            seenTypes[activityType] = true
            activityTypes[#activityTypes + 1] = activityType
        end
    end

    -- Match ESO's own Activity Finder manager: walk the complete live enum
    -- range. Trials and arenas are not guaranteed to live in only the four
    -- queue categories used by the dungeon finder on every API revision.
    local firstType = _G.LFG_ACTIVITY_ITERATION_BEGIN
    local lastType = _G.LFG_ACTIVITY_ITERATION_END
    if type(firstType) == "number" and type(lastType) == "number"
        and lastType >= firstType and lastType - firstType < 100 then
        for activityType = firstType, lastType do addType(activityType) end
    end

    -- Retain explicit fallbacks for older API/test environments that do not
    -- publish the iteration boundary constants.
    addType(_G.LFG_ACTIVITY_DUNGEON)
    addType(_G.LFG_ACTIVITY_MASTER_DUNGEON)
    addType(_G.LFG_ACTIVITY_TRIAL)
    addType(_G.LFG_ACTIVITY_ARENA)
    addType(_G.LFG_ACTIVITY_ADVENTURE_ZONE)

    for _, activityType in ipairs(activityTypes) do
        local count = GetNumActivitiesByType(activityType) or 0
        for index = 1, count do
            local activityId = GetActivityIdByTypeAndIndex(activityType, index)
            if activityId then
                local name = ""
                if type(GetActivityName) == "function" then
                    name = GetActivityName(activityId) or ""
                end
                if name == "" and type(GetActivityInfo) == "function" then
                    name = GetActivityInfo(activityId)
                end
                local texture = getFinderArtwork(activityId)
                if texture then
                    local nameKey = DMC.NormalizeText(name or "")
                    if nameKey ~= "" and not activityArtworkCatalog.byName[nameKey] then
                        activityArtworkCatalog.byName[nameKey] = texture
                    end
                    if type(GetActivityZoneId) == "function" then
                        local zoneId = GetActivityZoneId(activityId)
                        if zoneId and zoneId > 0 and not activityArtworkCatalog.byZone[zoneId] then
                            activityArtworkCatalog.byZone[zoneId] = texture
                        end
                    end
                end
            end
        end
    end
    return activityArtworkCatalog
end

local function getZoneStoryArtwork(activity)
    if type(GetZoneStoryKeyboardBackground) ~= "function"
        and type(GetZoneStoryGamepadBackground) ~= "function" then
        return nil
    end

    local tested = {}
    local function tryZone(zoneId)
        if not zoneId or zoneId <= 0 or tested[zoneId] then return nil end
        tested[zoneId] = true
        if type(GetZoneStoryKeyboardBackground) == "function" then
            local texture = GetZoneStoryKeyboardBackground(zoneId)
            if validTexture(texture) then return texture end
        end
        if type(GetZoneStoryGamepadBackground) == "function" then
            local texture = GetZoneStoryGamepadBackground(zoneId)
            if validTexture(texture) then return texture end
        end
        return nil
    end

    for _, zoneId in ipairs(activity.zoneIds or {}) do
        local texture = tryZone(zoneId)
        if texture then return texture end
        if type(GetZoneStoryZoneIdForZoneId) == "function" then
            texture = tryZone(GetZoneStoryZoneIdForZoneId(zoneId))
            if texture then return texture end
        end
    end
    return nil
end

local function getActivityArtwork(activity)
    if not activity then return nil end
    local cached = activityArtworkCache[activity.id]
    if cached then
        return cached.texture, cached.isLoadscreen
    end

    local instanceLoadscreen = INSTANCE_LOADSCREENS[activity.id]
    if instanceLoadscreen then
        activityArtworkCache[activity.id] = {texture = instanceLoadscreen, isLoadscreen = true}
        return instanceLoadscreen, true
    end

    -- Do not accept Activity Finder or Zone Story fallbacks for a Trial/Arena:
    -- both APIs return shared chapter/category art rather than the selected
    -- instance's splash image. A missing future mapping should stay blank until
    -- its real client texture is added, never silently show the wrong picture.
    if DMC.GetActivityKind(activity) ~= "dungeon" then
        return nil
    end

    local function findInCatalog(catalog)
        local texture
        for _, zoneId in ipairs(activity.zoneIds or {}) do
            texture = catalog.byZone[zoneId]
            if texture then return texture end
        end
        texture = catalog.byName[DMC.NormalizeText(activity.name or "")]
        if texture then return texture end
        for _, alias in ipairs(activity.aliases or {}) do
            texture = catalog.byName[DMC.NormalizeText(alias)]
            if texture then return texture end
        end
        return nil
    end

    local texture = findInCatalog(buildActivityArtworkCatalog(false))
    if not texture then
        -- Finder tables can be empty during early addon initialization. Rebuild
        -- rather than preserving an incomplete catalog or a permanent miss.
        texture = findInCatalog(buildActivityArtworkCatalog(true))
        if not texture then texture = getZoneStoryArtwork(activity) end
    end
    if texture then
        activityArtworkCache[activity.id] = {texture = texture, isLoadscreen = false}
        return texture, false
    end
    -- Never cache a miss: ESO may populate Finder/Zone Story data later.
    return nil
end

local ARTWORK_RETRY_DELAYS_MS = {1200, 3600}
local ARTWORK_HEALTH_UPDATE_NAME = DMC.name .. "ArtworkHealth"

local function artworkClockMilliseconds()
    if type(GetFrameTimeMilliseconds) == "function" then
        return GetFrameTimeMilliseconds()
    end
    return 0
end

local function artworkShouldBeVisible()
    local enabled = not DMC.ShouldShowAppearanceElement
        or DMC.ShouldShowAppearanceElement("showArtwork")
    return enabled and UI.currentArtwork ~= nil
        and UI.window ~= nil and not UI.window:IsHidden()
end

local ARTWORK_SHADE_SEGMENT_COUNT = 32
local ARTWORK_VISIBILITY_FLOOR = 0.00
local ARTWORK_VISIBILITY_ALPHA_SCALE = 2.00
local ARTWORK_SHADE_TINT_MIX = 0.18

local function clampUnit(value)
    return math.max(0, math.min(1, value or 0))
end

local function setArtworkShadeHidden(hidden)
    for _, segment in ipairs(UI.dungeonArtShadeSegments or {}) do
        segment:SetHidden(hidden)
    end
end

local function applyArtworkShade()
    if not UI.dungeonArtShadeSegments then return end
    local intensity = DMC.GetArtworkIntensity and DMC.GetArtworkIntensity() or 1
    local left = C.artworkLeft
    local right = C.artworkRight
    local panel = C.panel2
    local signature = table.concat({
        tostring(intensity),
        tostring(left[1]), tostring(left[2]), tostring(left[3]), tostring(left[4]),
        tostring(right[1]), tostring(right[2]), tostring(right[3]), tostring(right[4]),
        tostring(panel[1]), tostring(panel[2]), tostring(panel[3]), tostring(panel[4]),
    }, ":")
    if UI.artworkShadeSignature == signature then return end

    -- Never shade the DDS controls themselves. ESO retains vertex-gradient
    -- state when a texture control is reused, which progressively darkens an
    -- image after A -> B -> A navigation. These permanent solid-color strips
    -- provide a light readability veil without touching either art buffer.
    --
    -- The old texture-gradient alpha values represented how much artwork was
    -- visible over the panel. Applying their literal inverse as an overlay
    -- made this independent layer 83-93% opaque before color luminance was
    -- considered, and the prior midtone conversion pushed it to roughly 95%.
    -- Remap those deliberately small alpha values into a useful visibility
    -- range instead: at the default intensity, about 14% of the image remains
    -- at the text-heavy left edge and 34% remains at the right edge.
    for index, segment in ipairs(UI.dungeonArtShadeSegments) do
        local amount = (index - 0.5) / ARTWORK_SHADE_SEGMENT_COUNT
        local r = left[1] + (right[1] - left[1]) * amount
        local g = left[2] + (right[2] - left[2]) * amount
        local b = left[3] + (right[3] - left[3]) * amount
        local alpha = left[4] + (right[4] - left[4]) * amount
        local visibility = clampUnit((ARTWORK_VISIBILITY_FLOOR
            + alpha * ARTWORK_VISIBILITY_ALPHA_SCALE) * intensity)
        local shadeAlpha = 1 - visibility
        local tintMix = ARTWORK_SHADE_TINT_MIX * clampUnit(intensity)
        local shadeR = clampUnit(panel[1] + (r - panel[1]) * tintMix)
        local shadeG = clampUnit(panel[2] + (g - panel[2]) * tintMix)
        local shadeB = clampUnit(panel[3] + (b - panel[3]) * tintMix)
        segment:SetColor(shadeR, shadeG, shadeB, shadeAlpha)
    end
    UI.artworkShadeSignature = signature
end

local function setArtworkTextureCoords(control, isLoadscreen)
    if not control then return end
    if isLoadscreen then
        -- Loading screens are 16:9; crop a centered horizontal banner that
        -- fills the 936x112 summary panel without stretching the artwork.
        control:SetTextureCoords(0, 1, 0.394, 0.606)
    else
        -- Activity Finder keyboard artwork uses a larger atlas region.
        control:SetTextureCoords(0, 0.6836, 0.41, 0.575)
    end
end

local function artworkIsLoaded(control)
    if not control or not control.dmcArtworkPath then return false end
    if type(control.IsTextureLoaded) == "function" then
        return control:IsTextureLoaded()
    end
    return true
end

local function clearArtworkBuffer(control)
    if not control then return end
    control.dmcArtworkPath = nil
    control.dmcArtworkIsLoadscreen = nil
    control.dmcArtworkRequestId = nil
    control.dmcArtworkRetriesExhausted = nil
    control:SetHidden(true)
    control:SetTexture(nil)
end

local function releaseDisplayedArtwork()
    UI.artworkRequestId = (UI.artworkRequestId or 0) + 1
    for _, control in ipairs(UI.dungeonArtBuffers or {}) do
        clearArtworkBuffer(control)
    end
    UI.dungeonArt = UI.dungeonArtBuffers and UI.dungeonArtBuffers[1] or UI.dungeonArt
    UI.pendingArtwork = nil
    UI.loadedArtwork = nil
    setArtworkShadeHidden(true)
end

local function finishArtworkLoad(control)
    if not control or control.dmcArtworkRequestId ~= UI.artworkRequestId
        or control.dmcArtworkPath ~= UI.currentArtwork
        or not artworkShouldBeVisible() or not artworkIsLoaded(control) then
        return false
    end

    local previous = UI.dungeonArt
    control:SetDrawLevel(4)
    control:SetHidden(false)
    UI.dungeonArt = control
    UI.pendingArtwork = nil
    UI.loadedArtwork = control.dmcArtworkPath
    UI.artworkRetryAfter = nil
    setArtworkShadeHidden(false)

    if previous and previous ~= control then
        previous:SetDrawLevel(3)
        clearArtworkBuffer(previous)
    end
    return true
end

local function scheduleArtworkRetry(control, requestId, attempt)
    local delay = ARTWORK_RETRY_DELAYS_MS[attempt]
    if not delay then
        if control and control.dmcArtworkRequestId == requestId
            and requestId == UI.artworkRequestId then
            control.dmcArtworkRetriesExhausted = true
            UI.artworkRetryAfter = artworkClockMilliseconds() + 10000
        end
        return
    end
    zo_callLater(function()
        if not control or control.dmcArtworkRequestId ~= requestId
            or requestId ~= UI.artworkRequestId
            or control.dmcArtworkPath ~= UI.currentArtwork
            or not artworkShouldBeVisible() then
            return
        end
        if finishArtworkLoad(control) then return end

        -- Rebind the same verified client path if ESO's asynchronous texture
        -- request stalled or was evicted before it reached the control.
        local path = control.dmcArtworkPath
        control:SetTexture(nil)
        control:SetTexture(path)
        if not finishArtworkLoad(control) then
            scheduleArtworkRetry(control, requestId, attempt + 1)
        end
    end, delay)
end

local function requestCurrentArtwork()
    local path = UI.currentArtwork
    local isLoadscreen = UI.currentArtworkIsLoadscreen
    local active = UI.dungeonArt

    -- A repeated click on the selected activity is a true no-op while ESO
    -- confirms that its texture is still resident. If it was evicted, fall
    -- through and repair it using the second buffer.
    if active and active.dmcArtworkPath == path
        and not active:IsHidden() and artworkIsLoaded(active) then
        UI.loadedArtwork = path
        setArtworkShadeHidden(false)
        return
    end

    local pending = UI.pendingArtwork
    if pending and pending.dmcArtworkPath == path
        and pending.dmcArtworkRequestId == UI.artworkRequestId then
        if finishArtworkLoad(pending) then return end
        -- A user selecting the same activity again after all bounded retries
        -- have elapsed explicitly restarts the stalled request below.
    end

    UI.artworkRequestId = (UI.artworkRequestId or 0) + 1
    UI.artworkRetryAfter = nil
    local requestId = UI.artworkRequestId
    local buffers = UI.dungeonArtBuffers or {}
    local target
    if active and not active.dmcArtworkPath then
        target = active
    else
        for _, control in ipairs(buffers) do
            if control ~= active then target = control break end
        end
    end
    target = target or buffers[1] or active
    if not target then return end

    clearArtworkBuffer(target)
    target.dmcArtworkPath = path
    target.dmcArtworkIsLoadscreen = isLoadscreen
    target.dmcArtworkRequestId = requestId
    target.dmcArtworkRetriesExhausted = false
    setArtworkTextureCoords(target, isLoadscreen)
    UI.pendingArtwork = target
    target:SetTexture(path)

    if finishArtworkLoad(target) then return end

    -- Do not leave another activity's artwork under a stalled request. The
    -- brief grace period prevents a black flash during ordinary cached loads.
    zo_callLater(function()
        if UI.pendingArtwork == target and target.dmcArtworkRequestId == requestId
            and UI.dungeonArt and UI.dungeonArt ~= target then
            UI.dungeonArt:SetHidden(true)
        end
    end, 250)
    scheduleArtworkRetry(target, requestId, 1)
end

local function applyArtworkAppearance()
    if not UI.dungeonArt and not UI.dungeonArtBuffers then return end
    applyArtworkShade()
    if not artworkShouldBeVisible() then
        releaseDisplayedArtwork()
        return
    end

    requestCurrentArtwork()
end

local function checkArtworkHealth()
    if not artworkShouldBeVisible() then return end
    local active = UI.dungeonArt
    if active and active.dmcArtworkPath == UI.currentArtwork
        and not active:IsHidden() and artworkIsLoaded(active) then
        return
    end
    if UI.pendingArtwork then
        if finishArtworkLoad(UI.pendingArtwork) then return end
        if not UI.pendingArtwork.dmcArtworkRetriesExhausted then return end
    end
    if UI.artworkRetryAfter
        and artworkClockMilliseconds() < UI.artworkRetryAfter then
        return
    end
    requestCurrentArtwork()
end

local function startArtworkHealthMonitor()
    if not EVENT_MANAGER or type(EVENT_MANAGER.RegisterForUpdate) ~= "function" then return end
    EVENT_MANAGER:UnregisterForUpdate(ARTWORK_HEALTH_UPDATE_NAME)
    EVENT_MANAGER:RegisterForUpdate(ARTWORK_HEALTH_UPDATE_NAME, 2000, checkArtworkHealth)
end

local function stopArtworkHealthMonitor()
    if EVENT_MANAGER and type(EVENT_MANAGER.UnregisterForUpdate) == "function" then
        EVENT_MANAGER:UnregisterForUpdate(ARTWORK_HEALTH_UPDATE_NAME)
    end
end

local function getSessionState()
    DMC.sessionState = DMC.sessionState or {}
    if not DMC.sessionState.roleFilter then DMC.sessionState.roleFilter = "all" end
    if DMC.sessionState.activityType ~= "trial" and DMC.sessionState.activityType ~= "arena" then
        DMC.sessionState.activityType = "dungeon"
    end
    return DMC.sessionState
end

local function isValidRoleFilter(role)
    return role == "all" or role == "quick" or role == "tank" or role == "healer" or role == "dps"
end

local ROLE_ORDER = {"all", "quick", "tank", "healer", "dps"}

local function hideCompactHint()
    if UI.compactHint then UI.compactHint:SetHidden(true) end
end

local function showCompactHint(control, text, belowControl)
    if not UI.compactHint or not UI.compactHintLabel then return end
    if DMC.ShouldShowAppearanceElement and not DMC.ShouldShowAppearanceElement("showHoverHints") then
        hideCompactHint()
        return
    end
    UI.compactHintLabel:SetText(text or "")
    local width = math.max(46, math.min(132, math.ceil(UI.compactHintLabel:GetTextWidth() + 16)))
    UI.compactHint:SetDimensions(width, 20)
    UI.compactHint:ClearAnchors()
    if belowControl then
        UI.compactHint:SetAnchor(TOP, control, BOTTOM, 0, 4)
    else
        UI.compactHint:SetAnchor(BOTTOM, control, TOP, 0, -4)
    end
    UI.compactHint:SetHidden(false)
end

local function anchorFill(control, parent, inset)
    inset = inset or 0
    control:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, inset)
    control:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -inset, -inset)
end

local LEGACY_FONT_ROLES = {
    ZoFontGame = FONT_UI,
    ZoFontGameBold = FONT_UI_BOLD,
    ZoFontGameSmall = FONT_UI_SMALL,
    ZoFontWinH2 = FONT_H2,
    ZoFontWinH3 = FONT_H3,
}

local function getFontRole(font)
    if DMC.appearanceFontRoles and DMC.appearanceFontRoles[font] then return font end
    return LEGACY_FONT_ROLES[font]
end

local function resolveFont(font)
    local role = getFontRole(font)
    return role and DMC.GetAppearanceFont(role) or (font or "ZoFontGame")
end

local function bindFont(control, font)
    if not control then return end
    local role = getFontRole(font)
    control:SetFont(resolveFont(font))
    if role then
        control.dmcFontRole = role
        UI.themeFontControls[#UI.themeFontControls + 1] = control
    end
end

local function getColorKey(color)
    if type(color) ~= "table" then return nil end
    for key, value in pairs(C) do
        if value == color then return key end
    end
    return nil
end

local function bindColor(control, method, color)
    if not control or not method or type(control[method]) ~= "function" then return end
    local key = type(color) == "string" and color or getColorKey(color)
    local value = key and C[key] or color
    if type(value) ~= "table" then return end
    control[method](control, unpack(value))
    if key then
        UI.themeColorBindings[#UI.themeColorBindings + 1] = {
            control = control,
            method = method,
            key = key,
        }
    end
end

local function makeBackdrop(parent, name, centerColor, edgeColor, inset)
    local backdrop = wm:CreateControl(name, parent, CT_BACKDROP)
    anchorFill(backdrop, parent, inset or 0)
    backdrop:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    backdrop:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16)
    backdrop:SetInsets(7, 7, -7, -7)
    bindColor(backdrop, "SetCenterColor", centerColor or C.panel)
    bindColor(backdrop, "SetEdgeColor", edgeColor or C.edgeDim)
    backdrop:SetMouseEnabled(false)
    backdrop:SetDrawLayer(DL_BACKGROUND)
    return backdrop
end

local function makeWindowStroke(parent, name, thickness, inset, color)
    local frame = wm:CreateControl(name, parent, CT_CONTROL)
    frame:SetAnchor(TOPLEFT, parent, TOPLEFT, inset, inset)
    frame:SetAnchor(BOTTOMRIGHT, parent, BOTTOMRIGHT, -inset, -inset)
    frame:SetMouseEnabled(false)
    frame.lines = {}

    local function horizontal(suffix, top)
        local line = wm:CreateControl(name .. suffix, frame, CT_TEXTURE)
        line:SetHeight(thickness)
        line:SetAnchor(top and TOPLEFT or BOTTOMLEFT, frame, top and TOPLEFT or BOTTOMLEFT, 0, 0)
        line:SetAnchor(top and TOPRIGHT or BOTTOMRIGHT, frame, top and TOPRIGHT or BOTTOMRIGHT, 0, 0)
        bindColor(line, "SetColor", color)
        line:SetDrawLayer(DL_OVERLAY)
        line:SetDrawLevel(250)
        table.insert(frame.lines, line)
    end

    local function vertical(suffix, left)
        local line = wm:CreateControl(name .. suffix, frame, CT_TEXTURE)
        line:SetWidth(thickness)
        line:SetAnchor(left and TOPLEFT or TOPRIGHT, frame, left and TOPLEFT or TOPRIGHT, 0, 0)
        line:SetAnchor(left and BOTTOMLEFT or BOTTOMRIGHT, frame, left and BOTTOMLEFT or BOTTOMRIGHT, 0, 0)
        bindColor(line, "SetColor", color)
        line:SetDrawLayer(DL_OVERLAY)
        line:SetDrawLevel(250)
        table.insert(frame.lines, line)
    end

    horizontal("Top", true)
    horizontal("Bottom", false)
    vertical("Left", true)
    vertical("Right", false)
    return frame
end

local function setStrokeColor(frame, color)
    if not frame or not frame.lines then return end
    for _, line in ipairs(frame.lines) do line:SetColor(unpack(color)) end
end

local function makePanel(parent, name, x, y, width, height, centerColor)
    local panel = wm:CreateControl(name, parent, CT_CONTROL)
    panel:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    panel:SetDimensions(width, height)
    panel.bg = makeBackdrop(panel, name .. "Backdrop", centerColor or C.panel, {0, 0, 0, 0}, 0)
    panel.bg:SetEdgeColor(0, 0, 0, 0)
    return panel
end

local function makeSectionBand(parent, name, height, x, width, color)
    local band = wm:CreateControl(name, parent, CT_BACKDROP)
    x = x or 1
    band:SetAnchor(TOPLEFT, parent, TOPLEFT, x, 1)
    if width then
        band:SetDimensions(width, height)
    else
        band:SetAnchor(TOPRIGHT, parent, TOPRIGHT, -1, 1)
        band:SetHeight(height)
    end
    bindColor(band, "SetCenterColor", color or C.section)
    band:SetEdgeColor(0, 0, 0, 0)
    band:SetMouseEnabled(false)
    band:SetDrawLayer(DL_BACKGROUND)
    band:SetDrawLevel(2)

    local rule = wm:CreateControl(name .. "Rule", band, CT_TEXTURE)
    rule:SetAnchor(BOTTOMLEFT, band, BOTTOMLEFT, 0, 0)
    rule:SetAnchor(BOTTOMRIGHT, band, BOTTOMRIGHT, 0, 0)
    rule:SetHeight(1)
    bindColor(rule, "SetColor", C.structuralRule)
    return band
end

local function makeLabel(parent, name, text, font, color, oneLine)
    local label = wm:CreateControl(name, parent, CT_LABEL)
    bindFont(label, font or FONT_UI)
    label:SetText(text or "")
    bindColor(label, "SetColor", color or C.text)
    if oneLine then label:SetWrapMode(TEXT_WRAP_MODE_ELLIPSIS) end
    return label
end

local function createHeaderIcon(parent, name, kind, color)
    local icon = wm:CreateControl(name, parent, CT_CONTROL)
    icon:SetDimensions(14, 14)
    icon:SetMouseEnabled(false)
    icon.parts = {}

    local function part(suffix, x, y, w, h, alpha)
        local p = wm:CreateControl(name .. suffix, icon, CT_TEXTURE)
        p:SetAnchor(TOPLEFT, icon, TOPLEFT, x, y)
        p:SetDimensions(w, h)
        local c = color or C.title
        if alpha then
            -- Preserve the deliberate relative opacity of multi-part glyphs.
            p.dmcIconAlpha = alpha
            p.dmcIconColorKey = getColorKey(c)
            p:SetColor(c[1], c[2], c[3], alpha)
            UI.themeIconParts[#UI.themeIconParts + 1] = p
        else
            bindColor(p, "SetColor", c)
        end
        p:SetDrawLayer(DL_OVERLAY)
        p:SetDrawLevel(25)
        table.insert(icon.parts, p)
    end

    if kind == "list" then
        part("Dot1", 0, 2, 2, 2, 0.95)
        part("Line1", 4, 2, 9, 2, 0.90)
        part("Dot2", 0, 6, 2, 2, 0.82)
        part("Line2", 4, 6, 9, 2, 0.78)
        part("Dot3", 0, 10, 2, 2, 0.72)
        part("Line3", 4, 10, 9, 2, 0.68)
    elseif kind == "notes" then
        part("Top", 1, 0, 10, 1, 0.90)
        part("Left", 1, 0, 1, 12, 0.90)
        part("Right", 10, 0, 1, 12, 0.90)
        part("Bottom", 1, 11, 10, 1, 0.90)
        part("Clip", 4, 0, 4, 2, 0.95)
        part("Line1", 3, 4, 6, 1, 0.75)
        part("Line2", 3, 7, 6, 1, 0.60)
    elseif kind == "mechanics" then
        part("Bar", 6, 1, 2, 8, 0.92)
        part("Dot", 6, 11, 2, 2, 0.82)
        part("Accent", 3, 1, 2, 2, 0.62)
        part("Accent2", 9, 1, 2, 2, 0.62)
    elseif kind == "bosses" then
        part("Top", 1, 1, 8, 1, 0.92)
        part("Left", 1, 1, 1, 8, 0.92)
        part("Right", 8, 1, 1, 8, 0.92)
        part("Bottom", 1, 8, 8, 1, 0.92)
        part("Center", 4, 4, 2, 2, 0.95)
        part("Side", 11, 4, 2, 2, 0.68)
    end
    return icon
end

local function makeButton(parent, name, text, callback, font, suppressNativeText)
    local button = wm:CreateControl(name, parent, CT_BUTTON)
    bindFont(button, font or FONT_UI)
    button:SetText(text or "")
    if suppressNativeText then
        -- Pill and segment controls draw an optically-centered child caption.
        -- Do not bind the native button label to the theme or it will become
        -- visible again after a live palette refresh beneath that caption.
        button:SetNormalFontColor(0, 0, 0, 0)
        button:SetMouseOverFontColor(0, 0, 0, 0)
        button:SetPressedFontColor(0, 0, 0, 0)
        button:SetDisabledFontColor(0, 0, 0, 0)
    else
        bindColor(button, "SetNormalFontColor", C.buttonText)
        bindColor(button, "SetMouseOverFontColor", C.buttonHoverText)
        bindColor(button, "SetPressedFontColor", C.buttonPressedText)
    end
    if callback then button:SetHandler("OnClicked", callback) end
    return button
end

local function setPillText(button, text)
    if not button then return end
    text = text or ""
    button:SetText(text)
    if button.caption then button.caption:SetText(text) end
end

local function applyPillVisual(button)
    if not button or not button.bg then return end
    local fill, edge, textColor
    if button.isEnabled == false then
        fill, edge, textColor = C.pillDisabled, C.pillDisabledEdge, C.buttonDisabledText
    elseif button.isPressed then
        fill, edge, textColor = C.pillPressed, C.pillSelectedEdge, C.title
    elseif button.isSelected then
        fill, edge, textColor = C.pillSelected, C.pillSelectedEdge, C.title
    elseif button.iconStyle and button.isHovered then
        fill, edge, textColor = C.iconPillHover, C.pillHoverEdge, C.text
    elseif button.iconStyle then
        fill, edge, textColor = C.iconPill, C.iconPillEdge, C.buttonText
    elseif button.variant == "primary" and button.isHovered then
        fill, edge, textColor = C.pillPrimaryHover, C.pillSelectedEdge, C.text
    elseif button.variant == "primary" then
        fill, edge, textColor = C.pillSelected, C.pillSelectedEdge, C.title
    elseif button.isHovered then
        fill, edge, textColor = C.pillHover, C.pillHoverEdge, C.text
    else
        fill, edge, textColor = C.pill, C.pillEdge, C.buttonText
    end
    button.bg:SetCenterColor(unpack(fill))
    button.bg:SetEdgeColor(unpack(edge))
    setStrokeColor(button.frame, edge)
    if button.caption then button.caption:SetColor(unpack(textColor)) end
    if button.icon then button.icon:SetColor(unpack(textColor)) end
end

local function makePill(parent, name, text, callback, font)
    local button = makeButton(parent, name, text, callback, font or "ZoFontGameSmall", true)
    button.bg = wm:CreateControl(name .. "Bg", button, CT_BACKDROP)
    button.bg:SetAnchorFill(button)
    bindColor(button.bg, "SetCenterColor", C.pill)
    button.bg:SetEdgeColor(0, 0, 0, 0)
    button.bg:SetMouseEnabled(false)
    button.bg:SetDrawLayer(DL_BACKGROUND)
    button.bg:SetDrawLevel(10)
    button.frame = makeWindowStroke(button, name .. "Frame", 1, 0, C.pillEdge)
    button.caption = makeLabel(button, name .. "Label", text or "", font or "ZoFontGameSmall", C.buttonText, true)
    button.caption:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 0)
    button.caption:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -2, 0)
    button.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetMouseEnabled(false)
    button.caption:SetDrawLayer(DL_OVERLAY)
    button.caption:SetDrawLevel(20)
    button:SetNormalFontColor(0, 0, 0, 0)
    button:SetMouseOverFontColor(0, 0, 0, 0)
    button:SetPressedFontColor(0, 0, 0, 0)
    button:SetDisabledFontColor(0, 0, 0, 0)
    button.isEnabled = true
    button:SetHandler("OnMouseEnter", function(control)
        control.isHovered = true
        applyPillVisual(control)
    end)
    button:SetHandler("OnMouseExit", function(control)
        control.isHovered = false
        control.isPressed = false
        applyPillVisual(control)
    end)
    button:SetHandler("OnMouseDown", function(control)
        control.isPressed = true
        applyPillVisual(control)
    end)
    button:SetHandler("OnMouseUp", function(control)
        control.isPressed = false
        applyPillVisual(control)
    end)
    applyPillVisual(button)
    UI.themeButtons[#UI.themeButtons + 1] = button
    return button
end

local function layoutPasteIcon(button, partNumber)
    if not button or not button.icon then return end
    button.pastePart = partNumber
    button.icon:ClearAnchors()
    button.caption:ClearAnchors()
    if partNumber then
        button.icon:SetAnchor(LEFT, button, LEFT, 6, 0)
        button.icon:SetDimensions(15, 15)
        button.caption:SetAnchor(TOPLEFT, button, TOPLEFT, 22, 0)
        button.caption:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -4, 0)
        button.caption:SetText(tostring(partNumber))
        button.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    else
        button.icon:SetAnchor(CENTER, button, CENTER, 0, 0)
        button.icon:SetDimensions(16, 16)
        button.caption:SetText("")
        button.caption:SetAnchorFill(button)
    end
    button.caption:SetVerticalAlignment(TEXT_ALIGN_CENTER)
end

local function makePasteIconButton(parent, name, callback)
    local button = makePill(parent, name, "", callback, FONT_META_BOLD)
    button.iconStyle = true
    button.icon = wm:CreateControl(name .. "Icon", button, CT_TEXTURE)
    button.icon:SetTexture("DungeonMechsCodex/paste_icon.dds")
    button.icon:SetMouseEnabled(false)
    button.icon:SetDrawLayer(DL_OVERLAY)
    button.icon:SetDrawLevel(22)
    layoutPasteIcon(button, nil)
    ZO_PostHookHandler(button, "OnMouseEnter", function(control)
        local text = control.pastePart and ("Paste part " .. tostring(control.pastePart)) or "Paste"
        showCompactHint(control, text)
    end)
    ZO_PostHookHandler(button, "OnMouseExit", hideCompactHint)
    applyPillVisual(button)
    return button
end

local function applySegmentVisual(button)
    if not button or not button.bg then return end
    local fill, textColor
    if button.isEnabled == false then
        fill, textColor = C.pillDisabled, C.buttonDisabledText
    elseif button.isPressed then
        fill, textColor = C.segmentPressed, C.title
    elseif button.isSelected then
        fill, textColor = C.segmentSelected, C.title
    elseif button.isHovered then
        fill, textColor = C.segmentHover, C.text
    else
        fill, textColor = C.segment, C.buttonText
    end
    button.bg:SetCenterColor(unpack(fill))
    if button.caption then button.caption:SetColor(unpack(textColor)) end
    if button.activeBar then button.activeBar:SetHidden(not button.isSelected) end
end

local function makeSegmentButton(parent, name, text, callback, font)
    local button = makeButton(parent, name, text, callback, font or "ZoFontGameSmall", true)
    button.bg = wm:CreateControl(name .. "Bg", button, CT_BACKDROP)
    button.bg:SetAnchorFill(button)
    button.bg:SetCenterColor(unpack(C.segment))
    button.bg:SetEdgeColor(0, 0, 0, 0)
    button.bg:SetMouseEnabled(false)
    button.bg:SetDrawLayer(DL_BACKGROUND)
    button.bg:SetDrawLevel(10)

    button.caption = makeLabel(button, name .. "Label", text or "", font or "ZoFontGameSmall", C.buttonText, true)
    button.caption:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 0)
    button.caption:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -2, 0)
    button.caption:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    button.caption:SetMouseEnabled(false)
    button.caption:SetDrawLayer(DL_OVERLAY)
    button.caption:SetDrawLevel(20)

    button.activeBar = wm:CreateControl(name .. "ActiveBar", button, CT_TEXTURE)
    button.activeBar:SetAnchor(BOTTOMLEFT, button, BOTTOMLEFT, 7, 0)
    button.activeBar:SetAnchor(BOTTOMRIGHT, button, BOTTOMRIGHT, -7, 0)
    button.activeBar:SetHeight(2)
    bindColor(button.activeBar, "SetColor", C.edge)
    button.activeBar:SetDrawLayer(DL_OVERLAY)
    button.activeBar:SetDrawLevel(25)
    button.activeBar:SetHidden(true)

    button:SetNormalFontColor(0, 0, 0, 0)
    button:SetMouseOverFontColor(0, 0, 0, 0)
    button:SetPressedFontColor(0, 0, 0, 0)
    button:SetDisabledFontColor(0, 0, 0, 0)
    button.isEnabled = true
    button.isSegment = true
    button:SetHandler("OnMouseEnter", function(control)
        control.isHovered = true
        applySegmentVisual(control)
    end)
    button:SetHandler("OnMouseExit", function(control)
        control.isHovered = false
        control.isPressed = false
        applySegmentVisual(control)
    end)
    button:SetHandler("OnMouseDown", function(control)
        control.isPressed = true
        applySegmentVisual(control)
    end)
    button:SetHandler("OnMouseUp", function(control)
        control.isPressed = false
        applySegmentVisual(control)
    end)
    applySegmentVisual(button)
    UI.themeButtons[#UI.themeButtons + 1] = button
    return button
end

local function setSelectedButton(button, selected)
    if not button then return end
    button.isSelected = selected
    if button.isSegment then applySegmentVisual(button) else applyPillVisual(button) end
end

local function setButtonEnabled(button, enabled)
    if not button then return end
    button.isEnabled = enabled
    button:SetEnabled(enabled)
    button:SetAlpha(1)
    if button.caption then
        if button.isSegment then applySegmentVisual(button) else applyPillVisual(button) end
    else
        button:SetAlpha(enabled and 1 or 0.55)
    end
end

local function colorMarkup(color, text)
    color = color or C.text
    local function channel(value)
        return math.max(0, math.min(255, math.floor((tonumber(value) or 0) * 255 + 0.5)))
    end
    return string.format("|c%02X%02X%02X%s|r", channel(color[1]), channel(color[2]), channel(color[3]), tostring(text or ""))
end

local function shortFlags(boss)
    if not boss or not boss.flags then return "" end
    local out, seen = {}, {}
    local function add(label)
        if not seen[label] then
            seen[label] = true
            table.insert(out, label)
        end
    end
    for _, flag in ipairs(boss.flags) do
        local normalized = DMC.NormalizeText(flag)
        if normalized == "secret" then add("Secret")
        elseif normalized == "super secret" then add("Secret+")
        elseif normalized == "final" then add("Final")
        elseif normalized == "main" then add("Main")
        end
    end
    return #out > 0 and ("  " .. colorMarkup(C.bossFlagText, table.concat(out, " "))) or ""
end

local function plainFlags(boss)
    if not boss or not boss.flags then return "" end
    local out, seen = {}, {}
    local function add(label)
        if not seen[label] then seen[label] = true table.insert(out, label) end
    end
    for _, flag in ipairs(boss.flags) do
        local normalized = DMC.NormalizeText(flag)
        if normalized == "secret" then add("Secret")
        elseif normalized == "super secret" then add("Secret+")
        elseif normalized == "final" then add("Final")
        elseif normalized == "main" then add("Main") end
    end
    return table.concat(out, " ")
end

local function getDungeonSummaryText(dungeon)
    if not dungeon or not dungeon.summary then return "" end
    return DMC.GetModeText(dungeon.summary, {"ui", "full"}, UI.mode)
end

local function getBossSummaryText(boss)
    if not boss then return "" end
    return DMC.GetModeText(boss, {"ui", "summary"}, UI.mode)
end

local function stripForUI(text)
    return DMC.StripChatFormatting(text or "")
end

local function setPasteButton(button, chatText, label)
    if not button then return end
    button.chatText = chatText
    button:SetHidden(not chatText or chatText == "")
    if chatText then
        if button.iconStyle then
            local partNumber = label and tostring(label):match("(%d+)$") or nil
            layoutPasteIcon(button, partNumber)
        else
            setPillText(button, label or "PASTE")
        end
    end
end

local function layoutDungeonPasteButtons(lineCount)
    local count = math.min(lineCount or 0, #UI.dungeonPasteButtons)
    local buttonWidth, gap = 42, 5
    local rightInset = 16
    local rightEdge = RIGHT_WIDTH - rightInset
    local topY = 7
    local totalWidth = count > 0 and (count * buttonWidth + math.max(0, count - 1) * gap) or 0
    local startX = rightEdge - totalWidth

    for index, button in ipairs(UI.dungeonPasteButtons) do
        if index <= count then
            button:ClearAnchors()
            button:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, startX + (index - 1) * (buttonWidth + gap), topY)
            button:SetDimensions(buttonWidth, 25)
        end
    end

    local pasteLabelWidth = 38
    local pasteLabelLeft = count > 0 and (startX - pasteLabelWidth - 7) or rightEdge
    if UI.dungeonPasteLabel then
        UI.dungeonPasteLabel:ClearAnchors()
        UI.dungeonPasteLabel:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, pasteLabelLeft, topY + 2)
        UI.dungeonPasteLabel:SetHidden(count == 0)
    end

    local modeWidth = UI.modeGroup and not UI.modeGroup:IsHidden() and 92 or 0
    local modeRight = count > 0 and (pasteLabelLeft - 10) or rightEdge
    local modeLeft = modeRight - modeWidth
    if UI.modeGroup and modeWidth > 0 then
        UI.modeGroup:ClearAnchors()
        UI.modeGroup:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, modeLeft, topY)
    end
    local titleRight = modeLeft - (modeWidth > 0 and 12 or 0)
    if UI.statusLabel and not UI.statusLabel:IsHidden() then
        UI.statusLabel:ClearAnchors()
        UI.statusLabel:SetAnchor(TOPRIGHT, UI.dungeonPanel, TOPRIGHT, -(RIGHT_WIDTH - startX + 10), 12)
        UI.statusLabel:SetDimensions(116, 20)
        titleRight = startX - 136
    end
    UI.dungeonTitleAvailableWidth = math.min(600, math.max(300, titleRight - DUNGEON_TITLE_X))
end

local function applyActivityCapabilities(activity)
    if not activity then return end
    local capabilities = DMC.GetActivityCapabilities(activity)
    local preferredMode = DMC.GetDifficultyMode(DMC.sv and DMC.sv.mode or UI.mode)
    UI.mode = DMC.ActivitySupports(activity, "difficulties", preferredMode)
        and preferredMode or (capabilities.difficulties[1] or "vet")

    local preferredRole = getSessionState().roleFilter
    UI.roleFilter = DMC.ActivitySupports(activity, "roles", preferredRole)
        and preferredRole or (capabilities.roles[1] or "all")

    local supportedRoles = {}
    for _, role in ipairs(ROLE_ORDER) do
        if DMC.ActivitySupports(activity, "roles", role) then
            supportedRoles[#supportedRoles + 1] = role
        end
    end
    local segmentWidth = 65
    UI.roleGroup:SetDimensions(math.max(segmentWidth, #supportedRoles * segmentWidth), 30)
    local visibleIndex = 0
    for _, role in ipairs(ROLE_ORDER) do
        local button = UI.roleButtons and UI.roleButtons[role]
        local supported = DMC.ActivitySupports(activity, "roles", role)
        if button then
            button:SetHidden(not supported)
            if supported then
                button:ClearAnchors()
                button:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, visibleIndex * segmentWidth, 0)
                button:SetDimensions(segmentWidth, 30)
                visibleIndex = visibleIndex + 1
            end
        end
        local separator = UI.roleSeparators and UI.roleSeparators[role]
        if separator then
            separator:SetHidden(not supported or visibleIndex <= 1)
            if supported and visibleIndex > 1 then
                separator:ClearAnchors()
                separator:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, (visibleIndex - 1) * segmentWidth, 5)
                separator:SetAnchor(BOTTOMLEFT, UI.roleGroup, BOTTOMLEFT, (visibleIndex - 1) * segmentWidth, -5)
            end
        end
    end

    UI.modeGroup:SetHidden(#(capabilities.difficulties or {}) < 2)
    setSelectedButton(UI.modeVet, UI.mode == "vet")
    setSelectedButton(UI.modeHm, UI.mode == "hm")
    for _, role in ipairs(ROLE_ORDER) do
        setSelectedButton(UI.roleButtons and UI.roleButtons[role], UI.roleFilter == role)
    end
end

local function layoutDungeonTitle(dungeon)
    if not UI.dungeonTitle or not UI.dungeonDlc then return end
    local titleMax = UI.dungeonTitleAvailableWidth or 500
    local dlcText = tostring(dungeon and dungeon.dlc or "")
    local hasDlc = dlcText ~= "" and DMC.ShouldShowAppearanceElement("showDlcTags")
    local dungeonNameMax = math.max(180, titleMax - (hasDlc and 124 or 0))

    UI.dungeonTitle:SetText(dungeon and dungeon.name or "Select an activity")
    UI.dungeonTitle:SetDimensions(dungeonNameMax, 30)
    local dungeonNameWidth = math.min(dungeonNameMax, math.ceil(UI.dungeonTitle:GetTextWidth() + 2))
    UI.dungeonTitle:SetDimensions(dungeonNameWidth, 30)

    UI.dungeonDlc:ClearAnchors()
    UI.dungeonDlc:SetAnchor(LEFT, UI.dungeonTitle, RIGHT, 10, 1)
    UI.dungeonDlc:SetText(dlcText)
    UI.dungeonDlc:SetHidden(not hasDlc)
    local dlcMax = math.max(0, titleMax - dungeonNameWidth - 14)
    UI.dungeonDlc:SetDimensions(math.min(190, dlcMax), 20)
end

local function layoutBossPasteButtons(lineCount)
    local count = math.min(lineCount or 0, #UI.bossPasteButtons)
    local buttonWidth, gap = 42, 4
    local rightX = 520
    local totalWidth = count * buttonWidth + math.max(0, count - 1) * gap
    local startX = rightX - totalWidth

    for index, button in ipairs(UI.bossPasteButtons) do
        if index <= count then
            button:ClearAnchors()
            button:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, startX + (index - 1) * (buttonWidth + gap), 7)
            button:SetDimensions(buttonWidth, 25)
        end
    end
    UI.bossTitleAvailableWidth = count > 0 and math.max(170, startX - 24) or 504
end

local function layoutSelectedBossTitle(boss)
    if not UI.bossTitle or not UI.bossMeta then return end
    local available = UI.bossTitleAvailableWidth or 504
    local meta = plainFlags(boss)
    UI.bossMeta:SetText(meta)
    local metaWidth = meta ~= "" and math.min(90, math.max(54, math.ceil(UI.bossMeta:GetTextWidth() + 12))) or 0
    local nameMax = math.max(150, available - (metaWidth > 0 and (metaWidth + 8) or 0))
    UI.bossTitle:SetDimensions(nameMax, 28)
    UI.bossTitle:SetText(boss and boss.name or "")
    local nameWidth = math.min(nameMax, math.ceil(UI.bossTitle:GetTextWidth() + 2))
    UI.bossTitle:SetDimensions(nameWidth, 28)
    UI.bossMeta:ClearAnchors()
    UI.bossMeta:SetAnchor(LEFT, UI.bossTitle, RIGHT, 7, 1)
    UI.bossMeta:SetDimensions(metaWidth, 20)
    UI.bossMeta:SetHidden(meta == "")
end

local function measureBossRowWidth(text)
    if not UI.bossMeasureLabel then return 260 end
    UI.bossMeasureLabel:SetText(text or "")
    return math.ceil(UI.bossMeasureLabel:GetTextWidth() + 30)
end

local function layoutBossListTable(bossCount)
    bossCount = bossCount or 0
    local rowsPerColumn = math.max(1, math.ceil(bossCount / 2))
    local leftCount = math.min(rowsPerColumn, bossCount)
    local rightCount = math.max(0, bossCount - leftCount)
    local rightStart = leftCount + 1
    local topY = 39
    local rowHeight = rowsPerColumn > 4 and 16 or 20
    local leftX, totalWidth, gap = 16, 908, 20
    local leftMin, rightMin, leftMax = 250, 280, 520

    local leftNeed = leftMin
    for index = 1, leftCount do
        local button = UI.bossButtons[index]
        if button and button.bossId then
            leftNeed = math.max(leftNeed, measureBossRowWidth(button.measureText))
        end
    end

    local rightNeed = rightMin
    for index = rightStart, rightStart + rightCount - 1 do
        local button = UI.bossButtons[index]
        if button and button.bossId then
            rightNeed = math.max(rightNeed, measureBossRowWidth(button.measureText))
        end
    end

    local usable = totalWidth - (rightCount > 0 and gap or 0)
    local leftWidth
    if rightCount == 0 then
        leftWidth = zo_clamp(leftNeed, leftMin, math.min(leftMax, usable))
    elseif leftNeed + rightNeed <= usable then
        leftWidth = zo_clamp(leftNeed, leftMin, math.min(leftMax, usable - rightMin))
    else
        local combined = math.max(1, leftNeed + rightNeed)
        local proportional = math.floor(usable * (leftNeed / combined) + 0.5)
        leftWidth = zo_clamp(proportional, leftMin, math.min(leftMax, usable - rightMin))
    end

    local rightX = leftX + leftWidth + gap
    local rightWidth = math.max(rightMin, totalWidth - leftWidth - gap)

    for index, button in ipairs(UI.bossButtons) do
        if button.bossId then
            local column = index <= leftCount and 0 or 1
            local row = column == 0 and (index - 1) or (index - rightStart)
            button:ClearAnchors()
            if column == 0 then
                button:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, leftX, topY + row * rowHeight)
                button:SetDimensions(leftWidth, rowHeight - 1)
            else
                button:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, rightX, topY + row * rowHeight)
                button:SetDimensions(rightWidth, rowHeight - 1)
            end
        end
    end
end

local function makeNativeScroll(parent, name, x, y, width, height)
    local scroll = wm:CreateControlFromVirtual(name, parent, "ZO_ScrollContainer")
    scroll:SetAnchor(TOPLEFT, parent, TOPLEFT, x, y)
    scroll:SetDimensions(width, height)
    local child = scroll:GetNamedChild("ScrollChild")
    child:SetResizeToFitDescendents(false)
    ZO_Scroll_SetUseFadeGradient(scroll, false)
    return scroll, child
end

local function updateNativeScroll(scroll, child, contentWidth, contentHeight, reset)
    if not scroll or not child then return end
    child:SetDimensions(contentWidth, math.max(1, contentHeight))
    local function update()
        if reset then ZO_Scroll_ResetToTop(scroll) end
        ZO_Scroll_UpdateScrollBar(scroll, true)
    end
    update()
    zo_callLater(update, 0)
end

local function makeScrollableText(parent, name, x, y, width, height, font, color)
    local scroll, child = makeNativeScroll(parent, name .. "Scroll", x, y, width, height)
    local contentWidth = width - 24
    local label = makeLabel(child, name .. "Label", "", font or "ZoFontGameSmall", color or C.text, false)
    label:SetAnchor(TOPLEFT, child, TOPLEFT, 0, 0)
    label:SetDimensions(contentWidth, height)
    return {
        scroll = scroll,
        child = child,
        label = label,
        contentWidth = contentWidth,
        viewHeight = height,
    }
end

local function setScrollableText(view, text, reset)
    if not view then return end
    view.label:SetText(text or "")
    view.label:SetDimensions(view.contentWidth, 1000)
    local contentHeight = math.max(view.viewHeight, math.ceil(view.label:GetTextHeight() + 6))
    view.label:SetDimensions(view.contentWidth, contentHeight)
    updateNativeScroll(view.scroll, view.child, view.contentWidth, contentHeight, reset ~= false)
end

local function forwardWheel(scroll)
    return function(_, delta)
        ZO_Scroll_OnMouseWheel(scroll, delta)
    end
end

local function findCurrentDungeon()
    return DMC.GetCurrentDungeon()
end

local function getCurrentBoss()
    local dungeon = DMC.GetDungeonById(UI.selectedDungeonId)
    return dungeon, DMC.GetBossById(dungeon, UI.selectedBossId)
end

local function refreshNoteControls()
    if not UI.noteEdit then return end
    local dungeon, boss = getCurrentBoss()
    local hasBoss = dungeon ~= nil and boss ~= nil
    local text = UI.noteEdit:GetText() or ""
    local dirty = hasBoss and text ~= (UI.noteOriginal or "")
    local count = ZoUTF8StringLength(text)

    UI.noteCounter:SetText(string.format("%d / %d", count, DMC.personalNoteMaxChars or 900))
    if not hasBoss then
        UI.noteStatus:SetText("SELECT A BOSS")
        UI.noteStatus:SetColor(unpack(C.quiet))
    elseif dirty then
        UI.noteStatus:SetText("UNSAVED")
        UI.noteStatus:SetColor(unpack(C.warning))
    else
        UI.noteStatus:SetText(text ~= "" and "SAVED" or "")
        UI.noteStatus:SetColor(unpack(C.ok))
    end

    setButtonEnabled(UI.noteSave, dirty)
    setButtonEnabled(UI.noteRevert, dirty)
    local chatLines = hasBoss and DMC.BuildBossNoteChatLines(text) or {}
    if UI.notePasteLabel then UI.notePasteLabel:SetHidden(#chatLines == 0) end
    for index, button in ipairs(UI.notePasteButtons) do
        local line = chatLines[index]
        setPasteButton(button, line, tostring(index))
        setButtonEnabled(button, line ~= nil)
    end
    UI.noteEdit:SetEditEnabled(hasBoss)
end

local function loadCurrentBossNote()
    if not UI.noteEdit then return end
    local dungeon, boss = getCurrentBoss()
    local mode = DMC.GetDifficultyMode(UI.mode)
    local text = boss and DMC.GetBossNote(dungeon.id, boss.id, mode) or ""
    UI.noteLoading = true
    UI.noteEdit:SetText(text)
    UI.noteLoading = false
    UI.noteOriginal = text
    UI.noteLoadedDungeonId = dungeon and dungeon.id or nil
    UI.noteLoadedBossId = boss and boss.id or nil
    UI.noteLoadedMode = boss and mode or nil
    if UI.noteTitle then
        UI.noteTitle:SetText(mode == "vet" and "PERSONAL NOTES · VET" or "PERSONAL NOTES · HM")
    end
    refreshNoteControls()
end

function DMC.SavePersonalBossNote(showStatus)
    if not UI.noteEdit then return end
    local dungeon, boss = getCurrentBoss()
    local dungeonId = UI.noteLoadedDungeonId or (dungeon and dungeon.id)
    local bossId = UI.noteLoadedBossId or (boss and boss.id)
    local mode = UI.noteLoadedMode or UI.mode
    if not dungeonId or not bossId then return end

    local saved = DMC.SetBossNote(dungeonId, bossId, UI.noteEdit:GetText(), mode)
    if UI.noteEdit:GetText() ~= saved then
        UI.noteLoading = true
        UI.noteEdit:SetText(saved)
        UI.noteLoading = false
    end
    UI.noteOriginal = saved
    refreshNoteControls()
    if showStatus ~= false then
        UI.noteStatus:SetText(saved ~= "" and "SAVED" or "CLEARED")
        UI.noteStatus:SetColor(unpack(C.ok))
    end
end

local function saveCurrentNoteIfDirty()
    if UI.noteEdit and not UI.noteLoading and UI.noteLoadedBossId then
        if (UI.noteEdit:GetText() or "") ~= (UI.noteOriginal or "") then
            DMC.SavePersonalBossNote(false)
        end
    end
end

local function revertPersonalBossNote()
    if not UI.noteEdit then return end
    UI.noteLoading = true
    UI.noteEdit:SetText(UI.noteOriginal or "")
    UI.noteLoading = false
    refreshNoteControls()
    UI.noteStatus:SetText("REVERTED")
    UI.noteStatus:SetColor(unpack(C.muted))
end

local function pastePersonalBossNoteChunk(control)
    local chatText = control and control.chatText
    if not UI.noteEdit or not chatText then return end
    DMC.SavePersonalBossNote(false)
    DMC.PasteBossNoteToChat(chatText)
end

local function setDungeonButtonState(button, selected, current)
    if not button then return end
    button.isSelected = selected
    button.isCurrent = current

    -- Auto-detection is indicated purely by typography now: green + bold.
    -- Keep that treatment even when the detected dungeon is also selected.
    if current then
        button.dmcFontRole = FONT_UI_BOLD
        button:SetFont(DMC.GetAppearanceFont(FONT_UI_BOLD))
        button:SetNormalFontColor(unpack(C.currentText))
    else
        button.dmcFontRole = FONT_UI
        button:SetFont(DMC.GetAppearanceFont(FONT_UI))
        if selected then
            button:SetNormalFontColor(unpack(C.rowSelectedText))
        else
            button:SetNormalFontColor(unpack(C.rowText))
        end
    end

    if selected then
        button.bg:SetCenterColor(unpack(C.rowSelected))
        button.accent:SetColor(unpack(C.edge))
        button.accent:SetHidden(false)
    elseif current then
        button.bg:SetCenterColor(unpack(C.currentRow))
        button.accent:SetColor(unpack(C.ok))
        button.accent:SetHidden(false)
    elseif button.isHovered then
        button.bg:SetCenterColor(unpack(C.rowHover))
        button.accent:SetHidden(true)
    else
        button.bg:SetCenterColor(unpack(C.row))
        button.accent:SetHidden(true)
    end
end

local function ensureDungeonButton(index)
    if UI.dungeonButtons[index] then return UI.dungeonButtons[index] end
    local button = makeButton(UI.dungeonListChild, "DMC_DungeonButton" .. index, "", function(control)
        if not control.dungeonId then return end
        if control.dungeonId == UI.selectedDungeonId then
            -- Repeated selection has no content work to do, but it remains a
            -- convenient manual health check if ESO evicted the active image.
            applyArtworkAppearance()
        else
            DMC.SelectDungeon(control.dungeonId)
        end
    end, FONT_UI)
    button:SetDimensions(DUNGEON_CONTENT_WIDTH, DMC.GetActivityRowHeight() - 1)
    button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
    button:SetHandler("OnMouseWheel", forwardWheel(UI.dungeonListScroll))

    button.bg = wm:CreateControl("DMC_DungeonButton" .. index .. "Bg", button, CT_BACKDROP)
    button.bg:SetAnchorFill(button)
    button.bg:SetCenterColor(unpack(C.row))
    button.bg:SetEdgeColor(0, 0, 0, 0)
    button.bg:SetMouseEnabled(false)
    button.bg:SetDrawLayer(DL_BACKGROUND)

    button.accent = wm:CreateControl("DMC_DungeonButton" .. index .. "Accent", button, CT_TEXTURE)
    button.accent:SetAnchor(TOPLEFT, button, TOPLEFT, 2, 3)
    button.accent:SetAnchor(BOTTOMLEFT, button, BOTTOMLEFT, 2, -3)
    button.accent:SetWidth(3)
    button.accent:SetHidden(true)

    button:SetHandler("OnMouseEnter", function(control)
        control.isHovered = true
        if not control.isSelected and not control.isCurrent then
            control.bg:SetCenterColor(unpack(C.rowHover))
        end
    end)
    button:SetHandler("OnMouseExit", function(control)
        control.isHovered = false
        setDungeonButtonState(control, control.isSelected, control.isCurrent)
    end)

    UI.dungeonButtons[index] = button
    return button
end

local function updateBossButtonText(button, activeChevron)
    if not button or not button.bossName then return end
    local chevron = colorMarkup(activeChevron and C.bossChevronActive or C.bossChevron, "›") .. "  "
    button:SetText(chevron .. button.bossName .. (button.bossFlagsMarkup or ""))
end

local function setBossButtonState(button, selected)
    if not button then return end
    button.isSelected = selected
    if selected then
        button:SetNormalFontColor(unpack(C.rowSelectedText))
        button.bg:SetCenterColor(unpack(C.rowSelected))
        button.accent:SetHidden(false)
    elseif button.isHovered then
        button:SetNormalFontColor(unpack(C.bossHoverText))
        button.bg:SetCenterColor(unpack(C.bossRowHover))
        button.accent:SetHidden(true)
    else
        button:SetNormalFontColor(unpack(C.bossText))
        button.bg:SetCenterColor(unpack(C.bossRow))
        button.accent:SetHidden(true)
    end
    updateBossButtonText(button, selected or button.isHovered)
end

local function ensureMechanicRow(index)
    if UI.mechanicRows[index] then return UI.mechanicRows[index] end
    local row = wm:CreateControl("DMC_MechanicRow" .. index, UI.mechanicsChild, CT_CONTROL)
    row:SetDimensions(MECHANIC_CONTENT_WIDTH, 104)
    row:SetMouseEnabled(true)
    row:SetHandler("OnMouseWheel", forwardWheel(UI.mechanicsScroll))
    local rowColor = index % 2 == 1 and C.mechanic or C.mechanicAlt
    row.bg = makeBackdrop(row, "DMC_MechanicRow" .. index .. "Bg", rowColor, {0, 0, 0, 0}, 0)
    row.bg:SetEdgeColor(0, 0, 0, 0)

    row.header = wm:CreateControl("DMC_MechanicHeader" .. index, row, CT_BACKDROP)
    row.header:SetAnchor(TOPLEFT, row, TOPLEFT, 1, 1)
    row.header:SetAnchor(TOPRIGHT, row, TOPRIGHT, -1, 1)
    row.header:SetHeight(34)
    bindColor(row.header, "SetCenterColor", C.mechanicHeader)
    row.header:SetEdgeColor(0, 0, 0, 0)
    row.header:SetMouseEnabled(false)
    row.header:SetDrawLayer(DL_BACKGROUND)
    row.header:SetDrawLevel(2)

    row.headerRule = wm:CreateControl("DMC_MechanicHeaderRule" .. index, row.header, CT_TEXTURE)
    row.headerRule:SetAnchor(BOTTOMLEFT, row.header, BOTTOMLEFT, 0, 0)
    row.headerRule:SetAnchor(BOTTOMRIGHT, row.header, BOTTOMRIGHT, 0, 0)
    row.headerRule:SetHeight(1)
    bindColor(row.headerRule, "SetColor", C.mechanicHeaderRule)

    row.bottomRule = wm:CreateControl("DMC_MechanicBottomRule" .. index, row, CT_TEXTURE)
    row.bottomRule:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 3, 0)
    row.bottomRule:SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, 0, 0)
    row.bottomRule:SetHeight(1)
    bindColor(row.bottomRule, "SetColor", C.mechanicBottomRule)
    row.bottomRule:SetDrawLayer(DL_OVERLAY)
    row.bottomRule:SetDrawLevel(20)

    row.actionSurface = wm:CreateControl("DMC_MechanicActionSurface" .. index, row, CT_BACKDROP)
    row.actionSurface:SetAnchor(TOPRIGHT, row, TOPRIGHT, -1, 35)
    row.actionSurface:SetAnchor(BOTTOMRIGHT, row, BOTTOMRIGHT, -1, -1)
    row.actionSurface:SetWidth(94)
    bindColor(row.actionSurface, "SetCenterColor", C.mechanicAction)
    row.actionSurface:SetEdgeColor(0, 0, 0, 0)
    row.actionSurface:SetMouseEnabled(false)
    row.actionSurface:SetDrawLayer(DL_BACKGROUND)
    row.actionSurface:SetDrawLevel(3)

    row.actionDivider = wm:CreateControl("DMC_MechanicActionDivider" .. index, row.actionSurface, CT_TEXTURE)
    row.actionDivider:SetAnchor(TOPLEFT, row.actionSurface, TOPLEFT, 0, 0)
    row.actionDivider:SetAnchor(BOTTOMLEFT, row.actionSurface, BOTTOMLEFT, 0, 0)
    row.actionDivider:SetWidth(1)
    bindColor(row.actionDivider, "SetColor", C.passiveRule)
    row.actionDivider:SetDrawLayer(DL_OVERLAY)
    row.actionDivider:SetDrawLevel(20)

    row.accent = wm:CreateControl("DMC_MechanicAccent" .. index, row, CT_TEXTURE)
    row.accent:SetAnchor(TOPLEFT, row, TOPLEFT, 1, 1)
    row.accent:SetAnchor(BOTTOMLEFT, row, BOTTOMLEFT, 1, -1)
    row.accent:SetWidth(3)
    bindColor(row.accent, "SetColor", C.mechanicAccent)
    row.accent:SetDrawLayer(DL_OVERLAY)
    row.accent:SetDrawLevel(240)

    row.title = makeLabel(row, "DMC_MechanicTitle" .. index, "", FONT_UI_BOLD, C.gold, true)
    row.title:SetAnchor(TOPLEFT, row, TOPLEFT, 14, 7)
    row.title:SetDimensions(MECHANIC_CONTENT_WIDTH - 128, 24)

    row.number = makeLabel(row, "DMC_MechanicNumber" .. index, "", FONT_UI_BOLD, C.quiet, true)
    row.number:SetAnchor(TOPRIGHT, row, TOPRIGHT, -14, 9)
    row.number:SetDimensions(44, 20)
    row.number:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    row.lines = {}
    row.pasteButtons = {}
    for lineIndex = 1, 3 do
        local label = makeLabel(row, "DMC_MechanicLine" .. index .. "_" .. lineIndex, "", FONT_BODY, C.bodyText, false)
        row.lines[lineIndex] = label
        local paste = makePasteIconButton(row, "DMC_MechanicPaste" .. index .. "_" .. lineIndex, function(control)
            if control.chatText then
                UI.selectedChatLine = control.chatText
                DMC.PasteToChatInput(control.chatText)
            end
        end)
        paste:SetDimensions(42, 26)
        paste:SetHandler("OnMouseWheel", forwardWheel(UI.mechanicsScroll))
        row.pasteButtons[lineIndex] = paste
    end

    UI.mechanicRows[index] = row
    return row
end

local function layoutMechanicRow(row, chatLines)
    local bodyWidth = MECHANIC_CONTENT_WIDTH - 122
    local y = 41
    local visible = math.min(#chatLines, 3)
    if visible == 0 then
        visible = 1
        chatLines = {"No written mechanic text matches this view."}
    end

    for lineIndex = 1, 3 do
        local label = row.lines[lineIndex]
        local paste = row.pasteButtons[lineIndex]
        local line = chatLines[lineIndex]
        if line then
            label:ClearAnchors()
            label:SetAnchor(TOPLEFT, row, TOPLEFT, 15, y)
            label:SetText(stripForUI(line))
            label:SetDimensions(bodyWidth, 160)
            local textHeight = math.max(22, math.ceil(label:GetTextHeight()))
            label:SetDimensions(bodyWidth, textHeight)
            label:SetHidden(false)

            paste:ClearAnchors()
            paste:SetAnchor(TOPRIGHT, row, TOPRIGHT, -26, y)
            setPasteButton(paste, line, visible > 1 and ("PASTE " .. tostring(lineIndex)) or "PASTE")
            y = y + math.max(textHeight, 26) + 8
        else
            label:SetText("")
            label:SetHidden(true)
            setPasteButton(paste, nil)
        end
    end

    local rowHeight = math.max(96, y + 9)
    row:SetDimensions(MECHANIC_CONTENT_WIDTH, rowHeight)
    return rowHeight
end

local function applyOptionalElementVisibility()
    if not UI.window then return end
    local showSectionIcons = DMC.ShouldShowAppearanceElement("showSectionIcons")
    for _, icon in ipairs({UI.dungeonSectionIcon, UI.bossListIcon, UI.noteIcon, UI.mechanicsIcon}) do
        if icon then icon:SetHidden(not showSectionIcons) end
    end

    if UI.tagline then UI.tagline:SetHidden(not DMC.ShouldShowAppearanceElement("showHeaderTagline")) end
    local showCounters = DMC.ShouldShowAppearanceElement("showCounters")
    if UI.dungeonCount then UI.dungeonCount:SetHidden(not showCounters) end
    if UI.mechanicsCount then UI.mechanicsCount:SetHidden(not showCounters) end

    if not DMC.ShouldShowAppearanceElement("showHoverHints") then hideCompactHint() end
    for _, row in ipairs(UI.mechanicRows) do
        if row.number and row.number:GetText() ~= "" then
            row.number:SetHidden(not DMC.ShouldShowAppearanceElement("showMechanicNumbers"))
        end
    end
end

local function applySearchAppearance()
    if not UI.searchBg then return end
    if UI.searchFocused then
        UI.searchBg:SetCenterColor(unpack(C.searchFocus))
        UI.searchBg:SetEdgeColor(unpack(C.fieldFocus))
    elseif UI.searchHovered then
        UI.searchBg:SetCenterColor(unpack(C.searchHover))
        UI.searchBg:SetEdgeColor(unpack(C.fieldEdge))
    else
        UI.searchBg:SetCenterColor(unpack(C.search))
        UI.searchBg:SetEdgeColor(unpack(C.fieldEdge))
    end
end

function DMC.ApplyAppearanceToUI(reflow)
    if not UI.window then return end

    for _, binding in ipairs(UI.themeColorBindings) do
        local control = binding.control
        local color = C[binding.key]
        if control and color and type(control[binding.method]) == "function" then
            control[binding.method](control, unpack(color))
        end
    end
    for _, part in ipairs(UI.themeIconParts) do
        local color = C[part.dmcIconColorKey]
        if color then
            part:SetColor(color[1], color[2], color[3], math.min(1, (part.dmcIconAlpha or 1) * (color[4] or 1)))
        end
    end
    for _, control in ipairs(UI.themeFontControls) do
        if control and control.dmcFontRole then
            control:SetFont(DMC.GetAppearanceFont(control.dmcFontRole))
        end
    end

    UI.window:SetScale(DMC.GetAppearanceValue("layout", "windowScale") / 100)
    UI.window:SetMovable(not DMC.GetAppearanceValue("layout", "lockWindowPosition"))
    if UI.closeIcon then UI.closeIcon:SetColor(unpack(UI.closeHovered and C.closeHover or C.close)) end
    if UI.settingsIcon then UI.settingsIcon:SetColor(unpack(UI.settingsHovered and C.closeHover or C.close)) end
    applySearchAppearance()
    if UI.noteBackdrop then
        UI.noteBackdrop:SetEdgeColor(unpack(UI.noteFocused and C.fieldFocus or C.fieldEdge))
    end
    applyArtworkAppearance()
    applyOptionalElementVisibility()

    for _, button in ipairs(UI.themeButtons) do
        if button.isSegment then applySegmentVisual(button) else applyPillVisual(button) end
    end
    local current = findCurrentDungeon()
    local currentDungeonId = current and current.id or false
    for _, button in ipairs(UI.dungeonButtons) do
        if button.dungeonId then
            setDungeonButtonState(button, button.dungeonId == UI.selectedDungeonId, button.dungeonId == currentDungeonId)
        end
    end
    for _, button in ipairs(UI.bossButtons) do
        if button.bossId then
            if button.bossData then button.bossFlagsMarkup = shortFlags(button.bossData) end
            setBossButtonState(button, button.bossId == UI.selectedBossId)
        end
    end
    refreshNoteControls()

    if reflow then
        DMC.RefreshDungeonList(false)
        local dungeon, boss = getCurrentBoss()
        if dungeon then
            layoutDungeonTitle(dungeon)
            local statusText = dungeon.status ~= "complete" and " Dataset stub: mechanics not written yet." or ""
            setScrollableText(UI.dungeonSummaryView, getDungeonSummaryText(dungeon) .. statusText, false)
            local bossCount = 0
            for _, button in ipairs(UI.bossButtons) do
                if button.bossId then bossCount = bossCount + 1 end
            end
            layoutBossListTable(bossCount)
            if boss then layoutSelectedBossTitle(boss) end
            DMC.RefreshBossDetails()
        end
    end
end

function DMC.InitializeUI()
    local session = getSessionState()
    UI.roleFilter = isValidRoleFilter(session.roleFilter) and session.roleFilter or "all"
    UI.mode = DMC.GetDifficultyMode(DMC.sv and DMC.sv.mode or "hm")
    UI.activityType = (session.activityType == "trial" or session.activityType == "arena")
        and session.activityType or "dungeon"
    UI.selectedDungeonId = session.selectedDungeonId
    UI.selectedBossId = session.selectedBossId

    local window = wm:CreateTopLevelWindow("DMC_MainWindow")
    UI.window = window
    window:SetDimensions(WINDOW_WIDTH, WINDOW_HEIGHT)
    local savedWindow = DMC.sv and DMC.sv.window or nil
    if savedWindow and savedWindow.x and savedWindow.y and (savedWindow.x ~= 0 or savedWindow.y ~= 0) then
        window:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, savedWindow.x, savedWindow.y)
    else
        window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    end
    window:SetMouseEnabled(true)
    window:SetMovable(true)
    window:SetClampedToScreen(true)
    window:SetHidden(true)
    window:SetDrawLayer(DL_OVERLAY)
    window:SetDrawTier(DT_HIGH)
    window:SetDrawLevel(100)
    window:SetHandler("OnMoveStop", function()
        if DMC.sv and DMC.sv.window then
            DMC.sv.window.x = window:GetLeft()
            DMC.sv.window.y = window:GetTop()
        end
    end)

    makeBackdrop(window, "DMC_MainWindowBackdrop", C.bg, {0, 0, 0, 0}, WINDOW_INSET)

    -- Paste and difficulty hints belong to the Codex window itself. This keeps
    -- them above the addon's high draw tier without invoking ESO's shared tooltip.
    UI.compactHint = wm:CreateControl("DMC_CompactHint", window, CT_BACKDROP)
    UI.compactHint:SetDimensions(54, 20)
    UI.compactHint:SetCenterTexture("EsoUI/Art/Tooltips/UI-TooltipCenter.dds")
    UI.compactHint:SetEdgeTexture("EsoUI/Art/Tooltips/UI-Tooltip-Border.dds", 128, 16)
    UI.compactHint:SetInsets(5, 5, -5, -5)
    bindColor(UI.compactHint, "SetCenterColor", C.hintSurface)
    bindColor(UI.compactHint, "SetEdgeColor", C.hintEdge)
    UI.compactHint:SetMouseEnabled(false)
    UI.compactHint:SetDrawLayer(DL_OVERLAY)
    UI.compactHint:SetDrawLevel(480)
    UI.compactHint:SetHidden(true)
    UI.compactHintLabel = makeLabel(UI.compactHint, "DMC_CompactHintLabel", "", FONT_HINT, C.muted, true)
    UI.compactHintLabel:SetAnchorFill(UI.compactHint)
    UI.compactHintLabel:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
    UI.compactHintLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    UI.compactHintLabel:SetDrawLayer(DL_OVERLAY)
    UI.compactHintLabel:SetDrawLevel(490)

    -- The tooltip-center texture used by the outer backdrop is translucent.
    -- This inset surface keeps the visible body aligned with the header and
    -- signature frame instead of exposing uneven strips of the game world.
    UI.bodySurface = wm:CreateControl("DMC_MainBodySurface", window, CT_BACKDROP)
    UI.bodySurface:SetAnchor(TOPLEFT, window, TOPLEFT, WINDOW_INSET, WINDOW_INSET + 52)
    UI.bodySurface:SetAnchor(BOTTOMRIGHT, window, BOTTOMRIGHT, -WINDOW_INSET, -WINDOW_INSET)
    bindColor(UI.bodySurface, "SetCenterColor", C.mainSurface)
    UI.bodySurface:SetEdgeColor(0, 0, 0, 0)
    UI.bodySurface:SetMouseEnabled(false)
    UI.bodySurface:SetDrawLayer(DL_BACKGROUND)
    UI.bodySurface:SetDrawLevel(1)
    makeWindowStroke(window, "DMC_MainWindowStroke", 2, WINDOW_INSET, C.edge)

    local header = wm:CreateControl("DMC_MainHeader", window, CT_BACKDROP)
    UI.header = header
    header:SetAnchor(TOPLEFT, window, TOPLEFT, WINDOW_INSET, WINDOW_INSET)
    header:SetAnchor(TOPRIGHT, window, TOPRIGHT, -WINDOW_INSET, WINDOW_INSET)
    header:SetHeight(52)
    bindColor(header, "SetCenterColor", C.header)
    header:SetEdgeColor(0, 0, 0, 0)
    header:SetDrawLayer(DL_BACKGROUND)
    header:SetDrawLevel(0)
    local headerGlow = wm:CreateControl("DMC_HeaderGlow", header, CT_TEXTURE)
    headerGlow:SetAnchor(BOTTOMLEFT, header, BOTTOMLEFT, 0, 0)
    headerGlow:SetAnchor(BOTTOMRIGHT, header, BOTTOMRIGHT, 0, 0)
    headerGlow:SetHeight(2)
    bindColor(headerGlow, "SetColor", C.edge)

    UI.brand = makeLabel(window, "DMC_Brand", "FLAMECHASERS", FONT_UI_SMALL, C.title, true)
    UI.brand:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 11)
    UI.brand:SetDimensions(170, 17)
    UI.title = makeLabel(window, "DMC_Title", "DUNGEON, TRIAL & ARENA CODEX", FONT_UI_BOLD, C.text, true)
    UI.title:SetAnchor(TOPLEFT, window, TOPLEFT, 20, 27)
    UI.title:SetDimensions(350, 22)
    UI.tagline = makeLabel(window, "DMC_Tagline", "Boss mechanics. Role-ready. Paste-ready.", FONT_UI_SMALL, C.muted, true)
    UI.tagline:SetAnchor(LEFT, UI.title, RIGHT, 14, 0)
    UI.tagline:SetDimensions(330, 22)

    -- Header actions use the same structure proven by Travel Slots' help icon:
    -- a real transparent hit target with a separately centered texture. Keeping
    -- both controls identical and anchoring one to the other avoids font-metric,
    -- texture-padding, and scale-dependent alignment drift.
    local function makeHeaderAction(name, texture, callback)
        local button = wm:CreateControl(name, window, CT_BUTTON)
        button:SetDimensions(32, 32)
        button:SetText("")
        button:SetNormalFontColor(0, 0, 0, 0)
        button:SetMouseOverFontColor(0, 0, 0, 0)
        button:SetPressedFontColor(0, 0, 0, 0)
        button:SetDisabledFontColor(0, 0, 0, 0)
        button:SetDrawLayer(DL_OVERLAY)
        button:SetDrawLevel(200)
        button:SetHandler("OnClicked", callback)

        local icon = wm:CreateControl(name .. "Icon", button, CT_TEXTURE)
        icon:SetAnchor(CENTER, button, CENTER, 0, 0)
        icon:SetDimensions(20, 20)
        icon:SetTexture(texture)
        icon:SetMouseEnabled(false)
        icon:SetDrawLayer(DL_OVERLAY)
        icon:SetDrawLevel(210)
        return button, icon
    end

    UI.close, UI.closeIcon = makeHeaderAction(
        "DMC_Close", "DungeonMechsCodex/close_icon.dds", function() DMC.HideWindow() end)
    UI.close:SetAnchor(TOPRIGHT, window, TOPRIGHT, -16, 17)
    UI.closeHovered = false
    UI.closeIcon:SetColor(unpack(C.close))
    UI.close:SetHandler("OnMouseEnter", function()
        UI.closeHovered = true
        UI.closeIcon:SetColor(unpack(C.closeHover))
    end)
    UI.close:SetHandler("OnMouseExit", function()
        UI.closeHovered = false
        UI.closeIcon:SetColor(unpack(C.close))
    end)

    UI.settings, UI.settingsIcon = makeHeaderAction(
        "DMC_Settings",
        "EsoUI/Art/Housing/Keyboard/path_settings_icon_up.dds",
        function()
            hideCompactHint()
            if not DMC.OpenSettings then return end
            -- Finish the Codex cursor-mode release before the game-menu scene
            -- takes ownership. This prevents the delayed close cleanup from
            -- disabling the cursor after LibAddonMenu has opened.
            DMC.HideWindow()
            zo_callLater(function() DMC.OpenSettings() end, 75)
        end)
    UI.settings:SetAnchor(RIGHT, UI.close, LEFT, -2, 0)
    UI.settingsHovered = false
    UI.settingsIcon:SetColor(unpack(C.close))
    UI.settings:SetHandler("OnMouseEnter", function(control)
        UI.settingsHovered = true
        UI.settingsIcon:SetColor(unpack(C.closeHover))
        showCompactHint(control, "Settings", true)
    end)
    UI.settings:SetHandler("OnMouseExit", function()
        UI.settingsHovered = false
        UI.settingsIcon:SetColor(unpack(C.close))
        hideCompactHint()
    end)

    UI.leftPanel = makePanel(window, "DMC_LeftPanel", LEFT_X, CONTENT_Y, LEFT_WIDTH, CONTENT_HEIGHT, C.panel)
    UI.sidebarDivider = wm:CreateControl("DMC_SidebarDivider", UI.leftPanel, CT_TEXTURE)
    UI.sidebarDivider:SetAnchor(TOPRIGHT, UI.leftPanel, TOPRIGHT, 0, 0)
    UI.sidebarDivider:SetAnchor(BOTTOMRIGHT, UI.leftPanel, BOTTOMRIGHT, 0, 0)
    UI.sidebarDivider:SetWidth(1)
    bindColor(UI.sidebarDivider, "SetColor", C.structuralRule)
    UI.sidebarDivider:SetDrawLayer(DL_OVERLAY)
    UI.sidebarDivider:SetDrawLevel(20)
    makeSectionBand(UI.leftPanel, "DMC_LeftPanelHeader", 34)
    UI.dungeonSectionTitle = makeLabel(UI.leftPanel, "DMC_DungeonSectionTitle", "ACTIVITIES", FONT_SECTION, C.sectionTitle, true)
    UI.dungeonSectionIcon = createHeaderIcon(UI.leftPanel, "DMC_DungeonSectionIcon", "list", C.sectionTitle)
    UI.dungeonSectionIcon:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 14, 11)
    UI.dungeonSectionTitle:SetAnchor(LEFT, UI.dungeonSectionIcon, RIGHT, 7, 0)
    UI.dungeonSectionTitle:SetDimensions(140, 22)
    UI.dungeonCount = makeLabel(UI.leftPanel, "DMC_DungeonCount", "", FONT_META, C.quiet, true)
    UI.dungeonCount:SetAnchor(TOPRIGHT, UI.leftPanel, TOPRIGHT, -14, 13)
    UI.dungeonCount:SetDimensions(96, 20)
    UI.dungeonCount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    UI.searchBg = wm:CreateControlFromVirtual("DMC_SearchBackdrop", UI.leftPanel, "ZO_SingleLineEditBackdrop_Keyboard")
    UI.searchBg:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 14, 37)
    UI.searchBg:SetDimensions(248, 34)
    bindColor(UI.searchBg, "SetCenterColor", C.search)
    bindColor(UI.searchBg, "SetEdgeColor", C.fieldEdge)
    UI.search = wm:CreateControlFromVirtual("DMC_SearchBox", UI.searchBg, "ZO_DefaultEditForBackdrop")
    UI.search:SetAnchor(TOPLEFT, UI.searchBg, TOPLEFT, 6, 0)
    UI.search:SetAnchor(BOTTOMRIGHT, UI.searchBg, BOTTOMRIGHT, 0, 0)
    bindColor(UI.search, "SetColor", C.searchText)
    UI.search:SetMaxInputChars(50)
    UI.search:SetDefaultText("Search name, DLC, chapter...")
    UI.search:SetHandler("OnTextChanged", function(edit)
        UI.searchText = edit:GetText() or ""
        DMC.RefreshDungeonList(true)
    end)
    UI.searchFocused = false
    UI.searchHovered = false
    ZO_PostHookHandler(UI.search, "OnMouseEnter", function()
        UI.searchHovered = true
        if not UI.searchFocused then UI.searchBg:SetCenterColor(unpack(C.searchHover)) end
    end)
    ZO_PostHookHandler(UI.search, "OnMouseExit", function()
        UI.searchHovered = false
        if not UI.searchFocused then UI.searchBg:SetCenterColor(unpack(C.search)) end
    end)
    ZO_PostHookHandler(UI.search, "OnFocusGained", function()
        UI.searchFocused = true
        UI.searchBg:SetCenterColor(unpack(C.searchFocus))
        UI.searchBg:SetEdgeColor(unpack(C.fieldFocus))
    end)
    ZO_PostHookHandler(UI.search, "OnFocusLost", function()
        UI.searchFocused = false
        if UI.searchHovered then
            UI.searchBg:SetCenterColor(unpack(C.searchHover))
        else
            UI.searchBg:SetCenterColor(unpack(C.search))
        end
        UI.searchBg:SetEdgeColor(unpack(C.fieldEdge))
    end)

    UI.activityGroup = wm:CreateControl("DMC_ActivityGroup", UI.leftPanel, CT_CONTROL)
    UI.activityGroup:SetAnchor(TOPLEFT, UI.leftPanel, TOPLEFT, 14, 77)
    UI.activityGroup:SetDimensions(248, 25)
    UI.activityGroupBg = wm:CreateControl("DMC_ActivityGroupBg", UI.activityGroup, CT_BACKDROP)
    UI.activityGroupBg:SetAnchorFill(UI.activityGroup)
    bindColor(UI.activityGroupBg, "SetCenterColor", C.groupSurface)
    bindColor(UI.activityGroupBg, "SetEdgeColor", C.pillEdge)
    UI.activityDungeon = makeSegmentButton(UI.activityGroup, "DMC_ActivityDungeon", "DUNGEONS", function()
        DMC.SetActivityType("dungeon")
    end, FONT_META_BOLD)
    UI.activityDungeon:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, 0, 0)
    UI.activityDungeon:SetDimensions(83, 25)
    UI.activityTrial = makeSegmentButton(UI.activityGroup, "DMC_ActivityTrial", "TRIALS", function()
        DMC.SetActivityType("trial")
    end, FONT_META_BOLD)
    UI.activityTrial:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, 83, 0)
    UI.activityTrial:SetDimensions(82, 25)
    UI.activityArena = makeSegmentButton(UI.activityGroup, "DMC_ActivityArena", "ARENAS", function()
        DMC.SetActivityType("arena")
    end, FONT_META_BOLD)
    UI.activityArena:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, 165, 0)
    UI.activityArena:SetDimensions(83, 25)
    for index, x in ipairs({83, 165}) do
        local divider = wm:CreateControl("DMC_ActivityDivider" .. index, UI.activityGroup, CT_TEXTURE)
        divider:SetAnchor(TOPLEFT, UI.activityGroup, TOPLEFT, x, 4)
        divider:SetAnchor(BOTTOMLEFT, UI.activityGroup, BOTTOMLEFT, x, -4)
        divider:SetWidth(1)
        bindColor(divider, "SetColor", C.passiveRule)
        divider:SetDrawLayer(DL_OVERLAY)
    end
    setSelectedButton(UI.activityDungeon, UI.activityType == "dungeon")
    setSelectedButton(UI.activityTrial, UI.activityType == "trial")
    setSelectedButton(UI.activityArena, UI.activityType == "arena")

    UI.dungeonListScroll, UI.dungeonListChild = makeNativeScroll(UI.leftPanel, "DMC_DungeonList", 14, 109, 248, 647)
    UI.noDungeons = makeLabel(UI.dungeonListChild, "DMC_NoDungeons", "No matching activities.", "ZoFontGameSmall", C.muted, true)
    UI.noDungeons:SetAnchor(TOPLEFT, UI.dungeonListChild, TOPLEFT, 8, 8)
    UI.noDungeons:SetDimensions(DUNGEON_CONTENT_WIDTH - 16, 24)
    UI.noDungeons:SetHidden(true)

    UI.dungeonPanel = makePanel(window, "DMC_DungeonPanel", RIGHT_X, CONTENT_Y, RIGHT_WIDTH, 112, C.panel2)
    makeSectionBand(UI.dungeonPanel, "DMC_DungeonPanelHeader", 38)
    UI.dungeonArtBuffers = {}
    for index = 1, 2 do
        local art = wm:CreateControl("DMC_DungeonArt" .. tostring(index), UI.dungeonPanel, CT_TEXTURE)
        art:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 1, 1)
        art:SetAnchor(BOTTOMRIGHT, UI.dungeonPanel, BOTTOMRIGHT, -1, -1)
        art:SetResizeToFitFile(false)
        if art.SetPixelRoundingEnabled then art:SetPixelRoundingEnabled(false) end
        if art.SetTextureReleaseOption and _G.RELEASE_TEXTURE_AT_ZERO_REFERENCES then
            art:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
        end
        if art.ClearGradientColors then art:ClearGradientColors() end
        art:SetColor(1, 1, 1, 1)
        art:SetAlpha(1)
        art:SetTextureCoords(0, 0.6836, 0.41, 0.575)
        art:SetMouseEnabled(false)
        art:SetDrawLayer(DL_BACKGROUND)
        art:SetDrawLevel(index == 1 and 3 or 2)
        art:SetHidden(true)
        art:SetHandler("OnTextureLoaded", function(control)
            finishArtworkLoad(control)
        end)
        UI.dungeonArtBuffers[index] = art
    end
    UI.dungeonArt = UI.dungeonArtBuffers[1]
    UI.dungeonArtShadeSegments = {}
    local artworkInnerWidth = RIGHT_WIDTH - 2
    for index = 1, ARTWORK_SHADE_SEGMENT_COUNT do
        local leftX = math.floor((index - 1) * artworkInnerWidth / ARTWORK_SHADE_SEGMENT_COUNT)
        local rightX = math.floor(index * artworkInnerWidth / ARTWORK_SHADE_SEGMENT_COUNT)
        local segment = wm:CreateControl("DMC_DungeonArtShade" .. tostring(index), UI.dungeonPanel, CT_TEXTURE)
        segment:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 1 + leftX, 1)
        segment:SetDimensions(math.max(1, rightX - leftX), 110)
        segment:SetMouseEnabled(false)
        segment:SetDrawLayer(DL_BACKGROUND)
        segment:SetDrawLevel(5)
        segment:SetHidden(true)
        UI.dungeonArtShadeSegments[index] = segment
    end
    applyArtworkShade()
    UI.dungeonIcon = wm:CreateControl("DMC_DungeonIcon", UI.dungeonPanel, CT_TEXTURE)
    UI.dungeonIcon:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 16, 6)
    UI.dungeonIcon:SetDimensions(28, 28)
    UI.dungeonIcon:SetTexture(ZO_GetZoneDisplayTypeIcon(ZONE_DISPLAY_TYPE_DUNGEON))
    bindColor(UI.dungeonIcon, "SetColor", C.title)
    UI.dungeonIcon:SetMouseEnabled(false)
    UI.dungeonIcon:SetDrawLayer(DL_OVERLAY)
    UI.dungeonIcon:SetDrawLevel(24)
    UI.dungeonIcon:SetHidden(true)
    UI.dungeonTitle = makeLabel(UI.dungeonPanel, "DMC_DungeonTitle", "Select an activity", FONT_H2, C.title, true)
    UI.dungeonTitle:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, DUNGEON_TITLE_X, 10)
    UI.dungeonTitle:SetDimensions(500, 30)
    UI.dungeonDlc = makeLabel(UI.dungeonPanel, "DMC_DungeonDlc", "", FONT_META_BOLD, C.quiet, true)
    UI.dungeonDlc:SetAnchor(LEFT, UI.dungeonTitle, RIGHT, 10, 1)
    UI.dungeonDlc:SetDimensions(190, 20)
    UI.statusLabel = makeLabel(UI.dungeonPanel, "DMC_StatusLabel", "HARD MODE", FONT_META_BOLD, C.muted, true)
    UI.statusLabel:SetAnchor(TOPRIGHT, UI.dungeonPanel, TOPRIGHT, -14, 12)
    UI.statusLabel:SetDimensions(210, 20)
    UI.statusLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.statusLabel:SetHidden(true)
    UI.dungeonSummaryView = makeScrollableText(UI.dungeonPanel, "DMC_DungeonSummary", 16, 43, 904, 55, FONT_BODY, C.bodyText)

    UI.modeGroup = wm:CreateControl("DMC_ModeGroup", UI.dungeonPanel, CT_CONTROL)
    UI.modeGroup:SetDimensions(92, 25)
    UI.modeGroup:SetHidden(true)
    UI.modeGroupBg = wm:CreateControl("DMC_ModeGroupBg", UI.modeGroup, CT_BACKDROP)
    UI.modeGroupBg:SetAnchorFill(UI.modeGroup)
    bindColor(UI.modeGroupBg, "SetCenterColor", C.segment)
    UI.modeGroupBg:SetEdgeColor(0, 0, 0, 0)
    UI.modeGroupBg:SetMouseEnabled(false)
    UI.modeGroupBg:SetDrawLayer(DL_BACKGROUND)
    UI.modeGroupBg:SetDrawLevel(5)
    UI.modeGroupFrame = makeWindowStroke(UI.modeGroup, "DMC_ModeGroupFrame", 1, 0, C.pillEdge)

    UI.modeVet = makeSegmentButton(UI.modeGroup, "DMC_ModeVet", "VET", function()
        DMC.SetDifficultyMode("vet")
    end, FONT_META_BOLD)
    UI.modeVet:SetAnchor(TOPLEFT, UI.modeGroup, TOPLEFT, 0, 0)
    UI.modeVet:SetDimensions(46, 25)
    UI.modeHm = makeSegmentButton(UI.modeGroup, "DMC_ModeHm", "HM", function()
        DMC.SetDifficultyMode("hm")
    end, FONT_META_BOLD)
    UI.modeHm:SetAnchor(TOPLEFT, UI.modeGroup, TOPLEFT, 46, 0)
    UI.modeHm:SetDimensions(46, 25)
    UI.modeSeparator = wm:CreateControl("DMC_ModeSeparator", UI.modeGroup, CT_TEXTURE)
    UI.modeSeparator:SetAnchor(TOPLEFT, UI.modeGroup, TOPLEFT, 46, 4)
    UI.modeSeparator:SetAnchor(BOTTOMLEFT, UI.modeGroup, BOTTOMLEFT, 46, -4)
    UI.modeSeparator:SetWidth(1)
    bindColor(UI.modeSeparator, "SetColor", C.passiveRule)
    UI.modeSeparator:SetDrawLayer(DL_OVERLAY)
    UI.modeSeparator:SetDrawLevel(28)
    ZO_PostHookHandler(UI.modeVet, "OnMouseEnter", function(control)
        showCompactHint(control, "Veteran")
    end)
    ZO_PostHookHandler(UI.modeVet, "OnMouseExit", hideCompactHint)
    ZO_PostHookHandler(UI.modeHm, "OnMouseEnter", function(control)
        showCompactHint(control, "Hard Mode")
    end)
    ZO_PostHookHandler(UI.modeHm, "OnMouseExit", hideCompactHint)

    for index = 1, 4 do
        local paste = makePasteIconButton(UI.dungeonPanel, "DMC_DungeonPaste" .. index, function(control)
            if control.chatText then DMC.PasteToChatInput(control.chatText) end
        end)
        paste:SetAnchor(TOPLEFT, UI.dungeonPanel, TOPLEFT, 878, 7)
        paste:SetDimensions(42, 25)
        UI.dungeonPasteButtons[index] = paste
    end
    UI.dungeonPasteLabel = makeLabel(UI.dungeonPanel, "DMC_DungeonPasteLabel", "PASTE", FONT_META, C.quiet, true)
    UI.dungeonPasteLabel:SetDimensions(38, 21)
    UI.dungeonPasteLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.dungeonPasteLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    UI.dungeonPasteLabel:SetHidden(true)

    UI.bossListPanel = makePanel(window, "DMC_BossListPanel", RIGHT_X, CONTENT_Y + 122, RIGHT_WIDTH, 120, C.panel2)
    makeSectionBand(UI.bossListPanel, "DMC_BossListPanelHeader", 35)
    UI.bossListTitle = makeLabel(UI.bossListPanel, "DMC_BossListTitle", "BOSSES", FONT_SECTION_SMALL, C.sectionTitle, true)
    UI.bossListIcon = createHeaderIcon(UI.bossListPanel, "DMC_BossListIcon", "bosses", C.sectionTitle)
    UI.bossListIcon:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, 16, 11)
    UI.bossListTitle:SetAnchor(LEFT, UI.bossListIcon, RIGHT, 7, 0)
    UI.bossListTitle:SetDimensions(120, 22)
    UI.bossMeasureLabel = makeLabel(UI.bossListPanel, "DMC_BossMeasureLabel", "", FONT_BOSS_ROW, C.text, true)
    UI.bossMeasureLabel:SetDimensions(900, 20)
    UI.bossMeasureLabel:SetHidden(true)
    UI.roleGroup = wm:CreateControl("DMC_RoleGroup", UI.bossListPanel, CT_CONTROL)
    UI.roleGroup:SetAnchor(TOPRIGHT, UI.bossListPanel, TOPRIGHT, -16, 6)
    UI.roleGroup:SetDimensions(325, 30)
    UI.roleGroupBg = wm:CreateControl("DMC_RoleGroupBg", UI.roleGroup, CT_BACKDROP)
    UI.roleGroupBg:SetAnchorFill(UI.roleGroup)
    bindColor(UI.roleGroupBg, "SetCenterColor", C.segment)
    UI.roleGroupBg:SetEdgeColor(0, 0, 0, 0)
    UI.roleGroupBg:SetMouseEnabled(false)
    UI.roleGroupBg:SetDrawLayer(DL_BACKGROUND)
    UI.roleGroupBg:SetDrawLevel(5)
    UI.roleGroupFrame = makeWindowStroke(UI.roleGroup, "DMC_RoleGroupFrame", 1, 0, C.pillEdge)

    UI.roleLabel = makeLabel(UI.bossListPanel, "DMC_RoleLabel", "VIEW", FONT_META, C.quiet, true)
    UI.roleLabel:SetAnchor(RIGHT, UI.roleGroup, LEFT, -10, 0)
    UI.roleLabel:SetDimensions(44, 22)
    UI.roleLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.roleLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)

    local roleDefs = {
        {key = "all", label = "FULL", width = 65},
        {key = "quick", label = "QUICK", width = 65},
        {key = "tank", label = "TANK", width = 65},
        {key = "healer", label = "HEALER", width = 65},
        {key = "dps", label = "DPS", width = 65},
    }
    UI.roleButtons = {}
    UI.roleSeparators = {}
    local x = 0
    for index, def in ipairs(roleDefs) do
        local roleKey = def.key
        local button = makeSegmentButton(UI.roleGroup, "DMC_Role" .. def.key, def.label, function()
            DMC.SetRoleFilter(roleKey)
        end)
        button:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, x, 0)
        button:SetDimensions(def.width, 30)
        if index > 1 then
            local separator = wm:CreateControl("DMC_RoleSeparator" .. index, UI.roleGroup, CT_TEXTURE)
            separator:SetAnchor(TOPLEFT, UI.roleGroup, TOPLEFT, x, 5)
            separator:SetAnchor(BOTTOMLEFT, UI.roleGroup, BOTTOMLEFT, x, -5)
            separator:SetWidth(1)
            bindColor(separator, "SetColor", C.passiveRule)
            separator:SetDrawLayer(DL_OVERLAY)
            separator:SetDrawLevel(28)
            UI.roleSeparators[def.key] = separator
        end
        UI["role" .. def.key] = button
        UI.roleButtons[def.key] = button
        x = x + def.width
    end

    for index = 1, 12 do
        local button = makeButton(UI.bossListPanel, "DMC_BossButton" .. index, "", function(control)
            if control.bossId then DMC.SelectBoss(control.bossId) end
        end, FONT_BOSS_ROW)
        local column = index <= 4 and 0 or 1
        local row = (index - 1) % 4
        button:SetAnchor(TOPLEFT, UI.bossListPanel, TOPLEFT, 16 + column * 452, 39 + row * 20)
        button:SetDimensions(440, 19)
        button:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
        button.bg = wm:CreateControl("DMC_BossButton" .. index .. "Bg", button, CT_BACKDROP)
        button.bg:SetAnchorFill(button)
        bindColor(button.bg, "SetCenterColor", C.bossRow)
        button.bg:SetEdgeColor(0, 0, 0, 0)
        button.bg:SetMouseEnabled(false)
        button.bg:SetDrawLayer(DL_BACKGROUND)
        button.accent = wm:CreateControl("DMC_BossButton" .. index .. "Accent", button, CT_TEXTURE)
        button.accent:SetAnchor(TOPLEFT, button, TOPLEFT, 0, 1)
        button.accent:SetAnchor(BOTTOMLEFT, button, BOTTOMLEFT, 0, -1)
        button.accent:SetWidth(2)
        bindColor(button.accent, "SetColor", C.edge)
        button.accent:SetHidden(true)

        button:SetHandler("OnMouseEnter", function(control)
            control.isHovered = true
            if not control.isSelected then
                control.bg:SetCenterColor(unpack(C.bossRowHover))
                control:SetNormalFontColor(unpack(C.bossHoverText))
            end
            updateBossButtonText(control, true)
        end)
        button:SetHandler("OnMouseExit", function(control)
            control.isHovered = false
            setBossButtonState(control, control.isSelected)
        end)
        UI.bossButtons[index] = button
    end

    UI.bossPanel = makePanel(window, "DMC_BossPanel", RIGHT_X, CONTENT_Y + 252, RIGHT_WIDTH, 188, C.panel2)
    makeSectionBand(UI.bossPanel, "DMC_BossSummaryHeader", 39, 1, 535, C.section)
    makeSectionBand(UI.bossPanel, "DMC_NoteHeader", 39, 537, 398, C.sectionAlt)
    local bossDivider = wm:CreateControl("DMC_BossPanelDivider", UI.bossPanel, CT_TEXTURE)
    bossDivider:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 536, 1)
    bossDivider:SetAnchor(BOTTOMLEFT, UI.bossPanel, BOTTOMLEFT, 536, -1)
    bossDivider:SetWidth(1)
    bindColor(bossDivider, "SetColor", C.passiveRule)
    bossDivider:SetDrawLayer(DL_OVERLAY)
    bossDivider:SetDrawLevel(20)

    UI.bossTitle = makeLabel(UI.bossPanel, "DMC_BossTitle", "", FONT_H3, C.title, true)
    UI.bossTitle:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 16, 10)
    UI.bossTitle:SetDimensions(420, 28)
    UI.bossMeta = makeLabel(UI.bossPanel, "DMC_BossMeta", "", FONT_META_BOLD, C.quiet, true)
    UI.bossMeta:SetDimensions(80, 20)
    for index = 1, 4 do
        local paste = makePasteIconButton(UI.bossPanel, "DMC_BossPaste" .. index, function(control)
            if control.chatText then DMC.PasteToChatInput(control.chatText) end
        end)
        paste:SetDimensions(42, 25)
        UI.bossPasteButtons[index] = paste
    end
    UI.bossSummaryView = makeScrollableText(UI.bossPanel, "DMC_BossSummary", 16, 45, 504, 127, FONT_BODY, C.bodyText)

    UI.noteTitle = makeLabel(UI.bossPanel, "DMC_NoteTitle", "PERSONAL NOTES", FONT_SECTION_SMALL, C.sectionTitle, true)
    UI.noteIcon = createHeaderIcon(UI.bossPanel, "DMC_NoteIcon", "notes", C.sectionTitle)
    UI.noteIcon:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 554, 13)
    UI.noteTitle:SetAnchor(LEFT, UI.noteIcon, RIGHT, 7, -1)
    UI.noteTitle:SetDimensions(164, 22)
    UI.noteStatus = makeLabel(UI.bossPanel, "DMC_NoteStatus", "SELECT A BOSS", FONT_META, C.quiet, true)
    UI.noteStatus:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 722, 13)
    UI.noteStatus:SetDimensions(98, 20)
    UI.noteStatus:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.noteCounter = makeLabel(UI.bossPanel, "DMC_NoteCounter", "0 / 900", FONT_META, C.quiet, true)
    UI.noteCounter:SetAnchor(TOPRIGHT, UI.bossPanel, TOPRIGHT, -16, 13)
    UI.noteCounter:SetDimensions(96, 20)
    UI.noteCounter:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)

    UI.noteBackdrop = wm:CreateControlFromVirtual("DMC_NoteBackdrop", UI.bossPanel, "ZO_MultiLineEditBackdrop_Keyboard")
    UI.noteBackdrop:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 554, 43)
    UI.noteBackdrop:SetDimensions(366, 91)
    bindColor(UI.noteBackdrop, "SetCenterColor", C.noteSurface)
    bindColor(UI.noteBackdrop, "SetEdgeColor", C.fieldEdge)
    UI.noteEdit = wm:CreateControlFromVirtual("DMC_NoteEdit", UI.noteBackdrop, "ZO_DefaultEditMultiLineForBackdrop")
    UI.noteEdit:SetMaxInputChars(DMC.personalNoteMaxChars or 900)
    bindColor(UI.noteEdit, "SetColor", C.bodyTextSoft)
    bindFont(UI.noteEdit, FONT_BODY)
    UI.noteEdit:SetDefaultText("Write a boss note to keep and paste later...")
    UI.noteEdit:SetHandler("OnTextChanged", function()
        if not UI.noteLoading then refreshNoteControls() end
    end)
    UI.noteFocused = false
    ZO_PostHookHandler(UI.noteEdit, "OnFocusGained", function()
        UI.noteFocused = true
        UI.noteBackdrop:SetEdgeColor(unpack(C.fieldFocus))
    end)
    ZO_PostHookHandler(UI.noteEdit, "OnFocusLost", function()
        UI.noteFocused = false
        UI.noteBackdrop:SetEdgeColor(unpack(C.fieldEdge))
    end)

    UI.noteRevert = makePill(UI.bossPanel, "DMC_NoteRevert", "REVERT", revertPersonalBossNote)
    UI.noteRevert:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 554, 145)
    UI.noteRevert:SetDimensions(70, 26)
    UI.noteSave = makePill(UI.bossPanel, "DMC_NoteSave", "SAVE", function() DMC.SavePersonalBossNote(true) end)
    UI.noteSave:SetAnchor(LEFT, UI.noteRevert, RIGHT, 6, 0)
    UI.noteSave:SetDimensions(70, 26)
    UI.noteSave.variant = "primary"
    applyPillVisual(UI.noteSave)

    UI.notePasteLabel = makeLabel(UI.bossPanel, "DMC_NotePasteLabel", "", FONT_META, C.quiet, true)
    UI.notePasteLabel:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 734, 145)
    UI.notePasteLabel:SetDimensions(44, 26)
    UI.notePasteLabel:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.notePasteLabel:SetVerticalAlignment(TEXT_ALIGN_CENTER)
    UI.notePasteLabel:SetHidden(true)

    for index = 1, 4 do
        local paste = makePasteIconButton(UI.bossPanel, "DMC_NotePaste" .. index, pastePersonalBossNoteChunk)
        if index == 1 then
            paste:SetAnchor(TOPLEFT, UI.bossPanel, TOPLEFT, 748, 145)
        else
            paste:SetAnchor(LEFT, UI.notePasteButtons[index - 1], RIGHT, 4, 0)
        end
        paste:SetDimensions(40, 26)
        UI.notePasteButtons[index] = paste
    end

    UI.mechanicsPanel = makePanel(window, "DMC_MechanicsPanel", RIGHT_X, CONTENT_Y + 446, RIGHT_WIDTH, 328, C.panel2)
    makeSectionBand(UI.mechanicsPanel, "DMC_MechanicsPanelHeader", 37)
    UI.mechanicsTitle = makeLabel(UI.mechanicsPanel, "DMC_MechanicsTitle", "MECHANICS", FONT_SECTION_SMALL, C.sectionTitle, true)
    UI.mechanicsIcon = createHeaderIcon(UI.mechanicsPanel, "DMC_MechanicsIcon", "mechanics", C.sectionTitle)
    UI.mechanicsIcon:SetAnchor(TOPLEFT, UI.mechanicsPanel, TOPLEFT, 16, 11)
    UI.mechanicsTitle:SetAnchor(LEFT, UI.mechanicsIcon, RIGHT, 7, 0)
    UI.mechanicsTitle:SetDimensions(180, 22)
    UI.mechanicsCount = makeLabel(UI.mechanicsPanel, "DMC_MechanicsCount", "", FONT_META, C.quiet, true)
    UI.mechanicsCount:SetAnchor(TOPRIGHT, UI.mechanicsPanel, TOPRIGHT, -18, 12)
    UI.mechanicsCount:SetDimensions(130, 20)
    UI.mechanicsCount:SetHorizontalAlignment(TEXT_ALIGN_RIGHT)
    UI.mechanicsScroll, UI.mechanicsChild = makeNativeScroll(UI.mechanicsPanel, "DMC_MechanicsList", 14, 42, 908, 267)

    setSelectedButton(UI.roleall, UI.roleFilter == "all")
    setSelectedButton(UI.rolequick, UI.roleFilter == "quick")
    setSelectedButton(UI.roletank, UI.roleFilter == "tank")
    setSelectedButton(UI.rolehealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roledps, UI.roleFilter == "dps")
    DMC.RefreshDungeonList(true)
    loadCurrentBossNote()
    DMC.ApplyAppearanceToUI(false)
end

local function enterCursorModeForCodex()
    UI.cursorModeWasActiveOnOpen = IsGameCameraUIModeActive()
    UI.cursorModeActivatedByCodex = not UI.cursorModeWasActiveOnOpen
    SetGameCameraUIMode(true)
    zo_callLater(function()
        if UI.window and not UI.window:IsHidden() then SetGameCameraUIMode(true) end
    end, 50)
end

local function restoreCursorModeForCodex()
    local shouldRestore = UI.cursorModeActivatedByCodex
    UI.cursorModeActivatedByCodex = false
    UI.cursorModeWasActiveOnOpen = nil
    if not shouldRestore then return end
    zo_callLater(function()
        if UI.window and UI.window:IsHidden() then SetGameCameraUIMode(false) end
    end, 50)
end

function DMC.ShowWindow()
    if not UI.window then return end
    if UI.window:IsHidden() then UI.window:SetHidden(false) end

    local session = getSessionState()
    if isValidRoleFilter(session.roleFilter) then UI.roleFilter = session.roleFilter end
    local current = findCurrentDungeon()
    if current then
        if UI.search and UI.search:GetText() ~= "" then
            UI.search:SetText("")
            UI.searchText = ""
        end
        DMC.SelectDungeon(current.id)
    elseif session.selectedDungeonId and DMC.GetDungeonById(session.selectedDungeonId) then
        DMC.SelectDungeon(session.selectedDungeonId, session.selectedBossId)
    else
        local dungeons = DMC.GetDungeonsSorted(UI.searchText, false, UI.activityType)
        if dungeons[1] then DMC.SelectDungeon(dungeons[1].id) end
    end
    DMC.RefreshDungeonList(current ~= nil)
    startArtworkHealthMonitor()
    enterCursorModeForCodex()
end

function DMC.HideWindow()
    if not UI.window then return end
    saveCurrentNoteIfDirty()
    if UI.noteEdit then UI.noteEdit:LoseFocus() end
    hideCompactHint()
    stopArtworkHealthMonitor()
    UI.window:SetHidden(true)
    applyArtworkAppearance()
    restoreCursorModeForCodex()
end

function DMC.ToggleWindow()
    if not UI.window then return end
    if UI.window:IsHidden() then DMC.ShowWindow() else DMC.HideWindow() end
end

function DMC.CenterWindow()
    if not UI.window then return end
    UI.window:ClearAnchors()
    UI.window:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
    if DMC.sv and DMC.sv.window then
        DMC.sv.window.x = 0
        DMC.sv.window.y = 0
    end
end

function DMC.HandlePlayerActivated()
    if not UI.window or UI.window:IsHidden() then return end
    local current = findCurrentDungeon()
    if current and current.id ~= UI.selectedDungeonId then
        if UI.search and UI.search:GetText() ~= "" then
            UI.search:SetText("")
            UI.searchText = ""
        end
        DMC.SelectDungeon(current.id)
    else
        DMC.RefreshDungeonList(current ~= nil)
    end
end

function DMC.SetRoleFilter(role)
    local activity = DMC.GetDungeonById(UI.selectedDungeonId)
    if activity and not DMC.ActivitySupports(activity, "roles", role) then return end
    UI.roleFilter = isValidRoleFilter(role) and role or "all"
    getSessionState().roleFilter = UI.roleFilter
    UI.selectedChatLine = nil
    setSelectedButton(UI.roleall, UI.roleFilter == "all")
    setSelectedButton(UI.rolequick, UI.roleFilter == "quick")
    setSelectedButton(UI.roletank, UI.roleFilter == "tank")
    setSelectedButton(UI.rolehealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roledps, UI.roleFilter == "dps")
    DMC.RefreshBossDetails()
end

function DMC.SetDifficultyMode(mode)
    mode = DMC.NormalizeDifficultyMode(mode)
    local activity = DMC.GetDungeonById(UI.selectedDungeonId)
    if activity and not DMC.ActivitySupports(activity, "difficulties", mode) then return end
    if UI.mode == mode then return end
    saveCurrentNoteIfDirty()
    UI.mode = mode
    if DMC.sv then DMC.sv.mode = mode end
    UI.selectedChatLine = nil
    setSelectedButton(UI.modeVet, mode == "vet")
    setSelectedButton(UI.modeHm, mode == "hm")
    if UI.selectedDungeonId then
        DMC.SelectDungeon(UI.selectedDungeonId, UI.selectedBossId)
    end
end

function DMC.SetActivityType(activityType)
    activityType = (activityType == "trial" or activityType == "arena") and activityType or "dungeon"
    if UI.activityType == activityType then return end
    saveCurrentNoteIfDirty()
    UI.activityType = activityType
    local session = getSessionState()
    session.activityType = activityType
    UI.selectedChatLine = nil
    setSelectedButton(UI.activityDungeon, activityType == "dungeon")
    setSelectedButton(UI.activityTrial, activityType == "trial")
    setSelectedButton(UI.activityArena, activityType == "arena")

    local selected = DMC.GetDungeonById(UI.selectedDungeonId)
    if not selected or DMC.GetActivityKind(selected) ~= activityType then
        local current = findCurrentDungeon()
        local target = current and DMC.GetActivityKind(current) == activityType and current or nil
        if not target then
            local activities = DMC.GetDungeonsSorted(UI.searchText, false, activityType)
            -- A search from the previous collection should not leave its old
            -- activity selected behind an empty new tab. Clear only when the
            -- same query has no result in the collection being opened.
            if not activities[1] and UI.searchText ~= "" then
                UI.searchText = ""
                UI.search:SetText("")
                activities = DMC.GetDungeonsSorted("", false, activityType)
            end
            target = activities[1]
        end
        if target then DMC.SelectDungeon(target.id) end
    end
    DMC.RefreshDungeonList(true)
end

function DMC.RefreshDungeonList(resetScroll)
    if not UI.dungeonListChild then return end
    local current = findCurrentDungeon()
    local currentDungeonId = current and current.id or false
    local dungeons = DMC.GetDungeonsSorted(UI.searchText, currentDungeonId, UI.activityType)
    local hasSearch = DMC.NormalizeText(UI.searchText or "") ~= ""
    if hasSearch then
        UI.dungeonCount:SetText(string.format("%d RESULTS", #dungeons))
    else
        local collectionLabel = UI.activityType == "trial" and "TRIALS"
            or (UI.activityType == "arena" and "ARENAS" or "DUNGEONS")
        UI.dungeonCount:SetText(string.format("%d %s", #dungeons, collectionLabel))
    end
    local rowHeight = DMC.GetActivityRowHeight()
    for index, dungeon in ipairs(dungeons) do
        local button = ensureDungeonButton(index)
        button:ClearAnchors()
        button:SetAnchor(TOPLEFT, UI.dungeonListChild, TOPLEFT, 0, (index - 1) * rowHeight)
        button:SetDimensions(DUNGEON_CONTENT_WIDTH, rowHeight - 1)
        local isCurrent = dungeon.id == currentDungeonId
        local status = dungeon.status == "complete" and "" or (" " .. colorMarkup(C.stubText, "(stub)"))
        button:SetText("   " .. dungeon.name .. status)
        button.dungeonId = dungeon.id
        button:SetHidden(false)
        setDungeonButtonState(button, dungeon.id == UI.selectedDungeonId, isCurrent)
    end
    for index = #dungeons + 1, #UI.dungeonButtons do
        UI.dungeonButtons[index]:SetHidden(true)
        UI.dungeonButtons[index].dungeonId = nil
    end

    UI.noDungeons:SetHidden(#dungeons > 0)
    local contentHeight = #dungeons > 0 and (#dungeons * rowHeight) or 40
    updateNativeScroll(UI.dungeonListScroll, UI.dungeonListChild, DUNGEON_CONTENT_WIDTH, contentHeight, resetScroll == true)
end

function DMC.SelectDungeon(dungeonId, preferredBossId)
    local dungeon = DMC.GetDungeonById(dungeonId)
    if not dungeon then return end
    local previousDungeonId = UI.selectedDungeonId
    local previousBossId = UI.selectedBossId
    local session = getSessionState()
    local activityType = DMC.GetActivityKind(dungeon)
    UI.activityType = activityType
    session.activityType = activityType
    setSelectedButton(UI.activityDungeon, activityType == "dungeon")
    setSelectedButton(UI.activityTrial, activityType == "trial")
    setSelectedButton(UI.activityArena, activityType == "arena")
    local rememberedBossId = session.selectedDungeonId == dungeonId and session.selectedBossId or nil

    saveCurrentNoteIfDirty()
    UI.selectedDungeonId = dungeonId
    session.selectedDungeonId = dungeonId
    UI.selectedChatLine = nil

    applyActivityCapabilities(dungeon)

    local isStub = dungeon.status ~= "complete"
    UI.statusLabel:SetText(isStub and "DATASET STUB" or "")
    UI.statusLabel:SetColor(unpack(C.muted))
    UI.statusLabel:SetHidden(not isStub)
    local statusText = isStub and " Dataset stub: mechanics not written yet." or ""
    setScrollableText(UI.dungeonSummaryView, getDungeonSummaryText(dungeon) .. statusText, true)

    local dungeonLines = DMC.BuildDungeonChatLines(dungeon, UI.mode)
    for index, button in ipairs(UI.dungeonPasteButtons) do
        local line = dungeonLines[index]
        setPasteButton(button, line, #dungeonLines > 1 and ("PASTE " .. tostring(index)) or "PASTE")
    end
    layoutDungeonPasteButtons(#dungeonLines)

    local zoneDisplayType = ZONE_DISPLAY_TYPE_DUNGEON
    if activityType == "trial" then
        zoneDisplayType = ZONE_DISPLAY_TYPE_RAID
    elseif activityType == "arena" then
        zoneDisplayType = _G.ZONE_DISPLAY_TYPE_GROUP_ARENA
            or _G.ZONE_DISPLAY_TYPE_SOLO_ARENA
            or _G.ZONE_DISPLAY_TYPE_DUNGEON
    end
    UI.dungeonIcon:SetTexture(ZO_GetZoneDisplayTypeIcon(zoneDisplayType))
    UI.dungeonIcon:SetHidden(false)
    local artwork, isLoadscreen = getActivityArtwork(dungeon)
    UI.currentArtwork = artwork
    UI.currentArtworkIsLoadscreen = isLoadscreen
    applyArtworkAppearance()
    layoutDungeonTitle(dungeon)

    local visibleBossCount = 0
    for index, button in ipairs(UI.bossButtons) do
        local boss = dungeon.bosses and dungeon.bosses[index]
        if boss then
            button.bossId = boss.id
            button.bossData = boss
            button.bossName = boss.name
            button.bossFlagsMarkup = shortFlags(boss)
            local flags = plainFlags(boss)
            button.measureText = boss.name .. (flags ~= "" and ("  " .. flags) or "")
            button:SetHidden(false)
            button.isHovered = false
            updateBossButtonText(button, false)
            visibleBossCount = visibleBossCount + 1
        else
            button:SetText("")
            button.bossId = nil
            button.bossData = nil
            button.bossName = nil
            button.bossFlagsMarkup = nil
            button.measureText = nil
            button:SetHidden(true)
        end
    end
    layoutBossListTable(visibleBossCount)

    if dungeon.bosses and dungeon.bosses[1] then
        local targetBossId = preferredBossId
        if not targetBossId and previousDungeonId == dungeonId then targetBossId = previousBossId end
        if not targetBossId then targetBossId = rememberedBossId end
        if not targetBossId or not DMC.GetBossById(dungeon, targetBossId) then
            targetBossId = dungeon.bosses[1].id
        end
        DMC.SelectBoss(targetBossId, true)
    else
        UI.selectedBossId = nil
        session.selectedBossId = nil
        loadCurrentBossNote()
        DMC.RefreshBossDetails()
    end
    DMC.RefreshDungeonList(false)
end

function DMC.SelectBoss(bossId, skipSave)
    if not skipSave and bossId ~= UI.selectedBossId then saveCurrentNoteIfDirty() end
    UI.selectedBossId = bossId
    getSessionState().selectedBossId = bossId
    UI.selectedChatLine = nil
    loadCurrentBossNote()
    DMC.RefreshBossDetails()
end

function DMC.RefreshBossDetails()
    for _, button in ipairs(UI.bossButtons) do
        setBossButtonState(button, button.bossId and button.bossId == UI.selectedBossId)
    end
    setSelectedButton(UI.roleall, UI.roleFilter == "all")
    setSelectedButton(UI.rolequick, UI.roleFilter == "quick")
    setSelectedButton(UI.roletank, UI.roleFilter == "tank")
    setSelectedButton(UI.rolehealer, UI.roleFilter == "healer")
    setSelectedButton(UI.roledps, UI.roleFilter == "dps")

    local dungeon, boss = getCurrentBoss()
    if not boss then
        UI.bossTitle:SetText("No boss selected")
        UI.bossTitle:SetDimensions(504, 28)
        if UI.bossMeta then UI.bossMeta:SetHidden(true) end
        setScrollableText(UI.bossSummaryView, "Select a boss to view its overview and mechanics.", true)
        for _, button in ipairs(UI.bossPasteButtons) do setPasteButton(button, nil) end
        layoutBossPasteButtons(0)
        UI.mechanicsCount:SetText("")
        for _, row in ipairs(UI.mechanicRows) do row:SetHidden(true) end
        updateNativeScroll(UI.mechanicsScroll, UI.mechanicsChild, MECHANIC_CONTENT_WIDTH, 1, true)
        refreshNoteControls()
        return
    end

    setScrollableText(UI.bossSummaryView, getBossSummaryText(boss), true)
    local bossLines = DMC.BuildBossChatLines(dungeon, boss, UI.mode)
    for index, button in ipairs(UI.bossPasteButtons) do
        local line = bossLines[index]
        setPasteButton(button, line, #bossLines > 1 and ("PASTE " .. tostring(index)) or "PASTE")
    end
    layoutBossPasteButtons(#bossLines)
    layoutSelectedBossTitle(boss)

    local matching = {}
    for _, mechanic in ipairs(boss.mechanics or {}) do
        if DMC.MechanicMatchesRole(mechanic, UI.roleFilter, UI.mode) then table.insert(matching, mechanic) end
    end
    UI.mechanicsCount:SetText(string.format("%d %s", #matching, #matching == 1 and "ENTRY" or "ENTRIES"))

    local y = 0
    if #matching == 0 then
        local row = ensureMechanicRow(1)
        row:ClearAnchors()
        row:SetAnchor(TOPLEFT, UI.mechanicsChild, TOPLEFT, 0, 0)
        row.title:SetText(UI.roleFilter == "quick" and "No Quick callouts" or "No mechanics")
        row.number:SetText("")
        row.number:SetHidden(true)
        local message = UI.roleFilter == "quick"
            and "No Quick callouts are written for this boss yet. Use Full for the complete mechanic explanations."
            or "No mechanics match this view."
        y = layoutMechanicRow(row, {message})
        for _, button in ipairs(row.pasteButtons) do setPasteButton(button, nil) end
        row:SetHidden(false)
        for index = 2, #UI.mechanicRows do UI.mechanicRows[index]:SetHidden(true) end
    else
        for index, mechanic in ipairs(matching) do
            local row = ensureMechanicRow(index)
            row:ClearAnchors()
            row:SetAnchor(TOPLEFT, UI.mechanicsChild, TOPLEFT, 0, y)
            row.title:SetText(DMC.GetMechanicLabel(mechanic, UI.mode))
            row.number:SetText(string.format("%02d", index))
            row.number:SetHidden(not DMC.ShouldShowAppearanceElement("showMechanicNumbers"))
            local lines = DMC.BuildMechanicChatLines(dungeon, boss, mechanic, UI.roleFilter, UI.mode)
            local rowHeight = layoutMechanicRow(row, lines)
            row:SetHidden(false)
            y = y + rowHeight + DMC.GetMechanicSpacing()
        end
        for index = #matching + 1, #UI.mechanicRows do UI.mechanicRows[index]:SetHidden(true) end
    end

    updateNativeScroll(UI.mechanicsScroll, UI.mechanicsChild, MECHANIC_CONTENT_WIDTH, math.max(1, y), true)
    refreshNoteControls()
end

function DMC.PasteSelectedChatLine()
    if UI.selectedChatLine then
        DMC.PasteToChatInput(UI.selectedChatLine)
        return
    end
    local dungeon, boss = getCurrentBoss()
    local lines = DMC.BuildBossChatLines(dungeon, boss, UI.mode)
    if lines[1] then DMC.PasteToChatInput(lines[1])
    else DMC.Print("No selected mechanic chat line yet.") end
end
