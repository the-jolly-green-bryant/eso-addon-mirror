Mephisto = Mephisto or {}
local MP = Mephisto

MP.conditions = {}
local MPC = MP.conditions

function MPC.Init()
	MPC.name = MP.name .. "Conditions"
	
	MPC.bossList = {}
	MPC.trashList = {}
	
	MPC.ResetCache()
end

function MPC.LoadConditions()
	MPC.bossList = {}
	MPC.trashList = {}
	
	local zone = MP.currentZone
	if not MP.pages[zone.tag] then return end
	local pageId = MP.pages[zone.tag][0].selected
	
	for entry in MP.PageIterator(zone, pageId) do
		local setup = Setup:FromStorage(zone.tag, pageId, entry.index)
		if setup:HasCondition() then
			local condition = setup:GetCondition()
			if condition.boss == GetString(MP_TRASH) then
				if condition.trash and condition.trash ~= MP.CONDITIONS.NONE then
					MPC.trashList[condition.trash] = {
						zone = zone,
						pageId = pageId,
						index = entry.index
					}
				end
			else
				MPC.bossList[condition.boss] = {
					zone = zone,
					pageId = pageId,
					index = entry.index
				}
			end
			
		end
	end
end

function MPC.ResetCache()
	MPC.cache = {
		boss = MP.CONDITIONS.EVERYWHERE
	}
end

function MPC.OnBossChange(bossName)
	local substitute = false
	if #bossName == 0 then
		local entry = MPC.trashList[MPC.cache.boss] or MPC.trashList[MP.CONDITIONS.EVERYWHERE]
		if entry and MP.settings.autoEquipSetups then
			substitute = MP.LoadSetup(entry.zone, entry.pageId, entry.index, true)
		end
	else
		local entry = MPC.bossList[bossName]
		if entry and MP.settings.autoEquipSetups then
			substitute = MP.LoadSetup(entry.zone, entry.pageId, entry.index, true)
		end
		MPC.cache.boss = bossName
	end
	if not substitute and MP.settings.autoEquipSetups then
		MPC.LoadSubstitute(bossName)
	end
end

function MPC.LoadSubstitute(bossName)
	if MP.currentZone.tag == "GEN"
		and not (MP.settings.substitute.dungeons and GetCurrentZoneDungeonDifficulty() > 0
		or MP.settings.substitute.overland and GetCurrentZoneDungeonDifficulty() == 0) then
		return
	end
	local index = 2
	if #bossName == 0 then index = 1 end
	MP.LoadSetupSubstitute(index)
end