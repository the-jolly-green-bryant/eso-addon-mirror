---------------------
-- General utility --
---------------------

local ADDON_LOGO = "esoui/art/menubar/gamepad/gp_playermenu_icon_crowncrates.dds"

-- This table is used to publicly expose certain functions and variables
CrownCrateTracker = {
	ADDON_NAME = "CrownCrateLogger",
	MAIL_RECIPIENT = { "@Faunter", "@Faunter2", "@Faunter3" },
	MAX_REWARDS_SUPPORTED = 5,

	ICON_CSA = string.format("|t64:64:%s|t", ADDON_LOGO),
	ICON_NOTICE = string.format("|t150%%:150%%:%s|t", ADDON_LOGO),

	DURATION_LONGEST = 15000,
	DURATION_LONG = 10000,
	DURATION_MEDIUM = 7000,
	DURATION_SHORT = 4000,
	DURATION_SHORTEST = 1000,

	MAIL_TIMEOUT_TICKS = 10,
	mailTicksLeft = 10,

	STATE_REFRESHING = 0,
	STATE_IDLE = 1,
	STATE_ANNOUNCING = 2,
	STATE_MAILING_NORMAL = 3,
	STATE_MAILING_MUTED = 4,
	currentState = 0,

	hasMailPending = false,
	isLastMail = false,
	savedVariables
}

-- This function is called when the player wants to visit the website
function CrownCrateTracker.VisitWebsite()
	RequestOpenUnsafeURL("https://www.crowncrates.com")
end

-- This function handles all of the center screen announcing for the addon
function CrownCrateTracker.ShowCSA(category, sound, message, combinedMessage, lifespanMS)

	CrownCrateTracker.currentState = CrownCrateTracker.STATE_ANNOUNCING

	-- Create the message parameters and add the message
	local messageParams = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(category, sound)
	messageParams:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_SYSTEM_BROADCAST) -- Best fit to allow during crafting
	messageParams:SetText(message, combinedMessage)
	messageParams:SetLifespanMS(lifespanMS)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(messageParams)

	-- Reset the addon state to idle once all announcements have been cleared
	local function WaitForAllClear()
		local hasAnyActiveLines = CENTER_SCREEN_ANNOUNCE:HasAnyActiveLines()
		if not hasAnyActiveLines then
			EVENT_MANAGER:UnregisterForUpdate("CrownCrateTrackerAnnouncing")
			CrownCrateTracker.currentState = CrownCrateTracker.STATE_IDLE
		end
	end
	EVENT_MANAGER:RegisterForUpdate("CrownCrateTrackerAnnouncing", CrownCrateTracker.DURATION_SHORTEST, WaitForAllClear)
end

-- This function prints a crate-tracker-stylized message to the chatbox
function CrownCrateTracker.ShowChatNotice(notice)

	local defaultFont = "EsoUI/Common/Fonts/Univers57.otf"
	local defaultSize = 18
	local defaultWeight = "soft-shadow-thin"

	local font, size, weight = ChatContainer:GetChatFont():GetFontInfo()

	if font == defaultFont and size == defaultSize and weight == defaultWeight then
		CHAT_SYSTEM:AddMessage(string.format("%s %s", CrownCrateTracker.ICON_NOTICE, notice))
	else
		CHAT_SYSTEM:AddMessage(string.format("[Crown Crate Tracker] %s", notice))
	end
end





------------------------
--- Crate submitting ---
------------------------

-- This function searches for unsubmitted crate results and mails them
function CrownCrateTracker.MailCrateResults()

	local totalCrates = #CrownCrateData.Crates["Crate info"]

	-- If this is the first time firing up the addon, set allSubmitted to true
	-- Otherwise allSubmitted would already be true and this function wouldn't have been called
	if totalCrates == 0 then
		CrownCrateTracker.savedVariables.allSubmitted = true
		return
	end

	-- Decide how we will mail the results based on if a mail error had previously occurred
	if CrownCrateTracker.savedVariables.mailErrorOccurred then
		CrownCrateTracker.currentState = CrownCrateTracker.STATE_MAILING_MUTED
	else
		CrownCrateTracker.currentState = CrownCrateTracker.STATE_MAILING_NORMAL
		CrateTrackerLoading:SetHidden(false)
	end

	-- The current latency is used as a mailing interval to help prevent mail lag issues
	-- Latency usually ranges from 100-300, so multiplying it by 10 gives us about 1-3 seconds between mails
	local mailInterval = GetLatency() * 10

	-- Create a 360-degree clockwise rotation animation over mailInterval seconds for the loading texture
	local animation, timeline = CreateSimpleAnimation(ANIMATION_TEXTUREROTATE, CrateTrackerLoadingTexture, 0)
	animation:SetDuration(mailInterval)
	animation:SetRotationValues(0, -math.pi*2)

	-- This function gets registered for an update every mailInterval seconds
	local function SendCrateMail()

		-- Restart the animation to make it appear as infinitely looping
		timeline:PlayFromStart()

		-- If there is a crate mail pending, that means there's mail lag and we're still waiting for the previous crate mail to get sent
		if CrownCrateTracker.hasMailPending then
			if CrownCrateTracker.mailTicksLeft > 0 then
				-- We haven't reached the time limit yet, so update the text and decrement the ticks
				local mailLagText = string.format("%s |cC64343(%s)|r", GetString(SI_CROWN_CRATE_TRACKER_MAIL_LAG), CrownCrateTracker.mailTicksLeft)
				CrateTrackerLoadingLabel:SetText(mailLagText)
				CrownCrateTracker.mailTicksLeft = CrownCrateTracker.mailTicksLeft - 1
			else
				-- We've reached the time limit, so manually cancel the mailing process
				CrownCrateTracker.OnMailSendFailed(-1, -1)
			end
		else
			-- There is no crate mail pending, so we're ready to send the next mail
			CrownCrateTracker.hasMailPending = true

			local mailBody = ""
			local mailBodyNumChars = 0
			local cratesInMail = 0

			-- Go through every recorded crate and search for ones that are unsubmitted (or preparing, in case the player had previously quit the game mid-mail)
			for i = 1, totalCrates do
				local currentCrate = CrownCrateData.Crates["Crate info"][i]
				if currentCrate.Status == "Unsubmitted" or currentCrate.Status == "Preparing" then

					local dataString = currentCrate.Data
					local dataStringLength = dataString:len()

					-- If the current crate's data can't fit inside this mail, exit the loop
					if mailBodyNumChars + dataStringLength > MAIL_MAX_BODY_CHARACTERS then
						break
					end

					-- This crate's data can fit, so append it to the current mail's body
					mailBody = string.format("%s%s", mailBody, dataString)
					mailBodyNumChars = mailBodyNumChars + dataStringLength
					currentCrate.Status = "Preparing"
					cratesInMail = cratesInMail + 1
				end

				-- If this is the last crate, set a flag to display the final announcement and unregister the update in OnMailSendSuccess()
				-- This is out here as a precaution in case the last crate is somehow already submitted while previous ones weren't
				if i == totalCrates then
					CrownCrateTracker.isLastMail = true
				end
			end

			-- If there are no new crates to send, unregister the update, close the mailbox, prepare for future mails, and exit the function
			-- This is a failsafe in case we somehow end up here with nothing to submit, but that shouldn't happen (but you never know (but it shouldn't happen))
			if cratesInMail == 0 then
				EVENT_MANAGER:UnregisterForUpdate("CrownCrateTrackerSubmit")
				zo_callLater(CloseMailbox, CrownCrateTracker.DURATION_SHORTEST)

				CrateTrackerLoading:SetHidden(true)
				CrownCrateTracker.isLastMail = false
				CrownCrateTracker.hasMailPending = false
				CrownCrateTracker.savedVariables.allSubmitted = true
				CrownCrateTracker.mailTicksLeft = CrownCrateTracker.MAIL_TIMEOUT_TICKS

				CrownCrateTracker.currentState = CrownCrateTracker.STATE_IDLE

				return
			end

			CrateTrackerLoadingLabel:SetText(GetString(SI_CROWN_CRATE_TRACKER_MAIL_SENDING))

			-- Send a mail containing the crate results to a random recipient
			-- This effectively increases the mailbox buffer size to allow for breathing room during periods of high activity
			-- It also helps avoid potential loss of data due to sometimes-unpredictable inbox behavior
			RequestOpenMailbox()
			SendMail(CrownCrateTracker.MAIL_RECIPIENT[math.random(1, #CrownCrateTracker.MAIL_RECIPIENT)], "Crown Crate Data", mailBody)
		end
	end

	-- Begin the animation earlier so it feels more responsive
	timeline:PlayFromStart()

	-- Keep sending mails containing unsubmitted crown crate results until they've all been submitted or until a mail error occurs
	EVENT_MANAGER:RegisterForUpdate("CrownCrateTrackerSubmit", mailInterval, SendCrateMail)
end

-- This function is called after any mail is successfully delivered
-- It reacts to successful mails sent by the addon
function CrownCrateTracker.OnMailSendSuccess(eventCode)

	-- If the mail wasn't sent by the addon, ignore it
	if not CrownCrateTracker.hasMailPending then
		return
	end

	-- Go through every single crate and mark the ones that were sent as submitted
	local totalCrates = #CrownCrateData.Crates["Crate info"]
	for i = 1, totalCrates do
		local currentCrate = CrownCrateData.Crates["Crate info"][i]
		if currentCrate.Status == "Preparing" then
			currentCrate.Status = "Submitted"
		end
	end

	-- Display a mail success notice in the chat
	CrownCrateTracker.ShowChatNotice(GetString(SI_CROWN_CRATE_TRACKER_MAIL_SUCCESS))

	-- If this was the last mail, we should unregister the update, close the mailbox, and display a final success announcement
	if CrownCrateTracker.isLastMail then
		EVENT_MANAGER:UnregisterForUpdate("CrownCrateTrackerSubmit")
		zo_callLater(CloseMailbox, CrownCrateTracker.DURATION_SHORTEST)

		CrownCrateTracker.isLastMail = false
		CrownCrateTracker.savedVariables.allSubmitted = true
		CrateTrackerLoading:SetHidden(true)

		CrownCrateTracker.ShowCSA(CSA_CATEGORY_LARGE_TEXT, SOUNDS.OBJECTIVE_COMPLETED, string.format("|cEECA2A%s|r", GetString(SI_CROWN_CRATE_TRACKER_MAIL_DONE)),
			GetString(SI_CROWN_CRATE_TRACKER_MAIL_THANKS), CrownCrateTracker.DURATION_MEDIUM)
		CrownCrateTracker.ShowChatNotice(GetString(SI_CROWN_CRATE_TRACKER_MAIL_FINAL))

	elseif CrownCrateTracker.currentState == CrownCrateTracker.STATE_MAILING_MUTED then

		-- A previous mail error was fixed by sending this mail, and there are more mails to send
		-- Set the addon state to normal mailing and show the loading
		CrownCrateTracker.currentState = CrownCrateTracker.STATE_MAILING_NORMAL
		CrateTrackerLoading:SetHidden(false)
	end

	-- Prepare for future mails
	CrownCrateTracker.hasMailPending = false
	CrownCrateTracker.savedVariables.mailErrorOccurred = false
	CrownCrateTracker.mailTicksLeft = CrownCrateTracker.MAIL_TIMEOUT_TICKS
end

-- This function is called after an error occurs during the mailing process
-- It reacts to unsuccessful mails sent by the addon
function CrownCrateTracker.OnMailSendFailed(eventCode, reason)

	-- If the mail wasn't sent by the addon, ignore it
	if not CrownCrateTracker.hasMailPending then
		return
	end

	-- Something went wrong while sending a mail, so we should no longer try to send more
	EVENT_MANAGER:UnregisterForUpdate("CrownCrateTrackerSubmit")
	zo_callLater(CloseMailbox, CrownCrateTracker.DURATION_SHORTEST)

	-- Go through every single crate and revert the ones that failed back to unsubmitted
	local totalCrates = #CrownCrateData.Crates["Crate info"]
	for i = 1, totalCrates do
		local currentCrate = CrownCrateData.Crates["Crate info"][i]
		if currentCrate.Status == "Preparing" then
			currentCrate.Status = "Unsubmitted"
		end
	end

	-- Prepare for future mails
	CrownCrateTracker.isLastMail = false
	CrownCrateTracker.hasMailPending = false
	CrownCrateTracker.mailTicksLeft = CrownCrateTracker.MAIL_TIMEOUT_TICKS

	-- To prevent spam, only display an error message if the addon wasn't mailing in muted mode
	if CrownCrateTracker.currentState == CrownCrateTracker.STATE_MAILING_MUTED then
		CrownCrateTracker.currentState = CrownCrateTracker.STATE_IDLE
	else
		CrownCrateTracker.savedVariables.mailErrorOccurred = true

		local errorMessage
		local tryAgain
		local sound

		if reason == MAIL_SEND_RESULT_FAIL_MAILBOX_FULL then
			errorMessage = GetString(SI_CROWN_CRATE_TRACKER_MAIL_FAILURE_CAUSE_SPIKE)
			tryAgain = GetString(SI_CROWN_CRATE_TRACKER_MAIL_FAILURE_EFFECT_QUEUED)
			sound = SOUNDS.TUTORIAL_INFO_SHOWN
		elseif reason == -1 then
			-- reason -1 means a mail was manually canceled because of lag
			errorMessage = GetString(SI_CROWN_CRATE_TRACKER_MAIL_FAILURE_CAUSE_DELAYS)
			tryAgain = GetString(SI_CROWN_CRATE_TRACKER_MAIL_FAILURE_EFFECT_RETRY)
			sound = SOUNDS.QUEST_STEP_FAILED
		else
			errorMessage = string.format("|cC64343%s %s:|r %s", GetString(SI_CROWN_CRATE_TRACKER_MAIL_FAILURE_CAUSE_ERROR), reason, GetString(SI_CROWN_CRATE_TRACKER_MAIL_FAILURE_CAUSE_GENERIC))
			tryAgain = GetString(SI_CROWN_CRATE_TRACKER_MAIL_FAILURE_EFFECT_LATER)
			sound = SOUNDS.QUEST_STEP_FAILED
		end

		-- Hide the loading and display the error message
		CrateTrackerLoading:SetHidden(true)
		CrownCrateTracker.ShowChatNotice(string.format("%s %s", errorMessage, tryAgain))
		local csaMessage = string.format("%s %s\n%s", CrownCrateTracker.ICON_CSA, errorMessage, tryAgain)
		CrownCrateTracker.ShowCSA(CSA_CATEGORY_MAJOR_TEXT, sound, csaMessage, nil, CrownCrateTracker.DURATION_LONG)
	end
end