-- Inline list headers (options center / nav left / flush left) for parametric rows.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

LCM.HEADER_TEMPLATE_OPTIONS = "ZO_GamepadOptionsHeaderTemplate"
LCM.HEADER_TEMPLATE_NAV = "ZO_GamepadMenuEntryHeaderTemplate"
LCM.WITH_HEADER_SUFFIX = "WithHeader"
LCM.WITH_NAV_HEADER_SUFFIX = "WithNavHeader"

-- Legacy alias; prefer NormalizeAlign + ResolveHeaderAlign.
function LCM.NormalizeHeaderAlign(align)
	return LCM.NormalizeAlign(align)
end

function LCM.ResolveHeaderText(setting)
	local header = setting.headerText
	if header == nil then
		return nil
	end
	if type(header) == "function" then
		return header(setting)
	end
	if type(header) == "number" then
		return GetString(header)
	end
	return header
end

-- ZO's default header setup uses GetNamedChild("Header"), but AddDataTemplateWithHeader
-- attaches the label as control.headerControl on the scroll parent. Set text there.
function LCM.HeaderSetup(headerControl, data)
	local text = data and data.header
	if not text then
		return
	end
	if type(text) == "function" then
		text = text(data)
	end

	local target = headerControl
	if (not target or target.SetText == nil) and data.control then
		target = data.control.headerControl
	end
	if not target then
		return
	end

	local align = LCM.NormalizeAlign(data.headerAlign)
	local zoAlign = LCM.IsLeftAlign(align) and TEXT_ALIGN_LEFT or TEXT_ALIGN_CENTER

	local function ApplyText(label)
		if not label then
			return
		end
		if label.SetHorizontalAlignment then
			label:SetHorizontalAlignment(zoAlign)
		end
		if label.SetText then
			label:SetText(text)
		end
	end

	ApplyText(target)
	if target.GetNamedChild then
		ApplyText(target:GetNamedChild("Label"))
	end
end

-- align: "center" | "leftIndent" | "leftFlush". indentPx: left inset when leftIndent.
function LCM.LayoutHeaderControl(headerControl, control, align, indentPx)
	local gap = 18
	align = LCM.NormalizeAlign(align)
	indentPx = indentPx or 0
	headerControl:ClearAnchors()
	if LCM.IsLeftAlign(align) then
		headerControl:SetAnchor(BOTTOMLEFT, control, TOPLEFT, indentPx, -gap)
		headerControl:SetAnchor(BOTTOMRIGHT, control, TOPRIGHT, 0, -gap)
	else
		-- Stretch above the row so centered header text sits over the options column.
		headerControl:SetAnchor(BOTTOMLEFT, control, TOPLEFT, 0, -gap)
		headerControl:SetAnchor(BOTTOMRIGHT, control, TOPRIGHT, 0, -gap)
	end
end

-- Attach a nav-style header template variant for an entry type.
-- update/reset are the same pool callbacks used for the base row.
function LCM.RegisterWithNavHeader(list, entryTemplateName, suffix, update, reset)
	local dataTypeName = entryTemplateName .. LCM.WITH_NAV_HEADER_SUFFIX
	if list.dataTypes[dataTypeName] then
		return
	end
	local poolPrefix = (suffix or dataTypeName) .. LCM.WITH_NAV_HEADER_SUFFIX
	local dataTypeInfo = {
		pool = ZO_ControlPool:New(entryTemplateName, list.scrollControl, poolPrefix),
		setupFunction = update,
		parametricFunction = ZO_GamepadMenuEntryTemplateParametricListFunction,
		equalityFunction = function(left, right)
			return left == right
		end,
		headerSetupFunction = LCM.HeaderSetup,
		hasHeader = true,
	}
	dataTypeInfo.pool:SetCustomFactoryBehavior(function(control)
		local headerControl = CreateControlFromVirtual(
			control:GetName() .. "Header",
			list.scrollControl,
			LCM.HEADER_TEMPLATE_NAV
		)
		for i = 0, 1 do
			local isValid, point, _, relPoint, offsetX, offsetY = headerControl:GetAnchor(i)
			if isValid then
				headerControl:SetAnchor(point, control, relPoint, offsetX, offsetY)
			end
		end
		control.headerControl = headerControl
		if list.AddMouseBehaviorToControl then
			list:AddMouseBehaviorToControl(control)
		end
	end)
	dataTypeInfo.pool:SetCustomResetBehavior(function(control)
		control.headerControl:SetHidden(true)
		reset(control)
	end)
	dataTypeInfo.pool:SetCustomAcquireBehavior(function(control)
		control.headerControl:SetHidden(false)
	end)
	list.dataTypes[dataTypeName] = dataTypeInfo
end

-- Resolve header text/align and pick the WithHeader / WithNavHeader template suffix.
-- Indented left → nav header template; center or flush left → options header template.
function LCM.ResolveSettingEntryTemplate(list, setting, templateName)
	local header = LCM.ResolveHeaderText(setting)
	if header and header ~= "" and header ~= list.lastLcmHeader then
		list.lastLcmHeader = header
		setting.header = header
		local align, indentPx = LCM.ResolveHeaderAlign(setting.headerAlign, setting, LCM.currentMenu)
		setting.headerAlign = align
		setting.headerIndentPx = indentPx
		-- Nav template only when leftIndent (icon column).
		if align == "leftIndent" then
			templateName = templateName .. LCM.WITH_NAV_HEADER_SUFFIX
		else
			templateName = templateName .. LCM.WITH_HEADER_SUFFIX
		end
	else
		setting.header = nil
	end
	-- Header groups share a centered-chevron column (longest label in the group).
	setting.lcmArrowGroup = list.lastLcmHeader or ""
	return templateName
end
