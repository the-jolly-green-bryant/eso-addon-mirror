PotionBlocker = PotionBlocker or {}
local pot = PotionBlocker

local EM = GetEventManager()
local WM = GetWindowManager()

function pot.setupUI()
	local sFrame = WM:CreateTopLevelWindow("PotionBlockerNotiFrame")
	sFrame:SetClampedToScreen(false)
	sFrame:SetDimensions(500, 500)
	sFrame:ClearAnchors()
	sFrame:SetMouseEnabled(false)
	sFrame:SetMovable(false)
	sFrame:SetHidden(false)
end
