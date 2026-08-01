CF.Drawing = {}

local Drawing = CF.Drawing

Drawing.Fonts = {
    ["Standard"] = "$(MEDIUM_FONT)",
    ["ESO Bold"] = "$(BOLD_FONT)",
    ["Antique"] = "$(ANTIQUE_FONT)",
    ["Handwritten"] = "$(HANDWRITTEN_FONT)",
    ["Trajan"] = "$(STONE_TABLET_FONT)",
    ["Futura"] = "EsoUI/Common/Fonts/FuturaStd-CondensedLight.otf",
    ["Futura Bold"] = "EsoUI/Common/Fonts/FuturaStd-Condensed.otf"
}

Drawing.Textures = {
    regenLarge = "CompanionFrame/assets/textures/regen_large.dds",
    regenSmall = "CompanionFrame/assets/textures/regen_small.dds",
    status = "CompanionFrame/assets/textures/background1.dds"
}

function Drawing.GetFont(fontName, fontSize, shadow)
    local font = Drawing.Fonts[fontName] or fontName
    local size = fontSize or 14
    local hasShadow = shadow and "|soft-shadow-thick" or ""

    return font .. "|" .. size .. hasShadow
end

function Drawing.Window(name, width, height, anchors, visible)
    local window = _G[name] or WINDOW_MANAGER:CreateTopLevelWindow(name)

    window:SetDimensions(width, height)
    window:ClearAnchors()
    window:SetAnchor(unpack(anchors))
    window:SetHidden(not visible)

    return window
end

function Drawing.Control(name, parent, width, height, anchors, visible)
    local control = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_CONTROL)

    control:SetDimensions(width, height)
    control:ClearAnchors()
    control:SetAnchor(unpack(anchors))
    control:SetHidden(not visible)

    return control
end

function Drawing.Background(name, parent, width, height, anchors, centreColour, edgeColour, texture, visible)
    local background = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_BACKDROP)

    background:SetDimensions(width, height)
    background:ClearAnchors()
    background:SetAnchor(unpack(anchors))
    background:SetCenterColor(unpack(centreColour))
    background:SetEdgeColor(unpack(edgeColour))
    background:SetEdgeTexture("", 8, 2, 2)
    background:SetCenterTexture(texture)
    background:SetHidden(not visible)

    return background
end

function Drawing.Label(
    name,
    parent,
    width,
    height,
    anchors,
    font,
    colourData,
    horizontalAlignment,
    verticalAlignment,
    text,
    visible)
    font = font or "ZoFontGame"

    local label = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_LABEL)

    label:SetDimensions(width, height)
    label:ClearAnchors()
    label:SetAnchor(unpack(anchors))
    label:SetFont(font)
    label:SetColor(unpack(colourData or CF.Vars.FrameFontColour))
    label:SetHorizontalAlignment(horizontalAlignment or TOP)
    label:SetVerticalAlignment(verticalAlignment or TOP)
    label:SetText(text)
    label:SetHidden(not visible)

    return label
end

function Drawing.Statusbar(name, parent, width, height, anchors, colourData, texture, visible)
    local statusBar = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_STATUSBAR)

    statusBar:SetDimensions(width, height)
    statusBar:ClearAnchors()
    statusBar:SetAnchor(unpack(anchors))
    statusBar:SetColor(unpack(colourData or {1, 1, 1, 1}))
    statusBar:SetTexture(texture)
    statusBar:SetHidden(not visible)

    return statusBar
end

function Drawing.Texture(name, parent, width, height, anchors, texturePath, visible)
    texturePath = texturePath or "/esoui/art/icons/icon_missing.dds"

    local texture = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_TEXTURE)

    texture:SetDimensions(width, height)
    texture:ClearAnchors()
    texture:SetAnchor(unpack(anchors))
    texture:SetTexture(texturePath)
    texture:SetHidden(not visible)

    return texture
end

function Drawing.Cooldown(name, parent, width, height, anchors, colourData, visible)
    local cooldown = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_COOLDOWN)

    cooldown:SetDimensions(width, height)
    cooldown:ClearAnchors()
    cooldown:SetAnchor(unpack(anchors))
    cooldown:SetFillColor(unpack(colourData or {1, 1, 1, 1}))
    cooldown:SetHidden(not visible)

    return cooldown
end

function Drawing.Button(
    name,
    parent,
    width,
    height,
    anchors,
    state,
    font,
    horizontalAlignment,
    verticalAlignment,
    normal,
    pressed,
    mouseover,
    visible)
    state = state or BSTATE_NORMAL
    font = font or "ZoFontGame"

    local button = _G[name] or WINDOW_MANAGER:CreateControl(name, parent, CT_BUTTON)

    button:SetDimensions(width, height)
    button:ClearAnchors()
    button:SetAnchor(unpack(anchors))
    button:SetState(state)
    button:SetFont(font)
    button:SetNormalFontColor(unpack(normal or {1, 1, 1, 1}))
    button:SetPressedFontColor(unpack(pressed or {1, 1, 1, 1}))
    button:SetMouseOverFontColor(unpack(mouseover or {1, 1, 1, 1}))
    button:SetHorizontalAlignment(horizontalAlignment or TOP)
    button:SetVerticalAlignment(verticalAlignment or TOP)
    button:SetHidden(not visible)

    return button
end

-- from https://wowwiki-archive.fandom.com/wiki/USERAPI_ColorGradient
function Drawing.Gradient(perc, ...)
	if perc >= 1 then
		local r, g, b = select(select('#', ...) - 2, ...)
		return r, g, b
	elseif perc <= 0 then
		local r, g, b = ...
		return r, g, b
	end

	local num = select('#', ...) / 3

	local segment, relperc = math.modf(perc*(num-1))
	local r1, g1, b1, r2, g2, b2 = select((segment*3)+1, ...)

	return r1 + (r2 - r1) * relperc, g1 + (g2 - g1) * relperc, b1 + (b2 - b1) * relperc
end
