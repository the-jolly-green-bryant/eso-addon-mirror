describe("Listener", function()

    local expected = { ["addonName"] = 'AddonName', ["callback"] = Listener.dispatch }

    it("should be able register to the event of avatar changing zone", function()
        Listener:registerEvents('AddonName')
        events = EVENT_MANAGER.GetRegisteredEvents()
        expected['event'] = EVENT_ZONE_CHANGED
        assert.are.same(expected, events[1])
    end)

    it("should be able register to the event of avatar looting", function()
        Listener:registerEvents('AddonName')
        events = EVENT_MANAGER.GetRegisteredEvents()
        expected.event = EVENT_LOOT_UPDATED

        assert.are.same(expected, events[2])
    end)

end)
