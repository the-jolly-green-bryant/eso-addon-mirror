local lib = {}
LibGuardArrow = lib


--local PLAYER_UNIT_TAG = "player"
local ARROW1 = nil
local REFRESH_TIME = 40

--local targetUnitTag = "player"

local target1X = 0
local target1Y = 0


local showArrows = false -- if arrow is current visible


local function GetTexturePath()
	return "GuardHelper/icons/arrow1.dds"
end



function lib.CreateTexture()

	ARROW1 = WINDOW_MANAGER:CreateControl("LibGuardArrow1Texture", RETICLE.control, CT_TEXTURE)
	ARROW1:SetAnchor(CENTER, GuiRoot, CENTER, 0, 0)
	ARROW1:SetDrawLayer(1)
	ARROW1:SetDimensions(128, 128)
	ARROW1:SetAlpha(1)
	ARROW1:SetHidden(true)


end

function lib.ApplyStyle(texture, color, scale)
	ARROW1:SetTexture(texture)
    if color then
        ARROW1:SetColor(unpack(color))
    end
	if scale then
	    ARROW1:SetScale(scale)
	end
end

function lib.ApplyColor(color)
	if color then
	    ARROW1:SetColor(unpack(color))
	end
end

function lib.ApplyColorGreen()
    ARROW1:SetColor(unpack({0, 77/255.0, 8/255.0, 1} ))
end


function lib.ApplyColorBlue()
    ARROW1:SetColor(unpack({0, 17/255.0, 99/255.0, 1}))
end


function lib.ApplyColorRed()
    ARROW1:SetColor(unpack({99/255.0, 0, 0, 1}))
end


local function AngleRotation(angle)
	return angle - 2*math.pi * math.floor( (angle + math.pi) / 2*math.pi )
end

local function GetRotationAngle(playerX, playerY, targetX, targetY)
	return AngleRotation(-1*(AngleRotation(GetPlayerCameraHeading()) - math.atan2(playerX-targetX, playerY-targetY)))
end

function lib.SetTarget1XY(xx,yy)
	target1X=xx
	target1Y=yy
end



function lib.ShowArrow()

	if showArrows==false then
		showArrows = true

		ARROW1:SetHidden(false)

		EVENT_MANAGER:UnregisterForUpdate("LibGuardArrowUpdate")
		EVENT_MANAGER:RegisterForUpdate(
			"LibGuardArrowUpdate",
			REFRESH_TIME,
			function()


				local zone, playerX, wY, playerY = GetUnitRawWorldPosition( "player" )

				if target1X== 0 or target1Y == 0 then
				else
				    --d("rotating arrow1")
				    ARROW1:SetTextureRotation(GetRotationAngle(playerX, playerY, target1X, target1Y))
				end

			end
		)
	end


end

function lib.HideArrow()
	if showArrows==true then
	    --d("hidding arrow")
		showArrows = false
		EVENT_MANAGER:UnregisterForUpdate("LibGuardArrowUpdate")
		ARROW1:SetHidden(true)
	end
end
