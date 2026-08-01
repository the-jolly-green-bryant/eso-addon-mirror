VestigeMirror = VestigeMirror or {}
VestigeMirror.Preview = {}

function VestigeMirror.Preview:GetController()
    return ITEM_PREVIEW_KEYBOARD or ITEM_PREVIEW_GAMEPAD
end

function VestigeMirror.Preview:Initialize()
    self.active = false
end

function VestigeMirror.Preview:ShowAppearance(appearance)
    local controller = self:GetController()
    if not controller or not controller.PreviewOutfit or not controller.PreviewUnequipOutfit then
        return
    end

    if appearance.outfitIndex then
        controller:PreviewOutfit(appearance.actorCategory, appearance.outfitIndex)
    else
        controller:PreviewUnequipOutfit(appearance.actorCategory)
    end

    self.active = true
end

function VestigeMirror.Preview:Hide()
    if not self.active then
        return
    end

    local controller = self:GetController()
    if controller and controller.ResetOutfitPreview then
        controller:ResetOutfitPreview()
    end

    self.active = false
end
