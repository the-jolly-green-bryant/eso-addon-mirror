-- Initialize File
ZDAT           = ZDAT or {}
ZDAT.UI        = ZDAT.UI or {}
ZDAT.UI.Icons = {}

------------------------------------------------------------------------------------------------------------------
-- Basic Icon  
------------------------------------------------------------------------------------------------------------------
function ZDAT.UI.Icons.basic(data)
	data.s   = data.s or ZDAT.UI.Constants.iconSize
    data.c   = data.c or  ZDAT.UI.Constants.rgbWhite
    data.tta = data.tta or BOTTOM -- tooltip anchor
	data.ttf = data.ttf or ZDAT.UI.Constants.tooltipFont
	data.ttc = data.ttc or ZDAT.UI.Constants.hexGold

	-- static settings
	local control = WINDOW_MANAGER:CreateControl("$(parent)_Icon" .. ZDAT.Utils.uid(), ZDAT_GUI, CT_TEXTURE)
	control:SetDimensions(data.s, data.s)      
	control:SetTexture(data.t) 
    control:SetColor(unpack(data.c))
	control:SetDrawTier(DT_HIGH)
	
    -- optionally add tooltip
	if data.tt then
		control:SetMouseEnabled(true)
		control:SetHandler("OnMouseEnter", function(control) 
			ZO_Tooltips_ShowTextTooltip(control, data.tta)
			InformationTooltip:AddLine(string.format('|%s%s|r', data.ttc, data.tt), data.ttf)
			end)
		control:SetHandler("OnMouseExit", function (control) 
			ClearTooltip(InformationTooltip)
			end)  
	end		

    -- optionally setup conditional visibility
	if data.v then
		ZDAT.UI.Layout.registerRefreshFn(function()
			control:SetHidden(not data.v())
			end)
	end
	
	return control
end

------------------------------------------------------------------------------------------------------------------
-- Achievement Icon  
------------------------------------------------------------------------------------------------------------------
function ZDAT.UI.Icons.achievement(data)
	-- if aid is nil, use static icon
	if data.a==nil then 
        -- can also use this for future AIDS, defined but doesn't exist check add following to if statement
        -- ZDAT.utils.aidExists(data.aid)
        data.t  = ZDAT.UI.Constants.texture.X
		data.c  = ZDAT.UI.Constants.rgbGray
		data.tt = 'does not exist'
		return ZDAT.UI.Icons.basic(data)
	end
		

	-- create control
	local control = ZDAT.UI.Icons.basic(data)
	control:SetMouseEnabled(true)
	control:SetHandler("OnMouseExit",  function (control) 
		ClearTooltip(InformationTooltip)
		ClearTooltip(ItemTooltip)
		end)
		
	-- if ESOAPI returns link, use achievement tt, else use "coming soon" tt
	local released = GetAchievementIdFromLink(GetAchievementLink(data.a,1)) ~= 0 -- kinda hacky existance check
	if released then

		-- set hover
		control:SetHandler("OnMouseEnter", function(control) 
			InitializeTooltip(ItemTooltip, control, TOP, 0, 0, BOTTOM)
			ItemTooltip:SetLink(GetAchievementLink(data.a,1))
		end)


		-- set click: show journal 
		control:SetHandler("OnMouseUp", function (control, mButton) -- control and mButoon passed in context
			if mButton == 1	then
				-- open achievement window
				if not SCENE_MANAGER:IsShowing("achievements") then
					MAIN_MENU_KEYBOARD:ShowScene("achievements")
				end			
				-- set global aid for callback
				ZDAT.ACHIEVEMENTAID = data.l
				-- update search box
				ACHIEVEMENTS.contentSearchEditBox:SetText(GetAchievementName(data.l))
			end
		end)

	else
		-- set hover
		control:SetHandler("OnMouseEnter", function(control) 
			ZO_Tooltips_ShowTextTooltip(control, BOTTOM)
			InformationTooltip:AddLine(string.format('|%s%s|r', ZDAT.UI.Constants.hexGold, "Coming Soon"), ZDAT.UI.Constants.tooltipFont)
		end)
	end
            
	-- set dynamic settings
	ZDAT.UI.Layout.registerRefreshFn(function()
		-- texture is check or box
		control:SetTexture(IsAchievementComplete(data.a) and ZDAT.UI.Constants.texture.CHECK or ZDAT.UI.Constants.texture.BOX)
		-- color is green or gray
		control:SetColor(unpack(IsAchievementComplete(data.a) and ZDAT.UI.Constants.rgbGreen or ZDAT.UI.Constants.rgbGray))
		end)

	return control
end

------------------------------------------------------------------------------------------------------------------
-- Is completed for today? Icon  
------------------------------------------------------------------------------------------------------------------
function ZDAT.UI.Icons.progress(data)
	-- if aid is nil, use static icon
	if data.a==nil then 
        -- can also use this for future AIDS, defined but doesn't exist check add following to if statement
        -- ZDAT.utils.aidExists(data.aid)
        data.t  = ZDAT.UI.Constants.texture.X
		data.c  = ZDAT.UI.Constants.rgbGray
		data.tt = 'does not exist'
		return ZDAT.UI.Icons.basic(data)
	end

	-- create control
	local control = ZDAT.UI.Icons.basic(data)

	if data.tt then
		control:SetMouseEnabled(true)
		control:SetHandler("OnMouseEnter", function(control)
			ZO_Tooltips_ShowTextTooltip(control, TEXT_ALIGN_LEFT)
			InformationTooltip:AddLine(string.format('|%s%s|r', ZDAT.UI.Constants.hexGold, data.tt), ZDAT.UI.Constants.tooltipFont)
			end)
		control:SetHandler("OnMouseExit", function (control) 
			ClearTooltip(InformationTooltip)
			end)  
	end		

	-- set dynamic settings
	ZDAT.UI.Layout.registerRefreshFn(function()
		local dailyStatus = ZDAT.Utils.isDailyQuestComplete(data.a)
		-- texture is check or box
		control:SetTexture(dailyStatus and ZDAT.UI.Constants.texture.CHECK or ZDAT.UI.Constants.texture.BOX)
		-- color is green or gray
		control:SetColor(unpack(dailyStatus and ZDAT.UI.Constants.rgbGreen or ZDAT.UI.Constants.rgbGray))
		end)

	return control
end