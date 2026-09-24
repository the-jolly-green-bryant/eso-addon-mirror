local SW = Schlosswerk

SW.styles = {
    original = {
        id = "original",
        nameKey = "STYLE_ORIGINAL",
        body = "EsoUI/Art/Lockpicking/lock_body.dds",
        mask = "EsoUI/Art/Lockpicking/lock_mask.dds",
    },
    classic = {
        id = "classic",
        nameKey = "STYLE_CLASSIC",
        body = SW.textureRoot .. "lock_classic_body.dds",
        mask = SW.textureRoot .. "lock_classic_mask.dds",
    },
    dremora = {
        id = "dremora",
        nameKey = "STYLE_DREMORA",
        body = SW.textureRoot .. "lock_dremora_body.dds",
        mask = SW.textureRoot .. "lock_dremora_mask.dds",
    },
    dwemer = {
        id = "dwemer",
        nameKey = "STYLE_DWEMER",
        body = SW.textureRoot .. "lock_dwemer_body.dds",
        mask = SW.textureRoot .. "lock_dwemer_mask.dds",
    },
    holz = {
        id = "holz",
        nameKey = "STYLE_HOLZ",
        body = SW.textureRoot .. "lock_holz_body.dds",
        mask = SW.textureRoot .. "lock_holz_mask.dds",
    },
    nord = {
        id = "nord",
        nameKey = "STYLE_NORD",
        body = SW.textureRoot .. "lock_nord_body.dds",
        mask = SW.textureRoot .. "lock_nord_mask.dds",
    },
    orsimer = {
        id = "orsimer",
        nameKey = "STYLE_ORSIMER",
        body = SW.textureRoot .. "lock_orsimer_body.dds",
        mask = SW.textureRoot .. "lock_orsimer_mask.dds",
    },
}

SW.styleOrder = {
    "original",
    "classic",
    "dremora",
    "dwemer",
    "holz",
    "nord",
    "orsimer",
}

function SW:IsValidStyle(styleId)
    return type(styleId) == "string" and self.styles[styleId] ~= nil
end

function SW:GetStyleName(styleId)
    local style = self.styles[styleId]
    if not style then
        style = self.styles.original
    end
    return self:L(style.nameKey)
end

function SW:GetStyleChoices()
    local names = {}
    local values = {}
    for index, styleId in ipairs(self.styleOrder) do
        names[index] = self:GetStyleName(styleId)
        values[index] = styleId
    end
    return names, values
end

function SW:ApplyStyle(styleId)
    local style = self.styles[styleId] or self.styles.original
    local panel = ZO_LockpickPanel
    if not panel then
        return false
    end

    local body = panel:GetNamedChild("Body")
    local mask = panel:GetNamedChild("Mask")
    if not body or not mask then
        return false
    end

    body:SetTexture(style.body)
    mask:SetTexture(style.mask)
    self.currentAttemptStyle = style.id
    return true
end
