OHH = OHH or {}
local OHH = OHH

OHH.name 		= "OdyHybridHeal"
OHH.version 	= "1.8.3"
OHH.author 		= "@Lamierina7"
OHH.interval 	= 100
OHH.fade        = 0.3
OHH.boss		= nil
OHH.yolna 		= false
OHH.debug       = false
OHH.activated   = false
OHH.player		= zo_strformat( SI_UNIT_NAME, GetUnitName( "player" ) )
OHH.events		= GetEventManager()
OHH.window 		= GetWindowManager()

OHH.groupSize   = 0
OHH.group       = { }
OHH.panels      = { }
OHH.groupL      = { }
OHH.groupR      = { }
OHH.groupBak    = { }

-- debouncing
OHH.debounceItems = false
OHH.debounceSlots = false
OHH.debounceDelay = 500

-- markarth: new common berserk buff is 61744, old combat prayer specific buff was 62636
local PANEL_BERSERK = 61744
local PANEL_WIDTH   = 110
local PANEL_HEIGHT  = 25
local PANEL_PADDING = 5
local PANEL_RIGHT   = PANEL_WIDTH + PANEL_HEIGHT * 2 + 6

local TRACKCHOICES = {
	"None",
	"Major Courage",
	"Major Slayer",
	"Powerful Assault",
	"Empower",
}

local DEFAULTS = {
	-- procs
	["UseZen"]              = true,
	["UseMartial"]          = true,
	["UsePowerful"]         = true,
	["UseOlorime"]          = true,
	["TrackOlorimeSides"]   = "Never",
	["UseWinter"]           = true,
	["UseHiti"]             = true,
	["UseKyne"]             = true,
	["UseOverflow"]         = true,
	["UseOpportunist"]      = true,
	["TrackOpportunist"]    = "Player affected",
	-- buffs
	["TrackSwarm"]          = true,
	["TrackOffBalance"]     = false,
	-- cp
	["TrackMinorBerserk"]   = false,
	["TrackUnitsBuffed"]	= false,
	["TrackTopType"]    	= "Major Courage",
	["TrackTopCol"]			= { 0.75, 0.75, 0 },
	["TrackBotType"]		= "Major Slayer",
	["TrackBotCol"]			= { 0.75, 0, 0 },
	["TrackLineHeight"]		= 2,
	-- sustain
	["TrackResourceReturn"] = false,
}

local HOTBARS = {
	[HOTBAR_CATEGORY_PRIMARY] = true,
	[HOTBAR_CATEGORY_BACKUP]  = true,
}

local MAJORSLAYER = {
	[93109]  = true,
	[93120]  = true,
	[93442]  = true,
	[121871] = true,
	[135923] = true,
	[137986] = true,
}

local MAJORCOURAGE = {
	[66902]  = true,
	[109966] = true,
	[109994] = true,
	[110020] = true,
	[120015] = true,
}

local EMPOWER = GetAbilityName( 61737 )

local SUSTAINWIDTH  = 240
local DETAILSPACING = 2
local DETAILHEIGHT  = 15
local DETAILHEAD    = 120
local DETAILWIDTH   = ( SUSTAINWIDTH - DETAILHEAD - 2 ) / 2
local DETAILMAX     = 5	-- how many different sets at same time

local SUSTAINSENTINAL   = "Sentinel of Rkugamz"
local SUSTAINSYMPHONY   = "Meridia's Favor"
local SUSTAINMASTER     = "Grand Rejuvenation"
local SUSTAINVATESHRAN  = "Force Overflow"
local SUSTAINKYNE       = "Kyne's Wind"
local SUSTAINHOLLOWFANG = "Hollowfang Thirst"

local SUSTAINMODEOVERALL = 1
local SUSTAINMODEAVERAGE = 2

local SUSTAINSOURCES = {
	-- rkugamz
	[81041]  = SUSTAINSENTINAL,		-- stamina
	[133239] = SUSTAINSENTINAL,		-- magicka
	-- symphony
	[117119] = SUSTAINSYMPHONY,		-- stamina
	[117118] = SUSTAINSYMPHONY,		-- magicka
	-- master resto
	[99781]  = SUSTAINMASTER,		-- stamina
	[131489] = SUSTAINMASTER,		-- magicka
	-- vateshran resto (beam hits other player)
	[147879] = SUSTAINVATESHRAN,	-- stamina
	[147873] = SUSTAINVATESHRAN,	-- magicka
	-- vateshran resto (buff on caster)
	[149877] = SUSTAINVATESHRAN,	-- stamina
	[149878] = SUSTAINVATESHRAN,	-- magicka
	-- kyne's wind
	[137993] = SUSTAINKYNE,			-- stamina
	[137996] = SUSTAINKYNE,			-- magicka
	-- hollowfang
	[126938] = SUSTAINHOLLOWFANG,	-- magicka
}

local SUSTAINBUFFER = {
	mode    = SUSTAINMODEOVERALL,
	open    = false,
	use     = false,
	start   = 0,
	dur     = 0,
	stam    = 0,
	mag     = 0,
	targets = { },
	sources = {
		[SUSTAINSENTINAL] = {
			stam    = 0,
			mag     = 0,
			targets = { },
			sets    = {
				"|H1:item:94757:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h",
			},
		},
		[SUSTAINSYMPHONY] = {
			stam    = 0,
			mag     = 0,
			targets = { },
			sets    = {
				"|H1:item:147243:364:50:0:0:0:0:0:0:0:0:0:0:0:1:67:0:1:0:10000:0|h|h",
			},
		},
		[SUSTAINHOLLOWFANG] = {
			stam    = 0,
			mag     = 0,
			targets = { },
			sets    = {
				"|H1:item:152539:364:50:0:0:0:0:0:0:0:0:0:0:0:1:93:0:1:0:0:0|h|h",
			},
		},
		[SUSTAINMASTER] = {
			stam    = 0,
			mag     = 0,
			targets = { },
			sets    = {
				-- perfected
				-- "|H1:item:166064:364:50:0:0:0:0:0:0:0:0:0:0:0:1:1:0:1:0:498:0|h|h",
				[166064] = true,
				[166081] = true,
				[166098] = true,
				[166115] = true,
				[166132] = true,
				[166149] = true,
				[166166] = true,
				[166184] = true,
				-- normal
				-- "|H1:item:133793:364:50:0:0:0:0:0:0:0:0:0:0:0:1:1:0:1:0:500:0|h|h",
				[133793] = true,
				[133810] = true,
				[133827] = true,
				[133844] = true,
				[133861] = true,
				[133878] = true,
				[133895] = true,
				[133929] = true,
				-- old normal?
				[55939]  = true,
				[55969]  = true,
				[55975]  = true,
				[55981]  = true,
				[55987]  = true,
				[55993]  = true,
				[55999]  = true,
			},
		},
		[SUSTAINVATESHRAN] = {
			stam    = 0,
			mag     = 0,
			targets = { },
		},
		[SUSTAINKYNE] = {
			stam    = 0,
			mag     = 0,
			targets = { },
		},
	},
}

local FORCEOVERFLOW = {
	gui    = nil,
	win    = nil,
	frag   = nil,
	use    = nil,
	broken = false,
	active = false,
	finish = 0,
	cd     = 10,
	id     = 147872,
	icon   = "esoui/art/icons/achievement_u28_arena_meta.dds",
	sets   = {
		-- perfected
		-- "|H1:item:170010:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:474:0|h|h",
		[170010] = true,
		[170027] = true,
		[170044] = true,
		[170061] = true,
		[170078] = true,
		[170094] = true,
		[170110] = true,
		[170127] = true,
		-- normal
		-- "|H1:item:169891:364:50:0:0:0:0:0:0:0:0:0:0:0:1:10:0:1:0:500:0|h|h",
		[169891] = true,
		[169908] = true,
		[169925] = true,
		[169942] = true,
		[169959] = true,
		[169976] = true,
		[169993] = true,
	}
}

local HITI = {
	gui    = nil,
	win    = nil,
	frag   = nil,
	use    = nil,
	active = false,
	finsih = 0,
	lost   = 2,
	cd     = 12,
	id     = 133210, 
	sets   = {
		"|H1:item:156890:364:50:0:0:0:0:0:0:0:0:0:0:0:1:97:0:1:0:10000:0|h|h",
	}
}

local ZEN = {
	gui    = nil,
	win    = nil,
	frag   = nil,
	use    = nil,
	curcd  = 0,
	debuff = 126597,
	sets   = {
		"|H1:item:153094:363:50:0:0:0:0:0:0:0:0:0:0:0:1:89:0:1:0:0:0|h|h",
	},
}

local MARTIAL = {
	gui    = nil,
	win    = nil,
	frag   = nil,
	use    = nil,
	active = false,
	finish = 0,
	tick   = 0,
	curcd  = 0,
	cd     = 8,
	debuff = 127070,
	sets   = {
		"|H1:item:95453:363:50:0:0:0:0:0:0:0:0:0:0:0:1:35:0:1:0:0:0|h|h",
	},
}

local OLORIME = {
	gui     = nil,
	win     = nil,
	frag    = nil,
	use     = nil,
	left    = true,
	active  = false,
	finish  = 0,
	cd      = 10,
	proc    = 107141,
	perfect = 109084,
	sets    = {
		-- olorime
		"|H1:item:137323:364:50:0:0:0:30:0:0:0:0:0:0:0:1:73:0:1:0:0:0|h|h",
		-- perfected olorime
		"|H1:item:138580:363:50:0:0:0:0:0:0:0:0:0:0:0:1:73:0:1:0:10000:0|h|h",
	},
}

local RESPITE = {
	gui    = nil,
	win    = nil,
	frag   = nil,
	use    = nil,
	active = false,
	finish = 0,
	cd     = 10,
	icon   = 135658,
	proc   = 135659,
	sets   = {
		"|H1:item:160668:364:50:0:0:0:0:0:0:0:0:0:0:0:1:100:0:1:0:10000:0|h|h",
	},
}

local POWERFUL = {
	gui    = nil,
	win    = nil,
	frag   = nil,
	use    = nil,
	active = false,
	finish = 0,
	cd     = 10,
	id     = 61771,
	sets   = {
		"|H1:item:117178:364:50:26591:370:50:0:0:0:0:0:0:0:0:1:24:0:1:0:426:0|h|h",
	},
}

local KYNE = {
	gui     = nil,
	win     = nil,
	frag    = nil,
	use     = nil,
	active  = false,
	finish  = 0,
	cdreg   = 4,
	cd      = 10,
	icon    = "esoui/art/icons/ability_healer_015.dds",
	proc    = 136098,
	perfect = 137995,
	sets    = {
		-- kynes wind
		"|H1:item:162374:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
		-- perfected kynes wind
		"|H1:item:162917:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
	},
}

local OPPORTUNIST = {
	gui     = nil,
	win     = nil,
	frag    = nil,
	use     = nil,
	active  = false,
	finish  = 0,
	nobuff  = 0,
	cd      = 22,
	proc    = 135923,
	perfect = 137986,
	sets    = {
		-- roaring opportunist
		"|H1:item:161965:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
		-- perfected roaring opportunist
		"|H1:item:162508:364:50:0:0:0:0:0:0:0:0:0:0:0:1:0:0:1:0:0:0|h|h",
	},
	debuff  = {
		last  = 0,
		total = 0,
		cd    = 22,
		ids   = {
			[135924] = true,
			[137985] = true,
		}
	}
}

local SWARM = {
	gui     = nil,
	win     = nil,
	frag    = nil,
	use     = nil,
	curcd   = 0,
	icon    = 86023,
	skills  = {
		[86023] = true, -- swarm
		[86027] = true, -- fetcher infection
		[86031] = true, -- growing swarm
	},
	debuffs = {
		[101703] = true, -- swarm
		[101904] = true, -- fetcher infection
		[101944] = true, -- growing swarm
	},
}

local OFFBALANCE = {
	gui    = nil,
	win    = nil,
	frag   = nil,
	curcd  = 0,
	cd     = 22,
	icon   = 131562,
	immune = 134599,
	name   = GetAbilityName( 131562 ),
}

local PROCMENUITEMS = {
	{ "Z'en's Redress",           "Zen",         ZEN.debuff,       nil },
	{ "Way of Martial Knowledge", "Martial",     MARTIAL.debuff,   nil },
	{ "Powerful Assault",         "Powerful",    POWERFUL.id,      nil },
	{ "Vestment of Olorime",      "Olorime",     OLORIME.proc,     nil },
	{ "Winter's Respite",         "Winter",      RESPITE.icon,     nil },
	{ "Hiti's Hearth",            "Hiti",        HITI.id,          nil },
	{ "Kyne's Wind",              "Kyne",        nil,              KYNE.icon },
	{ "Force Overflow",           "Overflow",    nil,              FORCEOVERFLOW.icon },
	{ "Roaring Opportunist",      "Opportunist", OPPORTUNIST.proc, nil },
}

local function d( msg )
	if OHH.debug then
		_G["d"]( "[OHH] " .. msg )
	end
end

local function getTime( finish )
	return zo_max( 0, finish - GetGameTimeMilliseconds() / 1000 )
end

local function tableRemove( arr, val )
	local idx = 0
	for i = 1, #arr do
		if arr[i] == val then
			idx = i
			break
		end
	end
	if idx ~= 0 then
		table.remove( arr, idx )
	end
end

local function tableAppend( tab, add )
	for _, v in ipairs( add ) do
		table.insert( tab, v )
	end
end

local function tableLength( tab, min )
	min = min or 0
	local len = 0
	for key, val in pairs( tab ) do
		len = len + 1
	end
	return zo_max( min, len )
end

local function getStamina()
	local cur, _, max = GetUnitPower( "player", POWERTYPE_STAMINA )
	return max > 0 and 100 * cur / max or 0
end

local function isSetEquipped( sets, num )
	num = num or 3
	for i, set in pairs( sets ) do
		local hasSet, setName, numBonuses, numEquipped, maxEquipped = GetItemLinkSetInfo( set, true )
		if numEquipped >= num then
			-- debug
			-- d( setName .. " has=" .. tostring( hasSet ) .. " numEquipped=" .. numEquipped .. " maxEquipped=" .. maxEquipped )
			return true
		end
	end
	return false
end

local function isWeaponEquipped( ids )
	return ids[GetItemId( BAG_WORN, EQUIP_SLOT_MAIN_HAND )] or ids[GetItemId( BAG_WORN, EQUIP_SLOT_BACKUP_MAIN )]
end

local function isSkillSlotted( skills )
	for hotbar in pairs( HOTBARS ) do
		for i = 1, 5 do
			local slot = ACTION_BAR_ASSIGNMENT_MANAGER:GetHotbar( hotbar ):GetSlotData( ACTION_BAR_FIRST_NORMAL_SLOT_INDEX + i )
			if slot.skillData and slot.skillData.currentMorphSlot then
				local morph   = slot.skillData.currentMorphSlot
				local ability = nil
				for key, skill in pairs( slot.skillData.skillProgressions ) do
					if skill.skillProgressionKey == morph then
						ability = skill.abilityId
						break
					end
				end
				if ability then
					-- debug output
					-- d( "HOTBAR " .. hotbar .. " SLOT " .. i .. ": [" .. ability .. "] <" .. GetAbilityName( ability ) .. ">" )
					if skills[ability] then
						return true
					end
				end
			end
		end
	end
	return false
end

local function isUnitBuffed( unit, id, name )
	local num   = GetNumBuffs( unit )
	local found = false
	for i = 1, num do
		local buffName, start, finish, slot, stacks, icon, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo( unit, i )
		if ( id and id == abilityId ) or ( name and name == buffName ) then
			return {
				["start"]  = start,
				["finish"] = finish,
			}
		end
	end
	return false
end

function OHH.OnItemSlotUpdate()
-- function OHH.OnItemSlotUpdate( eventCode, bagId, slotId, isNewItem, itemSound, updateReason, countChange )
-- 	if bagId == 0 then
		local sentinel      = isSetEquipped( SUSTAINBUFFER.sources[SUSTAINSENTINAL].sets, 2 )
		local symphony      = isSetEquipped( SUSTAINBUFFER.sources[SUSTAINSYMPHONY].sets, 2 )
		local hollowfang    = isSetEquipped( SUSTAINBUFFER.sources[SUSTAINHOLLOWFANG].sets )
		local masterresto   = isWeaponEquipped( SUSTAINBUFFER.sources[SUSTAINMASTER].sets )
		local overflow      = isWeaponEquipped( FORCEOVERFLOW.sets )
		local hasKyne       = isSetEquipped( KYNE.sets )

		local zen           = isSetEquipped( ZEN.sets ) and OHH.store.UseZen
		local martial       = isSetEquipped( MARTIAL.sets ) and OHH.store.UseMartial
		local powerful      = isSetEquipped( POWERFUL.sets ) and OHH.store.UsePowerful
		local olorime       = isSetEquipped( OLORIME.sets ) and OHH.store.UseOlorime
		local respite       = isSetEquipped( RESPITE.sets ) and OHH.store.UseWinter
		local hiti          = isSetEquipped( HITI.sets ) and OHH.store.UseHiti
		local opportunist   = isSetEquipped( OPPORTUNIST.sets ) and OHH.store.UseOpportunist
		local kyne          = hasKyne and OHH.store.UseKyne
		local forceoverflow = overflow and OHH.store.UseOverflow

		local hasSustainSet = sentinel or symphony or hollowfang or masterresto or overflow or hasKyne
		local trackSustain  = OHH.store.TrackResourceReturn and hasSustainSet

		SUSTAINBUFFER.use = trackSustain
		SUSTAINBUFFER.gui.ctrl:SetHidden( not trackSustain )

		if zen ~= ZEN.use then
			ZEN.use = zen

			if zen then
				HUD_UI_SCENE:AddFragment( ZEN.frag )
				HUD_SCENE:AddFragment( ZEN.frag )
			else
				HUD_UI_SCENE:RemoveFragment( ZEN.frag )
				HUD_SCENE:RemoveFragment( ZEN.frag )
			end

			-- debug
			d( "Z'en " .. ( zen and "" or "not " ) .. "equipped" )
		end

		if martial ~= MARTIAL.use then
			MARTIAL.use = martial

			if martial then
				HUD_UI_SCENE:AddFragment( MARTIAL.frag )
				HUD_SCENE:AddFragment( MARTIAL.frag )
			else
				HUD_UI_SCENE:RemoveFragment( MARTIAL.frag )
				HUD_SCENE:RemoveFragment( MARTIAL.frag )
			end

			-- debug
			d( "Martial Knowledge " .. ( martial and "" or "not " ) .. "equipped" )
		end

		if powerful ~= POWERFUL.use then
			POWERFUL.use = powerful

			if powerful then
				HUD_UI_SCENE:AddFragment( POWERFUL.frag )
				HUD_SCENE:AddFragment( POWERFUL.frag )
			else
				HUD_UI_SCENE:RemoveFragment( POWERFUL.frag )
				HUD_SCENE:RemoveFragment( POWERFUL.frag )
			end

			-- debug
			d( "Powerful Assault " .. ( powerful and "" or "not " ) .. "equipped" )
		end

		if olorime ~= OLORIME.use then
			OLORIME.use = olorime

			if olorime then
				HUD_UI_SCENE:AddFragment( OLORIME.frag )
				HUD_SCENE:AddFragment( OLORIME.frag )
			else
				HUD_UI_SCENE:RemoveFragment( OLORIME.frag )
				HUD_SCENE:RemoveFragment( OLORIME.frag )
			end

			-- debug
			d( "Olorime " .. ( olorime and "" or "not " ) .. "equipped" )
		end

		if respite ~= RESPITE.use then
			RESPITE.use = respite

			if respite then
				HUD_UI_SCENE:AddFragment( RESPITE.frag )
				HUD_SCENE:AddFragment( RESPITE.frag )
			else
				HUD_UI_SCENE:RemoveFragment( RESPITE.frag )
				HUD_SCENE:RemoveFragment( RESPITE.frag )
			end

			-- debug
			d( "Winter's Respite " .. ( respite and "" or "not " ) .. "equipped" )
		end

		if hiti ~= HITI.use then
			HITI.use = hiti

			if hiti then
				HUD_UI_SCENE:AddFragment( HITI.frag )
				HUD_SCENE:AddFragment( HITI.frag )
			else
				HUD_UI_SCENE:RemoveFragment( HITI.frag )
				HUD_SCENE:RemoveFragment( HITI.frag )
			end

			-- debug
			d( "Hiti's Hearth " .. ( hiti and "" or "not " ) .. "equipped" )
		end

		if kyne ~= KYNE.use then
			KYNE.use = kyne

			if kyne then
				HUD_UI_SCENE:AddFragment( KYNE.frag )
				HUD_SCENE:AddFragment( KYNE.frag )
			else
				HUD_UI_SCENE:RemoveFragment( KYNE.frag )
				HUD_SCENE:RemoveFragment( KYNE.frag )
			end

			-- debug
			d( "Kyne's Wind " .. ( kyne and "" or "not " ) .. "equipped" )
		end

		if opportunist ~= OPPORTUNIST.use then
			OPPORTUNIST.use = opportunist

			if opportunist then
				HUD_UI_SCENE:AddFragment( OPPORTUNIST.frag )
				HUD_SCENE:AddFragment( OPPORTUNIST.frag )
			else
				HUD_UI_SCENE:RemoveFragment( OPPORTUNIST.frag )
				HUD_SCENE:RemoveFragment( OPPORTUNIST.frag )
			end

			-- debug
			d( "Opportunist " .. ( opportunist and "" or "not " ) .. "equipped" )
		end

		if forceoverflow ~= FORCEOVERFLOW.use then
			FORCEOVERFLOW.use = forceoverflow

			if forceoverflow then
				HUD_UI_SCENE:AddFragment( FORCEOVERFLOW.frag )
				HUD_SCENE:AddFragment( FORCEOVERFLOW.frag )
			else
				HUD_UI_SCENE:RemoveFragment( FORCEOVERFLOW.frag )
				HUD_SCENE:RemoveFragment( FORCEOVERFLOW.frag )
			end

			-- debug
			d( "Force Overflow " .. ( forceoverflow and "" or "not " ) .. "equipped" )
		end
	-- end
end

function OHH.OnSkillSlotUpdate()
-- function OHH.OnSkillSlotUpdate( eventCode, actionSlotIndex )
	local swarm = isSkillSlotted( SWARM.skills ) and OHH.store.TrackSwarm

	if swarm ~= SWARM.use then
		SWARM.use = swarm

		if swarm then
			HUD_UI_SCENE:AddFragment( SWARM.frag )
			HUD_SCENE:AddFragment( SWARM.frag )
		else
			HUD_UI_SCENE:RemoveFragment( SWARM.frag )
			HUD_SCENE:RemoveFragment( SWARM.frag )
		end

		-- debug
		d( "Swarm " .. ( swarm and "" or "not " ) .. "slotted" )
	end
end

function OHH.OnPanelUpdate()
	local units  = zo_max( #OHH.groupL, #OHH.groupR )
	local height = units + units * PANEL_HEIGHT
	local width  = PANEL_WIDTH + PANEL_HEIGHT + 1
	if #OHH.groupR >= 1 then
		width = 4 + 2 * ( PANEL_WIDTH + PANEL_HEIGHT + 1 )
	end

	OHH.panelButton:SetHidden( units <= 0 )
	OHH.panelWin:SetDimensions( width, height )
	OHH.panelCtrl:SetDimensions( width, height )
end

function OHH.OnPanelMove( left, idx )
	local unit = OHH.panels[idx].tag
	local name = OHH.group[unit].name

	OHH.groupBak[name] = not left
	OHH.panels[idx].left:SetHidden( left )
	OHH.panels[idx].right:SetHidden( not left )

	if left then
		tableRemove( OHH.groupR, unit )
		OHH.panels[idx].ctrl:ClearAnchors()
		OHH.panels[idx].ctrl:SetAnchor( TOPLEFT, OHH.panelCtrl, TOPLEFT, 0, #OHH.groupL + #OHH.groupL * PANEL_HEIGHT )
		table.insert( OHH.groupL, unit )
		if #OHH.groupR >= 1 then
			for i = 1, #OHH.groupR do
				local tag   = OHH.groupR[i]
				local panel = OHH.group[tag].panel
				panel.ctrl:ClearAnchors()
				panel.ctrl:SetAnchor( TOPLEFT, OHH.panelCtrl, TOPLEFT, PANEL_RIGHT, ( i - 1 ) + ( i - 1 ) * PANEL_HEIGHT )
			end
		end
	else
		tableRemove( OHH.groupL, unit )
		OHH.panels[idx].ctrl:ClearAnchors()
		OHH.panels[idx].ctrl:SetAnchor( TOPLEFT, OHH.panelCtrl, TOPLEFT, PANEL_RIGHT, #OHH.groupR + #OHH.groupR * PANEL_HEIGHT )
		table.insert( OHH.groupR, unit )
		if #OHH.groupL >= 1 then
			for i = 1, #OHH.groupL do
				local tag   = OHH.groupL[i]
				local panel = OHH.group[tag].panel
				panel.ctrl:ClearAnchors()
				panel.ctrl:SetAnchor( TOPLEFT, OHH.panelCtrl, TOPLEFT, 0, ( i - 1 ) + ( i - 1 ) * PANEL_HEIGHT )
			end
		end
	end

	OHH.OnPanelUpdate()
end

function OHH.BuildGroup()
	OHH.groupSize = GetGroupSize()
	OHH.group     = { }
	OHH.groupL    = { }
	OHH.groupR    = { }

	for i = 1, GROUP_SIZE_MAX do
		if i <= OHH.groupSize then
			local tag  = GetGroupUnitTagByIndex( i )
			local unit = GetUnitDisplayName( tag )
			
			OHH.group[tag] = {
				name  = unit,
				role  = GetGroupMemberSelectedRole( tag ),
				panel = OHH.panels[i],
			}

			if OHH.group[tag].role == LFG_ROLE_DPS then
				OHH.panels[i].name:SetText( unit )
				OHH.panels[i].ctrl:SetHidden( false )
				
				OHH.panels[i].tag    = tag
				OHH.panels[i].inuse  = true
				OHH.panels[i].finish = 0
				OHH.panels[i].bar:SetValue( 0 )

				-- TODO: check for major slayer, major courage, powerful assault and empower
				local buff = isUnitBuffed( tag, PANEL_BERSERK, nil )
				if buff then
					local total = ( buff.finish - buff.start ) * 1000
					local cur   = buff.finish * 1000 - GetGameTimeMilliseconds()

					OHH.panels[i].total  = total
					OHH.panels[i].finish = buff.finish * 1000
					OHH.panels[i].bar:SetValue( zo_min( 1, zo_max( 0, cur ) / total ) )
				end

				-- local num = GetNumBuffs( tag )
				-- for j = 1, num do
				-- 	local buffName, start, finish, slot, stacks, icon, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo( tag, j )
				-- 	if abilityId == PANEL_BERSERK then
				-- 		local total = ( finish - start ) * 1000
				-- 		local cur   = finish * 1000 - GetGameTimeMilliseconds()

				-- 		OHH.panels[i].total  = total
				-- 		OHH.panels[i].finish = finish * 1000
				-- 		OHH.panels[i].bar:SetValue( zo_min( 1, zo_max( 0, cur ) / total ) )

				-- 		break
				-- 	end
				-- end

				local right = OHH.groupBak[unit]
				OHH.panels[i].ctrl:ClearAnchors()
				OHH.panels[i].ctrl:SetAnchor( TOPLEFT, OHH.panelCtrl, TOPLEFT, right and PANEL_RIGHT or 0, right and ( #OHH.groupR + #OHH.groupR * PANEL_HEIGHT ) or ( #OHH.groupL + #OHH.groupL * PANEL_HEIGHT ) )
				OHH.panels[i].left:SetHidden( not right )
				OHH.panels[i].right:SetHidden( right )
				table.insert( right and OHH.groupR or OHH.groupL, tag )
			else
				OHH.panels[i].inuse = false
				OHH.panels[i].bar:SetValue( 0 )
				OHH.panels[i].ctrl:SetHidden( true )
			end
		else
			OHH.panels[i].inuse = false
			OHH.panels[i].bar:SetValue( 0 )
			OHH.panels[i].ctrl:SetHidden( true )
		end
	end

	OHH.OnPanelUpdate()
end

function OHH.OnGroupUpdate( eventCode )
	zo_callLater( OHH.BuildGroup, 500 )
end

function OHH.ResetSustainBuffer()
	SUSTAINBUFFER.stam    = 0
	SUSTAINBUFFER.mag     = 0
	SUSTAINBUFFER.targets = { }

	for source, data in pairs( SUSTAINBUFFER.sources ) do
		data.stam    = 0
		data.mag     = 0
		data.targets = { }
	end
end

function OHH.OnEffectChanged( eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceType )
	-- debug
	-- d( "type=" .. changeType .. " name=" .. effectName .. " id=" .. abilityId .. " source=" .. sourceType )

	if abilityId == FORCEOVERFLOW.id and sourceType == COMBAT_UNIT_TYPE_PLAYER then
		if changeType == EFFECT_RESULT_GAINED then
			local runTime = endTime - beginTime

			FORCEOVERFLOW.active = true
			FORCEOVERFLOW.broken = false
			FORCEOVERFLOW.finish = endTime

			FORCEOVERFLOW.gui.timer:SetText( string.format( "%.1f", runTime ) )
			FORCEOVERFLOW.gui.border:SetEdgeColor( 0, 1, 0, 1 )

			FORCEOVERFLOW.gui.cd:ResetCooldown()
			FORCEOVERFLOW.gui.cd:SetHidden( false )
			FORCEOVERFLOW.gui.cd:StartCooldown( runTime * 1000, FORCEOVERFLOW.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )

			d( "Force Overflow gained" )
		elseif changeType == EFFECT_RESULT_FADED then
			if FORCEOVERFLOW.active then
				FORCEOVERFLOW.broken = true
			end

			d( "Force Overflow faded" )
		end
	end

	if OHH.group[unitTag] and changeType ~= EFFECT_RESULT_FADED then
		-- powerful assault
		if abilityId == POWERFUL.id then
			local et  = endTime * 1000
			local tot = ( endTime - beginTime ) * 1000
			local cur = et - GetGameTimeMilliseconds()

			OHH.group[unitTag].panel.pa.finish = et
			OHH.group[unitTag].panel.pa.total  = tot
		-- unit is DD
		elseif OHH.group[unitTag].role == LFG_ROLE_DPS then
			-- minor berserk
			if abilityId == PANEL_BERSERK then
				local total = ( endTime - beginTime ) * 1000
				local cur   = endTime * 1000 - GetGameTimeMilliseconds()

				OHH.group[unitTag].panel.total  = total
				OHH.group[unitTag].panel.finish = endTime * 1000
				OHH.group[unitTag].panel.bar:SetValue( zo_min( 1, zo_max( 0, cur ) / total ) )
			-- major slayer
			elseif MAJORSLAYER[abilityId] then
				local et  = endTime * 1000
				local tot = ( endTime - beginTime ) * 1000
				local cur = et - GetGameTimeMilliseconds()
				
				OHH.group[unitTag].panel.ms.finish = et
				OHH.group[unitTag].panel.ms.total  = tot
			-- major courage
			elseif MAJORCOURAGE[abilityId] then
				local et  = endTime * 1000
				local tot = ( endTime - beginTime ) * 1000
				local cur = et - GetGameTimeMilliseconds()
				
				OHH.group[unitTag].panel.mc.finish = et
				OHH.group[unitTag].panel.mc.total  = tot
			end
		end
	end
end

function OHH.OnCombatEvent( _, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId )
	-- debug
	-- d( "type=" .. result .. " name=" .. abilityName .. " id=" .. abilityId .. " power=" .. powerType .. " damage=" .. damageType .. " hit=" .. hitValue .. " source=" .. zo_strformat( SI_UNIT_NAME, sourceName ) .. " target=" .. zo_strformat( SI_UNIT_NAME, targetName ) )
	-- if result == ACTION_RESULT_POWER_ENERGIZE and SUSTAINSOURCES[abilityId] then
	-- 	_G["d"]( "type=" .. tostring( SUSTAINSOURCES[abilityId] ) .. " power=" .. powerType .. " id=" .. abilityId .. " name=" .. abilityName .. " source=" .. zo_strformat( SI_UNIT_NAME, sourceName ) .. " target=" .. zo_strformat( SI_UNIT_NAME, targetName ) .. " val=" .. hitValue .. " mine=" .. tostring( playerCasted or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET ) .. " combat=" .. tostring( combat ) )
	-- end

	local playerCasted   = zo_strformat( SI_UNIT_NAME, sourceName ) == OHH.player
	local playerTarget   = zo_strformat( SI_UNIT_NAME, targetName )
	local playerAffected = playerTarget == OHH.player
	local now            = GetGameTimeMilliseconds() / 1000
	local combat         = IsUnitInCombat( "player" )

	-- if playerCasted and playerTarget == OHH.player then
	-- 	_G["d"]( "result=" .. result .. " id=" .. abilityId .. " name=" .. tostring( abilityName ) )
	-- end

	-- debug resource return
	-- if ( playerCasted or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET ) and result == ACTION_RESULT_POWER_ENERGIZE and hitValue > 0 then
	-- 	local dbg = "|cffffff" .. playerTarget .. "|r gains "
	-- 	dbg = dbg .. ( powerType == POWERTYPE_MAGICKA and "|c7f7fff" or "|c00ff00" )
	-- 	dbg = dbg .. hitValue .. "|r " .. ( powerType == POWERTYPE_MAGICKA and "mag" or "stam" ) .. " from |cff00ff" .. abilityName .. "|r (id=" .. abilityId .. ")"
	-- 	_G["d"]( dbg )
	-- end

	if combat and ( playerCasted or sourceType == COMBAT_UNIT_TYPE_PLAYER_PET ) and result == ACTION_RESULT_POWER_ENERGIZE and SUSTAINSOURCES[abilityId] and hitValue > 0 then
		if SUSTAINBUFFER.start == 0 then
			OHH.ResetSustainBuffer()
			SUSTAINBUFFER.start = now
			SUSTAINBUFFER.dur   = 0
		end

		local source = SUSTAINBUFFER.sources[SUSTAINSOURCES[abilityId]]
		local type   = powerType == POWERTYPE_MAGICKA and "mag" or ( powerType == POWERTYPE_STAMINA and "stam" or nil )

		if type then
			-- local dbg = "|cffffff" .. playerTarget .. "|r gains "
			-- dbg = dbg .. ( powerType == POWERTYPE_MAGICKA and "|c7f7fff" or "|c00ff00" )
			-- dbg = dbg .. hitValue .. "|r " .. type .. " from |cff00ff" .. abilityName .. "|r (id=" .. abilityId .. ", type=" .. SUSTAINSOURCES[abilityId] .. ")"
			-- _G["d"]( dbg )

			SUSTAINBUFFER[type] = SUSTAINBUFFER[type] + hitValue
			source[type]        = source[type] + hitValue

			if not SUSTAINBUFFER.targets[playerTarget] then
				SUSTAINBUFFER.targets[playerTarget] = {
					stam = 0,
					mag  = 0,
				}
			end
			SUSTAINBUFFER.targets[playerTarget][type] = SUSTAINBUFFER.targets[playerTarget][type] + hitValue

			if not source.targets[playerTarget] then
				source.targets[playerTarget] = {
					stam = 0,
					mag  = 0,
				}
			end
			source.targets[playerTarget][type] = source.targets[playerTarget][type] + hitValue
		end
	end

	if result == ACTION_RESULT_EFFECT_GAINED_DURATION and ( abilityId == OPPORTUNIST.proc or abilityId == OPPORTUNIST.perfect ) then

		-- Roaring Opportunist
		d( "Roaring Opportunist procced, source = " .. zo_strformat( SI_UNIT_NAME, sourceName ) .. ", target=" .. zo_strformat( SI_UNIT_NAME, targetName ) .. ", duration=" .. string.format( "%.3f", hitValue / 1000 ) )

		if now > OPPORTUNIST.finish and ( ( OHH.store.TrackOpportunist == "Player affected" and playerAffected ) or ( OHH.store.TrackOpportunist == "Player casted" and playerCasted ) or ( OHH.store.TrackOpportunist == "Both" and playerAffected and playerCasted ) ) then
			local endTime = now + hitValue / 1000
			
			OPPORTUNIST.active = true
			OPPORTUNIST.finish = endTime
			OPPORTUNIST.nobuff = now + OPPORTUNIST.cd

			OPPORTUNIST.gui.timer:SetText( string.format( "%.1f", endTime - now ) )
			OPPORTUNIST.gui.border:SetEdgeColor( 0, 1, 0, 1 )

			OPPORTUNIST.gui.cd:ResetCooldown()
			OPPORTUNIST.gui.cd:SetHidden( false )
			OPPORTUNIST.gui.cd:StartCooldown( OPPORTUNIST.cd * 1000, OPPORTUNIST.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )

			d( "Roaring Opportunist tracking started" )
		end
	end

	if OPPORTUNIST.debuff.ids[abilityId] then
		if result == ACTION_RESULT_EFFECT_GAINED then
			OPPORTUNIST.debuff.last  = OPPORTUNIST.debuff.cd + now
			OPPORTUNIST.debuff.total = OPPORTUNIST.debuff.total + 1
			-- _G["d"]( playerTarget .. " gained Opportunist Cooldown" )
		elseif result == ACTION_RESULT_EFFECT_FADED then
			OPPORTUNIST.debuff.total = zo_max( 0, OPPORTUNIST.debuff.total - 1 )
			-- _G["d"]( playerTarget .. " lost Opportunist Cooldown" )
		end
	end

	-- Powerful Assault
	if abilityId == POWERFUL.id and result == ACTION_RESULT_EFFECT_GAINED and playerCasted and playerAffected then
		POWERFUL.active = true
		POWERFUL.finish = POWERFUL.cd + now

		POWERFUL.gui.timer:SetText( POWERFUL.cd .. ".0" )
		POWERFUL.gui.border:SetEdgeColor( 0, 1, 0, 1 )

		POWERFUL.gui.cd:ResetCooldown()
		POWERFUL.gui.cd:SetHidden( false )
		POWERFUL.gui.cd:StartCooldown( POWERFUL.cd * 1000, POWERFUL.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )

		d( "Powerful Assault procced" )
	end

	if result == ACTION_RESULT_EFFECT_GAINED and playerCasted then

		-- Kyne's Wind
		if abilityId == KYNE.proc or abilityId == KYNE.perfect then
			if KYNE.finish - now < KYNE.cd - KYNE.cdreg then
				KYNE.active = true
				KYNE.finish = KYNE.cd + now

				KYNE.gui.timer:SetText( KYNE.cd .. ".0" )
				KYNE.gui.border:SetEdgeColor( 0, 1, 0, 1 )

				KYNE.gui.cd:ResetCooldown()
				KYNE.gui.cd:SetHidden( false )
				KYNE.gui.cd:StartCooldown( KYNE.cd * 1000, KYNE.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )

				d( "Kyne's Wind procced" )
			end
		end

		-- Olorime
		if abilityId == OLORIME.proc or abilityId == OLORIME.perfect then
			OLORIME.active = true
			OLORIME.left   = not OLORIME.left
			OLORIME.finish = OLORIME.cd + now

			OLORIME.gui.timer:SetText( OLORIME.cd .. ".0" )
			OLORIME.gui.border:SetEdgeColor( 0, 1, 0, 1 )

			OLORIME.gui.cd:ResetCooldown()
			OLORIME.gui.cd:SetHidden( false )
			OLORIME.gui.cd:StartCooldown( OLORIME.cd * 1000, OLORIME.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )

			d( "Olorime procced" )
		end

		-- Winter's Respite
		if abilityId == RESPITE.proc then
			RESPITE.active = true
			RESPITE.finish = RESPITE.cd + now

			RESPITE.gui.timer:SetText( RESPITE.cd .. ".0" )
			RESPITE.gui.border:SetEdgeColor( 0, 1, 0, 1 )

			RESPITE.gui.cd:ResetCooldown()
			RESPITE.gui.cd:SetHidden( false )
			RESPITE.gui.cd:StartCooldown( RESPITE.cd * 1000, RESPITE.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )

			d( "Winter's Repsite procced" )
		end

		-- Hiti's Hearth
		if abilityId == HITI.id then
			HITI.active = true
			HITI.finish = HITI.cd + now

			HITI.gui.timer:SetText( HITI.cd .. ".0" )
			HITI.gui.border:SetEdgeColor( 0, 1, 0, 1 )

			HITI.gui.cd:ResetCooldown()
			HITI.gui.cd:SetHidden( false )
			HITI.gui.cd:StartCooldown( HITI.cd * 1000, HITI.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )

			d( "Hiti's Hearth procced" )
		end
	end
end

function OHH.ToggleSustainDetails()
	local toggle       = not SUSTAINBUFFER.open
	SUSTAINBUFFER.open = toggle
	SUSTAINBUFFER.gui.details:SetHidden( not toggle )
	SUSTAINBUFFER.toggle:SetTexture( "odyhybridheal/icons/" .. ( toggle and "caret_up.dds" or "caret_down.dds" ) )
end

function OHH.PaintSustainDetails()
	for i = 1, DETAILMAX do
		local source = SUSTAINBUFFER.gui.sources[i]
		source.container:SetHidden( i ~= 1 )
		source.colTarget:GetParent():SetHidden( true )
		source.colStam:GetParent():SetHidden( true )
		source.colMag:GetParent():SetHidden( true )
	end

	local panel = 0
	for type, data in pairs( SUSTAINBUFFER.sources ) do
		if data.stam > 0 or data.mag > 0 then
			panel = panel + 1
			if panel > DETAILMAX then
				break
			end

			local source = SUSTAINBUFFER.gui.sources[panel]
			source.container:SetHidden( false )
			source.colTitle:SetText( type )
			source.colStamTotal:SetText( data.stam )
			source.colMagTotal:SetText( data.mag )

			local num        = 0
			local strTargets = ""
			local strStam    = ""
			local strMag     = ""

			if SUSTAINBUFFER.mode == SUSTAINMODEOVERALL then
				for target, res in pairs( data.targets ) do
					local nl   = num > 0 and "\n" or ""
					strTargets = strTargets .. nl .. target
					strStam    = strStam .. nl .. res.stam
					strMag     = strMag .. nl .. res.mag
					num        = num + 1
				end
			else
				local targets = tableLength( data.targets )
				num           = 1
				strTargets    = "Average for " .. targets .. " Target" .. ( targets > 1 and "s" or "" )
				strStam       = zo_round( data.stam / targets )
				strMag        = zo_round( data.mag / targets )
			end

			source.colTarget:SetText( strTargets )
			source.colTarget:GetParent():SetHidden( false )
			source.colTarget:GetParent():SetDimensions( DETAILHEAD, DETAILHEIGHT * num + DETAILSPACING * ( num - 1 ) )
			
			source.colStam:SetText( strStam )
			source.colStam:GetParent():SetHidden( false )
			source.colStam:GetParent():SetDimensions( DETAILWIDTH, DETAILHEIGHT * num + DETAILSPACING * ( num - 1 ) )

			source.colMag:SetText( strMag )
			source.colMag:GetParent():SetHidden( false )
			source.colMag:GetParent():SetDimensions( DETAILWIDTH, DETAILHEIGHT * num + DETAILSPACING * ( num - 1 ) )
		end
	end

	if panel == 0 then
		SUSTAINBUFFER.gui.sources[1].colTitle:SetText( "No resources returned" )
	end
end

function OHH.PrintSustainStats()
	-- local num = GetGroupSize() > 0 and GetGroupSize() or 1
	-- local num = #SUSTAINBUFFER.targets > 0 and #SUSTAINBUFFER.targets or 1
	local num = tableLength( SUSTAINBUFFER.targets, 1 )
	local dur = SUSTAINBUFFER.dur ~= 0 and SUSTAINBUFFER.dur or ( SUSTAINBUFFER.start ~= 0 and GetGameTimeMilliseconds() / 1000 - SUSTAINBUFFER.start or 1 )

	local out = "|cffffff[OHH]|r Resources restored"
	if num > 1 then
		out = out .. "\n |cff00ffAverage|r "
		out = out .. "|c00ff00" .. string.format( "%.1f", SUSTAINBUFFER.stam / num ) .. "|r tot / |c00ff00" .. string.format( "%.1f", SUSTAINBUFFER.stam / num / dur ) .. "|r sps "
		out = out .. "|c7f7fff" .. string.format( "%.1f", SUSTAINBUFFER.mag / num )  .. "|r tot / |c7f7fff" .. string.format( "%.1f", SUSTAINBUFFER.mag  / num / dur ) .. "|r mps"
	end
	out = out .. "\n |cff00ffOverall|r "
	out = out .. "|c00ff00" .. SUSTAINBUFFER.stam .. "|r tot / |c00ff00" .. string.format( "%.1f", SUSTAINBUFFER.stam / dur ) .. "|r sps "
	out = out .. "|c7f7fff" .. SUSTAINBUFFER.mag  .. "|r tot / |c7f7fff" .. string.format( "%.1f", SUSTAINBUFFER.mag  / dur ) .. "|r mps"
	for target, res in pairs( SUSTAINBUFFER.targets ) do
		out = out .. "\n- " .. target .. " "
		out = out .. "|c00ff00" .. res.stam .. "|r tot / |c00ff00" .. string.format( "%.1f", res.stam / dur ) .. "|r sps "
		out = out .. "|c7f7fff" .. res.mag  .. "|r tot / |c7f7fff" .. string.format( "%.1f", res.mag  / dur ) .. "|r mps"
	end
	for source, data in pairs( SUSTAINBUFFER.sources ) do
		if data.stam > 0 or data.mag > 0 then
			out = out .. "\n |cff00ff" .. source .. "|r "
			out = out .. "|c00ff00" .. data.stam .. "|r tot / |c00ff00" .. string.format( "%.1f", data.stam / dur ) .. "|r sps "
			out = out .. "|c7f7fff" .. data.mag  .. "|r tot / |c7f7fff" .. string.format( "%.1f", data.mag  / dur ) .. "|r mps"
			for target, res in pairs( data.targets ) do
				out = out .. "\n- " .. target .. " "
				out = out .. "|c00ff00" .. res.stam .. "|r tot / |c00ff00" .. string.format( "%.1f", res.stam / dur ) .. "|r sps "
				out = out .. "|c7f7fff" .. res.mag  .. "|r tot / |c7f7fff" .. string.format( "%.1f", res.mag  / dur ) .. "|r mps"
			end
		end
	end
	_G["d"]( out )
end

function OHH.OnCombatState( _, inCombat )
	if not inCombat then
		OLORIME.left        = true
		SUSTAINBUFFER.dur   = GetGameTimeMilliseconds() / 1000 - SUSTAINBUFFER.start
		SUSTAINBUFFER.start = 0
	else
		if SUSTAINBUFFER.start == 0 then
			OHH.ResetSustainBuffer()
			SUSTAINBUFFER.start = GetGameTimeMilliseconds() / 1000
			SUSTAINBUFFER.dur   = 0
		end
	end
end

function OHH.OnBossChanged()
	local boss1 = GetUnitName( "boss1" )
	local boss2 = GetUnitName( "boss2" )
	local boss  = boss1 ~= nil and boss1 ~= "" and ( boss2 == nil or boss2 == "" )
	
	if OHH.boss ~= boss then
		-- debug
		d( ( boss and "B" or "No b" ) .. "oss detected" .. ( boss and " [" .. boss1 .. "]" or "" ) )
	end

	OHH.boss = boss

	if OHH.store.TrackOlorimeSides == "Never" then
		OHH.yolna = false
	elseif OHH.store.TrackOlorimeSides == "Always" then
		OHH.yolna = true
	else
		OHH.yolna = boss and string.lower( boss1 ) == "yolnahkriin" or false
	end
end

function OHH.OnUpdate()
	-- number of players buffed
	local ddTot = 0
	local paTot = 0
	local paDD  = 0
	local mcDD  = 0
	local msDD  = 0
	local mbDD  = 0
	local emDD  = 0
	-- extra bars for cp tracker
	local paBar = OHH.store.TrackTopType == "Powerful Assault" and "top" or ( OHH.store.TrackBotType == "Powerful Assault" and "bot" or nil )
	local mcBar = OHH.store.TrackTopType == "Major Courage" and "top" or ( OHH.store.TrackBotType == "Major Courage" and "bot" or nil )
	local msBar = OHH.store.TrackTopType == "Major Slayer" and "top" or ( OHH.store.TrackBotType == "Major Slayer" and "bot" or nil )
	local emBar = OHH.store.TrackTopType == "Empower" and "top" or ( OHH.store.TrackBotType == "Empower" and "bot" or nil )

	if OHH.store.TrackMinorBerserk then
		for i = 1, GROUP_SIZE_MAX do
			-- reset extra bars
			OHH.panels[i].top:SetValue( 0 )
			OHH.panels[i].bot:SetValue( 0 )

			-- powerful assault
			if OHH.panels[i].pa.finish > 0 then
				local cur = OHH.panels[i].pa.finish - GetGameTimeMilliseconds()
				if cur <= 0 then
					OHH.panels[i].pa.finish = 0
				else
					if paBar then
						OHH.panels[i][paBar]:SetValue( zo_min( 1, cur / OHH.panels[i].pa.total ) )
						paDD = paDD + ( OHH.panels[i].inuse and 1 or 0 )
					end
					paTot = paTot + 1
				end
			end

			-- active panel (unit is DD)
			if OHH.panels[i].inuse then
				ddTot = ddTot + 1

				-- minor berserk
				if OHH.panels[i].finish > 0 then
					local cur = OHH.panels[i].finish - GetGameTimeMilliseconds()
					if cur <= 0 then
						OHH.panels[i].finish = 0
						OHH.panels[i].bar:SetValue( 0 )
					else
						OHH.panels[i].bar:SetValue( zo_min( 1, cur / OHH.panels[i].total ) )
						mbDD = mbDD + 1
					end
				end
				-- major courage
				if OHH.panels[i].mc.finish > 0 then
					local cur = OHH.panels[i].mc.finish - GetGameTimeMilliseconds()
					if cur <= 0 then
						OHH.panels[i].mc.finish = 0
					elseif mcBar then
						OHH.panels[i][mcBar]:SetValue( zo_min( 1, cur / OHH.panels[i].mc.total ) )
						mcDD = mcDD + 1
					end
				end
				-- major slayer
				if OHH.panels[i].ms.finish > 0 then
					local cur = OHH.panels[i].ms.finish - GetGameTimeMilliseconds()
					if cur <= 0 then
						OHH.panels[i].ms.finish = 0
					elseif msBar then
						OHH.panels[i][msBar]:SetValue( zo_min( 1, cur / OHH.panels[i].ms.total ) )
						msDD = msDD + 1
					end
				end
				-- empower
				if emBar then
					local buff = isUnitBuffed( OHH.panels[i].tag, nil, EMPOWER )
					if buff then
						OHH.panels[i].em.finish = buff.finish * 1000
						OHH.panels[i].em.total  = ( buff.finish - buff.start ) * 1000
					end

					if OHH.panels[i].em.finish > 0 then
						local cur = OHH.panels[i].em.finish - GetGameTimeMilliseconds()
						if cur <= 0 then
							OHH.panels[i].em.finish = 0
						else
							OHH.panels[i][emBar]:SetValue( zo_min( 1, cur / OHH.panels[i].em.total ) )
							emDD = emDD + 1
						end
					end
				end
			end
		end

		OHH.panelFrac[1].ctrl:SetHidden( not ( OHH.store.TrackUnitsBuffed and ddTot > 0 ) )
		OHH.panelFrac[1].label:SetText( mbDD .. "/" .. ddTot )

		local nextBar = 2
		if OHH.store.TrackTopType ~= "None" then
			local num = paBar == "top" and paDD or ( msBar == "top" and msDD or ( mcBar == "top" and mcDD or ( emBar == "top" and emDD or 0 ) ) )
			OHH.panelFrac[nextBar].bar:SetCenterColor( OHH.store.TrackTopCol[1], OHH.store.TrackTopCol[2], OHH.store.TrackTopCol[3], 1 )
			OHH.panelFrac[nextBar].ctrl:SetHidden( not ( OHH.store.TrackUnitsBuffed and ddTot > 0 ) )
			OHH.panelFrac[nextBar].label:SetText( num .. "/" .. ddTot )	
			nextBar = nextBar + 1
		end
		if OHH.store.TrackBotType ~= "None" then
			local num = paBar == "bot" and paDD or ( msBar == "bot" and msDD or ( mcBar == "bot" and mcDD or ( emBar == "bot" and emDD or 0 ) ) )
			OHH.panelFrac[nextBar].bar:SetCenterColor( OHH.store.TrackBotCol[1], OHH.store.TrackBotCol[2], OHH.store.TrackBotCol[3], 1 )
			OHH.panelFrac[nextBar].ctrl:SetHidden( not ( OHH.store.TrackUnitsBuffed and ddTot > 0 ) )
			OHH.panelFrac[nextBar].label:SetText( num .. "/" .. ddTot )	
			nextBar = nextBar + 1
		end
		while nextBar < 4 do
			OHH.panelFrac[nextBar].ctrl:SetHidden( true )
			nextBar = nextBar + 1
		end
	end

	if SUSTAINBUFFER.use then
		-- local num = #SUSTAINBUFFER.targets > 0 and #SUSTAINBUFFER.targets or 1
		local num = tableLength( SUSTAINBUFFER.targets, 1 )
		local dur = SUSTAINBUFFER.dur ~= 0 and SUSTAINBUFFER.dur or ( SUSTAINBUFFER.start ~= 0 and GetGameTimeMilliseconds() / 1000 - SUSTAINBUFFER.start or 1 )
		local avg = SUSTAINBUFFER.mode == SUSTAINMODEAVERAGE

		SUSTAINBUFFER.gui.colTitle:SetText( avg and ( "Average resources returned " .. ( num > 1 and ( "(" .. num .. " targets)" ) or "" ) ) or "Overall resources returned" )
		SUSTAINBUFFER.gui.colStamTotal:SetText( ( avg and zo_round( SUSTAINBUFFER.stam / num ) or SUSTAINBUFFER.stam ) .. " tot" )
		SUSTAINBUFFER.gui.colStamSec:SetText( string.format( "%.1f", avg and SUSTAINBUFFER.stam / num / dur or SUSTAINBUFFER.stam / dur ) .. " sps" )
		SUSTAINBUFFER.gui.colMagTotal:SetText( ( avg and zo_round( SUSTAINBUFFER.mag / num ) or SUSTAINBUFFER.mag ) .. " tot" )
		SUSTAINBUFFER.gui.colMagSec:SetText( string.format( "%.1f", avg and SUSTAINBUFFER.mag / num / dur or SUSTAINBUFFER.mag / dur ) .. " mps" )

		if SUSTAINBUFFER.open then
			OHH.PaintSustainDetails()
		end
	end

	-- DEBUG
	-- local offname = GetAbilityName( 131562 )
	-- local mybuffs = GetNumBuffs( "player" )
	-- for i = 1, mybuffs do
	-- 	local buffName, start, finish, slot, stacks, icon, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo( "player", i )
	-- 	if buffName == offname then
	-- 		local time = getTime( finish )
	-- 		d( "OFF BALANCE (" .. abilityId .. ") " .. string.format( "%.1f", time ) )
	-- 	end
	-- 	if abilityId == 134599 then
	-- 		local time = getTime( finish )
	-- 		d( "OFF BALANCE IMMUNITY " .. string.format( "%.1f", time ) )
	-- 	end
	-- end

	-- current groupsize
	local gs = zo_max( 1, GetGroupSize() )
	-- roaring opportunist fraction
	if getTime( OPPORTUNIST.debuff.last ) <= 0 then
		OPPORTUNIST.debuff.total = 0
	end
	OPPORTUNIST.gui.debuff:SetHidden( gs <= 1 )
	OPPORTUNIST.gui.debuff:SetText( OPPORTUNIST.debuff.total .. "/" .. gs )
	-- powerful assault fraction
	POWERFUL.gui.frac:SetHidden( gs <= 1 )
	POWERFUL.gui.frac:SetText( paTot .. "/" .. gs )

	local dots   = 0
	local off    = false
	local zen    = false
	local swarm  = false
	local target = OHH.boss and "boss1" or "reticleover"
	local num    = GetNumBuffs( target )
	for i = 1, num do
		local buffName, start, finish, slot, stacks, icon, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff, castByPlayer = GetUnitBuffInfo( target, i )

		if castByPlayer and finish - start > 1 and abilityType == 1 then
			dots = dots + 1
		end

		if ZEN.debuff == abilityId and castByPlayer then
			local time = getTime( finish )

			if time > ZEN.curcd then
				ZEN.gui.cd:ResetCooldown()
				ZEN.gui.cd:SetHidden( false )
				ZEN.gui.cd:StartCooldown( time * 1000, ( finish - start ) * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
			end

			ZEN.curcd = time
			zen       = true
		end

		if MARTIAL.debuff == abilityId and castByPlayer then
			MARTIAL.finish = start + MARTIAL.cd
			MARTIAL.active = true
		end

		if SWARM.debuffs[abilityId] and castByPlayer then
			local time = getTime( finish )

			SWARM.gui.timer:SetText( string.format( "%.1f", time ) )
			SWARM.gui.border:SetEdgeColor( time < 3 and 1 or 0, time < 3 and 0.5 or 1, 0, 1 )
			if time > SWARM.curcd then
				SWARM.gui.cd:ResetCooldown()
				SWARM.gui.cd:SetHidden( false )
				SWARM.gui.cd:StartCooldown( time * 1000, ( finish - start ) * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
			end

			SWARM.curcd = time
			swarm       = true
		end

		if buffName == OFFBALANCE.name then
			local total = finish - start
			local time  = getTime( finish )
			local str   = string.format( "%.1f", time )
			local cd    = getTime( start + OFFBALANCE.cd )

			OFFBALANCE.gui.timer:SetText( str )
			OFFBALANCE.gui.border:SetEdgeColor( 0, 1, 0, 1 )
			if cd > OFFBALANCE.curcd then
				OFFBALANCE.gui.cd:ResetCooldown()
				OFFBALANCE.gui.cd:SetHidden( false )
				OFFBALANCE.gui.cd:StartCooldown( cd * 1000, OFFBALANCE.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
			end

			OFFBALANCE.curcd = cd
			off              = true
		elseif abilityId == OFFBALANCE.immune then
			local total = finish - start
			local time  = getTime( finish )
			local str   = string.format( "%.1f", time )

			OFFBALANCE.gui.timer:SetText( str )
			OFFBALANCE.gui.border:SetEdgeColor( 1, time < 3 and 0.5 or 1, 0, 1 )
			if time > OFFBALANCE.curcd then
				OFFBALANCE.gui.cd:ResetCooldown()
				OFFBALANCE.gui.cd:SetHidden( false )
				OFFBALANCE.gui.cd:StartCooldown( time * 1000, OFFBALANCE.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
			end

			OFFBALANCE.curcd = time
			off              = true
		end
	end

	if not off then
		OFFBALANCE.gui.timer:SetText( "" )
		OFFBALANCE.gui.border:SetEdgeColor( 1, 0, 0, 1 )
		OFFBALANCE.gui.cd:SetHidden( true )
		OFFBALANCE.curcd = 0
	end

	if not zen then
		ZEN.curcd = 0

		ZEN.gui.timer:SetText( "" )
		ZEN.gui.cd:SetHidden( true )
		ZEN.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	else
		ZEN.gui.timer:SetText( dots )
		ZEN.gui.border:SetEdgeColor( dots < 4 and 1 or 0, dots > 1 and 1 or 0.5, 0, 1 )
	end

	local stam = zo_floor( getStamina() )
	MARTIAL.gui.stamval:SetText( stam .. "%" )
	MARTIAL.gui.stambar:SetCenterColor( stam < 50 and 0 or 0.6, stam < 50 and 0.6 or 0, 0, 1 )
	MARTIAL.gui.stambar:SetDimensions( 45, stam * 62 / 100 )

	if MARTIAL.active then
		local time = getTime( MARTIAL.finish )
		if time > 0 then
			local tick = zo_ceil( time )
			if tick < MARTIAL.tick and tick < 4 and stam >= 50 then
				PlaySound( SOUNDS.DUEL_BOUNDARY_WARNING )
			end
			MARTIAL.tick = tick

			MARTIAL.gui.timer:SetText( string.format( "%.1f", time ) )
			MARTIAL.gui.border:SetEdgeColor( time < 3 and 1 or 0, time < 3 and 0.5 or 1, 0, 1 )
			
			if time > MARTIAL.curcd then
				MARTIAL.gui.cd:ResetCooldown()
				MARTIAL.gui.cd:SetHidden( false )
				MARTIAL.gui.cd:StartCooldown( time * 1000, MARTIAL.cd * 1000, CD_TYPE_RADIAL, CD_TIME_TYPE_TIME_UNTIL, false )
			end

			MARTIAL.curcd = time
		else
			MARTIAL.active = false
		end
	end

	if not MARTIAL.active then
		if MARTIAL.tick > 0 and stam >= 50 then
			PlaySound( SOUNDS.DUEL_START )
		end
		MARTIAL.tick  = 0
		MARTIAL.curcd = 0

		MARTIAL.gui.timer:SetText( "" )
		MARTIAL.gui.cd:SetHidden( true )
		MARTIAL.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end

	if not swarm then
		SWARM.curcd = 0

		SWARM.gui.timer:SetText( "" )
		SWARM.gui.cd:SetHidden( true )
		SWARM.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end
	
	if OLORIME.active then
		local time = getTime( OLORIME.finish )
		if time > 0 then
			OLORIME.gui.timer:SetText( string.format( "%.1f", time ) )
			OLORIME.gui.border:SetEdgeColor( time < 3 and 1 or 0, time < 3 and 0.5 or 1, 0, 1 )

			if time >= 3 or not OHH.yolna then
				OLORIME.gui.left:SetHidden( true )
				OLORIME.gui.right:SetHidden( true )
			else
				OLORIME.gui.left:SetHidden( not OLORIME.left )
				OLORIME.gui.left:SetColor( 1, 0.5, 0, 1 )
				OLORIME.gui.right:SetHidden( OLORIME.left )
				OLORIME.gui.right:SetColor( 1, 0.5, 0, 1 )
			end
		else
			OLORIME.active = false
		end
	end

	if not OLORIME.active then
		OLORIME.gui.timer:SetText( "" )
		OLORIME.gui.cd:SetHidden( true )
		OLORIME.gui.border:SetEdgeColor( 1, 0, 0, 1 )

		if not OHH.yolna then
			OLORIME.gui.left:SetHidden( true )
			OLORIME.gui.right:SetHidden( true )
		else
			OLORIME.gui.left:SetHidden( not OLORIME.left )
			OLORIME.gui.left:SetColor( 1, 0, 0, 1 )
			OLORIME.gui.right:SetHidden( OLORIME.left )
			OLORIME.gui.right:SetColor( 1, 0, 0, 1 )
		end
	end

	if RESPITE.active then
		local time = getTime( RESPITE.finish )
		if time > 0 then
			RESPITE.gui.timer:SetText( string.format( "%.1f", time ) )
			RESPITE.gui.border:SetEdgeColor( time < 3 and 1 or 0, time < 3 and 0.5 or 1, 0, 1 )
		else
			RESPITE.active = false
		end
	end

	if not RESPITE.active then
		RESPITE.gui.timer:SetText( "" )
		RESPITE.gui.cd:SetHidden( true )
		RESPITE.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end

	if POWERFUL.active then
		local time = getTime( POWERFUL.finish )
		if time > 0 then
			POWERFUL.gui.timer:SetText( string.format( "%.1f", time ) )
			POWERFUL.gui.border:SetEdgeColor( time < 3 and 1 or 0, time < 3 and 0.5 or 1, 0, 1 )
		else
			POWERFUL.active = false
		end
	end

	if not POWERFUL.active then
		POWERFUL.gui.timer:SetText( "" )
		POWERFUL.gui.cd:SetHidden( true )
		POWERFUL.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end

	if HITI.active then
		local time = getTime( HITI.finish )
		if time > 0 then
			HITI.gui.timer:SetText( string.format( "%.1f", time ) )
			HITI.gui.border:SetEdgeColor( time <= HITI.lost and 1 or 0, time < 3 and 0.5 or 1, 0, 1 )
		else
			HITI.active = false
		end
	end

	if not HITI.active then
		HITI.gui.timer:SetText( "" )
		HITI.gui.cd:SetHidden( true )
		HITI.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end

	if FORCEOVERFLOW.active then
		local time = getTime( FORCEOVERFLOW.finish )
		if time > 0 then
			FORCEOVERFLOW.gui.timer:SetText( string.format( "%.1f", time ) )
			FORCEOVERFLOW.gui.border:SetEdgeColor( ( time < 3 or FORCEOVERFLOW.broken ) and 1 or 0, time < 3 and 0.5 or 1, 0, 1 )
		else
			FORCEOVERFLOW.active = false
		end
	end

	if not FORCEOVERFLOW.active then
		FORCEOVERFLOW.gui.timer:SetText( "" )
		FORCEOVERFLOW.gui.cd:SetHidden( true )
		FORCEOVERFLOW.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end

	if KYNE.active then
		local time = getTime( KYNE.finish )
		if time > 0 then
			local buff = time >= KYNE.cd - KYNE.cdreg
			KYNE.gui.timer:SetText( string.format( "%.1f", time ) )
			KYNE.gui.border:SetEdgeColor( buff and 0 or 1, time < 3 and 0.5 or 1, 0, 1 )
		else
			KYNE.active = false
		end
	end

	if not KYNE.active then
		KYNE.gui.timer:SetText( "" )
		KYNE.gui.cd:SetHidden( true )
		KYNE.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end

	if OPPORTUNIST.active then
		local time  = getTime( OPPORTUNIST.finish )
		local total = getTime( OPPORTUNIST.nobuff )
		if time > 0 then
			OPPORTUNIST.gui.timer:SetText( string.format( "%.1f", time ) )
			OPPORTUNIST.gui.border:SetEdgeColor( 0, 1, 0, 1 )
		elseif total > 0 then
			OPPORTUNIST.gui.timer:SetText( string.format( "%.1f", total ) )
			OPPORTUNIST.gui.border:SetEdgeColor( 1, total < 3 and 0.5 or 1, 0, 1 )
		else
			OPPORTUNIST.active = false
		end
	end

	if not OPPORTUNIST.active then
		OPPORTUNIST.gui.timer:SetText( "" )
		OPPORTUNIST.gui.cd:SetHidden( true )
		OPPORTUNIST.gui.border:SetEdgeColor( 1, 0, 0, 1 )
	end
end

function OHH.CreateMini( name, parent, offset, id, texture, hidden, showborder )
	local ctrl = OHH.window:CreateControl( name, parent, CT_CONTROL )
	ctrl:ClearAnchors()
	ctrl:SetAnchor( TOPLEFT, parent, TOPLEFT, 66 * offset, 0 )
	ctrl:SetDimensions( 50, 50 )
	ctrl:SetHidden( hidden )

	local border = OHH.window:CreateControl( name .. "Border", ctrl, CT_BACKDROP )
	border:ClearAnchors()
	border:SetAnchor( TOPLEFT, ctrl, TOPLEFT, -6, -6 )
	border:SetDimensions( 62, 62 )
	border:SetEdgeColor( 1, 0, 0, 1 )
	border:SetCenterColor( 0, 0, 0, 0 )
	border:SetEdgeTexture( nil, 2, 2, 4, 0 )
	border:SetHidden( not showborder )

	local back = OHH.window:CreateControl( name .. "Back", ctrl, CT_BACKDROP )
	back:ClearAnchors()
	back:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
	back:SetDimensions( 50, 50 )
	back:SetEdgeColor( 0, 0, 0, 0 )
	back:SetCenterColor( 0, 0, 0, 1 )

	local icon = OHH.window:CreateControl( name .. "Icon", ctrl, CT_TEXTURE )
	icon:SetTexture( texture and texture or GetAbilityIcon( id ) )
	icon:ClearAnchors()
	icon:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
	icon:SetAlpha( OHH.fade )
	icon:SetDimensions( 50, 50 )

	local cd = OHH.window:CreateControl( name .. "Cooldown", ctrl, CT_COOLDOWN )
	cd:SetTexture( texture and texture or GetAbilityIcon( id ) )
	cd:ClearAnchors()
	cd:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 2, 2 )
	cd:SetDimensions( 46, 46 )

	local button = OHH.window:CreateControl( name .. "Button", ctrl, CT_TEXTURE )
	button:SetTexture( "EsoUI/Art/ActionBar/abilityFrame64_up.dds" )
	button:ClearAnchors()
	button:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
	button:SetDimensions( 50, 50 )

	local timer = OHH.window:CreateControl( name .. "Timer", ctrl, CT_LABEL )
	timer:ClearAnchors()
	timer:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
	timer:SetDimensions( 50, 50 )
	timer:SetColor( 1, 1, 1, 1 )
	timer:SetFont( "ZoFontKeyboard18ThickOutline" )
	timer:SetVerticalAlignment( TEXT_ALIGN_CENTER )
	timer:SetHorizontalAlignment( TEXT_ALIGN_CENTER )

	return {
		["ctrl"]   = ctrl,
		["icon"]   = icon,
		["border"] = border,
		["cd"]     = cd,
		["timer"]  = timer,
	}
end

function OHH.CreateSustainStats( name, parent, hidden )
	local ctrl = OHH.window:CreateControl( name, parent, CT_CONTROL )
	ctrl:ClearAnchors()
	ctrl:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	ctrl:SetDimensions( SUSTAINWIDTH, PANEL_HEIGHT * 3 + 2 )
	ctrl:SetHidden( hidden )

	local function rowButton( name, offY, tex, callback )
		local button = OHH.window:CreateControl( name, ctrl, CT_BACKDROP )
		button:ClearAnchors()
		button:SetAnchor( TOPLEFT, ctrl, TOPLEFT, SUSTAINWIDTH + 1, offY )
		button:SetDimensions( PANEL_HEIGHT, PANEL_HEIGHT )
		button:SetEdgeColor( 0, 0, 0, 0 )
		button:SetCenterColor( 0, 0, 0, 0.5 )
		button:SetMouseEnabled( true )
		button:SetHandler( "OnMouseEnter", function()
			button:SetCenterColor( 0.25, 0.25, 0.25, 0.75 )
		end )
		button:SetHandler( "OnMouseExit", function()
			button:SetCenterColor( 0, 0, 0, 0.5 )
		end )
		button:SetHandler( "OnMouseUp", callback )

		local icon = OHH.window:CreateControl( name .. "Icon", button, CT_TEXTURE )
		icon:ClearAnchors()
		icon:SetAnchor( TOPLEFT, button, TOPLEFT, 6, 6 )
		icon:SetDimensions( PANEL_HEIGHT - 12, PANEL_HEIGHT - 12 )
		icon:SetTexture( "odyhybridheal/icons/" .. tex )

		return icon
	end

	SUSTAINBUFFER.toggle = rowButton( name .. "ButtonDetails", PANEL_HEIGHT * 2 + 2, "caret_down.dds", OHH.ToggleSustainDetails )
	rowButton( name .. "ButtonSwitch", 0, "switch.dds", function() SUSTAINBUFFER.mode = SUSTAINBUFFER.mode == SUSTAINMODEOVERALL and SUSTAINMODEAVERAGE or SUSTAINMODEOVERALL end )
	rowButton( name .. "ButtonPrint", PANEL_HEIGHT + 1, "print.dds", OHH.PrintSustainStats )

	local function createCol( parent, name, width, offX, offY, black, align, text, r, g, b, font, spacing, height, hidden )
		font    = font or "ZoFontGameSmall"
		spacing = spacing or 7
		height  = height or PANEL_HEIGHT
		hidden  = hidden or false

		local back = parent:CreateControl( name, CT_BACKDROP )
		back:ClearAnchors()
		back:SetAnchor( TOPLEFT, parent, TOPLEFT, offX, offY )
		back:SetDimensions( width, height )
		back:SetEdgeColor( 0, 0, 0, 0 )
		back:SetCenterColor( black, black, black, 0.5 )
		back:SetHidden( hidden )

		local label = back:CreateControl( name .. "Label", CT_LABEL )
		label:ClearAnchors()
		label:SetAnchor( TOPLEFT, back, TOPLEFT, 2 + PANEL_PADDING, 0 )
		label:SetAnchor( BOTTOMRIGHT, back, BOTTOMRIGHT, -( 2 + PANEL_PADDING ), 0 )
		label:SetLineSpacing( spacing )
		-- label:SetDimensions( width - 4 - 2 * PANEL_PADDING, height )
		label:SetColor( 1, 1, 1, 1 )
		label:SetFont( font )
		label:SetWrapMode( TEXT_WRAP_MODE_TRUNCATE )
		label:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		label:SetHorizontalAlignment( align )
		label:SetColor( r, g, b, 1 )
		label:SetText( text )

		return label
	end

	local colWidth = ( SUSTAINWIDTH - 2 ) / 3
	createCol( ctrl, name .. "StamTitle", colWidth, 0, PANEL_HEIGHT + 1, 0, TEXT_ALIGN_LEFT, "Stamina", 1, 1, 1 )
	createCol( ctrl, name .. "MagTitle", colWidth, 0, PANEL_HEIGHT * 2 + 2, 0, TEXT_ALIGN_LEFT, "Magicka", 1, 1, 1 )

	local dFont    = "$(MEDIUM_FONT)|$(KB_10)|soft-shadow-thin"
	local details  = OHH.window:CreateControl( name .. "Details", ctrl, CT_CONTROL )
	details:ClearAnchors()
	details:SetAnchor( TOPLEFT, ctrl, BOTTOMLEFT, 0, 1 )
	-- details:SetDimensions( width, PANEL_HEIGHT * 2 + 1 )
	details:SetResizeToFitDescendents( true )
	details:SetHidden( true )

	local sources = { }
	for i = 1, DETAILMAX do
		local parent    = i == 1 and details or sources[i - 1].container
		local container = details:CreateControl( name .. "DetailsContainer" .. i, CT_CONTROL )
		container:ClearAnchors()
		container:SetAnchor( TOPLEFT, parent, i == 1 and TOPLEFT or BOTTOMLEFT, 0, i == 1 and 0 or 1 )
		-- container:SetDimensions( width, PANEL_HEIGHT * 2 + 1 )
		container:SetResizeToFitDescendents( true )
		container:SetHidden( i ~= 1 )

		sources[i] = {
			["container"] = container,
			colTitle      = createCol( container, name .. "DetailsTitle" .. i, DETAILHEAD, 0, 0, 0, TEXT_ALIGN_LEFT, "No resources returned", 1, 0, 1, dFont, DETAILSPACING, DETAILHEIGHT ),
			colStamTotal  = createCol( container, name .. "DetailsStamTotal" .. i, DETAILWIDTH, DETAILHEAD + 1, 0, 0.1, TEXT_ALIGN_RIGHT, "0", 0, 1, 0, dFont, DETAILSPACING, DETAILHEIGHT ),
			colMagTotal   = createCol( container, name .. "DetailsMagTotal" .. i, DETAILWIDTH, DETAILHEAD + DETAILWIDTH + 2, 0, 0, TEXT_ALIGN_RIGHT, "0", 0.5, 0.5, 1, dFont, DETAILSPACING, DETAILHEIGHT ),
			colTarget     = createCol( container, name .. "DetailsTarget" .. i, DETAILHEAD, 0, DETAILHEIGHT + 1, 0, TEXT_ALIGN_LEFT, "Target", 1, 1, 1, dFont, DETAILSPACING, DETAILHEIGHT, true ),
			colStam       = createCol( container, name .. "DetailsStam" .. i, DETAILWIDTH, DETAILHEAD + 1, DETAILHEIGHT + 1, 0.1, TEXT_ALIGN_RIGHT, "0", 0, 1, 0, dFont, DETAILSPACING, DETAILHEIGHT, true ),
			colMag        = createCol( container, name .. "DetailsMag" .. i, DETAILWIDTH, DETAILHEAD + DETAILWIDTH + 2, DETAILHEIGHT + 1, 0, TEXT_ALIGN_RIGHT, "0", 0.5, 0.5, 1, dFont, DETAILSPACING, DETAILHEIGHT, true ),
		}
	end

	return {
		["ctrl"]     = ctrl,
		["details"]  = details,
		["sources"]  = sources,
		colTitle     = createCol( ctrl, name .. "Title", SUSTAINWIDTH, 0, 0, 0, TEXT_ALIGN_LEFT, "Overall resources returned", 1, 0, 1 ),
		colStamTotal = createCol( ctrl, name .. "StamTotal", colWidth, colWidth + 1, PANEL_HEIGHT + 1, 0.1, TEXT_ALIGN_RIGHT, "0 tot", 0, 1, 0 ),
		colStamSec   = createCol( ctrl, name .. "StamSec", colWidth, colWidth * 2 + 2, PANEL_HEIGHT + 1, 0, TEXT_ALIGN_RIGHT, "0.0 sps", 0, 1, 0 ),
		colMagTotal  = createCol( ctrl, name .. "MagTotal", colWidth, colWidth + 1, PANEL_HEIGHT * 2 + 2, 0.1, TEXT_ALIGN_RIGHT, "0 tot", 0.5, 0.5, 1 ),
		colMagSec    = createCol( ctrl, name .. "MagSec", colWidth, colWidth * 2 + 2, PANEL_HEIGHT * 2 + 2, 0, TEXT_ALIGN_RIGHT, "0.0 mps", 0.5, 0.5, 1 ),
	}
end

function OHH.CreatePanel( name, parent, idx )
	local ctrl = OHH.window:CreateControl( name, parent, CT_CONTROL )
	ctrl:ClearAnchors()
	ctrl:SetAnchor( TOPLEFT, parent, TOPLEFT, 0, 0 )
	ctrl:SetDimensions( PANEL_WIDTH, PANEL_HEIGHT )
	ctrl:SetHidden( true )

	local back = OHH.window:CreateControl( name .. "Back", ctrl, CT_BACKDROP )
	back:ClearAnchors()
	back:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
	back:SetDimensions( PANEL_WIDTH, PANEL_HEIGHT )
	back:SetEdgeColor( 0, 0, 0, 0 )
	back:SetCenterColor( 0, 0, 0, 0.5 )

	local bar = OHH.window:CreateControl( name .. "Bar", ctrl, CT_STATUSBAR )
	bar:ClearAnchors()
	bar:SetAnchor( TOPLEFT, ctrl, TOPLEFT, PANEL_PADDING, PANEL_PADDING )
	bar:SetDimensions( PANEL_WIDTH - 2 * PANEL_PADDING, PANEL_HEIGHT - 2 * PANEL_PADDING )
	bar:SetGradientColors( 0, 0.75, 0, 1, 0, 0.75, 0, 1 )
	bar:SetMinMax( 0, 1 )
	bar:SetValue( 0 )

	local top = OHH.window:CreateControl( name .. "TopBar", ctrl, CT_STATUSBAR )
	top:ClearAnchors()
	top:SetAnchor( TOPLEFT, ctrl, TOPLEFT, PANEL_PADDING, PANEL_PADDING - 1 )
	top:SetDimensions( PANEL_WIDTH - 2 * PANEL_PADDING, OHH.store.TrackLineHeight )
	top:SetGradientColors( OHH.store.TrackTopCol[1], OHH.store.TrackTopCol[2], OHH.store.TrackTopCol[3], 1, OHH.store.TrackTopCol[1], OHH.store.TrackTopCol[2], OHH.store.TrackTopCol[3], 1 )
	top:SetMinMax( 0, 1 )
	top:SetValue( 0 )

	local bot = OHH.window:CreateControl( name .. "BottomBar", ctrl, CT_STATUSBAR )
	bot:ClearAnchors()
	bot:SetAnchor( BOTTOMLEFT, ctrl, BOTTOMLEFT, PANEL_PADDING, -PANEL_PADDING + 1 )
	bot:SetDimensions( PANEL_WIDTH - 2 * PANEL_PADDING, OHH.store.TrackLineHeight )
	bot:SetGradientColors( OHH.store.TrackBotCol[1], OHH.store.TrackBotCol[2], OHH.store.TrackBotCol[3], 1, OHH.store.TrackBotCol[1], OHH.store.TrackBotCol[2], OHH.store.TrackBotCol[3], 1 )
	bot:SetMinMax( 0, 1 )
	bot:SetValue( 0 )

	local unit = OHH.window:CreateControl( name .. "Name", ctrl, CT_LABEL )
	unit:ClearAnchors()
	unit:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 2 + PANEL_PADDING, 0 )
	unit:SetDimensions( PANEL_WIDTH - 4 - 2 * PANEL_PADDING, PANEL_HEIGHT )
	unit:SetColor( 1, 1, 1, 1 )
	unit:SetFont( "ZoFontGameSmall" )
	unit:SetWrapMode( TEXT_WRAP_MODE_TRUNCATE )
	unit:SetVerticalAlignment( TEXT_ALIGN_CENTER )

	local function panelButton( left )
		local button = OHH.window:CreateControl( name .. ( left and "Left" or "Right"), ctrl, CT_BACKDROP )
		button:ClearAnchors()
		button:SetAnchor( left and TOPRIGHT or TOPLEFT, ctrl, left and TOPLEFT or TOPRIGHT, left and -1 or 1, 0 )
		button:SetDimensions( PANEL_HEIGHT, PANEL_HEIGHT )
		button:SetEdgeColor( 0, 0, 0, 0 )
		button:SetCenterColor( 0, 0, 0, 0.5 )
		button:SetHidden( true )
		button:SetMouseEnabled( true )
		button:SetHandler( "OnMouseEnter", function()
			OHH.panels[idx][left and "left" or "right"]:SetCenterColor( 0.25, 0.25, 0.25, 0.75 )
		end )
		button:SetHandler( "OnMouseExit", function()
			OHH.panels[idx][left and "left" or "right"]:SetCenterColor( 0, 0, 0, 0.5 )
		end )
		button:SetHandler( "OnMouseUp", function()
			OHH.OnPanelMove( left, idx )
		end )

		local arr = OHH.window:CreateControl( name .. ( left and "Left" or "Right") .. "Arr", button, CT_LABEL )
		arr:ClearAnchors()
		arr:SetAnchor( TOPLEFT, button, TOPLEFT, 0, 0 )
		arr:SetDimensions( PANEL_HEIGHT, PANEL_HEIGHT )
		arr:SetColor( 1, 1, 1, 1 )
		arr:SetFont( "ZoFontGameSmall" )
		arr:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		arr:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		arr:SetText( left and "<" or ">" )

		return button
	end

	return {
		["inuse"]  = false,
		["finish"] = 0,
		["ctrl"]   = ctrl,
		["bar"]    = bar,
		["name"]   = unit,
		["left"]   = panelButton( true ),
		["right"]  = panelButton( false ),
		["top"]    = top,
		["bot"]    = bot,
		["mc"]     = {
			["finish"] = 0,
		},
		["ms"]     = {
			["finish"] = 0,
		},
		["pa"]     = {
			["finish"] = 0,
		},
		["em"]	   = {
			["finish"] = 0,
		},
	}
end

function OHH.UpdatePanelUI()
	for i = 1, GROUP_SIZE_MAX do
		-- top bar
		OHH.panels[i].top:SetDimensions( PANEL_WIDTH - 2 * PANEL_PADDING, OHH.store.TrackLineHeight )
		OHH.panels[i].top:SetGradientColors( OHH.store.TrackTopCol[1], OHH.store.TrackTopCol[2], OHH.store.TrackTopCol[3], 1, OHH.store.TrackTopCol[1], OHH.store.TrackTopCol[2], OHH.store.TrackTopCol[3], 1 )
		-- bottom bar
		OHH.panels[i].bot:SetDimensions( PANEL_WIDTH - 2 * PANEL_PADDING, OHH.store.TrackLineHeight )
		OHH.panels[i].bot:SetGradientColors( OHH.store.TrackBotCol[1], OHH.store.TrackBotCol[2], OHH.store.TrackBotCol[3], 1, OHH.store.TrackBotCol[1], OHH.store.TrackBotCol[2], OHH.store.TrackBotCol[3], 1 )
	end
end

function OHH.CreateBuffFraction( name, parent )
	local frac = OHH.window:CreateControl( name, parent, CT_LABEL )
	frac:ClearAnchors()
	frac:SetAnchor( TOPRIGHT, parent, TOPRIGHT, -3, -1 )
	frac:SetDimensions( 50, 50 )
	frac:SetColor( 1, 1, 1, 1 )
	frac:SetFont( "$(MEDIUM_FONT)|$(KB_14)|soft-shadow-thin" )
	frac:SetVerticalAlignment( TEXT_ALIGN_TOP )
	frac:SetHorizontalAlignment( TEXT_ALIGN_RIGHT )
	frac:SetHidden( true )

	return frac
end

function OHH.CreatePanelFraction( name, parent, offset )
	local width = 36

	local ctrl = OHH.window:CreateControl( name, parent, CT_CONTROL )
	ctrl:ClearAnchors()
	ctrl:SetAnchor( BOTTOMLEFT, parent, TOPLEFT, offset * ( width + 1 ), -4 )
	ctrl:SetDimensions( width, PANEL_HEIGHT )
	-- ctrl:SetHidden( false )

	local back = OHH.window:CreateControl( name .. "Back", ctrl, CT_BACKDROP )
	back:ClearAnchors()
	back:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
	back:SetDimensions( width, PANEL_HEIGHT )
	back:SetEdgeColor( 0, 0, 0, 0 )
	back:SetCenterColor( 0, 0, 0, 0.5 )

	local bar = OHH.window:CreateControl( name .. "Bar", ctrl, CT_BACKDROP )
	bar:ClearAnchors()
	bar:SetAnchor( TOPLEFT, ctrl, TOPLEFT, 0, 0 )
	bar:SetDimensions( width, 5 )
	bar:SetEdgeColor( 0, 0, 0, 0 )
	bar:SetCenterColor( 0, 1, 0, 1 )

	local label = OHH.window:CreateControl( name .. "Label", ctrl, CT_LABEL )
	label:ClearAnchors()
	label:SetAnchor( BOTTOMRIGHT, ctrl, BOTTOMRIGHT, 0, -2 )
	label:SetDimensions( width, PANEL_HEIGHT )
	label:SetColor( 1, 1, 1, 1 )
	label:SetFont( "$(MEDIUM_FONT)|$(KB_12)|soft-shadow-thin" )
	label:SetVerticalAlignment( TEXT_ALIGN_BOTTOM )
	label:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
	label:SetText( "24/24" )

	return {
		["ctrl"]  = ctrl,
		["bar"]   = bar,
		["label"] = label,
	}
end

function OHH.CreateUIWin( name, left, top, width, height, store, hidden )
	local win = OHH.window:CreateTopLevelWindow( name )
	win:SetClampedToScreen( true )
	win:SetDimensions( width, height )
	win:ClearAnchors()
	win:SetAnchor( TOPLEFT, GuiRoot, TOPLEFT, ( store and OHH.store[store] ) and OHH.store[store].left or left, ( store and OHH.store[store] ) and OHH.store[store].top or top )
	win:SetMouseEnabled( store and true or false )
	win:SetMovable( store and true or false )
	win:SetHidden( hidden )

	if store then
		win:SetHandler( "OnMoveStop", function( control )
			local x, y = control:GetScreenRect()
			OHH.store[store] = {
				["left"] = x,
				["top"]  = y,
			}
		end )
	end

	return win
end

function OHH.CreateUI()
	SUSTAINBUFFER.win  = OHH.CreateUIWin( "OHHWinSustain", 800, 345, SUSTAINWIDTH, PANEL_HEIGHT * 3 + 2, "PosSustain", false )
	SUSTAINBUFFER.gui  = OHH.CreateSustainStats( "OHHWinSustainCtrl", SUSTAINBUFFER.win, true )
	SUSTAINBUFFER.frag = ZO_HUDFadeSceneFragment:New( SUSTAINBUFFER.win )
	HUD_UI_SCENE:AddFragment( SUSTAINBUFFER.frag )
	HUD_SCENE:AddFragment( SUSTAINBUFFER.frag )

	OHH.panelWin  = OHH.CreateUIWin( "OHHWinPanels", 1300, 345, 0, 0, "PosPanels", false )
	OHH.panelFrag = ZO_HUDFadeSceneFragment:New( OHH.panelWin )
	HUD_UI_SCENE:AddFragment( OHH.panelFrag )
	HUD_SCENE:AddFragment( OHH.panelFrag )

	OHH.panelLock = true
	OHH.panelWin:SetMovable( false )

	OHH.panelCtrl = OHH.window:CreateControl( "OHHWinPanelsCtrl", OHH.panelWin, CT_CONTROL )
	OHH.panelCtrl:ClearAnchors()
	OHH.panelCtrl:SetAnchor( TOPLEFT, OHH.panelWin, TOPLEFT, 0, 0 )
	OHH.panelCtrl:SetDimensions( 0, 0 )
	OHH.panelCtrl:SetHidden( not OHH.store.TrackMinorBerserk )

	OHH.panelButton = OHH.window:CreateControl( "OHHWinPanelsLock", OHH.panelCtrl, CT_BACKDROP )
	OHH.panelButton:ClearAnchors()
	OHH.panelButton:SetAnchor( BOTTOMRIGHT, OHH.panelCtrl, TOPRIGHT, 0, -4 )
	OHH.panelButton:SetDimensions( PANEL_HEIGHT, PANEL_HEIGHT )
	OHH.panelButton:SetEdgeColor( 0, 0, 0, 0 )
	OHH.panelButton:SetCenterColor( 0, 0, 0, 0.5 )
	OHH.panelButton:SetMouseEnabled( true )
	OHH.panelButton:SetHandler( "OnMouseEnter", function()
		OHH.panelButton:SetCenterColor( 0.25, 0.25, 0.25, 0.75 )
	end )
	OHH.panelButton:SetHandler( "OnMouseExit", function()
		OHH.panelButton:SetCenterColor( 0, 0, 0, 0.5 )
	end )
	OHH.panelButton:SetHandler( "OnMouseUp", function()
		OHH.panelLock = not OHH.panelLock
		OHH.panelWin:SetMovable( not OHH.panelLock )
		OHH.panelButtonTex:SetTexture( OHH.panelLock and "odyhybridheal/icons/lock_closed.dds" or "odyhybridheal/icons/lock_open.dds" )
	end )

	OHH.panelButtonTex = OHH.window:CreateControl( "OHHWinPanelsLockIcon", OHH.panelButton, CT_TEXTURE )
	OHH.panelButtonTex:ClearAnchors()
	OHH.panelButtonTex:SetAnchor( TOPLEFT, OHH.panelButton, TOPLEFT, 4, 4 )
	OHH.panelButtonTex:SetDimensions( PANEL_HEIGHT - 8, PANEL_HEIGHT - 8 )
	OHH.panelButtonTex:SetTexture( "odyhybridheal/icons/lock_closed.dds" )

	OHH.panelFrac = {
		OHH.CreatePanelFraction( "OHHWinPanelsFrac1", OHH.panelCtrl, 0 ),
		OHH.CreatePanelFraction( "OHHWinPanelsFrac2", OHH.panelCtrl, 1 ),
		OHH.CreatePanelFraction( "OHHWinPanelsFrac3", OHH.panelCtrl, 2 ),
	}

	for i = 1, GROUP_SIZE_MAX do
		OHH.panels[i] = OHH.CreatePanel( "OHHPanel" .. i, OHH.panelCtrl, i )
	end

	RESPITE.win  = OHH.CreateUIWin( "OHHWinRespite", 1165, 275, 50, 50, "PosRespite", true )
	RESPITE.gui  = OHH.CreateMini( "OHHGuiRespite", RESPITE.win, 0, RESPITE.icon, nil, false, true )
	RESPITE.frag = ZO_HUDFadeSceneFragment:New( RESPITE.win )

	POWERFUL.win      = OHH.CreateUIWin( "OHHWinPowerful", 1095, 345, 50, 50, "PosPowerful", true )
	POWERFUL.gui      = OHH.CreateMini( "OHHGuiPowerful", POWERFUL.win, 0, POWERFUL.id, nil, false, true )
	POWERFUL.gui.frac = OHH.CreateBuffFraction( "OHHGuiPowerfulFraction", POWERFUL.gui.ctrl )
	POWERFUL.frag     = ZO_HUDFadeSceneFragment:New( POWERFUL.win )

	HITI.win  = OHH.CreateUIWin( "OHHWinHiti", 1095, 275, 50, 50, "PosHiti", true )
	HITI.gui  = OHH.CreateMini( "OHHGuiHiti", HITI.win, 0, HITI.id, nil, false, true )
	HITI.frag = ZO_HUDFadeSceneFragment:New( HITI.win )

	ZEN.win  = OHH.CreateUIWin( "OHHWinZen", 1165, 345, 50, 50, "PosZen", true )
	ZEN.gui  = OHH.CreateMini( "OHHGuiZen", ZEN.win, 0, ZEN.debuff, nil, false, true )
	ZEN.frag = ZO_HUDFadeSceneFragment:New( ZEN.win )

	MARTIAL.win  = OHH.CreateUIWin( "OHHWinMartial", 1165, 415, 50, 50, "PosMartial", true )
	MARTIAL.gui  = OHH.CreateMini( "OHHGuiMartial", MARTIAL.win, 0, MARTIAL.debuff, nil, false, true )
	MARTIAL.frag = ZO_HUDFadeSceneFragment:New( MARTIAL.win )

	OLORIME.win  = OHH.CreateUIWin( "OHHWinOlorime", 1165, 485, 50, 50, "PosOlorime", true )
	OLORIME.gui  = OHH.CreateMini( "OHHGuiOlorime", OLORIME.win, 0, OLORIME.proc, nil, false, true )
	OLORIME.frag = ZO_HUDFadeSceneFragment:New( OLORIME.win )

	SWARM.win  = OHH.CreateUIWin( "OHHWinSwarm", 1165, 555, 50, 50, "PosSwarm", true )
	SWARM.gui  = OHH.CreateMini( "OHHGuiSwarm", SWARM.win, 0, SWARM.icon, nil, false, true )
	SWARM.frag = ZO_HUDFadeSceneFragment:New( SWARM.win )

	KYNE.win  = OHH.CreateUIWin( "OHHWinKyne", 1165, 205, 50, 50, "PosKyne", true )
	KYNE.gui  = OHH.CreateMini( "OHHGuiKyne", KYNE.win, 0, KYNE.proc, KYNE.icon, false, true )
	KYNE.frag = ZO_HUDFadeSceneFragment:New( KYNE.win )

	OPPORTUNIST.win        = OHH.CreateUIWin( "OHHWinOpportunist", 1165, 625, 50, 50, "PosOpportunist", true )
	OPPORTUNIST.gui        = OHH.CreateMini( "OHHGuiOpportunist", OPPORTUNIST.win, 0, OPPORTUNIST.proc, nil, false, true )
	OPPORTUNIST.gui.debuff = OHH.CreateBuffFraction( "OHHGuiOpportunistDebuff", OPPORTUNIST.gui.ctrl )
	OPPORTUNIST.frag       = ZO_HUDFadeSceneFragment:New( OPPORTUNIST.win )

	FORCEOVERFLOW.win  = OHH.CreateUIWin( "OHHWinForceOverflow", 1095, 625, 50, 50, "PosForceOverflow", true )
	FORCEOVERFLOW.gui  = OHH.CreateMini( "OHHGuiForceOverflow", FORCEOVERFLOW.win, 0, FORCEOVERFLOW.id, FORCEOVERFLOW.icon, false, true )
	FORCEOVERFLOW.frag = ZO_HUDFadeSceneFragment:New( FORCEOVERFLOW.win )

	OFFBALANCE.win  = OHH.CreateUIWin( "OHHWinOffBalance", 1165, 695, 50, 50, "PosOffBalance", true )
	OFFBALANCE.gui  = OHH.CreateMini( "OHHGuiOffBalance", OFFBALANCE.win, 0, OFFBALANCE.icon, nil, not OHH.store.TrackOffBalance, true )
	OFFBALANCE.frag = ZO_HUDFadeSceneFragment:New( OFFBALANCE.win )
	HUD_UI_SCENE:AddFragment( OFFBALANCE.frag )
	HUD_SCENE:AddFragment( OFFBALANCE.frag )

	local left = OHH.window:CreateControl( "OHHGuiOlorimeLeft", OLORIME.gui.ctrl, CT_TEXTURE )
	left:SetTexture( "esoui/art/tutorial/smithing_leftarrow_up.dds" )
	left:ClearAnchors()
	left:SetAnchor( TOPRIGHT, OLORIME.gui.ctrl, TOPLEFT, 0, -2 )
	left:SetDimensions( 50, 50 )
	left:SetColor( 1, 0, 0, 1 )
	left:SetHidden( true )

	local right = OHH.window:CreateControl( "OHHGuiOlorimeRight", OLORIME.gui.ctrl, CT_TEXTURE )
	right:SetTexture( "esoui/art/tutorial/smithing_rightarrow_up.dds" )
	right:ClearAnchors()
	right:SetAnchor( TOPLEFT, OLORIME.gui.ctrl, TOPRIGHT, 0, 0 )
	right:SetDimensions( 50, 50 )
	right:SetColor( 1, 0, 0, 1 )
	right:SetHidden( true )

	OLORIME.gui.left  = left
	OLORIME.gui.right = right

	local function createExtraBar( name, gui, height, txt )
		local back = OHH.window:CreateControl( name .. "ExtraBack", gui.ctrl, CT_BACKDROP )
		back:ClearAnchors()
		back:SetAnchor( TOPLEFT, gui.ctrl, TOPRIGHT, 10, -6 )
		back:SetDimensions( 45, 62 )
		back:SetEdgeColor( 0, 0, 0, 0 )
		back:SetCenterColor( 0.27, 0.27, 0.27, 0.75 )

		local bar = OHH.window:CreateControl( name .. "ExtraBar", gui.ctrl, CT_BACKDROP )
		bar:ClearAnchors()
		bar:SetAnchor( BOTTOMLEFT, gui.ctrl, BOTTOMRIGHT, 10, 6 )
		bar:SetDimensions( 45, height )
		bar:SetEdgeColor( 0, 0, 0, 0 )
		bar:SetCenterColor( 0.6, 0, 0, 1 )

		local text = OHH.window:CreateControl( name .. "ExtraText", back, CT_LABEL )
		text:ClearAnchors()
		text:SetAnchor( TOPLEFT, back, TOPLEFT, 0, 0 )
		text:SetDimensions( 45, 62 )
		text:SetColor( 1, 1, 1, 1 )
		text:SetFont( "ZoFontGame" )
		text:SetVerticalAlignment( TEXT_ALIGN_CENTER )
		text:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		text:SetText( txt )

		gui.stambar = bar
		gui.stamval = text
	end

	createExtraBar( "OHHGuiMartial", MARTIAL.gui, 62, "100%" )
	-- createExtraBar( "OHHGuiOpportunist", OPPORTUNIST.gui, 0, "" )
end

function OHH.DebounceItems()
	if not OHH.debounceItems then
		OHH.debounceItems = true
		zo_callLater( function()
			OHH.OnItemSlotUpdate()
			OHH.debounceItems = false
		end, OHH.debounceDelay )
	end
end

function OHH.DebounceSlots()
	if not OHH.debounceSlots then
		OHH.debounceSlots = true
		zo_callLater( function()
			OHH.OnSkillSlotUpdate()
			OHH.debounceSlots = false
		end, OHH.debounceDelay )
	end
end

function OHH.CreateMenu()
	local panelData = {
		type				= "panel",
		name				= OHH.name,
		displayName			= OHH.name,
		author				= OHH.author,
		version				= OHH.version,
		slashCommand		= "/ohh",
		registerForRefresh	= true,
		registerForDefaults = true,
	}

	local optionsTable = {
		{
			type = "description",
			text = "Originally developed as private addon back when playing |cff00ffZ'en|r and |cff00ffMartial Knowledge|r as healer became a thing - hence the name |c00ffffHybridHeal|r - it since then has grown to a full blown toolkit for healers.",
		},
		{
			type = "description",
			text = "UI elements can be moved in mouse-mode, all settings are saved per character. Use the |cffff00/ohh|r command to open the addon settings.",
		},
		-- {
		-- 	type = "divider",
		-- },
		{
			type  = "description",
			title = "\n|cffff00SET PROCS|r",
		},
		{
			type  = "description",
			text  = "When activated, the trackers for |cff00ffZ'en's Redress|r, |cff00ffWay of Martial Knowledge|r, |cff00ffPowerful Assault|r, |cff00ffVestment of Olorime|r, |cff00ffWinter's Respite|r, |cff00ffHiti's Hearth|r, |cff00ffKyne's Wind|r and |cff00ffRoaring Opportunist|r will show automatically while wearing at least 3 pieces of the respective Item-Set. The |cff00ffForce Overflow|r tracker will show automatically when a Vateshran Restoration Staff is equipped.",
		},
		{
			type = "description",
			text = "For fights with a single boss, |cff00ffZ'en's Redress|r will be tracked for the boss itself, for trash-fights or fights with multiple bosses, the debuffs will be tracked on the targeted enemy.",
		},
	}

	for _, p in ipairs( PROCMENUITEMS ) do
		local save = "Use" .. p[2]
		local icon = p[3] and GetAbilityIcon( p[3] ) or p[4]

		table.insert( optionsTable, {
			type    = "checkbox",
			name    = "|t24:24:" .. icon .. "|t  Track " .. p[1],
			default = DEFAULTS[save],
			getFunc = function() return OHH.store[save] end,
			setFunc = function( newValue ) OHH.store[save] = newValue; OHH.OnItemSlotUpdate() end,
		} )

		if p[2] == "Olorime" then
			table.insert( optionsTable, {
				type     = "dropdown",
				name     = "|t24:24:odyhybridheal/icons/dummy.dds|t  Show side / group to proc Olorime on",
				tooltip  = "You can choose to show a little arrow next to the tracker-icon once the timer is below 3s indicating on which side / group you should proc Olorime on next. |c00ffffNever|r does not show the arrow at all, |c00ffffYolnahkriin|r only shows the arrow when fighting Yolnahkriin in Sunspire, |c00ffffAlways|r shows the arrow in every fight.",
				default  = DEFAULTS.TrackOlorimeSides,
				getFunc  = function() return OHH.store.TrackOlorimeSides end,
				setFunc  = function( newValue ) OHH.store.TrackOlorimeSides = newValue; OHH.OnBossChanged() end,
				disabled = function() return not OHH.store.UseOlorime end,
				choices  = {
					"Never",
					"Yolnahkriin",
					"Always",
				},
			} )
		elseif p[2] == "Opportunist" then
			table.insert( optionsTable, {
				type     = "dropdown",
				name     = "|t24:24:odyhybridheal/icons/dummy.dds|t  Start Roaring Opportunist when",
				tooltip  = "Select the condition which has to apply to start the Roaring Opportunist timer. |c00ffffPlayer affected|r only applies when you received the buff, |c00ffffPlayer casted|r only applies when you casted yourself, |c00ffffBoth|r only applies when you received the buff and casted yourself.",
				default  = DEFAULTS.TrackOpportunist,
				getFunc  = function() return OHH.store.TrackOpportunist end,
				setFunc  = function( newValue ) OHH.store.TrackOpportunist = newValue end,
				disabled = function() return not OHH.store.UseOpportunist end,
				choices  = {
					"Player affected",
					"Player casted",
					"Both",
				},
			} )
		end
	end

	local furtherOptions = {
		{
			type  = "description",
			title = "\n|cffff00DEBUFF TRACKER|r",
		},
		{
			type  = "description",
			text  = "When activated, the tracker for |c00ffffSwarm|r will show automatically while having the skill or it's morphs slotted on one of your skill-bars.",
		},
		{
			type = "description",
			text = "For fights with a single boss, |c00ffffSwarm|r and |c00ffffOff-Balance|r will be tracked for the boss itself, for trash-fights or fights with multiple bosses, the debuffs will be tracked on the targeted enemy.",
		},
		{
			type    = "checkbox",
			name    = "|t24:24:" .. GetAbilityIcon( SWARM.icon ) .. "|t  Track Swarm",
			default = DEFAULTS.TrackSwarm,
			getFunc = function() return OHH.store.TrackSwarm end,
			setFunc = function( newValue ) OHH.store.TrackSwarm = newValue; OHH.OnSkillSlotUpdate() end,
		},
		{
			type    = "checkbox",
			name    = "|t24:24:" .. GetAbilityIcon( OFFBALANCE.icon ) .. "|t  Track Off-Balance",
			default = DEFAULTS.TrackOffBalance,
			getFunc = function() return OHH.store.TrackOffBalance end,
			setFunc = function( newValue ) OHH.store.TrackOffBalance = newValue; OFFBALANCE.gui.ctrl:SetHidden( not newValue ) end,
		},
		{
			type  = "description",
			title = "\n|cffff00MINOR BERSERK / COMBAT PRAYER TRACKER|r",
		},
		{
			type  = "description",
			text  = "When grouped, the |c00ff00Minor Berserk|r tracker shows all |c00ffffdamage dealers|r in a list which can be split into 2 columns. Additionally the tracker can show extra bars at the top and the bottom tracking either |cff00ffMajor Courage|r, |cff00ffMajor Slayer|r, |cff00ffPowerful Assault|r or |cff00ffEmpower|r for each unit.",
		},
		{
			type  = "description",
			text  = "Use the |t16:16:odyhybridheal/icons/lock_closed.dds|t-button to unlock the window and move it into the desired position.",
		},
		{
			type    = "checkbox",
			name    = "Track Minor Berserk",
			default = DEFAULTS.TrackMinorBerserk,
			getFunc = function() return OHH.store.TrackMinorBerserk end,
			setFunc = function( newValue ) OHH.store.TrackMinorBerserk = newValue; OHH.panelCtrl:SetHidden( not newValue ) end,
		},
		{
			type     = "checkbox",
			name     = "Show number of units buffed",
			default  = DEFAULTS.TrackUnitsBuffed,
			getFunc  = function() return OHH.store.TrackUnitsBuffed end,
			setFunc  = function( newValue ) OHH.store.TrackUnitsBuffed = newValue end,
			disabled = function() return not OHH.store.TrackMinorBerserk end,
		},
		{
            type     = "slider",
            name     = "Extra bars height",
            min      = 1,
            max      = 5,
            default  = DEFAULTS.TrackLineHeight,
            getFunc  = function() return OHH.store.TrackLineHeight end,
			setFunc  = function( newValue ) OHH.store.TrackLineHeight = newValue; OHH.UpdatePanelUI() end,
			disabled = function() return not OHH.store.TrackMinorBerserk end,
        },
		{
			type     = "dropdown",
			name     = "Top bar buff to track",
			default  = DEFAULTS.TrackTopType,
			getFunc  = function() return OHH.store.TrackTopType end,
			setFunc  = function( newValue ) OHH.store.TrackTopType = newValue end,
			disabled = function() return not OHH.store.TrackMinorBerserk end,
			choices  = TRACKCHOICES,
		},
		{
            type     = "colorpicker",
            name     = "Top bar color",
            default  = { r = DEFAULTS.TrackTopCol[1], g = DEFAULTS.TrackTopCol[2], b = DEFAULTS.TrackTopCol[3] },
            getFunc  = function() return unpack( OHH.store.TrackTopCol ) end,
            setFunc  = function( r, g, b, a ) OHH.store.TrackTopCol = { r, g, b }; OHH.UpdatePanelUI() end,
            disabled = function() return not OHH.store.TrackMinorBerserk end,
		},
		{
			type     = "dropdown",
			name     = "Bottom bar buff to track",
			default  = DEFAULTS.TrackBotType,
			getFunc  = function() return OHH.store.TrackBotType end,
			setFunc  = function( newValue ) OHH.store.TrackBotType = newValue end,
			disabled = function() return not OHH.store.TrackMinorBerserk end,
			choices  = TRACKCHOICES,
		},
		{
            type     = "colorpicker",
            name     = "Bottom bar color",
            default  = { r = DEFAULTS.TrackBotCol[1], g = DEFAULTS.TrackBotCol[2], b = DEFAULTS.TrackBotCol[3] },
            getFunc  = function() return unpack( OHH.store.TrackBotCol ) end,
            setFunc  = function( r, g, b, a ) OHH.store.TrackBotCol = { r, g, b }; OHH.UpdatePanelUI() end,
            disabled = function() return not OHH.store.TrackMinorBerserk end,
		},
		{
			type  = "description",
			title = "\n|cffff00RESOURCE RETURN STATISTICS|r",
		},
		{
			type  = "description",
			text  = "When activated, the |c00ffffResource Return Statistics|r will show automatically when you have |cff00ffKyne's Wind|r, |cff00ffHollowfang Thirst|r, |cff00ffSentinel of Rkugamz|r, |cff00ffSymphony of Blades|r, |cff00ffVateshran Restoration Staff|r or |cff00ffMaster's Restoration Staff|r equipped and track the amount of returned resources during combat.",
		},
		{
			type  = "description",
			text  = "Use the |t16:16:odyhybridheal/icons/switch.dds|t-button to toggle between |c00ffffoverall|r and |c00ffffaverage|r statistics. Use the |t16:16:odyhybridheal/icons/print.dds|t-button to print a detailed list of returned resources to your chat-window. Use the |t16:16:odyhybridheal/icons/caret_down.dds|t-button to show a panel with detailed live statistics.",
		},
		{
			type    = "checkbox",
			name    = "Track resources returned",
			default = DEFAULTS.TrackResourceReturn,
			getFunc = function() return OHH.store.TrackResourceReturn end,
			setFunc = function( newValue ) OHH.store.TrackResourceReturn = newValue; OHH.OnItemSlotUpdate() end,
		},
		{
			type  = "description",
			text  = "",
		},
	}

	tableAppend( optionsTable, furtherOptions )

	LAM = LibAddonMenu2
	LAM:RegisterAddonPanel( OHH.name .. "Options", panelData )
	LAM:RegisterOptionControls( OHH.name .. "Options", optionsTable )
end

function OHH.OnActivated()
	OHH.OnItemSlotUpdate( 0, 0 )
	OHH.OnSkillSlotUpdate()
	OHH.OnBossChanged()
	
	OHH.BuildGroup()
	-- workaround for when game reports that player is not grouped shortly after zoning
	if OHH.groupSize == 0 then
		zo_callLater( OHH.BuildGroup, 5000 )
	end

	-- OHH.events:UnregisterForEvent( OHH.name .. "Activated", EVENT_PLAYER_ACTIVATED )

	if not OHH.activated then
		OHH.activated = true

		-- OHH.events:RegisterForEvent( OHH.name .. "SkillSlotUpdate", EVENT_ACTION_SLOT_STATE_UPDATED, OHH.OnSkillSlotUpdate )
		ACTION_BAR_ASSIGNMENT_MANAGER:RegisterCallback( "SlotUpdated", function( hotbarCategory, actionSlotIndex, isChangedByPlayer )
			if isChangedByPlayer then
				OHH.DebounceSlots()
			end
		end )
	
		-- OHH.events:RegisterForEvent( OHH.name .. "ItemSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, OHH.OnItemSlotUpdate )
		OHH.events:RegisterForEvent( OHH.name .. "ItemSlotUpdate", EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function( eventCode, bagId, slotId, isNewItem, itemSound, updateReason, countChange )
			if bagId == 0 and updateReason == 0 and not ( slotId == 13 or slotId == 14 ) then
				OHH.DebounceItems()
			end
		end )

		OHH.events:RegisterForEvent( OHH.name .. "BossChange", EVENT_BOSSES_CHANGED, OHH.OnBossChanged )
		OHH.events:RegisterForEvent( OHH.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, OHH.OnCombatState )

		OHH.events:RegisterForEvent( OHH.name .. "CombatEventKyne1", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventKyne1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, KYNE.proc )
		OHH.events:RegisterForEvent( OHH.name .. "CombatEventKyne2", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventKyne2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, KYNE.perfect )
		-- OHH.events:RegisterForEvent( OHH.name .. "Kyne1Effect", EVENT_EFFECT_CHANGED, OHH.OnEffectChanged )

		OHH.events:RegisterForEvent( OHH.name .. "CombatEventOlo1", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventOlo1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, OLORIME.proc )
		OHH.events:RegisterForEvent( OHH.name .. "CombatEventOlo2", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventOlo2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, OLORIME.perfect )

		-- debug
		-- OHH.events:RegisterForEvent( OHH.name .. "TestEvent", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		-- OHH.events:RegisterForEvent( OHH.name .. "TestEffect", EVENT_EFFECT_CHANGED, OHH.OnEffectChanged )

		OHH.events:RegisterForEvent( OHH.name .. "ForceOverflowEffect", EVENT_EFFECT_CHANGED, OHH.OnEffectChanged )
		OHH.events:AddFilterForEvent( OHH.name .. "ForceOverflowEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, FORCEOVERFLOW.id )

		for id, source in pairs( SUSTAINSOURCES ) do
			OHH.events:RegisterForEvent( OHH.name .. "SustainSource" .. id, EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
			OHH.events:AddFilterForEvent( OHH.name .. "SustainSource" .. id, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id )
		end

		OHH.events:RegisterForEvent( OHH.name .. "CombatEventOpp1", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventOpp1", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, OPPORTUNIST.proc )
		OHH.events:RegisterForEvent( OHH.name .. "CombatEventOpp2", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventOpp2", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, OPPORTUNIST.perfect )
		-- OHH.events:RegisterForEvent( OHH.name .. "Opp1Effect", EVENT_EFFECT_CHANGED, OHH.OnEffectChanged )
		-- OHH.events:AddFilterForEvent( OHH.name .. "Opp1Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, OPPORTUNIST.proc )
		-- OHH.events:RegisterForEvent( OHH.name .. "Opp2Effect", EVENT_EFFECT_CHANGED, OHH.OnEffectChanged )
		-- OHH.events:AddFilterForEvent( OHH.name .. "Opp2Effect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, OPPORTUNIST.perfect )

		for id, _ in pairs( OPPORTUNIST.debuff.ids ) do
			OHH.events:RegisterForEvent( OHH.name .. "CombatEventOppDebuff" .. id, EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
			OHH.events:AddFilterForEvent( OHH.name .. "CombatEventOppDebuff" .. id, EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, id )
		end

		OHH.events:RegisterForEvent( OHH.name .. "CombatEventPowerful", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventPowerful", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, POWERFUL.id )

		OHH.events:RegisterForEvent( OHH.name .. "CombatEventRespite", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventRespite", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, RESPITE.proc )
		-- OHH.events:RegisterForEvent( OHH.name .. "Respite", EVENT_EFFECT_CHANGED, OHH.OnEffectChanged )
		-- OHH.events:AddFilterForEvent( OHH.name .. "Respite", EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, RESPITE.proc )

		OHH.events:RegisterForEvent( OHH.name .. "CombatEventHiti", EVENT_COMBAT_EVENT, OHH.OnCombatEvent )
		OHH.events:AddFilterForEvent( OHH.name .. "CombatEventHiti", EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, HITI.id )

		OHH.events:RegisterForEvent( OHH.name .. "GroupJoined", EVENT_GROUP_MEMBER_JOINED, OHH.OnGroupUpdate )
		OHH.events:RegisterForEvent( OHH.name .. "GroupLeft", EVENT_GROUP_MEMBER_LEFT, OHH.OnGroupUpdate )
		OHH.events:RegisterForEvent( OHH.name .. "GroupRoles", EVENT_GROUP_MEMBER_ROLE_CHANGED, OHH.OnGroupUpdate )
		OHH.events:RegisterForEvent( OHH.name .. "GroupConnect", EVENT_GROUP_MEMBER_CONNECTED_STATUS, OHH.OnGroupUpdate )
		OHH.events:RegisterForEvent( OHH.name .. "GroupEffect", EVENT_EFFECT_CHANGED, OHH.OnEffectChanged )
		OHH.events:AddFilterForEvent( OHH.name .. "GroupEffect", EVENT_EFFECT_CHANGED, REGISTER_FILTER_UNIT_TAG_PREFIX, "group" )

		-- OHH.events:RegisterForEvent( OHH.name .. "Click", EVENT_GLOBAL_MOUSE_DOWN, function()
		-- 	d( "mouse down event" )
		-- end )
		
		OHH.events:RegisterForUpdate( OHH.name .. "Update", OHH.interval, OHH.OnUpdate )
	end
end

function OHH.OnAddonLoaded( event, addonName )
	if addonName ~= OHH.name then
		return
	end
	
	OHH.store = ZO_SavedVars:New( "OHHStore", 1, nil, DEFAULTS )

	OHH.CreateUI()
	OHH.CreateMenu()

	OHH.events:UnregisterForEvent( OHH.name, EVENT_ADD_ON_LOADED )
	OHH.events:RegisterForEvent( OHH.name .. "Activated", EVENT_PLAYER_ACTIVATED, OHH.OnActivated )
end

OHH.events:RegisterForEvent( OHH.name, EVENT_ADD_ON_LOADED, OHH.OnAddonLoaded )
