---[ Namespaces ]---

if not MagicCarpet then MagicCarpet = { } end
local MC = MagicCarpet

if not MC.GameSettings then MC.GameSettings = ZO_Object:Subclass() end
local GS = MC.GameSettings

---[ Settings ]---

function GS:GetCurrentSetting( settingType, settingId )
	if not settingType or not settingId then return end
	return GetSetting( settingType, settingId )
end

function GS:GetPreservedSetting( settingType, settingId )
	if not settingType or not settingId then return end

	local preservedGameSettings = MC.Vars.Settings.PreservedGameSettings
	if not preservedGameSettings then
		preservedGameSettings = { }
		MC.Vars.Settings.PreservedGameSettings = preservedGameSettings
	end

	local key = string.format( "%s__%s", tostring( settingType ), tostring( settingId ) )
	local setting = preservedGameSettings[ key ]

	if setting then
		return setting[3]
	else
		return nil
	end
end

function GS:PreserveSetting( settingType, settingId )
	if not settingType or not settingId then return end

	local preservedGameSettings = MC.Vars.Settings.PreservedGameSettings
	if not preservedGameSettings then
		preservedGameSettings = { }
		MC.Vars.Settings.PreservedGameSettings = preservedGameSettings
	end

	local key = string.format( "%s__%s", tostring( settingType ), tostring( settingId ) )
	local value = GetSetting( settingType, settingId )
	if not preservedGameSettings[ key ] then
		preservedGameSettings[ key ] = { settingType, settingId, value }
	end

	return value
end

function GS:ModifySetting( settingType, settingId, value )
	if not settingType or not settingId then return end

	GS:PreserveSetting( settingType, settingId )
	SetSetting( settingType, settingId, value )

	return value
end

function GS:RestoreSetting( settingType, settingId )
	if not settingType or not settingId then return end

	local preservedGameSettings = MC.Vars.Settings.PreservedGameSettings
	if not preservedGameSettings then
		preservedGameSettings = { }
		MC.Vars.Settings.PreservedGameSettings = preservedGameSettings
	end

	local key = string.format( "%s__%s", tostring( settingType ), tostring( settingId ) )
	local setting = preservedGameSettings[ key ]
	local value

	if setting and 3 <= #setting then
		value = setting[3]
		SetSetting( setting[1], setting[2], setting[3] )
	end

	MC.Vars.Settings.PreservedGameSettings[ key ] = nil

	return value
end

function GS:RestoreAllSettings()
	local preservedGameSettings = MC.Vars.Settings.PreservedGameSettings
	if not preservedGameSettings then
		preservedGameSettings = { }
		MC.Vars.Settings.PreservedGameSettings = preservedGameSettings
	end

	for key, setting in pairs( preservedGameSettings ) do
		if 3 <= #setting then
			SetSetting( setting[1], setting[2], setting[3] )
		end
	end

	MC.Vars.Settings.PreservedGameSettings = { }
end

---[ Singleton Setup ]---

MC.GameSettings = ZO_Object.New( MC.GameSettings )
