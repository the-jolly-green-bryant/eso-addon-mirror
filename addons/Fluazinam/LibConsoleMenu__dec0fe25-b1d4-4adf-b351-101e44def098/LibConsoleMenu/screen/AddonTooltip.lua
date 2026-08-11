-- Add-ons submenu left tooltip: manifest via GetAddOnInfo + menu version.

if not LibConsoleMenu or not IsConsoleUI() then
	return
end

local LCM = LibConsoleMenu

local function StripColorCodes(text)
	if not text or text == "" then
		return text
	end
	return text:gsub("|c%x%x%x%x%x%x", ""):gsub("|r", "")
end

local function TitlesMatch(a, b)
	if not a or not b or a == "" or b == "" then
		return false
	end
	return StripColorCodes(a) == StripColorCodes(b)
end

local function FindAddOnIndex(addon)
	local mgr = GetAddOnManager()
	if not mgr then
		return nil
	end

	local menuId = addon.menuId or addon.addonID
	local displayTitle = addon.displayTitle or addon.title

	-- 1) Folder / TOC name == CreateAddonMenu id
	if menuId and menuId ~= "" then
		for i = 1, mgr:GetNumAddOns() do
			local name = mgr:GetAddOnInfo(i)
			if name == menuId then
				return i
			end
		end
	end

	-- 2) Stripped manifest title == menu display title
	if displayTitle and displayTitle ~= "" then
		for i = 1, mgr:GetNumAddOns() do
			local _, title = mgr:GetAddOnInfo(i)
			if TitlesMatch(title, displayTitle) then
				return i
			end
		end
	end

	return nil
end

-- Returns nil if the addon cannot be resolved in AddOnManager (no tooltip).
-- Title/author/description/OOD from manifest; version from menuData (## Version is not in the API).
function LCM.GetAddonManifestMeta(addon)
	if not addon then
		return nil
	end

	local mgr = GetAddOnManager()
	local index = FindAddOnIndex(addon)
	if not mgr or not index then
		return nil
	end

	local _, title, author, description, _, _, isOutOfDate = mgr:GetAddOnInfo(index)
	local version = addon.version
	if version ~= nil then
		version = tostring(version)
		if version == "" then
			version = nil
		end
	end

	return {
		title = StripColorCodes(title) or "",
		author = StripColorCodes(author) or "",
		description = description or "",
		version = version,
		isOutOfDate = isOutOfDate == true,
	}
end

function ZO_Tooltip:LayoutLibConsoleMenuAddonTooltip(meta)
	if not meta then
		return
	end

	if meta.isOutOfDate then
		local topSection = self:AcquireSection(self:GetStyle("addOnTopSection"))
		topSection:AddLine(GetString("SI_ADDONLOADSTATE", ADDON_STATE_VERSION_MISMATCH))
		self:AddSection(topSection)
	end

	if meta.title ~= "" then
		self:AddLine(meta.title, self:GetStyle("addOnName"))
	end

	if meta.author ~= "" then
		local authorPair = self:AcquireStatValuePair(self:GetStyle("statValuePair"), self:GetStyle("fullWidth"))
		authorPair:SetStat(GetString(SI_GAMEPAD_ADDON_MANAGER_TOOLTIP_AUTHOR), self:GetStyle("statValuePairStat"))
		authorPair:SetValue(meta.author, self:GetStyle("statValuePairValueSmall"))
		self:AddStatValuePair(authorPair)
	end

	if meta.version then
		local versionPair = self:AcquireStatValuePair(self:GetStyle("statValuePair"), self:GetStyle("fullWidth"))
		versionPair:SetStat(GetString(SI_LCM_ADDON_TOOLTIP_VERSION), self:GetStyle("statValuePairStat"))
		versionPair:SetValue(meta.version, self:GetStyle("statValuePairValueSmall"))
		self:AddStatValuePair(versionPair)
	end

	if meta.description ~= "" then
		local bodySection = self:AcquireSection(self:GetStyle("bodySection"))
		bodySection:AddLine(meta.description, self:GetStyle("bodyDescription"))
		self:AddSection(bodySection)
	end
end
