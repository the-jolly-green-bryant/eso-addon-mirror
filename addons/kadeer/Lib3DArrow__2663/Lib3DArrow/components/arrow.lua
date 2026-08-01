L3DA = {}

local function AngleToRadians(angle)
  return angle * math.pi / 180
end

function L3DA:UpdateArrow(parent, data, pData)
  -- 1: Arrow
  -- rotate arrow to be horizontal and angle it to point at target
  local angleRadians = math.atan2(pData.playerY-data.targetY, data.targetX-pData.playerX)
  parent.arrow:Set3DRenderSpaceOrientation(AngleToRadians(90) , angleRadians, 0)

  -- use players world position to place the arrow in a circle around the player
  -- direction of arrow + 90 degree offset to place it correctly
  local circ = angleRadians + (90 * math.pi / 180)
  parent.arrow:Set3DRenderSpaceOrigin(pData.worldX + (data.arrowMagnitude * math.sin(circ)), pData.worldY + data.arrowHeight, pData.worldZ + (data.arrowMagnitude * math.cos(circ)))

  -- glowing animation
  local time = GetFrameTimeSeconds()
  parent.arrow.glow:SetAlpha(1 - math.sin(time))
end

function L3DA:CreateArrow(parent, data)
  -- arrow settings or use defaults
  data.arrowMagnitude = data.arrowMagnitude or 5
  data.arrowScale = data.arrowScale or 2
  data.arrowHeight = data.arrowHeight or 1.5
  data.arrowColour = data.arrowColour or "3F9092"
  data.arrowHeight = data.arrowHeight + (parent.uniqueId * 0.005)

  -- Arrow
  parent.arrow = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
  local arrow = parent.arrow
  arrow:Create3DRenderSpace()

  arrow.glow = WINDOW_MANAGER:CreateControl(nil, arrow, CT_TEXTURE)
  local glow = arrow.glow
  glow:SetTexture("Lib3DArrow/art/glow.dds")
  glow:Create3DRenderSpace()
  glow:Set3DLocalDimensions(data.arrowScale, data.arrowScale)
  glow:Set3DRenderSpaceUsesDepthBuffer(data.depthBuffer)
  glow:Set3DRenderSpaceOrigin(0,0,0)

  arrow.chevron = WINDOW_MANAGER:CreateControl(nil, arrow, CT_TEXTURE)
  local chevron = arrow.chevron
  chevron:Create3DRenderSpace()
  local c = ZO_ColorDef:New(data.arrowColour)
  chevron:SetColor(c.r, c.g, c.b, c.a)
  chevron:SetTexture("Lib3DArrow/art/arrow.dds")
  chevron:Set3DLocalDimensions(data.arrowScale, data.arrowScale)
  chevron:Set3DRenderSpaceUsesDepthBuffer(data.depthBuffer)
  chevron:Set3DRenderSpaceOrigin(0,0,0)
end