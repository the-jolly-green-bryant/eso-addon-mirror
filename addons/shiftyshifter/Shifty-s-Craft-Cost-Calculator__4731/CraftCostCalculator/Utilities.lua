-- Shared helpers (links, formatting, small caches).

CraftCostCalculator = CraftCostCalculator or {}
local CCC = CraftCostCalculator

CCC.Utilities = CCC.Utilities or {}
local U = CCC.Utilities

function U:Init(addon)
	U.addon = addon
	U.linkCache = {}
end

--- Build a usable item link from an itemId (sufficient for TTC material lookups).
function U:ItemIdToLink(itemId)
	if not itemId then
		return nil
	end
	local cached = U.linkCache[itemId]
	if cached then
		return cached
	end
	local link = string.format("|H0:item:%d:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0:0|h|h", itemId)
	U.linkCache[itemId] = link
	return link
end

function U:GetItemName(itemLink)
	if not itemLink or itemLink == "" then
		return "Unknown"
	end
	return zo_strformat(SI_TOOLTIP_ITEM_NAME, GetItemLinkName(itemLink))
end

local GOLD_ICON_PATH = "EsoUI/Art/currency/currency_gold.dds"
local GOLD_ICON_SIZE = 16
local STATUS_ICON_SIZE = 16

-- Stock ESO textures only (no custom art).
U.ICON_PATHS = {
	ok = "EsoUI/Art/Miscellaneous/check_icon_64.dds",
	fail = "EsoUI/Art/Buttons/decline_up.dds",
	warn = "EsoUI/Art/Miscellaneous/ESO_Icon_Warning.dds",
	search = "EsoUI/Art/Miscellaneous/search_icon.dds",
	emptyBag = "EsoUI/Art/Inventory/inventory_tabIcon_all_up.dds",
	emptySearch = "EsoUI/Art/Miscellaneous/search_icon.dds",
	emptyCraft = "EsoUI/Art/TreeIcons/tutorial_idexIcon_Crafting_up.dds",
	closeUp = "EsoUI/Art/Buttons/closebutton_up.dds",
	closeOver = "EsoUI/Art/Buttons/closebutton_over.dds",
	closeDown = "EsoUI/Art/Buttons/closebutton_down.dds",
	trashUp = "EsoUI/Art/Buttons/decline_up.dds",
	trashOver = "EsoUI/Art/Buttons/decline_over.dds",
	trashDown = "EsoUI/Art/Buttons/decline_down.dds",
	expand = "EsoUI/Art/Buttons/plus_up.dds",
	expandOver = "EsoUI/Art/Buttons/plus_over.dds",
	expandDown = "EsoUI/Art/Buttons/plus_down.dds",
	collapse = "EsoUI/Art/Buttons/minus_up.dds",
	collapseOver = "EsoUI/Art/Buttons/minus_over.dds",
	collapseDown = "EsoUI/Art/Buttons/minus_down.dds",
}

function U:GoldIcon(size)
	size = size or GOLD_ICON_SIZE
	return zo_iconFormat(GOLD_ICON_PATH, size, size)
end

function U:FormatGold(amount, decimals)
	decimals = decimals or 0
	if amount == nil then
		return "—"
	end
	if TamrielTradeCentre and TamrielTradeCentre.FormatNumber then
		return TamrielTradeCentre:FormatNumber(amount, decimals)
	end
	if decimals > 0 then
		return zo_strformat("<<1>>", zo_floor(amount * (10 ^ decimals) + 0.5) / (10 ^ decimals))
	end
	return zo_strformat("<<1>>", zo_floor(amount + 0.5))
end

--- Number + gold coin texture (for labels, chat, and localized strings).
function U:FormatGoldText(amount, decimals, iconSize)
	if amount == nil then
		return "—"
	end
	return U:FormatGold(amount, decimals) .. " " .. U:GoldIcon(iconSize)
end

--- Prefer a stored icon path; resolve from itemLink only when missing.
function U:ResolveItemIcon(itemLink, existing)
	if existing and existing ~= "" then
		return existing
	end
	if not itemLink or itemLink == "" then
		return nil
	end
	return GetItemLinkIcon(itemLink)
end

--- SetTexture + show, or hide if empty. Skips SetTexture when path is unchanged.
function U:ApplyItemIcon(textureControl, iconPath)
	if not textureControl then
		return
	end
	if not iconPath or iconPath == "" then
		textureControl.cccLastIconPath = nil
		textureControl:SetHidden(true)
		return
	end
	if textureControl.cccLastIconPath ~= iconPath then
		textureControl:SetTexture(iconPath)
		textureControl.cccLastIconPath = iconPath
	end
	textureControl:SetHidden(false)
end

--- Inline status icon + plain text (Known / Unknown, import ok/error, etc.).
-- @param kind "ok"|"fail"|"warn"|"search"
function U:FormatStatusText(kind, label, size)
	size = size or STATUS_ICON_SIZE
	local path = U.ICON_PATHS[kind]
	if not path then
		return label or ""
	end
	local icon = zo_iconFormat(path, size, size)
	if label and label ~= "" then
		return icon .. " " .. label
	end
	return icon
end

--- Muted placeholder texture for empty list hosts.
function U:CreateEmptyPlaceholder(wm, name, parent, iconPath, size)
	size = size or 48
	local tex = wm:CreateControl(name, parent, CT_TEXTURE)
	tex:SetDimensions(size, size)
	tex:SetTexture(iconPath or U.ICON_PATHS.emptyBag)
	tex:SetColor(0.72, 0.72, 0.72, 0.55)
	tex:SetHidden(true)
	tex:SetMouseEnabled(false)
	return tex
end

--- Apply stock close-button textures to a CT_BUTTON (clears text).
function U:ApplyCloseButtonTextures(btn)
	if not btn then
		return
	end
	local p = U.ICON_PATHS
	btn:SetText("")
	btn:SetNormalTexture(p.closeUp)
	btn:SetMouseOverTexture(p.closeOver)
	btn:SetPressedTexture(p.closeDown)
end

--- Apply stock decline/trash textures to a small remove CT_BUTTON.
function U:ApplyRemoveButtonTextures(btn)
	if not btn then
		return
	end
	local p = U.ICON_PATHS
	btn:SetText("")
	btn:SetNormalTexture(p.trashUp)
	btn:SetMouseOverTexture(p.trashOver)
	btn:SetPressedTexture(p.trashDown)
end

--- Apply expand (+) or collapse (−) textures to a tree toggle button.
function U:ApplyExpandButtonTextures(btn, expanded)
	if not btn then
		return
	end
	local p = U.ICON_PATHS
	btn:SetText("")
	if expanded then
		btn:SetNormalTexture(p.collapse)
		btn:SetMouseOverTexture(p.collapseOver)
		btn:SetPressedTexture(p.collapseDown)
	else
		btn:SetNormalTexture(p.expand)
		btn:SetMouseOverTexture(p.expandOver)
		btn:SetPressedTexture(p.expandDown)
	end
end

function U:IsCraftableGear(itemLink)
	local itemType = GetItemLinkItemType(itemLink)
	return itemType == ITEMTYPE_WEAPON or itemType == ITEMTYPE_ARMOR
end

function U:IsMasterWrit(itemLink)
	if not itemLink or itemLink == "" then
		return false
	end
	return GetItemLinkItemType(itemLink) == ITEMTYPE_MASTER_WRIT
end

--- Gear or Master Writ inputs the calculator can attempt to resolve.
function U:IsSupportedCraftInput(itemLink)
	return U:IsCraftableGear(itemLink) or U:IsMasterWrit(itemLink)
end

function U:SafeCall(fn, ...)
	local ok, a, b, c, d = pcall(fn, ...)
	if ok then
		return a, b, c, d
	end
	return nil
end
