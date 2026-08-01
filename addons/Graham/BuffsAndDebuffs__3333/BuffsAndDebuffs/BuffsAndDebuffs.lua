GlByGrhmForBuffsAndDebuffs = {}
local bad = GlByGrhmForBuffsAndDebuffs
bad.saved = {}
bad.savedChar = {}
bad.WM = GetWindowManager()

bad.eventPrefix = "EventForGrhmsBaD"
bad.ctrlPrefix = "CtrlForGrhmsBaD"

bad.checks = {}

local trackList = {}
local frames = {}
local headers = {}
local fronts = {}
local timers = {}
local backdrops = {}
local numLabels = {}
local charges = {}
local endTimes = {}
local totalTimes = {}
local lasts = {}
local percentCalcs = {}
percentCalcs["Drain"] = function(e, t, s) return (e - s) / t * 100 end
percentCalcs["Fill"] = function(e, t, s) return (s - (e - t)) / t * 100 end
local timerCalcs = {}
timerCalcs["Drain"] = function(e, t, s) return e - s end
timerCalcs["Fill"] = function(e, t, s) return s - (e - t) end
local headFuncs = {}
local members = {}
local timeStamp = 0
local exitTime = 0.01
local lagTime = 2.0
local ChangeCallbacks = {}
local CombatCallbacks = {}
local sourceNames = {}
local targetNames = {}
local fragmentGroup = {}

local function ChangeEffect(barId, changeType, beginTime, endTime, unitId)
	if changeType ~= EFFECT_RESULT_FADED then
		endTimes[barId] = endTime
		totalTimes[barId] = endTime - beginTime
		lasts[barId] = unitId
		backdrops[barId]:SetHidden(false)
	elseif lasts[barId] == unitId then
		endTimes[barId] = nil
		totalTimes[barId] = nil
		lasts[barId] = 0
		if timers[barId] then timers[barId]:SetText("") end
		fronts[barId]:SetValue(0)
		backdrops[barId]:SetHidden(true)
	end
end

function bad.initialize()
	
	bad.saved = ZO_SavedVars:NewAccountWide("BuffsAndDebuffsVars", 1, nil, nil)
	--bad.saved.profiles = nil
	if bad.saved.profiles == nil then bad.saved = ZO_SavedVars:NewAccountWide("BuffsAndDebuffsVars", 1, nil, bad.defaults) end
	bad.savedChar = ZO_SavedVars:NewCharacterIdSettings("BuffsAndDebuffsVars", 1, nil, bad.defaultsChar)
	
	bad.menuInitialize()

	local spacing = 5
	local pi = bad.savedChar.selProfile
	if bad.saved.profiles[pi] == nil then pi = 1 end
	if bad.saved.profiles[pi].lag then lagTime = bad.saved.profiles[pi].lag end
	local bi = 0
	
	if bad.saved.profiles[pi].frames then
		for fi = 1, #bad.saved.profiles[pi].frames do
			local frame = bad.saved.profiles[pi].frames[fi]
			if frame.show == true then
				local top = frame.size + spacing
				frames[fi] = bad.WM:CreateTopLevelWindow(bad.ctrlPrefix .. "Frame" .. fi)
				frames[fi]:SetDimensions(frame.width, top)
				frames[fi]:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, frame.x, frame.y)
				frames[fi]:SetMovable(true)
				frames[fi]:SetMouseEnabled(true)
				frames[fi]:SetHandler("OnMoveStop", function()
					frame.x = frames[fi]:GetLeft()
					frame.y = frames[fi]:GetTop()
				end)
				
				fragmentGroup[fi-1] = ZO_SimpleSceneFragment:New(frames[fi])
				
				headers[fi] = bad.WM:CreateControl(string.format("%sHeader%d", bad.ctrlPrefix, fi), frames[fi], CT_LABEL )
				headers[fi]:SetAnchor(TOPLEFT, frames[fi], TOPLEFT, 0, 0)
				headers[fi]:SetFont(string.format("$(BOLD_FONT)|%d|soft-shadow-thick", frame.size))
				headers[fi]:SetWrapMode(ELLIPSIS)
				headers[fi]:SetColor(frame.color.r,frame.color.g,frame.color.b,frame.color.a)
				if string.find(frame.name, "+power") then
					headFuncs["PowerUpdate"] = function()
						local p = ""
						local w = GetPlayerStat(STAT_POWER,0)
						local s = GetPlayerStat(STAT_SPELL_POWER,0)
						if w > s then p = w else p = s end
						headers[fi]:SetText(string.gsub(frame.name, "+power", tostring(p)))
					end
				else headers[fi]:SetText(frame.name) end
				
				if frame.bars then
					for sbi = 1, #frame.bars do
						if frame.bars[sbi].show == true then
							local bar = frame.bars[sbi]
							bi = bi + 1

							backdrops[bi] = bad.WM:CreateControl(string.format("%sBarBackdrop%d", bad.ctrlPrefix, bi), frames[fi], CT_BACKDROP )
							if sbi == 1 then backdrops[bi]:SetAnchor(TOPLEFT, frames[fi], TOPLEFT, 0, top) end
							if sbi > 1 then backdrops[bi]:SetAnchor(TOPLEFT, backdrops[bi-1], TOPLEFT, 0, top) end
							if sbi > 1 and bar.sitsOn == true then backdrops[bi]:SetAnchor(TOPLEFT, backdrops[bi-1], TOPLEFT, 0, 0) end
							backdrops[bi]:SetDimensions(frame.width, bar.thick)
							backdrops[bi]:SetCenterColor(bar.backColor.r,bar.backColor.g,bar.backColor.b,bar.backColor.a)
							backdrops[bi]:SetEdgeColor(0,0,0,0)
							backdrops[bi]:SetAlpha(1)
							backdrops[bi]:SetHidden(true)
							
							fronts[bi] = bad.WM:CreateControl(string.format("%sBarFront%d", bad.ctrlPrefix, bi), frames[fi], CT_STATUSBAR )
							fronts[bi]:SetAnchor(TOPLEFT, backdrops[bi], TOPLEFT, 0, 0)
							fronts[bi]:SetDimensions(frame.width, bar.thick)
							fronts[bi]:SetMinMax(0, 100)
							fronts[bi]:SetGradientColors(bar.startColor.r, bar.startColor.g, bar.startColor.b, bar.startColor.a, bar.endColor.r, bar.endColor.g, bar.endColor.b, bar.endColor.a )
							fronts[bi]:SetValue(0)

							if bar.timer ~= 0 then
								timers[bi] = bad.WM:CreateControl(string.format("%sBarTimer%d", bad.ctrlPrefix, bi), frames[fi], CT_LABEL )
								timers[bi]:SetAnchor(bar.timer, fronts[bi], bar.timer, 0, 0)
								timers[bi]:SetFont(string.format("$(MEDIUM_FONT)|%d|shadow", bar.thick))
								timers[bi]:SetColor(bar.timerColor.r,bar.timerColor.g,bar.timerColor.b,bar.timerColor.a)
								timers[bi]:SetText("")
							end
							
							top = spacing + bar.thick

							lasts[bi] = 0
							local barId = bi
							if bar.charge then charges[bi] = bar.charge else charges[bi] = "Drain" end
							if bar.character then
								ChangeCallbacks[bi] = function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
									--d(string.format("%s %s %d", unitName, unitTag, sourceUnitType))
									--d(sourceNames[barId])
									if unitName == bar.character and sourceNames[barId] == unitName then
										ChangeEffect(barId, changeType, beginTime, endTime, unitId)
									end
								end
								CombatCallbacks[bi] = function(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId,targetUnitId, abilityId, overflow)
									sourceNames[barId] = sourceName
								end
							else
								ChangeCallbacks[bi] = function(eventCode, changeType, effectSlot, effectName, unitTag, beginTime, endTime, stackCount, iconName, buffType, effectType, abilityType, statusEffectType, unitName, unitId, abilityId, sourceUnitType)
									--d(string.format("%s %s %d", unitName, unitTag, sourceUnitType))
									ChangeEffect(barId, changeType, beginTime, endTime, unitId)
								end
							end
														
							for idi = 1, #bar.IDs do
								if bar.character then 
									EVENT_MANAGER:RegisterForEvent(string.format("%sCombatBId%dAId%d", bad.eventPrefix, bi, idi), EVENT_COMBAT_EVENT, CombatCallbacks[bi])
									EVENT_MANAGER:AddFilterForEvent(string.format("%sCombatBId%dAId%d", bad.eventPrefix, bi, idi), EVENT_COMBAT_EVENT, REGISTER_FILTER_ABILITY_ID, bar.IDs[idi])
								end
	
								EVENT_MANAGER:RegisterForEvent(string.format("%sChangeBId%dAId%d", bad.eventPrefix, bi, idi), EVENT_EFFECT_CHANGED, ChangeCallbacks[bi])
								EVENT_MANAGER:AddFilterForEvent(string.format("%sChangeBId%dAId%d", bad.eventPrefix, bi, idi), EVENT_EFFECT_CHANGED, REGISTER_FILTER_ABILITY_ID, bar.IDs[idi])
								if bar.source ~= 0 then 
									EVENT_MANAGER:AddFilterForEvent(string.format("%sChangeBId%dAId%d", bad.eventPrefix, bi, idi), EVENT_EFFECT_CHANGED, REGISTER_FILTER_SOURCE_COMBAT_UNIT_TYPE, bar.source)
								end
								if bar.target ~= "any" then
									local tag = REGISTER_FILTER_UNIT_TAG
									if bar.target == "group" then tag = REGISTER_FILTER_UNIT_TAG_PREFIX else tag = REGISTER_FILTER_UNIT_TAG end
									EVENT_MANAGER:AddFilterForEvent(string.format("%sChangeBId%dAId%d", bad.eventPrefix, bi, idi), EVENT_EFFECT_CHANGED, tag, bar.target) 
								end
							end
						end
					end
				end
			end
		end
	end
	
	local sceneHud = SCENE_MANAGER:GetScene("hud")
	local sceneHudui = SCENE_MANAGER:GetScene("hudui")
	sceneHud:AddFragmentGroup(fragmentGroup)
	sceneHudui:AddFragmentGroup(fragmentGroup)
	
	SLASH_COMMANDS["/bad_me"] = function()
		d(string.format("GameTime: %d", GetGameTimeMilliseconds() / 1000))
		for i = 1, GetNumBuffs("player") do
			local buffName, timeStarted, timeEnding, buffSlot, stackCount, iconFilename, buffType, effectType, abilityType, statusEffectType, abilityId, canClickOff = GetUnitBuffInfo("player" , i)
			d(string.format("%s: %s, %s, %s, %s, %s, %s, %s", buffName, timeStarted, timeEnding, buffType, effectType, abilityType, statusEffectType, abilityId))
		end
	end
	
	SLASH_COMMANDS["/bad_get_members"] = function()
		d(GetUnitName("player"))
	end
	
	SLASH_COMMANDS["/bad_check"] = function()
		for i = 1, #ChangeCallbacks do
			ChangeCallbacks[i]()
		end
	end

	function CombatCallbacksTest(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
		if sourceType == 1 then
			d(string.format("%s - %d *%s", abilityName, abilityId, hitValue))
		end
	end
	SLASH_COMMANDS["/bad_combat_on"] = function()
		EVENT_MANAGER:RegisterForEvent(string.format("%sCombatBITest", bad.eventPrefix), EVENT_COMBAT_EVENT, CombatCallbacksTest)
	end
	SLASH_COMMANDS["/bad_combat_off"] = function()
		EVENT_MANAGER:UnregisterForEvent(string.format("%sCombatBITest", bad.eventPrefix), EVENT_COMBAT_EVENT, CombatCallbacksTest)
	end
	
	
	EVENT_MANAGER:UnregisterForEvent(string.format("%sIni", bad.eventPrefix), EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForUpdate(string.format("%sUpd", bad.eventPrefix), 10, bad.update)
end

EVENT_MANAGER:RegisterForEvent(string.format("%sIni", bad.eventPrefix), EVENT_ADD_ON_LOADED, bad.initialize)

function bad.update()
	for i, v in pairs(totalTimes) do
		timeStamp = GetGameTimeMilliseconds() / 1000
		fronts[i]:SetValue(percentCalcs[charges[i]](endTimes[i], totalTimes[i], timeStamp))
		if timers[i] then 
			timers[i]:SetText(string.format("%0.1f", timerCalcs[charges[i]](endTimes[i], totalTimes[i], timeStamp))) 
		end
		if (timeStamp - lagTime) > endTimes[i] then
			endTimes[i] = nil
			totalTimes[i] = nil
			lasts[i] = 0
			if timers[i] then timers[i]:SetText("") end
			fronts[i]:SetValue(0)
			backdrops[i]:SetHidden(true)
		end
	end
	if headFuncs["PowerUpdate"] then headFuncs["PowerUpdate"]() end
end