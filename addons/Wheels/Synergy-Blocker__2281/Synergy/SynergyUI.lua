synergy = synergy or {}
local syn = synergy

local EM = GetEventManager()
local WM = GetWindowManager()

function syn.setupUI()
	local sFrame = WM:CreateTopLevelWindow("SynergyNotiFrame")
	sFrame:SetClampedToScreen(true)
	sFrame:SetDimensions(500, 500)
	sFrame:ClearAnchors()
	sFrame:SetMouseEnabled(false)
	sFrame:SetMovable(false)
	sFrame:SetHidden(false)

	local sIcon = WM:CreateControl("SynergyNotiIcon", sFrame, CT_TEXTURE)
	sIcon:SetAnchor(TOPLEFT, ZO_SynergyTopLevelContainerIcon, TOPLEFT, 0, 0)
	sIcon:SetDimensions(50, 50)
	--sIcon:SetTexture("/esoui/art/icons/ability_necromancer_004.dds")

	local sIconFrame = WM:CreateControl("SynergyNotiIconFrame", sIcon, CT_TEXTURE)
	sIconFrame:SetAnchor(TOPLEFT, sIcon, TOPLEFT, 0, 0)
	sIconFrame:SetAnchor(BOTTOMRIGHT, sIcon, BOTTOMRIGHT, 0, 0)
	sIconFrame:SetDimensions(50, 50)
	sIconFrame:SetTexture("/esoui/art/actionbar/abilityframe64_up.dds")

	local sText = WM:CreateControl("SynergyNotiLabel", sFrame, CT_LABEL)
	sText:SetAnchor(LEFT, sIcon, RIGHT, 15, 0)
	sText:SetDimensions(0, 30)
	sText:SetColor(1, 1, 1, 1)
	sText:SetFont("ZoInteractionPrompt")
	sText:SetVerticalAlignment(TEXT_ALIGN_TOP)
	--sText:SetText("Boneyard Available")

	syn.alertFrame = sFrame
	syn.alertIcon = sIcon
	syn.alertText = sText
end
