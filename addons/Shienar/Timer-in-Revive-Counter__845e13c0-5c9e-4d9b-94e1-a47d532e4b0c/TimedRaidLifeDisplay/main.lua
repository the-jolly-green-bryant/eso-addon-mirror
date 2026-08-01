TRLD = TRLD or {}
TRLD.name = "TimedRaidLifeDisplay"

function TRLD.Initialize()
	--TIMED TRIALS/ARENAS
	TRLD.timerLabel = CreateControl("ZO_HUDRaidLifeReservoirTimerLabel", ZO_HUDRaidLifeReservoir, CT_LABEL)
	TRLD.timer = CreateControl("ZO_HUDRaidLifeReservoirTimer", ZO_HUDRaidLifeReservoir, CT_LABEL)

	TRLD.timerLabel:SetHidden(false)
	TRLD.timer:SetHidden(false)

	TRLD.timerLabel:SetAnchor(LEFT, ZO_HUDRaidLifeReservoirTotalScore, RIGHT, 20, 5)
	TRLD.timer:SetAnchor(LEFT, TRLD.timerLabel, RIGHT, 10, -5)

	TRLD.timerLabel:SetFont("ZoFontGamepad27")
	TRLD.timer:SetFont("ZoFontGamepad42")

	TRLD.timerLabel:SetText("TIME")
	TRLD.timer:SetText("0:00")

	TRLD.timerLabel:SetColor(197/255, 194/255, 158/255, 1)

	--ENDLESS ARCHIVE SPECIAL CASE
	TRLD.timerLabel_ENDLESS = CreateControl("ZO_EndlessDungeonHUD_TopLevelTimerLabel", ZO_EndlessDungeonHUD_TopLevel, CT_LABEL)
	TRLD.timer_ENDLESS = CreateControl("ZO_EndlessDungeonHUD_TopLevelTimer", ZO_EndlessDungeonHUD_TopLevel, CT_LABEL)

	TRLD.timerLabel_ENDLESS:SetHidden(false)
	TRLD.timer_ENDLESS:SetHidden(false)

	TRLD.timerLabel_ENDLESS:SetAnchor(LEFT, ZO_EndlessDungeonHUD_TopLevelScoreLabelOutLabel, RIGHT, 20, 5)
	TRLD.timer_ENDLESS:SetAnchor(LEFT, TRLD.timerLabel_ENDLESS, RIGHT, 10, -5)

	TRLD.timerLabel_ENDLESS:SetFont("ZoFontGamepad27")
	TRLD.timer_ENDLESS:SetFont("ZoFontGamepad42")

	TRLD.timerLabel_ENDLESS:SetText("TIME")
	TRLD.timer_ENDLESS:SetText("0:00")

	TRLD.timerLabel_ENDLESS:SetColor(197/255, 194/255, 158/255, 1)

	EVENT_MANAGER:RegisterForUpdate("TRLD", 1000, function()
		if GetRaidDuration() > 0 then
			TRLD.timer:SetText(ZO_FormatTimeMilliseconds(GetRaidDuration(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS))
		elseif IsInstanceEndlessDungeon() then
			if GetEndlessDungeonFinalRunTimeMilliseconds() ~= 0 then
				TRLD.timer_ENDLESS:SetText(ZO_FormatTimeMilliseconds(GetEndlessDungeonFinalRunTimeMilliseconds(), TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS))
			else
				--os.time() is in seconds
				local runDurationMS = (os.time()*1000) - GetEndlessDungeonStartTimeMilliseconds()
				TRLD.timer_ENDLESS:SetText(ZO_FormatTimeMilliseconds(runDurationMS, TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS))
			end
		end
	end)
end

function TRLD.OnAddOnLoaded(event, addonName)
	if addonName == TRLD.name then
		TRLD.Initialize()
		EVENT_MANAGER:UnregisterForEvent(TRLD.name, EVENT_ADD_ON_LOADED)
	end
end

EVENT_MANAGER:RegisterForEvent(TRLD.name, EVENT_ADD_ON_LOADED, TRLD.OnAddOnLoaded)