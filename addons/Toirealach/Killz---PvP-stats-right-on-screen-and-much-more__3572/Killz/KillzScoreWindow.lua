-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- The Killz score window that sits in the upper right corner of the window
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

Killz = Killz or {}

local LCLSTR = Killz.Localization

local initTries = 0
function Killz.ScoreWindow_OnInitialized()
    -- Keep calling ourselves recursively up to ten times until the Saved Variables are loaded in.
    -- Why? Because we need the saved variables to restore our window position

	if not Killz.settings then 
        initTries = initTries + 1
        if initTries <= 10 then zo_callLater(function() Killz.ScoreWindow_OnInitialized() end, 1000) end
    else
	    Killz.ScoreWindow_RestorePosition()
	    KillzScoreWindow:SetMovable(not(Killz.settings.statsBarLocked))
		local fragment = ZO_SimpleSceneFragment:New(KillzScoreWindow)
		HUD_SCENE:AddFragment(fragment)
		HUD_UI_SCENE:AddFragment(fragment)
    end
end

local shouldMinimise = false
function Killz.ScoreWindow_OnMouseDoubleClick()
	
end

function Killz.ScoreWindow_Update()

	local statsStr = nil

	-- If we are in a PvP Zone or hiding stats in PvE is turned off then compute stats string

	if IsPlayerInPvP() or (Killz.settings.hideInPvE == false) then 
				
		local kills = Killz.settings.sessionStats.kills or 0
		local killStreak = Killz.settings.sessionStats.killStreak or 0
		local killingBlows = Killz.settings.sessionStats.killingBlows or 0
		local kbStreak = Killz.settings.sessionStats.kbStreak or 0
		local deaths = Killz.settings.sessionStats.deaths or 0
		local ap = Killz.settings.sessionStats.alliancePoints or 0
		local killsPerDeath = kills or 0

		if deaths > 0 then killsPerDeath = kills/deaths end

		local abbrevStr = Colorz.ltPurple:Colorize(string.format("%s:", LCLSTR.KILLS_ABBREVIATION))
		local valStr = tostring(kills)
		if killStreak > 0 then valStr = valStr..string.format(" [%d]", killStreak) end
		valStr = Colorz.justWhite:Colorize(valStr)
		local killsStr = abbrevStr.." "..valStr
		
		abbrevStr = Colorz.orange:Colorize(string.format("%s:", LCLSTR.DEATHS_ABBREVIATION))
		valStr = tostring(deaths)
		if kills > 0 and deaths > 0 then valStr = valStr..string.format(" (%.1f)", killsPerDeath) end
		valStr = Colorz.justWhite:Colorize(valStr)
		local deathsStr = abbrevStr.." "..valStr
		
		abbrevStr = Colorz.bloodRed:Colorize(string.format("%s:", LCLSTR.KBS_ABBREVIATION))
		valStr = tostring(killingBlows)
		if kbStreak > 0 then valStr = valStr..string.format(" [%d]", kbStreak) end
		valStr = Colorz.justWhite:Colorize(valStr)
		local killingBlowsStr = abbrevStr.." "..valStr
		
		abbrevStr = Colorz.alliancePts:Colorize(string.format("%s:", LCLSTR.AP_ABBREVIATION))
		valStr = Colorz.justWhite:Colorize(tostring(ap))
		local apStr = abbrevStr.." "..valStr
	
		statsStr = string.format("%s   %s   %s   %s", killsStr, deathsStr, killingBlowsStr, apStr)
	end

	local qStr = nil
	local timeStr = nil

	if Killz.queuedCampaignID then

		if Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_JOIN then qStr = LCLSTR.Q_STATE_QUEUEING	
		elseif Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_ACCEPT then qStr = LCLSTR.Q_STATE_ENTERING 	
		elseif Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_PENDING_LEAVE then qStr = LCLSTR.Q_STATE_LEAVING 	
		elseif Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_CONFIRMING then qStr = LCLSTR.Q_STATE_CONFIRMING 	
		elseif Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING then qStr = LCLSTR.Q_STATE_WAITING	
		elseif Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_FINISHED then qStr = LCLSTR.Q_STATE_FINISHED
		else qStr = LCLSTR.Q_STATE_UNKNOWN end -- This should never happen

		qStr = string.format(qStr, GetCampaignName(Killz.queuedCampaignID) or LCLSTR.UNKNOWN_Q)

		if Killz.queueState == CAMPAIGN_QUEUE_REQUEST_STATE_WAITING and Killz.queuePosition ~= nil then
			qStr = string.format(LCLSTR.Q_NUMBER..qStr, Killz.queuePosition)

			if Killz.queueTimeInSecs and Killz.queueTimeInSecs > 0 then
				timeStr = FormatTimeSeconds(Killz.queueTimeInSecs, 
											TIME_FORMAT_STYLE_DESCRIPTIVE_MINIMAL, 
											TIME_FORMAT_PRECISION_SECONDS, 
											TIME_FORMAT_DIRECTION_DESCENDING)
				timeStr = string.format(LCLSTR.Q_TIME, timeStr)
			end 
		end

	end

	local topLine = statsStr
	local bottomLine = qStr

	-- If no stats but queue status, move queue status to top line
	if not topLine and bottomLine then 
		topLine = bottomLine
		topLine = Colorz.white:Colorize(topLine)
		if not timeStr and Killz.campTimerStr then timeStr = Killz.campTimerStr end
		bottomLine = timeStr -- Set time in queue or camp respawn timer to the bottom line, if it exists
	elseif bottomLine and timeStr then
		bottomLine = bottomLine..".  "..timeStr
	elseif Killz.campTimerStr ~= nil then
		bottomLine = Killz.campTimerStr
	end

	if bottomLine then bottomLine = Colorz.white:Colorize(bottomLine) end -- make sure any bottom line is white

	if topLine then
		KillzScoreWindowTopLabel:SetHidden(false)
		KillzScoreWindowTopLabel:SetText(topLine)
	else KillzScoreWindowTopLabel:SetHidden(true) end

	-- Adjust the window width for the size of the text in top line
	local topWidth = KillzScoreWindowTopLabel:GetTextWidth() + 60

	if bottomLine then
		KillzScoreWindowBottomLabel:SetHidden(false)
		KillzScoreWindowBottomLabel:SetText(bottomLine)
	else 
		KillzScoreWindowBottomLabel:SetHidden(true) 
	end

	local shouldHideWindow = false

	if (topLine == nil and bottomLine == nil) then

		-- Either hide the window completely or minimize it 
	 	if Killz.settings.hideInPvE == true then
			-- Minimize window by setting topWidth to 40 & make sure icon button is visible
			topWidth = 40
	 	end
	end

	-- KillzScoreWindowOppWinBtn:SetHidden(shouldHideWindow)
	if KillzScoreWindow:GetWidth() ~= topWidth then KillzScoreWindow:SetWidth(topWidth) end
	KillzScoreWindow:SetHidden(shouldHideWindow)
end

function Killz.ScoreWindow_Scale()
	Killz.settings.scoreWindowScale = Killz.settings.scoreWindowScale or 0
	local scaleModifier = 1 + (Killz.settings.scoreWindowScale/100)
	if KillzScoreWindow:GetScale() ~= scaleModifier then KillzScoreWindow:SetScale(scaleModifier) end
end

function Killz.ScoreWindow_ToggleHidden()
	KillzScoreWindow:SetHidden(not KillzScoreWindow:IsHidden())
end

function Killz.ScoreWindow_Show()
	Killz.ScoreWindow_Update()	
	KillzScoreWindow:SetHidden(false)
end

function Killz.ScoreWindow_Hide()
	KillzScoreWindow:SetHidden(true)
end

function Killz.ScoreWindow_SaveAnchor()

	local 	isValidAnchor, 
			currAnchorPoint, 
			relativeTo, 
			relativePoint, 
			currXOff, 
			currYOff, 
			anchorConstrains = KillzScoreWindow:GetAnchor()

	Killz.settings.ScoreWindow = { anchorPoint = currAnchorPoint, xOff = currXOff, yOff = currYOff }
	-- d(string.format("Kills.ScoreWindow: anchor = %s, xOff = %s, yOff = %s", tostring(currAnchorPoint), tostring(currXOff), tostring(currYOff)))
end

function Killz.AdjustBtmLabel()

	-- Move the "bottom" line to above the "top" line if the user 
	-- puts the stats bar near the botton of the screen

	local btmLineOffset = 27
	if Killz.settings.ScoreWindow.anchorPoint == 6 or Killz.settings.ScoreWindow.anchorPoint == 12 then btmLineOffset = -27 end

	local 	isValidAnchor, 
			currAnchorPoint, 
			relativeTo, 
			relativePoint, 
			currXOff, 
			currYOff, 
			anchorConstrains = KillzScoreWindowBottomLabel:GetAnchor()
	
	if currYOff ~= btmLineOffset then
		currYOff = btmLineOffset
		KillzScoreWindowBottomLabel:SetAnchor(currAnchorPoint, relativeTo, relativePoint, currXOff, currYOff, anchorConstrains)
		-- d(string.format("KillzScoreWindowBottomLabel: anchor = %s, xOff = %s, yOff = %s", tostring(currAnchorPoint), tostring(currXOff), tostring(currYOff)))
	end
end

function Killz.ScoreWindow_OnMoveStop()
	Killz.ScoreWindow_SaveAnchor()
	Killz.AdjustBtmLabel()
end

function Killz.ScoreWindow_RestorePosition()
	
	if Killz.settings.windownchorPoint and not Killz.settings.ScoreWindow then
        Killz.settings.ScoreWindow = { anchorPoint = Killz.settings.windowAnchorPoint, xOff = Killz.settings.windowXOff, yOff = Killz.settings.windowYOff}
	end

	-- Save original window position if doesn't exist yet
	if not Killz.settings.ScoreWindow then Killz.ScoreWindow_SaveAnchor() end

	-- FYI: If you fuck up the XML file you'll get a nil error here when loading the addon
	KillzScoreWindow:ClearAnchors()
	KillzScoreWindow:SetAnchor(Killz.settings.ScoreWindow.anchorPoint, GuiRoot, nil, Killz.settings.ScoreWindow.xOff, Killz.settings.ScoreWindow.yOff)
	Killz.AdjustBtmLabel()
end

local confirmDialogSetup = false

function Killz.ShowScoreResetDialog(data, textParams)

	if not confirmDialogSetup then 

		ZO_Dialogs_RegisterCustomDialog("CONFIRM_KILLZ_PVP_STATS_RESET",
		{
			gamepadInfo =
			{
				dialogType = GAMEPAD_DIALOGS.BASIC,
			},
			title =
			{
				text = LCLSTR.CONFIRM_STATS_RESET_TITLE,
			},
			mainText =
			{
				text = LCLSTR.CONFIRM_STATS_RESET_TEXT,
			},
			buttons =
			{
				{
					text = LCLSTR.CONFIRM_YES,
					callback = function(dialog)
						Killz.resetSessionStats()
						Killz.ScoreWindow_Update()
					end,
				},
				{
					text = LCLSTR.CONFIRM_NO,
				}
			}
		})
	
		confirmDialogSetup = true
	end

    ZO_Dialogs_ShowPlatformDialog("CONFIRM_KILLZ_PVP_STATS_RESET", data, textParams)
end

function Killz.ScoreWindow_OnDoubleClick()

	Killz.ShowScoreResetDialog()
	
end

