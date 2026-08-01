BSCASynergy = BSCASynergy or {}
local BSCAS = BSCASynergy
local LIB = LibBSCWizardBridge

if not LIB then return end

local CLIENT_ID = "BSCAS"
local PROVIDER_KEY = "WizardsWardrobe"

local function getStore()
    BSCAS.SV_acc.SETUP_LINKS = BSCAS.SV_acc.SETUP_LINKS or {}
    return BSCAS.SV_acc.SETUP_LINKS
end

local function normalizePayload(payload)
    if type(payload) ~= "table" then return nil end

    local out = {}
    local blockPreset = payload.blockPreset or "Default"
    if BSCAS:PresetExist(blockPreset) then
        out.blockPreset = blockPreset
    end

	local prioPreset = payload.prioPreset or "Default"
	if BSCAS:PrioPresetExists(prioPreset) then
		out.prioPreset = prioPreset
	end
	
	local printPreset = payload.PrintPreset
    if printPreset == nil then
        printPreset = true
    end
    out.PrintPreset = printPreset and true or false

    if next(out) == nil then
        return nil
    end
    return out
end

local function applyPayload(payload)
    if type(payload) ~= "table" then return end
	
    local blockPreset = payload.blockPreset
    if blockPreset and BSCAS:PresetExist(blockPreset) and BSCAS.SV.SELECTED_PRESET ~= blockPreset then
        BSCAS.LoadSetting(blockPreset)
		if payload.PrintPreset then
            CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFF BSCs-AS Loading Block <<1>>|r", BSCAS.SV.SELECTED_PRESET))
        end
        BSCAS.PlaySound(1, SOUNDS.CHAMPION_RESPEC_ACCEPT)
    end

	local prioPreset = payload.prioPreset
	if prioPreset and BSCAS:PrioPresetExists(prioPreset) and BSCAS.SV.SELECTED_PRIO_PRESET ~= prioPreset then
		BSCAS:ApplyPrioPreset(prioPreset)
		if payload.PrintPreset then
			CHAT_ROUTER:AddSystemMessage(zo_strformat("|cFFFFFF BSCs-AS Loading Priority <<1>>|r", BSCAS.SV.SELECTED_PRIO_PRESET))
		end
		BSCAS.PlaySound(1, SOUNDS.OUTFIT_GAMEPAD_UNDO_CHANGES)
	end
end

local function getEditorFields()
    local fields = {
        {
            key = "blockPreset",
            label = "Blocking Preset",
            type = "dropdown",
            default = "Default",
            choices = function()
                return BSCAS:GetListNames()
            end,
        },
		{
            key = "prioPreset",
            label = "Priority Preset",
            type = "dropdown",
            default = "Default",
            choices = function()
                return BSCAS:GetListPrioNames()
            end,
		},
		{
			key = "PrintPreset",
			label = "Print Switch Info",
			type = "checkbox",    
			default = false,
			tooltip = "Print Loaded Preset Info into chat.",
		},
    }

    return fields
end

function BSCAS:registerClient()
    LIB:RegisterClient({
        id = CLIENT_ID,
        provider = PROVIDER_KEY,
        displayName = "BSC Advanced Synergy",
        getStore = getStore,
        getEditorFields = getEditorFields,
        normalizePayload = normalizePayload,
        apply = applyPayload,
    })
end