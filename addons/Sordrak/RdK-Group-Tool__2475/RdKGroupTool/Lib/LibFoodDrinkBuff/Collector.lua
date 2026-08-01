local lib = LIB_FOOD_DRINK_BUFF

local chat = lib.chat
local async = lib.async

-- The collector is only active, if LibAsync is loaded
if not async then
	SLASH_COMMANDS["/dumpfdb"] = function()
		chat:Print(GetString(SI_LIB_FOOD_DRINK_BUFF_LIB_ASYNC_NEEDED))
	end
	return
end

-- Register new ESO dialog
ESO_Dialogs["LIB_FOOD_DRINK_BUFF_FOUND_DATA"] =
{
	title =
	{
		text = SI_LIB_FOOD_DRINK_BUFF_DIALOG_TITLE,
	},
	mainText =
	{
		text = function(dialog) return zo_strformat(SI_LIB_FOOD_DRINK_BUFF_DIALOG_MAINTEXT, dialog.data.countEntries) end
	},
	buttons =
	{
		[1] =
		{
			text = SI_DIALOG_YES,
			callback = function() ReloadUI("ingame") end,
		},
		[2] =
		{
			text = SI_DIALOG_NO,
		},
	},
}

local ARGUMENT_ALL = 1
local ARGUMENT_NEW = 2

local MAX_ABILITY_ID = 2000000
local MINIMUM_BUFF_DURATION = 35 * ZO_ONE_MINUTE_IN_MILLISECONDS

local worldName = GetWorldName()
local taskCollector = async:Create(LFDB_LIB_IDENTIFIER .. "_Collector")

local function GetSaveType(arg)
	return arg == "new" and ARGUMENT_NEW or arg == "all" and ARGUMENT_ALL
end

local function PrintSummary()
	local countEntries = #lib.savedVars.foodDrinkBuffList[worldName]
	if countEntries > 0 then
		local data = { countEntries = countEntries }
		ZO_Dialogs_ShowDialog("LIB_FOOD_DRINK_BUFF_FOUND_DATA", data)
	else
		chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXPORT_FINISH, countEntries))
	end
end

local function AddAbilityToSavedVars(abilityId, abilityName)
	local newEntry = { }
	newEntry.abilityId = abilityId
	newEntry.abilityName = ZO_CachedStrFormat(SI_ABILITY_NAME, abilityName)
	newEntry.lua = ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_EXCEL, abilityId, newEntry.abilityName)
	table.insert(lib.savedVars.foodDrinkBuffList[worldName], newEntry)
end

local function CheckAndCollectAbilityData(abilityId, saveType)
	if saveType == ARGUMENT_NEW and lib:GetBuffTypeInfos(abilityId) ~= LFDB_BUFF_TYPE_NONE then
		return
	end
	-- We gonna check the abilityId parameter step by step to increase performance during the check.
	if GetAbilityAngleDistance(abilityId) == 0 then
		if GetAbilityRadius(abilityId) == 0 then
			if GetAbilityDuration(abilityId) >= MINIMUM_BUFF_DURATION then
				local minRangeCM, maxRangeCM = GetAbilityRange(abilityId)
				if minRangeCM == 0 and maxRangeCM == 0 then
					local cost, mechanic = GetAbilityCost(abilityId)
					if cost == 0 and mechanic == POWERTYPE_MAGICKA then
						local channeled, castTime = GetAbilityCastInfo(abilityId)
						if not channeled and castTime == 0 then
							if GetAbilityTargetDescription(abilityId) == GetString(SI_TARGETTYPE2) then
								if GetAbilityDescription(abilityId) ~= "" and GetAbilityEffectDescription(abilityId) == "" then
									local abilityName = GetAbilityName(abilityId)
									if not lib:DoesStringContainsBlacklistPattern(abilityName) then
										AddAbilityToSavedVars(abilityId, abilityName)
									end
								end
							end
						end
					end
				end
			end
		end
	end
end

SLASH_COMMANDS["/dumpfdb"] = function(arg)
	local saveType = GetSaveType(arg)
	if saveType then
		chat:Print(GetString(SI_LIB_FOOD_DRINK_BUFF_EXPORT_START))

		-- Get and set the SavedVariables. We are not using ZO_SavedVars wrapper here but just the global table of lib.savedVarsName!
		local savedVarsName = lib.savedVarsName
		_G[savedVarsName] = _G[savedVarsName] or { }
		lib.savedVars = _G[savedVarsName]

		-- Clear old savedVars food and drink buff list of the current server
		lib.savedVars.foodDrinkBuffList = lib.savedVars.foodDrinkBuffList or { }
		lib.savedVars.foodDrinkBuffList[worldName] = { }

		-- start new scan
		taskCollector:For(1, MAX_ABILITY_ID):Do(function(abilityId)
			if DoesAbilityExist(abilityId) then
				CheckAndCollectAbilityData(abilityId, saveType)
			end
		end):Then(function()
			-- update the savedVars timestamp
			lib.savedVars.lastUpdated = lib.savedVars.lastUpdated or { }
			lib.savedVars.lastUpdated[worldName] =
			{
				timestamp = os.date(),
				saveType = arg,
			}
			PrintSummary()
		end)
	else
		chat:Print(ZO_CachedStrFormat(SI_LIB_FOOD_DRINK_BUFF_ARGUMENT_MISSING, GetString(SI_ERROR_INVALID_COMMAND)))
	end
end
