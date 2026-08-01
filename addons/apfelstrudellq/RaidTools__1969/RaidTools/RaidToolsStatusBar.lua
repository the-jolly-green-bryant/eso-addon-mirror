RaidToolsStatusBar = {}
STATUS_BAR = {}

local function OnBaseGUIMoveStop()
	local x, y = RaidTools.storage.config.ui.x, RaidTools.storage.config.ui.y
	RaidTools.storage.config.ui.x = STATUS_BAR:GetLeft()
	RaidTools.storage.config.ui.y = STATUS_BAR:GetTop()
	RaidTools.DebugMessage(string.format('UI Moved: %s, %s -> %s, %s', x, y, RaidTools.storage.config.ui.x, RaidTools.storage.config.ui.y))
end

local boss_dps
local boss_name, boss_name_fade_ticks = '', 0

function RaidToolsStatusBar.Init()
	STATUS_BAR = RaidTools.WM:CreateTopLevelWindow("RaidToolsUI")
	STATUS_BAR:SetDimensions(440, 30)
	STATUS_BAR:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, RaidTools.storage.config.ui.x, RaidTools.storage.config.ui.y)
	STATUS_BAR:SetClampedToScreen(true)
	STATUS_BAR:SetMouseEnabled(true)
	STATUS_BAR:SetMovable(true)
	STATUS_BAR:SetHidden(true)
	STATUS_BAR:SetAlpha(1)
	STATUS_BAR:SetHandler("OnMoveStop", OnBaseGUIMoveStop)

	STATUS_BAR.background = RaidTools.WM:CreateControl(nil, STATUS_BAR, CT_BACKDROP)
	STATUS_BAR.background:SetAnchorFill(STATUS_BAR)
	STATUS_BAR.background:SetEdgeTexture(nil, 1, 1, 1.0, 1.0)
	STATUS_BAR.background:SetCenterColor(0.0, 0.0, 0.0, 0.4)
	if RaidTools.storage.config.status_bar_border then
		STATUS_BAR.background:SetEdgeColor(255, 255, 255, 0.8)
	else
		STATUS_BAR.background:SetEdgeColor(255, 255, 255, 0.0)
	end
	
	STATUS_BAR.time = RaidTools.WM:CreateControl(nil, STATUS_BAR, CT_CONTROL)
	STATUS_BAR.time:SetDimensions(110, 30)
	STATUS_BAR.time:SetAnchor(TOPLEFT, STATUS_BAR, TOPLEFT, 0, 0)
	STATUS_BAR.label = RaidTools.WM:CreateControl(nil, STATUS_BAR.time, CT_LABEL);
	STATUS_BAR.label:SetDimensions(80, 25);
	STATUS_BAR.label:SetAnchor(LEFT, STATUS_BAR.time, LEFT, 34, -3);
	STATUS_BAR.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT);
	STATUS_BAR.label:SetVerticalAlignment(TEXT_ALIGN_CENTER);
	STATUS_BAR.label:SetFont('ZoFontAlert');
	STATUS_BAR.time.icon = RaidTools.WM:CreateControl(nil, STATUS_BAR.time, CT_TEXTURE)
	STATUS_BAR.time.icon:SetDimensions(25, 25)
	STATUS_BAR.time.icon:SetAnchor(LEFT, STATUS_BAR.time, LEFT, 5, -1)
	STATUS_BAR.time.icon:SetTexture("/esoui/art/tutorial/timer_icon.dds")

	STATUS_BAR.vitality = RaidTools.WM:CreateControl(nil, STATUS_BAR, CT_CONTROL)
	STATUS_BAR.vitality:SetDimensions(90, 30)
	STATUS_BAR.vitality:SetAnchor(LEFT, STATUS_BAR.time, RIGHT, 0, 0)
	STATUS_BAR.vitality.label = RaidTools.WM:CreateControl(nil, STATUS_BAR.vitality, CT_LABEL)
	STATUS_BAR.vitality.label:SetDimensions(76, 25)
	STATUS_BAR.vitality.label:SetAnchor(LEFT, STATUS_BAR.vitality, LEFT, 36, -3)
	STATUS_BAR.vitality.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	STATUS_BAR.vitality.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	STATUS_BAR.vitality.label:SetFont('ZoFontAlert')
	STATUS_BAR.vitality.icon = RaidTools.WM:CreateControl(nil, STATUS_BAR.vitality, CT_TEXTURE)
	STATUS_BAR.vitality.icon:SetDimensions(25, 25)
	STATUS_BAR.vitality.icon:SetAnchor(LEFT, STATUS_BAR.vitality, LEFT, 6, -1)
	STATUS_BAR.vitality.icon:SetTexture("/esoui/art/trials/vitalitydepletion.dds")

	STATUS_BAR.score = RaidTools.WM:CreateControl(nil, STATUS_BAR, CT_CONTROL)
	STATUS_BAR.score:SetDimensions(120, 30)
	STATUS_BAR.score:SetAnchor(LEFT, STATUS_BAR.vitality, RIGHT, 0, 0)
	STATUS_BAR.score.label = RaidTools.WM:CreateControl(nil, STATUS_BAR.score, CT_LABEL)
	STATUS_BAR.score.label:SetDimensions(85, 25)
	STATUS_BAR.score.label:SetAnchor(LEFT, STATUS_BAR.score, LEFT, 33, -3)
	STATUS_BAR.score.label:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	STATUS_BAR.score.label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	STATUS_BAR.score.label:SetFont('ZoFontAlert')
	STATUS_BAR.score.label_es = RaidTools.WM:CreateControl(nil, STATUS_BAR.score, CT_LABEL)
	STATUS_BAR.score.label_es:SetDimensions(120, 25)
	STATUS_BAR.score.label_es:SetAnchor(LEFT, STATUS_BAR.score.label, LEFT, 90, 0)
	STATUS_BAR.score.label_es:SetHorizontalAlignment(TEXT_ALIGN_LEFT)
	STATUS_BAR.score.label_es:SetVerticalAlignment(TEXT_ALIGN_CENTER)
	STATUS_BAR.score.label_es:SetFont('ZoFontAlert')
	STATUS_BAR.score.icon = RaidTools.WM:CreateControl(nil, STATUS_BAR.score, CT_TEXTURE)
	STATUS_BAR.score.icon:SetDimensions(25, 25)
	STATUS_BAR.score.icon:SetAnchor(LEFT, STATUS_BAR.score, LEFT, 5, -1)
	STATUS_BAR.score.icon:SetTexture("/esoui/art/menubar/gamepad/gp_playermenu_icon_leaderboards.dds")

	STATUS_BAR.namelabel = RaidTools.WM:CreateControl(nil, STATUS_BAR, CT_LABEL);
	STATUS_BAR.namelabel:SetDimensions(430, 25);
	STATUS_BAR.namelabel:SetAnchor(LEFT, STATUS_BAR, LEFT, 5, -3);
	STATUS_BAR.namelabel:SetHorizontalAlignment(TEXT_ALIGN_LEFT);
	STATUS_BAR.namelabel:SetVerticalAlignment(TEXT_ALIGN_CENTER);
	STATUS_BAR.namelabel:SetFont('ZoFontAlert');
	STATUS_BAR.namelabel:SetHidden(true)
	STATUS_BAR.namelabel:SetText('@apfelstrudellq')

	STATUS_BAR.fragment = ZO_HUDFadeSceneFragment:New(STATUS_BAR)
	HUD_SCENE:AddFragment(STATUS_BAR.fragment)
    HUD_UI_SCENE:AddFragment(STATUS_BAR.fragment)
    RaidToolsStatusBar.Hide()

    CALLBACK_MANAGER:RegisterCallback("OnBossFightDPSUpdate", function(dps)--function(boss, dps, start)
		--RaidTools.DebugMessage(string.format('DPSUPDATE: %s - %s', boss.name, dps))
		boss_dps = dps
	end)
	CALLBACK_MANAGER:RegisterCallback("OnBossFightStart", function(boss, hardmode)
		RaidTools.trial.hard_mode_param = RaidTools.LBF:GetKilledBosses()
		RaidTools.trial.hard_mode = hardmode
		boss_name_fade_ticks = 4
		boss_name = boss.name
	end)
end

local boss_index = 0
local boss_count = 0
local bosses = {}
local boss_history = {}
local active_boss = {}
local boss_hash = nil
local bossfight = false
local fight_start = 0

function RaidToolsStatusBar.OnTrialStart( ... )
	boss_index = 0
	boss_count = 0
	bosses = {}
	boss_history = {}
	active_boss = {}
	boss_hash = nil
	bossfight = false
	fight_start = 0
	RaidTools.trial.hard_mode_param = RaidTools.LBF:GetKilledBosses()
	RaidTools.trial.hard_mode = RaidTools.LBF:IsHardModeActive()
end

function RaidToolsStatusBar.Reset()
	bosses = {}
	boss_history = {}
	boss_index = 0
	boss_count = 0
	active_boss = {}
	boss_hash = nil
	STATUS_BAR.label:SetText('|cd100d1Init...|r')
	STATUS_BAR.vitality.label:SetText('')
	STATUS_BAR.score.label:SetText('')
	STATUS_BAR.score.label_es:SetText('')
	STATUS_BAR.vitality.icon:SetColor(1, 1, 1, 1)
	STATUS_BAR.score.icon:SetColor(1, 1, 1, 1)
	STATUS_BAR.time.icon:SetColor(1, 1, 1, 1)
end

function RaidToolsStatusBar.Show()
	if RaidTools.storage and not RaidTools.storage.modules.status_bar then return end
	RaidToolsStatusBar.Reset()
	STATUS_BAR.fragment:SetHiddenForReason("HideRaidToolBar", false)
end

function RaidToolsStatusBar.Hide()
	STATUS_BAR.fragment:SetHiddenForReason("HideRaidToolBar", true)
end

function RaidToolsStatusBar.Start()
	if not RaidTools.storage.modules.status_bar then return end
	if RaidTools.trial._status_bar_live then return end
	RaidTools.trial._status_bar_live = true
	EVENT_MANAGER:RegisterForUpdate('RaidToolsStatusBarUpdate', RaidTools.trial._update_interval, RaidToolsStatusBar.Update)
end

function RaidToolsStatusBar.Stop()
	if not RaidTools.trial._status_bar_live then return end
	RaidTools.trial._status_bar_live = false
	EVENT_MANAGER:UnregisterForUpdate('RaidToolsStatusBarUpdate')
end

function RaidToolsStatusBar.Toggle(force_show, force_hide)
	if STATUS_BAR.label:IsHidden() and not force_hide then
		STATUS_BAR.label:SetHidden(false)
		STATUS_BAR.time.icon:SetHidden(false)
		STATUS_BAR.vitality.icon:SetHidden(false)
		STATUS_BAR.vitality.label:SetHidden(false)
		STATUS_BAR.score.icon:SetHidden(false)
		STATUS_BAR.score.label:SetHidden(false)
		STATUS_BAR.score.label_es:SetHidden(false)
	elseif not force_show then
		STATUS_BAR.label:SetHidden(true)
		STATUS_BAR.time.icon:SetHidden(true)
		STATUS_BAR.vitality.icon:SetHidden(true)
		STATUS_BAR.vitality.label:SetHidden(true)
		STATUS_BAR.score.icon:SetHidden(true)
		STATUS_BAR.score.label:SetHidden(true)
		STATUS_BAR.score.label_es:SetHidden(true)
	end
end

local speed_run_times = {
	[TRIAL_HEL_RA_CITADEL] = 33*60*1000,
	[TRIAL_AETHERIAN_ARCHIVE] = 33*60*1000,
	[TRIAL_SANCTUM_OPHIDIA] = 33*60*1000,
	[TRIAL_DRAGONSTAR_ARENA] = 60*60*1000,
	[TRIAL_MAW_OF_LORKHAJ] = 40*60*1000,
	[TRIAL_MAELSTROM_ARENA] = 35*60*1000,
	[TRIAL_HALLS_OF_FABRICATION] = 40*60*1000,
	[TRIAL_ASYLUM_SANCTORIUM] = 15*60*1000,
	[TRIAL_CLOUDREST] = 15*60*1000,
	[TRIAL_BLACKROSE_PRISON] = 30*60*1000,
	[TRIAL_SUNSPIRE] = 30*60*1000
}

function RaidToolsStatusBar.Update(force)
	local duration = GetRaidDuration()
	local duration_in_seconds = duration/1000
	local score = GetCurrentRaidScore()
	local deaths = GetCurrentRaidDeaths()
	local remaining = GetRaidReviveCountersRemaining()
	if RaidTools.trial.in_progress == false or GetCurrentParticipatingRaidId() ~= RaidTools.trial.raid_id then
		if force ~= true then -- Blinking during staging phase
			STATUS_BAR.label:SetText('|cd100d1Staging|r')
			RaidToolsStatusBar.Toggle()
			return
		end
	end
	if boss_name_fade_ticks > 0 then
		RaidToolsStatusBar.Toggle(false, true)
		STATUS_BAR.namelabel:SetHidden(false)
		STATUS_BAR.namelabel:SetText('|t28:28:esoui/art/icons/mapkey/mapkey_groupboss.dds|t'..boss_name)
		boss_name_fade_ticks = boss_name_fade_ticks - 1
	elseif boss_name_fade_ticks == 0 then
		boss_name_fade_ticks = -1
		STATUS_BAR.namelabel:SetHidden(true)
		RaidToolsStatusBar.Toggle(true)
	end
	local time_prefix, estimated_score
	if RaidTools.trial.target_time_failed then
		time_prefix = '|cFF0000' -- red -> target time failed
	elseif RaidTools.trial.speed_run_failed then
		time_prefix = '|cFFA500' -- orange -> speed run failed
	else
		time_prefix = ''
	end

	local vitality_prefix
	if remaining == 0 then
		vitality_prefix = '|cFF0000'
	elseif remaining <= (GetCurrentRaidStartingReviveCounters()/4) then
		vitality_prefix = '|cFFA500'
	else
		vitality_prefix = ''
	end
	
	STATUS_BAR.label:SetText(time_prefix .. ZO_FormatTime(duration / 1000 , TIME_FORMAT_STYLE_COLONS, TIME_FORMAT_PRECISION_SECONDS).. '|r')
	STATUS_BAR.vitality.label:SetText(vitality_prefix ..remaining.. '/' .. GetCurrentRaidStartingReviveCounters()..'|r')
	STATUS_BAR.score.label:SetText('' .. score)
	if RaidTools.LBF:IsHardModeActive() then
		STATUS_BAR.score.icon:SetColor(255, 215, 0, 1)
	else
		STATUS_BAR.score.icon:SetColor(1, 1, 1, 1)
	end

	estimated_score = RaidTools.LBF:GetEstimatedScore()
	
	if (RaidTools.LBF:IsInFight(true)) then
		STATUS_BAR.score.label_es:SetText('|t30:30:esoui/art/icons/servicetooltipicons/servicetooltipicon_swords.dds|t'..FormatIntegerWithDigitGrouping(boss_dps, '.', 3))
		if estimated_score > 0 then
			STATUS_BAR.score.label:SetText('~' .. ZO_CommaDelimitNumber(estimated_score))
		end
	elseif RaidTools.LBF:IsArenaRaid() then
		STATUS_BAR.score.label:SetText('~' .. ZO_CommaDelimitNumber(estimated_score))
		STATUS_BAR.score.label_es:SetText(RaidTools.LBF:GetArenaString())
	else
		if estimated_score <= 0 then
			STATUS_BAR.score.label:SetText('~ n/a')
		else
			STATUS_BAR.score.label:SetText('~' .. ZO_CommaDelimitNumber(estimated_score))
		end
		-- RaidTools.EstimatedLeaderboardRank(false, estimated_score)
		-- (#%s) 
		STATUS_BAR.score.label_es:SetText(string.format('|t30:30:%s|t %s |t30:30:%s|t%s', 'esoui/art/icons/crafting_skeleton_skull.dds', RaidTools.GetMyDeaths(), 'esoui/art/icons/servicetooltipicons/servicetooltipicon_swords.dds', '---', 'esoui/art/icons/soulgem_006_filled.dds', RaidTools.GetMyRez()))
	end
	
	if duration >= speed_run_times[GetCurrentParticipatingRaidId()] then
		if not RaidTools.trial.speed_run_failed then
			RaidTools.trial.speed_run_failed = true
			RaidTools.BrandedMessage('Speed-run failed!')
		end
	end
	if duration >= RaidTools.trial.target_time then
		if not RaidTools.trial.target_time_failed then
			RaidTools.trial.target_time_failed = true
			RaidTools.BrandedMessage('Target time exceeded!')
		end
	end
end