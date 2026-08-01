local LMP = RAEIH.LMP
local uTag = "player"

-- P5ych3 - Updated vapirism ability IDs.
local vampirismStages = {
    [GetAbilityName(135397)] = 1, -- vampire stage 1
    [GetAbilityName(135399)] = 2, -- vampire stage 2
    [GetAbilityName(135400)] = 3, -- vampire stage 3
    [GetAbilityName(135402)] = 4, -- vampire stage 4
}

--P5ych3 - Old vampirism IDs were outdated, removed.
--local vampirismStages = {
--    [GetAbilityName(35771)] = 1,
--    [GetAbilityName(35773)] = 2,
--    [GetAbilityName(35780)] = 3,
--    [GetAbilityName(35786)] = 4,
--}

function RAEIH.CreateVampirism()
	local WM = GetWindowManager()
	if RAEIH_Vampirism == nil then
		-- Shorten Variables
		local mX = RAEIH.SavedVars.VampirismX
		local mY = RAEIH.SavedVars.VampirismY
		local mW = RAEIH.SavedVars.VampirismIconW + 10
		local mH = RAEIH.SavedVars.VampirismIconH
		local iX = RAEIH.SavedVars.VampirismIconX
		local iY = RAEIH.SavedVars.VampirismIconY
		local iW = RAEIH.SavedVars.VampirismIconW
		local iH = RAEIH.SavedVars.VampirismIconH
		local bA = RAEIH.SavedVars.VampirismBA
		-- Main Placeholder
		RAEIH_Vampirism = WM:CreateTopLevelWindow("RAEIH_Vampirism")
		RAEIH_Vampirism:SetClampedToScreen(true)
		RAEIH_Vampirism:SetDrawLevel(1)
		RAEIH_Vampirism:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, mX, mY)
		RAEIH_Vampirism:SetMouseEnabled(true)
		RAEIH_Vampirism:SetMovable(not RAEIH.SavedVars.LockVampirism)
		RAEIH_Vampirism:SetHandler("OnReceiveDrag", RAEIH.StartMovingVampirism)
		RAEIH_Vampirism:SetHandler("OnMouseUp", RAEIH.StopMovingVampirism)
		RAEIH_Vampirism:SetHidden(not RAEIH.SavedVars.ShowVampirism)
		-- Icon
		RAEIH_Vampirism_Icon = WM:CreateControl("RAEIH_Vampirism_Icon", RAEIH_Vampirism, CT_TEXTURE)
		RAEIH_Vampirism_Icon:SetTexture(RAEIH.Icons.Vampirism)
		RAEIH_Vampirism_Icon:SetDimensions(iW, iH)
		RAEIH_Vampirism_Icon:SetSimpleAnchor(RAEIH_Vampirism, iX, iY)
		-- String
		RAEIH_Vampirism_String = WM:CreateControl("RAEIH_Vampirism_String", RAEIH_Vampirism, CT_LABEL)
		RAEIH_Vampirism_String:SetSimpleAnchor(RAEIH_Vampirism, iW, RAEIH.IconStrPosAdjusting(iH))
		RAEIH_Vampirism_String:SetHorizontalAlignment(CENTER)
		RAEIH_Vampirism_String:SetVerticalAlignment(CENTER)
		-- Backdrop
		RAEIH_Vampirism_Backdrop = WM:CreateControl("RAEIH_Vampirism_Backdrop", RAEIH_Vampirism, CT_BACKDROP)
		RAEIH_Vampirism_Backdrop:SetAnchorFill(RAEIH_Vampirism)
		RAEIH_Vampirism_Backdrop:SetCenterColor(0, 0, 0, bA)
		RAEIH_Vampirism_Backdrop:SetEdgeColor(0, 0, 0, 0)
	end
end

function RAEIH.SetVampirism()

	local clrDft = "|c" .. RAEIH.SavedVars.VampirismDefaultColour
	local clrA = "|c" .. RAEIH.SavedVars.VampirismAlertColour
	local clrW = "|c" .. RAEIH.SavedVars.VampirismWarningColour
	local clrN = "|c" .. RAEIH.SavedVars.VampirismNormalColour

	local numBuffs = GetNumBuffs(uTag)
	RAEIH.VampirismText = clrW .. "No Vampirism"

	for i = 1, numBuffs do
		local bName, __, tEnding = GetUnitBuffInfo("player", i)

		if vampirismStages[bName] ~= nil then

			tEndingM = RAEIH.Round((tEnding - (GetGameTimeMilliseconds()/1000))/60)

			if vampirismStages[bName] == 4 then
				RAEIH.VampirismText = clrW .. "Stage 4" .. clrDft .. " Vampirism (" .. clrW .. tEndingM .. "m" .. clrDft .. ")" 
				--RAEIH.VampirismText = clrA .. "Stage 4" .. clrDft .. " Vampirism (" .. clrA .. "Feed!" .. clrDft .. ")" --P5ych3 - Vampirism no longer functions this way. Unnecessary prompt removed..
			elseif vampirismStages[bName] == 3 then
				RAEIH.VampirismText = clrW .. "Stage 3" .. clrDft .. " Vampirism (" .. clrW .. tEndingM .. "m" .. clrDft .. ")"
			elseif vampirismStages[bName] == 2 then
				RAEIH.VampirismText = clrW .. "Stage 2" .. clrDft .. " Vampirism (" .. clrW .. tEndingM .. "m" .. clrDft .. ")"
			elseif vampirismStages[bName] == 1 then
				RAEIH.VampirismText = clrN .. "Stage 1" .. clrDft .. " Vampirism (" .. clrN .. tEndingM .. "m" .. clrDft .. ")"
			end
		end
	end
	RAEIH_Vampirism_String:SetText(RAEIH.VampirismText)
	RAEIH.OrganizeLegatus()
end

function RAEIH.FormatVampirism()

	local font = LMP:Fetch('font', RAEIH.SavedVars.VampirismFont)
	local size = RAEIH.SavedVars.VampirismFontSize
	local style = RAEIH.FontStyles[RAEIH.SavedVars.VampirismFontStyle]

	local fontFormat = font .. "|" .. size .. "|" .. style

	RAEIH_Vampirism_String:SetFont(fontFormat)

end

function RAEIH.OrganizeVampirism()
	-- Shorten Variables
	local mX = RAEIH.SavedVars.VampirismX
	local mY = RAEIH.SavedVars.VampirismY
	local mW = RAEIH.SavedVars.VampirismIconW + RAEIH_Vampirism_String:GetTextWidth() + 10
	local mH = RAEIH.SavedVars.VampirismIconH
	local iX = RAEIH.SavedVars.VampirismIconX
	local iY = RAEIH.SavedVars.VampirismIconY
	local iW = RAEIH.SavedVars.VampirismIconW
	local iH = RAEIH.SavedVars.VampirismIconH
	local bA = RAEIH.SavedVars.VampirismBA
	-- Update General Dimensions
	RAEIH_Vampirism:SetDimensions(mW, mH)
	-- Update Icon Dimensions
	RAEIH_Vampirism_Icon:SetDimensions(iW, iH)
	-- Update Icon Anchor
	RAEIH_Vampirism_Icon:ClearAnchors()
	RAEIH_Vampirism_Icon:SetSimpleAnchor(RAEIH_Vampirism, iX, iY)
	-- Update String Anchor
	RAEIH_Vampirism_String:ClearAnchors()
	RAEIH_Vampirism_String:SetSimpleAnchor(RAEIH_Vampirism, iW, RAEIH.IconStrPosAdjusting(iH))
	-- Update Background Alpha
	RAEIH_Vampirism_Backdrop:SetCenterColor(0, 0, 0, bA)
end

function RAEIH.StartMovingVampirism()
	RAEIH_Vampirism:StartMoving()
end

function RAEIH.StopMovingVampirism()
	RAEIH_Vampirism:StopMovingOrResizing()
	RAEIH.SavedVars.VampirismX = RAEIH_Vampirism:GetLeft()
	RAEIH.SavedVars.VampirismY = RAEIH_Vampirism:GetTop()
end