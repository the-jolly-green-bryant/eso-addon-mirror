GearTracker = {}
local gear = GearTracker
local libScroll = LibScroll

-- Written by M0R_Gaming

gear.name = "GearTracker"
gear.list = nil



-- Setting up Keybinds and Commands --

--SLASH_COMMANDS["/vote"] = SimpleVote.sendVote


local order = {
	[EQUIP_TYPE_HEAD] = 1,
	[EQUIP_TYPE_SHOULDERS] = 2,
	[EQUIP_TYPE_CHEST] = 3,
	[EQUIP_TYPE_HAND] = 4,
	[EQUIP_TYPE_WAIST] = 5,
	[EQUIP_TYPE_LEGS] = 6,
	[EQUIP_TYPE_FEET] = 7,
	[EQUIP_TYPE_NECK] = 8,
	[EQUIP_TYPE_RING] = 9,
	[EQUIP_TYPE_MAIN_HAND] = -1,
	[EQUIP_TYPE_OFF_HAND] = -1,
	[EQUIP_TYPE_ONE_HAND] = -1,
	[EQUIP_TYPE_TWO_HAND] = -1
}

local orderWeapons = {
	[WEAPONTYPE_DAGGER] = 10,
	[WEAPONTYPE_AXE] = 11,
	[WEAPONTYPE_HAMMER] = 12,
	[WEAPONTYPE_SWORD] = 13,
	[WEAPONTYPE_TWO_HANDED_AXE] = 14,
	[WEAPONTYPE_TWO_HANDED_HAMMER] = 15,
	[WEAPONTYPE_TWO_HANDED_SWORD] = 16,
	[WEAPONTYPE_BOW] = 17,
	[WEAPONTYPE_HEALING_STAFF] = 18,
	[WEAPONTYPE_FIRE_STAFF] = 19,
	[WEAPONTYPE_FROST_STAFF] = 20,
	[WEAPONTYPE_LIGHTNING_STAFF] = 21,
	[WEAPONTYPE_SHIELD] = 22
}

gear.bag = {}
function gear.getItems(bag)
	for slotId=0,GetBagSize(bag) do
		local _, _, _, _, _, equipType, _, quality = GetItemInfo(bag,slotId)
		if equipType ~= EQUIP_TYPE_INVALID then
			local hasSet, _, _, _, _, setId = GetItemLinkSetInfo(GetItemLink(bag, slotId))
			if hasSet then
				orderNumber = order[equipType]
				if orderNumber == -1 then
					orderNumber = orderWeapons[GetItemWeaponType(bag,slotId)]
				end
				if not gear.bag[setId] then
					gear.bag[setId] = {[orderNumber] = quality}
				else
					if gear.bag[setId][orderNumber] then
						if quality > gear.bag[setId][orderNumber] then
							gear.bag[setId][orderNumber] = quality
						end
					else
						gear.bag[setId][orderNumber] = quality
					end
				end
			end
		end
	end
end



--[[

Done via JS:

function search(items) {
	let outAll = ''
	items.split(',').forEach((item) => {
		output = ''
		test.forEach((x) => {
			if (x.setName.toLowerCase().includes(item.toLowerCase())) {
				output += '{name="'+x.setName+'", id='+x.gameId+'},\n'
			}
		})
		if (output == '') {
			output = "No set found for "+item
		}
		outAll += output
	})
	console.log(outAll)
}

httpGet('https://esolog.uesp.net/exportJson.php?table=setSummary',(x) => {
	test = JSON.parse(x)
	console.log(done)
})


test = JSON.parse(httpGet('https://esolog.uesp.net/exportJson.php?table=setSummary')).setSummary


search("Subject")

--]]


local sets = {
	["PugESO Healers"] = {
		{name="Spell Power Cure", id=185},
		{name="The Worm's Raiment", id=124},
		{name="Roaring Opportunist", id=496},
		{name="Perfected Roaring Opportunist", id=497},
		{name="Jorvuld's Guidance", id=346},
		{name="Vestment of Olorime", id=391},
		{name="Perfected Vestment of Olorime", id=395},
		{name="Way of Martial Knowledge", id=147},
		{name="Master Architect", id=332},
		{name="Stone-Talker's Oath", id=588},
		{name="Perfected Stone-Talker's Oath", id=592},
		{name="Saxhleel Champion", id=585},
		{name="Perfected Saxhleel Champion", id=589},
		{name="Hollowfang Thirst", id=452},
		{name="Symphony of Blades (Monster Helm)", id=436, pieces=2},
		{name="The Troll King (Monster Helm)", id=278, pieces=2},
		{name="Encratis's Behemoth (Monster Helm)", id=577, pieces=2},
		{name="Sentinel of Rkugamz (Monster Helm)", id=268, pieces=2},
	},
	["PugESO Tanks"] = {
		{name="Claw of Yolnahkriin", id=446},
		{name="Perfected Claw of Yolnahkriin", id=451},
		{name="Aegis of Galenwe", id=388},
		{name="Perfected Aegis of Galenwe", id=392},
		{name="Powerful Assault", id=180},
		{name="Dragon's Defilement", id=457},
		{name="The Worm's Raiment", id=124},
		{name="Roar of Alkosh", id=232},
		{name="Frozen Watcher", id=433},
		{name="War Machine", id=331},
		{name="Saxhleel Champion", id=585},
		{name="Perfected Saxhleel Champion", id=589},
		{name="Elemental Catalyst", id=516},
		{name="Encratis's Behemoth (Monster Helm)", id=577, pieces=2},
		{name="Lord Warden (Monster Helm)", id=164, pieces=2},
		{name="Thurvokun (Monster Helm)", id=349, pieces=2},
		{name="Bloodspawn (Monster Helm)", id=163, pieces=2},
		{name="Lady Thorn (Monster Helm)", id=535, pieces=2},
	}
}



local function SetupDataRow(rowControl, data, scrollList)

    local amount = 0
    local minAmount = data.pieces or 5
    for i=1,22 do
    	local button = rowControl:GetNamedChild("Box"..i)
    	if not button then
	    	button = WINDOW_MANAGER:CreateControl("$(parent)Box"..i, rowControl, CT_TEXTURE)
	    end
		button:SetDimensions(24, 24)
		button:SetAnchor(LEFT, rowControl, LEFT, 423+(i-1)*30, 0) -- original 140+(i-1)*30
		if gear.bag[data.id] and gear.bag[data.id][i] then

			if (i > 13 and i < 22) or (i == 9) then
				amount = amount + 2
			else
				amount = amount + 1
			end

			button:SetTexture("/esoui/art/cadwell/check.dds")

			if gear.bag[data.id][i] == 5 then
				button:SetColor(0.8, 0.66, 0.1) -- ccaa1a
			elseif gear.bag[data.id][i] == 4 then
				button:SetColor(0.63, 0.18, 0.97) -- a02ef7
			elseif gear.bag[data.id][i] == 3 then
				button:SetColor(0.23, 0.57, 1) -- 3a92ff
			elseif gear.bag[data.id][i] == 2 then
				button:SetColor(0.18, 0.77, 0.05)
			else
				button:SetColor(1, 1, 1)
			end
		else
			button:SetTexture("/esoui/art/buttons/swatchframe_down.dds")  -- little square box
			button:SetColor(1, 1, 1)
		end
		button:SetMouseEnabled(false)
	end
	rowControl:GetNamedChild("Name"):SetText(data.name)
	if amount >= minAmount then
		rowControl:GetNamedChild("Name"):SetColor(0,1,0)
	end
end


local function CreateScrollList()
    local mainWindow = GearList
    local scrollData = {
        name = "GearScrollList",
        parent = mainWindow,
        rowTemplate = "WishListRow",
        setupCallback = SetupDataRow,
        width = 1133,
        height = 700,
    }
    
    local scrollList = libScroll:CreateScrollList(scrollData)
    scrollList:SetAnchor(TOPLEFT, mainWindow, TOPLEFT, 25, 100)
    
    return scrollList
end


function gear.showWindow()
	if not gear.list then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "|cff0000Please select a valid list!|r")
		return
	end
	gear.getItems(BAG_BACKPACK)
	gear.getItems(BAG_BANK)
	gear.getItems(BAG_SUBSCRIBER_BANK)
	gear.getItems(BAG_WORN)
	gear.scrollList:Clear()
	gear.scrollList:Update(sets[gear.list])
	GearList:SetHidden(false)
end


SLASH_COMMANDS['/showgearlist'] = gear.showWindow









function gear.createSettings()
	local panelName = "GearTrackerSettingsPanel"
	local panelData = {
		type = "panel",
		name = "|cFFD700Gear Tracker|r",
		author = "|c0DC1CF@M0R_Gaming|r",
		slashCommand = "/gear"
	}

	local optionsTable = {
	    {
			type = "dropdown",
			name = "Gear List",
			tooltip = "Which gear list should be displayed.",
			choices = {"PugESO Healers", "PugESO Tanks"},
			getFunc = function() return nil end,
			setFunc = function(value) gear.list = value end
		},
		{
			type = "button",
			name = "Show Window",
			tooltip = "Click here to show the window.",
			width = "half",
			func = gear.showWindow,
		},
		{
			type = "button",
			name = "Take Screenshot",
			tooltip = "Click here to take a screenshot (Saved to the ESO Screenshots folder).",
			width = "half",
			func = gear.takeScreenshot,
		}
	}


	local panel = LibAddonMenu2:RegisterAddonPanel(panelName, panelData)
	LibAddonMenu2:RegisterOptionControls(panelName, optionsTable)

end






function gear.takeScreenshot()
	if not gear.list then
		ZO_Alert(UI_ALERT_CATEGORY_ERROR, SOUNDS.NEGATIVE_CLICK, "|cff0000Please select a valid list!|r")
		return
	end
	gear.getItems(BAG_BACKPACK)
	gear.getItems(BAG_BANK)
	gear.getItems(BAG_SUBSCRIBER_BANK)
	gear.getItems(BAG_WORN)
	gear.scrollList:Update(sets[gear.list])
	
	GearListButtonScreenshot:SetHidden(true)
	GearListButtonCloseAddon:SetHidden(true)


	--SCENE_MANAGER:HideScene(SCENE_MANAGER:GetScene("hud"))
	--SCENE_MANAGER:HideScene(SCENE_MANAGER:GetScene("hudui"))
	local currentScene = SCENE_MANAGER:GetCurrentSceneName()
	--SCENE_MANAGER:SwapCurrentScene("GearListScene")
	SCENE_MANAGER:Push("GearListScene")
	SetFrameLocalPlayerInGameCamera(true)
	SetFrameLocalPlayerTarget(0.15, 0.65)


	local chatShown = CHAT_SYSTEM:IsHidden()
	local minbarShown = CHAT_SYSTEM.isMinimized
	if not chatShown then
		CHAT_SYSTEM:Minimize()
		CHAT_SYSTEM:HideMinBar()
	end
	if minbarShown then CHAT_SYSTEM:HideMinBar() end
	--HUD_SCENE:SetState(SCENE_GROUP_HIDDEN)
	zo_callLater(function()
		--SetGuiHidden('ingame', true)
		TakeScreenshot()
		--GearList:Show()
		zo_callLater(function()

			--SCENE_MANAGER:SwapCurrentScene(currentScene)
			SetFrameLocalPlayerTarget(0.5, 0.65)
			SetFrameLocalPlayerInGameCamera(false)
			SCENE_MANAGER:Push(currentScene)
			if not chatShown then CHAT_SYSTEM:Maximize() end
			if minbarShown then CHAT_SYSTEM:ShowMinBar() end
			GearListButtonScreenshot:SetHidden(false)
			GearListButtonCloseAddon:SetHidden(false)
			--SCENE_MANAGER:ShowScene(SCENE_MANAGER:GetScene("hud"))
			--SCENE_MANAGER:ShowScene(SCENE_MANAGER:GetScene("hudui"))
		end,1000)

	end, 1000)
		
end























-- The following was adapted from https://wiki.esoui.com/Circonians_Stamina_Bar_Tutorial#lua_Structure

-------------------------------------------------------------------------------------------------
--  OnAddOnLoaded  --
-------------------------------------------------------------------------------------------------
function gear.OnAddOnLoaded(event, addonName)
	if addonName ~= gear.name then return end

	gear:Initialize()
end
 
-------------------------------------------------------------------------------------------------
--  Initialize Function --
-------------------------------------------------------------------------------------------------
function gear:Initialize()
	EVENT_MANAGER:UnregisterForEvent(gear.name, EVENT_ADD_ON_LOADED)
	gear.scrollList = CreateScrollList()
	gear.createSettings()
	local fragment = ZO_SimpleSceneFragment:New(GearList)
	gear.scene = ZO_Scene:New("GearListScene", SCENE_MANAGER)
	gear.scene:AddFragment(fragment)

end
 
-------------------------------------------------------------------------------------------------
--  Register Events --
-------------------------------------------------------------------------------------------------
EVENT_MANAGER:RegisterForEvent(gear.name, EVENT_ADD_ON_LOADED, gear.OnAddOnLoaded)