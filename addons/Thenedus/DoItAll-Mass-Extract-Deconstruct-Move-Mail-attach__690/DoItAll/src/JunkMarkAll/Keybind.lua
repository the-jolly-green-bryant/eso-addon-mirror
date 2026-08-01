DoItAll = DoItAll or {}

local function toggleVisibilityAtStoreWindow()
--	local isPlayerInvShown 		= not INVENTORY_FRAGMENT:IsHidden()
--	local isNotFenceVendor 		= not DoItAll.IsShowingFence()
--	local isNotLaunderVendor 	= not DoItAll.IsShowingLaunder()
--d("isPlayerInvShown: " .. tostring(isPlayerInvShown) .. ", isNotFenceVendor: " .. tostring(isNotFenceVendor) .. ", isNotLaunderVendor: " .. tostring(isNotLaunderVendor))
--    return isPlayerInvShown and isNotFenceVendor and isNotLaunderVendor
    return true
end

--Slightly delayed cuz of addon TweakIt which is overwriting the STORE_WINDOW.keybindStripDescriptor
zo_callLater(function()
	table.insert(STORE_WINDOW.keybindStripDescriptor, {
    	name = "Un-/Junk-Mark All",
        keybind = "SC_BANK_ALL",
        visible = function() return toggleVisibilityAtStoreWindow() end,
        alignment = KEYBIND_STRIP_ALIGN_LEFT,
        callback = function() DoItAll.MarkAllAsJunk() end,
    })
end, 250)
