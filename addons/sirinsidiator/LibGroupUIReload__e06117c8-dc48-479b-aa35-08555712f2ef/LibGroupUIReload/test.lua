-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
local LGB = LibGroupBroadcast
local UIReload = LGB:GetHandlerApi("UIReload")

Taneth("LibGroupUIReload", function()
    it("should be able to register and unregister for ui reloads", function()
        assert.equals("function", type(UIReload.RegisterForUIReload))
        assert.equals("function", type(UIReload.UnregisterForUIReload))

        local callback = function() end
        assert.is_true(UIReload:RegisterForUIReload(callback))
        assert.is_true(UIReload:UnregisterForUIReload(callback))
    end)
end)
