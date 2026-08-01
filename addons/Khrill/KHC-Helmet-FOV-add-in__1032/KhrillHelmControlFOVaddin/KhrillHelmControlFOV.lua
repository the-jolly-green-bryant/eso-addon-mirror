------------------------------------------
--               FOV addin              --
--            for Helm Control          --
--               by Khrill              --
--                                      --
--                v 1.4.0               --
------------------------------------------

KHCFOV = {}
KHCFOV.name ="KhrillHelmControlFOVaddin"
KHCFOV.version = "1.4.0"
KHCFOV.defaults = {
	settingsVersion = 105,
	Zoom = {0,1,0,1},
	opacity = 1,
}
KHCFOV.accountDefaults = {
}
KHCFOV.settings = KHCFOV.defaults
KHCFOV.accountSettings = KHCFOV.accountDefaults
KHCFOV.activeAddon = {
	ImmersiveHorseRiding = false,
}

local FOVWnd
local isFirst = false
--local thirdPersonZoom = "4.00000000"
local HelmsSliderOffset = 0
local HelmsMaxRow = 6
local HelmsMaxCol = 5
local HelmsTotal = 0
local texturePath = "KhrillHelmControlFOVaddin/Fov/"
local textureList = {}
--	textureList = {
--		[ITEMSTYLE_RACIAL_ARGONIAN] = {"texture1.dds", "texture2.dds" , ...}
--		[ItemStyle] = {filename, ...}
--	}
local textureZoom = {}
--	textureZoom = {
--		[textureFilename] = {left, right, top, bottom} -- zoom value
--	}

--[[ItemStyle:
* ITEMSTYLE_NONE				0
* ITEMSTYLE_RACIAL_ARGONIAN		6
* ITEMSTYLE_RACIAL_BRETON		1
* ITEMSTYLE_RACIAL_DARK_ELF		4
* ITEMSTYLE_RACIAL_HIGH_ELF		7
* ITEMSTYLE_RACIAL_IMPERIAL		34
* ITEMSTYLE_RACIAL_KHAJIIT		9
* ITEMSTYLE_RACIAL_NORD			5
* ITEMSTYLE_RACIAL_ORC			3
* ITEMSTYLE_RACIAL_REDGUARD		2
* ITEMSTYLE_RACIAL_WOOD_ELF		8
* ITEMSTYLE_AREA_DWEMER			14
* ITEMSTYLE_AREA_ANCIENT_ELF	15
* ITEMSTYLE_AREA_REACH			17
* ITEMSTYLE_ENEMY_PRIMITIVE		19
* ITEMSTYLE_ENEMY_DAEDRIC		20
]]
local styleFilter = {}
local selectedIcon = nil
local selectedHelm = {}
--	selectedHelm = {
--		texture = filename,
--		itemStyle = ItemStyle,
--		listIndex = position in textureList,	
--		zoom = texturecoord position,
--	}
local TEXTURES = {
	[ARMORTYPE_NONE] = "default/fov_00_null.dds",
	[ARMORTYPE_HEAVY] = "default/fov_06_mithril.dds",
	[ARMORTYPE_MEDIUM] = "default/fov_03_thief.dds",
	[ARMORTYPE_LIGHT] = "default/fov_24_generichood.dds",
}
--local TEXTURESCOORD = { -- left, right, top, bottom
--	[ARMORTYPE_NONE] = {0,1,0,1},
--	[ARMORTYPE_HEAVY] = {.15,.85,.20,1},
--	[ARMORTYPE_MEDIUM] = {.15,.85,.20,1}, --{0,1,0,1}, 
--	[ARMORTYPE_LIGHT] = {.15,.85,.20,1},
--}
local TEXTURE_CLOSE = "/esoui/art/buttons/cancel_up.dds"
local TEXTURE_OUTLINE = KHCFOV.name .. "/art/gridItem_outline.dds"
local TEXTURE_SLIDER = "/esoui/art/miscellaneous/scrollbox_elevator.dds"
local TEXTURE_PARAM = "/esoui/art/chatwindow/chat_options_up.dds"
local TEXTURE_HEAD = "/esoui/art/characterwindow/gearslot_head.dds"
local TEXTURE_ICONINVENTORY = KHCFOV.name .. "/art/fovicon.dds"

local COLOR_KHRILLSELECT = "FF6A00" -- orange ^^
local COLOR_NOCOLOR = "FFFFFF" --transparent
local COLOR_BG = "C5C29E" --sand
local COLOR_DISABLED = "303030" -- gray black

local stringLocal = {
	["fr"] = {Zoom = "Zoom", Opacity = "Opacit\195\169",},
	["en"] = {Zoom = "Zoom", Opacity = "Opacity",},
	["de"] = {Zoom = "Zoom", Opacity = "Opazit\195\164t",},
	["es"] = {Zoom = "Zoom", Opacity = "Opacidad",},
}
local langString

-- // **********
-- //  Utility
-- // **********
local function HexToRGBA( hex )
	if string.len(hex) == 6 then hex = hex.."FF" end
    local rhex, ghex, bhex, ahex = string.sub(hex, 1, 2), string.sub(hex, 3, 4), string.sub(hex, 5, 6), string.sub(hex, 7, 8)
    return tonumber(rhex, 16)/255, tonumber(ghex, 16)/255, tonumber(bhex, 16)/255, tonumber(ahex, 16)/255
end
local function RGBAToHex( r, g, b, a )
	if a == nil then a = 1 end
	r = r <= 1 and r >= 0 and r or 0
	g = g <= 1 and g >= 0 and g or 0
	b = b <= 1 and b >= 0 and b or 0
	return string.upper(string.format("%02x%02x%02x%02x", r * 255, g * 255, b * 255, a * 255))
end
local function getKeyByValue(t, value)
	for k,v in pairs(t) do
		if v==value then return k end
	end
	return nil
end
local function GetItemLinkID(link)
	if type(link) == "string" then
		local itemId = link:match("|H.-:.-:(.-):")
		if itemId ~= nil then
			return tonumber(itemId)
		end
	end
	return nil
end
local function ControlChangeColor(control, hexColor)
	control:SetColor(HexToRGBA(hexColor)) 
end
local function isControlColorEgalTo(control, hexColor)
	return string.sub(RGBAToHex(control:GetColor()), 1, 6) == string.sub(hexColor, 1, 6)
end
local function TableCopy(src, dest)
    if type(dest) ~= 'table' then dest = {} end
	if type(src) == 'table' then
		for k, v in pairs(src) do
			if type(v) == 'table' then
				TableCopy(v, dest[k])
			end
			dest[k] = v
		end
	end
end
local function TableCount(src)
	local count = 0
	if type(src) == 'table' then
		for k,v in pairs(src) do
			count = count +1
		end
	end
	return count
end

local function addButton(parent, name, callbackFunction, text, font, tooltipText, tooltipAlign, textureNormal, textureMouseOver, textureClicked, color, width, height, left, top, alignValue, alignControl, alignControlValue, hideButton, outlineSelect)
	--Add a button to an existing parent control (original code by Votan)
--	d("addButton "..name..","..tostring(hideButton))
	--Abort needed?
	if  (parent == nil or name == nil or callbackFunction == nil
		or width <= 0 or height <= 0 )
		and (textureNormal == nil or text == nil) then
			return nil
	end
	local button
    --Does the button already exist?
    button = WINDOW_MANAGER:GetControlByName(name, "")
    if button == nil then
        --Button does not exist yet and it should be hidden? Abort here!
        if hideButton == true then return nil end
        --Create the button control at the parent
        button = WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)
    end
    --Button was created?
    if button ~= nil then
        -- -- Button should be hidden?
        -- if hideButton == false then
			local highlightColor = nil
			local isColorInitiated = false
			local defaultColor = color or COLOR_NOCOLOR
			button.color = defaultColor
            --Set the button's size
            button:SetDimensions(width, height)
            --Align the button
            if alignControl == nil then
                alignControl = parent
            end
            --SetAnchor(point, relativeTo, relativePoint, offsetX, offsetY)
			if alignValue == nil then alignValue = TOPLEFT end
			if alignControlValue == nil then alignControlValue = TOPLEFT end
			button:ClearAnchors()
            button:SetAnchor(alignValue, alignControl, alignControlValue, left, top)
			highlightColor = COLOR_KHRILLSELECT
            --Texture or text?
            if (text ~= nil) then
                --Text
				button.type = "Label"
				local label
                 --Check if label exists
                label = WINDOW_MANAGER:GetControlByName(name .. "Label", "")
                if label == nil then
                    --Create the label for the button to hold the text
                    label = WINDOW_MANAGER:CreateControl(name .. "Label", button, CT_LABEL)
                end
				label:SetAnchorFill()
				label:SetVerticalAlignment(TEXT_ALIGN_CENTER)
				label:SetHorizontalAlignment(TEXT_ALIGN_CENTER)
                --Set the label's font
                if font == nil then
                    label:SetFont("ZoFontGameSmall")
                else
                    label:SetFont(font)
                end
                --Set the button's text
                label:SetText(text)
				--Set default color
				label.color = defaultColor
				label:SetColor(HexToRGBA(defaultColor))
				label:SetHidden(false)
            else
				-- if color ~= nil then --add  bg color
					-- local bgcolor = GetControl(name .. "BGColor")
					-- if bgcolor == nil then
						-- bgcolor = WINDOW_MANAGER:CreateControl(name .. "BGColor", button, CT_BACKDROP)
						-- bgcolor:SetCenterColor(HexToRGBA(color))
						-- bgcolor:SetEdgeColor(HexToRGBA(color))
						-- bgcolor:SetAlpha(0.5)
						-- bgcolor:SetAnchorFill(button)
						-- bgcolor:SetDrawLayer(DL_OVERLAY)
					-- end				
				-- end
                --Texture
				button.type = "Texture"
                local texture
                 --Check if texture exists
                texture = WINDOW_MANAGER:GetControlByName(name .. "Texture", "")
                if texture == nil then
                    --Create the texture for the button to hold the image
                    texture = WINDOW_MANAGER:CreateControl(name .. "Texture", button, CT_TEXTURE)
                end
                texture:SetAnchorFill()
                --Set the texture for normale state now
                texture:SetTexture(textureNormal)
                --Do we have seperate textures for the button states?
				if textureMouseOver == nil and textureClicked == nil then
					isColorInitiated = (isControlColorEgalTo(texture, highlightColor))
				end
				texture.color = defaultColor
				texture:SetColor(HexToRGBA(defaultColor))
                button.upTexture      = textureNormal
                button.downTexture    = textureMouseOver or textureNormal
                button.clickedTexture = textureClicked or textureNormal
            end
			button.highlightColor = highlightColor
			button.isColorInitiated = isColorInitiated
			
			if outlineSelect == true then
				local outline
				 --Check if texture exists
				outline = WINDOW_MANAGER:GetControlByName(name .. "Outline", "")
				if outline == nil then
					--Create the texture for the button to hold the image
					outline = WINDOW_MANAGER:CreateControl(name .. "Outline", button, CT_TEXTURE)
					outline:SetDimensions(width+4, height+4)
					outline:SetAnchor(TOPLEFT, button, TOPLEFT, -2, -2)
--					outline:SetAnchorFill()
					--Set the texture for normale state now
					outline:SetTexture(TEXTURE_OUTLINE)
					outline:SetTextureCoords(.07,.93,.07,.93)
					outline:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
				end
				outline:SetHidden(not isColorInitiated)
			end
			
            if tooltipAlign == nil then tooltipAlign = TOP end
            --Set a tooltip?
            if tooltipText ~= nil then
                if button:GetHandler("OnMouseEnter") == nil then button:SetHandler("OnMouseEnter", function(self)
                    if self.downTexture then self:GetChild(1):SetTexture(self.downTexture) end
					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.highlightColor)) end
                    ZO_Tooltips_ShowTextTooltip(self, tooltipAlign, tooltipText)
					end)
				end
                if button:GetHandler("OnMouseExit") == nil then button:SetHandler("OnMouseExit", function(self)
                    if self.upTexture then self:GetChild(1):SetTexture(self.upTexture) end
					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.color)) end
                    ZO_Tooltips_HideTextTooltip()
					end)
				end
            else
                if button:GetHandler("OnMouseEnter") == nil then button:SetHandler("OnMouseEnter", function(self)
                    if self.downTexture then self:GetChild(1):SetTexture(self.downTexture) end
 					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.highlightColor)) end
					end)
				end
                if button:GetHandler("OnMouseExit") == nil then button:SetHandler("OnMouseExit", function(self)
                    if self.upTexture then self:GetChild(1):SetTexture(self.upTexture) end
 					if self.highlightColor ~= nil and not self.isColorInitiated then self:GetChild(1):SetColor(HexToRGBA(self.color)) end
					end)
				end
            end
            --Set the callback function of the button
            if button:GetHandler("OnClicked") == nil then button:SetHandler("OnClicked", function(butn)
				if butn.highlightColor ~= nil and not butn.isColorInitiated then butn:GetChild(1):SetColor(HexToRGBA(butn.color)) end
				butn.isColorInitiated = not(butn.isColorInitiated)
                callbackFunction()
				end)
			end
			if button:GetHandler("OnMouseDown") == nil then button:SetHandler("OnMouseDown", function(butn, ctrl, alt, shift, command)
				if butn.clickedTexture then butn:GetChild(1):SetTexture(butn.clickedTexture) end
				end)
			end
			--Show the button and make it react on mouse input
			button:SetHidden(hideButton) --false)
			button:SetMouseEnabled(not hideButton) --true)
			--Return the button control
			return button
		-- else
			-- --Hide the button and make it not reacting on mouse input
			-- button:SetHidden(true)
			-- button:SetMouseEnabled(false)
		-- end
	else
		return nil
	end
end
local function isButtonItemSelected(button)
	local color = button.color or COLOR_NOCOLOR
	return not isControlColorEgalTo(button:GetNamedChild("Texture"), color)	
end
local function addSlider(parent, name, callbackFunction, minValue, maxValue, step, defaultValue, orientation, width, height, left, top, alignValue, alignControl, alignControlValue)
--d("--addSlider:"..name..","..minValue..","..maxValue..","..step..","..defaultValue..","..orientation)
	--add a slider with min and max text and label for selected
	--Abort needed?
	if (parent == nil or name == nil) then
		return nil
	end
	if orientation == nil then orientation = ORIENTATION_HORIZONTAL end
	
--	local myslider = WINDOW_MANAGER:CreateControlFromVirtual(name, parent, "ZO_Slider")
	local myslider = WINDOW_MANAGER:CreateControl(name, parent, CT_SLIDER)
	myslider:SetThumbTexture("EsoUI\\Art\\Miscellaneous\\scrollbox_elevator.dds", nil, nil, 12, 12) --,0,0,1,1)

	if orientation == ORIENTATION_HORIZONTAL then
		myslider:SetDimensions(50, 18)
	else
		myslider:SetDimensions(8, 55)
	end
	myslider:SetDimensions(width, height)
	myslider:SetAnchor(alignValue, alignControl, alignControlValue, left, top)
	myslider:SetOrientation(orientation)
	myslider:SetMinMax(minValue,maxValue)
	myslider:SetValueStep(step) 
	myslider:SetValue(defaultValue) 
	myslider:SetMouseEnabled(true)
	if callbackFunction == nil then
		if myslider:GetHandler("OnValueChanged") == nil then myslider:SetHandler("OnValueChanged", function(self, value, eventReason)
				if eventReason == EVENT_REASON_SOFTWARE then return end
				self.selText:SetText(value)	
			end)
		end
	else
		if myslider:GetHandler("OnValueChanged") == nil then myslider:SetHandler("OnValueChanged", function(self, value, eventReason)
				if eventReason == EVENT_REASON_SOFTWARE then return end
				self.selText:SetText(value)
				callbackFunction()
			end)
		end
	end
	myslider:SetHidden(false)
	myslider:SetDrawLevel(2)
	myslider.bg = WINDOW_MANAGER:CreateControl(nil, myslider, CT_BACKDROP)
	local bg = myslider.bg
	bg:SetCenterColor(0, 0, 0)
	bg:SetAnchor(TOPLEFT, myslider, TOPLEFT, 0, 4)
	bg:SetAnchor(BOTTOMRIGHT, myslider, BOTTOMRIGHT, 0, -4)
	bg:SetEdgeTexture("EsoUI\\Art\\Tooltips\\UI-SliderBackdrop.dds", 32, 4)
	-- actual value label
	myslider.selText = WINDOW_MANAGER:CreateControl(nil, myslider, CT_LABEL)
	local selText = myslider.selText
	selText.Color=COLOR_KHRILLSELECT
	selText:SetFont("ZoFontGame")
	selText:SetColor(HexToRGBA(selText.Color))
	if alignValue == LEFT then opposite = RIGHT
	elseif alignValue == RIGHT then opposite = LEFT
	elseif alignValue == TOP then opposite = BOTTOM
	elseif alignValue == BOTTOM then opposite = TOP
	end
	selText:SetAnchor(alignValue, myslider, opposite)
	selText:SetAnchor(alignValue, myslider, opposite)
	selText:SetText(defaultValue)
	-- -- min & max labels
	-- myslider.minText = WINDOW_MANAGER:CreateControl(nil, myslider, CT_LABEL)
	-- local minText = myslider.minText
	-- minText.Color=COLOR_DISABLED
	-- minText:SetFont("ZoFontGameSmall")
	-- minText:SetColor(HexToRGBA(minText.Color))
	-- minText:SetAnchor(RIGHT, myslider, LEFT,-10)
	-- minText:SetText(minValue)
	-- myslider.maxText = WINDOW_MANAGER:CreateControl(nil, myslider, CT_LABEL)
	-- local maxText = myslider.maxText
	-- maxText.Color=COLOR_DISABLED
	-- maxText:SetFont("ZoFontGameSmall")
	-- maxText:SetColor(HexToRGBA(maxText.Color))
	-- maxText:SetAnchor(LEFT, myslider, RIGHT,10)
	-- maxText:SetText(maxValue)

	return myslider
end

-- private functions --
-----------------------
local function OnCameraDeactivated()
--d("OnCameraDeactivated")
	FOVWnd:SetHidden(true)
end
local function KHCFOV_OnInventoryShow(self, hidden)
--	d("--OnInventoryShow:"..tostring(hidden))
	FOVWnd:SetHidden(true)
end
local function KHCFOV_OnInventoryHide(self, hidden)
	KHCFOV:OnSettingClose()
	KHCFOV:CheckFov()
end
local function OnInventoryUpdate(eventCode, bagId, slotId, isNewItem, itemSoundCategory, updateReason)
    --if ((updateReason == INVENTORY_UPDATE_REASON_DURABILITY_CHANGE) and (bagId == BAG_WORN)) then
    if bagId == BAG_WORN and slotId == EQUIP_SLOT_HEAD then	KHCFOV:RefreshSettingUI() end
end

local function initSetting()
	-- Main panel + helm icon + title
	local wnd = WINDOW_MANAGER:CreateTopLevelWindow()
	local panel = WINDOW_MANAGER:CreateControl("KHCFOVSettings", wnd, CT_CONTROL)
	panel:SetDimensions(800, 500)
	panel:SetDrawLayer(DL_OVERLAY)
	panel:SetHidden(true)
	panel.icon = WINDOW_MANAGER:CreateControl("KHCFOVSettingsIcon", panel, CT_TEXTURE)
	panel.icon:SetDimensions(48, 48)
	panel.icon:SetAnchor(BOTTOMLEFT, panel, TOPLEFT, 5, -8)
	panel.label = WINDOW_MANAGER:CreateControl("KHCFOVSettingsLabel", panel, CT_LABEL)
	panel.label:SetAnchor(LEFT, panel.icon, RIGHT, 10, 5)
	panel.label:SetFont("EsoUI/Common/Fonts/Handwritten_Bold.otf|36|shadow")
	panel.label:SetText("Helmet FOV")
	panel.label:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
	panel.label:SetStyleColor(HexToRGBA("FFFFFFFF"))
	-- filter zone (race)
	panel.filters = WINDOW_MANAGER:CreateControl("KHCFOVSettingsFilters", panel, CT_CONTROL)
	panel.filters:SetDimensions(150, 480)
	panel.filters:SetAnchor(TOPLEFT, panel, TOPLEFT, 0, 0)
	panel.filters:SetHidden(false)
	panel.filters.bg = WINDOW_MANAGER:CreateControlFromVirtual("KHCFOVSettingsFiltersBG", panel.filters, "ZO_DefaultBackdrop")
	panel.filters.bg:SetAlpha(0.7)
	panel.filters.bg:SetHidden(false)
	panel.filters.label = WINDOW_MANAGER:CreateControl("KHCFOVSettingsFiltersLabel", panel.filters, CT_LABEL)
	panel.filters.label:SetAnchor(TOP, panel.filters, BOTTOM, 0, 2)
	panel.filters.label:SetFont("EsoUI/Common/Fonts/ProseAntiquePSMT.otf|22|soft-shadow-thick")
	panel.filters.label:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
	panel.filters.label:SetText("Race")
	panel.filters.label:SetHidden(false)
	-- helm textures zone
	panel.helms = WINDOW_MANAGER:CreateControl("KHCFOVSettingsHelms", panel, CT_CONTROL)
	panel.helms:SetDimensions(640, 480)
	panel.helms:SetAnchor(TOPLEFT, panel.filters, TOPRIGHT, 20, 0)
	panel.helms:SetMouseEnabled(true)
	panel.helms:SetHandler("OnMouseWheel", function(self, delta) KHCFOV:OnMouseWheel(delta) end)
	panel.helms:SetHidden(false)
	panel.helms.bg = WINDOW_MANAGER:CreateControlFromVirtual("KHCFOVSettingsHelmsBG", panel.helms, "ZO_DefaultBackdrop")
	panel.helms.bg:SetAlpha(0.7)
	panel.helms.bg:SetHidden(false)
	panel.helms.bgcolor = WINDOW_MANAGER:CreateControl("KHCFOVSettingsHelmsBGColor", panel.helms, CT_BACKDROP) --"ZO_DefaultBackdrop")
	panel.helms.bgcolor:SetCenterColor(HexToRGBA(COLOR_BG))
	panel.helms.bgcolor:SetEdgeColor(HexToRGBA(COLOR_BG))
	panel.helms.bgcolor:SetAlpha(0.5)
	panel.helms.bgcolor:SetDimensions(648, 488)
	panel.helms.bgcolor:SetAnchor(TOPLEFT, panel.helms, TOPLEFT, -5, -5)
	panel.helms.bgcolor:SetEdgeTexture("",1,1,1)
	panel.helms.bgcolor:SetHidden(false)
	panel.helms.label = WINDOW_MANAGER:CreateControl("KHCFOVSettingsHelmsLabel", panel.helms, CT_LABEL)
	panel.helms.label:SetAnchor(TOP, panel.helms, BOTTOM, 0, 2)
	panel.helms.label:SetFont("EsoUI/Common/Fonts/ProseAntiquePSMT.otf|22|soft-shadow-thick")
	panel.helms.label:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
	panel.helms.label:SetText("Helms")
	panel.helms.label:SetHidden(false)
	-- slider
	panel.helms.slider = CreateControl("KHCFOVSettingsHelmsSlider",panel.helms,CT_SLIDER)
	panel.helms.slider:SetDimensions(30,488)
	panel.helms.slider:SetMouseEnabled(true)
	panel.helms.slider:SetThumbTexture(TEXTURE_SLIDER,TEXTURE_SLIDER,TEXTURE_SLIDER,20,245,0,0,1,1)
	panel.helms.slider:SetValueStep(1)
	panel.helms.slider:SetAnchor(TOPLEFT,panel.helms,TOPRIGHT,-2,-5)
	panel.helms.slider:SetHandler("OnValueChanged",function(self,value,eventReason) KHCFOV:OnSliderMove(value) end)
	panel.helms.slider:SetHidden(false)
	
	-- Add all itemStyle as filters
	local styleList = {}
	local maxStyles = 0
	for styleIndex = 1, GetNumSmithingStyleItems() do
        local name, icon, sellPrice, meetsUsageRequirement, itemStyle, quality = GetSmithingStyleItemInfo(styleIndex)
		if name ~= "" then
			table.insert(styleList, {styleIndex=styleIndex, name=name, icon=icon, itemStyle=itemStyle, control=nil})
			maxStyles = maxStyles +1
		end
	end
	for k, v in pairs(styleList) do
		local posX = 70*(math.floor((k-1)/9)) +10
		local posY = 52*((k-1)%9) +10
        if v.itemStyle == ITEMSTYLE_NONE then
            v.icon = nil
        end
        local tipName = GetString("SI_ITEMSTYLE", v.itemStyle)
 		local button = addButton(panel.filters, panel.filters:GetName()..v.itemStyle, function(...) KHCFOV:OnFilterSelect(v.styleIndex,v.itemStyle) end, nil, nil, tipName, BOTTOM, v.icon, nil, nil, nil, 45, 45, posX, posY, TOPLEFT, panel.filters, TOPLEFT, false, true)
		v.control = button
	end
	panel.filters.styleList = styleList
	panel.filters:SetDimensions(70*(math.floor((maxStyles-1)/9)+1), 480)
	-- close btn
	local closeBtn = addButton(panel, panel:GetName().."CloseBtn", function(...) KHCFOV:OnSettingClose() end, nil, nil, "Close", TOP, TEXTURE_CLOSE, nil, nil, COLOR_KHRILLSELECT, 28, 28, -17, -4, BOTTOMLEFT, panel.helms, TOPRIGHT, false)
	-- param btn
	addButton(panel, panel:GetName().."ParamBtn", function(...) KHCFOV:OnSettingParam() end, nil, nil, "FOV Zoom", TOP, TEXTURE_PARAM, nil, nil, nil, 36, 36, 0, 0, RIGHT, closeBtn, LEFT, false)

	return panel
end
local function updateParam(zoom)
	local panel = GetControl("KHCFOVSettingsParam")
	if panel ~= nil then
		panel.leftSlider:SetValue(zoom[1]*100)
		panel.leftSlider.selText:SetText(zoom[1]*100)
		panel.rightSlider:SetValue(zoom[2]*100)
		panel.rightSlider.selText:SetText(zoom[2]*100)
		panel.topSlider:SetValue(zoom[3]*100)
		panel.topSlider.selText:SetText(zoom[3]*100)
		panel.bottomSlider:SetValue(zoom[4]*100)
		panel.bottomSlider.selText:SetText(zoom[4]*100)
	end
end
local function initParam()
	local panel = GetControl("KHCFOVSettings")
	-- param zone (zoom)
	panel.param = WINDOW_MANAGER:CreateControl("KHCFOVSettingsParam", panel, CT_CONTROL)
	panel.param:SetDimensions(150, 150)
	panel.param:SetAnchor(BOTTOMRIGHT, KHCFOVSettingsParamBtn, BOTTOMLEFT, -10, -12)
	panel.param:SetHidden(false)
	panel.param.bg = WINDOW_MANAGER:CreateControlFromVirtual("KHCFOVSettingsParamBG", panel.param, "ZO_DefaultBackdrop")
	panel.param.bg:SetAlpha(0.7)
	panel.param.bg:SetHidden(false)
	panel.param.label = WINDOW_MANAGER:CreateControl("KHCFOVSettingsParamLabel", panel.param, CT_LABEL)
	panel.param.label:SetAnchor(BOTTOM, panel.param, TOP, 0, -5)
	panel.param.label:SetFont("EsoUI/Common/Fonts/ProseAntiquePSMT.otf|22|soft-shadow-thick")
	panel.param.label:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
	panel.param.label:SetText(langString.Zoom)
	panel.param.label:SetHidden(false)

	-- Sliders for texturecoord:  left, right, top, bottom (0..1)
	local zoom = KHCFOV.settings.Zoom
	if selectedHelm ~= nil and textureZoom[selectedHelm.texture] ~= nil then zoom = textureZoom[selectedHelm.texture] end
	panel.param.leftSlider = addSlider(panel.param, "KHCFOVSettingsParamLeft", function(...) KHCFOV:OnParamChange() end, 0, 50, 1, zoom[1]*100, ORIENTATION_HORIZONTAL, 50, 18, -5, 0, RIGHT, panel.param, CENTER)
	panel.param.rightSlider = addSlider(panel.param, "KHCFOVSettingsParamRight", function(...) KHCFOV:OnParamChange() end, 50, 100, 1, zoom[2]*100, ORIENTATION_HORIZONTAL, 50, 18, 5, 0, LEFT, panel.param, CENTER)
	panel.param.topSlider = addSlider(panel.param, "KHCFOVSettingsParamTop", function(...) KHCFOV:OnParamChange() end, 0, 50, 1, zoom[3]*100, ORIENTATION_VERTICAL, 8, 55, 0, -5, BOTTOM, panel.param, CENTER)
	panel.param.bottomSlider = addSlider(panel.param, "KHCFOVSettingsParamBottom", function(...) KHCFOV:OnParamChange() end, 50, 100, 1, zoom[4]*100, ORIENTATION_VERTICAL, 8, 55, 0, 5, TOP, panel.param, CENTER)
	updateParam(zoom)
	
	-- Opacity (zone & slider)
	panel.param.opacity = WINDOW_MANAGER:CreateControl("KHCFOVSettingsParamOpacity", panel.param, CT_CONTROL)
	panel.param.opacity:SetDimensions(150, 150)
	panel.param.opacity:SetAnchor(BOTTOMRIGHT, panel.param, BOTTOMLEFT, -10, 0)
	panel.param.opacity:SetHidden(false)
	panel.param.opacity.bg = WINDOW_MANAGER:CreateControlFromVirtual("KHCFOVSettingsParamOpacityBG", panel.param.opacity, "ZO_DefaultBackdrop")
	panel.param.opacity.bg:SetAlpha(0.7)
	panel.param.opacity.bg:SetHidden(false)
	panel.param.opacity.label = WINDOW_MANAGER:CreateControl("KHCFOVSettingsParamOpacityLabel", panel.param.opacity, CT_LABEL)
	panel.param.opacity.label:SetAnchor(BOTTOM, panel.param.opacity, TOP, 0, -5)
	panel.param.opacity.label:SetFont("EsoUI/Common/Fonts/ProseAntiquePSMT.otf|22|soft-shadow-thick")
	panel.param.opacity.label:SetStyleColor(HexToRGBA(COLOR_KHRILLSELECT))
	panel.param.opacity.label:SetText(langString.Opacity)
	panel.param.opacity.label:SetHidden(false)
	panel.param.opacity.slider = addSlider(panel.param.opacity, "KHCFOVSettingsParamOpacitySlider", function(...) KHCFOV:OnOpacityChange() end, 30, 100, 1, KHCFOV.settings.opacity*100, ORIENTATION_HORIZONTAL, 120, 18, 0, 0, TOP, panel.param.opacity, CENTER)
	
	return panel
end

local function CleanUI(parent)
	--d("--CleanHelmUI ")
	-- delete all child textures with Hidden
	for i=1,parent:GetNumChildren() do
		local controlName = parent:GetChild(i):GetName()
		if string.find(controlName, "BG") == nil and string.find(controlName, "Label") == nil and string.find(controlName, "Slider") == nil then
			parent:GetChild(i):SetHidden(true)
		end
	end
end

local function updateHelms()
--	d("updateHelms: offset="..HelmsSliderOffset)
	-- update printed FOV helmet with slider position
	for i= 1, HelmsTotal do
		local helmControl = GetControl("KHCFOVSettingsHelms"..i)
		local row = math.ceil(i/HelmsMaxCol) 
		if row >= HelmsSliderOffset and row < HelmsMaxRow+HelmsSliderOffset then
			helmControl:ClearAnchors()
			local posX = 130*((i-1)%HelmsMaxCol) +10
			local posY = 80*(row-HelmsSliderOffset) +10
			helmControl:SetAnchor(TOPLEFT, KHCFOVSettingsHelms, TOPLEFT, posX, posY)
			helmControl:SetHidden(false)
		else
			helmControl:SetHidden(true)
		end
	end
end
local function showHelm()
	-- Show all textures from packages and filtered by choosen races
	local panel = GetControl("KHCFOVSettingsHelms")
	CleanUI(panel)
	local cpt = 0
	local myHelm = nil
	if KHCFOV.accountSettings[selectedIcon] ~= nil then	myHelm = KHCFOV.accountSettings[selectedIcon] end --{texture, itemStyle, listIndex, zoom}
	for itemStyle, texturePack in pairs(textureList) do
--d("itemStyle "..itemStyle.."->"..tostring(styleFilter[tonumber(itemStyle)]))
		for i, texturefile in pairs(texturePack) do
			-- filter by race selected (or none)
			if TableCount(styleFilter) == 0 or styleFilter[tonumber(itemStyle)] == true then
				cpt = cpt +1
				local posX = 130*((cpt-1)%HelmsMaxCol) +10
				local posY = 80*(math.floor((cpt-1)/HelmsMaxCol)) +10
--d(cpt..":"..i.."="..texturefile.."("..posX..","..posY..")")
				local instant = cpt
				local button = addButton(panel, panel:GetName()..instant, function(...) KHCFOV:OnHelmSelect(instant,itemStyle,texturefile) end, nil, nil, texturefile, BOTTOM, texturePath..texturefile, nil, nil, nil, 96, 64, posX, posY, TOPLEFT, panel, TOPLEFT, false, true)
				-- is helm saved?
				if myHelm ~= nil and myHelm.texture == texturefile and myHelm.itemStyle == itemStyle then
					KHCFOV:OnHelmSelect(instant,itemStyle,texturefile,true) --select it
				end
			end
		end
	end
	HelmsTotal = cpt
	--slider
	local nbRow = math.ceil(HelmsTotal/HelmsMaxCol) 
	if nbRow <= HelmsMaxRow then
		KHCFOVSettingsHelmsSlider:SetMinMax(1,1)
		KHCFOVSettingsHelmsSlider:SetThumbTexture(TEXTURE_SLIDER,TEXTURE_SLIDER,TEXTURE_SLIDER,20,488,0,0,1,1)
	else
		updateHelms()
		KHCFOVSettingsHelmsSlider:SetMinMax(1,nbRow-HelmsMaxRow+1)
		KHCFOVSettingsHelmsSlider:SetThumbTexture(TEXTURE_SLIDER,TEXTURE_SLIDER,TEXTURE_SLIDER,20,245,0,0,1,1)
	end
	KHCFOVSettingsHelmsSlider:SetValue(1)
end

local function onScreenResized(eventCode, x, y, guiName)
	local width = GuiRoot:GetWidth() 
	local height = GuiRoot:GetHeight()
	KHCFOVUI:SetDimensions(width, height)
end


-- addin Interface functions --
-------------------------------
-- FOV
function KHCFOV:Put()
--d("--Put")
--d("DISTANCE ".. (GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)))
--d((GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) == "2.00000000")
-- d("1P_FIELD_OF_VIEW "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_FIRST_PERSON_FIELD_OF_VIEW))
-- d("3P_FIELD_OF_VIEW "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_FIELD_OF_VIEW))
-- d("3P_HORIZONTAL_OFFSET "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_OFFSET))
-- d("3P_HORIZONTAL_POSITION_MULTIPLIER "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_HORIZONTAL_POSITION_MULTIPLIER))
-- d("3P_VERTICAL_OFFSET "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_THIRD_PERSON_VERTICAL_OFFSET))


--GetItemInfo(BAG_WORN, EQUIP_SLOT_HEAD)
-- _Returns:_ *textureName* _icon_, *integer* _stack_, *integer* _sellPrice_, *bool* _meetsUsageRequirement_, *bool* _locked_, *integer* _equipType_, *integer* _itemStyle_, *integer* _quality_

--[[ ArmorType
* ARMORTYPE_HEAVY
* ARMORTYPE_LIGHT
* ARMORTYPE_MEDIUM
* ARMORTYPE_NONE
]]
	local helmArmorType = GetItemArmorType(BAG_WORN, EQUIP_SLOT_HEAD)
	if isFirst and helmArmorType ~= ARMORTYPE_NONE then
		local control = GetControl("KHCFOVUI")
		control:ClearAnchors()
		control:SetAnchor(TOPLEFT, FOVWnd, TOPLEFT, 0, - GuiRoot:GetHeight())
		FOVWnd:SetHidden(false)
		control.animPut:PlayFromStart()
	end
end
function KHCFOV:Remove()
--d("--Remove")
	if isFirst then
		KHCFOVUI.animRemove:PlayFromStart()
		zo_callLater(function()
			FOVWnd:SetHidden(true)
			KHCFOVUI:ClearAnchors()
			KHCFOVUI:SetAnchor(TOPLEFT, FOVWnd, TOPLEFT, 0, 0)
		end, 2000)
	end
end
function KHCFOV:CheckFov(isZoomOut)
	if KHC ~= nil then
		local distance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
--		if isZoomOut and distance == "2.00000000" then distance = "2.50000000" end
--		isFirst = tonumber(distance) <= 2
--		d("CheckFov("..tostring(thirdPersonZoom).."):"..tostring(isFirst)..","..tostring(KHC:IsHelmet()))
--		d("distance="..tostring(distance)..";"..tonumber(distance))
		if not(isFirst) or IsInteractionCameraActive() or (IsMounted() and (not KHCFOV.activeAddon.ImmersiveHorseRiding or tonumber(distance) >= 2)) then
			FOVWnd:SetHidden(true)
		elseif isFirst and KHC:IsHelmet() then
			if tonumber(distance) < 2 then 
				thirdPersonZoom = "2.00000000"
				SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, "0.00000000")
			end
			FOVWnd:SetHidden(false)
		end
	end
end

local origToggleGameCameraFirstPerson = ToggleGameCameraFirstPerson
ToggleGameCameraFirstPerson = function(...)
--d("ToggleGameCameraFirstPerson: "..GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
	local distance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
--	d(tonumber(distance),isFirst)
--	origToggleGameCameraFirstPerson (...)
	if isFirst and tonumber(distance) <= 2 then --mousewheel used or ImmersiveHorseRiding
		distance = "2.50000000"
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, distance)
	else
		origToggleGameCameraFirstPerson (...)
	end
--	thirdPersonZoom = tostring(distance)
	if IsMounted() and not KHCFOV.activeAddon.ImmersiveHorseRiding then --toggle when mounted force 3rd person view
		isFirst = false
	else
		isFirst = not(isFirst)
	end
	KHCFOV:CheckFov()
--	d(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE))
--	if tonumber(GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)) > 2 then
--		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, "0.00000000") --"2.00000000")
--		KHCFOV:CheckFov()
--	else
--		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, thirdPersonZoom) --"4.00000000")
--		KHCFOV:CheckFov(true)
--	end
end
local origCameraZoomIn = CameraZoomIn
CameraZoomIn = function(...)
--d("CameraZoomIn")
	local distance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
	origCameraZoomIn (...)
	if distance <= "2.00000000" and (not IsMounted() or (IsMounted() and KHCFOV.activeAddon.ImmersiveHorseRiding)) then 
		isFirst = true
--		thirdPersonZoom = "2.00000000"
		SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, "0.00000000")
	end
	KHCFOV:CheckFov()
end
local origCameraZoomOut = CameraZoomOut
CameraZoomOut = function(...)
--d("CameraZoomOut")
	origCameraZoomOut (...)
	local distance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
--	thirdPersonZoom = tostring(distance)
	if distance >= "2.00000000" then
		isFirst = false
	end
	KHCFOV:CheckFov()
end

-- Setting UI
function KHCFOV:IsSetting(panel)
	if panel == nil then panel = GetControl("KHCFOVSettings") end
	return not panel:IsControlHidden()
end
function KHCFOV:RefreshSettingUI(panel)
	if panel == nil then panel = GetControl("KHCFOVSettings") end
	if KHCFOV:IsSetting(panel) then 
		-- get equipped helm icon
	--	GetEquippedItemInfo(*integer* _equipSlot_)
	-- _Returns:_ *string* _icon_, *bool* _slotHasItem_, *integer* _sellPrice_, *bool* _isHeldSlot_, *bool* _isHeldNow_, *bool* _locked_
		local icon, slotHasItem, sellPrice, isHeldSlot, isHeldNow, locked = GetEquippedItemInfo(EQUIP_SLOT_HEAD)
		if slotHasItem then
			selectedIcon = icon
			panel.icon:SetTexture(icon)
			-- show Helms
			showHelm()
		else --no helm -> end
			CleanUI(panel.helms)
			selectedIcon = nil
			panel.icon:SetTexture(TEXTURE_HEAD)
			CHAT_SYSTEM:AddMessage("|c"..COLOR_KHRILLSELECT.."["..KHC.name.."]|r : FOV addin -> |cFF0000No "..KHC.langString.KHCSettings_title0.."|r")
		end
	end
end

function KHCFOV:OnSettingOpen()
	-- icon select
	local panel = GetControl("KHCFOVSettings")
	if panel == nil then return end --error
	if panel:IsControlHidden() then
		ZO_CharacterWindowStats:SetHidden(true)
		panel:ClearAnchors()
		panel:SetAnchor(TOPLEFT, ZO_CharacterEquipmentSlotsHeadFOV, TOPRIGHT, 50, -25)
		panel:SetHidden(false)
		KHCFOV:RefreshSettingUI(panel)
		-- show BG texture for preview
		FOVWnd:SetHidden(false)
		ZO_CharacterEquipmentSlotsHeadFOV:GetNamedChild("Texture"):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
	else
		KHCFOV:OnSettingClose()
		ZO_CharacterWindowStats:SetHidden(false)
	end
end
function KHCFOV:OnSettingClose()
	FOVWnd:SetHidden(true)
	GetControl("KHCFOVSettings"):SetHidden(true)
	ZO_CharacterEquipmentSlotsHeadFOV:GetNamedChild("Texture"):SetColor(HexToRGBA(COLOR_BG))
end

function KHCFOV:OnSettingParam()
	-- open/close param window to change texturecoord (zoom)
	local panel = GetControl("KHCFOVSettingsParam")
	if panel == nil then panel = initParam() end

	local button = GetControl("KHCFOVSettingsParamBtn")
	if isButtonItemSelected(button) then
		-- deselect
		button:GetNamedChild("Texture"):SetColor(HexToRGBA(button.color)) 
		panel:SetHidden(true)
	else --select
		button:GetNamedChild("Texture"):SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		-- update slider values
		local zoom = KHCFOV.settings.Zoom
		if selectedHelm ~= nil and textureZoom[selectedHelm.texture] ~= nil then zoom = textureZoom[selectedHelm.texture] end
		updateParam(zoom)
		panel:SetHidden(false)
	end
end
function KHCFOV:OnParamChange()
	-- slider for texturecoord
	local panel = GetControl("KHCFOVSettingsParam")
	if panel == nil then return end --error
--d(panel.leftSlider.selText:GetText()..","..panel.rightSlider.selText:GetText()..","..panel.topSlider.selText:GetText()..","..panel.bottomSlider.selText:GetText())
	local zoom = {panel.leftSlider.selText:GetText()/100,panel.rightSlider.selText:GetText()/100,panel.topSlider.selText:GetText()/100,panel.bottomSlider.selText:GetText()/100}
	if selectedHelm ~= nil then --save for specific helm
		selectedHelm.zoom = zoom
		KHCFOV.accountSettings[selectedIcon] = {}
		KHCFOV.accountSettings[selectedIcon] = selectedHelm
	else -- or global
		KHCFOV.settings.Zoom = zoom
	end
	KHCFOVUI:SetTextureCoords(zoom[1],zoom[2],zoom[3],zoom[4])	
end
function KHCFOV:OnOpacityChange()
	-- slider for opacity
	local panel = GetControl("KHCFOVSettingsParamOpacity")
	if panel == nil then return end --error
	local value = panel.slider.selText:GetText()/100
	KHCFOV.settings.opacity = value
	KHCFOVUI:SetAlpha(value)
end

function KHCFOV:OnFilterSelect(styleIndex,itemStyle)
--d("OnFilterSelect "..styleIndex..","..itemStyle.."="..GetString("SI_ITEMSTYLE", itemStyle))
	local button = GetControl("KHCFOVSettingsFilters"..itemStyle)
	local control = button:GetNamedChild("Texture")
	if isButtonItemSelected(button) then
		--deselect
		control:SetColor(HexToRGBA(control.color)) 
		button:GetNamedChild("Outline"):SetHidden(true)
		styleFilter[tonumber(itemStyle)] = nil
	else --select
		control:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		button:GetNamedChild("Outline"):SetHidden(false)
		styleFilter[tonumber(itemStyle)] = true
	end
	
	local panel = GetControl("KHCFOVSettings")
	local icon, slotHasItem, _, _, _, _ = GetEquippedItemInfo(EQUIP_SLOT_HEAD)
	if slotHasItem then -- helm equipped
		selectedIcon = icon
		panel.icon:SetTexture(icon)
		-- filter it
		showHelm()
	else
		CleanUI(panel.helms)
		selectedIcon = nil
		panel.icon:SetTexture(TEXTURE_HEAD)
	end
end

function KHCFOV:OnHelmSelect(index,itemStyle,texture, nochange)
--d("OnHelmSelect "..tostring(index)..","..itemStyle..","..texture)
	if nochange == nil then nochange = false end
	local button = GetControl("KHCFOVSettingsHelms"..index)
	local control = button:GetNamedChild("Texture")
	local zoom = KHCFOV.settings.Zoom
	if isButtonItemSelected(button) then
		--deselect
		control:SetColor(HexToRGBA(control.color)) 
		button:GetNamedChild("Outline"):SetHidden(true)
		KHCFOV.accountSettings[selectedIcon] = {}
		updateParam(zoom)
	else --select
		control:SetColor(HexToRGBA(COLOR_KHRILLSELECT))
		button:GetNamedChild("Outline"):SetHidden(false)
		-- deselect other items
		local controlList = GetControl("KHCFOVSettingsHelms")
		for i=1,controlList:GetNumChildren() do
			local itemControl = controlList:GetChild(i)
			if itemControl:GetName() ~= "KHCFOVSettingsHelms"..index and string.find(itemControl:GetName(), "BG") == nil and string.find(itemControl:GetName(), "Label") == nil and string.find(itemControl:GetName(), "Slider") == nil then
				itemControl:GetNamedChild("Texture"):SetColor(HexToRGBA(itemControl.color)) 
				itemControl:GetNamedChild("Outline"):SetHidden(true)
				itemControl.isColorInitiated = false
			end
		end
		if textureZoom[texture] ~= nil then zoom = textureZoom[texture] end
		updateParam(zoom)
		if not nochange then
			-- change bg
			selectedHelm = {texture = texture,	itemStyle = itemStyle, listIndex = index, zoom = zoom}
			KHCFOVUI:SetTexture(texturePath..texture)
			KHCFOVUI:SetTextureCoords(zoom[1],zoom[2],zoom[3],zoom[4])
			-- save it
			KHCFOV.accountSettings[selectedIcon] = selectedHelm		
		end
	end
end

function KHCFOV:OnSliderMove(value)
--d("--OnSliderMove:"..value)
	HelmsSliderOffset = value
	updateHelms()
end

function KHCFOV:OnMouseWheel(delta)
--d("--OnMouseWheel:"..delta)
	local offset = HelmsSliderOffset
	offset = offset - delta
	local nbRow = math.ceil(HelmsTotal/HelmsMaxCol) 
	if (offset > nbRow-HelmsMaxRow+1) then offset = nbRow-HelmsMaxRow+1 end
	if (offset < 1) then offset = 1 end
	
	HelmsSliderOffset = offset
	KHCFOVSettingsHelmsSlider:SetValue(offset)
	updateHelms()
end

-- TEXTURES PACK
----------------
function KHCFOV:AddPackage(packageName, addinList, zoom)
	-- external link for adding package texture
--	addinList = {
--		[ITEMSTYLE_RACIAL_ARGONIAN] = {"texture1.dds", "texture2.dds" , ...}
--		[ItemStyle] = {filename, ...}
	if KHC == nil or type(addinList)~='table' then
		return nil
	end
	if zoom == nil then zoom = KHCFOV.defaults.Zoom end
	
	--add <package name>/ directory to filename
	local temp = {}
	local zoomList = {}
	for styleIndex, texturePack in pairs(addinList) do
		temp[styleIndex] = {}
		for i, texturefile in pairs(texturePack) do
			local filename = packageName.."/"..texturefile
			temp[styleIndex][i] = filename
			zoomList[filename] = zoom
		end
	end
	--add to collection
	TableCopy(temp, textureList)
	TableCopy(zoomList, textureZoom)

	if KHC.settings.LogInfo then
		local msg = "|c"..COLOR_KHRILLSELECT.."["..KHC.name.."]|r : FOV package |cFFFFFF"..packageName.."|r OK"
		CHAT_SYSTEM:AddMessage(msg)
	end
end


--    INIT    --
----------------
local function checkVersion()
	-- check settings version & update if needed
	if KHCFOV.settings.settingsVersion == nil then KHCFOV.settings.settingsVersion = 1 end
	local msg = "|c"..COLOR_KHRILLSELECT.."["..KHC.name.."]|r : FOV addin " ..GetString(SI_GAME_MENU_SETTINGS).." v"..KHCFOV.settings.settingsVersion.." => |c00FF00v"
	if KHCFOV.settings.settingsVersion == 1 then --v1.0.0 to 1.0.4
		-- 1.0.5 : change default Zoom values
		KHCFOV.settings.Zoom = KHCFOV.defaults.Zoom
		KHCFOV.settings.settingsVersion = 105
		msg = msg .. KHCFOV.settings.settingsVersion.."|r"
		--CHAT_SYSTEM:AddMessage(msg)
	end
end

local function OnActivate()
	-- link with KHC
	if KHC ~= nil then
		KHC.Addins.FOV = true
		if KHC.settings.LogInfo == nil then KHC.settings.LogInfo = true end
		if KHC.settings.LogInfo then
			local msg = "|c"..COLOR_KHRILLSELECT.."["..KHC.name.."]|r : FOV addin |c00FF00"..KHC.langString.KHCSettings_enable.."|r"
			CHAT_SYSTEM:AddMessage(msg)
		end
		--check version/update
		checkVersion()

		-- button for fov settings in inventory
		local button = addButton(ZO_CharacterEquipmentSlotsHead, "ZO_CharacterEquipmentSlotsHeadFOV", function(...) KHCFOV:OnSettingOpen()	end, nil, nil, " |c"..COLOR_KHRILLSELECT.."Helmet FOV|r\n(click to change)", RIGHT, TEXTURE_ICONINVENTORY, nil, nil, COLOR_BG, 48, 48, 15, 0, LEFT, ZO_CharacterEquipmentSlotsHead, RIGHT, hidden, true)
		button:GetNamedChild("Outline"):SetHidden(false)
		-- helmet icon & fov texture
		local icon, slotHasItem, sellPrice, isHeldSlot, isHeldNow, locked = GetEquippedItemInfo(EQUIP_SLOT_HEAD)
		local helmArmorType = GetItemArmorType(BAG_WORN, EQUIP_SLOT_HEAD)
		if slotHasItem and KHCFOV.accountSettings[icon] ~= nil then
			selectedIcon = icon
			selectedHelm = KHCFOV.accountSettings[icon]
			-- check for saved helms before 1.0.5
			if selectedHelm.zoom == nil then
				if textureZoom[selectedHelm.texture] ~= nil then
					selectedHelm.zoom = textureZoom[selectedHelm.texture]
				else
					selectedHelm.zoom = KHCFOV.settings.Zoom
				end
				KHCFOV.accountSettings[icon] = selectedHelm
			end
		else
			selectedHelm = {texture = TEXTURES[helmArmorType],	itemStyle = ITEMSTYLE_NONE, listIndex = nil, zoom = KHCFOV.settings.Zoom}
		end
		KHCFOVUI:SetTexture(texturePath..selectedHelm.texture)
		KHCFOVUI:SetTextureCoords(selectedHelm.zoom[1],selectedHelm.zoom[2],selectedHelm.zoom[3],selectedHelm.zoom[4])
		KHCFOVUI:SetAlpha(KHCFOV.settings.opacity)
		KHCFOVUI:SetHidden(false)
		-- force 1st view to 0
		local distance = GetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE)
		isFirst = tonumber(distance) <= 2
		if isFirst then SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, "0.00000000") end
		KHCFOV:CheckFov()

		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_PLAYER_DEACTIVATED, function(...) if isFirst then SetSetting(SETTING_TYPE_CAMERA, CAMERA_SETTING_DISTANCE, "2.00000000") end end)

		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_GAME_CAMERA_DEACTIVATED, function(...) OnCameraDeactivated() end)
		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_GAME_CAMERA_ACTIVATED, function(...) KHCFOV:CheckFov() end)

		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_RETICLE_HIDDEN_UPDATE, function(eventCode, hidden)
												if hidden then
													FOVWnd:SetHidden(hidden)
												else
													KHCFOV:CheckFov()
												end
		end)
		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_MOUNTED_STATE_CHANGED, function(...) KHCFOV:CheckFov() end)
		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_SCREEN_RESIZED, function(...) onScreenResized(...) end)

--		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_PLAYER_NOT_SWIMMING, function(...) d("EVENT_PLAYER_NOT_SWIMMING") end)
--		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_PLAYER_SWIMMING, function(...) d("EVENT_PLAYER_SWIMMING") end)
			 
--		ZO_PlayerInventory:SetHandler("OnEffectivelyShown", KHCFOV_OnInventoryShow)
--		ZO_PlayerInventory:SetHandler("OnEffectivelyHidden", KHCFOV_OnInventoryHide)
--		ZO_PreHookHandler(ZO_PlayerInventory, "OnEffectivelyShown", KHCFOV_OnInventoryShow)
		ZO_PreHookHandler(ZO_PlayerInventory, "OnEffectivelyHidden", KHCFOV_OnInventoryHide)
		EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_INVENTORY_SINGLE_SLOT_UPDATE, function(...) OnInventoryUpdate(...) end)
	end
	
	EVENT_MANAGER:UnregisterForEvent(KHCFOV.name, EVENT_ADD_ON_LOADED)
	EVENT_MANAGER:UnregisterForEvent(KHCFOV.name, EVENT_PLAYER_ACTIVATED)
end
local function OnInit(eventCode, addonName)
	-- check addons compatibility is active?
	if (addonName == "ImmersiveHorseRiding") then KHCFOV.activeAddon.ImmersiveHorseRiding = true end

	if addonName ~= KHCFOV.name then return end
    
	langString = stringLocal[KHC:GetLanguage()]
	-- saved variables
	KHCFOV.settings = ZO_SavedVars:New(KHCFOV.name .. "_settings", 1, nil, KHCFOV.defaults)
	KHCFOV.accountSettings = ZO_SavedVars:NewAccountWide(KHCFOV.name .. "_settings", 1, nil, KHCFOV.accountDefaults)

	-- Init UI
	FOVWnd = WINDOW_MANAGER:CreateTopLevelWindow()
	FOVWnd:SetAnchorFill(GuiRoot)
	FOVWnd:SetDrawLayer(DL_BACKGROUND)
	FOVWnd:SetMouseEnabled(false)
	-- anim control
	local control = WINDOW_MANAGER:CreateControl("KHCFOVUI", FOVWnd, CT_TEXTURE)
	local width = GuiRoot:GetWidth() 
	local height = GuiRoot:GetHeight()
	control:SetDimensions(width, height)
	control:SetTexture(texturePath..TEXTURES[ARMORTYPE_NONE])
	control:SetAnchor(TOPLEFT, FOVWnd, TOPLEFT, 0, 0)
	-- Animation = slide down
	local timelinePut = ANIMATION_MANAGER:CreateTimeline()
	local translate = timelinePut:InsertAnimation(ANIMATION_TRANSLATE, control, 500)
	translate:SetTranslateOffsets(0, -GuiRoot:GetHeight(), 0, 0)
	translate:SetDuration(500)
	translate:SetEasingFunction(ZO_EaseInQuadratic)
	control.animPut = timelinePut
	local timelineRemove = ANIMATION_MANAGER:CreateTimeline()
	local translate = timelineRemove:InsertAnimation(ANIMATION_TRANSLATE, control, 500)
	translate:SetTranslateOffsets(0, 0, 0, -GuiRoot:GetHeight())
	translate:SetDuration(500)
	translate:SetEasingFunction(ZO_EaseInQuadratic)
	control.animRemove = timelineRemove
	control:SetHidden(false)
	FOVWnd:SetHidden(true)

	-- Textures and setting UI
	textureList = {}
	styleFilter = {}
	initSetting()
	
	EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_PLAYER_ACTIVATED, OnActivate)
end

EVENT_MANAGER:RegisterForEvent(KHCFOV.name, EVENT_ADD_ON_LOADED, function(_event, _name) OnInit(_event, _name) end)