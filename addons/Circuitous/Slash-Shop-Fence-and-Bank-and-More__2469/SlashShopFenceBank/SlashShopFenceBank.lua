local version = 2
local LAM2 = LibAddonMenu2
local merchantID
local bankerID
local fenceID
local compID
local armoryID
local deconID
local SSFB = SSFB or {}

function SSFB:GetSettings()
	if not self or not self.character or not self.account then
		return false
	end

	if self.character.useCharacter == true then
		return self.character
	else
		return self.account
	end
end

-- make a menu!
local function settingsMenu()
	local panelData = {
		type = "panel",
		name = "Slash Shop, Fence, and Bank",
		displayName = "SSFB Settings",
		author = "Circuitous",
		version = version,
		slashCommand = "/ssfb",
		registerForRefresh = true,
		registerForDefaults = true,
	}
	
	local cntrlOptionsPanel = LAM2:RegisterAddonPanel("SSFB_Settings", panelData)	
	
	local bankerList = {"0 - None"}
	local bankerCount = 2
	if IsCollectibleUnlocked(267) then 
		bankerList[bankerCount] = "267 - Tythis Andromo" 
		bankerCount = bankerCount + 1
	end
	if IsCollectibleUnlocked(397) then 
		bankerList[bankerCount] = "397 - Cassus Andronicus"
		bankerCount = bankerCount + 1
	end
	if IsCollectibleUnlocked(6376) then 
		bankerList[bankerCount] = "6376 - Ezabi"
		bankerCount = bankerCount + 1
	end
	if IsCollectibleUnlocked(8994) then
		bankerList[bankerCount] = "8994 - Baron Jangleplume"
		bankerCount = bankerCount + 1
	end
	if IsCollectibleUnlocked(9743) then
		bankerList[bankerCount] = "9743 - Factotum Property Steward"
		bankerCount = bankerCount + 1
	end
	if IsCollectibleUnlocked(11097) then
		bankerList[bankerCount] = "11097 - Pyroclast"
		bankerCount = bankerCount + 1
	end
	if IsCollectibleUnlocked(12413) then
		bankerList[bankerCount] = "12413 - Eri"
		bankerCount = bankerCount + 1
	end
	if IsCollectibleUnlocked(13517) then
		bankerList[bankerCount] = "13517 - Celia Tyde"
		bankerCount = bankerCount + 1
	end
	
	local merchantList = {"0 - None"}
	local merchantCount = 2
	if IsCollectibleUnlocked(301) then 
		merchantList[merchantCount] = "301 - Nuzhimeh" 
		merchantCount = merchantCount + 1
	end
	if IsCollectibleUnlocked(396) then 
		merchantList[merchantCount] = "396 - Allaria Erwen"
		merchantCount = merchantCount + 1
	end
	if IsCollectibleUnlocked(6378) then 
		merchantList[merchantCount] = "6378 - Fezez"
		merchantCount = merchantCount + 1
	end
	if IsCollectibleUnlocked(8995) then
		merchantList[merchantCount] = "8995 - Peddler of Prizes"
		merchantCount = merchantCount + 1
	end
	if IsCollectibleUnlocked(9744) then
		merchantList[merchantCount] = "9744 - Factotum Commerce Delegate"
		merchantCount = merchantCount + 1
	end
	if IsCollectibleUnlocked(11059) then
		merchantList[merchantCount] = "11059 - Hoarfrost"
		merchantCount = merchantCount + 1
	end
	if IsCollectibleUnlocked(12414) then
		merchantList[merchantCount] = "12414 - Xyn"
		merchantCount = merchantCount + 1
	end
	if IsCollectibleUnlocked(13066) then
		merchantList[merchantCount] = "13066 - Terilorne"
		merchantCount = merchantCount + 1
	end
	
	local fenceList = {"0 - None"}
	local fenceCount = 2
	if IsCollectibleUnlocked(300) then
		fenceList[fenceCount] = "300 - Pirharri"
		fenceCount = fenceCount + 1
	end
	if IsCollectibleUnlocked(14204) then
		fenceList[fenceCount] = "14204 - Cambio Zammes"
		fenceCount = fenceCount + 1
	end
	
	local companionList = {"0 - None"}
	local companionCount = 2
	if IsCollectibleUnlocked(9353) then
		companionList[companionCount] = "9353 - Mirri Elendis"
		companionCount = companionCount + 1
	end
	if IsCollectibleUnlocked(9245) then
		companionList[companionCount] = "9245 - Bastian Hallix"
		companionCount = companionCount + 1
	end
	if IsCollectibleUnlocked(9911) then
		companionList[companionCount] = "9911 - Ember"
		companionCount = companionCount + 1
	end
	if IsCollectibleUnlocked(9912) then
		companionList[companionCount] = "9912 - Isobel Veloise"
		companionCount = companionCount + 1
	end
	if IsCollectibleUnlocked(11113) then
		companionList[companionCount] = "11113 - Sharp-as-Night"
		companionCount = companionCount + 1
	end
	if IsCollectibleUnlocked(11114) then
		companionList[companionCount] = "11114 - Azandar al-Cybiades"
		companionCount = companionCount + 1
	end
	if IsCollectibleUnlocked(12172) then
		companionList[companionCount] = "12172 - Tanlorin"
		companionCount = companionCount + 1
	end
	if IsCollectibleUnlocked(12173) then
		companionList[companionCount] = "12173 - Zerith-var"
		companionCount = companionCount + 1
	end
	
	local armoryList = {"0 - None"}
	local armoryCount = 2
	if IsCollectibleUnlocked(9745) then 
		armoryList[armoryCount] = "9745 - Ghrasharog" 
		armoryCount = armoryCount + 1
	end
	if IsCollectibleUnlocked(11876) then
		armoryList[armoryCount] = "11876 - Drinweth"
		armoryCount = armoryCount + 1
	end
	if IsCollectibleUnlocked(10618) then
		armoryList[armoryCount] = "10618 - Zuqoth"
		armoryCount = armoryCount + 1
	end
	if IsCollectibleUnlocked(13518) then
		armorList[armoryCount] = "13518 - Voko"
		armoryCount = armoryCount + 1
	end
	
	local deconList = {"0 - None"}
	local deconCount = 2
	if IsCollectibleUnlocked(10184) then 
		deconList[deconCount] = "10184 - Giladil" 
		deconCount = deconCount + 1
	end
	if IsCollectibleUnlocked(10617) then
		deconList[deconCount] = "10617 - Aderene"
		deconCount = deconCount + 1
	end
	if IsCollectibleUnlocked(11877) then
		deconList[deconCount] = "11877 - Tzozabrar"
		deconCount = deconCount + 1
	end
	if IsCollectibleUnlocked(13063) then
		deconList[deconCount] = "13063 - Siluruz"
		deconCount = deconCount + 1
	end
	if IsCollectibleUnlocked(14018) then
		deconList[deconCount] = "14018 - Pontius Remus"
		deconCount = deconCount + 1
	end
	
	local optionsData = {
		[1] = {
			type = "header",
			name = "Settings",
		},

		[2] = {
			type = "description",
			text = "Toggle per-character settings.",
		},

		[3] = {
			type = "checkbox",
			name = "Use Settings for this character only",
			getFunc = function() return SSFB.character.useCharacter end,
			setFunc = function(value) SSFB.character.useCharacter = value end,
			requiresReload = true,
		},

		[4] = {
			type = "header",
			name = "Set Assistants",
		},
		
		[5] = {
			type = "description",
			text = "Set your assistants from those you have unlocked.",
		},
		
		[6] = {
			type = "dropdown",
			name = "Banker",
			tooltip = "Hopefully a list of valid Bankers...",
			choices = bankerList,
			getFunc = function() return SSFB:GetSettings().banker end,
			setFunc = 
				function(val) 
					SSFB:GetSettings().banker = val
					bankerID = string.match(val, '%d+')
				end,
		},
		
		[7] = {
			type = "dropdown",
			name = "Fence",
			tooltip = "Hopefully a list of valid Fences...",
			choices = fenceList,
			getFunc = function() return SSFB:GetSettings().fence end,
			setFunc = 
				function(val)
					SSFB:GetSettings().fence = val
					fenceID = string.match(val, '%d+')
				end,
		},
		
		[8] = {
			type = "dropdown",
			name = "Merchant",
			tooltip = "Hopefully a list of valid Merchants...",
			choices = merchantList,
			getFunc = function() return SSFB:GetSettings().merchant end,
			setFunc = 
				function(val)
					SSFB:GetSettings().merchant = val
					merchantID = string.match(val, '%d+')
				end,
		},
		
		[9] = {
			type = "dropdown",
			name = "Companion",
			tooltip = "Hopefully a list of valid Companions...",
			choices = companionList,
			getFunc = function() return SSFB:GetSettings().companion end,
			setFunc = 
				function(val)
					SSFB:GetSettings().companion = val
					compID = string.match(val, '%d+')
				end,
		},
		
		[10] = {
			type = "dropdown",
			name = "Armory Assistant",
			tooltip = "Hopefully a list of valid Armory assistants...",
			choices = armoryList,
			getFunc = function() return SSFB:GetSettings().armory end,
			setFunc =
				function(val)
					SSFB:GetSettings().armory = val
					armoryID = string.match(val, '%d+')
				end,
		},
		
		[11] = {
			type = "dropdown",
			name = "Decon Assistant",
			tooltip = "Hopefully a list of valid Decon assistants...",
			choices = deconList,
			getFunc = function() return SSFB:GetSettings().decon end,
			setFunc =
				function(val)
					SSFB:GetSettings().decon = val
					deconID = string.match(val, '%d+')
				end,
		}
	}
	
	LAM2:RegisterOptionControls("SSFB_Settings", optionsData)
end

local function handleSettings()
	if SSFB.character.useCharacter then
		if SSFB.character.banker then bankerID = string.match(SSFB.character.banker, '%d+') end
		if SSFB.character.merchant then merchantID = string.match(SSFB.character.merchant, '%d+') end
		if SSFB.character.fence then fenceID = string.match(SSFB.character.fence, '%d+') end
		if SSFB.character.companion then compID = string.match(SSFB.character.companion, '%d+') end
		if SSFB.character.armory then armoryID = string.match(SSFB.character.armory, '%d+') end
		if SSFB.character.decon then deconID = string.match(SSFB.character.decon, '%d+') end
	else
		if SSFB.account.banker then bankerID = string.match(SSFB.account.banker, '%d+') end
		if SSFB.account.merchant then merchantID = string.match(SSFB.account.merchant, '%d+') end
		if SSFB.account.fence then fenceID = string.match(SSFB.account.fence, '%d+') end
		if SSFB.account.companion then compID = string.match(SSFB.account.companion, '%d+') end
		if SSFB.account.armory then armoryID = string.match(SSFB.account.armory, '%d+') end
		if SSFB.account.decon then deconID = string.match(SSFB.account.decon, '%d+') end
	end
end

local function pvpCheck()
	-- verify that the player isn't in a pvp setting, and is allowed to summon
	-- their assistants. print an appropriate error if so.
	if IsPlayerInAvAWorld() == true then
		-- player is in some sort of ava world. figure out which and print an error.
		if IsInCyrodiil() == true then
			-- is somewhere in cyrodiil's overworld
			d("Can't call assistants in Cyrodiil.")
		elseif IsInImperialCity() == true then
			-- is somewhere in the imperial city, but where?
			if GetCurrentMapIndex() == nil then
				-- GetCurrentMapIndex() returns nil when you're in the ic sewers
				d("Can't call assistants in the Imperial City sewers.")
			else
				-- so if it's not nil, we can assume they're up top
				d("Can't call assistants in the Imperial City.")
			end
		else
			-- IsInCyrodiil() weirdly only accounts for overland, not delves
			-- but we've accounted for every other possibility elsewhere, so...
			d("Can't call assistants in Cyrodiil - not even in delves.")
		end
		-- error printed, now tell the other function
		return true
	elseif IsActiveWorldBattleground() == true then
		-- player is currently in a battleground match, no assistants there
		d("Can't call assistants in a Battleground.")
		-- tattle on them
		return true
	else
		-- all clear, user is not in any pvp zone and can summon assistants
		return false
	end
end

local function announce(id)
	-- get the name we'll use in the message
	local assistantName = GetCollectibleName(id)
	-- just check if the requested assistant is already out, so the message
	-- is appropriate.
	if IsCollectibleActive(id) == true then
		d(zo_strformat("Dismissing <<1>>...", assistantName))
	else
		d(zo_strformat("Summoning <<1>>...", assistantName))
	end
end

local function callAssistant(id)
	-- verify that the requested assistant is unlocked first
	if IsCollectibleUnlocked(id) == true then
		-- all good, but are we allowed to call assistants here?
		if pvpCheck() == false then
			-- we're safe, so decide whether they're being summoned or dismissed
			announce(id)
			-- and, finally, use the darn thing
			UseCollectible(id)
		end
	else
		-- the assistant id isn't valid, which shouldn't happen if the settings are
		-- done properly.
		d("Requested Assistant is not unlocked - something went wrong with settings!")
	end
end

-- the pieces are in place, now we have the individual slash functions
-- would it have made more sense to have a single function...? i wonder.
function SSFB_toggleShop()
	if merchantID == nil or merchantID == "0" then
		d("No Merchant assigned. Assign one via Settings > Addons > SlashShopFenceBank.")
		return
	end
	callAssistant(merchantID)
end

function SSFB_toggleBank()
	if bankerID == nil or bankerID == "0" then
		d("No Banker assigned. Assign one via Settings > Addons > SlashShopFenceBank.")
		return
	end
	callAssistant(bankerID)
end

function SSFB_toggleFence()
	if fenceID == nil or fenceID == "0" then
		d("No Fence assigned. Assign one via Settings > Addons > SlashShopFenceBank.")
		return
	end
	callAssistant(fenceID)
end

function SSFB_toggleCompanion()
	if compID == nil or compID == 0 then
		d("No Companion assigned. Assign one via Settings > Addons > SlashShopFenceBank.")
		return
	end
	callAssistant(compID)
end

function SSFB_toggleArmory()
	if compID == nil or compID == 0 then
		d("No Armory assistant assigned. Assign one via Settings > Addons > SlashShopFenceBank.")
		return
	end
	callAssistant(armoryID)
end

function SSFB_toggleDecon()
	if deconID == nil or deconID == 0 then
		d("No Decon assistant assigned. Assign one via Settings > Addons > SlashShopFenceBank.")
		return
	end
	callAssistant(deconID)
end

-- onload stuff
local function onLoad(eventCode, addOnName)
	if addOnName ~= "SlashShopFenceBank" then return end
	EVENT_MANAGER:UnregisterForEvent("SlashShopFenceBank", EVENT_ADD_ON_LOADED)

	-- load some dang variables
	SSFB.account = ZO_SavedVars:NewAccountWide("SSFB_Data", version)
	SSFB.character = ZO_SavedVars:NewCharacterIdSettings("SSFB_Data", version, nil, SSFB.account)
	
	-- make the menu or something
	settingsMenu()
	handleSettings()
	
	-- strings for keybinding
	ZO_CreateStringId("SI_BINDING_NAME_SSFB_BANK", "Toggle Assigned Banker")
	ZO_CreateStringId("SI_BINDING_NAME_SSFB_SHOP", "Toggle Assigned Merchant")
	ZO_CreateStringId("SI_BINDING_NAME_SSFB_FENCE", "Toggle Assigned Fence")
	ZO_CreateStringId("SI_BINDING_NAME_SSFB_COMPANION", "Toggle Assigned Companion")
	ZO_CreateStringId("SI_BINDING_NAME_SSFB_ARMORY", "Toggle Assigned Armory Assistant")
	ZO_CreateStringId("SI_BINDING_NAME_SSFB_DECON", "Toggle Assigned Decon Assistant")
	
	-- slash commands
	SLASH_COMMANDS["/fence"] = SSFB_toggleFence
	SLASH_COMMANDS["/bank"] = SSFB_toggleBank
	SLASH_COMMANDS["/shop"] = SSFB_toggleShop
	SLASH_COMMANDS["/comp"] = SSFB_toggleCompanion
	SLASH_COMMANDS["/armory"] = SSFB_toggleArmory
	SLASH_COMMANDS["/decon"] = SSFB_toggleDecon
end

EVENT_MANAGER:RegisterForEvent("SlashShopFenceBank", EVENT_ADD_ON_LOADED, onLoad)
