KPUI_GamepadTooltip = {}
colors = kpuiConst.Colors


local function LayoutFunction(self, tooltipType, ...)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer == nil then
        return
    end

    local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)

    local tooltipFunction = tooltipContainerTip.tooltip[self.currentLayoutFunctionName] or nil
    if tooltipFunction == nil then
        return nil -- if this line fired you called a function that does not exist on KPUI_GamepadTooltip or KPUI_Tooltip
    end

    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipContainerTip:ClearLines(tooltipInfo.resetScroll)
    local returnValue = tooltipFunction(tooltipContainerTip.tooltip, ...)
    local tooltipFragment = self:GetTooltipFragment(tooltipType)
    if tooltipContainerTip:HasControls() then
        SCENE_MANAGER:AddFragment(tooltipFragment)
        if self:DoesAutoShowTooltipBg(tooltipType) then
            SCENE_MANAGER:AddFragment(self:GetTooltipBgFragment(tooltipType))
        end
    else
        SCENE_MANAGER:RemoveFragment(tooltipFragment)
        if self:DoesAutoShowTooltipBg(tooltipType) then
            SCENE_MANAGER:RemoveFragment(self:GetTooltipBgFragment(tooltipType))
        end
    end
    return returnValue
end

KPUI_GamepadTooltip.metaTable =
{
    __index = function(t, key)
        local value = KPUI_GamepadTooltip[key]
        if value == nil then
            t.currentLayoutFunctionName = key
            return LayoutFunction
        end
        return value
    end,
}

KPUI_GAMEPAD_MAIN_TOOLTIP = "KPUI_GAMEPAD_MAIN_TOOLTIP"
KPUI_GAMEPAD_LEFT_TOOLTIP = "KPUI_GAMEPAD_LEFT_TOOLTIP"
KPUI_GAMEPAD_RIGHT_TOOLTIP = "KPUI_GAMEPAD_RIGHT_TOOLTIP"
KPUI_GAMEPAD_TRADING_TOOLTIP = "KPUI_GAMEPAD_TRADING_TOOLTIP"
KPUI_GAMEPAD_COMPARE_TOOLTIP = "KPUI_GAMEPAD_COMPARE_TOOLTIP"
KPUI_GAMEPAD_COMPARE_TOOLTIP2 = "KPUI_GAMEPAD_COMPARE_TOOLTIP2"
KPUI_GAMEPAD_MOVABLE_TOOLTIP = "KPUI_GAMEPAD_MOVABLE_TOOLTIP"
KPUI_GAMEPAD_LEFT_DIALOG_TOOLTIP = "KPUI_GAMEPAD_LEFT_DIALOG_TOOLTIP"
KPUI_GAMEPAD_QUAD3_TOOLTIP = "KPUI_GAMEPAD_QUAD3_TOOLTIP"
KPUI_GAMEPAD_QUAD1_TOOLTIP = "KPUI_GAMEPAD_QUAD1_TOOLTIP"
KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP = "KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP"
KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP = "KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP"
KPUI_GAMEPAD_WIDE_SETS_TOOLTIP = "KPUI_GAMEPAD_WIDE_SETS_TOOLTIP"

KPUI_GAMEPAD_TOOLTIP_NORMAL_BG = 1
KPUI_GAMEPAD_TOOLTIP_DARK_BG = 2

function KPUI_GamepadTooltip:New(...)
    local gamepadTooltip = {}
    setmetatable(gamepadTooltip, self.metaTable)
    gamepadTooltip:Initialize(...)
    return gamepadTooltip
end

function KPUI_GamepadTooltip:Initialize(control, dialogControl, researchControl)
    self.control = control
    self.dialogControl = dialogControl
	self.researchControl = researchControl
    self.tooltips = {}

    local AUTO_SHOW_BG = true
    local DONT_AUTO_SHOW_BG = false
    self:InitializeTooltip(KPUI_GAMEPAD_MAIN_TOOLTIP, self.control, "Movable", AUTO_SHOW_BG, LEFT)
    self:InitializeTooltip(KPUI_GAMEPAD_LEFT_TOOLTIP, self.control, "Left", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(KPUI_GAMEPAD_RIGHT_TOOLTIP, self.control, "Right", AUTO_SHOW_BG, LEFT)
    self:InitializeTooltip(KPUI_GAMEPAD_TRADING_TOOLTIP, self.control, "Trading", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(KPUI_GAMEPAD_COMPARE_TOOLTIP, self.control, "Compare", AUTO_SHOW_BG, LEFT)
    self:InitializeTooltip(KPUI_GAMEPAD_COMPARE_TOOLTIP2, self.control, "Compare2", AUTO_SHOW_BG, LEFT)
    self:InitializeTooltip(KPUI_GAMEPAD_MOVABLE_TOOLTIP, self.control, "Movable", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(KPUI_GAMEPAD_QUAD3_TOOLTIP, self.control, "Quadrant3", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(KPUI_GAMEPAD_QUAD1_TOOLTIP, self.control, "Quadrant1", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(KPUI_GAMEPAD_LEFT_DIALOG_TOOLTIP, self.dialogControl, "Left", AUTO_SHOW_BG, RIGHT)
    self:InitializeTooltip(KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP, self.control, "WideResearch", AUTO_SHOW_BG, RIGHT)
	self:InitializeTooltip(KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP, self.control, "WideCrafting", AUTO_SHOW_BG, RIGHT)
	self:InitializeTooltip(KPUI_GAMEPAD_WIDE_SETS_TOOLTIP, self.control, "WideSets", AUTO_SHOW_BG, RIGHT)
end

function KPUI_GamepadTooltip:InitializeTooltip(tooltipType, baseControl, prefix, autoShowBg, scrollIndicatorSide)
    local control = baseControl:GetNamedChild(prefix.."Tooltip")
    local bgControl = baseControl:GetNamedChild(prefix.."TooltipBg")
    local darkBgControl = baseControl:GetNamedChild(prefix.."TooltipDarkBg")
    local headerContainerControl = baseControl:GetNamedChild(prefix.."HeaderContainer")



    local container = control:GetNamedChild("Container")
    container.tip = container:GetNamedChild("Tip")
    container.tip.initialized = false;
    container.tipLeft = container:GetNamedChild("TipLeft")
    container.tipLeft.initialized = false;
    container.tipRight = container:GetNamedChild("TipRight")
    container.tipRight.initialized = false;
    container.tipTop = container:GetNamedChild("TipTop")
    container.tipTop.initialized = false;
    container.tipBottom = container:GetNamedChild("TipBottom")
    container.tipBottom.initialized = false;
    container.statusLabel = container:GetNamedChild("StatusLabel")
    container.statusLabelValue = container:GetNamedChild("StatusLabelValue")
    container.statusLabelValueForVisualLayer = container:GetNamedChild("StatusLabelValueForVisualLayer")
    container.statusLabelVisualLayer = container:GetNamedChild("StatusLabelVisualLayer")
    container.bottomRail = container:GetNamedChild("BottomRail")
	
	control.container = container

    local bgFragment = ZO_FadeSceneFragment:New(bgControl, true)
    bgControl:SetAnchorFill(control)
    _G[tooltipType.."_BACKGROUND_FRAGMENT"] = bgFragment

    local darkBgFragment = ZO_FadeSceneFragment:New(darkBgControl, true)
    _G[tooltipType.."_DARK_BACKGROUND_FRAGMENT"] = darkBgFragment
    darkBgControl:SetAnchorFill(control)

    local headerControl = nil
    if headerContainerControl ~= nil then
        local headerContainer = headerContainerControl:GetNamedChild("ContentContainer")
        if headerContainer ~= nil then
            headerControl = headerContainer:GetNamedChild("Header")
            ZO_GamepadGenericHeader_Initialize(headerControl, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE)	
			-- headerControl:ClearAnchors()
			-- headerControl:SetAnchor(TOPLEFT, control, TOPLEFT, 0, 0)
			-- headerControl:SetAnchor(TOPRIGHT, control, TOPRIGHT, 0, 0)	
        end
    end
	
	local researchRightPane = baseControl:GetNamedChild("RightPane")
	local contentHeader = researchRightPane:GetNamedChild("HeaderContainer"):GetNamedChild("Header")
	ZO_GamepadGenericHeader_Initialize(contentHeader, ZO_GAMEPAD_HEADER_TABBAR_DONT_CREATE, ZO_GAMEPAD_HEADER_LAYOUTS.DATA_PAIRS_TOGETHER)
	local contentHeaderData = {}
	contentHeaderData.titleText = ""
	contentHeaderData.data1HeaderText = ""
	contentHeaderData.data1Text = ""

	local needBG = KPUI_GAMEPAD_TOOLTIP_NORMAL_BG
	if tooltipType == KPUI_GAMEPAD_LEFT_DIALOG_TOOLTIP then	needBG = KPUI_GAMEPAD_TOOLTIP_DARK_BG end
	if tooltipType == KPUI_GAMEPAD_COMPARE_TOOLTIP then	needBG = KPUI_GAMEPAD_TOOLTIP_DARK_BG end
	if tooltipType == KPUI_GAMEPAD_COMPARE_TOOLTIP2 then	needBG = KPUI_GAMEPAD_TOOLTIP_DARK_BG end
	
	
    self.tooltips[tooltipType] =
    {
        control = control,
        bgControl = bgControl,
        darkBgControl = darkBgControl,
        headerContainerControl = headerContainerControl,
        headerControl = headerControl,
		
		-- kela
		researchRightPane = researchRightPane,
		contentHeader = contentHeader,
		contentHeaderData = contentHeaderData,
		
        fragment = ZO_FadeSceneFragment:New(control, true),
        bgFragment = bgFragment,
        darkBgFragment = darkBgFragment,
        autoShowBg = autoShowBg,
        defaultAutoShowBg = autoShowBg,
        bgType = needBG,
        resetScroll = true,
        scrollIndicatorSide = scrollIndicatorSide,
    }

    self:SetScrollIndicatorSide(tooltipType, scrollIndicatorSide)
end

function KPUI_GamepadTooltip:ClearContentHeader(tooltipType)
	-- KelaPostMsg("ClearContentHeader")
	local tooltipInfo = self:GetTooltipInfo(tooltipType)    
	tooltipInfo.researchRightPane:SetHidden(true)
	tooltipInfo.contentHeaderData.titleText = ""
	tooltipInfo.contentHeaderData.data1HeaderText = ""
	tooltipInfo.contentHeaderData.data1Text = ""
	ZO_GamepadGenericHeader_Refresh(tooltipInfo.contentHeader, tooltipInfo.contentHeaderData)
end
function KPUI_GamepadTooltip:RefreshContentHeader(tooltipType, title, dataHeaderText, dataText)
	-- KelaPostMsg("RefreshContentHeader")
	local tooltipInfo = self:GetTooltipInfo(tooltipType)    
	tooltipInfo.contentHeaderData.titleText = zo_strformat(SI_ABILITY_TOOLTIP_NAME, title)
    tooltipInfo.contentHeaderData.data1HeaderText = dataHeaderText
    tooltipInfo.contentHeaderData.data1Text = dataText
    ZO_GamepadGenericHeader_Refresh(tooltipInfo.contentHeader, tooltipInfo.contentHeaderData)
	tooltipInfo.researchRightPane:SetHidden(false)
end



function KPUI_GamepadTooltip:HideTooltip(tooltipType)
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipFragment(tooltipType))
	SCENE_MANAGER:RemoveFragment(KPUI_GAMEPAD_TOOLTIPS:GetTooltipBgFragment(tooltipType))	
end
--Set retainFragment to true if you intend to re-layout this tooltip immediately after calling ClearTooltip
--This saves us the performance cost of removing the fragment just to add it right back in again
--Particularly when done in an update loop
function KPUI_GamepadTooltip:ClearTooltip(tooltipType, retainFragment)
	
	local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
        local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)

        local tooltipInfo = self:GetTooltipInfo(tooltipType)
        tooltipContainerTip:ClearLines(tooltipInfo.resetScroll)
        if not retainFragment then
            SCENE_MANAGER:RemoveFragment(self:GetTooltipFragment(tooltipType))
            if self:DoesAutoShowTooltipBg(tooltipType) then
                SCENE_MANAGER:RemoveFragment(self:GetTooltipBgFragment(tooltipType))
            end
        end
        self:ClearStatusLabel(tooltipType)		
    end
	local tooltipInfo = self:GetTooltipInfo(tooltipType)
	if tooltipInfo.contentHeaderData.titleText ~= "" then self:ClearContentHeader(tooltipType) end
end

function KPUI_GamepadTooltip:ResetScrollTooltipToTop(tooltipType)
    local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)
    if tooltipContainerTip then
        tooltipContainerTip:ResetToTop()
    end
end

function KPUI_GamepadTooltip:ClearStatusLabel(tooltipType)
    self:SetStatusLabelText(tooltipType)
end

function KPUI_GamepadTooltip:SetStatusLabelText(tooltipType, stat, value, visualLayer, trading)
    if stat == nil then stat = "" end
    if value == nil then value = "" end
	if value2 == nil then value2 = "" end
    if visualLayer == nil then visualLayer = "" end
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
        tooltipContainer.statusLabel:SetText(stat)
        if visualLayer ~= "" then
            tooltipContainer.statusLabelValueForVisualLayer:SetText(value)
        else
            tooltipContainer.statusLabelValue:SetText(value)
        end
        tooltipContainer.statusLabelVisualLayer:SetText(visualLayer)
        local hidden = stat == "" and value == "" and visualLayer == ""
        tooltipContainer.statusLabel:SetHidden(hidden)
        tooltipContainer.statusLabelVisualLayer:SetHidden(hidden)
        tooltipContainer.bottomRail:SetHidden(hidden)
        tooltipContainer.statusLabelValue:SetHidden(hidden or (visualLayer ~= ""))
        tooltipContainer.statusLabelValueForVisualLayer:SetHidden(hidden or (visualLayer == ""))
		
		if trading then 
			tooltipContainer.statusLabelValueForVisualLayer:SetFont("ZoFontGamepad20")
			tooltipContainer.statusLabelVisualLayer:SetFont("ZoFontGamepadCondensed18")
		end
		
    end
	-- SetFont("ZoFontHeader3")
end

function KPUI_GamepadTooltip:SetMovableTooltipVerticalRules(leftHidden, rightHidden)
    local bgControl = self:GetTooltipInfo(KPUI_GAMEPAD_MOVABLE_TOOLTIP).bgControl:GetNamedChild("Bg")
    bgControl:GetNamedChild("LeftDivider"):SetHidden(leftHidden)
    bgControl:GetNamedChild("RightDivider"):SetHidden(rightHidden)
end

function KPUI_GamepadTooltip:SetMovableTooltipAnchors(anchorTable)
    local movableTooltipContainer = self:GetTooltipInfo(KPUI_GAMEPAD_MOVABLE_TOOLTIP).control
    movableTooltipContainer:ClearAnchors()
    for i, anchor in ipairs(anchorTable) do
        movableTooltipContainer:SetAnchor(anchor:GetMyPoint(), anchor:GetTarget(), anchor:GetRelativePoint(), anchor:GetOffsetX(), anchor:GetOffsetY())
    end
end
function KPUI_GamepadTooltip:GetTooltipControl(tooltipType)
    local tooltipContainer = self:GetTooltipInfo(tooltipType).control
	return tooltipContainer
end


function KPUI_GamepadTooltip:SetScrollIndicatorSide(tooltipType, side)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
		if tooltipType == KPUI_GAMEPAD_WIDE_RESEARCH_TOOLTIP then
			local tooltipInfoLeft = self:GetTooltipInfo(tooltipType)
			local tooltipContainerTipLeft = tooltipContainer.tipLeft
			local scrollIndicatorLeft = tooltipContainerTipLeft:GetNamedChild("ScrollIndicator")
			ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicatorLeft, tooltipInfoLeft.bgControl, side)
			local tooltipInfoRight = self:GetTooltipInfo(tooltipType)
			local tooltipContainerTipRight = tooltipContainer.tipRight
			local scrollIndicatorRight = tooltipContainerTipRight:GetNamedChild("ScrollIndicator")
			ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicatorRight, tooltipInfoRight.bgControl, side)
			-- local tooltipInfoBottom = self:GetTooltipInfo(tooltipType)
			-- local tooltipContainerTipBottom = tooltipContainer.tipBottom
			-- local scrollIndicatorBottom = tooltipContainerTipBottom:GetNamedChild("ScrollIndicator")
			-- ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicatorBottom, tooltipInfoBottom.bgControl, side)
			local tooltipInfo = self:GetTooltipInfo(tooltipType)
			local tooltipContainerTip = tooltipContainer.tip
			local scrollIndicator = tooltipContainerTip:GetNamedChild("ScrollIndicator")
			ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicator, tooltipInfo.bgControl, side)
		elseif tooltipType == KPUI_GAMEPAD_WIDE_CRAFTING_TOOLTIP then
			local tooltipInfoTop = self:GetTooltipInfo(tooltipType)
			local tooltipContainerTipTop = tooltipContainer.tipTop
			local scrollIndicatorTop = tooltipContainerTipTop:GetNamedChild("ScrollIndicator")
			ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicatorTop, tooltipInfoTop.bgControl, side)				
		elseif tooltipType == KPUI_GAMEPAD_WIDE_SETS_TOOLTIP then
			local tooltipInfoBottom = self:GetTooltipInfo(tooltipType)
			local tooltipContainerTipBottom = tooltipContainer.tipBottom
			local scrollIndicatorBottom = tooltipContainerTipBottom:GetNamedChild("ScrollIndicator")
			ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicatorBottom, tooltipInfoBottom.bgControl, side)		
		else
			local tooltipInfo = self:GetTooltipInfo(tooltipType)
			-- we don't want to initialize the tip at this point, because we don't need it to be yet
			-- and this is called in the class initialization, which defeats the point of deferring initialization of the tip
			local tooltipContainerTip = tooltipContainer.tip
			local scrollIndicator = tooltipContainerTip:GetNamedChild("ScrollIndicator")
			ZO_Scroll_Gamepad_SetScrollIndicatorSide(scrollIndicator, tooltipInfo.bgControl, side)		
		end
    end
end


function KPUI_GamepadTooltip:ShowBg(tooltipType)
    SCENE_MANAGER:AddFragment(self:GetTooltipBgFragment(tooltipType))
end

function KPUI_GamepadTooltip:HideBg(tooltipType)
    SCENE_MANAGER:RemoveFragment(self:GetTooltipBgFragment(tooltipType))
end

function KPUI_GamepadTooltip:SetAutoShowBg(tooltipType, autoShowBg)
    self:GetTooltipInfo(tooltipType).autoShowBg = autoShowBg
end

function KPUI_GamepadTooltip:SetBgType(tooltipType, bgType)
    self:GetTooltipInfo(tooltipType).bgType = bgType
end

function KPUI_GamepadTooltip:SetBgAlpha(tooltipType, alpha)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipInfo.bgControl:GetNamedChild("Bg"):SetAlpha(alpha)
    tooltipInfo.darkBgControl:GetNamedChild("Bg"):SetAlpha(alpha)
end

function KPUI_GamepadTooltip:SetTooltipResetScrollOnClear(tooltipType, resetScroll)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipInfo.resetScroll = resetScroll
end

function KPUI_GamepadTooltip:ShowGenericHeader(tooltipType, data)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    ZO_GamepadGenericHeader_Refresh(tooltipInfo.headerControl, data)
    tooltipInfo.headerContainerControl:SetHidden(false)
end

function KPUI_GamepadTooltip:Reset(tooltipType)
    local tooltipInfo = self:GetTooltipInfo(tooltipType)
    tooltipInfo.autoShowBg = tooltipInfo.defaultAutoShowBg
    tooltipInfo.bgType = KPUI_GAMEPAD_TOOLTIP_NORMAL_BG
    tooltipInfo.bgControl:GetNamedChild("Bg"):SetAlpha(1)
    tooltipInfo.darkBgControl:GetNamedChild("Bg"):SetAlpha(1)
    tooltipInfo.resetScroll = true
    self:SetScrollIndicatorSide(tooltipType, tooltipInfo.scrollIndicatorSide)
    if tooltipInfo.headerContainerControl ~= nil then
        tooltipInfo.headerContainerControl:SetHidden(true)
    end
    if tooltipType == KPUI_GAMEPAD_MOVABLE_TOOLTIP then
        local HIDE_LEFT_DIVIDER = false
        local HIDE_RIGHT_DIVIDER = false
        self:SetMovableTooltipVerticalRules(HIDE_LEFT_DIVIDER, HIDE_RIGHT_DIVIDER)
    end
    self:ClearTooltip(tooltipType)
end

function KPUI_GamepadTooltip:GetTooltipTop(tooltipType)
    local tooltipContainerTipTop = self:GetAndInitializeTooltipContainerTipTop(tooltipType)
    if tooltipContainerTipTop then
        return tooltipContainerTipTop.tooltip
    end
end
function KPUI_GamepadTooltip:GetAndInitializeTooltipContainerTipTop(tooltipType)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
		local tooltipContainerTip
		tooltipContainerTip = tooltipContainer.tipTop
		if tooltipContainerTip.initialized == false then
            tooltipContainerTip.initialized = true
            ZO_ScrollTooltip_Gamepad:Initialize(tooltipContainerTip, ZO_TOOLTIP_STYLES)
        end
        return tooltipContainerTip
    end
end

function KPUI_GamepadTooltip:GetTooltipBottom(tooltipType)
    local tooltipContainerTipBottom = self:GetAndInitializeTooltipContainerTipBottom(tooltipType)
    if tooltipContainerTipBottom then
        return tooltipContainerTipBottom.tooltip
    end
end
function KPUI_GamepadTooltip:GetAndInitializeTooltipContainerTipBottom(tooltipType)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
		local tooltipContainerTip
		tooltipContainerTip = tooltipContainer.tipBottom
		if tooltipContainerTip.initialized == false then
            tooltipContainerTip.initialized = true
            ZO_ScrollTooltip_Gamepad:Initialize(tooltipContainerTip, ZO_TOOLTIP_STYLES)
        end
        return tooltipContainerTip
    end
end

function KPUI_GamepadTooltip:GetTooltipLeftRight(tooltipType)
    local tooltipContainerTipLeft = self:GetAndInitializeTooltipContainerTipLeftRight(tooltipType, "Left")
	local tooltipContainerTipRight = self:GetAndInitializeTooltipContainerTipLeftRight(tooltipType, "Right")

    if tooltipContainerTipLeft and tooltipContainerTipRight then
        return tooltipContainerTipLeft.tooltip, tooltipContainerTipRight.tooltip
    end
end
function KPUI_GamepadTooltip:GetAndInitializeTooltipContainerTipLeftRight(tooltipType, tipLeftRight)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)
    if tooltipContainer then
		local tooltipContainerTip
		if tipLeftRight == "Left" then
		    tooltipContainerTip = tooltipContainer.tipLeft
        elseif tipLeftRight == "Right" then
			tooltipContainerTip = tooltipContainer.tipRight
		else
			tooltipContainerTip = tooltipContainer.tip
		end
		if tooltipContainerTip.initialized == false then
            tooltipContainerTip.initialized = true
            ZO_ScrollTooltip_Gamepad:Initialize(tooltipContainerTip, ZO_TOOLTIP_STYLES)
        end
        return tooltipContainerTip
    end
end


function KPUI_GamepadTooltip:GetTooltip(tooltipType)
    local tooltipContainerTip = self:GetAndInitializeTooltipContainerTip(tooltipType)

    if tooltipContainerTip then
        return tooltipContainerTip.tooltip
    end
end

function KPUI_GamepadTooltip:GetTooltipContainer(tooltipType)
    return self:GetTooltipInfo(tooltipType).control.container
end

function KPUI_GamepadTooltip:GetAndInitializeTooltipContainerTip(tooltipType)
    local tooltipContainer = self:GetTooltipContainer(tooltipType)

    if tooltipContainer then
        local tooltipContainerTip = tooltipContainer.tip
        if tooltipContainerTip.initialized == false then
            tooltipContainerTip.initialized = true
            ZO_ScrollTooltip_Gamepad:Initialize(tooltipContainerTip, ZO_TOOLTIP_STYLES)
        end
        return tooltipContainerTip
    end
end

function KPUI_GamepadTooltip:GetTooltipFragment(tooltipType)
    return self:GetTooltipInfo(tooltipType).fragment
end

function KPUI_GamepadTooltip:GetTooltipBgFragment(tooltipType)
    local info = self:GetTooltipInfo(tooltipType)
    if info.bgType == KPUI_GAMEPAD_TOOLTIP_NORMAL_BG then
        return info.bgFragment
    elseif info.bgType == KPUI_GAMEPAD_TOOLTIP_DARK_BG then
        return info.darkBgFragment
    end
end

function KPUI_GamepadTooltip:AddTooltipInstantScene(tooltipType, scene)
    local info = self:GetTooltipInfo(tooltipType)
    info.fragment:AddInstantScene(scene)
    info.bgFragment:AddInstantScene(scene)
    info.darkBgFragment:AddInstantScene(scene)
end

function KPUI_GamepadTooltip:DoesAutoShowTooltipBg(tooltipType)
    return self:GetTooltipInfo(tooltipType).autoShowBg
end

function KPUI_GamepadTooltip:GetTooltipInfo(tooltipType)
    return self.tooltips[tooltipType]
end

function KPUI_GamepadTooltip_OnInitialized(control, dialogControl)
    KPUI_GAMEPAD_TOOLTIPS = KPUI_GamepadTooltip:New(control, dialogControl)
end




function KPUI_GamepadTooltip:CreateDivider(parent, previous, index, offsetX, offsetY)
	if offsetX == nil then offsetX = 4 end
	if offsetY == nil then offsetY = 4 end
	local newControl = CreateControlFromVirtual("$(parent)Divider", parent, "KPUI_Divider", index)
	newControl:ClearAnchors()
	newControl:SetAnchor(TOPLEFT, previous, BOTTOMLEFT, offsetX, offsetY)
	newControl:SetAnchor(TOPRIGHT, previous, BOTTOMRIGHT, offsetX, offsetY)
    newControl.index = index
    return newControl
end

function KPUI_GamepadTooltip:CreateRowSimple(parent, previous, index, offsetY, first, name)
    
	local newControl = CreateControlFromVirtual("$(parent)"..name, parent, "KPUI_WidePanel_Entry", index)
	newControl:ClearAnchors()
	if first then 	
		newControl:SetAnchor(LEFT, previous, LEFT, 10, offsetY)
		newControl:SetAnchor(RIGHT, previous, RIGHT, -10, offsetY)
	else
		newControl:SetAnchor(LEFT, previous, LEFT, 0, offsetY)
		newControl:SetAnchor(RIGHT, previous, RIGHT, 0, offsetY)
	end
	
    newControl.index = index
	newControl.rowHeader = newControl:GetNamedChild("RowHeaderLeft")
	newControl.rowHeaderValue = newControl:GetNamedChild("RowHeaderValue")
	
    return newControl
end
function KPUI_GamepadTooltip:CreateRowMainList(parent, previous, index)
    
	local newControl = CreateControlFromVirtual("$(parent)rowList", parent, "KPUI_WidePanel_Entry", index)
	
    newControl.index = index
	newControl.divider = newControl:GetNamedChild("Divider")
	newControl.divider:ClearAnchors()
	newControl.divider:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 45)
	newControl.divider:SetAnchor(TOPRIGHT, parent, TOPLEFT, 300, 48)
	-- newControl.rowIcon = newControl:GetNamedChild("RowIcon"):GetNamedChild("Icon")
	-- newControl.rowIcon:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 45)	
	-- newControl.rowFrame = newControl:GetNamedChild("RowIcon"):GetNamedChild("Frame")
	newControl.rowHeader = newControl:GetNamedChild("RowHeader")
	newControl.rowHeaderValue = newControl:GetNamedChild("RowHeaderValue")
	
    return newControl
end
function KPUI_GamepadTooltip:CreateCraftingSetsPanel(parent, previous, index)
    
	local newControl = CreateControlFromVirtual("$(parent)CraftingSetsPanel", parent, "KPUI_WidePanel_Entry", index)

    newControl.index = index
	newControl.dividerPippedHeader = newControl:GetNamedChild("DividerPippedHeader")
	newControl.dividerPipped = newControl:GetNamedChild("DividerPipped")
	newControl.pipsControl = newControl.dividerPipped:GetNamedChild("Pips")	
	newControl.panelPip2 = newControl:GetNamedChild("PipPanel2")
	newControl.panelPip3 = newControl:GetNamedChild("PipPanel3")
	newControl.panelPip4 = newControl:GetNamedChild("PipPanel4")
	newControl.panelPip5 = newControl:GetNamedChild("PipPanel5")
	newControl.panelPip6 = newControl:GetNamedChild("PipPanel6")
	newControl.panelPip7 = newControl:GetNamedChild("PipPanel7")
	newControl.panelPip8 = newControl:GetNamedChild("PipPanel8")
	newControl.panelPip9 = newControl:GetNamedChild("PipPanel9")
	
    return newControl
end
function KPUI_GamepadTooltip:CreateOverlandSetsPanel(parent, previous, index)
    
	local newControl = CreateControlFromVirtual("$(parent)OverlandSetsPanel", parent, "KPUI_WidePanel_Entry", index)

    newControl.index = index
	newControl.dividerPippedHeader = newControl:GetNamedChild("DividerPippedHeader")
	newControl.dividerPipped = newControl:GetNamedChild("DividerPipped")
	newControl.pipsControl = newControl.dividerPipped:GetNamedChild("Pips")	
	newControl.panelPip1 = newControl:GetNamedChild("PipPanel1")
	newControl.panelPip2 = newControl:GetNamedChild("PipPanel2")
	newControl.panelPip3 = newControl:GetNamedChild("PipPanel3")
	newControl.panelPip4 = newControl:GetNamedChild("PipPanel4")
	newControl.panelPip5 = newControl:GetNamedChild("PipPanel5")
	newControl.panelPip6 = newControl:GetNamedChild("PipPanel6")
	newControl.panelPip7 = newControl:GetNamedChild("PipPanel7")
	newControl.panelPip8 = newControl:GetNamedChild("PipPanel8")
	
    return newControl
end
function KPUI_GamepadTooltip:CreateDungeonSetsPanel(parent, previous, index)
    
	local newControl = CreateControlFromVirtual("$(parent)DungeonSetsPanel", parent, "KPUI_WidePanel_Entry", index)

    newControl.index = index
	newControl.dividerPippedHeader = newControl:GetNamedChild("DividerPippedHeader")
	newControl.dividerPipped = newControl:GetNamedChild("DividerPipped")
	newControl.pipsControl = newControl.dividerPipped:GetNamedChild("Pips")	
	newControl.panelPip1 = newControl:GetNamedChild("PipPanel1")
	newControl.panelPip2 = newControl:GetNamedChild("PipPanel2")
	newControl.panelPip3 = newControl:GetNamedChild("PipPanel3")
	newControl.panelPip4 = newControl:GetNamedChild("PipPanel4")
	newControl.panelPip5 = newControl:GetNamedChild("PipPanel5")
	newControl.panelPip6 = newControl:GetNamedChild("PipPanel6")
	newControl.panelPip7 = newControl:GetNamedChild("PipPanel7")
	newControl.panelPip8 = newControl:GetNamedChild("PipPanel8")
	newControl.panelPip9 = newControl:GetNamedChild("PipPanel9")
	
    return newControl
end
function KPUI_GamepadTooltip:CreateMonsterSetsPanel(parent, previous, index)
    
	local newControl = CreateControlFromVirtual("$(parent)MonsterSetsPanel", parent, "KPUI_WidePanel_Entry", index)

    newControl.index = index
	newControl.dividerPippedHeader = newControl:GetNamedChild("DividerPippedHeader")
	newControl.dividerPipped = newControl:GetNamedChild("DividerPipped")
	newControl.pipsControl = newControl.dividerPipped:GetNamedChild("Pips")	
	newControl.panelPip1 = newControl:GetNamedChild("PipPanel1")
	newControl.panelPip2 = newControl:GetNamedChild("PipPanel2")
	newControl.panelPip3 = newControl:GetNamedChild("PipPanel3")	
    return newControl
end

function KPUI_GamepadTooltip:CreateResearchPanel(parent, previous, index)
	local newControl = CreateControlFromVirtual("$(parent)ResearchPanel", parent, "KPUI_ResearchPanel_Entry", index)
    newControl.index = index
	newControl.dividerPipped = newControl:GetNamedChild("DividerPipped")
	newControl.dividerPipped:ClearAnchors()
	newControl.dividerPipped:SetAnchor(TOPLEFT, parent, TOPLEFT, 0, 0)
	newControl.dividerPipped:SetAnchor(TOPRIGHT, parent, TOPLEFT, KELA_TOOLTIPS_WIDE_CONTENT_WIDTH, 0)
	newControl.pipsControl = newControl.dividerPipped:GetNamedChild("Pips")	
	newControl.panelResearch1 = newControl:GetNamedChild("ResearchPanel1")
	newControl.panelResearch2 = newControl:GetNamedChild("ResearchPanel2")
	newControl.panelResearch3 = newControl:GetNamedChild("ResearchPanel3")
	newControl.panelResearch4 = newControl:GetNamedChild("ResearchPanel4")
	newControl.panelResearch5 = newControl:GetNamedChild("ResearchPanel5")
	newControl.panelResearch6 = newControl:GetNamedChild("ResearchPanel6")
	newControl.panelResearch7 = newControl:GetNamedChild("ResearchPanel7")
    return newControl
end


local PADDING = 3
function KPUI_GamepadTooltip:CreateResearchLineSlot(parent, previous, index, offsetX, offsetY)
    local newControl = CreateControlFromVirtual("$(parent)ResearchLine", parent, "KPUI_ResearchLine_Entry", index)
	newControl:ClearAnchors()
	if offsetX then 	
		newControl:SetAnchor(LEFT, previous, LEFT, offsetX, offsetY)
	-- elseif index == 1 or index == 8 then
		-- newControl:SetAnchor(LEFT, previous, LEFT, 170, 110)
	else
		newControl:SetAnchor(LEFT, previous, RIGHT, PADDING, 0)
	end
    newControl.index = index
    newControl.icon = newControl:GetNamedChild("Icon")
    newControl.frame = newControl:GetNamedChild("Frame")
    return newControl
end
function KPUI_GamepadTooltip:CreateTraitSlot(parent, previous, index)
    local newControl = CreateControlFromVirtual("$(parent)Trait", parent, "KPUI_Trait_Entry", index)
	newControl:ClearAnchors()
	if previous then
        newControl:SetAnchor(TOP, previous, BOTTOM, 0, 6)
    else
        newControl:SetAnchor(TOP, nil, TOP, 0, 0)
    end

    newControl.index = index
    newControl.icon = newControl:GetNamedChild("Icon")
    newControl.frame = newControl:GetNamedChild("Frame")

    return newControl
end


local alreadykelaReColorDescription
KELA_FIRST_CALL_RECOLOR_BONUSES = true

KELA_RECOLOR_BONUS = ""
KELA_RECOLOR_BONUS_PERCENT = ""
KELA_RECOLOR_BONUS_INACTIVE = ""
KELA_RECOLOR_BONUS_INACTIVE_PERCENT = ""

-- подсвечиваем цифры в описании бонусов
function kelaReColorDescription(activateBonus)
	if KELA_FIRST_CALL_RECOLOR_BONUSES then
		KELA_RECOLOR_BONUS = GetString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS)
		KELA_RECOLOR_BONUS_PERCENT = GetString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS_PERCENT)
		KELA_RECOLOR_BONUS_INACTIVE = GetString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS_INACTIVE)
		KELA_RECOLOR_BONUS_INACTIVE_PERCENT = GetString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS_INACTIVE_PERCENT)
		KELA_FIRST_CALL_RECOLOR_BONUSES = false
	end
	if activateBonus then 
		SafeAddString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS_INACTIVE, KELA_RECOLOR_BONUS, 2)
		SafeAddString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS_INACTIVE_PERCENT, KELA_RECOLOR_BONUS_PERCENT, 1) 
	else
		SafeAddString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS_INACTIVE, KELA_RECOLOR_BONUS_INACTIVE, 2)
		SafeAddString(SI_ITEM_FORMAT_STR_SET_PROPERTY_BONUS_INACTIVE_PERCENT, KELA_RECOLOR_BONUS_INACTIVE_PERCENT, 1) 
	end
end

function ZO_Tooltip:LayoutDescriptionTooltip(title, desc)
    self:AddLine(title, self:GetStyle("title"))
    local bodySection = self:AcquireSection(self:GetStyle("bodySection"))	
    if desc then bodySection:AddLine(desc, self:GetStyle("bodyDescription")) end
    self:AddSection(bodySection)
end

function ZO_Tooltip:LayoutItemStatComparisonItemLink(itemLink, comparisonSlot)
 	
	local name = colors.COLOR_WHITE:Colorize(string.upper(GetString("SI_EQUIPSLOT", comparisonSlot)))
	self:AddLine(name, self:GetStyle("title"), {fontSize = KELA_TOOLTIPS_FONT_BIG, customSpacing = 0, childSpacing = 30})
	
	local statDeltaLookup = ZO_GetStatDeltaLookupFromItemComparisonReturns(CompareItemLinkToCurrentlyEquipped(itemLink, comparisonSlot))
    for _, statGroup in ipairs(ZO_INVENTORY_STAT_GROUPS) do
        local statSection = self:AcquireSection(self:GetStyle("itemComparisonStatSection"))
        for _, stat in ipairs(statGroup) do
            
            local statName = zo_strformat(SI_STAT_NAME_FORMAT, GetString("SI_DERIVEDSTATS", stat))
            local currentValue = GetPlayerStat(stat)
            local statDelta = statDeltaLookup[stat] or 0
            local valueToShow = currentValue + statDelta
            
            if stat == STAT_SPELL_CRITICAL or stat == STAT_CRITICAL_STRIKE then
                local newPercent = GetCriticalStrikeChance(valueToShow)
                valueToShow = zo_strformat(SI_STAT_VALUE_PERCENT, newPercent)
            end

            local colorStyle = self:GetStyle("itemComparisonStatValuePairDefaultColor")
            if statDelta ~= 0 then
                local icon
                if statDelta > 0 then
                    colorStyle = self:GetStyle("succeeded")
                    icon = "EsoUI/Art/Buttons/Gamepad/gp_upArrow.dds"
                else
                    colorStyle = self:GetStyle("failed")
                    icon = "EsoUI/Art/Buttons/Gamepad/gp_downArrow.dds"
                end
                valueToShow = valueToShow .. zo_iconFormatInheritColor(icon, 24, 24)
            end

            local statValuePair = statSection:AcquireStatValuePair(self:GetStyle("itemComparisonStatValuePair"))
            statValuePair:SetStat(statName, self:GetStyle("statValuePairStat"))
            statValuePair:SetValue(valueToShow, self:GetStyle("itemComparisonStatValuePairValue"), colorStyle)
            statSection:AddStatValuePair(statValuePair)
        end
        self:AddSection(statSection)
    end
end

function ZO_Tooltip:LayoutSetTooltip(data)
	
	-- local DMText
	-- local DMTextFull
	-- if data.setDropMechanic then 
		-- local count = 0
		-- for i, ID in pairs(data.setDropMechanic) do
			-- count = count + 1
			-- local tooltipMechanic, tooltipMechanicFull = LibSets.GetDropMechanicName(ID)
			-- if count == 1 then
				-- DMText = tooltipMechanic
				-- DMTextFull = colors.COLOR_BROWN:Colorize(tostring(count)..".  "..tostring(tooltipMechanicFull))
			-- else
				-- DMText = DMText..", "..tooltipMechanic
				-- DMTextFull = DMTextFull.."\n"..colors.COLOR_BROWN:Colorize(tostring(count)..".  "..tostring(tooltipMechanicFull))
			-- end
		-- end
	-- end	

	-- setID = setID,
	-- setDLCID = setDLCID,
	-- setDLCName = setDLCName,
	-- setSource = setSource,
	-- setObtainableItemsTable = setObtainableItemsTable,
	-- setObtainableItems = setObtainableItems,
	-- setItemsID = setItemsID,
	-- setName = setName,
	-- setTypeName = setTypeName,
	-- setTraits = setTraits,
	-- setVeteran = setVeteran,
	-- setBindType = setBindType,
	-- setWayshrines = setWayshrines,
	-- setZoneIds = setZoneIds,
	-- setZoneNames = setZoneNames,
	-- setDropMechanic = setDropMechanic,
	-- setDropMechanicNames = setDropMechanicNames,
	
	if KELA_SETS_LIST.comparedSetData ~= false then 
	    -- self:AddLine(name, self:GetStyle("title"))

		comparedData = KELA_SETS_LIST.comparedSetData
		local bodySection2 = self:AcquireSection(self:GetStyle("bodySection"))	
		local name2 = colors.COLOR_WHITE:Colorize(string.upper(comparedData.setName))
		if name2 then bodySection2:AddLine(name2, self:GetStyle("title")) end
		if comparedData.setObtainableItemsFull then bodySection2:AddLine(GetString(KELA_SETSLIST_HEADER_OBTAINABLEITEMS)..": "..colors.COLOR_WHITE:Colorize(comparedData.setObtainableItemsFull), self:GetStyle("bodyDescription")) end	
		self:AddSection(bodySection2)		
		local itemID = LibSets.GetSetItemId(comparedData.setID)
		local itemLink = LibSets.buildItemLink(itemID, 370)
		if itemLink then
			local bodySection2 = self:AcquireSection(self:GetStyle("bodySection"))	
			bodySection2:AddLine(colors.COLOR_WHITE:Colorize(GetString(KELA_SETS_TOOLTIP_BONUSES)), self:GetStyle("bodyDescription"))
			local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)
			for i=1, numBonuses do
				local numRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, false, i)
				bodySection2:AddLine(bonusDescription, self:GetStyle("activeBonus"), self:GetStyle("bodyDescription"))
			end		
			self:AddSection(bodySection2)	
		end

		local bodySection2 = self:AcquireSection(self:GetStyle("bodySection"))	
		bodySection2:AddLine(" ", self:GetStyle("bodyDescription"), {customSpacing = -20}) 
		bodySection2:AddLine("________________________________", self:GetStyle("bodyDescription"), {customSpacing = -20, horizontalAlignment = TEXT_ALIGN_CENTER}) 
		bodySection2:AddLine(" ", self:GetStyle("bodyDescription"), {customSpacing = -20}) 
		self:AddSection(bodySection2)		

		local bodySection = self:AcquireSection(self:GetStyle("bodySection"))	
		local name = colors.COLOR_WHITE:Colorize(string.upper(data.setName))
		if name then bodySection:AddLine(name, self:GetStyle("title")) end
		if data.setObtainableItemsFull then bodySection:AddLine(GetString(KELA_SETSLIST_HEADER_OBTAINABLEITEMS)..": "..colors.COLOR_WHITE:Colorize(data.setObtainableItemsFull), self:GetStyle("bodyDescription")) end	
		self:AddSection(bodySection)	
		local itemID = LibSets.GetSetItemId(data.setID)
		local itemLink = LibSets.buildItemLink(itemID, 370)
		if itemLink then
			local bodySection = self:AcquireSection(self:GetStyle("bodySection"))	
			bodySection:AddLine(colors.COLOR_WHITE:Colorize(GetString(KELA_SETS_TOOLTIP_BONUSES)), self:GetStyle("bodyDescription"))
			local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)
			for i=1, numBonuses do
				local numRequired, bonusDescription, a1, a2, a3, a4, a5 = GetItemLinkSetBonusInfo(itemLink, false, i)
				bodySection:AddLine(bonusDescription, self:GetStyle("activeBonus"), self:GetStyle("bodyDescription"))
			end		
			self:AddSection(bodySection)	
		end	
		
	else	
		local bodySection = self:AcquireSection(self:GetStyle("bodySection"))	
		local name = colors.COLOR_WHITE:Colorize(string.upper(data.setName))
		if name then bodySection:AddLine(name, self:GetStyle("title")) end

		if data.setTypeName then bodySection:AddLine(GetString(KELA_SETSLIST_HEADER_SETTYPE)..": "..data.setTypeName, self:GetStyle("bodyDescription")) end
		if data.setDLCName then bodySection:AddLine(GetString(KELA_SETSLIST_HEADER_DLC)..": "..colors.COLOR_WHITE:Colorize(data.setDLCName), self:GetStyle("bodyDescription")) end
		if data.setObtainableItemsFull then bodySection:AddLine(GetString(KELA_SETSLIST_HEADER_OBTAINABLEITEMS)..": "..colors.COLOR_WHITE:Colorize(data.setObtainableItemsFull), self:GetStyle("bodyDescription")) end

		if data.setZoneNames then 
			local ZoneText
			if data.setDropMechanic then
				ZoneText = GetString(KELA_SETSLIST_HEADER_DROPZONE)..": "..colors.COLOR_WHITE:Colorize(tostring(data.setZoneNames)).." ("..data.DMText..")"
			else
				ZoneText = GetString(KELA_SETSLIST_HEADER_DROPZONE)..": "..colors.COLOR_WHITE:Colorize(tostring(data.setZoneNames))
			end
			bodySection:AddLine(ZoneText, self:GetStyle("bodyDescription")) 
		end

		bodySection:AddLine(" ", self:GetStyle("bodyDescription"), {customSpacing = -20}) 
		self:AddSection(bodySection)
		
		if data.setTraits or data.setVeteran or data.setBindType then -- or data.setWayshrines then
			local bodySection = self:AcquireSection(self:GetStyle("bodySection"))	
			bodySection:AddLine(colors.COLOR_WHITE:Colorize(GetString(KELA_SETS_TOOLTIP_EXTRA)), self:GetStyle("bodyDescription"))
			self:AddSection(bodySection)
			local ExtraList
			local infoExtraSection = self:AcquireSection(self:GetStyle("InfoTooltipDesc"))
			local infoExtra = self:AcquireStatValuePair(self:GetStyle("InfoTooltipStatValuePair"))
			local bop = colors.COLOR_BROWN:Colorize("- ")
			if data.setTraits then 
				ExtraList = bop..colors.COLOR_PINK:Colorize(GetString(KELA_SETS_TOOLTIP_TRAITS1))..colors.COLOR_WHITE:Colorize(data.setTraits)..colors.COLOR_PINK:Colorize(GetString(KELA_SETS_TOOLTIP_TRAITS2))
			end
			if data.canTeleport then 
				if ExtraList then
					ExtraList = ExtraList.."\n"..bop..colors.COLOR_STAMINA:Colorize(GetString(KELA_SETS_TOOLTIP_HAVEWAYSHRINE))
				else
					ExtraList = bop..colors.COLOR_STAMINA:Colorize(GetString(KELA_SETS_TOOLTIP_HAVEWAYSHRINE))
				end
			end
			if data.setVeteran then
				if ExtraList then
					ExtraList = ExtraList.."\n"..bop..colors.COLOR_ORANGE:Colorize(GetString(KELA_SETS_VETERANFULL))
				else
					ExtraList = bop..colors.COLOR_ORANGE:Colorize(GetString(KELA_SETS_VETERANFULL))
				end
			end
			if data.setBindType then 
				if ExtraList then
					ExtraList = ExtraList.."\n"..bop..colors.COLOR_BROWN:Colorize(GetString("SI_BINDTYPE", data.setBindType))
				else
					ExtraList = bop..colors.COLOR_BROWN:Colorize(GetString("SI_BINDTYPE", data.setBindType))
				end
			end
			infoExtra:SetStat(" ", self:GetStyle("InfoTooltipStatValuePairStat"))
			infoExtra:SetValue(ExtraList, self:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
			infoExtraSection:AddStatValuePair(infoExtra)
			self:AddSection(infoExtraSection)		
		end	
		
		local itemID = LibSets.GetSetItemId(data.setID)
		local itemLink = LibSets.buildItemLink(itemID)
		if itemLink then
			local bodySection = self:AcquireSection(self:GetStyle("bodySection"))	
			bodySection:AddLine(" ", self:GetStyle("bodyDescription"), {customSpacing = -20}) 
			bodySection:AddLine(colors.COLOR_WHITE:Colorize(GetString(KELA_SETS_TOOLTIP_BONUSES)), self:GetStyle("bodyDescription"))
			
			 -- {horizontalAlignment = TEXT_ALIGN_CENTER})
					-- headerInfo:AddLine(colors.COLOR_GREY:Colorize(GetString(KELA_TOOLTIP_INTERESTING_INFORMATION_NO)), {horizontalAlignment = TEXT_ALIGN_CENTER})

			local _, _, numBonuses = GetItemLinkSetInfo(itemLink, false)
		
			--CHAT_SYSTEM:AddMessage("itemLink "..tostring(itemLink)..", numBonuses "..tostring(numBonuses))
			
			for i=1, numBonuses do
				local numRequired, bonusDescription = GetItemLinkSetBonusInfo(itemLink, false, i)
				bodySection:AddLine(bonusDescription, self:GetStyle("activeBonus"), self:GetStyle("bodyDescription"))
			end		
			bodySection:AddLine(" ", self:GetStyle("bodyDescription"), {customSpacing = -20}) 
			self:AddSection(bodySection)
		end


		
		if data.setDropMechanic then 
			local bodySection = self:AcquireSection(self:GetStyle("bodySection"))	
			bodySection:AddLine(colors.COLOR_WHITE:Colorize(GetString(KELA_SETS_TOOLTIP_DROPMECHANIC)), self:GetStyle("bodyDescription"))
			self:AddSection(bodySection)
			local infoDMSection = self:AcquireSection(self:GetStyle("InfoTooltipDesc"))
			local infoDM = self:AcquireStatValuePair(self:GetStyle("InfoTooltipStatValuePair"))
			infoDM:SetStat(" ", self:GetStyle("InfoTooltipStatValuePairStat"))
			infoDM:SetValue(data.DMTextFull, self:GetStyle("InfoTooltipStatValuePairValueLeftAlign"))
			infoDMSection:AddStatValuePair(infoDM)
			self:AddSection(infoDMSection)	
		end	
			
	
	end
	
end

			

			












