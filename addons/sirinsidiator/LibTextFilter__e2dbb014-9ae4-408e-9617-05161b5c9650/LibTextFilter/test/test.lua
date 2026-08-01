-- SPDX-FileCopyrightText: 2025 sirinsidiator
--
-- SPDX-License-Identifier: Artistic-2.0

if not Taneth then return end
local lib = LibTextFilter

Taneth("LibTextFilter", function()
    describe("Test tokenizer", function()
        local testCases = {
            -- one operator
            { input = "",                                                                                                                                    output = {} },
            { input = " ",                                                                                                                                   output = {} },
            { input = "+",                                                                                                                                   output = {} },

            -- one operator, one term
            { input = "A",                                                                                                                                   output = { "A" } },
            { input = " A",                                                                                                                                  output = { " ", "A" } },
            { input = "A ",                                                                                                                                  output = { "A" } },
            { input = "  A",                                                                                                                                 output = { " ", "A" } },
            { input = " +A",                                                                                                                                 output = { "A" } },
            { input = "+ A",                                                                                                                                 output = { " ", "A" } },
            { input = " + A",                                                                                                                                output = { " ", "A" } },
            { input = "+A",                                                                                                                                  output = { "A" } },
            { input = "-A",                                                                                                                                  output = { "-", "A" } },
            { input = "~A",                                                                                                                                  output = { "~", "A" } },

            -- two operators, one term
            { input = "+A+",                                                                                                                                 output = { "A" } },
            { input = "+A +",                                                                                                                                output = { "A" } },
            { input = "+ A +",                                                                                                                               output = { " ", "A" } },
            { input = " + A + ",                                                                                                                             output = { " ", "A" } },

            -- 0-2 operator, two terms
            { input = "A B",                                                                                                                                 output = { "A", " ", "B" } },
            { input = "B A",                                                                                                                                 output = { "B", " ", "A" } },
            { input = "A -B",                                                                                                                                output = { "A", "-", "B" } },
            { input = "-B A",                                                                                                                                output = { "-", "B", " ", "A" } },
            { input = "A ~B",                                                                                                                                output = { "A", " ", "~", "B" } },
            { input = "~B A",                                                                                                                                output = { "~", "B", " ", "A" } },
            { input = "A +B",                                                                                                                                output = { "A", "+", "B" } },
            { input = "A+B",                                                                                                                                 output = { "A", "+", "B" } },
            { input = "+A B",                                                                                                                                output = { "A", " ", "B" } },
            { input = "+A +B",                                                                                                                               output = { "A", "+", "B" } },
            { input = "+A+B",                                                                                                                                output = { "A", "+", "B" } },
            { input = "+A -B",                                                                                                                               output = { "A", "-", "B" } },
            { input = "+A-B",                                                                                                                                output = { "A-B" } },
            { input = "+A +-B",                                                                                                                              output = { "A", "-", "B" } },
            { input = "+A !B",                                                                                                                               output = { "A", " ", "!", "B" } },
            { input = "+A +!B",                                                                                                                              output = { "A", "+", "!", "B" } },

            -- 0-3 operators, 3 terms
            { input = "A B C",                                                                                                                               output = { "A", " ", "B", " ", "C" } },
            { input = "  A  B  C  ",                                                                                                                         output = { " ", "A", " ", "B", " ", "C" } },
            { input = "-A B C",                                                                                                                              output = { "-", "A", " ", "B", " ", "C" } },
            { input = "A +B -C",                                                                                                                             output = { "A", "+", "B", "-", "C" } },
            { input = "A -B+C",                                                                                                                              output = { "A", "-", "B", "+", "C" } },

            -- parentheses
            { input = "(A",                                                                                                                                  output = { "(", "A" } },
            { input = "((A",                                                                                                                                 output = { "(", "(", "A" } },
            { input = ")A",                                                                                                                                  output = { ")", "A" } },
            { input = "))A",                                                                                                                                 output = { ")", ")", "A" } },
            { input = "(A)",                                                                                                                                 output = { "(", "A", ")" } },
            { input = "((A))",                                                                                                                               output = { "(", "(", "A", ")", ")" } },
            { input = "A (B+C)",                                                                                                                             output = { "A", " ", "(", "B", "+", "C", ")" } },
            { input = "A -(B+C)",                                                                                                                            output = { "A", "-", "(", "B", "+", "C", ")" } },
            { input = "-(B+C) A",                                                                                                                            output = { "-", "(", "B", "+", "C", ")", " ", "A" } },
            { input = "(A -B) +C",                                                                                                                           output = { "(", "A", "-", "B", ")", "+", "C" } },
            { input = "(-B A) +C",                                                                                                                           output = { "(", "!", "B", " ", "A", ")", "+", "C" } },
            { input = "(!B A) +C",                                                                                                                           output = { "(", "!", "B", " ", "A", ")", "+", "C" } },
            { input = "-A (+B+C)",                                                                                                                           output = { "-", "A", " ", "(", "B", "+", "C", ")" } },
            { input = "-A (+B +C)",                                                                                                                          output = { "-", "A", " ", "(", "B", "+", "C", ")" } },
            { input = "-A (+B-C)",                                                                                                                           output = { "-", "A", " ", "(", "B-C", ")" } },
            { input = "-A (+B -C)",                                                                                                                          output = { "-", "A", " ", "(", "B", "-", "C", ")" } },

            -- quotes
            { input = "\"A",                                                                                                                                 output = { "A" } },
            { input = "\"A\"",                                                                                                                               output = { "A" } },
            { input = " \"A\" ",                                                                                                                             output = { " ", "A" } },
            { input = "\"A \"",                                                                                                                              output = { "A " } },
            { input = "\" A \"",                                                                                                                             output = { " A " } },
            { input = "\" A ",                                                                                                                               output = { " A " } },
            { input = "\"\" A ",                                                                                                                             output = { " ", "A" } },
            { input = "\"A\"\"B\"",                                                                                                                          output = { "A", " ", "B" } },
            { input = "\"A\" \"B\"",                                                                                                                         output = { "A", " ", "B" } },
            { input = "A \"B+C\"",                                                                                                                           output = { "A", " ", "B+C" } },
            { input = "-\"A\"",                                                                                                                              output = { "-", "A" } },

            -- complex
            { input = "\"A+A+A+A+A+A+A+A+A+A+A+A+A+A+A+A+A+A",                                                                                               output = { "A+A+A+A+A+A+A+A+A+A+A+A+A+A+A+A+A+A" } },
            { input = "\"(A+B)\"",                                                                                                                           output = { "(A+B)" } },
            { input = "\"(A+\" B)\"",                                                                                                                        output = { "(A+", " ", "B", ")" } },
            { input = "\"(A+\"B)\"",                                                                                                                         output = { "(A+", " ", "B", ")" } },
            { input = "\"(A+\"\"B)\"",                                                                                                                       output = { "(A+", " ", "B)" } },
            { input = "\"(A+\" \"B)\"",                                                                                                                      output = { "(A+", " ", "B)" } },
            { input = "some-item-name",                                                                                                                      output = { "some-item-name" } },
            { input = "some~item~name",                                                                                                                      output = { "some", " ", "~", "item", " ", "~", "name" } },
            { input = "\"some-item-name\"",                                                                                                                  output = { "some-item-name" } },

            -- itemlinks
            { input = "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",                                                                   output = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" } },
            { input = "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h",                                                                  output = { "~", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" } },
            { input = "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h |H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", output = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", " ", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" } },
        }

        for i = 1, #testCases do
            local test = testCases[i]
            it("case " .. i, function()
                lib:ClearCachedTokens()
                local result = lib:Tokenize(test.input)
                assert.same(test.output, result)
            end)
        end
    end)

    describe("Test parser", function()
        local testCases = {
            { input = lib:Tokenize("A"),                                                                                                                                   output = { "A" } },
            { input = lib:Tokenize("-A"),                                                                                                                                  output = { "A", "-" } },
            { input = lib:Tokenize("!A"),                                                                                                                                  output = { "A", "!" } },
            { input = lib:Tokenize("(A"),                                                                                                                                  output = { "A" } },
            { input = lib:Tokenize("(A)"),                                                                                                                                 output = { "A" } },
            { input = lib:Tokenize("A B"),                                                                                                                                 output = { "A", "B", " " } },
            { input = lib:Tokenize("A -B"),                                                                                                                                output = { "A", "B", "-" } },
            { input = lib:Tokenize("A !B"),                                                                                                                                output = { "A", "B", "!", " " } },
            { input = lib:Tokenize("-B A"),                                                                                                                                output = { "B", "-", "A", " " } },
            { input = lib:Tokenize("!B A"),                                                                                                                                output = { "B", "!", "A", " " } },
            { input = lib:Tokenize("A +B"),                                                                                                                                output = { "A", "B", "+" } },
            { input = lib:Tokenize("+A +B"),                                                                                                                               output = { "A", "B", "+" } },
            { input = lib:Tokenize("+A B"),                                                                                                                                output = { "A", "B", " " } },
            { input = lib:Tokenize("A B C"),                                                                                                                               output = { "A", "B", " ", "C", " " } },
            { input = lib:Tokenize("A +B +C"),                                                                                                                             output = { "A", "B", "+", "C", "+" } },
            { input = lib:Tokenize("A B -C"),                                                                                                                              output = { "A", "B", "C", "-", " " } },
            { input = lib:Tokenize("A +B -C"),                                                                                                                             output = { "A", "B", "+", "C", "-" } },
            { input = lib:Tokenize("A -B +C"),                                                                                                                             output = { "A", "B", "-", "C", "+" } },
            { input = lib:Tokenize("A -(B +C)"),                                                                                                                           output = { "A", "B", "C", "+", "-" } },
            { input = lib:Tokenize("A +B +C D"),                                                                                                                           output = { "A", "B", "+", "C", "+", "D", " " } },
            { input = lib:Tokenize("some~item~name"),                                                                                                                      output = { "some", "item", "~", "name", "~", " ", " " } },
            { input = lib:Tokenize("some-item-name"),                                                                                                                      output = { "some-item-name" } },

            -- itemlinks
            { input = lib:Tokenize("|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"),                                                                   output = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" } },
            { input = lib:Tokenize("~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"),                                                                  output = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~" } },
            { input = lib:Tokenize("|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h |H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h"), output = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", " " } },
        }

        for i = 1, #testCases do
            local test = testCases[i]
            it("case " .. i, function()
                lib:ClearCachedTokens()
                local actual = lib:Parse(test.input)
                for j = 1, #actual do
                    if (actual[j].token) then actual[j] = actual[j].token end
                end
                assert.same(test.output, actual)
            end)
        end
    end)

    describe("Test evaluation", function()
        local testCases = {
            { input = { "A", lib:Parse(lib:Tokenize("A")) },                                                                                                                                     output = { true, lib.RESULT_OK } },
            { input = { "A", lib:Parse(lib:Tokenize("-A")) },                                                                                                                                    output = { false, lib.RESULT_OK } },
            { input = { "A", lib:Parse(lib:Tokenize("!A")) },                                                                                                                                    output = { false, lib.RESULT_OK } },
            { input = { "B", lib:Parse(lib:Tokenize("A")) },                                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "B", lib:Parse(lib:Tokenize("-A")) },                                                                                                                                    output = { true, lib.RESULT_OK } },
            { input = { "B", lib:Parse(lib:Tokenize("!A")) },                                                                                                                                    output = { true, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A B")) },                                                                                                                                 output = { true, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A -B")) },                                                                                                                                output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("-A B")) },                                                                                                                                output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A !B")) },                                                                                                                                output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("!A B")) },                                                                                                                                output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A D")) },                                                                                                                                 output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A +B")) },                                                                                                                                output = { true, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("D +E")) },                                                                                                                                output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A +E")) },                                                                                                                                output = { true, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("E +A")) },                                                                                                                                output = { true, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A B C")) },                                                                                                                               output = { true, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A B C D")) },                                                                                                                             output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("A B -C")) },                                                                                                                              output = { false, lib.RESULT_OK } },
            { input = { "ABD", lib:Parse(lib:Tokenize("A B -C")) },                                                                                                                              output = { true, lib.RESULT_OK } },

            -- itemlinks
            { input = { "ABC", lib:Parse(lib:Tokenize("|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h")) },                                                                   output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h")) },                                                                  output = { false, lib.RESULT_OK } },
            { input = { "ABC", lib:Parse(lib:Tokenize("|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h |H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h")) }, output = { false, lib.RESULT_OK } },

            -- errors
            { input = { "ABD", lib:Parse(lib:Tokenize(")-C")) },                                                                                                                                 output = { false, lib.RESULT_OK } },
        }

        for i = 1, #testCases do
            local test = testCases[i]
            it("case " .. i, function()
                lib:ClearCachedTokens()
                local haystack, needle = unpack(test.input)
                for i = 1, #needle do needle[i] = lib.OPERATORS[needle[i]] or needle[i] end
                local actual, resultCode = lib:Evaluate(haystack, needle)

                local expectedValue, expectedResultCode = unpack(test.output)
                assert.equals(expectedResultCode, resultCode)
                assert.equals(expectedValue, actual)
            end)
        end
    end)

    describe("Test filter", function()
        local testCases = {
            { input = { "camlorn sweet brown ale recipe", "ale" },                                                                                                                                   output = { true, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "ale" },                                                                                                                           output = { true, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "ale" },                                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "ale" },                                                                                                                                    output = { false, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "ale -brown" },                                                                                                                            output = { false, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "ale -brown" },                                                                                                                    output = { true, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "ale -brown" },                                                                                                                              output = { false, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "ale -brown" },                                                                                                                             output = { false, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "ale brown" },                                                                                                                             output = { true, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "ale brown" },                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "ale brown" },                                                                                                                               output = { false, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "ale brown" },                                                                                                                              output = { false, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "ale -recipe" },                                                                                                                           output = { false, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "ale -recipe" },                                                                                                                   output = { false, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "ale -recipe" },                                                                                                                             output = { false, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "ale -recipe" },                                                                                                                            output = { false, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "ale recipe" },                                                                                                                            output = { true, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "ale recipe" },                                                                                                                    output = { true, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "ale recipe" },                                                                                                                              output = { false, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "ale recipe" },                                                                                                                             output = { false, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "ale +recipe" },                                                                                                                           output = { true, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "ale +recipe" },                                                                                                                   output = { true, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "ale +recipe" },                                                                                                                             output = { true, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "ale +recipe" },                                                                                                                            output = { true, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "recipe" },                                                                                                                                output = { true, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "recipe" },                                                                                                                        output = { true, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "recipe" },                                                                                                                                  output = { true, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "recipe" },                                                                                                                                 output = { true, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "tonal +vigilance" },                                                                                                                      output = { false, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "tonal +vigilance" },                                                                                                              output = { true, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "tonal +vigilance" },                                                                                                                        output = { true, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "tonal +vigilance" },                                                                                                                       output = { false, lib.RESULT_OK } },

            { input = { "camlorn sweet brown ale recipe", "ton" },                                                                                                                                   output = { false, lib.RESULT_OK } },
            { input = { "stendarr's vigilance ginger ale recipe", "ton" },                                                                                                                           output = { false, lib.RESULT_OK } },
            { input = { "tonal architect tonic recipe", "ton" },                                                                                                                                     output = { true, lib.RESULT_OK } },
            { input = { "rosy disposition tonic recipe", "ton" },                                                                                                                                    output = { true, lib.RESULT_OK } },

            { input = { "motif 5: chapter 1: something", "chapter (1+2)" },                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "motif 5: chapter 2: something", "chapter (1+2)" },                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "motif 5: chapter 3: something", "chapter (1+2)" },                                                                                                                          output = { false, lib.RESULT_OK } },
            { input = { "motif 22: chapter 1: something", "chapter (1+\" 2:\")" },                                                                                                                   output = { true, lib.RESULT_OK } },
            { input = { "motif 22: chapter 2: something", "chapter (1+\" 2:\")" },                                                                                                                   output = { true, lib.RESULT_OK } },
            { input = { "motif 22: chapter 3: something", "chapter (1+\" 2:\")" },                                                                                                                   output = { false, lib.RESULT_OK } },

            { input = { "chevre-radish salad with pumpkin seeds recipe", "-(with+rabbit) recipe" },                                                                                                  output = { false, lib.RESULT_OK } },
            { input = { "imperial stout recipe", "-(with+rabbit) recipe" },                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "braised rabbit with spring vegetables recipe", "-(with+rabbit) recipe" },                                                                                                   output = { false, lib.RESULT_OK } },
            { input = { "garlic cod with potato crust recipe", "-(with+rabbit) recipe" },                                                                                                            output = { false, lib.RESULT_OK } },
            { input = { "imperial stout", "-(with+rabbit) recipe" },                                                                                                                                 output = { false, lib.RESULT_OK } },

            { input = { "chevre-radish salad with pumpkin seeds recipe", "recipe -(with+rabbit)" },                                                                                                  output = { false, lib.RESULT_OK } },
            { input = { "imperial stout recipe", "recipe -(with+rabbit)" },                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "braised rabbit with spring vegetables recipe", "recipe -(with+rabbit)" },                                                                                                   output = { false, lib.RESULT_OK } },
            { input = { "garlic cod with potato crust recipe", "recipe -(with+rabbit)" },                                                                                                            output = { false, lib.RESULT_OK } },
            { input = { "imperial stout", "recipe -(with+rabbit)" },                                                                                                                                 output = { false, lib.RESULT_OK } },

            { input = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { true, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "-|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { false, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { true, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:10:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { false, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:10:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { true, lib.RESULT_OK } },
            { input = { "|H0:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { true, lib.RESULT_OK } },
            { input = { "|H0:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "-|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { false, lib.RESULT_OK } },
            { input = { "|H0:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { true, lib.RESULT_OK } },
            { input = { "|H0:item:64948:362:10:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { false, lib.RESULT_OK } },
            { input = { "|H0:item:64948:362:10:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { true, lib.RESULT_OK } },
            { input = { "robe of the arch-mage |H0:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h arch mage", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },  output = { true, lib.RESULT_OK } },
            { input = { "robe of the arch-mage |H0:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h arch mage", "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" }, output = { true, lib.RESULT_OK } },

            -- upper/lower case links
            { input = { "|h1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { true, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|h1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { true, lib.RESULT_OK } },
            { input = { "|h1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { true, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|h1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                 output = { true, lib.RESULT_OK } },
            { input = { "|h1:item:64948:362:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                   output = { false, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "|h1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                   output = { false, lib.RESULT_OK } },
            { input = { "|h1:item:64948:362:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|H1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { true, lib.RESULT_OK } },
            { input = { "|H1:item:64948:362:1:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h", "~|h1:item:64948:362:50:0:0:0:0:0:0:0:0:0:0:0:0:1:0:0:0:10000:0|h|h" },                                  output = { true, lib.RESULT_OK } },

            -- problem case #1: partial matches
            { input = { "oko", "oko -okoma" },                                                                                                                                                       output = { true, lib.RESULT_OK } },
            { input = { "okoma", "oko -okoma" },                                                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "okori", "oko -okoma" },                                                                                                                                                     output = { true, lib.RESULT_OK } },
            { input = { "oko", "-okoma oko" },                                                                                                                                                       output = { true, lib.RESULT_OK } },
            { input = { "okoma", "-okoma oko" },                                                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "okori", "-okoma oko" },                                                                                                                                                     output = { true, lib.RESULT_OK } },
            { input = { "oko", "-oko okoma" },                                                                                                                                                       output = { false, lib.RESULT_OK } },
            { input = { "okoma", "-oko okoma" },                                                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "okori", "-oko okoma" },                                                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "oko", "okoma -oko" },                                                                                                                                                       output = { false, lib.RESULT_OK } },
            { input = { "okoma", "okoma -oko" },                                                                                                                                                     output = { false, lib.RESULT_OK } },
            { input = { "okori", "okoma -oko" },                                                                                                                                                     output = { false, lib.RESULT_OK } },

            --	 problem case #2a: order of terms
            { input = { "repora", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "rejera", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "makko", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                           output = { true, lib.RESULT_OK } },
            { input = { "makkoma", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                         output = { false, lib.RESULT_OK } },
            { input = { "meip", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                            output = { true, lib.RESULT_OK } },
            { input = { "makderi", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                         output = { true, lib.RESULT_OK } },
            { input = { "taderi", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "rakeipa", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                         output = { true, lib.RESULT_OK } },
            { input = { "kuta", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                            output = { true, lib.RESULT_OK } },
            { input = { "rekuta", "repora +rejera +makko -makkoma +meip +makderi +taderi +rakeipa +kuta" },                                                                                          output = { true, lib.RESULT_OK } },

            -- problem case #2b: order of terms
            { input = { "rekuta", "+kuta +meip +makderi +repora -rekuta" },                                                                                                                          output = { false, lib.RESULT_OK } },
            { input = { "kuta", "kuta +meip +makderi +repora -rekuta" },                                                                                                                             output = { true, lib.RESULT_OK } },
            { input = { "rekuta", "meip +makderi +repora +kuta -rekuta" },                                                                                                                           output = { false, lib.RESULT_OK } },
            { input = { "kuta", "meip +makderi +repora +kuta -rekuta" },                                                                                                                             output = { true, lib.RESULT_OK } },

            --		 problem case #2c: order of terms
            { input = { "makko", "+kuta +makko -makkoma" },                                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "makko", "+kuta -makkoma +makko" },                                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "makko", "+makko +kuta -makkoma" },                                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "makko", "+makko -makkoma +kuta" },                                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "makko", "-makkoma +makko +kuta" },                                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "makko", "-makkoma +kuta +makko" },                                                                                                                                          output = { true, lib.RESULT_OK } },
            { input = { "makkoma", "+kuta +makko -makkoma" },                                                                                                                                        output = { false, lib.RESULT_OK } },
            { input = { "makkoma", "+kuta -makkoma makko" },                                                                                                                                         output = { false, lib.RESULT_OK } },
            { input = { "makkoma", "+makko +kuta -makkoma" },                                                                                                                                        output = { false, lib.RESULT_OK } },
            { input = { "makkoma", "+makko -makkoma +kuta" },                                                                                                                                        output = { false, lib.RESULT_OK } },
            { input = { "makkoma", "-makkoma +makko +kuta" },                                                                                                                                        output = { true, lib.RESULT_OK } },
            { input = { "makkoma", "-makkoma +kuta +makko" },                                                                                                                                        output = { true, lib.RESULT_OK } },

            -- problem case #3: whitespace only
            { input = { "Oko", " " },                                                                                                                                                                output = { false, lib.RESULT_INVALID_INPUT } },
        }

        for i = 1, #testCases do
            local test = testCases[i]
            it("case " .. i, function()
                lib:ClearCachedTokens()
                local haystack, needle = unpack(test.input)
                local actual, resultCode = lib:Filter(haystack, needle)

                local expectedValue, expectedResultCode = unpack(test.output)
                assert.equals(expectedResultCode, resultCode)
                assert.equals(expectedValue, actual)
            end)
        end
    end)

    describe("Test cache", function()
        it("should cache tokens", function()
            lib:ClearCachedTokens()
            local needle = "test +test"
            assert.is_nil(lib.cache[needle])
            local value1, result1 = lib:Filter("test", needle)
            assert.is_not_nil(lib.cache[needle])
            assert.equals(#lib.cache[needle], 3)
            local value2, result2 = lib:Filter("test", needle)
            assert.equals(#lib.cache[needle], 3)
            assert.is_not_nil(lib.cache[needle])
            assert.equals(result1, lib.RESULT_OK)
            assert.equals(result2, lib.RESULT_OK)
            assert.is_true(value1)
            assert.is_true(value2)
        end)
    end)
end)
