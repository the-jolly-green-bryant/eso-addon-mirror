-- ESO Adventurer Suite - Dungeon / Trial Chest Finder
-- Learns chest and Heavy Sack spawn locations only inside supported instanced
-- PvE content, then renders remembered locations as soft 3D world glows.
--
-- ESO does not expose a live list of nearby chest objects or their world
-- coordinates. The finder therefore learns a spawn when the player's reticle
-- identifies a chest/Heavy Sack, saving an approximate raw-world position at
-- interaction range. Remembered points become possible-spawn glows on later
-- runs. A point under the reticle is treated as confirmed for the current run,
-- and a successfully looted point is hidden until the player leaves/re-enters.
-- ESO addons cannot modify the chest model itself, so the glow is a world-space
-- ESO UI effect centered on the learned spawn position.

ESOProgressionCoach = ESOProgressionCoach or {}
local EPC = ESOProgressionCoach

EPC.DungeonChestFinder = EPC.DungeonChestFinder or {}
local F = EPC.DungeonChestFinder
local wm = WINDOW_MANAGER

local UPDATE_MS = 200
local MAX_MARKERS = 36
local DEDUPE_DISTANCE_CM = 450
local LOOT_MATCH_DISTANCE_CM = 700
local INTERACT_FORWARD_OFFSET_CM = 140
local GLOW_VERTICAL_OFFSET_CM = 55
local BASE_GLOW_WIDTH_M = 1.55
local BASE_GLOW_HEIGHT_M = 1.25
local BASE_PITCH = math.rad(-0.05)
local PENDING_LOOT_WINDOW_MS = 45000
local FAR_SCALE_START_M = 30
local GLOW_SOURCE_TEXTURE = "EsoUI/Art/Miscellaneous/lensflare_star_256.dds"
local GLOW_U1, GLOW_U2, GLOW_V1, GLOW_V2 = 0.22, 0.78, 0.22, 0.78
local GLOW_LAYERS = 1

local DEFAULT_CHEST_COLOR = { r = 1.00, g = 0.74, b = 0.14 }
local DEFAULT_SACK_COLOR = { r = 0.62, g = 0.92, b = 0.52 }

-- World glows should not be tied to IsGameCameraUIModeActive(). Chat entry,
-- cursor mode, and other harmless UI-camera states can be active during normal
-- dungeon/trial play and were causing the chest renderer to hide itself. Only
-- hide for actual full-screen/menu scenes when the Suite's hide-in-menus option
-- is enabled.
local WORLD_GLOW_HIDE_SCENES = {
    "gameMenuInGame", "inventory", "character", "skills", "championPerks",
    "journal", "collectionsBook", "groupMenu", "contacts", "guildHome",
    "mailInbox", "bank", "store", "tradingHouse", "crafting", "settings",
    "worldMap", "gamepad_worldMap", "gamepad_inventory_root",
    "gamepad_character_root", "gamepad_skills_root", "gamepad_journal_root",
    "gamepad_collections_book", "gamepad_group_root", "gamepad_options_root",
    "gamepad_player_menu", "gamepad_main_menu", "gamepad_championPerks_root",
    "gamepad_store", "gamepad_banking", "gamepad_trading_house",
    "gamepad_mail_manager", "gamepad_guild_hub", "gamepad_contacts_root",
}

local function safe(fn, fallback, ...)
    if type(fn) ~= "function" then return fallback end
    local ok, a, b, c, d, e, f, g, h = pcall(fn, ...)
    if not ok then return fallback end
    return a, b, c, d, e, f, g, h
end

local function lower(value)
    value = tostring(value or "")
    if type(zo_strlower) == "function" then
        local ok, result = pcall(zo_strlower, value)
        if ok and type(result) == "string" then return result end
    end
    return string.lower(value)
end

local function nowMs()
    if type(GetFrameTimeMilliseconds) == "function" then return tonumber(GetFrameTimeMilliseconds()) or 0 end
    return 0
end

local function distance2Dcm(ax, az, bx, bz)
    local dx = (tonumber(ax) or 0) - (tonumber(bx) or 0)
    local dz = (tonumber(az) or 0) - (tonumber(bz) or 0)
    return math.sqrt((dx * dx) + (dz * dz))
end

local CHEST_WORDS = {
    "chest",       -- English
    "coffre",      -- French
    "truhe",       -- German
    "cofre",       -- Spanish
}

local HEAVY_SACK_WORDS = {
    "heavy sack",  -- English
    "sac lourd",   -- French
    "schwerer sack", "schwere sack", -- German variants
    "saco pesado", -- Spanish
}

function F:ClassifyInteractable(name)
    local value = lower(name)
    if value == "" then return nil end

    for i = 1, #HEAVY_SACK_WORDS do
        if string.find(value, HEAVY_SACK_WORDS[i], 1, true) then return "SACK" end
    end
    for i = 1, #CHEST_WORDS do
        if string.find(value, CHEST_WORDS[i], 1, true) then return "CHEST" end
    end
    return nil
end

function F:GetPlayerRawPosition()
    if type(GetUnitRawWorldPosition) ~= "function" then return nil end
    local zoneId, x, y, z = safe(GetUnitRawWorldPosition, nil, "player")
    zoneId, x, y, z = tonumber(zoneId), tonumber(x), tonumber(y), tonumber(z)
    if not zoneId or not x or not y or not z then return nil end
    if x == 0 and y == 0 and z == 0 then return nil end
    return zoneId, x, y, z
end

function F:GetApproximateInteractablePosition()
    local zoneId, x, y, z = self:GetPlayerRawPosition()
    if not zoneId then return nil end

    -- ESO does not provide an interactable object's world position. At chest
    -- interaction range the player is already very close, so move the sample a
    -- small amount toward the camera heading. Even if the heading is unavailable,
    -- the player's raw position remains a useful persistent spawn approximation.
    local heading = tonumber(safe(GetPlayerCameraHeading, nil))
    if heading then
        x = x + (math.sin(heading) * INTERACT_FORWARD_OFFSET_CM)
        z = z + (math.cos(heading) * INTERACT_FORWARD_OFFSET_CM)
    end
    return zoneId, x, y, z
end

function F:GetInstanceKind()
    if EPC.saved and EPC.saved.dungeonChestFinderEnabled == false then return nil end

    local stamp = nowMs()
    if self.instanceKindCheckedAt and (stamp - self.instanceKindCheckedAt) < 1500 then
        return self.cachedInstanceKind or nil
    end
    local function finish(kind)
        self.instanceKindCheckedAt = stamp
        self.cachedInstanceKind = kind or false
        return kind
    end

    -- Do not gate everything on IsUnitInDungeon(). Some trial/arena states can
    -- be identified more reliably by the zone display type or dungeon difficulty.
    local inDungeon = safe(IsUnitInDungeon, false, "player") == true
    local inRaid = safe(IsPlayerInRaid, false) == true
    local displayType = self.currentZoneDisplayType

    -- Explicitly exclude non-target PvE spaces whenever ESO gave us a display type.
    if ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON ~= nil and displayType == ZONE_DISPLAY_TYPE_PUBLIC_DUNGEON then return finish(nil) end
    if ZONE_DISPLAY_TYPE_DELVE ~= nil and displayType == ZONE_DISPLAY_TYPE_DELVE then return finish(nil) end
    if ZONE_DISPLAY_TYPE_GROUP_DELVE ~= nil and displayType == ZONE_DISPLAY_TYPE_GROUP_DELVE then return finish(nil) end
    if ZONE_DISPLAY_TYPE_SOLO ~= nil and displayType == ZONE_DISPLAY_TYPE_SOLO then return finish(nil) end

    if ZONE_DISPLAY_TYPE_RAID ~= nil and displayType == ZONE_DISPLAY_TYPE_RAID then return finish("TRIAL") end
    if ZONE_DISPLAY_TYPE_DUNGEON ~= nil and displayType == ZONE_DISPLAY_TYPE_DUNGEON then return finish("DUNGEON") end
    if ZONE_DISPLAY_TYPE_GROUP_AREA ~= nil and displayType == ZONE_DISPLAY_TYPE_GROUP_AREA then return finish("GROUP_INSTANCE") end
    if ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON ~= nil and displayType == ZONE_DISPLAY_TYPE_ENDLESS_DUNGEON then return finish("INSTANCE") end

    local difficulty = nil
    if type(GetCurrentZoneDungeonDifficulty) == "function" then
        local ok, value = pcall(GetCurrentZoneDungeonDifficulty)
        if ok then difficulty = value end
    end

    local groupSize = tonumber(safe(GetGroupSize, 0)) or 0
    if difficulty ~= nil then
        if DUNGEON_DIFFICULTY_NORMAL ~= nil and difficulty == DUNGEON_DIFFICULTY_NORMAL then
            return finish((inRaid or groupSize >= 8) and "TRIAL" or "INSTANCE")
        end
        if DUNGEON_DIFFICULTY_VETERAN ~= nil and difficulty == DUNGEON_DIFFICULTY_VETERAN then
            return finish((inRaid or groupSize >= 8) and "TRIAL" or "INSTANCE")
        end
    end

    -- Runtime Group Dungeon matching is more expensive, so use it only as an
    -- ambiguity fallback and cache the result above instead of rescanning every tick.
    if EPC.DungeonFinder and type(EPC.DungeonFinder.GetCurrentGroupDungeonInfo) == "function" then
        local ok, info = pcall(EPC.DungeonFinder.GetCurrentGroupDungeonInfo, EPC.DungeonFinder)
        if ok and info then return finish("DUNGEON") end
    end

    if inRaid then return finish("TRIAL") end
    if inDungeon and difficulty ~= DUNGEON_DIFFICULTY_NONE then return finish("INSTANCE") end
    return finish(nil)
end

function F:IsSupportedInstance()
    return self:GetInstanceKind() ~= nil
end

function F:IsWorldGlowSuppressed()
    if EPC.saved and EPC.saved.hudHideInMenus == false then return false end
    if not SCENE_MANAGER or type(SCENE_MANAGER.IsShowing) ~= "function" then return false end
    for i = 1, #WORLD_GLOW_HIDE_SCENES do
        local ok, showing = pcall(SCENE_MANAGER.IsShowing, SCENE_MANAGER, WORLD_GLOW_HIDE_SCENES[i])
        if ok and showing == true then
            return true, WORLD_GLOW_HIDE_SCENES[i]
        end
    end
    return false
end

function F:GetZoneBucket(zoneId, create)
    if not EPC.saved then return nil end
    EPC.saved.dungeonChestLocations = EPC.saved.dungeonChestLocations or {}
    local key = tostring(tonumber(zoneId) or zoneId or "")
    if key == "" then return nil end
    local bucket = EPC.saved.dungeonChestLocations[key]
    if create and type(bucket) ~= "table" then
        bucket = {}
        EPC.saved.dungeonChestLocations[key] = bucket
    end
    return bucket, key
end

function F:EntryKey(zoneId, index)
    return tostring(zoneId) .. ":" .. tostring(index)
end

function F:FindNearbyEntry(zoneId, kind, x, z, maxDistanceCm)
    local bucket = self:GetZoneBucket(zoneId, false)
    if type(bucket) ~= "table" then return nil end
    local bestIndex, bestDistance
    for i = 1, #bucket do
        local entry = bucket[i]
        if type(entry) == "table" and entry.kind == kind then
            local d = distance2Dcm(x, z, entry.x, entry.z)
            if d <= (maxDistanceCm or DEDUPE_DISTANCE_CM) and (not bestDistance or d < bestDistance) then
                bestIndex, bestDistance = i, d
            end
        end
    end
    if not bestIndex then return nil end
    return bucket[bestIndex], bestIndex, bestDistance
end

function F:LearnInteractable(name, kind, forceSample)
    if not EPC.saved or EPC.saved.dungeonChestFinderEnabled == false then return nil end
    if not self:IsSupportedInstance() then return nil end
    local zoneId, x, y, z = self:GetApproximateInteractablePosition()
    if not zoneId then return nil end

    local entry, index = self:FindNearbyEntry(zoneId, kind, x, z, DEDUPE_DISTANCE_CM)
    if not entry and EPC.saved.dungeonChestLearnLocations ~= false then
        local bucket = self:GetZoneBucket(zoneId, true)
        entry = {
            kind = kind,
            name = tostring(name or (kind == "SACK" and "Heavy Sack" or "Chest")),
            x = math.floor(x + 0.5),
            y = math.floor(y + 0.5),
            z = math.floor(z + 0.5),
            learnedAt = tonumber(safe(GetTimeStamp, 0)) or 0,
            zoneName = tostring(safe(GetPlayerActiveZoneName, "") or ""),
        }
        bucket[#bucket + 1] = entry
        index = #bucket
    elseif entry and forceSample == true then
        -- A successful interaction is our best available approximation of the
        -- actual chest center. ESO does not expose the object's own world
        -- coordinates, so recenter the learned point from the player's current
        -- reticle-facing interaction position instead of leaving an older
        -- approach-angle sample around the chest.
        if not entry.name or entry.name == "" then entry.name = tostring(name or "") end
        entry.x = math.floor(x + 0.5)
        entry.y = math.floor(y + 0.5)
        entry.z = math.floor(z + 0.5)
    end

    if not entry or not index then return nil end
    local key = self:EntryKey(zoneId, index)
    self.confirmed = self.confirmed or {}
    -- Once ESO has actually identified this object, keep it in the bright
    -- confirmed state for the rest of the run (until looted) instead of only
    -- flashing for a couple seconds while the reticle happens to be over it.
    self.confirmed[key] = true
    self.lastDetectedName = tostring(name or entry.name or "")
    self.lastDetectedKind = kind
    self.lastDetectedKey = key
    self.lastDetectedAt = nowMs()
    -- Only a real interaction attempt arms per-run clearing. Merely looking at
    -- a chest must not let an unrelated nearby loot window clear its marker.
    if forceSample == true then
        self.pendingLootKey = key
        self.pendingLootAt = nowMs()
        self.pendingLootZoneId = zoneId
    end
    return key, entry, index
end

function F:CheckReticleInteractable()
    if not self:IsSupportedInstance() then return end
    if type(GetGameCameraInteractableActionInfo) ~= "function" then return end

    local action, name, blocked = safe(GetGameCameraInteractableActionInfo, nil)
    if blocked == true or type(name) ~= "string" or name == "" then return end
    local kind = self:ClassifyInteractable(name)
    if not kind then return end
    self:LearnInteractable(name, kind, false)
end

function F:HandleClientInteractResult(result, targetName)
    if not self:IsSupportedInstance() then return end
    if CLIENT_INTERACT_RESULT_SUCCESS ~= nil and result ~= CLIENT_INTERACT_RESULT_SUCCESS then return end
    local kind = self:ClassifyInteractable(targetName)
    if not kind then return end
    self:LearnInteractable(targetName, kind, true)
end

function F:TryClearPendingLoot()
    local key = self.pendingLootKey
    local pendingAt = tonumber(self.pendingLootAt) or 0
    if not key or (nowMs() - pendingAt) > PENDING_LOOT_WINDOW_MS then
        self.pendingLootKey = nil
        return
    end

    local zoneId, px, _, pz = self:GetPlayerRawPosition()
    if not zoneId or tonumber(zoneId) ~= tonumber(self.pendingLootZoneId) then return end

    local zonePart, indexPart = string.match(key, "^([^:]+):(%d+)$")
    local bucket = zonePart and self:GetZoneBucket(zonePart, false) or nil
    local entry = bucket and bucket[tonumber(indexPart)] or nil
    if type(entry) ~= "table" then return end

    if distance2Dcm(px, pz, entry.x, entry.z) <= LOOT_MATCH_DISTANCE_CM then
        self.runCleared = self.runCleared or {}
        self.runCleared[key] = true
        self.confirmed[key] = nil
        self.pendingLootKey = nil
        self.pendingLootAt = 0
    end
end

function F:EnsureWindow()
    if self.window then
        if type(self.window.SetHidden) == "function" then self.window:SetHidden(false) end
        if self.cameraWindow and type(self.cameraWindow.SetHidden) == "function" then self.cameraWindow:SetHidden(false) end
        return
    end
    local win = wm:CreateTopLevelWindow("EAS_DungeonChestFinderWorld")
    self.window = win
    win:SetHidden(false)
    win:SetDimensions(1, 1)
    win:SetMouseEnabled(false)
    win:SetMovable(false)
    win:SetClampedToScreen(false)
    win:ClearAnchors()
    win:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, -10, -10)
    if type(win.Create3DRenderSpace) == "function" then win:Create3DRenderSpace() end
    if type(win.SetDrawLayer) == "function" then win:SetDrawLayer(DL_BACKGROUND) end
    if type(win.SetDrawTier) == "function" then win:SetDrawTier(DT_LOW) end

    -- Match Team Visibility's camera-relative orientation path. The hidden
    -- camera render space lets the glow plane stay broadside to the camera
    -- instead of becoming effectively edge-on at some camera pitches.
    if not self.cameraWindow then
        local cameraWin = wm:CreateTopLevelWindow("EAS_DungeonChestFinderCameraWindow")
        self.cameraWindow = cameraWin
        cameraWin:SetHidden(false)
        cameraWin:SetDimensions(1, 1)
        cameraWin:SetMouseEnabled(false)
        local cameraControl = wm:CreateControl("EAS_DungeonChestFinderCameraControl", cameraWin, CT_TEXTURE)
        self.cameraControl = cameraControl
        cameraControl:SetHidden(true)
        if type(cameraWin.Create3DRenderSpace) == "function" then cameraWin:Create3DRenderSpace() end
        if type(cameraControl.Create3DRenderSpace) == "function" then cameraControl:Create3DRenderSpace() end
        if type(cameraControl.Set3DLocalDimensions) == "function" then cameraControl:Set3DLocalDimensions(0.01, 0.01) end
    end
end

function F:GetCameraForwardY()
    if not self.cameraControl or type(Set3DRenderSpaceToCurrentCamera) ~= "function" then return 0 end
    pcall(Set3DRenderSpaceToCurrentCamera, "EAS_DungeonChestFinderCameraControl")
    if type(self.cameraControl.Get3DRenderSpaceForward) == "function" then
        local _, y = self.cameraControl:Get3DRenderSpaceForward()
        return tonumber(y) or 0
    end
    return 0
end

function F:ResetRenderSpace()
    self:EnsureWindow()
    local win = self.window
    if win and type(win.Destroy3DRenderSpace) == "function" and type(win.Create3DRenderSpace) == "function" then
        pcall(function()
            win:Destroy3DRenderSpace()
            win:Create3DRenderSpace()
        end)
    end
    local cameraWin = self.cameraWindow
    local cameraControl = self.cameraControl
    if cameraWin and type(cameraWin.Destroy3DRenderSpace) == "function" and type(cameraWin.Create3DRenderSpace) == "function" then
        pcall(function()
            cameraWin:Destroy3DRenderSpace()
            cameraWin:Create3DRenderSpace()
        end)
    end
    if cameraControl and type(cameraControl.Destroy3DRenderSpace) == "function" and type(cameraControl.Create3DRenderSpace) == "function" then
        pcall(function()
            cameraControl:Destroy3DRenderSpace()
            cameraControl:Create3DRenderSpace()
            cameraControl:Set3DLocalDimensions(0.01, 0.01)
        end)
    end

    if self.markers then
        for _, marker in ipairs(self.markers) do
            if marker.layers then
                for _, tex in ipairs(marker.layers) do
                    if tex and type(tex.Destroy3DRenderSpace) == "function" and type(tex.Create3DRenderSpace) == "function" then
                        pcall(function()
                            tex:Destroy3DRenderSpace()
                            tex:Create3DRenderSpace()
                        end)
                    end
                end
            end
        end
    end
end

function F:ApplyGlowTextureState(tex, flipHorizontal)
    if not tex then return end
    if tex.easTextureSource ~= GLOW_SOURCE_TEXTURE then
        tex:SetTexture(GLOW_SOURCE_TEXTURE)
        tex.easTextureSource = GLOW_SOURCE_TEXTURE
    end
    if type(tex.SetAddressMode) == "function" and TEX_MODE_CLAMP ~= nil then tex:SetAddressMode(TEX_MODE_CLAMP) end
    if type(tex.SetTextureCoords) == "function" then
        if flipHorizontal then
            tex:SetTextureCoords(GLOW_U2, GLOW_U1, GLOW_V1, GLOW_V2)
        else
            tex:SetTextureCoords(GLOW_U1, GLOW_U2, GLOW_V1, GLOW_V2)
        end
    end
    if type(tex.SetTextureSampleProcessingWeight) == "function" then
        pcall(function()
            tex:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_RGB, 1.00)
            tex:SetTextureSampleProcessingWeight(TEX_SAMPLE_PROCESSING_ALPHA_AS_RGB, 0)
        end)
    end
end

function F:EnsureMarker(index)
    self:EnsureWindow()
    self.markers = self.markers or {}
    if self.markers[index] then return self.markers[index] end

    local marker = { layers = {}, index = index }
    for layer = 1, GLOW_LAYERS do
        local tex = wm:CreateControl(nil, self.window, CT_TEXTURE)
        tex:SetHidden(true)
        if type(tex.SetTextureReleaseOption) == "function" and RELEASE_TEXTURE_AT_ZERO_REFERENCES ~= nil then
            tex:SetTextureReleaseOption(RELEASE_TEXTURE_AT_ZERO_REFERENCES)
        end
        tex:ClearAnchors()
        tex:SetAnchor(CENTER, self.window, CENTER, 0, 0)
        if type(tex.SetBlendMode) == "function" then
            if TEX_BLEND_MODE_ADD ~= nil then tex:SetBlendMode(TEX_BLEND_MODE_ADD)
            elseif TEX_BLEND_MODE_ALPHA ~= nil then tex:SetBlendMode(TEX_BLEND_MODE_ALPHA) end
        end
        if type(tex.SetAddressMode) == "function" and TEX_MODE_CLAMP ~= nil then tex:SetAddressMode(TEX_MODE_CLAMP) end
        if type(tex.Create3DRenderSpace) == "function" then tex:Create3DRenderSpace() end
        if type(tex.Set3DLocalDimensions) == "function" then tex:Set3DLocalDimensions(BASE_GLOW_WIDTH_M, BASE_GLOW_HEIGHT_M) end
        if type(tex.SetDrawLevel) == "function" then tex:SetDrawLevel(20 + ((index + layer) % 4)) end
        local flipHorizontal = (layer % 2 == 0)
        self:ApplyGlowTextureState(tex, flipHorizontal)
        zo_callLater(function() self:ApplyGlowTextureState(tex, flipHorizontal) end, 100)
        marker.layers[layer] = tex
    end

    self.markers[index] = marker
    return marker
end

function F:HideMarker(marker)
    if marker and marker.layers then
        for _, tex in ipairs(marker.layers) do
            if tex then tex:SetHidden(true) end
        end
    end
end

function F:HideAllMarkers(reason)
    if self.markers then
        for _, marker in ipairs(self.markers) do self:HideMarker(marker) end
    end
    self.lastVisibleCount = 0
    if reason then self.lastHiddenReason = tostring(reason) end
end

function F:GetMarkerColor(kind)
    local saved = EPC.saved or {}
    local c
    if kind == "SACK" then c = saved.dungeonChestSackColor or DEFAULT_SACK_COLOR
    else c = saved.dungeonChestColor or DEFAULT_CHEST_COLOR end
    return tonumber(c.r) or 1, tonumber(c.g) or 1, tonumber(c.b) or 1
end

function F:PositionMarker(marker, entry, distanceM, confirmed)
    if not marker or not marker.layers or type(entry) ~= "table" then return false end
    if type(WorldPositionToGuiRender3DPosition) ~= "function" then return false end

    local x, y, z = tonumber(entry.x), tonumber(entry.y), tonumber(entry.z)
    if not x or not y or not z then return false end
    local gx, gy, gz = safe(WorldPositionToGuiRender3DPosition, nil, x, y + GLOW_VERTICAL_OFFSET_CM, z)
    gx, gy, gz = tonumber(gx), tonumber(gy), tonumber(gz)
    if not gx or not gy or not gz then return false end

    local ox, oy, oz = 0, 0, 0
    if self.window and type(self.window.Get3DRenderSpaceOrigin) == "function" then
        local rx, ry, rz = safe(self.window.Get3DRenderSpaceOrigin, nil, self.window)
        ox, oy, oz = tonumber(rx) or 0, tonumber(ry) or 0, tonumber(rz) or 0
    end
    gx, gy, gz = gx - ox, gy - oy, gz - oz

    self.lastRenderInfo = {
        name = tostring(entry.name or entry.kind or "spawn"),
        kind = tostring(entry.kind or ""),
        rawX = x, rawY = y, rawZ = z,
        guiX = gx, guiY = gy, guiZ = gz,
        distanceM = tonumber(distanceM) or 0,
        confirmed = confirmed == true,
    }

    local saved = EPC.saved or {}
    local scale = tonumber(saved.dungeonChestMarkerScale) or 1.0
    local width = BASE_GLOW_WIDTH_M * scale
    local height = BASE_GLOW_HEIGHT_M * scale
    if distanceM > FAR_SCALE_START_M then
        local farScale = math.min(2.00, 1.0 + ((distanceM - FAR_SCALE_START_M) / 140))
        width, height = width * farScale, height * farScale
    end
    if confirmed then
        -- Keep the confirmed glow tight to the chest rather than expanding into
        -- a large surrounding marker. Brightness/pulse conveys confirmation.
        width = width * 1.00
        height = height * 1.00
    end

    local throughWalls = saved.dungeonChestThroughWalls ~= false
    local r, g, b = self:GetMarkerColor(entry.kind)
    local intensity = zo_clamp(tonumber(saved.dungeonChestGlowOpacity) or 0.60, 0.05, 1.00)
    local pulse = 1.0
    if confirmed then
        local phase = (nowMs() % 1200) / 1200
        pulse = 0.72 + (0.28 * (0.5 - 0.5 * math.cos(phase * math.pi * 2)))
    end
    local baseAlpha = confirmed and math.min(1.0, intensity * 1.35) or math.max(0.18, intensity * 0.72)
    local heading = tonumber(safe(GetPlayerCameraHeading, 0)) or 0
    local pitch = BASE_PITCH + math.abs(self:GetCameraForwardY()) * BASE_PITCH

    for layer = 1, #marker.layers do
        local tex = marker.layers[layer]
        self:ApplyGlowTextureState(tex, layer % 2 == 0)
        if type(tex.Set3DRenderSpaceOrigin) == "function" then tex:Set3DRenderSpaceOrigin(gx, gy, gz) end
        if type(tex.Set3DRenderSpaceOrientation) == "function" then tex:Set3DRenderSpaceOrientation(pitch, heading, 0) end
        if type(tex.Set3DLocalDimensions) == "function" then
            local layerScale = layer == 1 and 1.00 or 0.78
            tex:Set3DLocalDimensions(width * layerScale, height * layerScale)
        end
        if type(tex.Set3DRenderSpaceUsesDepthBuffer) == "function" then tex:Set3DRenderSpaceUsesDepthBuffer(not throughWalls) end
        local layerAlpha = zo_clamp(baseAlpha * pulse, 0.02, 1.00)
        tex:SetColor(r, g, b, layerAlpha)
        tex:SetAlpha(layerAlpha)
        if type(tex.SetVertexColors) == "function" then
            tex:SetVertexColors(1 + 2, r, g, b, layerAlpha)
            tex:SetVertexColors(4 + 8, r, g, b, layerAlpha)
        end
        tex:SetHidden(false)
        -- Reassert the parent visibility as well. ESO may alter top-level visibility
        -- while switching UI/camera modes even though the texture itself still has
        -- valid 3D render-space state.
        if self.window and type(self.window.SetHidden) == "function" then self.window:SetHidden(false) end
    end
    self.lastRenderStatus = "ok"
    self.lastRenderEntry = tostring(entry.name or entry.kind or "spawn")
    self.lastRenderDistance = distanceM
    return true
end

function F:RefreshMarkers()
    if not EPC.saved or EPC.saved.enabled == false then
        self:HideAllMarkers("suite disabled")
        return
    end
    if EPC.saved.dungeonChestFinderEnabled == false then
        self:HideAllMarkers("finder disabled")
        return
    end
    if not self:IsSupportedInstance() then
        self:HideAllMarkers("unsupported instance")
        return
    end
    local suppressed, sceneName = self:IsWorldGlowSuppressed()
    if suppressed then
        self:HideAllMarkers("menu scene: " .. tostring(sceneName or "unknown"))
        return
    end

    local zoneId, px, _, pz = self:GetPlayerRawPosition()
    if not zoneId then self:HideAllMarkers("no player world position") return end
    local bucket = self:GetZoneBucket(zoneId, false)
    if type(bucket) ~= "table" then bucket = {} end

    self:EnsureWindow()
    -- SavedVariables from older builds or manual edits can contain values outside
    -- the settings slider range. Clamp here so a bad zero/tiny value can never
    -- suppress a chest that is right beside the player.
    local configuredDistanceM = tonumber(EPC.saved.dungeonChestDistance) or 120
    local maxDistanceM = zo_clamp(configuredDistanceM, 25, 250)
    local showPossible = EPC.saved.dungeonChestShowPossible ~= false
    local showSacks = EPC.saved.dungeonChestShowHeavySacks ~= false
    local visible = {}
    local nearestDistanceM = nil
    local hiddenDistance, hiddenSacks, hiddenPossible, hiddenCleared = 0, 0, 0, 0

    for i = 1, #bucket do
        local entry = bucket[i]
        if type(entry) == "table" then
            if entry.kind == "SACK" and not showSacks then
                hiddenSacks = hiddenSacks + 1
            else
                local key = self:EntryKey(zoneId, i)
                if self.runCleared and self.runCleared[key] then
                    hiddenCleared = hiddenCleared + 1
                else
                    local distanceM = distance2Dcm(px, pz, entry.x, entry.z) / 100
                    if not nearestDistanceM or distanceM < nearestDistanceM then nearestDistanceM = distanceM end
                    local confirmed = self.confirmed and self.confirmed[key] == true

                    -- A chest that ESO has confirmed during this run must never
                    -- be lost solely because of a stale/corrupt distance setting.
                    -- Possible-spawn markers still obey the configured range.
                    if distanceM <= maxDistanceM or confirmed then
                        if showPossible or confirmed then
                            visible[#visible + 1] = { entry = entry, key = key, distance = distanceM, confirmed = confirmed == true }
                        else
                            hiddenPossible = hiddenPossible + 1
                        end
                    else
                        hiddenDistance = hiddenDistance + 1
                    end
                end
            end
        end
    end

    -- If ESO has confirmed one or more real chests/Heavy Sacks during this run,
    -- do not leave unconfirmed learned spawn glows surrounding them. A confirmed
    -- object should read as one glow centered on the chest itself. Possible spawn
    -- locations remain available only when there is no confirmed object to show.
    local hasConfirmedVisible = false
    for i = 1, #visible do
        if visible[i].confirmed then
            hasConfirmedVisible = true
            break
        end
    end
    local hiddenAroundConfirmed = 0
    if hasConfirmedVisible then
        local confirmedOnly = {}
        for i = 1, #visible do
            if visible[i].confirmed then
                confirmedOnly[#confirmedOnly + 1] = visible[i]
            else
                hiddenAroundConfirmed = hiddenAroundConfirmed + 1
            end
        end
        visible = confirmedOnly
    end

    -- /eachests test creates one temporary unsaved glow four metres in front of
    -- the player. This isolates the 3D renderer from learned-location filtering.
    if self.debugTestEntry and nowMs() < (tonumber(self.debugTestUntil) or 0) then
        visible[#visible + 1] = {
            entry = self.debugTestEntry,
            key = "debug-test",
            distance = 4,
            confirmed = true,
            debug = true,
        }
    elseif self.debugTestEntry then
        self.debugTestEntry = nil
        self.debugTestUntil = 0
    end

    table.sort(visible, function(a, b)
        if a.debug ~= b.debug then return a.debug == true end
        if a.confirmed ~= b.confirmed then return a.confirmed end
        return a.distance < b.distance
    end)

    local used = math.min(#visible, MAX_MARKERS)
    for i = 1, used do
        local marker = self:EnsureMarker(i)
        if not self:PositionMarker(marker, visible[i].entry, visible[i].distance, visible[i].confirmed) then
            self.lastRenderStatus = "world-position conversion failed"
            self:HideMarker(marker)
        end
    end
    if self.markers then
        for i = used + 1, #self.markers do
            self:HideMarker(self.markers[i])
        end
    end

    self.lastFilterStats = {
        known = #bucket,
        maxDistanceM = maxDistanceM,
        nearestDistanceM = nearestDistanceM,
        hiddenDistance = hiddenDistance,
        hiddenSacks = hiddenSacks,
        hiddenPossible = hiddenPossible,
        hiddenCleared = hiddenCleared,
        hiddenAroundConfirmed = hiddenAroundConfirmed,
        showPossible = showPossible,
        showSacks = showSacks,
    }
    self.lastVisibleCount = used
    if used > 0 then
        self.lastHiddenReason = "none"
        self.lastVisibleAt = nowMs()
    elseif #bucket == 0 then
        self.lastHiddenReason = "no learned locations here"
    elseif hiddenDistance > 0 and nearestDistanceM then
        self.lastHiddenReason = string.format("nearest %.1fm > max %dm", nearestDistanceM, maxDistanceM)
    elseif hiddenSacks > 0 and hiddenSacks == #bucket then
        self.lastHiddenReason = "Heavy Sack glows disabled"
    elseif hiddenPossible > 0 then
        self.lastHiddenReason = "possible spawns disabled; none confirmed"
    elseif hiddenCleared > 0 then
        self.lastHiddenReason = "nearby learned spawns already looted this run"
    else
        self.lastHiddenReason = "no locations passed current filters"
    end
end

function F:RefreshSettings()
    self:RefreshMarkers()
end

function F:ClearLearnedLocations()
    if EPC.saved then EPC.saved.dungeonChestLocations = {} end
    self.confirmed = {}
    self.runCleared = {}
    self.pendingLootKey = nil
    self:HideAllMarkers()
end

function F:GetLearnedCount()
    local count = 0
    local all = EPC.saved and EPC.saved.dungeonChestLocations
    if type(all) == "table" then
        for _, bucket in pairs(all) do
            if type(bucket) == "table" then count = count + #bucket end
        end
    end
    return count
end

function F:GetStatusText()
    local kind = self:GetInstanceKind()
    local zoneId = select(1, self:GetPlayerRawPosition())
    local bucket = zoneId and self:GetZoneBucket(zoneId, false)
    local knownHere = type(bucket) == "table" and #bucket or 0
    local last = (self.lastDetectedName and self.lastDetectedName ~= "") and self.lastDetectedName or "none"
    local render = self.lastRenderStatus or "not rendered yet"
    local texture = "none"
    local marker = self.markers and self.markers[1]
    local tex = marker and marker.layers and marker.layers[1]
    if tex then
        local loaded = "n/a"
        if type(tex.IsTextureLoaded) == "function" then
            local ok, value = pcall(function() return tex:IsTextureLoaded() end)
            if ok then loaded = tostring(value) end
        end
        local has3D = type(tex.Has3DRenderSpace) == "function" and tostring(tex:Has3DRenderSpace()) or "n/a"
        local hidden = type(tex.IsHidden) == "function" and tostring(tex:IsHidden()) or "n/a"
        texture = string.format("loaded=%s 3D=%s hidden=%s", loaded, has3D, hidden)
    end
    local visibleCount = tonumber(self.lastVisibleCount) or 0
    local hiddenReason = tostring(self.lastHiddenReason or "none")
    local stats = self.lastFilterStats or {}
    local nearest = tonumber(stats.nearestDistanceM)
    local rangeText = nearest and string.format("Nearest: %.1fm / Max: %dm.", nearest, tonumber(stats.maxDistanceM) or 0)
        or string.format("Nearest: none / Max: %dm.", tonumber(stats.maxDistanceM) or (tonumber(EPC.saved and EPC.saved.dungeonChestDistance) or 120))
    local filtersText = string.format("Filtered d=%d sack=%d possible=%d looted=%d around=%d.",
        tonumber(stats.hiddenDistance) or 0,
        tonumber(stats.hiddenSacks) or 0,
        tonumber(stats.hiddenPossible) or 0,
        tonumber(stats.hiddenCleared) or 0,
        tonumber(stats.hiddenAroundConfirmed) or 0)

    if not kind then
        return string.format("Chest Finder idle. Learned: %d. Last: %s. Visible: %d. Hidden: %s. %s %s Renderer: %s. Texture: %s.",
            self:GetLearnedCount(), last, visibleCount, hiddenReason, rangeText, filtersText, render, texture)
    end
    return string.format("Chest Finder active (%s). Known here: %d. Total: %d. Last: %s. Visible: %d. Hidden: %s. %s %s Renderer: %s. Texture: %s.",
        tostring(kind), knownHere, self:GetLearnedCount(), last, visibleCount, hiddenReason, rangeText, filtersText, render, texture)
end

function F:StartDebugTestGlow()
    local zoneId, x, y, z = self:GetPlayerRawPosition()
    if not zoneId then return false end
    local heading = tonumber(safe(GetPlayerCameraHeading, 0)) or 0
    local offset = 400 -- 4m in raw-world centimeters
    self.debugTestEntry = {
        kind = "CHEST",
        name = "Chest Finder Test Glow",
        x = x + (math.sin(heading) * offset),
        y = y,
        z = z + (math.cos(heading) * offset),
    }
    self.debugTestUntil = nowMs() + 10000
    self:RefreshMarkers()
    return true
end

function F:HandlePlayerActivated()
    self.instanceKindCheckedAt = 0
    local zoneId = select(1, self:GetPlayerRawPosition())
    local supported = self:IsSupportedInstance()
    if tonumber(zoneId) ~= tonumber(self.activeZoneId) or (supported and not self.wasSupported) then
        self.runCleared = {}
        self.confirmed = {}
        self.pendingLootKey = nil
    end
    self.activeZoneId = zoneId
    self.wasSupported = supported
    self:HideAllMarkers()
    zo_callLater(function()
        self:ResetRenderSpace()
        self:RefreshMarkers()
    end, 400)
end

function F:Initialize()
    self.markers = {}
    self.confirmed = {}
    self.runCleared = {}
    self.pendingLootKey = nil
    self.currentZoneDisplayType = nil
    self.activeZoneId = nil
    self.wasSupported = false
    self.instanceKindCheckedAt = 0
    self.cachedInstanceKind = false
    self.debugTestEntry = nil
    self.debugTestUntil = 0
    self.lastFilterStats = {}

    if EPC.saved then
        EPC.saved.dungeonChestLocations = EPC.saved.dungeonChestLocations or {}
        if EPC.saved.dungeonChestColor == nil then EPC.saved.dungeonChestColor = { r = DEFAULT_CHEST_COLOR.r, g = DEFAULT_CHEST_COLOR.g, b = DEFAULT_CHEST_COLOR.b } end
        if EPC.saved.dungeonChestSackColor == nil then EPC.saved.dungeonChestSackColor = { r = DEFAULT_SACK_COLOR.r, g = DEFAULT_SACK_COLOR.g, b = DEFAULT_SACK_COLOR.b } end
        if EPC.saved.dungeonChestGlowOpacity == nil then EPC.saved.dungeonChestGlowOpacity = 0.60 end
        local styleVersion = tonumber(EPC.saved.dungeonChestGlowStyleVersion) or 0
        if styleVersion < 2 then
            -- 0.28.66's possible-spawn alpha was too faint in the additive 3D
            -- path. Preserve stronger custom values but migrate the old defaults.
            if (tonumber(EPC.saved.dungeonChestGlowOpacity) or 0) <= 0.34 then EPC.saved.dungeonChestGlowOpacity = 0.60 end
            if (tonumber(EPC.saved.dungeonChestMarkerScale) or 0) <= 1.0 then EPC.saved.dungeonChestMarkerScale = 1.20 end
            styleVersion = 2
        end
        if styleVersion < 3 then
            -- 0.28.70 switches from broad possible-spawn glows to a compact
            -- chest-centered confirmation glow. Disable possible-spawn clutter
            -- on upgrade and normalize the old oversized default.
            EPC.saved.dungeonChestShowPossible = false
            if (tonumber(EPC.saved.dungeonChestMarkerScale) or 0) <= 1.25 then
                EPC.saved.dungeonChestMarkerScale = 1.00
            end
            EPC.saved.dungeonChestGlowStyleVersion = 3
        end
    end

    self.lastRenderStatus = "not rendered yet"
    self.lastVisibleCount = 0
    self.lastHiddenReason = "not rendered yet"

    self:EnsureWindow()
    local prefix = (EPC.name or "EAS") .. "_DungeonChestFinder"

    EVENT_MANAGER:RegisterForUpdate(prefix .. "_Update", UPDATE_MS, function()
        if EPC.saved and EPC.saved.enabled ~= false and EPC.saved.dungeonChestFinderEnabled ~= false
            and self:IsSupportedInstance() then
            self:CheckReticleInteractable()
            self:RefreshMarkers()
        else
            self:RefreshMarkers()
        end
    end)

    if EVENT_CLIENT_INTERACT_RESULT ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Interact", EVENT_CLIENT_INTERACT_RESULT, function(_, result, targetName)
            self:HandleClientInteractResult(result, targetName)
        end)
    end

    if EVENT_LOOT_CLOSED ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_LootClosed", EVENT_LOOT_CLOSED, function()
            self:TryClearPendingLoot()
        end)
    end

    if EVENT_PREPARE_FOR_JUMP ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_PrepareJump", EVENT_PREPARE_FOR_JUMP, function(_, zoneName, zoneDescription, loadingTexture, zoneDisplayType)
            self.currentZoneDisplayType = zoneDisplayType
            self.instanceKindCheckedAt = 0
        end)
    end

    if EVENT_PLAYER_ACTIVATED ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Activated", EVENT_PLAYER_ACTIVATED, function()
            self:HandlePlayerActivated()
        end)
    end

    if EVENT_ZONE_CHANGED ~= nil then
        EVENT_MANAGER:RegisterForEvent(prefix .. "_Zone", EVENT_ZONE_CHANGED, function(_, unitTag)
            if not unitTag or unitTag == "player" then
                self:HideAllMarkers()
            end
        end)
    end

    SLASH_COMMANDS["/eachests"] = function(arg)
        arg = lower(zo_strtrim(tostring(arg or "")))
        if arg == "clear" then
            self:ClearLearnedLocations()
            if EPC.Print then EPC:Print("Dungeon / Trial Chest Finder learned locations cleared.") end
        elseif arg == "test" then
            local ok = self:StartDebugTestGlow()
            if EPC.Print then
                EPC:Print(ok and "Chest Finder test glow placed 4m in front of you for 10 seconds." or "Chest Finder test glow could not get the player world position.")
            end
        else
            if EPC.Print then EPC:Print(self:GetStatusText()) end
        end
    end

    self:HandlePlayerActivated()
end
