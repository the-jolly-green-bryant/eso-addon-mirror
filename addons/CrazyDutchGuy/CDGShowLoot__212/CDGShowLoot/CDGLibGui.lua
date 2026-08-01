local LMP = LibStub:GetLibrary("LibMediaProvider-1.0")
local CDGLG = ZO_Object:Subclass()

CDGLibGui = { 
	window = {
		ID = nil,
		BACKDROP = nil,
		TEXTBUFFER = nil 
	},
	fontstyles = {
		" ",
		"soft-shadow-thick",
		"soft-shadow-thin"
	},
	defaults = {
		general = {
			isMovable = true,
			isHidden = false,
			isBackgroundHidden = false,
			hideInDialogs = true,
		},
		anchor = {
			point = TOPLEFT,
			relativeTo = GuiRoot,
			relativePoint = TOPLEFT,
			offsetX = 0,
			offsetY = 0
		},
		dimensions = {
			width = 560,
			height = 264
		},
		font = {
			name = LMP:HashTable("font")["Univers 57"],
			height = "14",
			style = ""
		},
		minAlpha = 0,
		maxAlpha = 0.8,
		fadeInDelay = 0,
		fadeOutDelay = 1000,
		fadeDuration = 700,
		lineFadeTime = 5,
		lineFadeDuration = 3,
		timestamp = true,
	},
	fadeOutCheckOnUpdate = nil
}

local savedVars_CDGLibGui = {}

function CDGLibGui.CreateWindow( )
	if CDGLibGui.window.ID == nil then
		CDGLibGui.window.ID = WINDOW_MANAGER:CreateTopLevelWindow("CDGLG_TLW")
		CDGLibGui.window.ID:SetAlpha(savedVars_CDGlibGui.maxAlpha)
		CDGLibGui.window.ID:SetMouseEnabled(true)		
		CDGLibGui.window.ID:SetMovable( savedVars_CDGlibGui.general.isMovable )
		CDGLibGui.window.ID:SetClampedToScreen(true)
		CDGLibGui.window.ID:SetDimensions( savedVars_CDGlibGui.dimensions.width, savedVars_CDGlibGui.dimensions.height )
		if savedVars_CDGlibGui.general.isBackgroundHidden then
			CDGLibGui.window.ID:SetResizeHandleSize(0)
		else
			CDGLibGui.window.ID:SetResizeHandleSize(8)
		end
		CDGLibGui.window.ID:SetDrawLevel(DL_BELOW) -- Set the order where it is drawn, higher is more in background ???
		CDGLibGui.window.ID:SetDrawLayer(DL_BACKGROUND)
		CDGLibGui.window.ID:SetDrawTier(DT_LOW)
		CDGLibGui.window.ID:SetAnchor(
			savedVars_CDGlibGui.anchor.point, 
			savedVars_CDGlibGui.anchor.relativeTo, 
			savedVars_CDGlibGui.anchor.relativePoint, 
			savedVars_CDGlibGui.anchor.xPos, 
			savedVars_CDGlibGui.anchor.yPos )	

		CDGLibGui.window.ID:SetHidden(savedVars_CDGlibGui.general.isHidden)

		CDGLibGui.window.ID.isResizing = false		
				
		CDGLibGui.window.TEXTBUFFER = WINDOW_MANAGER:CreateControl(nil, CDGLibGui.window.ID, CT_TEXTBUFFER)	
		CDGLibGui.window.TEXTBUFFER:SetLinkEnabled(true)
		CDGLibGui.window.TEXTBUFFER:SetMouseEnabled(true)
		CDGLibGui.window.TEXTBUFFER:SetFont(savedVars_CDGlibGui.font.name.."|"..savedVars_CDGlibGui.font.height.."|"..savedVars_CDGlibGui.font.style)
		CDGLibGui.window.TEXTBUFFER:SetClearBufferAfterFadeout(false)
		CDGLibGui.window.TEXTBUFFER:SetLineFade(savedVars_CDGlibGui.lineFadeTime, savedVars_CDGlibGui.lineFadeDuration)
		CDGLibGui.window.TEXTBUFFER:SetMaxHistoryLines(100)
		CDGLibGui.window.TEXTBUFFER:SetDimensions(savedVars_CDGlibGui.dimensions.width-64, savedVars_CDGlibGui.dimensions.height-64)
		CDGLibGui.window.TEXTBUFFER:SetAnchor(TOPLEFT,CDGLibGui.window.ID,TOPLEFT,32,32)
	
		CDGLibGui.window.BACKDROP = WINDOW_MANAGER:CreateControl(nil, CDGLibGui.window.ID, CT_BACKDROP)
		CDGLibGui.window.BACKDROP:SetCenterTexture([[/esoui/art/chatwindow/chat_bg_center.dds]], 16, 1)
		CDGLibGui.window.BACKDROP:SetEdgeTexture([[/esoui/art/chatwindow/chat_bg_edge.dds]], 32, 32, 32, 0)
		CDGLibGui.window.BACKDROP:SetInsets(32,32,-32,-32)	
		CDGLibGui.window.BACKDROP:SetAnchorFill(CDGLibGui.window.ID)
		CDGLibGui.window.BACKDROP:SetHidden(savedVars_CDGlibGui.general.isBackgroundHidden)
	
		if not savedVars_CDGlibGui.general.isMovable then
			CDGLibGui.FadeOut()
		end

		CDGLibGui.window.TEXTBUFFER:SetHandler( "OnLinkMouseUp", function(self, _, link, button, ...)
			return ZO_LinkHandler_OnLinkMouseUp(link, button, self) 
		end) 
	

		CDGLibGui.window.TEXTBUFFER:SetHandler( "OnMouseEnter", function(self, ...) 
			CDGLibGui.FadeIn()

    		CDGLibGui.window.TEXTBUFFER:ShowFadedLines()

    		CDGLibGui.MonitorForMouseExit()
		end )

		CDGLibGui.window.ID:SetHandler( "OnMouseExit" , function(self, ...) 
			CDGLibGui.MonitorForMouseExit()
		end )

		CDGLibGui.window.ID:SetHandler( "OnResizeStart" , function(self, ...) 
			self.isResizing = true
		end )

		CDGLibGui.window.ID:SetHandler( "OnResizeStop" , function(self, ...) 
			savedVars_CDGlibGui.dimensions.width, savedVars_CDGlibGui.dimensions.height = self:GetDimensions()
			CDGLibGui.window.TEXTBUFFER:SetDimensions(savedVars_CDGlibGui.dimensions.width-64, savedVars_CDGlibGui.dimensions.height-64)
			self.isResizing = false
		end )

		CDGLibGui.window.ID:SetHandler( "OnMoveStop" , function(self, ...) 
			local isValidAnchor, point, relativeTo, relativePoint, offsetX, offsetY = CDGLibGui.window.ID:GetAnchor()
			if isValidAnchor then
				savedVars_CDGlibGui.anchor.point = point
				savedVars_CDGlibGui.anchor.relativeTo = relativeTo
				savedVars_CDGlibGui.anchor.relativePoint = relativePoint
				savedVars_CDGlibGui.anchor.xPos = offsetX
				savedVars_CDGlibGui.anchor.yPos = offsetY
				CDGLibGui.window.ID:ClearAnchors()
				CDGLibGui.window.ID:SetAnchor(
					savedVars_CDGlibGui.anchor.point, 
					savedVars_CDGlibGui.anchor.relativeTo, 
					savedVars_CDGlibGui.anchor.relativePoint, 
					savedVars_CDGlibGui.anchor.xPos, 
					savedVars_CDGlibGui.anchor.yPos )
			end
		end )
		
		CDGLibGui.window.ID:SetHandler( "OnMouseWheel", function(self, ...)  
			CDGLibGui.window.TEXTBUFFER:MoveScrollPosition(...) 
		end )
		--
		-- If the loot window is hidden do not add it to the scene manager (it would pop up back otherwise)
		-- If we dont want to hide in dialogs, dont add it to the scene manager
		--
		--local fragment = ZO_FadeSceneFragment:New( CDGLibGui.window.ID )
		local fragment = ZO_SimpleSceneFragment:New( CDGLibGui.window.ID )

		if not savedVars_CDGlibGui.general.isHidden and savedVars_CDGlibGui.general.hideInDialogs then
			SCENE_MANAGER:GetScene('hud'):AddFragment( fragment )	
			SCENE_MANAGER:GetScene('hudui'):AddFragment( fragment )
		end
	end
end

function CDGLibGui.FadeOut()
	if not savedVars_CDGlibGui.general.isBackgroundHidden then
		if not CDGLibGui.window.BACKDROP.fadeAnim then
			CDGLibGui.window.BACKDROP.fadeAnim = ZO_AlphaAnimation:New(CDGLibGui.window.BACKDROP)
		end
		CDGLibGui.window.BACKDROP.fadeAnim:SetMinMaxAlpha(savedVars_CDGlibGui.minAlpha, savedVars_CDGlibGui.maxAlpha)
		CDGLibGui.window.BACKDROP.fadeAnim:FadeOut(savedVars_CDGlibGui.fadeOutDelay, savedVars_CDGlibGui.fadeDuration)
	end
end

function CDGLibGui.FadeIn()
	if not savedVars_CDGlibGui.general.isBackgroundHidden then
       	if not CDGLibGui.window.BACKDROP.fadeAnim then
       		CDGLibGui.window.BACKDROP.fadeAnim = ZO_AlphaAnimation:New(CDGLibGui.window.BACKDROP)
       	end
		CDGLibGui.window.BACKDROP.fadeAnim:SetMinMaxAlpha(savedVars_CDGlibGui.minAlpha, savedVars_CDGlibGui.maxAlpha)
    	CDGLibGui.window.BACKDROP.fadeAnim:FadeIn(savedVars_CDGlibGui.fadeInDelay, savedVars_CDGlibGui.fadeDuration)
    end
end

function CDGLibGui.IsMouseInside()
	if  MouseIsOver(CDGLibGui.window.ID) or MouseIsOver(CDGLibGui.window.TEXTBUFFER) or  MouseIsOver(CDGLibGui.window.BACKDROP) then
        return true
    end
    
    return false
end

function CDGLibGui.fadeOutCheckOnUpdate()
	if not CDGLibGui.IsMouseInside() and not CDGLibGui.window.ID.isResizing then 
		CDGLibGui.FadeOut()
	end 
end
--
-- For some reason this OnUpdate is not working properly, forced to call this function
-- on Mouse exit of the main container ...
--
function CDGLibGui.MonitorForMouseExit()
	CDGLibGui.fadeOutCheckOnUpdate()
	--CDGLibGui.window.ID:SetHandler("OnUpdate", CDGLibGui.fadeOutCheckOnUpdate() )
end

function CDGLibGui.setMovable(value)
	savedVars_CDGlibGui.general.isMovable = value
	CDGLibGui.window.ID:SetMovable(value)
end

function CDGLibGui.getTimeTillLineFade()
	return savedVars_CDGlibGui.lineFadeTime
end

function CDGLibGui.setTimeTillLineFade(value)
	savedVars_CDGlibGui.lineFadeTime = value
	CDGLibGui.window.TEXTBUFFER:SetLineFade(savedVars_CDGlibGui.lineFadeTime, savedVars_CDGlibGui.lineFadeDuration)
end

function CDGLibGui.setBackgroundHidden(value)
	savedVars_CDGlibGui.general.isBackgroundHidden = value
	CDGLibGui.window.BACKDROP:SetHidden(value)
	if savedVars_CDGlibGui.general.isBackgroundHidden then
		CDGLibGui.window.ID:SetResizeHandleSize(0)
	else
		CDGLibGui.window.ID:SetResizeHandleSize(8)
	end
end

function CDGLibGui.isBackgroundHidden()
	return savedVars_CDGlibGui.general.isBackgroundHidden
end

function CDGLibGui.isMovable()
	return savedVars_CDGlibGui.general.isMovable
end

function CDGLibGui.Hide()
	CDGLibGui.window.ID:SetHidden(true)
end

function CDGLibGui.Show()
	if not savedVars_CDGlibGui.general.isHidden then
		CDGLibGui.window.ID:SetHidden(false)
	end
end

function CDGLibGui.HideInDialogs(value)
	savedVars_CDGlibGui.general.hideInDialogs = value
end

function CDGLibGui.isHiddenInDialogs()
	return savedVars_CDGlibGui.general.hideInDialogs
end

function CDGLibGui.setHidden(value)
	savedVars_CDGlibGui.general.isHidden = value
	CDGLibGui.window.ID:SetHidden(value)
end

function CDGLibGui.isHidden()
	return savedVars_CDGlibGui.general.isHidden
end

function CDGLibGui.getDefaultFont()
	for i,v in pairs(LMP:HashTable("font")) do
		if v == savedVars_CDGlibGui.font.name then
			return i
		end
	end
end

function CDGLibGui.setDefaultFont(value)
	savedVars_CDGlibGui.font.name = LMP:HashTable("font")[value]
end

function CDGLibGui.setFontSize(value)
	savedVars_CDGlibGui.font.height = value
end

function CDGLibGui.getFontSize()
	return savedVars_CDGlibGui.font.height
end

function CDGLibGui.getFontStyles()
	return CDGLibGui.fontstyles
end

function CDGLibGui.getFontStyle()
	return savedVars_CDGlibGui.font.style
end

function CDGLibGui.setFontStyle(value)
	savedVars_CDGlibGui.font.style = value
end

function CDGLibGui.isTimestampEnabled()
	return savedVars_CDGlibGui.timestamp
end

function CDGLibGui.setTimestampEnabled(value)
	savedVars_CDGlibGui.timestamp = value
end

function CDGLibGui.addMessage(message)
	if CDGLibGui.window.TEXTBUFFER ~= nil then	
		if CDGLibGui.isTimestampEnabled() then
			CDGLibGui.window.TEXTBUFFER:AddMessage("|c909000[" .. GetTimeString() .. "]|r " .. message)
		else
			CDGLibGui.window.TEXTBUFFER:AddMessage(message)
		end
	end
end

function CDGLibGui.initializeSavedVariable()
	savedVars_CDGlibGui = ZO_SavedVars:New("CDGLibGui_SavedVariables", 1, nil, CDGLibGui.defaults)
end

function addDebugMessage(message)	
	if true then CDGLibGui.addMessage("|cDD0000[DEBUG]|r" .. message ) end
end
