QDRH_SP = QDRH_SP or {}
local QDRH_SP = QDRH_SP

QDRH_SP.name	=	"Qcell_DSRHelper_Scorepush_Patch"
QDRH_SP.version  = "1.2.0"
QDRH_SP.author   = "Aries13th"
QDRH_SP.loaded = false

QDRH_SP.settings = {
	useAdaptiveStackPoints = true,
	showAdaptiveStackPointsEveryTime = false,
	showHPComparison = false,
	showCAPanel = true,
	debug = false,
	unlockHPComparison = false,
	panelLeft = 0,
	panelTop = 300,
}

QDRH_SP.data = {
	meeting_x_min = 67500,
	meeting_x_max = 72000,
	meeting_z_min = 82700,
	meeting_z_max = 87600,
	guardian_dash_id = 172072,
}

QDRH_SP.status = {
	reefGuardianPortalNum = 0,
	lastFirebrandTime = 0,
}

QDRH_SP.panel = {
	OnMoveStop = function()
		QDRH_SP.savedVariables.panelLeft = QCellDSRHelperScorepushPanel:GetLeft()
		QDRH_SP.savedVariables.panelTop = QCellDSRHelperScorepushPanel:GetTop()
	end,
}


function GetFarestPoint(points, x, z)
	local x_1, z_1, d = 0, 0, -1
	for i = 1, #points do
		local p_d = math.sqrt(math.max((points[i][1] - x)^2 + (points[i][2] - z)^2, 0.1))
		if p_d > d then
			x_1, z_1, d = points[i][1], points[i][2], p_d
		end
	end
	return x_1, z_1
end


function QDRH_SP.CalculateMeetingPoints()
	local points = {}
	local points_added = 0

	local x_c, y_c, z_c = 0, 0, 0
	for i = 1, GROUP_SIZE_MAX do
		local group_member = "group" .. tostring(i)
		if not IsUnitDead(group_member) then
			local zo, x, y, z = GetUnitWorldPosition(group_member)
			if (x ~= 0) and (zo == QDRH.data.dreadsailReefId) then
				points_added = points_added + 1
				points[points_added] = {x, z}
				if QDRH_SP.savedVariables.debug then d("QDRH_SP: player point " .. tostring(x) .. " - " .. tostring(z)) end
				if x_c == 0 then
					x_c, y_c, z_c = x, y, z
				else
					x_c = x_c + x
					y_c = y_c + y
					z_c = z_c + z
				end
			end
		end
	end

	if x_c == 0 then
		return 0, 0, 0, 0, 0
	end
	x_c, y_c, z_c = x_c / #points, y_c / #points, z_c / #points

	local x_1, z_1 = GetFarestPoint(points, x_c, z_c)
	local x_2, z_2 = GetFarestPoint(points, x_1, z_1)
	if QDRH_SP.savedVariables.debug then d("QDRH_SP: point1 " .. tostring(x_2) .. " - " .. tostring(z_2) .. " added ") end
	x_1, z_1 = GetFarestPoint(points, x_2, z_2)
	if QDRH_SP.savedVariables.debug then d("QDRH_SP: point2 " .. tostring(x_1) .. " - " .. tostring(z_1) .. " added ") end
	x_c, z_c = (x_1 + x_2) / 2, (z_1 + z_2) / 2

	local p1_x, p1_z, p2_x, p2_z = x_c + ((z_c - z_1) / 2), z_c - ((x_c - x_1) / 2), x_c - ((z_c - z_1) / 2), z_c + ((x_c - x_1) / 2)
	p1_x = math.min(math.max(p1_x, QDRH_SP.data.meeting_x_min), QDRH_SP.data.meeting_x_max)
	p1_z = math.min(math.max(p1_z, QDRH_SP.data.meeting_z_min), QDRH_SP.data.meeting_z_max)
	p2_x = math.min(math.max(p2_x, QDRH_SP.data.meeting_x_min), QDRH_SP.data.meeting_x_max)
	p2_z = math.min(math.max(p2_z, QDRH_SP.data.meeting_z_min), QDRH_SP.data.meeting_z_max)
	return p1_x, p1_z, p2_x, p2_z, y_c
end


function QDRH_SP.MatchBrands()
	if QDRH_SP.savedVariables.debug then d("QDRH_SP: Matching new points") end
	local p1_x, p1_z, p2_x, p2_z, y = QDRH_SP.CalculateMeetingPoints()
	QDRH.data.lylanar_brand_meeting_point[1][1] = p1_x
	QDRH.data.lylanar_brand_meeting_point[1][3] = p1_z
	QDRH.data.lylanar_brand_meeting_point[2][1] = p2_x
	QDRH.data.lylanar_brand_meeting_point[2][3] = p2_z

	if QDRH_SP.savedVariables.showAdaptiveStackPointsEveryTime then
		if QDRH_SP.savedVariables.debug then d("QDRH_SP: Drawing new points positions") end
		QDRH_SP.test_p1 = OSI.CreatePositionIcon(
				QDRH.data.lylanar_brand_meeting_point[1][1],
				QDRH.data.lylanar_brand_meeting_point[1][2],
				QDRH.data.lylanar_brand_meeting_point[1][3],
				"QcellDreadsailReefHelper/icons/yellow1.dds",
				OSI.GetIconSize())
		QDRH_SP.test_p2 = OSI.CreatePositionIcon(
				QDRH.data.lylanar_brand_meeting_point[2][1],
				QDRH.data.lylanar_brand_meeting_point[2][2],
				QDRH.data.lylanar_brand_meeting_point[2][3],
				"QcellDreadsailReefHelper/icons/yellow2.dds",
				OSI.GetIconSize())

		EVENT_MANAGER:RegisterForUpdate(QDRH_SP.name .. "MatchBrandsCountDown", 10000,
				function()
					OSI.DiscardPositionIcon(QDRH_SP.test_p1)
					OSI.DiscardPositionIcon(QDRH_SP.test_p2)
					if QDRH_SP.savedVariables.debug then d("QDRH_SP: Hiding new points positions") end
					EVENT_MANAGER:UnregisterForUpdate(QDRH_SP.name .. "MatchBrandsCountDown")
				end
		)
	end
end


function QDRH_SP.CombatEvent(eventCode, result, isError, abilityName, abilityGraphic, abilityActionSlotType, sourceName, sourceType, targetName, targetType, hitValue, powerType, damageType, log, sourceUnitId, targetUnitId, abilityId, overflow)
	if abilityId == QDRH.data.lylanar_pre_firebrand then
		if QDRH_SP.savedVariables.debug then d("QDRH_SP: Boss casting cookies") end
		local time = GetGameTimeSeconds()
		if time > QDRH_SP.status.lastFirebrandTime + 10 then
			QDRH_SP.status.lastFirebrandTime = time
			if QDRH_SP.savedVariables.useAdaptiveStackPoints and QDRH.status.isHMBoss then
				QDRH_SP.MatchBrands()
			else
				QDRH.data.lylanar_brand_meeting_point[1] = {68548, 36124-50, 85175}
				QDRH.data.lylanar_brand_meeting_point[2] = {69510, 36125-50, 85172}
			end
		end
	end
	if result == ACTION_RESULT_EFFECT_GAINED and abilityId == QDRH_SP.data.guardian_dash_id then
		QDRH_SP.status.reefGuardianPortalNum = QDRH_SP.status.reefGuardianPortalNum + 1;
		if QDRH_SP.savedVariables.debug then d("QDRH_SP: Boss run to Reef " .. QDRH_SP.status.reefGuardianPortalNum) end
	end
end


function QDRH_SP.ReefGuardianInitHPComparisonPanel()
	QDRH_SP.status.reefGuardianPortalNum = 0;
	QCellDSRHelperScorepushLabel3:SetText("");
	QCellDSRHelperScorepushLabel1:SetText("");
	QCellDSRHelperScorepushLabel2:SetText("");
	QCellDSRHelperScorepushPanel:SetHidden(false);
end


function QDRH_SP.ReefGuardianUpdateTick(gameTimeMs)
	local ofColor = 0.1;
	local bossHealth = {
		currentHP = {},
		maxHP = {},
		percentage = {},
		leftTo80 = {},
		alive = {},
	};
	local L, M1, M2, S1, S2 = 1, 2, 5, 3, 4;
	
  	-- MAX_BOSSES = 6
  	for i=1, 6 do
		local bossTag = "boss" .. tostring(i);
		bossHealth.currentHP[i], bossHealth.maxHP[i] = GetUnitPower(bossTag, POWERTYPE_HEALTH);
		bossHealth.percentage[i] = 0;
		bossHealth.leftTo80[i] = -1;
		bossHealth.alive[i] = false;
		if bossHealth.currentHP[i] ~= nil and bossHealth.maxHP[i] ~= nil and bossHealth.maxHP[i] ~= 0 then
			bossHealth.percentage[i] = bossHealth.currentHP[i] / bossHealth.maxHP[i] * 100;
			if bossHealth.percentage[i] > 80 then
				bossHealth.leftTo80[i] = bossHealth.currentHP[i] - (bossHealth.maxHP[i] * 0.8);
			end
			if bossHealth.currentHP[i] > 0 then
				bossHealth.alive[i] = true;
			end
		end
	end

	if bossHealth.alive[L] and ((bossHealth.alive[M1] or bossHealth.alive[M2] or bossHealth.alive[S1] or bossHealth.alive[S2]) == false) then
		QCellDSRHelperScorepushLabel3:SetText("Waiting..");
		QCellDSRHelperScorepushLabel3:SetColor(1, 0.67, 0, 1);
		QCellDSRHelperScorepushLabel2:SetText("");
		QCellDSRHelperScorepushLabel1:SetText("");
	elseif bossHealth.alive[L] and bossHealth.alive[M1] and ((bossHealth.alive[S1] and bossHealth.alive[M2]) == false) and (bossHealth.alive[S2] == false) then
		QCellDSRHelperScorepushLabel1:SetText("L " .. string.format("%.0f", bossHealth.percentage[L]) .. "%");
		QCellDSRHelperScorepushLabel2:SetText("M1 " .. string.format("%.0f", bossHealth.percentage[M1]) .. "%");
		QCellDSRHelperScorepushLabel3:SetText("");
		if bossHealth.leftTo80[L] > 0 then
			if bossHealth.leftTo80[1] > bossHealth.leftTo80[M1] then
				QCellDSRHelperScorepushLabel1:SetColor(1, ofColor, ofColor, 1);
			else
				QCellDSRHelperScorepushLabel1:SetColor(1, 1, 1, 0.8);
			end
		else
			QCellDSRHelperScorepushLabel1:SetColor(ofColor, 1, ofColor, 1);
		end
		if bossHealth.leftTo80[M1] > 0 then
			if bossHealth.leftTo80[M1] > bossHealth.leftTo80[L] then
				QCellDSRHelperScorepushLabel2:SetColor(1, ofColor, ofColor, 1);
			else
				QCellDSRHelperScorepushLabel2:SetColor(1, 1, 1, 0.8);
			end
		else
			QCellDSRHelperScorepushLabel2:SetColor(ofColor, 1, ofColor, 1);
		end
	elseif (bossHealth.percentage[M2] > 50) and (bossHealth.percentage[S1] > 50) and ((bossHealth.percentage[M2] > 78) or (bossHealth.percentage[S1] > 78)) then
		QCellDSRHelperScorepushLabel1:SetText("M2 " .. string.format("%.0f", bossHealth.percentage[M2]) .. "%");
		QCellDSRHelperScorepushLabel2:SetText("S1 " .. string.format("%.0f", bossHealth.percentage[S1]) .. "%");
		QCellDSRHelperScorepushLabel3:SetText("");
		if bossHealth.leftTo80[M2] > 0 then
			if bossHealth.leftTo80[M2] > bossHealth.leftTo80[S1] then
				QCellDSRHelperScorepushLabel1:SetColor(1, ofColor, ofColor, 1);
			else
				QCellDSRHelperScorepushLabel1:SetColor(1, 1, 1, 0.8);
			end
		else
			QCellDSRHelperScorepushLabel1:SetColor(ofColor, 1, ofColor, 1);
		end
		if bossHealth.leftTo80[S1] > 0 then
			if bossHealth.leftTo80[S1] > bossHealth.leftTo80[M2] then
				QCellDSRHelperScorepushLabel2:SetColor(1, ofColor, ofColor, 1);
			else
				QCellDSRHelperScorepushLabel2:SetColor(1, 1, 1, 0.8);
			end
		else
			QCellDSRHelperScorepushLabel2:SetColor(ofColor, 1, ofColor, 1);
		end
	else
		local portals = QDRH_SP.status.reefGuardianPortalNum;
		if portals < QDRH.status.reefGuardianPortalNum then
			portals = QDRH.status.reefGuardianPortalNum;
		end
		QCellDSRHelperScorepushLabel2:SetText("");
		QCellDSRHelperScorepushLabel1:SetText("");
		if portals <= 3 then
			QCellDSRHelperScorepushLabel3:SetText(tostring(portals) .. " portals");
			QCellDSRHelperScorepushLabel3:SetColor(ofColor, 1, ofColor, 1);
		else
			if portals <= 5 then
				QCellDSRHelperScorepushLabel3:SetText(tostring(portals) .. " portals");
				QCellDSRHelperScorepushLabel3:SetColor(1, 0.67, 0, 1);
			else
				QCellDSRHelperScorepushLabel3:SetText("WIPE");
				QCellDSRHelperScorepushLabel3:SetColor(1, ofColor, ofColor, 1);
			end
		end
	end
end


function QDRH_SP.CombatStateEvent(eventCode, inCombat)
	if inCombat then
		if QDRH.status.isReefGuardian then
			CombatAlerts.dsr.panel = QDRH_SP.savedVariables.showCAPanel;
			if QDRH_SP.savedVariables.showHPComparison then
				QDRH_SP.ReefGuardianInitHPComparisonPanel();
				EVENT_MANAGER:RegisterForUpdate(QDRH_SP.name.."ReefGuardianUpdateTick", 1000/10, QDRH_SP.ReefGuardianUpdateTick);
			end
		end
	else
		QCellDSRHelperScorepushPanel:SetHidden(true);
		CombatAlerts.dsr.panel = true;
		EVENT_MANAGER:UnregisterForUpdate(QDRH_SP.name .. "ReefGuardianUpdateTick")
	end
end


function QDRH_SP.OnPlayerActivated(eventCode, initial)
	EVENT_MANAGER:UnregisterForEvent(QDRH_SP.name .. "CombatEvent", EVENT_COMBAT_EVENT)
	EVENT_MANAGER:UnregisterForEvent(QDRH_SP.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE)

	if GetZoneId(GetUnitZoneIndex("player")) ~= QDRH.data.dreadsailReefId then
		return
	end

	if not QDRH_SP.loaded then
		QDRH_SP.loaded = true
		if QDRH_SP.savedVariables.debug then d("QDRH_SP: QDSR Scorepush Patch loaded") end
		QCellDSRHelperScorepushPanel:ClearAnchors()
		if (QDRH_SP.savedVariables.panelLeft == 0) and (QDRH_SP.savedVariables.panelTop == 100) then
			QCellDSRHelperScorepushPanel:SetAnchor(CENTER, GuiRoot, CENTER, QDRH_SP.savedVariables.panelLeft, QDRH_SP.savedVariables.panelTop)
		else
			QCellDSRHelperScorepushPanel:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, QDRH_SP.savedVariables.panelLeft, QDRH_SP.savedVariables.panelTop)
		end
	end

  	EVENT_MANAGER:RegisterForEvent(QDRH_SP.name .. "CombatEvent", EVENT_COMBAT_EVENT, QDRH_SP.CombatEvent)
	EVENT_MANAGER:RegisterForEvent(QDRH_SP.name .. "CombatState", EVENT_PLAYER_COMBAT_STATE, QDRH_SP.CombatStateEvent)
end


function QDRH_SP.OnAddonLoaded(event, addonName)
	if addonName ~= QDRH_SP.name then
		return
	end
	QDRH_SP.savedVariables = ZO_SavedVars:NewAccountWide("QcellDSRHelperScorepushPatchSavedVariables", 1, nil, QDRH_SP.settings)
	QDRH_SP.Menu.AddonMenu()
	EVENT_MANAGER:UnregisterForEvent("Qcell_DSRHelper_Scorepush_Patch", EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:RegisterForEvent("Qcell_DSRHelper_Scorepush_Patch", EVENT_PLAYER_ACTIVATED, QDRH_SP.OnPlayerActivated)
end


EVENT_MANAGER:RegisterForEvent("Qcell_DSRHelper_Scorepush_Patch", EVENT_ADD_ON_LOADED, QDRH_SP.OnAddonLoaded)