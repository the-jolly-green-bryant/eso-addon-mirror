local LMP = RAEIH.LMP
local uTag = "player"

function RAEIH.CreateLUAMemory()
	local WM = GetWindowManager()
	if RAEIH_LUAMemory == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.LUAMemoryX
		local mY = RAEIH.SavedVars.LUAMemoryY
		local mW = RAEIH.SavedVars.LUAMemoryIconW + 10
		local mH = RAEIH.SavedVars.LUAMemoryIconH
		local iX = RAEIH.SavedVars.LUAMemoryIconX
		local iY = RAEIH.SavedVars.LUAMemoryIconY
		local iW = RAEIH.SavedVars.LUAMemoryIconW
		local iH = RAEIH.SavedVars.LUAMemoryIconH
		local bA = RAEIH.SavedVars.LUAMemoryBA
		-- Main Placeholder
		RAEIH_LUAMemory = WM:CreateTopLevelWindow("RAEIH_LUAMemory")
		RAEIH_LUAMemory:SetClampedToScreen(true)
		RAEIH_LUAMemory:SetDrawLevel(1)
		RAEIH_LUAMemory:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_LUAMemory:SetMouseEnabled(true)
		RAEIH_LUAMemory:SetMovable(not RAEIH.SavedVars.LockLUAMemory)
		RAEIH_LUAMemory:SetHandler("OnReceiveDrag", RAEIH.StartMovingLUAMemory)
		RAEIH_LUAMemory:SetHandler("OnMouseUp", RAEIH.StopMovingLUAMemory)
		RAEIH_LUAMemory:SetHidden(not RAEIH.SavedVars.ShowLUAMemory)
		-- Icon
		RAEIH_LUAMemory_Icon = WM:CreateControl("RAEIH_LUAMemory_Icon", RAEIH_LUAMemory, CT_TEXTURE)
		RAEIH_LUAMemory_Icon:SetTexture(RAEIH.Icons.LUAMemory)
		RAEIH_LUAMemory_Icon:SetDimensions(iW, iH)
		RAEIH_LUAMemory_Icon:SetSimpleAnchor(RAEIH_LUAMemory, iX, iY)
		-- String
		RAEIH_LUAMemory_String = WM:CreateControl("RAEIH_LUAMemory_String", RAEIH_LUAMemory, CT_LABEL)
		RAEIH_LUAMemory_String:SetSimpleAnchor(RAEIH_LUAMemory, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_LUAMemory_String:SetHorizontalAlignment(CENTER)
		RAEIH_LUAMemory_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_LUAMemory_Backdrop = WM:CreateControl("RAEIH_LUAMemory_Backdrop", RAEIH_LUAMemory, CT_BACKDROP)
		RAEIH_LUAMemory_Backdrop:SetAnchorFill(RAEIH_LUAMemory)
		RAEIH_LUAMemory_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_LUAMemory_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetLUAMemory()

	local clrDft = "|c" .. RAEIH.SavedVars.LUAMemoryDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.LUAMemoryAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.LUAMemoryWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.LUAMemoryNormalColour

	local lualimit = tonumber(GetCVar("LuaMemoryLimitMB"))
	local luamem = collectgarbage("count")/1024
	if lualimit == nil then lualimit = 0 end

	if luamem > lualimit then
		clr = clrA
	elseif luamem <= lualimit and luamem > lualimit/2 then
		clr = clrW
	else
		clr = clrN
	end

	-- if RAEIH.SavedVars.TSFormat == "Point (.)" then
		-- RAEIH.LUAMemoryText = clr .. string.gsub(tostring(luamem), "%.", ",")
	-- else
	RAEIH.LUAMemoryText = clr .. tostring(RAEIH.Round(luamem)) .. "mb"
	-- end
	if lualimit == 0 then
		RAEIH.LUAMemoryText = RAEIH.LUAMemoryText .. " (limit undefined)"
	end
	RAEIH_LUAMemory_String:SetText(RAEIH.LUAMemoryText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatLUAMemory()

	local font = LMP:Fetch('font', RAEIH.SavedVars.LUAMemoryFont)
	local size = RAEIH.SavedVars.LUAMemoryFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.LUAMemoryFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_LUAMemory_String:SetFont(fontFormat)

end

function RAEIH.OrganizeLUAMemory()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.LUAMemoryX
	local mY = RAEIH.SavedVars.LUAMemoryY
	local mW = RAEIH.SavedVars.LUAMemoryIconW + RAEIH_LUAMemory_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.LUAMemoryIconH
	local iX = RAEIH.SavedVars.LUAMemoryIconX
	local iY = RAEIH.SavedVars.LUAMemoryIconY
	local iW = RAEIH.SavedVars.LUAMemoryIconW
	local iH = RAEIH.SavedVars.LUAMemoryIconH
	local bA = RAEIH.SavedVars.LUAMemoryBA
	-- Update General Dimensions
	RAEIH_LUAMemory:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_LUAMemory_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_LUAMemory_Icon:ClearAnchors()
	RAEIH_LUAMemory_Icon:SetSimpleAnchor(RAEIH_LUAMemory, iX, iY)
	-- Update String Anchor
	RAEIH_LUAMemory_String:ClearAnchors()
	RAEIH_LUAMemory_String:SetSimpleAnchor(RAEIH_LUAMemory, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_LUAMemory_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingLUAMemory()
	RAEIH_LUAMemory:StartMoving()
end

function RAEIH.StopMovingLUAMemory()
	RAEIH_LUAMemory:StopMovingOrResizing()
	RAEIH.SavedVars.LUAMemoryX = RAEIH_LUAMemory:GetLeft()
	RAEIH.SavedVars.LUAMemoryY = RAEIH_LUAMemory:GetTop()
end