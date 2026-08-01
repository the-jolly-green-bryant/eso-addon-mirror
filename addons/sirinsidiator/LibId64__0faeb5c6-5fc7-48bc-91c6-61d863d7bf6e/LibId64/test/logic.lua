-- SPDX-FileCopyrightText: 2023 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
Taneth("LibId64", function()
    describe("logic", function()
        local cases = {
            -- smaller, input, larger
            { nil, "0", "1", },
            { "0", "1", "2", },
            {"2147483646", "2147483647", "2147483648"},
            {"2147483647", "2147483648", "2147483649"},
            {"4294967294", "4294967295", "4294967296"},
            {"4294967295", "4294967296", "4294967297"},
            {"4294967296", "4294967297", "4294967298"},
            {"9007199254740990", "9007199254740991", "9007199254740992"},
            {"9007199254740991", "9007199254740992", "9007199254740993"},
            {"9223372036854775806", "9223372036854775807", "9223372036854775808"},
            {"9223372036854775807", "9223372036854775808", "9223372036854775809"},
            {"18446744073709551613", "18446744073709551614", "18446744073709551615"},
            {"18446744073709551614", "18446744073709551615", nil},
        }
        describe("equals", function()
            for i = 1, #cases do
                local _, input = unpack(cases[i])
                it(input, function()
                    local a = id64(input)
                    local b = id64(input)
                    assert.is_true(a == b)
                    assert.is_false(a ~= b)
                end)
            end
        end)
        describe("not equals", function()
            for i = 1, #cases do
                local smaller, input, larger = unpack(cases[i])
                it(input, function()
                    local a = id64(smaller or larger)
                    local b = id64(input)
                    assert.is_false(a == b)
                    assert.is_true(a ~= b)
                end)
            end
        end)
        describe("less than", function()
            for i = 1, #cases do
                local smaller, input, larger = unpack(cases[i])
                if smaller then
                    it(input, function()
                        local a = id64(smaller)
                        local b = id64(input)
                        assert.is_true(a < b)
                        assert.is_false(b < a)
                    end)
                end
            end
        end)
        describe("less than equal", function()
            for i = 1, #cases do
                local smaller, input, larger = unpack(cases[i])
                if smaller then
                    it(input, function()
                        local a = id64(smaller)
                        local b = id64(input)
                        assert.is_true(a <= b)
                        assert.is_false(b <= a)
                    end)
                end
            end
        end)
        describe("less than equal same", function()
            for i = 1, #cases do
                local _, input = unpack(cases[i])
                it(input, function()
                    local a = id64(input)
                    local b = id64(input)
                    assert.is_true(a <= b)
                    assert.is_true(b <= a)
                end)
            end
        end)
        describe("greater than", function()
            for i = 1, #cases do
                local smaller, input, larger = unpack(cases[i])
                if larger then
                    it(input, function()
                        local a = id64(larger)
                        local b = id64(input)
                        assert.is_true(a > b)
                        assert.is_false(b > a)
                    end)
                end
            end
        end)
        describe("greater than equal", function()
            for i = 1, #cases do
                local smaller, input, larger = unpack(cases[i])
                if larger then
                    it(input, function()
                        local a = id64(larger)
                        local b = id64(input)
                        assert.is_true(a >= b)
                        assert.is_false(b >= a)
                    end)
                end
            end
        end)
        describe("greater than equal same", function()
            for i = 1, #cases do
                local _, input = unpack(cases[i])
                if larger then
                    it(input, function()
                        local a = id64(input)
                        local b = id64(input)
                        assert.is_true(a >= b)
                        assert.is_true(b >= a)
                    end)
                end
            end
        end)
    end)
end)