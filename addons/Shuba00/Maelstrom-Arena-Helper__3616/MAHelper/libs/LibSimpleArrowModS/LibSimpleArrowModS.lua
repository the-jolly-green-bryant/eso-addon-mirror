local libModS = {}
LibSimpleArrowModS = libModS

-- Position Indicator
local PLAYER_UNIT_TAG = "player"
local ARROWS = {}
local FreeArrow = {}
local REFRESH_TIME = 40
--ARROW1, ARROW2,ARROW3,ARROW4,ARROW5,ARROW6,
local targetUnitTag = "player"

local targetX = 0
local targetY = 0

-- Functions

local function GetTexturePath()
	return CRHelper.name.."/texture/arrow1.dds"
end

function libModS.GetTargetUnitTag()
	return targetUnitTag
end

function libModS.SetTargetUnitTag(tag)
	targetUnitTag = tag
end

function libModS.CreateTexture()
	for i = 1, 10, 1 do
		FreeArrow[i] = true
		ARROWS[i] = WINDOW_MANAGER:CreateControl("LibSimpleArrowTextureModS" ..i, RETICLE.control, CT_TEXTURE)
		ARROWS[i]:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
		ARROWS[i]:SetDrawLayer(1)
		ARROWS[i]:SetDimensions(128, 128)
		ARROWS[i]:SetAlpha(1)
		ARROWS[i]:SetHidden(true)
	end 	
end

function libModS.SearchFreeArrow()
	for i = 1, 10,1 do
		if FreeArrow[i] then
			return i
		end
	end
	return 1
end

function libModS.ApplyStyle(texture, color, scale,id)

		ARROWS[id]:SetTexture(texture)
		if color then ARROWS[id]:SetColor(unpack(color)) end
		if scale then ARROWS[id]:SetScale(scale) end
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

function libModS.SetTarget(target)
	targetX, targetY = unpack(target)
end

function libModS.ShowArrow(targetX, targetY,id)
	FreeArrow[id] = false
	ARROWS[id]:SetHidden(false)
		EVENT_MANAGER:UnregisterForUpdate("LibSimpleArrowUpdateModS" ..id)
		EVENT_MANAGER:RegisterForUpdate(
			"LibSimpleArrowUpdateModS" ..id, 
			REFRESH_TIME, 
			function()
				local playerX, playerY = GetMapPlayerPosition(PLAYER_UNIT_TAG)
				ARROWS[id]:SetTextureRotation(GetRotationAngle(playerX, playerY, targetX, targetY))
			end
		)
end

function libModS.HideArrow(id)
	EVENT_MANAGER:UnregisterForUpdate("LibSimpleArrowUpdateModS" ..id)
	ARROWS[id]:SetHidden(true)
	FreeArrow[id] = true
end

