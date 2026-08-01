
--[[ LuXhrys Module Add-On System ]]
--[[ Written by Xhrysanth (PSNA) ]]
--[[ LibItemLinkPreview ]]
--[[ LIPPreview.lua ]]
--[[ LOAD ORDER FIRST ]]


--[[ DISCLAIMER
This Add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved.
]]

--[[ Information, attribution, copyright, and license:
This file is the item link preview component for the LuXhrys add-on system for the Elder Scrolls Online.

This code chunk implements item link preview functions for the LuXhrys add-on system for the Elder Scrolls Online.

Written and copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software.
]]


--[[ =========================> AUTHORIZATION <=========================== ]]--


do
	local playerName = GetDisplayName ()

	assert (playerName == "@Xhrysanth" or playerName == "Xhrysanth", "[LuXhrysLIPP] CRIT: Not an authorized user. This chunk will not be loaded.")

end


--[[ ==========================> DECLARATIONS <=========================== ]]--


-- ============================= [ Namespace ] ============================= --


if not LUXHRYS then
	d ("[LuXhrysLIPP] WARN: LuXhrys is not available. Please consider using the LuXhrys modular add-on system.")
end


-- ============================== [ Metadata ] ============================= --

local ADDON_SYSTEM_NAME = LUXHRYS.METADATA.ADDON_SYSTEM_NAME or "LuXhrys"
local ADDON_DESCRIPTION = LUXHRYS.METADATA.ADDON_DESCRIPTION or "The LuXhrys modular add-on system for the Elder Scrolls Online game."
local ADDON_DISCLAIMER = LUXHRYS.METADATA.ADDON_DISCLAIMER or "This add-on is not created by, affiliated with, or sponsored by, ZeniMax Media Inc. or its affiliates. The Elder Scrolls® and related logos are registered trademarks or trademarks of ZeniMax Media Inc. in the United States and/or other countries. All rights reserved."
local ADDON_AUTHOR = LUXHRYS.METADATA.ADDON_AUTHOR or "Xhrysanth (PSNA)"
local ADDON_COPYRIGHT_AND_LICENSE = LUXHRYS.METADATA.ADDON_COPYRIGHT_AND_LICENSE or "Copyright (c) 2026 by Xhrysanth (PSNA). License terms to be determined. Currently, and until this notice changes, all rights are reserved, except those that belong to ZeniMax Media Inc., which provides the API used by this software."

if not LUXHRYS then
	LUXHRYS = {}

	LUXHRYS.METADATA =
	{
		ADDON_SYSTEM_NAME = ADDON_SYSTEM_NAME,
		ADDON_DESCRIPTION = ADDON_DESCRIPTION,
		ADDON_DISCLAIMER = ADDON_DISCLAIMER,
		ADDON_AUTHOR = ADDON_AUTHOR,
		ADDON_COPYRIGHT_AND_LICENSE = ADDON_COPYRIGHT_AND_LICENSE
	}
end

local ADDON_MODULE_NAME = "LibItemLinkPreview"
local ADDON_MODULE_SHORT_NAME = "LIP"
local ADDON_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_NAME
local ADDON_MODULE_VERSION = "0.0a" -- Can we substitute with reading a var provided by the API?
local ADDON_MODULE_DESCRIPTION = "Implements itemLink preview functionality for the LuXhrys add-on system for the Elder Scrolls Online."

LUXHRYS.LIP = {}
LUXHRYS.LIP.METADATA =
{
	ADDON_MODULE_NAME = ADDON_MODULE_NAME,
	ADDON_MODULE_SHORT_NAME = ADDON_MODULE_SHORT_NAME,
	ADDON_NAME = ADDON_NAME,
	ADDON_MODULE_VERSION = ADDON_MODULE_VERSION,
	ADDON_MODULE_DESCRIPTION = ADDON_MODULE_DESCRIPTION
}

local ADDON_CHUNK_NAME = "Preview"
local ADDON_CHUNK_SHORT_NAME = "P"
local ADDON_DEBUG_NAME = ADDON_SYSTEM_NAME .. ADDON_MODULE_SHORT_NAME .. ADDON_CHUNK_SHORT_NAME


-- ===================== [ Localize Global Functions ] ===================== --


-------------------------------------------------------------------------------
--| From LXICommon |-----------------------------------------------------------
-------------------------------------------------------------------------------


local Debug = LUXHRYS.Debug


--[[ ============================> FUNCTIONS <============================ ]]--


-- ==========================[ Preview itemLink ]=========================== --

--[[ BASIC INSTRUCTIONS

	1. Add gamepad preview options fragment to your scene appropriate for the quadrants you want to use.
	2. Add the preview fragment to your scene by calling ITEM_PREVIEW_GAMEPAD:GetFragment.
	3. Add necessary keybinds to trigger preview and end preview.
	4. Call ITEM_PREVIEW_GAMEPAD:ClearPreviewCollection.
	5. Call ITEM_PREVIEW_GAMEPAD:PreviewItemLink.
	6. When finished, call ITEM_PREVIEW_GAMEPAD:EndCurrentPreview.

]]


LuXhrys_ItemPreviewType_ItemLink = ZO_ItemPreviewType:Subclass ()


function LuXhrys_ItemPreviewType_ItemLink:SetStaticParameters (itemLink)
    self.itemLink = itemLink
end

function LuXhrys_ItemPreviewType_ItemLink:ResetStaticParameters ()
    self.itemLink = ""
end

function LuXhrys_ItemPreviewType_ItemLink:HasStaticParameters (itemLink)
    return self.itemLink == itemLink
end

function LuXhrys_ItemPreviewType_ItemLink:Apply (variationIndex)
    PreviewItemLink (self.itemLink, variationIndex)
end

function LuXhrys_ItemPreviewType_ItemLink:GetNumVariations ()
    return GetNumItemLinkPreviewVariations (self.itemLink)
end

function LuXhrys_ItemPreviewType_ItemLink:GetVariationName (variationIndex)
    return GetItemLinkPreviewVariationDisplayName (self.itemLink, variationIndex)
end


local function InitializeLibItemLinkPreview (_, addonName)
	if addonName and addonName == ADDON_NAME then
		Debug.Msg (1, ADDON_DEBUG_NAME, "ILIP", "Initializing %s.", ADDON_CHUNK_NAME)

		local LUXHRYS_ITEM_PREVIEW_ITEMLINK_INDEX = #ITEM_PREVIEW_GAMEPAD.previewTypeObjects + 1

		--ZO_ItemPreview_Shared.previewTypeObjects[LUXHRYS_ITEM_PREVIEW_ITEMLINK] = LuXhrys_ItemPreviewType_ItemLink.New ()

		ITEM_PREVIEW_GAMEPAD.previewTypeObjects[LUXHRYS_ITEM_PREVIEW_ITEMLINK_INDEX] = LuXhrys_ItemPreviewType_ItemLink:New ()

		function ZO_ItemPreview_Shared:PreviewItemLink (itemLink)
			self:SharedPreviewSetup (LUXHRYS_ITEM_PREVIEW_ITEMLINK_INDEX, itemLink)
		end

		EVENT_MANAGER:UnregisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED)

		Debug.Msg (1, ADDON_DEBUG_NAME, "ILIP", "%s initialization %s.", ADDON_DEBUG_NAME, ITEM_PREVIEW_GAMEPAD.previewTypeObjects[LUXHRYS_ITEM_PREVIEW_ITEMLINK_INDEX] ~= nil and "successful" or "failed")
	end
end


EVENT_MANAGER:RegisterForEvent (ADDON_DEBUG_NAME, EVENT_ADD_ON_LOADED, InitializeLibItemLinkPreview)









