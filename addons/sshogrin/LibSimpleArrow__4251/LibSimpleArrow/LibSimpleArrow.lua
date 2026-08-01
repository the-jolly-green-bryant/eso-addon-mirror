local lib = {}
LibSimpleArrow = lib

-- Position Indicator
local PLAYER_UNIT_TAG = "player"
local ARROW = nil
local REFRESH_TIME = 40

-- Target for arrow
-- Use lib.SetTargetUnitTag(tag) function to change it
local targetUnitTag = "player"

local targetX = 0
local targetY = 0

-- Functions

local function GetTexturePath()
	return CRHelper.name.."/texture/arrow1.dds"
end

function lib.GetTargetUnitTag()
	return targetUnitTag
end

function lib.SetTargetUnitTag(tag)
	targetUnitTag = tag
end

function lib.CreateTexture()
	--[[
	The texture is defined here. To enable/disable the arrow, while using another scene,
	the parent is "RETICLE.control" and will turn off when the reticle is not visible.
	]]
	ARROW = WINDOW_MANAGER:CreateControl("LibSimpleArrowTexture", RETICLE.control, CT_TEXTURE)
	ARROW:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	ARROW:SetDrawLayer(1)
	ARROW:SetDimensions(128, 128)
	ARROW:SetAlpha(1)
	ARROW:SetHidden(true)
end

function lib.ApplyStyle(texture, color, scale)
	ARROW:SetTexture(texture)
	if color then ARROW:SetColor(unpack(color)) end
	if scale then ARROW:SetScale(scale) end
end

local function GetDistancePlayerToPlayer(x1, y1, x2, y2)
	return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
end

local function AngleRotation(angle)
	return angle - 2*math.pi * math.floor( (angle + math.pi) / 2*math.pi )
end

local function GetRotationAngle(playerX, playerY, targetX, targetY)
	return AngleRotation(-1*(AngleRotation(GetPlayerCameraHeading()) - math.atan2(playerX-targetX, playerY-targetY)))
end

function lib.SetTarget(target)
	targetX, targetY = unpack(target)
end

function lib.ShowArrow()

	ARROW:SetHidden(false)
	EVENT_MANAGER:UnregisterForUpdate("LibSimpleArrowUpdate")
	EVENT_MANAGER:RegisterForUpdate(
        "LibSimpleArrowUpdate", 
        REFRESH_TIME, 
        function()
			local playerX, playerY = GetMapPlayerPosition(PLAYER_UNIT_TAG)
			--local targetX, targetY = GetMapPlayerPosition(targetUnitTag)
			ARROW:SetTextureRotation(GetRotationAngle(playerX, playerY, targetX, targetY))
        end
    )

end

function lib.HideArrow()
	EVENT_MANAGER:UnregisterForUpdate("LibSimpleArrowUpdate")
	ARROW:SetHidden(true)
end