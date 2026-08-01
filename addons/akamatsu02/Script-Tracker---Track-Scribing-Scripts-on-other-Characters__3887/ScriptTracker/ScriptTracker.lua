ScriptTracker = ScriptTracker or {}
ScriptTracker.name = "ScriptTracker"
ScriptTracker.savedVars = {}
ScriptTracker.selectedChar = nil
ScriptTracker.donate = "Donate <3"
ScriptTracker.charList = {}
ScriptTracker.chatButton = {}

local TYPE_DISCOVERABLE_NONE = 0
local TYPE_DISCOVERABLE_QUEST = 1
local TYPE_DISCOVERABLE_COLLECT = 2

local scriptList = {
	[204549] = true, --Focus Script: Physical Damage 		
    [204550] = true, --Focus Script: Poison Damage 		
    [204551] = true, --Focus Script: Disease Damage 		
    [204552] = true, --Focus Script: Bleed Damage 		
    [204553] = true, --Focus Script: Magic Damage 		
    [204554] = true, --Focus Script: Shock Damage 		
    [204555] = true, --Focus Script: Frost Damage 		
    [204556] = true, --Focus Script: Flame Damage 		
    [204557] = true, --Focus Script: Trauma 		
    [204558] = true, --Focus Script: Multi-Target 		
    [204560] = true, --Focus Script: Taunt 		
    [204561] = true, --Focus Script: Knockback 		
    [204562] = true, --Focus Script: Pull 		
    [204563] = true, --Focus Script: Immobilize 		
    [204564] = true, --Focus Script: Stun 		
    [204565] = true, --Focus Script: Dispel 		
    [204566] = true, --Focus Script: Healing 		
    [204567] = true, --Focus Script: Restore Resources 		
    [204568] = true, --Focus Script: Damage Shield 		
    [204570] = true, --Focus Script: Generate Ultimate 		
    [204571] = true, --Focus Script: Mitigation 		
    [204572] = true, --Signature Script: Lingering Torment 		
    [204573] = true, --Signature Script: Hunter's Snare 		
    [204574] = true, --Signature Script: Knight's Valor 		
    [204575] = true, --Signature Script: Leeching Thirst 		
    [204576] = true, --Signature Script: Immobilizing Strike 		
    [204577] = true, --Signature Script: Assassin's Misery 		
    [204578] = true, --Signature Script: Anchorite's Cruelty 		
    [204579] = true, --Signature Script: Class Mastery 		
    [204580] = true, --Signature Script: Sage's Remedy 		
    [204581] = true, --Signature Script: Warmage's Defense 		
    [204582] = true, --Signature Script: Druid's Resurgence 		
    [204583] = true, --Signature Script: Thief's Swiftness 		
    [204584] = true, --Signature Script: Crusader's Defiance 		
    [204585] = true, --Signature Script: Fencer's Parry 		
    [204586] = true, --Signature Script: Gladiator's Tenacity 		
    [204587] = true, --Signature Script: Anchorite's Potency 		
    [204588] = true, --Signature Script: Wayfarer's Mastery 		
    [204589] = true, --Signature Script: Warrior's Opportunity 		
    [204590] = true, --Signature Script: Cavalier's Charge 		
    [204592] = true, --Affix Script: Off Balance 		
    [204593] = true, --Affix Script: Interrupt 		
    [204594] = true, --Affix Script: Savagery and Prophecy 		
    [204595] = true, --Affix Script: Expedition 		
    [204596] = true, --Affix Script: Resolve 		
    [204597] = true, --Affix Script: Evasion 		
    [204598] = true, --Affix Script: Vitality 		
    [204599] = true, --Affix Script: Berserk 		
    [204600] = true, --Affix Script: Brutality and Sorcery 		
    [204601] = true, --Affix Script: Empower 		
    [204602] = true, --Affix Script: Protection 		
    [204603] = true, --Affix Script: Courage 		
    [204604] = true, --Affix Script: Heroism 		
    [204605] = true, --Affix Script: Intellect and Endurance 		
    [204606] = true, --Affix Script: Force 		
    [204607] = true, --Affix Script: Vulnerability 		
    [204608] = true, --Affix Script: Maim 		
    [204609] = true, --Affix Script: Cowardice 		
    [204610] = true, --Affix Script: Enervation 		
    [204611] = true, --Affix Script: Mangle 		
    [204612] = true, --Affix Script: Breach 		
    [204613] = true, --Affix Script: Lifesteal 		
    [204614] = true, --Affix Script: Defile 		
    [204615] = true, --Affix Script: Brittle 		
    [204616] = true, --Affix Script: Uncertainty 		
    [204617] = true, --Affix Script: Magickasteal 		
    [207949] = true, --Signature Script: Growing Impact 		
    [207999] = true, --Bound Focus Script: Physical Damage 		
    [208000] = true, --Bound Focus Script: Poison Damage 		
    [208001] = true, --Bound Focus Script: Disease Damage 		
    [208002] = true, --Bound Focus Script: Bleed Damage 		
    [208003] = true, --Bound Focus Script: Magic Damage 		
    [208004] = true, --Bound Focus Script: Shock Damage 		
    [208005] = true, --Bound Focus Script: Frost Damage 		
    [208006] = true, --Bound Focus Script: Flame Damage 		
    [208007] = true, --Bound Focus Script: Trauma 		
    [208008] = true, --Bound Focus Script: Multi-Target 		
    [208010] = true, --Bound Focus Script: Taunt 		
    [208011] = true, --Bound Focus Script: Knockback 		
    [208012] = true, --Bound Focus Script: Pull 		
    [208013] = true, --Bound Focus Script: Immobilize 		
    [208014] = true, --Bound Focus Script: Stun 		
    [208015] = true, --Bound Focus Script: Dispel 		
    [208016] = true, --Bound Focus Script: Healing 		
    [208017] = true, --Bound Focus Script: Restore Resources 		
    [208018] = true, --Bound Focus Script: Damage Shield 		
    [208019] = true, --Bound Focus Script: Generate Ultimate 		
    [208020] = true, --Bound Focus Script: Mitigation 		
    [208021] = true, --Bound Signature Script: Lingering Torment 		
    [208022] = true, --Bound Signature Script: Hunter's Snare 		
    [208023] = true, --Bound Signature Script: Knight's Valor 		
    [208024] = true, --Bound Signature Script: Leeching Thirst 		
    [208025] = true, --Bound Signature Script: Immobilizing Strike 		
    [208026] = true, --Bound Signature Script: Assassins Misery 		
    [208027] = true, --Bound Signature Script: Anchorite's Cruelty 		
    [208028] = true, --Bound Signature Script: Class Mastery 		
    [208029] = true, --Bound Signature Script: Sage's Remedy 		
    [208030] = true, --Bound Signature Script: Warmage's Defense 		
    [208031] = true, --Bound Signature Script: Druid's Resurgence 		
    [208032] = true, --Bound Signature Script: Thief's Swiftness 		
    [208033] = true, --Bound Signature Script: Crusader's Defiance 		
    [208034] = true, --Bound Signature Script: Fencer's Parry 		
    [208035] = true, --Bound Signature Script: Gladiator's Tenacity 		
    [208036] = true, --Bound Signature Script: Anchorite's Potency 		
    [208037] = true, --Bound Signature Script: Wayfarer's Mastery 		
    [208038] = true, --Bound Signature Script: Warrior's Opportunity 		
    [208039] = true, --Bound Signature Script: Cavalier's Charge 		
    [208041] = true, --Bound Signature Script: Growing Impact 		
    [208042] = true, --Bound Affix Script: Off Balance 		
    [208043] = true, --Bound Affix Script: Interrupt 		
    [208044] = true, --Bound Affix Script: Savagery and Prophecy 		
    [208045] = true, --Bound Affix Script: Expedition 		
    [208046] = true, --Bound Affix Script: Resolve 		
    [208047] = true, --Bound Affix Script: Evasion 		
    [208048] = true, --Bound Affix Script: Vitality 		
    [208049] = true, --Bound Affix Script: Berserk 		
    [208050] = true, --Bound Affix Script: Brutality and Sorcery 		
    [208051] = true, --Bound Affix Script: Empower 		
    [208052] = true, --Bound Affix Script: Protection 		
    [208053] = true, --Bound Affix Script: Courage 		
    [208054] = true, --Bound Affix Script: Heroism 		
    [208055] = true, --Bound Affix Script: Intellect and Endurance 		
    [208056] = true, --Bound Affix Script: Force 		
    [208057] = true, --Bound Affix Script: Vulnerability 		
    [208058] = true, --Bound Affix Script: Maim 		
    [208059] = true, --Bound Affix Script: Cowardice 		
    [208060] = true, --Bound Affix Script: Enervation 		
    [208061] = true, --Bound Affix Script: Mangle 		
    [208062] = true, --Bound Affix Script: Breach 		
    [208063] = true, --Bound Affix Script: Lifesteal 		
    [208064] = true, --Bound Affix Script: Defile 		
    [208065] = true, --Bound Affix Script: Brittle 		
    [208066] = true, --Bound Affix Script: Uncertainty 		
    [208067] = true --Bound Affix Script: Magickasteal
}

local scriptItemList = {
	--Focus
	[1] = { bound = 207999, unbound = 204549, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "1.dds"  },
	[2] = { bound = 208000, unbound = 204550, discoverable = TYPE_DISCOVERABLE_NONE },
	[3] = { bound = 208001, unbound = 204551, discoverable = TYPE_DISCOVERABLE_NONE },
	[4] = { bound = 208002, unbound = 204552, discoverable = TYPE_DISCOVERABLE_NONE },
	[5] = { bound = 208003, unbound = 204553, discoverable = TYPE_DISCOVERABLE_QUEST },
	[6] = { bound = 208004, unbound = 204554, discoverable = TYPE_DISCOVERABLE_NONE },
	[7] = { bound = 208005, unbound = 204555, discoverable = TYPE_DISCOVERABLE_NONE },
	[8] = { bound = 208006, unbound = 204556, discoverable = TYPE_DISCOVERABLE_NONE },
	[9] = { bound = 208007, unbound = 204557, discoverable = TYPE_DISCOVERABLE_NONE },
	[10] = { bound = 208008, unbound = 204558, discoverable = TYPE_DISCOVERABLE_NONE },
	[12] = { bound = 208010, unbound = 204560, discoverable = TYPE_DISCOVERABLE_NONE },
	[13] = { bound = 208011, unbound = 204561, discoverable = TYPE_DISCOVERABLE_NONE },
	[14] = { bound = 208012, unbound = 204562, discoverable = TYPE_DISCOVERABLE_NONE },
	[15] = { bound = 208013, unbound = 204563, discoverable = TYPE_DISCOVERABLE_NONE },
	[16] = { bound = 208014, unbound = 204564, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "16.dds"  },
	[17] = { bound = 208015, unbound = 204565, discoverable = TYPE_DISCOVERABLE_NONE },
	[18] = { bound = 208016, unbound = 204566, discoverable = TYPE_DISCOVERABLE_QUEST },
	[19] = { bound = 208017, unbound = 204567, discoverable = TYPE_DISCOVERABLE_NONE },
	[20] = { bound = 208018, unbound = 204568, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "20.dds" },
	[22] = { bound = 208019, unbound = 204570, discoverable = TYPE_DISCOVERABLE_NONE },
	[23] = { bound = 208020, unbound = 204571, discoverable = TYPE_DISCOVERABLE_NONE },
	--Signature
	[24] = { bound = 208021, unbound = 204572, discoverable = TYPE_DISCOVERABLE_QUEST },
	[25] = { bound = 208022, unbound = 204573, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "25.dds"  },
	[26] = { bound = 208023, unbound = 204574, discoverable = TYPE_DISCOVERABLE_NONE },
	[27] = { bound = 208024, unbound = 204575, discoverable = TYPE_DISCOVERABLE_NONE },
	[28] = { bound = 208025, unbound = 204576, discoverable = TYPE_DISCOVERABLE_NONE },
	[29] = { bound = 208026, unbound = 204577, discoverable = TYPE_DISCOVERABLE_NONE },
	[30] = { bound = 208027, unbound = 204578, discoverable = TYPE_DISCOVERABLE_NONE },
	[31] = { bound = 208028, unbound = 204579, discoverable = TYPE_DISCOVERABLE_NONE },
	[32] = { bound = 208029, unbound = 204580, discoverable = TYPE_DISCOVERABLE_QUEST },
	[33] = { bound = 208030, unbound = 204581, discoverable = TYPE_DISCOVERABLE_NONE },
	[34] = { bound = 208031, unbound = 204582, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "34.dds"  },
	[35] = { bound = 208032, unbound = 204583, discoverable = TYPE_DISCOVERABLE_NONE },
	[36] = { bound = 208033, unbound = 204584, discoverable = TYPE_DISCOVERABLE_NONE },
	[37] = { bound = 208034, unbound = 204585, discoverable = TYPE_DISCOVERABLE_NONE },
	[38] = { bound = 208035, unbound = 204586, discoverable = TYPE_DISCOVERABLE_NONE },
	[39] = { bound = 208036, unbound = 204587, discoverable = TYPE_DISCOVERABLE_NONE },
	[40] = { bound = 208037, unbound = 204588, discoverable = TYPE_DISCOVERABLE_NONE },
	[41] = { bound = 208038, unbound = 204589, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "41.dds"  },
	[42] = { bound = 208039, unbound = 204590, discoverable = TYPE_DISCOVERABLE_NONE },
	[70] = { bound = 208041, unbound = 207949, discoverable = TYPE_DISCOVERABLE_NONE },
	--Affix
	[44] = { bound = 208042, unbound = 204592, discoverable = TYPE_DISCOVERABLE_QUEST },
	[45] = { bound = 208043, unbound = 204593, discoverable = TYPE_DISCOVERABLE_NONE },
	[46] = { bound = 208044, unbound = 204594, discoverable = TYPE_DISCOVERABLE_NONE },
	[47] = { bound = 208045, unbound = 204595, discoverable = TYPE_DISCOVERABLE_NONE },
	[48] = { bound = 208046, unbound = 204596, discoverable = TYPE_DISCOVERABLE_QUEST },
	[49] = { bound = 208047, unbound = 204597, discoverable = TYPE_DISCOVERABLE_NONE },
	[50] = { bound = 208048, unbound = 204598, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "50.dds"  },
	[51] = { bound = 208049, unbound = 204599, discoverable = TYPE_DISCOVERABLE_NONE },
	[52] = { bound = 208050, unbound = 204600, discoverable = TYPE_DISCOVERABLE_NONE },
	[53] = { bound = 208051, unbound = 204601, discoverable = TYPE_DISCOVERABLE_NONE },
	[54] = { bound = 208052, unbound = 204602, discoverable = TYPE_DISCOVERABLE_NONE },
	[55] = { bound = 208053, unbound = 204603, discoverable = TYPE_DISCOVERABLE_NONE },
	[56] = { bound = 208054, unbound = 204604, discoverable = TYPE_DISCOVERABLE_NONE },
	[57] = { bound = 208055, unbound = 204605, discoverable = TYPE_DISCOVERABLE_NONE },
	[58] = { bound = 208056, unbound = 204606, discoverable = TYPE_DISCOVERABLE_NONE },
	[59] = { bound = 208057, unbound = 204607, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "59.dds"  },
	[60] = { bound = 208058, unbound = 204608, discoverable = TYPE_DISCOVERABLE_COLLECT, image = "60.dds"  },
	[61] = { bound = 208059, unbound = 204609, discoverable = TYPE_DISCOVERABLE_NONE },
	[62] = { bound = 208060, unbound = 204610, discoverable = TYPE_DISCOVERABLE_NONE },
	[63] = { bound = 208061, unbound = 204611, discoverable = TYPE_DISCOVERABLE_NONE },
	[64] = { bound = 208062, unbound = 204612, discoverable = TYPE_DISCOVERABLE_QUEST },
	[65] = { bound = 208063, unbound = 204613, discoverable = TYPE_DISCOVERABLE_NONE },
	[66] = { bound = 208064, unbound = 204614, discoverable = TYPE_DISCOVERABLE_NONE },
	[67] = { bound = 208065, unbound = 204615, discoverable = TYPE_DISCOVERABLE_NONE },
	[68] = { bound = 208066, unbound = 204616, discoverable = TYPE_DISCOVERABLE_NONE },
	[69] = { bound = 208067, unbound = 204617, discoverable = TYPE_DISCOVERABLE_NONE },
}

local function clamp(num, min, max)
    if num < min then num = min end
    if num > max then num = max end
    return num
end

local function rgbToHex(r,g,b)
	r = clamp(r, 0, 255)
	g = clamp(g, 0, 255)
	b = clamp(b, 0, 255)
    return string.format("%02x", r)..string.format("%02x", g)..string.format("%02x", b)
end

local function percentageToHex(p)
    local r = 0
    local g = 0
	if p == 100 then
		return rgbToHex(0,255,0)
	end
	if p == 50 then
		return rgbToHex(255,255,0)
	end
	if p == 0 then
		return rgbToHex(255,0,0)
	end
	if p > 50 then
		p = (p - 50) * 2
		p = 1 - (p / 100)
		r = p * 255
		g = 255
	elseif p < 50 then
		p = p * 2
		p = p / 100
		g = p * 255
		r = 255
	end
    return rgbToHex(r,g,0)
end

local function GetFontByTextSize(size)
    return zo_strformat("$(<<1>>)|$(KB_<<2>>)|<<3>>", "MEDIUM_FONT", size, "soft-shadow-thin")
end

function ScriptTracker.UpdateUIFontSize()
	local size = ScriptTracker.savedVars.textsize
	local small = GetFontByTextSize(size)
	local medium = GetFontByTextSize(size + 4)
	local title = GetFontByTextSize(size + 8)

	ScriptTrackerUI_Title:SetFont(title)
	ScriptTrackerUIScribingLabel:SetFont(small)
	ScriptTrackerUIBodyLabelF:SetFont(medium)
	ScriptTrackerUIBodyLabelS:SetFont(medium)
	ScriptTrackerUIBodyLabelA:SetFont(medium)
	ScriptTrackerUIHideCheckBoxLabel:SetFont(small)

	ScriptTracker.UpdateList()
	ScriptTracker.RefreshScriptList(1)
	ScriptTracker.RefreshScriptList(2)
	ScriptTracker.RefreshScriptList(3)
	ScriptTracker.InitComboBox()
end

function ScriptTracker.TextureMessage(texture)
	local size = ScriptTracker.savedVars.textsize * 2
	return "|t"..size..":"..size..":"..texture.."|t"
end

function ScriptTracker.ColorMessage(text,color)
	return "|c"..color..text.."|r"
end

function ScriptTracker.GetScriptName(id)
	return zo_strformat(SI_ABILITY_NAME, GetCraftedAbilityScriptDisplayName(id))
end

function ScriptTracker.GetScriptDescription(id, unlocked)
	local text = tostring(ScriptTracker.GetScriptDescriptionType(id))
	text = text.."\n"..tostring(ScriptTracker.GetScriptDescriptionSource(id))
	text = text.."\n\n"..tostring(ScriptTracker.GetScriptDescriptionColoredGameDescription(id, unlocked))
	text = text.."\n\n"..tostring(ScriptTracker.GetScriptCharacterUnlockInfo(id))
	text = text..tostring(ScriptTracker.GetScriptAvailabilityText(id))
	if (scriptItemList[id] or {}).image ~= nil then
		text = text.."\n\n\n\n\n|t320:180:ScriptTracker/"..tostring((scriptItemList[id] or {}).image).."|t\n\n\n\n"
	end
	if ScriptTracker.savedVars.devmode == false then return text end
	text = text.."\n\nID: "..id
	return text
end

function ScriptTracker.GetScriptDescriptionColoredGameDescription(id, unlocked)
	local text = tostring(GetCraftedAbilityScriptGeneralDescription(id))
	if unlocked == false then
		text = text.."\n\n"..ScriptTracker.ColorMessage(tostring(GetCraftedAbilityScriptAcquireHint(id)), "ffffff")
	end
	return text
end

function ScriptTracker.GetScriptDescriptionSource(id)
	local text = ScriptTracker.ColorMessage("Source: ", "ffff00")
	if (scriptItemList[id] or {}).discoverable == 0 then 
		text = text..ScriptTracker.ColorMessage("Drop","c2c2c2")
	elseif (scriptItemList[id] or {}).discoverable == 1 then 
		text = text..ScriptTracker.ColorMessage("Quest","d75a3f")
	elseif (scriptItemList[id] or {}).discoverable == 2 then 
		text = text..ScriptTracker.ColorMessage("Guild","00c7d1")
	else
		text = text.."Unknown"
	end
	return text
end

function ScriptTracker.GetScriptDescriptionType(id)
	local text = ScriptTracker.ColorMessage("Type: ", "ffff00")
	if ScriptTracker.GetScriptType(id) == 1 then 
		text = text.."Focus"
	elseif ScriptTracker.GetScriptType(id) == 2 then 
		text = text.."Signature"
	elseif ScriptTracker.GetScriptType(id) == 3 then 
		text = text.."Affix"
	else
		text = text.."Unknown"
	end
	return text
end

function ScriptTracker.Round(self, decimals)
    decimals = math.pow(10, decimals or 0)
    self = self * decimals
    if self >= 0 then self = math.floor(self + 0.5) else self = math.ceil(self - 0.5) end
	self = self / decimals
    return self
end

function ScriptTracker.GetCharacterList()
	local data = {}
	for k, v in pairs(ScriptTracker.savedVars.charData or {}) do
		if ScriptTracker.savedVars.hiddenChars[k] ~= true then
			local max = {
				[1] = 0,
				[2] = 0,
				[3] = 0
			}
			local count = {
				[1] = 0,
				[2] = 0,
				[3] = 0
			}
			for key, value in pairs(v) do
				if key ~= "name" then
					if value.unlocked == true then
						count[tonumber(value.type)] = count[tonumber(value.type)] + 1
					end
					max[tonumber(value.type)] = max[tonumber(value.type)] + 1
				end
			end
			local total = max[1] + max[2] + max[3]
			local achieved = count[1] + count[2] + count[3]
			local progress = ScriptTracker.Round(( achieved / total ) * 100, 1)
			local complete = count[1] == max[1] and count[2] == max[2] and count[3] == max[3]
			local text = " (F:"..tostring(count[1]).."/"..tostring(max[1]).." - S:"..tostring(count[2]).."/"..tostring(max[2]).." - A:"..tostring(count[3]).."/"..tostring(max[3])..")"
			table.insert(data, {
				name = tostring(v.name),
				id = tostring(k),
				text = text,
				complete = complete,
				progress = progress
			})
		end
	end
	table.sort(data, function(a,b)
		return a.name < b.name
	end)
	ScriptTracker.charList = data
	return data
end

function ScriptTracker.ToggleCharVisibility(data)
	for k, v in pairs(ScriptTracker.savedVars.charData or {}) do
		local i = tostring(v.name) .. "  -  (" .. k .. ")"
		if i == data then
			ScriptTracker.savedVars.hiddenChars[k] = (ScriptTracker.savedVars.hiddenChars[k] or false) == false
			d(ScriptTracker.savedVars.charData[k].name.." visible: "..tostring(not ScriptTracker.savedVars.hiddenChars[k]))
			ScriptTracker.InitComboBox()
			ScriptTracker.GetCharacterList()
			ScriptTracker.UIResize()
			return
		end
	end
	d("There was an error.")
end

function ScriptTracker.GetCharsForSettings()
	local data = {}
	for k, v in pairs(ScriptTracker.savedVars.charData or {}) do
		table.insert(data, tostring(v.name) .. "  -  (" .. k .. ")")
	end
	table.sort(data, function(a,b)
		return a < b
	end)
	return data
end

function ScriptTracker.GetCharacterData(name)
	local data = ScriptTracker.GetCharacterList()
	for _, v in pairs(data) do
		if v.name == name then
			return v
		end
	end
	return nil
end

function ScriptTracker.GetScriptCharacterUnlockInfo(id)
	if #ScriptTracker.charList == 0 then
		ScriptTracker.GetCharacterList()
	end
	local text = ""
	for i, v in ipairs(ScriptTracker.charList) do
		local unlocked = ScriptTracker.DoesCharHaveScriptUnlocked(v.id, id)
		if unlocked == true then
			text = text..ScriptTracker.ColorMessage(v.name, "00ff00")
		else
			text = text..ScriptTracker.ColorMessage(v.name, "ff0000")
		end
		if i ~= #ScriptTracker.charList then
			text = text..", "
		end
	end
	return text
end

function ScriptTracker.GetScriptIcon(id)
	return ScriptTracker.TextureMessage(GetCraftedAbilityScriptIcon(id))
end

function ScriptTracker.GetScriptUnlocked(id)
	return IsCraftedAbilityScriptUnlocked(id)
end

function ScriptTracker.GetScriptType(id)
	return GetCraftedAbilityScriptScribingSlot(id)
end

function ScriptTracker.DoesCharHaveScriptUnlocked(charId, id)
	if ScriptTracker.savedVars.charData == nil then
		return nil
	end
	if ScriptTracker.savedVars.charData[charId] == nil then
		return nil
	end
	for _, v in pairs(ScriptTracker.savedVars.charData[charId] or {}) do
		if v.id == id then
			return v.unlocked
		end
	end
	return false
end

function ScriptTracker.ScanCharacter()
	local charId = GetCurrentCharacterId()
	ScriptTracker.savedVars.charData[charId] = {
		name = GetUnitName("player")
	}
	for id = 1, 70, 1 do
		if ScriptTracker.GetScriptType(id) ~= 0 then
			ScriptTracker.savedVars.charData[charId][id] = {
				id = id,
				unlocked = ScriptTracker.GetScriptUnlocked(id),
				type = ScriptTracker.GetScriptType(id)
			}
		end
	end
	if ScriptTracker.selectedChar == charId then
		ScriptTracker.RefreshScriptList(1)
		ScriptTracker.RefreshScriptList(2)
		ScriptTracker.RefreshScriptList(3)
	end
	ScriptTracker.InitComboBox()
	ScriptTracker.ScanInventories()
end

function ScriptTracker.OnUIMove()
	ScriptTracker.savedVars.left = ScriptTrackerUI:GetLeft()
	ScriptTracker.savedVars.top = ScriptTrackerUI:GetTop()
	ScriptTracker.savedVars.width = ScriptTrackerUI:GetWidth()
	ScriptTracker.savedVars.height = ScriptTrackerUI:GetHeight()
	ScriptTracker.UIResize()
end

function ScriptTracker.UIResize()
	local width = ScriptTrackerUIBody:GetWidth()
	local height = ScriptTrackerUIBody:GetHeight()-72
	ScriptTrackerUIBodyFocusList:SetDimensions(width/3, height)
	ScriptTrackerUIBodySignatureList:SetDimensions(width/3, height)
	ScriptTrackerUIBodyAffixList:SetDimensions(width/3, height)
	ScriptTracker.RefreshScriptList(1)
	ScriptTracker.RefreshScriptList(2)
	ScriptTracker.RefreshScriptList(3)
end

function ScriptTracker.toDonate()
	SCENE_MANAGER:Show('mailSend')
	zo_callLater(function()
		ZO_MailSendToField:SetText("@akamatsu02")
		ZO_MailSendSubjectField:SetText(ScriptTracker.name.." - Donation")
		ZO_MailSendBodyField:SetText("")
		QueueMoneyAttachment(50000)
		ZO_MailSendBodyField:TakeFocus()
	end, 200)
end

function ScriptTracker.toggleFavorite(control)
	ScriptTracker.savedVars.fav[tonumber(control.data.id)] = ScriptTracker.savedVars.fav[tonumber(control.data.id)] ~= true
	ScriptTracker.RefreshScriptList(1)
	ScriptTracker.RefreshScriptList(2)
	ScriptTracker.RefreshScriptList(3)
end

function ScriptTracker.SetupScriptRow(control, data)
	control:SetDimensions(control:GetWidth(), ScriptTracker.savedVars.textsize * 2 + 10)
	control.data = data
	control.label = GetControl(control, "Label")
	control.label:SetDimensions(control.label:GetWidth(), ScriptTracker.savedVars.textsize + 2)
	control.label:SetFont(GetFontByTextSize(ScriptTracker.savedVars.textsize))
	if data.unlocked == true then
		control.label:SetColor(0,1,0,1)
	else
		if ScriptTracker.IsScriptAvailable(data.id) == true then
			control.label:SetColor(1,0.65,0,1)
		else
			control.label:SetColor(1,0,0,1)
		end
	end
	if data.id == 0 then
		control.label:SetText("All scripts unlocked")
		control:SetHandler("OnMouseEnter", function()
			ZO_Tooltips_ShowTextTooltip(control, RIGHT, "All scripts unlocked")
		end);
		control:SetHandler("OnMouseExit", function()
			ZO_Tooltips_HideTextTooltip()
		end)
		return
	end
	local text = ""
	if data.isfav == true then
		text = text..ScriptTracker.ColorMessage("[Fav] ","ffff00")
	end
	if data.discoverableType == 0 then
		text = text..ScriptTracker.ColorMessage("[Drop] ","c2c2c2")
	end
	if data.discoverableType == 1 then
		text = text..ScriptTracker.ColorMessage("[Quest] ","d75a3f")
	end
	if data.discoverableType == 2 then
		text = text..ScriptTracker.ColorMessage("[Guild] ","00c7d1")
	end
	text = text..tostring(ScriptTracker.GetScriptIcon(data.id))
	text = text.." - "
	text = text..tostring(ScriptTracker.GetScriptName(data.id))
	control.label:SetText(text)
	control:SetHandler("OnMouseEnter", function()
		ZO_Tooltips_ShowTextTooltip(control, RIGHT, ScriptTracker.GetScriptDescription(data.id, data.unlocked))
	end);
	control:SetHandler("OnMouseExit", function()
		ZO_Tooltips_HideTextTooltip()
	end)
end

function ScriptTracker.InitList()
	local size = ScriptTracker.savedVars.textsize * 2 + 6
	ZO_ScrollList_AddDataType(ScriptTrackerUIBodyFocusList, 1, "ScriptTrackerUIUnitRow", size, ScriptTracker.SetupScriptRow)
	ZO_ScrollList_AddDataType(ScriptTrackerUIBodySignatureList, 1, "ScriptTrackerUIUnitRow", size, ScriptTracker.SetupScriptRow)
	ZO_ScrollList_AddDataType(ScriptTrackerUIBodyAffixList, 1, "ScriptTrackerUIUnitRow", size, ScriptTracker.SetupScriptRow)
end

function ScriptTracker.UpdateList()
	local size = ScriptTracker.savedVars.textsize * 2 + 6
	ZO_ScrollList_UpdateDataTypeHeight(ScriptTrackerUIBodyFocusList, 1, size)
	ZO_ScrollList_UpdateDataTypeHeight(ScriptTrackerUIBodySignatureList, 1, size)
	ZO_ScrollList_UpdateDataTypeHeight(ScriptTrackerUIBodyAffixList, 1, size)
end

function ScriptTracker.SplitFavorites(favorites)
	local drop = {}
	local quest = {}
	local collectable = {}
	for _, v in pairs(favorites) do
		local target = drop
		if v.discoverableType == 1 then 
			target = quest
		end
		if v.discoverableType == 2 then 
			target = collectable
		end
		table.insert(target, v)
	end
	table.sort(quest, function(a,b)
		return a.id < b.id
	end)
	table.sort(collectable, function(a,b)
		return a.id < b.id
	end)
	table.sort(drop, function(a,b)
		return a.id < b.id
	end)
	return quest, collectable, drop
end

function ScriptTracker.SortAndCombineLists(favorites, quest, collectable, drop)
	table.sort(quest, function(a,b)
		return a.id < b.id
	end)
	table.sort(collectable, function(a,b)
		return a.id < b.id
	end)
	table.sort(drop, function(a,b)
		return a.id < b.id
	end)
	local data = {}
	local favquest, favcollectable, favdrop = ScriptTracker.SplitFavorites(favorites)
	for _, v in ipairs(favquest) do
		table.insert(data, v)
	end
	for _, v in ipairs(favcollectable) do
		table.insert(data, v)
	end
	for _, v in ipairs(favdrop) do
		table.insert(data, v)
	end
	for _, v in ipairs(quest) do
		table.insert(data, v)
	end
	for _, v in ipairs(collectable) do
		table.insert(data, v)
	end
	for _, v in ipairs(drop) do
		table.insert(data, v)
	end
	return data
end

function ScriptTracker.RefreshScriptList(listType)
	local control = ScriptTrackerUIBodyAffixList
	if listType == 1 then
		control = ScriptTrackerUIBodyFocusList
	elseif listType == 2 then
		control = ScriptTrackerUIBodySignatureList
	elseif listType == 3 then
		control = ScriptTrackerUIBodyAffixList
	else
		return
	end
	local scrollData = ZO_ScrollList_GetDataList(control)
	ZO_ScrollList_Clear(control)
	local favs = {}
	local other = {}
	local discoverableQ = {}
	local discoverableOW = {}
	local data = {}
	if ScriptTracker.selectedChar ~= nil then
		for _, v in pairs(ScriptTracker.savedVars.charData[ScriptTracker.selectedChar] or {}) do
			local target = other
			local discoverableType = (scriptItemList[tonumber(v.id)] or {}).discoverable
			if discoverableType == 1 then 
				target = discoverableQ 
			end
			local discoverableType = (scriptItemList[tonumber(v.id)] or {}).discoverable
			if discoverableType == 2 then 
				target = discoverableOW 
			end
			local isfav = ScriptTracker.savedVars.fav[tonumber(v.id)] == true
			if isfav == true then 
				target = favs 
			end
			if v.type == listType then
				if ScriptTracker.savedVars.hideUnlocked == true then
					if v.unlocked == false then
						table.insert(target, {
							id = tonumber(v.id),
							unlocked = v.unlocked == true,
							type = tonumber(listType),
							isfav = isfav,
							discoverableType = discoverableType
						})
					end
				else
					table.insert(target, {
						id = tonumber(v.id),
						unlocked = v.unlocked == true,
						type = tonumber(listType),
						isfav = isfav,
						discoverableType = discoverableType
					})
				end
			end
		end

		data = ScriptTracker.SortAndCombineLists(favs, discoverableQ, discoverableOW, other)
		if #data == 0 then
			table.insert(data, {
				id = 0,
				unlocked = true,
				type = 0,
				isfav = false
			})
		end
		for i=1, #data do
			scrollData[#scrollData + 1] = ZO_ScrollList_CreateDataEntry(1, data[i])
		end
	end
	ZO_ScrollList_Commit(control)
end

function ScriptTracker.OpenWindow(show)
	ScriptTrackerUI:SetHidden(not show)
	local sceneName = SCENE_MANAGER:GetCurrentSceneName() 
	if sceneName == "scribingLibraryKeyboard" or sceneName == "scribingKeyboard" then
		ScriptTracker.savedVars.scenes[sceneName] = show
	end
	if show == true then
		SetGameCameraUIMode(true)
	end
end

SLASH_COMMANDS["/str"] = function ()
	ScriptTracker.OpenWindow(true)
end

SLASH_COMMANDS["/strdev"] = function ()
	ScriptTracker.savedVars.devmode = not ScriptTracker.savedVars.devmode
	if ScriptTracker.savedVars.devmode == true then
		d("Dev-Mode enabled")
	else
		d("Dev-Mode disabled")
	end
end

function ScriptTracker.AddInfo(control, id)
	if IsInGamepadPreferredMode() == true then return end
	control:AddVerticalPadding(5)
	ZO_Tooltip_AddDivider(control)
	control:AddLine(tostring(ScriptTracker.GetScriptCharacterUnlockInfo(tonumber(id))))
	if ScriptTracker.savedVars.devmode == false then return end
	ZO_Tooltip_AddDivider(control)
	control:AddLine("ID: "..id)
end

function ScriptTracker.AddInfoGamepad(control, id)
	if IsInGamepadPreferredMode() == false then return end
	local scenes = {
		['gamepad_inventory_root'] = true
	}
    local currentScene = SCENE_MANAGER:GetCurrentSceneName()
	if not scenes[currentScene] then return end
	local currentTooltip = control
	if not currentTooltip then return end
  
	local currentBodySection = currentTooltip:GetStyle("bodySection")
	local currentBodyDescription = currentTooltip:GetStyle("bodyDescription")
	local currentDividerLine = currentTooltip:GetStyle("dividerLine")
	local currentSection = currentTooltip:AcquireSection(currentBodySection)
  
	currentSection:AddTexture(ZO_GAMEPAD_HEADER_DIVIDER_TEXTURE, currentDividerLine)
	currentSection:AddLine(tostring(ScriptTracker.GetScriptCharacterUnlockInfo(tonumber(id))), currentBodyDescription)
	currentTooltip:AddSection(currentSection)
end

function ScriptTracker.InitComboBox()
	local comboBox
	if ScriptTrackerUIBodyCharDropdown.comboBox ~= nil then
        comboBox = ScriptTrackerUIBodyCharDropdown.comboBox
    else
        comboBox = ZO_ComboBox_ObjectFromContainer(ScriptTrackerUIBodyCharDropdown)
        ScriptTrackerUIBodyCharDropdown.comboBox = comboBox
    end
	comboBox:SetFont(GetFontByTextSize(ScriptTracker.savedVars.textsize))

	local function OnItemSelect(_, choiceText, choice)
        ScriptTracker.selectedChar = choice.data.id
		ScriptTracker.RefreshScriptList(1)
		ScriptTracker.RefreshScriptList(2)
		ScriptTracker.RefreshScriptList(3)
    end

    comboBox:SetSortsItems(false)
	comboBox:ClearItems()

    local choices = ScriptTracker.GetCharacterList()
	ScriptTracker.selectedChar = ScriptTracker.selectedChar or GetCurrentCharacterId()
	local current = nil

    for i = 1, #choices do
		local text = choices[i].name..choices[i].text
		if choices[i].complete == true then
			text = ScriptTracker.ColorMessage(text.." - 100%", "00FF00")
		else
			if choices[i].id == GetCurrentCharacterId() then
				text = ScriptTracker.ColorMessage("> ", "ffff70")..text
			end
			text = text.." - "..ScriptTracker.ColorMessage(tostring(choices[i].progress).."%", percentageToHex(choices[i].progress))
		end
		if choices[i].id == ScriptTracker.selectedChar then
			current = i
		end
        entry = comboBox:CreateItemEntry(text, OnItemSelect)
		entry.data = choices[i]
        comboBox:AddItem(entry)
    end

	if current ~= nil then
		comboBox:SetSelected(current)
	end
end

function ScriptTracker.test()
	for i = 0,100,1 do
		d(ScriptTracker.ColorMessage(percentageToHex(i), percentageToHex(i)))
	end
end

local function ToolTip(control, name, func)
	local base = control[name]
	control[name] = function(ctrl, ...)
		base(ctrl, ...)
		local link = func(...)
		if GetItemLinkItemType(link) == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and ScriptTracker.savedVars.tooltip == true then
			ScriptTracker.AddInfo(ctrl, GetItemLinkItemUseReferenceId(link))
		end
	end
end

local function GamePadToolTip(control, name, func)
	local base = control[name]
	control[name] = function(ctrl, ...)
		base(ctrl, ...)
		local link = func(...)
		if GetItemLinkItemType(link) == ITEMTYPE_CRAFTED_ABILITY_SCRIPT and ScriptTracker.savedVars.tooltip == true then
			ScriptTracker.AddInfoGamepad(ctrl, GetItemLinkItemUseReferenceId(link))
		end
	end
end

local function sceneChange(scene, newState)
	if scene:GetState() ~= SCENE_SHOWN then return end
	local sceneName = scene:GetName()
	ScriptTracker.OpenWindow(ScriptTracker.savedVars.scenes[sceneName] == true)
end

local function copyTable(t)
    local t2 = {}
    for k,v in pairs(t) do
        if type(v) == "table" then
            t2[k] = copyTable(v)
        else
            t2[k] = v
        end
    end
    setmetatable(t2, getmetatable(t))
    return t2
end

function ScriptTracker.UpdateSavedVars()
	if ScriptTracker.savedVars.chars == nil then return end
	local charDB = {}
	for i = 1, GetNumCharacters() do
		local name, _, _, _, _, _, id = GetCharacterInfo(i)
		name = zo_strformat(SI_ABILITY_NAME, name)
		if ScriptTracker.savedVars.chars[name] ~= nil then
			ScriptTracker.savedVars.charData[id] = copyTable(ScriptTracker.savedVars.chars[name])
			ScriptTracker.savedVars.charData[id].name = name
		end
	end
	ScriptTracker.savedVars.chars = nil
end

function ScriptTracker.LootedItem(_, _, itemName, _, _, _, isSelf, _, _, id)
	if isSelf == false then return end
	if id == 204881 then
		if IsAchievementComplete(3991) then
			ScriptTracker.CSA("Looted: "..itemName)
			return
		end
		local _, progress, required = GetAchievementCriterion(3991, 1)
		ScriptTracker.CSA("Looted: "..itemName.." ("..progress.."/"..required..")")
		return
	end
	if scriptList[id] == true then
		ScriptTracker.CSA("Looted: "..itemName)
	end
end

function ScriptTracker.CSA(text)
	local message = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
	message:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
	message:SetText(text)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(message)
end

function ScriptTracker.LootTracker()
	if ScriptTracker.savedVars.lootTacker == true then
		EVENT_MANAGER:RegisterForEvent(ScriptTracker.name.."Loot", EVENT_LOOT_RECEIVED, ScriptTracker.LootedItem)
		EVENT_MANAGER:AddFilterForEvent(ScriptTracker.name.."Loot", EVENT_LOOT_RECEIVED, REGISTER_FILTER_UNIT_TAG, "player")
	else
		EVENT_MANAGER:UnregisterForEvent(ScriptTracker.name.."Loot", EVENT_LOOT_RECEIVED, ScriptTracker.LootedItem)
	end
end

function ScriptTracker.OnItemCollected(_, bagId, slotIndex)
	local itemId = GetItemId(bagId, slotIndex)
	if itemId ~= 204881 and scriptList[itemId] == nil then
		return 
	end
	ScriptTracker.ScanInventories()
	ScriptTracker.UpdateCountsView()
end

function ScriptTracker.ItemIdToName(id)
	return zo_strformat(SI_ABILITY_NAME, GetItemLinkName("|H1:item:"..id..":124:1:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h"))
end

function ScriptTracker.IsScriptAvailable(id)
	local data = scriptItemList[id]
	return (ScriptTracker.CountItems(data.bound) + ScriptTracker.CountItems(data.unbound)) > 0
end

function ScriptTracker.GetScriptId(script)
	for id, v in pairs(scriptItemList) do
		if v.bound == script or v.unbound == script then
			return id
		end
	end
	return 0
end

function ScriptTracker.GetScriptAvailabilityText(id)
	local data = scriptItemList[id]
	local bound = ScriptTracker.CountItems(data.bound)
	local unbound = ScriptTracker.CountItems(data.unbound)
	if bound + unbound == 0 then return "" end
	local text = "\n\nInventory & Bank:\n"
	if bound > 0 then 
		text = text..ScriptTracker.ColorMessage(bound,"00ff00").."x "..ScriptTracker.ColorMessage(ScriptTracker.ItemIdToName(data.bound),"ffff00")
	end
	if unbound > 0 then 
		if bound > 0 then 
			text = text.."\n"
		end
		text = text..ScriptTracker.ColorMessage(unbound,"00ff00").."x "..ScriptTracker.ColorMessage(ScriptTracker.ItemIdToName(data.unbound),"ffff00")
	end
	return text
end

function ScriptTracker.UpdateCountsView()
	ScriptTrackerUIScribingLabel:SetText("Open Scribing ("..ScriptTracker.GetInkCount().."|t20:20:/esoui/art/icons/item_grimoire_ink.dds|t)")
end

function ScriptTracker.GetInkCount()
	local numInkInCraftingBag = GetSlotStackSize(BAG_VIRTUAL, 204881) or 0
	local numInkInBags = 0
	for _, v in pairs(ScriptTracker.savedVars.inventory.characters) do
		numInkInBags = numInkInBags + (v[204881] or 0)
	end
	local numInkInBank = ScriptTracker.savedVars.inventory.bank[204881] or 0
	return numInkInCraftingBag + numInkInBags + numInkInBank
end

function ScriptTracker.CountItems(id)
	local bank = ScriptTracker.savedVars.inventory.bank[id] or 0
	local bags = 0
	for _, v in pairs(ScriptTracker.savedVars.inventory.characters) do
		bags = bags + (v[id] or 0)
	end
	return bank + bags
end

function ScriptTracker.ScanInventories()
	ScriptTracker.savedVars.inventory.bank = {}
	ScriptTracker.savedVars.inventory.characters[GetCurrentCharacterId()] = {}
	ScriptTracker.Scan(ScriptTracker.savedVars.inventory.bank, BAG_BANK)
	ScriptTracker.Scan(ScriptTracker.savedVars.inventory.bank, BAG_SUBSCRIBER_BANK)
	ScriptTracker.Scan(ScriptTracker.savedVars.inventory.characters[GetCurrentCharacterId()], BAG_BACKPACK)
end

function ScriptTracker.Scan(savedVars, bagId)
	for i = 0, GetBagSize(bagId) do
		local id = GetItemId(bagId, i)
		if scriptList[id] == true or id == 204881 then
			local size = GetSlotStackSize(bagId, i)
			savedVars[id] = (savedVars[id] or 0) + size
		end
	end
end

local function OnAddOnLoaded(_, addonName)
	if (addonName ~= ScriptTracker.name) then return end
	
	ScriptTracker.savedVars = ZO_SavedVars:NewAccountWide("ScriptTracker_Data", 1, nil, {
		chatButton = true,
		lootTacker = false,
		tooltip = true,
		devmode = false,
		hideUnlocked = false,
		gamepadtooltip = false,
		left = nil,
		top = nil,
		width = nil,
		height = nil,
		charData = {},
		inventory = {
			bank = {},
			characters = {}
		},
		fav = {},
		scenes = {
			scribingLibraryKeyboard = true,
			scribingKeyboard = true
		},
		hiddenChars = {},
		textsize = 20
	}, GetWorldName())

	local hidecheckbox = WINDOW_MANAGER:CreateControlFromVirtual("ScriptTrackerUIHideCheckBox", ScriptTrackerUI, "ScriptTrackerUICheckbox")
	hidecheckbox:SetDimensions(30, 30)
	hidecheckbox:SetAnchor(BOTTOMLEFT, ScriptTrackerUI, BOTTOMLEFT, 0, 0)
	ZO_CheckButton_SetLabelText(hidecheckbox, "Hide unlocked scripts")
	ZO_CheckButton_SetCheckState(hidecheckbox, ScriptTracker.savedVars.hideUnlocked == true)
	ZO_CheckButton_SetToggleFunction(
		hidecheckbox,
		function()
			ScriptTracker.savedVars.hideUnlocked = ZO_CheckButton_IsChecked(hidecheckbox) == true
			ScriptTracker.RefreshScriptList(1)
			ScriptTracker.RefreshScriptList(2)
			ScriptTracker.RefreshScriptList(3)
		end
	)
	ScriptTracker.InitList()
	ScriptTracker.UpdateSavedVars()
	ScriptTracker.UpdateUIFontSize()
	
	ScriptTrackerUI:ClearAnchors()
	if ScriptTracker.savedVars.left == nil then
		ScriptTrackerUI:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		ScriptTrackerUI:SetDimensions(600, 450)
		ScriptTracker.OnUIMove()
	else
		ScriptTrackerUI:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, ScriptTracker.savedVars.left or 0, ScriptTracker.savedVars.top or 0)
		ScriptTrackerUI:SetDimensions(ScriptTracker.savedVars.width or 600, ScriptTracker.savedVars.height or 450)
	end
	
	EVENT_MANAGER:UnregisterForEvent(ScriptTracker.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent(ScriptTracker.name.."Tracker", EVENT_CRAFTED_ABILITY_SCRIPT_LOCK_STATE_CHANGED, ScriptTracker.ScanCharacter)
	EVENT_MANAGER:RegisterForEvent(ScriptTracker.name.."BagTracker", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, ScriptTracker.OnItemCollected)
	ScriptTracker.ScanInventories()

	ToolTip(ItemTooltip, "SetAttachedMailItem", GetAttachedItemLink)
	ToolTip(ItemTooltip, "SetBagItem", GetItemLink)
	ToolTip(ItemTooltip, "SetBuybackItem", GetBuybackItemLink)
	ToolTip(ItemTooltip, "SetLootItem", GetLootItemLink)
	ToolTip(ItemTooltip, "SetTradeItem", GetTradeItemLink)
	ToolTip(ItemTooltip, "SetStoreItem", GetStoreItemLink)
	ToolTip(ItemTooltip, "SetTradingHouseListing", GetTradingHouseListingItemLink)
	ToolTip(ItemTooltip, "SetQuestReward", GetQuestRewardItemLink)
	ToolTip(PopupTooltip, "SetLink", function(item) 
		return item 
	end)
	if ScriptTracker.savedVars.gamepadtooltip == true then
		GamePadToolTip(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_LEFT_TOOLTIP), "LayoutItem", function(item) 
			return item
		end)
		GamePadToolTip(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_RIGHT_TOOLTIP), "LayoutItem", function(item) 
			return item 
		end)
		GamePadToolTip(GAMEPAD_TOOLTIPS:GetTooltip(GAMEPAD_MOVABLE_TOOLTIP), "LayoutItem", function(item) 
			return item 
		end)
	end
	
	SCENE_MANAGER:RegisterCallback("SceneStateChanged", sceneChange)

	ScriptTracker.UIResize()

	ZO_CreateStringId("SI_BINDING_NAME_Open",  "Open ScriptTracker")

	ScriptTracker.LootTracker()

	if LibChatMenuButton ~= nil then
		ScriptTracker.chatButton = LibChatMenuButton.addChatButton("ScriptTrackerChatButton", GetCraftedAbilityScriptIcon(1), "Script Tracker", function()
			ScriptTracker.OpenWindow(ScriptTrackerUI:IsHidden())
		end)
		if ScriptTracker.savedVars.chatButton == true then
			ScriptTracker.chatButton:show()
		else
			ScriptTracker.chatButton:hide()
		end
	end

	ScriptTracker.ScanCharacter()
	ScriptTracker.UpdateCountsView()
	ScriptTracker.Settings()
	if akaUpdater and akaUpdater.init then 
		akaUpdater.init(ScriptTracker)
	end
end

EVENT_MANAGER:RegisterForEvent(ScriptTracker.name, EVENT_ADD_ON_LOADED, OnAddOnLoaded)

function ScriptTracker.Settings()
	local panelData = {
		type = "panel",
		name = ScriptTracker.name,
		displayName = "Script Tracker",
		author = "akamatsu02",
		registerForRefresh = true
	}

	LibAddonMenu2:RegisterAddonPanel(ScriptTracker.name.." - Options", panelData)

	local options = {}

	table.insert(options, {
		type = "checkbox",
		name = "Enable gamepad tooltip (beta) (needs reload)",
		tooltip = "This feature has been tested, but doesn't seem to work for everyone.",
		getFunc = function() 
			return ScriptTracker.savedVars.gamepadtooltip
		end,
		setFunc = function(value) 
			ScriptTracker.savedVars.gamepadtooltip = value
		end
	})

	table.insert(options, {
		type = "checkbox",
		name = "Track loot",
		tooltip = "Notifies you about looted scripts and ink",
		getFunc = function() 
			return ScriptTracker.savedVars.lootTacker 
		end,
		setFunc = function(value) 
			ScriptTracker.savedVars.lootTacker = value
			ScriptTracker.LootTracker()
		end
	})

	table.insert(options, {
		type = "checkbox",
		name = "Show tooltip",
		tooltip = "Show the item tooltip in your inventory",
		getFunc = function() 
			return ScriptTracker.savedVars.tooltip 
		end,
		setFunc = function(value) 
			ScriptTracker.savedVars.tooltip = value
		end
	})

	if LibChatMenuButton ~= nil then
		table.insert(options, {
			type = "checkbox",
			name = "Enable Chat-Button",
			tooltip = "Enable Chat-Button from LibChatMenuButton",
			getFunc = function() 
				return ScriptTracker.savedVars.chatButton
			end,
			setFunc = function(value) 
				ScriptTracker.savedVars.chatButton = value
				if ScriptTracker.savedVars.chatButton == true then
					ScriptTracker.chatButton:show()
				else
					ScriptTracker.chatButton:hide()
				end
			end
		})
	end

	table.insert(options, {
		type = "dropdown",
		name = "Text size",
		tooltip = "Size of the text-labels in the addon",
		choices = {12,14,16,18,20,22,24,26},
		getFunc = function() return ScriptTracker.savedVars.textsize end,
		setFunc = function(var) 
			var = tonumber(var) or 20
			ScriptTracker.savedVars.textsize = var
			ScriptTracker.UpdateUIFontSize()
		end
	})

	table.insert(options, {
		type = "divider",
		height = 10,
		alpha = 0.5,
		width = "full"
	})

	table.insert(options, {
		type = "dropdown",
		name = "Show/Hide character",
		tooltip = "Select a character to show/hide it from the list",
		choices = ScriptTracker.GetCharsForSettings(),
		getFunc = function() return ScriptTracker.toRemove or "" end,
		setFunc = function(var) 
			ScriptTracker.toRemove = var
		end
	})

	table.insert(options, {
		type = "button",
		name = "Select",
		tooltip = "Select a character to show/hide it from the list",
		func = function() 
			if ScriptTracker.toRemove == nil then return end
			ScriptTracker.ToggleCharVisibility(ScriptTracker.toRemove)
			ScriptTracker.toRemove = nil
		end
	})
	
	LibAddonMenu2:RegisterOptionControls(ScriptTracker.name.." - Options", options)
end d=d

--delete duplicate chars
--/script local cd=ScriptTracker.savedVars.charData;for k,v in pairs(cd or {})do if v.name==GetUnitName("player")then cd[k]=nil end end ScriptTracker.ScanCharacter()