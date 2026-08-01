--[[

Target Focus
by CaptainBlagbird
https://github.com/CaptainBlagbird

--]]

-- Addon info
local AddOnName = "TargetFocus"

-- UI Settings
local UI_WIDTH  = 300
local UI_HEIGHT = 300
local UI_OFF_X  = 0
local UI_OFF_Y  = 0
local UI_HEIGHT = 300
local UI_ALPHA  = 0.9

-- Local variables
local lastTarget = ""
local preferredTarget = ""
local isPreferredTargetSet = false

-- UI
local PI = math.pi
local tlw = WINDOW_MANAGER:CreateTopLevelWindow("UI_TargetFocus")
tlw:SetHidden(true)
tlw:ClearAnchors()
tlw:SetAnchor(CENTER, GuiRoot, CENTER, UI_OFF_X, UI_OFF_Y)
tlw:SetDimensions(UI_WIDTH, UI_HEIGHT)
tlw:SetAlpha(UI_ALPHA)
local texTL = WINDOW_MANAGER:CreateControl("UI_TargetFocus_TextureTL", tlw, CT_TEXTURE)
texTL:ClearAnchors()
texTL:SetAnchor(TOPLEFT, tlw, TOPLEFT, 0, 0)
texTL:SetDimensions(16, 16)
texTL:SetTexture("/esoui/art/reticle/selected_topleft.dds")
texTL:SetTextureRotation(0)
local texTR = WINDOW_MANAGER:CreateControl("UI_TargetFocus_TextureTR", tlw, CT_TEXTURE)
texTR:ClearAnchors()
texTR:SetAnchor(TOPRIGHT, tlw, TOPRIGHT, 0, 0)
texTR:SetDimensions(16, 16)
texTR:SetTexture("/esoui/art/reticle/selected_topleft.dds")
texTR:SetTextureRotation(-PI/2)
local texBL = WINDOW_MANAGER:CreateControl("UI_TargetFocus_TextureBL", tlw, CT_TEXTURE)
texBL:ClearAnchors()
texBL:SetAnchor(BOTTOMLEFT, tlw, BOTTOMLEFT, 0, 0)
texBL:SetDimensions(16, 16)
texBL:SetTexture("/esoui/art/reticle/selected_topleft.dds")
texBL:SetTextureRotation(PI/2)
local texBR = WINDOW_MANAGER:CreateControl("UI_TargetFocus_TextureBR", tlw, CT_TEXTURE)
texBR:ClearAnchors()
texBR:SetAnchor(BOTTOMRIGHT, tlw, BOTTOMRIGHT, 0, 0)
texBR:SetDimensions(16, 16)
texBR:SetTexture("/esoui/art/reticle/selected_topleft.dds")
texBR:SetTextureRotation(PI)


-- Event handler function for EVENT_RETICLE_TARGET_CHANGED
local function OnReticleTargetChanged(eventCode)
    -- Preferred enemy target set?
    if IsGameCameraPreferredTargetValid() then
        -- Only the first time (unset --> set)
        if not isPreferredTargetSet then
            preferredTarget = lastTarget
        end
        isPreferredTargetSet = true
    else
        isPreferredTargetSet = false
        preferredTarget = ""
        UI_TargetFocus:SetHidden(true)
    end
    
    if IsUnitAttackable("reticleover") then
        -- Remember target
        lastTarget = GetUnitNameHighlightedByReticle()
        
        -- Compare target name
        if lastTarget == preferredTarget then
            UI_TargetFocus:SetHidden(false)
        else
            UI_TargetFocus:SetHidden(true)
        end
    else
        UI_TargetFocus:SetHidden(true)
    end
end
EVENT_MANAGER:RegisterForEvent(AddOnName, EVENT_RETICLE_TARGET_CHANGED, OnReticleTargetChanged)