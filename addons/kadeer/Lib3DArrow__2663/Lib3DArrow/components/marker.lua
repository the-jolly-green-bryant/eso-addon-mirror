L3DA = L3DA or {}

function L3DA:UpdateMarker(parent, data, pData)
  -- always facing the camera ish
  parent.marker:Set3DRenderSpaceForward(pData.forwardX, pData.forwardY, pData.forwardZ)
  parent.marker:Set3DRenderSpaceRight(pData.rightX, pData.rightY, pData.rightZ)
  parent.marker:Set3DRenderSpaceUp(0, pData.upY, 0)

  -- using metres + angle to work out how far away and which direction the marker is
  -- prolly useful for hiding based on distance
  local circ = math.atan2(pData.playerY-data.targetY, data.targetX-pData.playerX) + (90 * math.pi / 180)
  parent.marker:Set3DRenderSpaceOrigin(pData.worldX + (data.metres * math.sin(circ)), pData.worldY, pData.worldZ + (data.metres * math.cos(circ)))
end

local MARKER_TYPE =
{
  ["pillar"] = {
    texture = "Lib3DArrow/art/pillar.dds",
    scaleY = 200,
  },
  ["crown"] = {
    texture = "Lib3DArrow/art/pillar.dds",
  },
  ["tank"] = {
    texture = "Lib3DArrow/art/pillar.dds",
  },
  ["dd"] = {
    texture = "Lib3DArrow/art/pillar.dds",
  },
  ["healer"] = {
    texture = "Lib3DArrow/art/pillar.dds",
  },
}


function L3DA:CreateMarker(parent, data)
  -- marker settings/defaults
  data.markerColour = data.markerColour or "3F9092"
  data.markerScale = data.markerScale or 1
  data.markerType = data.markerType or "pillar"
  data.markerType = string.lower(data.markerType)

  parent.marker = WINDOW_MANAGER:CreateControl(nil, parent, CT_CONTROL)
  local marker = parent.marker
  marker:Create3DRenderSpace()

  marker.pillar = WINDOW_MANAGER:CreateControl(nil, marker, CT_TEXTURE)
  local pillar = marker.pillar
  pillar:Create3DRenderSpace()
  local c = ZO_ColorDef:New(data.markerColour)
  pillar:SetColor(c.r, c.g, c.b, c.a)
  pillar:SetAlpha(0.5)
  pillar:Set3DRenderSpaceUsesDepthBuffer(true)
  pillar:Set3DRenderSpaceOrigin(0,0,0)

  local m = MARKER_TYPE[data.markerType]
  pillar:SetTexture(m.texture)
  pillar:Set3DLocalDimensions(m.scaleX or data.markerScale, m.scaleY or data.markerScale)
end
