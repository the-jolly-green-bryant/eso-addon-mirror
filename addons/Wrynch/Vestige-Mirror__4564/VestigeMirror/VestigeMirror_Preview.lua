VestigeMirror = VestigeMirror or {}
VestigeMirror.Preview = {}

function VestigeMirror.Preview:Initialize()
    self.active = false
end

function VestigeMirror.Preview:ShowAppearance(appearance)
    if not ITEM_PREVIEW_KEYBOARD then
        return
    end

    if appearance.isShared then
        self.active = false
        return
    elseif appearance.outfitIndex then
        ITEM_PREVIEW_KEYBOARD:PreviewOutfit(appearance.actorCategory, appearance.outfitIndex)
    else
        ITEM_PREVIEW_KEYBOARD:PreviewUnequipOutfit(appearance.actorCategory)
    end

    self.active = true
end

function VestigeMirror.Preview:Hide()
    if not self.active then
        return
    end

    if ITEM_PREVIEW_KEYBOARD then
        ITEM_PREVIEW_KEYBOARD:ResetOutfitPreview()
    end

    self.active = false
end
