DsRGuildBeam = DsRGuildBeam or {}
DsRBeam = DsRGuildBeam

---[ Constants ]---

DsRBeam.Debug = false

DsRBeam.Const 					= { }
DsRBeam.Const.AddonName 		= "DsRBeam"
DsRBeam.Const.AddonTitle 		= "Light of Togetherness"
DsRBeam.Const.SavedVarsFile 	= "DsRGuildRosterSettings"
DsRBeam.Const.SavedVarsDefaults = { }
DsRBeam.Const.SavedVarsVersion 	= 1
DsRBeam.Const.DialogAlert 		= "DsRBeamDialogAlert"
DsRBeam.Const.DialogConfirm 	= "DsRBeamDialogConfirm"
DsRBeam.Const.DefaultSettings 	= { }

DsRBeam.Attribute 				= { }
DsRBeam.Attribute.Active 		= 1
DsRBeam.Attribute.Dead 			= 2
DsRBeam.Attribute.Resurrecting 	= 3
DsRBeam.Attribute.Leader 		= 4
DsRBeam.Attribute.Healer 		= 5
DsRBeam.Attribute.Tank 			= 6
DsRBeam.Attribute.DPS 			= 7
DsRBeam.Attribute.Battleground 	= 8
DsRBeam.Attribute.Cyrodiil 		= 9
DsRBeam.Attribute.ImperialCity 	= 10
DsRBeam.Attribute.NonPVP 		= 11
DsRBeam.Attribute.Dungeon 		= 12

DsRBeam.RadiantPlayers = { }
DsRBeam.UnitTags = { }

local function InitUnitTags()
	for index = 1, GROUP_SIZE_MAX + 1 do
		if 1 == index then
			DsRBeam.UnitTags[index] = "player"
		else
			DsRBeam.UnitTags[index] = string.format( "group%d", index - 1 )
		end
	end

	DsRBeam.NumUnitTags = #DsRBeam.UnitTags
end
InitUnitTags()

---[ Initialization ]---

function DsRBeam.Initialize()
	DsRBeam.InitVars()
end

function DsRBeam.InitVars()
	local savedVars = ZO_SavedVars:NewAccountWide( "DsRGuildRosterSettings", 1, nil, DsRBeam.Const.SavedVarsDefaults ) 

	if not savedVars.Data 	 then savedVars.Data = { } end
	if not savedVars.Options then savedVars.Options = { } end

	DsRBeam.Vars 	= savedVars.Data
	DsRBeam.Options = savedVars.Options
end

function DsRBeam.GetSettingsTable()
	local settings = DsRBeam.Vars.Settings
	if "table" ~= type( settings ) then
		settings = { }
		DsRBeam.Vars.Settings = settings
	end

	return settings
end

function DsRBeam.SetDefaultSetting( settingName, value )
	if "string" == type( settingName ) and "" ~= settingName then
		DsRBeam.Const.DefaultSettings[ settingName ] = value
	end
end

function DsRBeam.GetSetting( settingName, suppressDefault )
	local settings = DsRBeam.GetSettingsTable()
	local value = settings[ settingName ]

	if nil == value and not suppressDefault then value = DsRBeam.Const.DefaultSettings[ settingName ] end
	return value
end

function DsRBeam.SetSetting( settingName, value )
	local settings = DsRBeam.GetSettingsTable()
	settings[ settingName ] = value

	DsRBeam.ResetAllLights()
	return value
end

function DsRBeam.GetColorSetting( settingName, suppressDefault )
	local value = DsRBeam.GetSetting( settingName, suppressDefault )
	if not value or "table" ~= type( value ) then value = { r = 1, g = 1, b = 1 } end
	value.a = 0.7 + 0.3 * zo_clamp( DsRBeam.GetSetting( "LightAlpha" ) or 1, 0.1, 1 )

	return value
end

function DsRBeam.GetColorSettingValues( settingName, suppressDefault )
	local color = DsRBeam.GetColorSetting( settingName, suppressDefault )
	return color.r, color.g, color.b, color.a
end

function DsRBeam.SetColorSetting( settingName, value )
	local settings = DsRBeam.GetSettingsTable()

	if "table" ~= type( value ) then value = { r = 1, g = 1, b = 1 } end
	value.r, value.g, value.b = value.r or 1, value.g or 1, value.b or 1
	settings[ settingName ] = value

	DsRBeam.ResetAllLights()

	return value
end

do
	local DisplayName = GetDisplayName()
	local A = DsRBeam.Attribute
	local Active, Dead, Rez, Lead, Heal, Tank, DPS, BG, Cyro, ImpCity, NonPVP, Dungeon = A.Active, A.Dead, A.Resurrecting, A.Leader, A.Healer, A.Tank, A.DPS, A.Battleground, A.Cyrodiil, A.ImperialCity, A.NonPVP, A.Dungeon
	local WasInGroup = false

	function DsRBeam.OnRefreshLights()
		local effects = DsRBeam.Effect:GetAll()
		if not effects then
			return
		end
		
		if IsPlayerInGroup(DisplayName) then
			WasInGroup = true

			local LIGHT_ENABLED = DsRBeam.GetSetting( "LightEnabled" )
			local isBG			= IsActiveWorldBattleground()
			local isCyro 		= IsInCyrodiil()
			local isImpCity 	= IsInImperialCity()
			local isDungeon 	= IsUnitInDungeon("player")
			local isNonPVP 		= not isBG and not isCyro and not isImpCity and not isDungeon
			local leaderUnitTag = GetGroupLeaderUnitTag()
			

			for index, effect in ipairs( effects ) do
				if effect and effect.Attributes and not effect.Deleted then
					local attr 		= effect.Attributes
					local unitTag 	= effect.UnitTag
					local isPlayer 	= AreUnitsEqual( "player", unitTag )
					local role 		= GetGroupMemberSelectedRole( unitTag )

					if	isPlayer or ( not isPlayer and DoesUnitExist( unitTag ) and IsUnitOnline( unitTag ) and IsGroupMemberInSameWorldAsPlayer( unitTag ) and not IsGroupMemberInRemoteRegion( unitTag ) ) then
						local displayName = string.lower( GetUnitDisplayName( unitTag ) )

						attr[ Active ] 	= true
						attr[ Dead ] 	= IsUnitDead( unitTag ) and 1 >= GetUnitPower( unitTag, POWERTYPE_HEALTH )
						attr[ Rez ]  	= IsUnitBeingResurrected( unitTag ) or DoesUnitHaveResurrectPending( unitTag )
						attr[ Lead ] 	= leaderUnitTag == unitTag
						attr[ Heal ] 	= role == LFG_ROLE_HEAL
						attr[ Tank ] 	= role == LFG_ROLE_TANK
						attr[ DPS ]  	= role == LFG_ROLE_DPS
						attr[ BG ] 	 	= isBG
						attr[ Cyro ] 	= isCyro
						attr[ ImpCity ] = isImpCity
						attr[ NonPVP ] 	= isNonPVP
						attr[ Dungeon ] = isDungeon
					else
						attr[ Active ] = false
					end

					if not attr[ Active ] or not LIGHT_ENABLED then
						effect:SetColor( nil, nil, nil, 0 )
					elseif attr[ Dead ] and DsRBeam.GetSetting( "LightDead" ) then
							if attr[ Rez ] and DsRBeam.GetSetting( "LightResurrecting" ) then
								effect:SetColor( DsRBeam.GetColorSettingValues( "LightResurrectingColor" ) )
							else
								effect:SetColor( DsRBeam.GetColorSettingValues( "LightDeadColor" ) )
							end
					elseif attr[ Dungeon ] 	and not DsRBeam.GetSetting( "LightRAIDTeam" ) then
						effect:SetColor( nil, nil, nil, 0 )
					elseif attr[ NonPVP ] 	and not DsRBeam.GetSetting( "LightNonPVPTeam" ) then
						effect:SetColor( nil, nil, nil, 0 )
					elseif attr[ ImpCity ] 	and not DsRBeam.GetSetting( "LightImperialCityTeam" ) then
						effect:SetColor( nil, nil, nil, 0 )
					elseif attr[ Cyro ] 	and not DsRBeam.GetSetting( "LightCyrodiilTeam" ) then
						effect:SetColor( nil, nil, nil, 0 )
					elseif attr[ BG ] 	and not DsRBeam.GetSetting( "LightBattlegroundTeam" ) then
						effect:SetColor( nil, nil, nil, 0 )
					else
						if GetUnitDisplayName( unitTag ) == GetUnitDisplayName( "player" ) and DsRBeam.GetSetting( "Lightown" ) then
							local role = GetSelectedLFGRole()
							if role == 1 then
								effect:SetColor( DsRBeam.GetColorSettingValues( "HighlightDDsColor" ) )
							elseif role == 4 then
								effect:SetColor( DsRBeam.GetColorSettingValues( "HighlightHealersColor" ) )
							elseif role == 2 then
								effect:SetColor( DsRBeam.GetColorSettingValues( "HighlightTanksColor" ) )
							end
						elseif not IsUnitInCombat( "player" ) and DsRBeam.GetSetting( "LightCombatOnly" ) and GetUnitDisplayName( unitTag ) ~= GetUnitDisplayName( "player" ) then
							effect:SetColor( nil, nil, nil, 0 )
						elseif attr[ Lead ] and DsRBeam.GetSetting( "HighlightLeader" ) and GetUnitDisplayName( unitTag ) ~= GetUnitDisplayName( "player" ) then
							effect:SetColor( DsRBeam.GetColorSettingValues( "HighlightLeaderColor" ) )
						elseif attr[ Heal ] and DsRBeam.GetSetting( "HighlightHealers" ) and GetUnitDisplayName( unitTag ) ~= GetUnitDisplayName( "player" ) then
							effect:SetColor( DsRBeam.GetColorSettingValues( "HighlightHealersColor" ) )
						elseif attr[ Tank ] and DsRBeam.GetSetting( "HighlightTanks" ) and GetUnitDisplayName( unitTag ) ~= GetUnitDisplayName( "player" ) then
							effect:SetColor( DsRBeam.GetColorSettingValues( "HighlightTanksColor" ) )
						elseif attr[ DPS ] and DsRBeam.GetSetting( "HighlightDDs" ) and GetUnitDisplayName( unitTag ) ~= GetUnitDisplayName( "player" ) then
							effect:SetColor( DsRBeam.GetColorSettingValues( "HighlightDDsColor" ) )
						else
							effect:SetColor( nil, nil, nil, 0 )
						end
					end
				end
			end
		elseif WasInGroup then
			WasInGroup = false

			for index, effect in ipairs( effects ) do
				effect.Attributes[ Active ] = false
			end
		end
	end
end

function DsRBeam.UnregisterOnUpdate()
	EVENT_MANAGER:UnregisterForUpdate( DsRBeam.Const.AddonName .. "UnregisterOnUpdate" )
end

function DsRBeam.ResetAllLights()
	DsRBeam.Effect:DeleteAll()

	local effect
	for index = 1, DsRBeam.NumUnitTags do
		effect = DsRBeam.Effect:New( "Light of Togetherness" )
		effect.Attributes, effect.UnitTag = { }, DsRBeam.UnitTags[index]
	end

	DsRBeam.OnRefreshLights()
end