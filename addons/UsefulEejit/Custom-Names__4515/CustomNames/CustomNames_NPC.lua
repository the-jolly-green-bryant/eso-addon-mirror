-- CustomNames_NPC.lua
-- Renames NPCs across all relevant UI surfaces.

local CN = CustomNames

------------------------------------------------------------------------
-- GetChatterName() — NPC name in the dialogue/conversation window.
-- Zero-argument C-side function, entirely separate from GetUnitName.
------------------------------------------------------------------------

local orig_GetChatterName = GetChatterName
GetChatterName = function()
    return CN.LookupNPC(orig_GetChatterName())
end

------------------------------------------------------------------------
-- GetGameCameraInteractableActionInfo() — the reticle interact prompt.
-- Return #2 (interactableName) is the name shown next to the action verb.
-- Handles both NPC renames and cell door renames in a single override.
------------------------------------------------------------------------

-- Selectable (door/chair/container) position-based ID.
-- Zone:Name:X:Y at ~5m grid precision — stable across approach angles.
local function MakeDoorID(zone, name, px, py)
    return zone .. ":" .. name .. ":" .. math.floor(px * 200 + 0.5) .. ":" .. math.floor(py * 200 + 0.5)
end

local orig_GetGameCameraInteractableActionInfo = GetGameCameraInteractableActionInfo
GetGameCameraInteractableActionInfo = function()
    local action, interactableName, interactionBlocked, isOwned,
          additionalInteractInfo, context, contextLink, isCriminalInteract =
        orig_GetGameCameraInteractableActionInfo()

    if interactableName and interactableName ~= "" and CN.savedVars and CN.savedVars.enabled then
        local isDoor = (additionalInteractInfo == ADDITIONAL_INTERACT_INFO_NONE
                     or additionalInteractInfo == ADDITIONAL_INTERACT_INFO_INSTANCE_TYPE
                     or additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_INSTANCE_DOOR)
        if isDoor then
            -- Selectables: position-keyed specific rename only.
            if CN.savedVars.doorNames then
                local zone = GetUnitZone("player") or ""
                local px, py = GetMapPlayerPosition("player")
                if zone ~= "" and px and not (px == 0 and py == 0) then
                    local id = MakeDoorID(zone, interactableName, px, py)
                    local renamed = CN.savedVars.doorNames[id]
                    if renamed and renamed ~= "" then
                        interactableName = renamed
                    end
                end
            end
        else
            -- NPCs: name lookup only.
            interactableName = CN.LookupNPC(interactableName)
        end
        -- Apply zone and location rename. Load doors often display the destination
        -- zone name (e.g. "Greenshade"), so LookupAny checks both zoneNames and
        -- locationNames — whichever has an entry wins.
        interactableName = CN.LookupAny(interactableName)
    end

    return action, interactableName, interactionBlocked, isOwned,
           additionalInteractInfo, context, contextLink, isCriminalInteract
end

------------------------------------------------------------------------
-- GetUnitName() — target frame, group frames, and any other UI that
-- calls GetUnitName("reticleover") or similar unit tags.
-- Guarded with IsUnitPlayer so player names are never touched.
------------------------------------------------------------------------

local orig_GetUnitName = GetUnitName
GetUnitName = function(unitTag)
    local name = orig_GetUnitName(unitTag)
    if name and name ~= "" and not IsUnitPlayer(unitTag) then
        return CN.LookupNPC(name)
    end
    return name
end

------------------------------------------------------------------------
-- Floating nameplate hook
--
-- GetUnitName is already overridden globally so nameplates created after
-- our addon loads automatically use the renamed string. For nameplates
-- already active at load time we force an immediate UpdateName refresh.
------------------------------------------------------------------------

local function HookNameplatePool()
    -- Refresh nameplates already visible at load time. CN.RefreshNPCNameplates
    -- is defined below and does the same work; call it directly.
    CN.RefreshNPCNameplates()
end

function CN.RefreshNPCNameplates()
    local mgr = ZO_NameplateManager
    if not mgr or not mgr.nameplatePool then return end
    local active = mgr.nameplatePool:GetActiveObjects()
    if active then
        for _, np in pairs(active) do
            if np.UpdateName then pcall(np.UpdateName, np) end
        end
    end
end

------------------------------------------------------------------------
-- Subtitle speaker name
--
-- subtitles.lua registers its EVENT_SHOW_SUBTITLE handler as a closure
-- on the control, not via EVENT_MANAGER, so we can't intercept the event.
-- Instead we wrap ZO_Subtitle:GetFormattedMessage at the class level —
-- this is what the manager calls to build the display string, and it's
-- where speakerName and messageText are combined. We only touch speakerName.
--
-- ZO_Subtitle is defined in subtitles.lua which loads before addons, but
-- we hook inside InitNPC() to be safe and avoid any load-order issues.
------------------------------------------------------------------------

local function HookSubtitleSpeaker()
    if not ZO_Subtitle or ZO_Subtitle._CN_hooked then return end
    ZO_Subtitle._CN_hooked = true

    local origGetFormatted = ZO_Subtitle.GetFormattedMessage
    ZO_Subtitle.GetFormattedMessage = function(self, showSpeakerName)
        local orig = self.speakerName
        local renamed = CN.LookupNPC(orig)
        if renamed ~= orig then
            self.speakerName = renamed
            local result = origGetFormatted(self, showSpeakerName)
            self.speakerName = orig
            return result
        end
        return origGetFormatted(self, showSpeakerName)
    end
end

------------------------------------------------------------------------
-- Target name helper for the settings panel "Add NPC" prefill
------------------------------------------------------------------------

function CN.GetTargetNPCName()
    local name = orig_GetUnitName("reticleover")
    if name and name ~= "" then return name end
    return CN._lastTargetName
end

------------------------------------------------------------------------
-- Init
------------------------------------------------------------------------

function CN.InitNPC()
    -- Hook subtitle speaker name. ZO_Subtitle is available by this point.
    HookSubtitleSpeaker()

    -- Track last targeted NPC for the settings panel prefill.
    EVENT_MANAGER:RegisterForEvent(
        CN.ADDON_NAME .. "_NPCTarget",
        EVENT_RETICLE_TARGET_CHANGED,
        function()
            local name = orig_GetUnitName("reticleover")
            if name and name ~= "" and not IsUnitPlayer("reticleover") then
                CN._lastTargetName = name
            end
        end
    )

    -- Hook the nameplate pool after all managers are initialised.
    EVENT_MANAGER:RegisterForEvent(
        CN.ADDON_NAME .. "_Nameplates",
        EVENT_PLAYER_ACTIVATED,
        function() HookNameplatePool() end
    )
end

------------------------------------------------------------------------
-- Selectable object detection
-- GetGameCameraInteractableActionInfo() return #5 (additionalInteractInfo)
-- identifies the interactable type. This covers cell load doors, chairs,
-- containers, and any other named interactable object:
--   ADDITIONAL_INTERACT_INFO_NONE           — plain objects (doors, chairs, etc.)
--   ADDITIONAL_INTERACT_INFO_INSTANCE_TYPE  — instanced zone doors
--   ADDITIONAL_INTERACT_INFO_HOUSE_INSTANCE_DOOR — housing doors
--
-- Key format: "Zone:Name:X:Y" where X/Y use * 200 (~5m) precision.
-- Including the original name means approach-angle variation (±1-3m)
-- doesn't break the match. Position separates identically-named objects
-- that are more than ~5m apart.
------------------------------------------------------------------------

function CN.GetTargetDoorID()
    local action, interactableName, _, _, additionalInteractInfo =
        orig_GetGameCameraInteractableActionInfo()
    if not action or not interactableName or interactableName == "" then return nil end

    local isDoor = (additionalInteractInfo == ADDITIONAL_INTERACT_INFO_NONE
                 or additionalInteractInfo == ADDITIONAL_INTERACT_INFO_INSTANCE_TYPE
                 or additionalInteractInfo == ADDITIONAL_INTERACT_INFO_HOUSE_INSTANCE_DOOR)
    if not isDoor then return nil end

    local zone = GetUnitZone("player") or ""
    if zone == "" then return nil end

    local px, py = GetMapPlayerPosition("player")
    if not px or (px == 0 and py == 0) then return nil end

    return MakeDoorID(zone, interactableName, px, py), interactableName
end
