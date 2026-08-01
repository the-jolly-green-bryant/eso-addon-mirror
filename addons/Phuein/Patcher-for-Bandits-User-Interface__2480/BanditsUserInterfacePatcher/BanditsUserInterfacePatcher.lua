--[[
    This addon is a template that helps developers create new addons.
    Most parts can be removed or modified to need.
--]]

BUIPatcher = {
    name            = "BanditsUserInterface Patcher",
    author          = "Developer",
    color           = "DDAAEE",
    menuName        = "Bandits User Interface Patcher",
}

-- Default settings.
BUIPatcher.savedVars = {
    firstLoad = true,                   -- First time the addon is loaded ever.
    accountWide = false,                -- Load settings from account savedVars, instead of character.
    distanceSensitivity = 400,
}

-- Wraps text with a color.
function BUIPatcher.Colorize(text, color)
    -- Default to addon's .color.
    if not color then color = BUIPatcher.color end

    text = string.format('|c%s%s|r', color, text)

    return text
end

function BUIPatcher.NewLeaderArrow()
    local texture=BUI_LeaderBar
	local width=74
	local scaleX,scaleY=BUI.MapData()
	if not texture then
		texture=WINDOW_MANAGER:CreateControl("BUI_LeaderBar", ZO_ReticleContainerReticle, CT_TEXTURE)
		texture:SetDimensions(width,width/3*2)
		texture:ClearAnchors()
		texture:SetAnchor(BOTTOM,ZO_ReticleContainerReticle,CENTER,0,0)
		texture:SetTexture('/BanditsUserInterface/textures/reticle/arrow_bar.dds')
    end

    -- Modifications to texture.
    texture:SetColor(1, 0.1, 0.2, 0)

    texture:SetHidden(true)
	EVENT_MANAGER:UnregisterForUpdate("BUI_OnScreen_LeaderBar")

	local function NormalizeAngle(angle)
		if angle>math.pi then return angle-2*math.pi end
		if angle<-math.pi then return angle+2*math.pi end
		return angle
	end

	local function LeaderBar()
        texture:SetHidden(true)

        -- Active only in Cyrodiil.
        if GetCurrentMapIndex() ~= GetCyrodiilMapIndex() then return end

		local tX, tY, _, inCurrentMap=GetMapPlayerPosition(BUI.GroupLeader)
		if inCurrentMap then
			local pX, pY=GetMapPlayerPosition("player")
            local dist=math.max(math.min(math.sqrt(((pX-tX)*scaleX)^2+((pY-tY)*scaleY)^2)*BUIPatcher.savedVars.distanceSensitivity, .75), .01)
			-- if dist > .1 then
            local angle=NormalizeAngle(math.atan2(pX-tX,pY-tY)-NormalizeAngle(GetPlayerCameraHeading()))
            -- texture:SetTextureCoords(dist/2,1-dist/2,0,1)
            -- texture:SetWidth(width*(d))
            -- d(dist)
            texture:SetAlpha(dist)
            texture:SetTextureRotation(angle,.5,1)
            texture:SetHidden(false)
			-- end
		end
	end

	if BUI.Vars.LeaderArrow and IsUnitGrouped('player') and BUI.GroupLeader and GetUnitDisplayName(BUI.GroupLeader)~=BUI.Player.accname then
		EVENT_MANAGER:RegisterForUpdate("BUI_OnScreen_LeaderBar", 40, LeaderBar)
	end
end

function BUIPatcher.Activated(e)
    EVENT_MANAGER:UnregisterForEvent(BUIPatcher.name, EVENT_PLAYER_ACTIVATED)

    if BUIPatcher.savedVars.firstLoad then
        BUIPatcher.savedVars.firstLoad = false

        -- Modify BUI here.
        if BUI and BUI.Reticle then
            if BUI.Reticle.LeaderArrow then
                BUI.Reticle.LeaderArrow = BUIPatcher.NewLeaderArrow
            else
                d(BUIPatcher.Colorize('BUIPatcher: ', 'FFFFFF') .. 'BUI.Reticle.LeaderArrow not found.')
            end
        else
            d(BUIPatcher.Colorize('BUIPatcher: ', 'FFFFFF') .. 'BUI not found.')
        end
    end
end
-- When player is ready, after everything has been loaded.
EVENT_MANAGER:RegisterForEvent(BUIPatcher.name, EVENT_PLAYER_ACTIVATED, BUIPatcher.Activated)

function BUIPatcher.OnAddOnLoaded(event, addonName)
    if addonName ~= BUIPatcher.name then return end
    EVENT_MANAGER:UnregisterForEvent(BUIPatcher.name, EVENT_ADD_ON_LOADED)

    -- Load saved variables.
    -- BUIPatcher.characterSavedVars = ZO_SavedVars:New("BUIPatcherSavedVariables", 1, nil, BUIPatcher.savedVars)
    -- BUIPatcher.accountSavedVars = ZO_SavedVars:NewAccountWide("BUIPatcherSavedVariables", 1, nil, BUIPatcher.savedVars)

    -- if not BUIPatcher.characterSavedVars.accountWide then
    --     BUIPatcher.savedVars = BUIPatcher.characterSavedVars
    -- else
    --     BUIPatcher.savedVars = BUIPatcher.accountSavedVars
    -- end

    -- Settings menu in Settings.lua.
    -- BUIPatcher.LoadSettings()

    -- Reset autocomplete cache to update it.
    -- SLASH_COMMAND_AUTO_COMPLETE:InvalidateSlashCommandCache()
end
-- When any addon is loaded, but before UI (Chat) is loaded.
EVENT_MANAGER:RegisterForEvent(BUIPatcher.name, EVENT_ADD_ON_LOADED, BUIPatcher.OnAddOnLoaded)