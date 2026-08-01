-- SPDX-FileCopyrightText: 2023 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
Taneth("LibId64", function()
    describe("basics", function()
        describe("create id64", function()
            it("from nil", function()
                local value = id64(nil)
                assert.is_nil(value)
            end)

            it("from function with multiple returns", function()
                local expected = id64("1234567890")
                local function test()
                    return expected.id64, true
                end
                local actual = id64(test())
                assert.equals(expected.string, actual.string)
            end)

            local cases = {
                {"-1", "18446744073709551615", nil},
                {"1", "1", 1},
                {"2147483647", "2147483647", 2147483647},
                {"4294967295", "4294967295", 4294967295},
                {"4294967296", "4294967296", 4294967296},
                {"9007199254740991", "9007199254740991", 9007199254740991},
                {"9007199254740992", "9007199254740992", nil},
                {"-9007199254740991", "18437736874454810625", nil},
                {"9223372036854775807", "9223372036854775807", nil},
                {"9223372036854775808", "9223372036854775808", nil},
                {"-9223372036854775808", "9223372036854775808", nil},
                {"18446744073709551615", "18446744073709551615", nil},
                {"18446744073709551616", "18446744073709551615", nil},
                {"-18446744073709551615", "1", 1},
                {"-18446744073709551616", "18446744073709551615", nil},
                {"", "0", 0},
                {"a", "0", 0},
                {"1a", "1", 1},
                {"1a2", "1", 1},
                {"123a2", "123", 123},
                {"0.1", "0", 0},
            }
            describe("from string", function()
                for i = 1, #cases do
                    local input, expected, numeric = unpack(cases[i])
                    it(input, function()
                        local a = id64(input)
                        assert.equals(expected, a.string)
                        assert.equals(numeric, a.number)
                    end)
                end
            end)
            describe("from id64", function()
                for i = 1, #cases do
                    local input, expected, numeric = unpack(cases[i])
                    it(input, function()
                        local a = id64(StringToId64(input))
                        assert.equals(expected, a.string)
                        assert.equals(numeric, a.number)
                    end)
                end
            end)

            describe("from valid Lua number", function()
                local cases = {
                    {-1, "18446744073709551615", nil},
                    {0, "0", 0},
                    {1, "1", 1},
                    {2147483647, "2147483647", 2147483647},
                    {4294967295, "4294967295", 4294967295},
                    {4294967296, "4294967296", 4294967296},
                    {9007199254740991, "9007199254740991", 9007199254740991},
                    {-9007199254740991, "18437736874454810625", nil},
                }
                for i = 1, #cases do
                    local input, expected, numeric = unpack(cases[i])
                    it(tostring(input), function()
                        local a = id64.fromNumber(input)
                        assert.equals(expected, a.string)
                        assert.equals(numeric, a.number)
                    end)
                end
            end)

            describe("from invalid Lua number", function()
                local cases = {
                    {9007199254740992, "Insufficient precision for conversion"},
                    {-9007199254740992, "Insufficient precision for conversion"},
                    {0.1, "Not an integer value"},
                    {0/0, "Not an integer value"},
                    {"0", "Unsupported value type string"},
                }
                for i = 1, #cases do
                    local input, expectedError = unpack(cases[i])
                    it(tostring(input), function()
                        assert.has_error(expectedError, function()
                            id64.fromNumber(input)
                        end)
                    end)
                end
            end)

            it("from an id64 object", function()
                local a = id64("6")
                local b = id64(a)
                assert.equals(a, b)
                assert.is_not_nil(a.__address)
                assert.is_not_nil(b.__address)
                assert.equals(a.__address, b.__address)
            end)

            it("zero is zero either way", function()
                local a = id64("0")
                local b = id64(0)
                local c = id64.fromNumber(0)
                local d = id64(a)
                assert.equals(a, b)
                assert.equals(b, c)
                assert.equals(c, d)
                assert.is_not_nil(a.__address)
                assert.is_not_nil(b.__address)
                assert.is_not_nil(c.__address)
                assert.is_not_nil(d.__address)
                assert.equals(a.__address, b.__address)
                assert.equals(b.__address, c.__address)
                assert.equals(c.__address, d.__address)
            end)
        end)

        it("all values are the same instance", function()
            local a, b
            do a = id64("123").__address end
            do b = id64("123").__address end
            assert.is_not_nil(a)
            assert.is_not_nil(b)
            assert.equals(a, b)
        end)
        -- the Lua GC is non-deterministic (see https://dl.acm.org/doi/fullHtml/10.1145/3414080.3414093)
        -- the only way to force it to collect the value is to run 'collectgarbage' in a loop
        -- but that means the runtime will hang if the cache is broken or someone is keeping a reference to the value
        -- which is why we don't run this test by default
        it.skip("all values are the same instance until they get collected", function()
            local a, b
            do a = id64("1234").__address end

            while a == id64("1234").__address do
                collectgarbage()
            end

            do b = id64("1234").__address end
            assert.is_not_nil(a)
            assert.is_not_nil(b)
            assert.are_not.equals(a, b)
        end)

        describe("isInstance", function()
            local cases = {
                false, 0, "0", {}, function() end, newproxy(true)
            }
            describe("invalid values", function()
                -- start with 0 as we want to test nil too
                for i = 0, #cases do
                    local input = cases[i]
                    it(type(input), function()
                        assert.is_false(id64.isInstance(input))
                    end)
                end
            end)

            it("valid instance", function()
                local input = id64("0")
                assert.is_true(id64.isInstance(input))
            end)
        end)

        describe("an id64 cannot be modified", function()
            local cases = {
                {"555", "id64"},
                {"666", "string"},
                {"777", "number"},
                {"888", "__address"},
            }
            for i = 1, #cases do
                local input, property = unpack(cases[i])
                it("by setting the " .. property .. " property", function()
                    local temp = id64(input)
                    local original = temp[property]
                    assert.has_error("id64 must not be modified", function()
                        temp[property] = "test"
                    end)
                    assert.equals(original, temp[property])
                end)
            end
            it("by modifying the metatable", function()
                local temp = id64("999")
                local mt = getmetatable(temp)
                mt.__index = function() return "test" end
                assert.equals("999", temp.string)
            end)
            it("by replacing the metatable", function()
                local temp = id64("1000")
                assert.has_error("bad argument #1 to 'setmetatable' (table/struct expected, got userdata)", function()
                    setmetatable(temp, {
                        __index = function() return "test" end
                    })
                end)
                assert.equals("1000", temp.string)
            end)
            it("by using rawset", function()
                local temp = id64("1001")
                assert.has_error("bad argument #1 to 'rawset' (table/struct expected, got userdata)", function()
                    rawset(temp, "string", "test")
                end)
                assert.equals("1001", temp.string)
            end)
        end)

        describe("string handling", function()
            it("toString", function()
                local input = id64("0")
                assert.equals("0", tostring(input))
            end)

            describe("append value", function()
                local cases = {
                    false, 0, "", " 0", {}, function() end, newproxy(true)
                }

                -- start with 0 as we want to test nil too
                for i = 0, #cases do
                    local input = cases[i]
                    it(type(input), function()
                        local temp = id64("0")
                        local expected = "0" .. tostring(input)
                        assert.equals(expected, temp .. input)
                    end)
                end
            end)

            describe("prepend value", function()
                local cases = {
                    false, 0, "", " 0", {}, function() end, newproxy(true)
                }

                -- start with 0 as we want to test nil too
                for i = 0, #cases do
                    local input = cases[i]
                    it(type(input), function()
                        local temp = id64("0")
                        local expected = tostring(input) .. "0"
                        assert.equals(expected, input .. temp)
                    end)
                end
            end)

            it("concatenate two id64", function()
                local a = id64("0")
                local b = id64("1")
                assert.equals("01", a .. b)
            end)
        end)
    end)
end)