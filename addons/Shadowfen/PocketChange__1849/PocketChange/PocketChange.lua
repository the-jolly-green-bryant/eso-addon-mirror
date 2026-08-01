local SF = LibSFUtils

PocketChange = {
	name = "PocketChange",
	author = "Shadowfen",
	version = "1.36",
	savedVarVersion = "1",
}
local PC=PocketChange
PC.displayName = SF.ColorText(PC.name,SF.colors.gold.hex)
PC.author = SF.ColorText(PC.author,SF.colors.purple.hex)
--PC.displayName = SF.colors.gold:Colorize(PC.name)
--PC.author = SF.colors.purple:Colorize(PC.author)

local LOCKPICKS = 101
local REPAIRS = 102
local GEMS=103
local EMPTY_GEMS=104
local MAIN_WEAPON=105
local BKUP_WEAPON=106

-- Define translation array
local ModeArray = {
	["Mode_No"] = GetString(PC_NOPT_NO),
	["Mode_Chat"] = GetString(PC_NOPT_CHAT),
	["Mode_SoundChat"] = GetString(PC_NOPT_BOTH),
	[GetString(PC_NOPT_NO)] = "Mode_No",
	[GetString(PC_NOPT_CHAT)] = "Mode_Chat",
	[GetString(PC_NOPT_BOTH)] = "Mode_SoundChat",
}

local defaults = {
	minimum = {
		[CURT_MONEY] = 2000, 	        -- GD
		[CURT_ALLIANCE_POINTS] = 0, 	-- AP
		[CURT_TELVAR_STONES] = 0, 		-- TV
		[CURT_WRIT_VOUCHERS] = 0, 		-- WV
		[LOCKPICKS] = 100,
		[GEMS]=100,
		[EMPTY_GEMS]=0,
		[REPAIRS]=40,
		[MAIN_WEAPON]=0,
		[BKUP_WEAPON]=0,
	},
	notify = {
		[LOCKPICKS] = "Mode_No",
		[REPAIRS] = "Mode_No",
		[GEMS] = "Mode_No",
		[EMPTY_GEMS] = "Mode_No",
		[MAIN_WEAPON] = "Mode_No",
		[BKUP_WEAPON] = "Mode_No",
    },
	disables = {
        [CURT_MONEY] = false,
        [CURT_ALLIANCE_POINTS] = false,
        [CURT_TELVAR_STONES] = false,
        [CURT_WRIT_VOUCHERS] = false,
    },
	debug = false,
}

local currencies = {
    [CURT_MONEY] = { 
        name = GetString(SI_CURRENCY_GOLD), color = SF.colors.gold 
    },
    [CURT_ALLIANCE_POINTS] = {
		name = GetString(SI_CURRENCY_ALLIANCE_POINTS), color = SF.colors.fine,
    },
    [CURT_TELVAR_STONES] = {
		name = GetString(SI_CURRENCY_TELVAR_STONES), color = SF.colors.ltskyblue,
    },
	[CURT_WRIT_VOUCHERS] = {
		name = GetString(SI_CURRENCY_WRIT_VOUCHERS), color = SF.colors.normal,
    },
}

local saved, aw, toon
local iconSize = "90%"

---------------------
-- send debug messages to chat if enabled
local PCmsg = SF.addonChatter:New(PC.name)
local debugmode=false
PCmsg:disableDebug()

local function dbg(...)	-- mostly because I hate to type
	PCmsg:debugMsg(...)
end

local function SystemMessage(...) 
    PCmsg:systemMessage(...)
end

local function slashToggleDebug()
	-- have a local debugmode variable instead of just using PCmsg:toggleDebug()
	-- (the addonChatter keeps track of its own state without outside assistance)
	-- just so that I can print to chat that I am enabling or disabling debug mode.
	if( debugmode == false ) then
		debugmode = true
		PCmsg:enableDebug()
		PCmsg:systemMessage("Enabling debug")

	else
		PCmsg:systemMessage("Disabling debug")
		debugmode = false
		PCmsg:disableDebug()
	end
end

---------------------
local function Rebalance()
	local deposit = {}          -- list of deposits to bank
	local withdrawal = {}       -- list of withdrawals from bank
    
	for currencyType, currency in pairs(currencies) do
        if saved.disables[currencyType] == false then
            local bankBalance = GetCurrencyAmount(currencyType, CURRENCY_LOCATION_BANK)
            local pocketChange 	= GetCurrencyAmount(currencyType, CURRENCY_LOCATION_CHARACTER)
            local minCurr = saved.minimum[currencyType]
            local diffCurr = tonumber(pocketChange - minCurr)
            if( diffCurr ~= 0 ) then
                local isDeposit = true
                if( diffCurr < 0 ) then
                    isDeposit = false
                    diffCurr = tonumber(minCurr - pocketChange)
                end
                
                local currColor = currency.color
                local currName = currency.name
                local currIcon = ZO_Currency_GetPlatformFormattedCurrencyIcon(currencyType, iconSize)
                local entry = zo_strformat("|c<<1>><<2>><<3>>|r", currColor.hex, diffCurr, currIcon)
                if (isDeposit == true) then
                    deposit[#deposit + 1] = entry
                    TransferCurrency(currencyType, diffCurr, CURRENCY_LOCATION_CHARACTER, CURRENCY_LOCATION_BANK)
                elseif( diffCurr ~= 0 ) then
                    if( bankBalance < diffCurr ) then
                        diffCurr = bankBalance
                        entry = zo_strformat("|c<<1>><<2>><<3>>|r", currColor.hex, diffCurr, currIcon)
                    end
                    withdrawal[#withdrawal + 1] = entry
    				TransferCurrency(currencyType, diffCurr, CURRENCY_LOCATION_BANK, CURRENCY_LOCATION_CHARACTER)
                end
            end
        end
    end
    return table.concat(deposit, " + "), table.concat(withdrawal, " + ")
end

local function getLockpicksNeeded()
	local pickStacks = PC.Bag.GetItemsByType(BAG_BACKPACK,{[1]=ITEMTYPE_TOOL,[2]=ITEMTYPE_LOCKPICK})
	local lockpicks = 0
	for i,t in ipairs(pickStacks) do
		local _, stackSize = GetItemInfo(t.bag, t.index)
		dbg(SF.str("picks: ",i," {",t.bag,", index ",t.index,", itemType ",t.itemType,", stackSize ",stackSize,"}"))
		lockpicks = lockpicks + stackSize
	end

	if( saved.minimum[LOCKPICKS] > lockpicks ) then
		local msg = zo_strformat("- <<1>> (<<2>> < <<3>>)",GetString(PC_ITEM_LOCKPICKS),
							SF.str(lockpicks), saved.minimum[LOCKPICKS])
		return msg
	end
	return nil
end

local function getGemsNeeded()
	local gemStacks = PC.Bag.GetSoulGems(BAG_BACKPACK)
	local gems = 0
	for i,t in ipairs(gemStacks) do
		dbg(SF.str("gems: ",i," {",t.bag,", index ",t.index,", tier ",t.tier,", stacksize ",t.size,"}"))
		gems = gems + t.size
	end

	if( saved.minimum[GEMS] > gems ) then
		local msg = zo_strformat("- <<1>> (<<2>> < <<3>>)",GetString(PC_ITEM_GEMS),
							SF.str(gems), saved.minimum[GEMS])
		return msg
	end
	return nil
end

local function getEmptyGemsNeeded()
	local gemStacks = PC.Bag.GetEmptySoulGems(BAG_BACKPACK)
	local gems = 0
	for i,t in ipairs(gemStacks) do
		dbg(SF.str("empty gems: ",i," {",t.bag,", index ",", stacksize ",t.size,"}"))
		gems = gems + t.size
	end

	if( saved.minimum[EMPTY_GEMS] > gems ) then
		local msg = zo_strformat("- <<1>> (<<2>> < <<3>>)",GetString(PC_ITEM_EMPTYGEMS),
							SF.str(gems), saved.minimum[EMPTY_GEMS])
		return msg
	end
	return nil
end

local function getKitsNeeded()
	local kitStacks = PC.Bag.GetRepairKits(BAG_BACKPACK)
	local kits = 0
	for i,t in ipairs(kitStacks) do
		dbg(SF.str("kits: ",i," {",t.bag,", index ",t.index,", tier ",t.tier,", stacksize ",t.size,"}"))
		kits = kits + t.size
	end

	if( saved.minimum[REPAIRS] > kits ) then
		local msg = zo_strformat("- <<1>> (<<2>> < <<3>>)",GetString(PC_ITEM_KITS),
							SF.str(kits), saved.minimum[REPAIRS])
		return msg
	end
	return nil
end

local function ScanWorn()
    local bagId = BAG_WORN
    local bagSlots = GetBagSize(bagId)
    for index = 1, bagSlots do
		local _, stackSize = GetItemInfo(BAG_WORN, index)
		dbg(SF.str(index,". ",GetItemName(bagId, index), " (",stackSize,")"))
    end
end
local function getMainPoisonsNeeded()
	--ScanWorn()
	local equipSlot = EQUIP_SLOT_MAIN_HAND	
	local hasPoison, stackSize = GetItemPairedPoisonInfo(equipSlot) 
	dbg(SF.str("Main: hasPoison=",hasPoison," stacksize=",stackSize))
	local _, stackSize = GetItemInfo(BAG_WORN, EQUIP_SLOT_POISON)
	--dbg(SF.str("Main: stacksize=",stackSize))
	--dbg(SF.str("Main: saved.minimum[MAIN_WEAPON]=",saved.minimum[MAIN_WEAPON]))
	if hasPoison ~= true then
		stackSize = 0
	end
	
	if( saved.minimum[MAIN_WEAPON] > stackSize ) then
		local msg = zo_strformat("- <<1>> (<<2>> < <<3>>)",GetString(PC_ITEM_MAIN),
							SF.str(stackSize), saved.minimum[MAIN_WEAPON])
		return msg
	end
	return nil
end

local function getBkupPoisonsNeeded()
	-- EQUIP_SLOT_BACKUP_POISON
	local equipSlot = EQUIP_SLOT_BACKUP_MAIN	
	local hasPoison, stackSize = GetItemPairedPoisonInfo(equipSlot) 	
	dbg(SF.str("Backup: hasPoison=",hasPoison," stacksize=",stackSize))
	dbg(SF.str("Backup: saved.minimum[MAIN_WEAPON]=",saved.minimum[MAIN_WEAPON]))
	if hasPoison ~= true then
		stackSize = 0
	end
	
	if( saved.minimum[BKUP_WEAPON] > stackSize ) then
		local msg = zo_strformat("- <<1>> (<<2>> < <<3>>)",GetString(PC_ITEM_BKUP),
							SF.str(stackSize), saved.minimum[BKUP_WEAPON])
		return msg
	end
	return nil
end


local function onBankOpen(_, bag)
	if( bag ~= BAG_BANK and bag ~= BAG_SUBSCRIBER_BANK ) then
		return
	end
	local deposit, withdrawal = Rebalance()
	if deposit ~= "" then
		local msg = zo_strformat("<<1>> <<2>>", GetString(POCKETCHANGE_DEPOSIT), deposit)
		SystemMessage(msg)
	end
	if withdrawal ~= "" then
		local msg = zo_strformat("<<1>> <<2>>", GetString(POCKETCHANGE_WITHDRAWAL), withdrawal)
		SystemMessage(msg)
	end
	local lkp = getLockpicksNeeded()
	local sg = getGemsNeeded()
	local esg = getEmptyGemsNeeded()
	local rk = getKitsNeeded()
	local mp = getMainPoisonsNeeded()
	local bp = getBkupPoisonsNeeded()
	if( lkp ~= nil or sg ~= nil or rk ~= nil or esg ~= nil or bp ~= nil or mp ~= nil ) then
		local ps = 0
		local alrt = 0
		if( lkp ~= nil and saved.notify[LOCKPICKS] ~= "Mode_No" ) then 
			if( ps == 0 ) then SystemMessage(GetString(PC_SUPPLIES_NEEDED)) end
			SystemMessage(lkp) 
			ps = 1
			if( saved.notify[LOCKPICKS] == "Mode_SoundChat" ) then alrt = 1 end
		end
		if( sg ~= nil and saved.notify[GEMS] ~= "Mode_No" ) then
			if( ps == 0 ) then SystemMessage(GetString(PC_SUPPLIES_NEEDED)) end
			SystemMessage(sg) 
			ps = 1
			if( saved.notify[GEMS] == "Mode_SoundChat" ) then alrt = 1 end
		end
		if( esg ~= nil and saved.notify[EMPTY_GEMS] ~= "Mode_No" ) then
			if( ps == 0 ) then SystemMessage(GetString(PC_SUPPLIES_NEEDED)) end
			SystemMessage(esg) 
			ps = 1
			if( saved.notify[EMPTY_GEMS] == "Mode_SoundChat" ) then alrt = 1 end
		end
		if( rk ~= nil and saved.notify[REPAIRS] ~= "Mode_No" ) then
			if( ps == 0 ) then SystemMessage(GetString(PC_SUPPLIES_NEEDED)) end
			SystemMessage(rk) 
			ps = 1
			if( saved.notify[REPAIRS] == "Mode_SoundChat" ) then alrt = 1 end
		end
		if( mp ~= nil and saved.notify[MAIN_WEAPON] ~= "Mode_No" ) then
			if( ps == 0 ) then SystemMessage(GetString(PC_SUPPLIES_NEEDED)) end
			SystemMessage(mp) 
			ps = 1
			if( saved.notify[MAIN_WEAPON] == "Mode_SoundChat" ) then alrt = 1 end
		end
		if( bp ~= nil and saved.notify[BKUP_WEAPON] ~= "Mode_No" ) then
			if( ps == 0 ) then SystemMessage(GetString(PC_SUPPLIES_NEEDED)) end
			SystemMessage(bp) 
			ps = 1
			if( saved.notify[BKUP_WEAPON] == "Mode_SoundChat" ) then alrt = 1 end
		end
		if( alrt == 1 ) then
				ZO_Alert(UI_ALERT_CATEGORY_ALERT, SOUNDS.ABILITY_ULTIMATE_READY, 
					SFcolor.red:Colorize(PC_SUPPLIES_NEEDED))
		end
	end
end

--------------
local function getCurrencyLabel(currencyType)
	local icon = ZO_Currency_GetPlatformFormattedCurrencyIcon(currencyType, iconSize)
	local text = currencies[currencyType].name
	dbg(SF.str("currency name: ",text, "    currency type: ",currencyType))
	local label = zo_strformat("<<1>> |c<<2>><<3>>|r", icon, currencies[currencyType].color.hex, text)
	return label
end

local function SettingsMenu()

	local notifyChoices = {
		GetString(PC_NOPT_NO), 
		GetString(PC_NOPT_CHAT),
		GetString(PC_NOPT_BOTH), 
	}
	local menu = LibAddonMenu2
	
	local panel = {
		type = "panel",
		name = PC.name,
		displayName = PC.displayName,
		author = PC.author,
        version = PC.version,
	    slashCommand = "/pocketchange.settings",
		registerForRefresh = true,
		registerForDefaults = true,
	}

	local options = {
		{
			type = "checkbox",
			name = POCKETCHANGE_ACCOUNTWIDE,
			tooltip = POCKETCHANGE_ACCOUNTWIDE_TT,
			getFunc = function() return toon.accountWide end,
			setFunc = function(value) 
                saved = SF.currentSavedVars(aw,toon,value)
			end,
			default = defaults.accountWide,
		},
		{
			type = "header",
			name = POCKETCHANGE_CURRENCY,
		},
		{
			type = "description",
			text = POCKETCHANGE_AUTOMANAGEMENT,
		},
		{
			type = "checkbox",
			name = PC_DISABLE_AUTOGOLD,
			tooltip = POCKETCHANGE_DISABLEAUTO_TT,
			getFunc = function() return saved.disables[CURT_MONEY] end,
			setFunc = function(value) 
				saved.disables[CURT_MONEY] = value 
			end,
			default = defaults.disables[CURT_MONEY],
		},
		{
			type = "checkbox",
			name = PC_DISABLE_AUTOAP,
			tooltip = POCKETCHANGE_DISABLEAUTO_TT,
			getFunc = function() return saved.disables[CURT_ALLIANCE_POINTS] end,
			setFunc = function(value) 
				saved.disables[CURT_ALLIANCE_POINTS] = value 
			end,
			default = defaults.disables[CURT_ALLIANCE_POINTS],
		},
		{
			type = "checkbox",
			name = PC_DISABLE_AUTOTELVAR,
			tooltip = POCKETCHANGE_DISABLEAUTO_TT,
			getFunc = function() return saved.disables[CURT_TELVAR_STONES] end,
			setFunc = function(value) 
				saved.disables[CURT_TELVAR_STONES] = value 
			end,
			default = defaults.disables[CURT_TELVAR_STONES],
		},
		{
			type = "checkbox",
			name = PC_DISABLE_AUTOVOUCHER,
			tooltip = POCKETCHANGE_DISABLEAUTO_TT,
			getFunc = function() return saved.disables[CURT_WRIT_VOUCHERS] end,
			setFunc = function(value) 
				saved.disables[CURT_WRIT_VOUCHERS] = value 
			end,
			default = defaults.disables[CURT_WRIT_VOUCHERS],
		},
		{
			type = "description",
			text = POCKETCHANGE_DESCRIPTION,
		},
		{
			type = "slider",
			name = getCurrencyLabel(CURT_MONEY),
			min = 0,
			max = 200000,
			step = 1000,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			disabled = function() 
					return saved.disables[CURT_MONEY]
				end,
			getFunc = function() 
					if saved.minimum[CURT_MONEY] < 0 then
						return 0
					end
					return saved.minimum[CURT_MONEY] 
				end,
			setFunc = function(value) 
					if value < 0 then
						saved.minimum[CURT_MONEY] = 0
					else
						saved.minimum[CURT_MONEY] = value 
					end
				end,
			default = defaults.minimum["CURT_MONEY"],
		},
		{
			type = "slider",
			name = getCurrencyLabel(CURT_TELVAR_STONES),
			min = 0,
			max = 6000,
			step = 100,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			disabled = function() 
					return saved.disables[CURT_TELVAR_STONES]
				end,
			getFunc = function() 
					if saved.minimum[CURT_TELVAR_STONES] < 0 then
						return 0
					else
						return saved.minimum[CURT_TELVAR_STONES] 
					end
				end,
			setFunc = function(value) 
					if value < 0 then
						saved.minimum[CURT_TELVAR_STONES] = 0
					else
						saved.minimum[CURT_TELVAR_STONES] = value 
					end
				end,
			default = defaults.minimum[CURT_TELVAR_STONES],
		},
		{
			type = "slider",
			name = getCurrencyLabel(CURT_ALLIANCE_POINTS),
			min = 0,
			max = 1000000,
			step = 100000,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			disabled = function() 
					return saved.disables[CURT_ALLIANCE_POINTS]
				end,
			getFunc = function() 
					if saved.minimum[CURT_ALLIANCE_POINTS] < 0 then
						return 0
					else
						return saved.minimum[CURT_ALLIANCE_POINTS] 
					end
				end,
			setFunc = function(value) 
					if value < 0 then
						saved.minimum[CURT_ALLIANCE_POINTS] = 0
					else
						saved.minimum[CURT_ALLIANCE_POINTS] = value
					end
				end,
			default = defaults.minimum[CURT_ALLIANCE_POINTS],
		},
		{
			type = "slider",
			name = getCurrencyLabel(CURT_WRIT_VOUCHERS),
			min = 0,
			max = 1000,
			step = 10,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			disabled = function() 
					return saved.disables[CURT_WRIT_VOUCHERS]
				end,
			getFunc = function() return saved.minimum[CURT_WRIT_VOUCHERS] end,
			setFunc = function(value) saved.minimum[CURT_WRIT_VOUCHERS] = value end,
			default = defaults.minimum[CURT_WRIT_VOUCHERS],
		},
		{
			type = "header",
			name = PC_SUPPLIES,
		},
		{
			type = "description",
			text = PC_SUPPLIES_DESC,
		},
		{
			type = "dropdown",
			name = PC_NOTIFY_LP,
			choices = notifyChoices,
			getFunc = function() return ModeArray[saved.notify[LOCKPICKS]] end,
			setFunc = function(var)
				saved.notify[LOCKPICKS] = ModeArray[var]
			end,
			default = ModeArray[GetString(PC_NOPT_NO)], 
			width = "half",
		},  -- end dropdown
		{
			type = "slider",
			name = GetString(PC_LOCKPICKS),
			min = 0,
			max = 400,
			step = 10,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			getFunc = function() return saved.minimum[LOCKPICKS] end,
			setFunc = function(value) saved.minimum[LOCKPICKS] = value end,
			default = defaults.minimum[LOCKPICKS],
			width = "half",
		},
		{
			type = "dropdown",
			name = PC_NOTIFY_RK,
			choices = notifyChoices,
			getFunc = function() return ModeArray[saved.notify[REPAIRS]] end,
			setFunc = function(var)
				saved.notify[REPAIRS] = ModeArray[var]
			end,
			default = ModeArray[GetString(PC_NOPT_NO)], 
			width = "half",
		},  -- end dropdown
		{
			type = "slider",
			name = GetString(PC_REPAIRKITS),
			min = 0,
			max = 400,
			step = 10,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			getFunc = function() return saved.minimum[REPAIRS] end,
			setFunc = function(value) saved.minimum[REPAIRS] = value end,
			default = defaults.minimum[REPAIRS],
			width = "half",
		},
		{
			type = "dropdown",
			name = PC_NOTIFY_SG,
			choices = notifyChoices,
			getFunc = function() return ModeArray[saved.notify[GEMS]] end,
			setFunc = function(var)
				saved.notify[GEMS] = ModeArray[var]
			end,
			default = ModeArray[GetString(PC_NOPT_NO)], 
			width = "half",
		},  -- end dropdown
		{
			type = "slider",
			name = GetString(PC_SOULGEMS),
			min = 0,
			max = 400,
			step = 10,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			getFunc = function() return saved.minimum[GEMS] end,
			setFunc = function(value) saved.minimum[GEMS] = value end,
			default = defaults.minimum[GEMS],
			width = "half",
		},
		{
			type = "dropdown",
			name = PC_NOTIFY_ESG,
			choices = notifyChoices,
			getFunc = function() return ModeArray[saved.notify[EMPTY_GEMS]] end,
			setFunc = function(var)
				saved.notify[EMPTY_GEMS] = ModeArray[var]
			end,
			default = ModeArray[GetString(PC_NOPT_NO)], 
			width = "half",
		},  -- end dropdown
		{
			type = "slider",
			name = GetString(PC_ESOULGEMS),
			min = 0,
			max = 400,
			step = 10,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			getFunc = function() return saved.minimum[EMPTY_GEMS] end,
			setFunc = function(value) saved.minimum[EMPTY_GEMS] = value end,
			default = defaults.minimum[EMPTY_GEMS],
			width = "half",
		},
		{
			type = "dropdown",
			name = PC_NOTIFY_MAIN,
			choices = notifyChoices,
			getFunc = function() return ModeArray[saved.notify[MAIN_WEAPON]] end,
			setFunc = function(var)
				saved.notify[MAIN_WEAPON] = ModeArray[var]
			end,
			default = ModeArray[GetString(PC_NOPT_NO)], 
			width = "half",
		},  -- end dropdown
		{
			type = "slider",
			name = GetString(PC_MAINPOISONS),
			min = 0,
			max = 400,
			step = 10,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			getFunc = function() return saved.minimum[MAIN_WEAPON] end,
			setFunc = function(value) saved.minimum[MAIN_WEAPON] = value end,
			default = defaults.minimum[MAIN_WEAPON],
			width = "half",
		},
		{
			type = "dropdown",
			name = PC_NOTIFY_BKUP,
			choices = notifyChoices,
			getFunc = function() return ModeArray[saved.notify[BKUP_WEAPON]] end,
			setFunc = function(var)
				saved.notify[BKUP_WEAPON] = ModeArray[var]
			end,
			default = ModeArray[GetString(PC_NOPT_NO)], 
			width = "half",
		},  -- end dropdown
		{
			type = "slider",
			name = GetString(PC_BKUPPOISONS),
			min = 0,
			max = 400,
			step = 10,
			inputLocation = "right",
			clampInput = false,
			decimals = 0,
			getFunc = function() return saved.minimum[BKUP_WEAPON] end,
			setFunc = function(value) saved.minimum[BKUP_WEAPON] = value end,
			default = defaults.minimum[BKUP_WEAPON],
			width = "half",
		},
	}

	menu:RegisterAddonPanel("PCOptionsMenu", panel)
	menu:RegisterOptionControls("PCOptionsMenu", options)

end

----------
-- INIT --
----------
local function onPlayerActivated()
    if(saved.debug == true) then
        SystemMessage(GetString(POCKETCHANGE_ENABLE_DEBUG))
    end
	EVENT_MANAGER:UnregisterForEvent(PC.name, EVENT_PLAYER_ACTIVATED)
	EVENT_MANAGER:RegisterForEvent(PC.name, EVENT_OPEN_BANK, onBankOpen)
end

local function onAddonLoaded(_, addonName)
	if addonName == PC.name then
		EVENT_MANAGER:UnregisterForEvent(PC.name, EVENT_ADD_ON_LOADED)
		
        aw, toon = SF.getAllSavedVars("PocketChangeVar", 1, defaults)
        saved = SF.currentSavedVars(aw, toon)
		
		SettingsMenu()
		
		EVENT_MANAGER:RegisterForEvent(PC.name, EVENT_PLAYER_ACTIVATED, onPlayerActivated)
	end
	
end

function PC.slashHelp()
	if PCmsg == nil then return end
    local cmdtable = {
        {"/pocketchange", PC_SLASH_HELP},
        {"/pocketchange.settings", PC_SLASH_SETTINGS},
        {"/pocketchange debug", PC_SLASH_DEBUG},
    }
    local title = "PocketChange commands"
    PCmsg:slashHelp(title, cmdtable)
end

-- slash commands (must not have capital letters!!)
SLASH_COMMANDS["/pocketchange"] = function(...)
	local nargs = select('#',...)
	if( nargs == 0 ) then
		PC.slashHelp()
	else
		i = 1
		local v = select(i,...)
        local t = type(v)
        if(v == nil or v == "") then
			PC.slashHelp()
		elseif(t == "table") then
			PCmsg:debugMsg("Invalid argument for /pocketchange")
		else
			local s = tostring(v)
			if( s == "debug" ) then
				slashToggleDebug()
			elseif( s == "help") then
				PC.slashHelp()
            else
                PCmsg:debugMsg("Invalid argument for /pocketchange")
			end
		end
	end
end

EVENT_MANAGER:RegisterForEvent(PC.name, EVENT_ADD_ON_LOADED, onAddonLoaded)



