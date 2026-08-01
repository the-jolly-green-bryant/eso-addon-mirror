local BuzzOff = {
	Name = "BuzzOff",
	Author = "Asaril",
	Version = "1.01"
}

function Set(list)
    local set = {}
    for _, l in ipairs(list) do set[l] = true end
    return set
end

local BuzzingThings = Set {
	"Torchbug",
	"Butterfly",
	"Fackelkäfer",
	"Schmetterling",
	"Flammouche",
	"Papillon",
	"Светлячок",
	"бабочка",
	"トーチバグ",
	"バタフライ",
	"蝶"
}

local function OnAddOnLoaded(event, addonName)
    if addonName == BuzzOff.Name then BuzzOff:Initialize() end
end

-- Modified reticle hook from No, Thank You!
local function HookReticleTake()
    local function DisableReticleTake_Hook(interactionPossible)
        if interactionPossible and IsCollectibleActive(9353) then
            local _, text, empty, _, addinfo, _, _, crime =
                GetGameCameraInteractableActionInfo()
            if BuzzingThings[text] then
                return true
            end
        end
        return false
    end
    ZO_PreHook(RETICLE, "TryHandlingInteraction", DisableReticleTake_Hook)
end

function BuzzOff:Initialize()
    EVENT_MANAGER:UnregisterForEvent(BuzzOff.Name, EVENT_ADD_ON_LOADED)
    HookReticleTake()
end

-- Stops interaction
local interactionManager = FISHING_MANAGER or INTERACTIVE_WHEEL_MANAGER
local orgInteract = interactionManager.StartInteraction
interactionManager.StartInteraction = function(...)
    local _, text, _, _, _, _, _, crime = GetGameCameraInteractableActionInfo()
    if IsCollectibleActive(9353) and BuzzingThings[text] then
        CHAT_SYSTEM:AddMessage("|caf0000Cannot take " .. text .. " while Mirri is near.|r")

        return true
    else
        return orgInteract(...)
    end
end

EVENT_MANAGER:RegisterForEvent(BuzzOff.Name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)
