SetRangeTracker = SetRangeTracker or {}
local ShowBlast = SetRangeTracker

SetRangeTracker.name = "SetRangeTracker"
SetRangeTracker.version = "1"
local EM = EVENT_MANAGER
local LAM2 = LibAddonMenu2

local SetDatas = {
    ["wm"] = {
        id = "|H1:item:124129:364:50:26588:370:50:0:0:0:0:0:0:0:0:1:60:0:1:0:10000:0|h|h",
        icon = "esoui/art/icons/ability_buff_major_slayer.dds",
        distance = 28,
        people = 6,
    },
    ["ma"] = {
        id = "|H1:item:124317:364:50:0:0:0:0:0:0:0:0:0:0:0:1:60:0:1:0:10000:0|h|h",
        icon = "esoui/art/icons/ability_buff_major_slayer.dds",
        distance = 28,
        people = 6,
    },
    ["sax"] = {
        id = "|H1:item:175048:364:50:45883:370:50:33:0:0:0:0:0:0:0:2049:0:0:1:0:0:0|h|h",
        icon = "esoui/art/icons/ability_buff_major_fortitude.dds",
        distance = 28,
        people = 12,
    },
    ["pillager"] = {
        id = "|H1:item:187047:364:50:0:0:0:0:0:0:0:0:0:0:0:1:130:0:1:0:10000:0|h|h",
        icon = "esoui/art/icons/ability_buff_major_mending.dds",
        distance = 12,
        people = 12,
    },
}

SetRangeTracker.Default = {
	OffsetX = 800,
	OffsetY = 300,
	AlwaysShowAlert = false,
}
function SetRangeTracker.CreateSettingsWindow()
	local panelData = {
		type = "panel",
		name = "SetRangeTracker",
		displayName = "Set|cdc143cRange|rTracker",
		author = "Floliroy",
		version = SetRangeTracker.version,
		slashCommand = "/setrange",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("SetRangeTracker_Settings", panelData)
	
	local optionsData = {
		{	type = "description",
			text = " ",
		},
		{	type = "checkbox",
			name = "Unlock",
			tooltip = "Use it to set the position of the SetRangeTracker icon.",
			default = false,
			getFunc = function() return sV.AlwaysShowAlert end,
			setFunc = function(newValue) 
				sV.AlwaysShowAlert = newValue
				SetRangeTrackerUI:SetHidden(not newValue)  
			end,
		},
	}

	LAM2:RegisterOptionControls("SetRangeTracker_Settings", optionsData)
end

local currentSetDatas = {}
function SetRangeTracker.OnGearUpdate()   
    local set1 = nil
    local set2 = nil
    for set, data in pairs(SetDatas) do
	    local _, _, _, normalPieces, _, _, perfectPieces = GetItemLinkSetInfo(data.id, true)
        if normalPieces + perfectPieces >= 3 then 
            if set1 == nil then
                set1 = set
            elseif set2 == nil then  
                set2 = set
            end
        end
    end
    
    if set1 ~= nil then
        if set2 ~= nil and SetDatas[set2].distance < SetDatas[set1].distance then
            currentSetDatas = SetDatas[set2]
        else
            currentSetDatas = SetDatas[set1]
        end

		SetRangeTrackerUI_Icon:SetTexture(currentSetDatas.icon)
        SetRangeTrackerUI:SetHidden(false)
        EM:UnregisterForUpdate(SetRangeTracker.name .. "UpdateIcon")
        EM:RegisterForUpdate(SetRangeTracker.name .. "UpdateIcon", 333, SetRangeTracker.UpdateSetIcon)
		EM:RegisterForEvent(SetRangeTracker.name .. "Reticle", EVENT_RETICLE_HIDDEN_UPDATE, SetRangeTracker.ReticleChange)
    else
        currentSetDatas = {}

		SetRangeTrackerUI:SetHidden(true)
        EM:UnregisterForUpdate(SetRangeTracker.name .. "UpdateIcon")
		EM:UnregisterForEvent(SetRangeTracker.name .. "Reticle", EVENT_RETICLE_HIDDEN_UPDATE)
    end
end

function SetRangeTracker.UpdateSetIcon()
    if not currentSetDatas or not currentSetDatas.id then return end
    local cpt = 0 
    local _, x1, y1, z1 = GetUnitWorldPosition("player")
    for i = 1, GetGroupSize() do
        local distance = currentSetDatas.distance + 1

        -- check group range first to avoid unneeded calculations
        if IsUnitInGroupSupportRange("group" .. i) then
            local _, x2, y2, z2 = GetUnitWorldPosition("group" .. i)
            distance = zo_sqrt((x1 - x2) ^ 2 + (y1 - y2) ^ 2 + (z1 - z2) ^ 2) / 100
        end
        if distance < currentSetDatas.distance then
            cpt = cpt + 1
        end
    end

    
	SetRangeTrackerUI_Number:SetText(tostring(cpt))
	if cpt >= currentSetDatas.people then
		SetRangeTrackerUI_Border:SetColor(0, 1, 0)
	else
		SetRangeTrackerUI_Border:SetColor(1, 0, 0)
	end

end

-- Get saved variables, reposition ui and register events
function SetRangeTracker.OnAddonLoaded(eventCode, addonName)
    if addonName == SetRangeTracker.name then
        EM:UnregisterForEvent(SetRangeTracker.name, eventCode)
        if AddonCategory then
            AddonCategory.AssignAddonToCategory(addonName, AddonCategory.baseCategories.Trackers)
        end

        --SavedVariables
        sV = ZO_SavedVars:NewAccountWide("SetRangeTrackerSV", 1, nil, SetRangeTracker.Default)
        SetRangeTracker.CreateSettingsWindow()

        --UI
        SetRangeTrackerUI:ClearAnchors()
        SetRangeTrackerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, sV.OffsetX, sV.OffsetY)
        SetRangeTrackerUI_Border:SetColor(1, 0, 0)
        SetRangeTrackerUI_Number:SetText("0")
		SetRangeTrackerUI_Icon:SetTexture("esoui/art/icons/ability_buff_major_slayer.dds")
		SetRangeTrackerUI:SetHidden(true)

        --Events
        EM:RegisterForEvent(SetRangeTracker.name .. "GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, SetRangeTracker.OnGearUpdate)
        EM:AddFilterForEvent(SetRangeTracker.name .. "GearUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, REGISTER_FILTER_BAG_ID, BAG_WORN, REGISTER_FILTER_INVENTORY_UPDATE_REASON, INVENTORY_UPDATE_REASON_DEFAULT)
        SetRangeTracker.OnGearUpdate()

    end
end

function SetRangeTracker.ReticleChange()
    if sV.AlwaysShowAlert then
        SetRangeTrackerUI:SetHidden(false)
        return 
    end
	SetRangeTrackerUI:SetHidden(IsReticleHidden())
	if not IsReticleHidden() then 
        SetRangeTrackerUI:SetHidden(not currentSetDatas or not currentSetDatas.id) 
    end
end

function SetRangeTracker.SaveLoc()
	sV.OffsetX = SetRangeTrackerUI:GetLeft()
	sV.OffsetY = SetRangeTrackerUI:GetTop()
end	

EM:RegisterForEvent(SetRangeTracker.name, EVENT_ADD_ON_LOADED, SetRangeTracker.OnAddonLoaded)