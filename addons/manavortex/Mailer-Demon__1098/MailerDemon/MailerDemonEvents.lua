
local scenes = {
	["bank"] = false,
	["guildBank"] = false,
	["tradinghouse"] = false,
	["smithing"] = false,
	["store"] = false,
	["stables"] = false,
	["trade"] = false,
	["inventory"] = false,
	["hud"] = false,
	["hudui"] = false,
	["mailInbox"] = true,
	["mailSend"] = true,
}

local function showButtons() 
	MailerDemon_Bait:SetHidden(not(MailerDemon.IsActive("Bait")))
	MailerDemon_Bounce:SetHidden(not(MailerDemon.IsActive("Bounce")))
	MailerDemon_Decon:SetHidden(not(MailerDemon.IsActive("Decon")))
	MailerDemon_Ref:SetHidden(not(MailerDemon.IsActive("Ref")))
	MailerDemon_Materials:SetHidden(not(MailerDemon.IsActive("Materials")))
	MailerDemonMain:SetHidden(false)	
end

function MailerDemon_HideButtons() 
	MailerDemonMain:SetHidden(true)	
end


function MailerDemon_ProcessSceneChange(sceneName, oldState, newState)
	-- d("MailerDemon_ProcessSceneChange called for " .. tostring(sceneName) .. ": " .. tostring(oldState) .. " => " .. tostring(newState))
	if (tostring(newState) == "shown") then
		if scenes[sceneName] then 
			showButtons()
		end
	else
		MailerDemon_HideButtons() 
	end
end

local function hookupScene(sceneName)
	local scene = SCENE_MANAGER:GetScene(sceneName)
	if nil == scene then return end
	scene:RegisterCallback("StateChange", function(...)
		MailerDemon_ProcessSceneChange(sceneName, ...)	
	end)
end


function MailerDemon_RegisterEvents()

    EVENT_MANAGER:RegisterForEvent( "MailerDemon_MailFail", EVENT_MAIL_SEND_FAILED, MailerDemon_MailFail)
    EVENT_MANAGER:RegisterForEvent( "MailerDemon_MailFail", EVENT_MAIL_SEND_FAILED, MailerDemon_MailFail)
    EVENT_MANAGER:RegisterForEvent("MailerDemon_EnterCombat", EVENT_PLAYER_COMBAT_STATE, MailerDemon_OnPlayerCombatState)

	for sceneName, visibility in pairs(scenes) do
		hookupScene(sceneName)
	end	
	
	
	
end