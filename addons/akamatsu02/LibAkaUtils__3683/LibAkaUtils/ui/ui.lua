LibAkaUtils = LibAkaUtils or {}

function LibAkaUtils.announcement(str)
	local message = CENTER_SCREEN_ANNOUNCE:CreateMessageParams(CSA_CATEGORY_LARGE_TEXT)
	message:SetCSAType(CENTER_SCREEN_ANNOUNCE_TYPE_DISPLAY_ANNOUNCEMENT)
	message:SetText(str)
	CENTER_SCREEN_ANNOUNCE:AddMessageWithParams(message)
end

function LibAkaUtils.alert(str)
	ZO_Alert(UI_ALERT_CATEGORY_ALERT, nil, str)
end

function LibAkaUtils.formatDistance(distance)
	return tostring(math.round(distance/100, 1)).."m"
end

function LibAkaUtils.SetElementAnchor(element, position, onDone)
    if position then
        local vara = position[1]
        local varb = position[2]
        local varc = position[3]
        local vard = position[4]
        local varf = position[5]
        local varg = CENTER
        if varc and vard and varf then
            vara = varc * GuiRoot:GetWidth()
            varb = vard * GuiRoot:GetHeight()
        else
            varf = TOPLEFT
            varg = TOPLEFT
        end
        element:ClearAnchors()
        element:SetAnchor(varg, GuiRoot, varf, vara, varb)
        if varg == TOPLEFT then
            onDone(element)
        end
    end
end

function LibAkaUtils.StorePosition(element)
	if element == nil then return end
    local vara, varb = element:GetCenter()
    local varc, vard = GuiRoot:GetCenter()
    local varf, varg = GuiRoot:GetDimensions()
    local varh
    local vari
    local varj
    if vara > varc then
        vari = (vara-varf)/varf
        if varb > vard then
            varj = (varb-varg)/varg
            varh = BOTTOMRIGHT
        else
            varj = varb/varg
            varh = TOPRIGHT
        end
    else
        vari = vara/varf
        if varb > vard then
            varj = (varb-varg)/varg
            varh = BOTTOMLEFT
        else
            varj = varb/varg
            varh = TOPLEFT
        end
    end
	return {element:GetLeft(), element:GetTop(), vari, varj, varh}
end