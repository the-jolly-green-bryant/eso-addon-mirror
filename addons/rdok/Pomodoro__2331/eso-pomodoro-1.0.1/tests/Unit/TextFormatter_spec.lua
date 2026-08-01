describe("TextFormatter", function()

    it("may format a text color for primary.", function()
        local actual = TextFormatter.primary('-value-')
        assert.same('|c007bff-value-|r', actual)
    end)

    it("may format a text color for errors.", function()
        local actual = TextFormatter.error('-value-')
        assert.same('|cdc3545-value-|r', actual)
    end)

    it("may format a text color for success.", function()
        local actual = TextFormatter.success('-value-')
        assert.same('|c28a745-value-|r', actual)
    end)

    it("may format a text color for warning.", function()
        local actual = TextFormatter.warning('-value-')
        assert.same('|cffc107-value-|r', actual)
    end)

    it("may format a text color for info.", function()
        local actual = TextFormatter.info('-value-')
        assert.same('|c17a2b8-value-|r', actual)
    end)
end)
