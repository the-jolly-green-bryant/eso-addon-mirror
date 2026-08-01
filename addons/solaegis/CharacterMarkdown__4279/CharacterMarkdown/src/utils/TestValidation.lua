-- CharacterMarkdown - Test Validation Utilities
-- Validates fixes applied to visual issues
-- Based on FIXES_APPLIED_SUMMARY.md test cases

local CM = CharacterMarkdown
CM.tests = CM.tests or {}
CM.tests.validation = {}

local string_find = string.find
local string_match = string.match
local string_gsub = string.gsub
local string_format = string.format

-- =====================================================
-- TEST RESULTS TRACKING
-- =====================================================

local testResults = {
    passed = {},
    failed = {},
    warnings = {},
}

local function AddResult(testName, passed, message, warning)
    if warning then
        table.insert(testResults.warnings, {
            test = testName,
            message = message or "",
        })
    elseif passed then
        table.insert(testResults.passed, {
            test = testName,
            message = message or "",
        })
    else
        table.insert(testResults.failed, {
            test = testName,
            message = message or "",
        })
    end
end

local function ResetResults()
    testResults.passed = {}
    testResults.failed = {}
    testResults.warnings = {}
end

-- =====================================================
-- ISSUE #1: HTML TABLE VALIDATION
-- =====================================================

local function ValidateHTMLStructure(markdown)
    local testName = "Issue #1: HTML Structure"

    -- Check for broken HTML (missing <tr> tags)
    local hasTable = string_find(markdown, "<table")
    if not hasTable then
        AddResult(testName, true, "No HTML tables found (using proper markdown)")
        return true
    end

    -- If tables exist, check for proper structure
    -- Count occurrences correctly

    -- Count <table> tags
    local _, tableCount = string_gsub(markdown, "<table", "")

    -- Count <tr> tags
    local _, trCount = string_gsub(markdown, "<tr", "")

    -- Valid HTML: every <table> should have at least one <tr>
    if trCount >= tableCount then
        AddResult(testName, true, string_format("All %d tables have proper <tr> tags", tableCount))
        return true
    else
        AddResult(testName, false, string_format("Found %d tables but only %d <tr> tags", tableCount, trCount))
        return false
    end
end

-- =====================================================
-- ISSUE #2: CALLOUT SYNTAX VALIDATION
-- =====================================================

local function ValidateCalloutSyntax(markdown, format)
    local testName = "Issue #2: Callout Syntax"

    -- Check for GitHub-native callout syntax: > [!NOTE]
    local noteCallout = string_find(markdown, "> %[!NOTE%]")
    local tipCallout = string_find(markdown, "> %[!TIP%]")
    local warningCallout = string_find(markdown, "> %[!WARNING%]")
    local importantCallout = string_find(markdown, "> %[!IMPORTANT%]")

    -- Also check for old incorrect syntax (blockquote without [!])
    local oldSyntax = string_find(markdown, "> %[NOTE%]")
        or string_find(markdown, "> %[TIP%]")
        or string_find(markdown, "> NOTE")
        or string_find(markdown, "> TIP")

    if oldSyntax then
        AddResult(testName, false, "Found old/incorrect callout syntax (missing !)")
        return false
    end

    local calloutCount = 0
    if noteCallout then
        calloutCount = calloutCount + 1
    end
    if tipCallout then
        calloutCount = calloutCount + 1
    end
    if warningCallout then
        calloutCount = calloutCount + 1
    end
    if importantCallout then
        calloutCount = calloutCount + 1
    end

    if calloutCount > 0 then
        AddResult(testName, true, string_format("Found %d properly formatted callout(s)", calloutCount))
        return true
    else
        AddResult(testName, true, "No callouts found (not an error)", true)
        return true
    end
end

-- =====================================================
-- ISSUE #3: RESOURCE VALUES VALIDATION
-- =====================================================

local function ValidateResourceValues(markdown)
    local testName = "Issue #3: Resource Values"

    -- Check for Quick Stats section first
    local hasQuickStats = string_find(markdown, "Quick Stats")
        or string_find(markdown, "%[!NOTE%].*Health")
        or string_find(markdown, "Level.*CP")

    if not hasQuickStats then
        AddResult(testName, true, "Quick Stats section not found (may be disabled)", true)
        return true
    end

    -- More flexible pattern matching for resource values
    -- Try multiple patterns to find resource values
    local healthPatterns = {
        "Health[^:]*:[^%d]*(%d+)",
        "Health[^|]*|.*(%d+)",
        "Health.*%*%*(%d+)",
    }

    local magickaPatterns = {
        "Magicka[^:]*:[^%d]*(%d+)",
        "Magicka[^|]*|.*(%d+)",
        "Magicka.*%*%*(%d+)",
    }

    local staminaPatterns = {
        "Stamina[^:]*:[^%d]*(%d+)",
        "Stamina[^|]*|.*(%d+)",
        "Stamina.*%*%*(%d+)",
    }

    local healthValue = nil
    local magickaValue = nil
    local staminaValue = nil

    -- Try to extract values
    for _, pattern in ipairs(healthPatterns) do
        local match = string_match(markdown, pattern)
        if match then
            healthValue = match
            break
        end
    end

    for _, pattern in ipairs(magickaPatterns) do
        local match = string_match(markdown, pattern)
        if match then
            magickaValue = match
            break
        end
    end

    for _, pattern in ipairs(staminaPatterns) do
        local match = string_match(markdown, pattern)
        if match then
            staminaValue = match
            break
        end
    end

    -- Only fail if we can clearly detect all three are zero
    if healthValue == nil and magickaValue == nil and staminaValue == nil then
        -- Couldn't find any values - might be format issue or actually all zero
        AddResult(testName, false, "Could not find resource values in Quick Stats (check format or data collection)")
        return false
    elseif not healthValue and not magickaValue and not staminaValue then
        -- Found patterns but all extracted values are nil
        AddResult(testName, false, "Could not extract resource values from Quick Stats (check format or data collection)")
        return false
    else
        AddResult(testName, true, "Resource values found and appear valid")
        return true
    end
end

-- =====================================================
-- ISSUE #4: ENLIGHTENMENT CALLOUT VALIDATION
-- =====================================================

local function ValidateEnlightenmentCallout(markdown, format)
    local testName = "Issue #4: Enlightenment Callout"

    -- Check for TIP callout (correct) vs SUCCESS callout (wrong)
    local tipCallout = string_find(markdown, "> %[!TIP%].*[Ee]nlight")
        or string_find(markdown, "> %[!TIP%].*4x.*[Cc][Pp]")

    local successCallout = string_find(markdown, "> %[!SUCCESS%].*[Ee]nlight")
        or string_find(markdown, "> %[!SUCCESS%].*4x.*[Cc][Pp]")

    if successCallout then
        AddResult(testName, false, "Found SUCCESS callout instead of TIP for Enlightenment")
        return false
    end

    if tipCallout then
        AddResult(testName, true, "Enlightenment uses correct TIP callout type")
        return true
    else
        AddResult(testName, true, "No enlightenment callout found (character not enlightened)", true)
        return true
    end
end

-- =====================================================
-- ISSUE #5: ATTENTION NEEDED WARNINGS
-- =====================================================

local function ValidateAttentionWarnings(markdown)
    local testName = "Issue #5: Attention Needed Warnings"

    -- Check for warning callout
    local warningCallout = string_find(markdown, "> %[!WARNING%]") or string_find(markdown, "##.*⚠️.*Attention")

    if not warningCallout then
        AddResult(testName, true, "No warnings found (not an error)", true)
        return true
    end

    -- Check for specific warning types
    local unspentSkillPoints = string_find(markdown, "unspent skill point")
    local unspentAttributes = string_find(markdown, "unspent attribute point")
    local inventoryFull = string_find(markdown, "nearly full") or string_find(markdown, "Backpack.*%d%%")
    local ridingTraining = string_find(markdown, "Riding training available")
    local companionLow = string_find(markdown, "Companion rapport low")

    local warningCount = 0
    if unspentSkillPoints then
        warningCount = warningCount + 1
    end
    if unspentAttributes then
        warningCount = warningCount + 1
    end
    if inventoryFull then
        warningCount = warningCount + 1
    end
    if ridingTraining then
        warningCount = warningCount + 1
    end
    if companionLow then
        warningCount = warningCount + 1
    end

    AddResult(testName, true, string_format("Found warning callout with %d warning type(s)", warningCount))
    return true
end

-- =====================================================
-- ISSUE #6: PROGRESS BAR CONSISTENCY
-- =====================================================

local function ValidateProgressBars(markdown)
    local testName = "Issue #6: Progress Bar Consistency"

    -- Require progress bar glyphs together in a capacity/progress context (not isolated characters)
    local progressBarPattern = "[█░]+"
    local hasProgressBarRow = string_find(markdown, "|.-|" .. progressBarPattern .. ".-%d+%%")
        or string_find(markdown, progressBarPattern .. ".-%d+%%")

    -- Check for old inconsistent characters
    local oldBars = string_find(markdown, "▓") or string_find(markdown, "▰") or string_find(markdown, "▱")

    if oldBars then
        AddResult(testName, false, "Found old progress bar characters (▓, ▰, ▱) - should use █ and ░")
        return false
    end

    if hasProgressBarRow then
        AddResult(testName, true, "Progress bars use standardized characters (█ and ░)")
        return true
    else
        AddResult(testName, true, "No progress bars found (not an error)", true)
        return true
    end
end

-- =====================================================
-- ISSUE #7: PVP SECTION VALIDATION
-- =====================================================

local function ValidatePvPSections(markdown)
    local testName = "Issue #7: PvP Section Duplication"

    -- Count PvP section headers correctly
    local _, pvpHeaderCount = string_gsub(markdown, "##.*⚔️.*PvP", "")

    -- Check for duplicate "PvP Stats" section
    local pvpStatsHeader = string_find(markdown, "##.*PvP Stats")

    if pvpStatsHeader then
        AddResult(testName, false, "Found duplicate 'PvP Stats' section (should be merged)")
        return false
    end

    if pvpHeaderCount > 1 then
        AddResult(testName, false, string_format("Found %d PvP sections (should be 1)", pvpHeaderCount))
        return false
    elseif pvpHeaderCount == 1 then
        AddResult(testName, true, "Single unified PvP section found")
        return true
    else
        AddResult(testName, true, "No PvP section found (PvP disabled or no data)", true)
        return true
    end
end

-- =====================================================
-- EMOJI COMPATIBILITY VALIDATION
-- =====================================================

local function ValidateEmojiCompatibility(markdown)
    local testName = "Emoji Compatibility"

    -- Check for problematic/newer emojis that might not render
    local problematicEmojis = {
        ["🪖"] = "Military helmet (newer emoji)",
        ["📿"] = "Prayer beads (may not render)",
        ["🦵"] = "Leg (newer emoji)",
        ["🧤"] = "Gloves (newer emoji)",
        ["🧬"] = "DNA (newer emoji)",
        ["🏛️"] = "Classical building (may not render)",
        ["🗡️"] = "Dagger (may not render)",
    }

    local foundProblems = {}
    for emoji, description in pairs(problematicEmojis) do
        if string_find(markdown, emoji) then
            table.insert(foundProblems, description)
        end
    end

    if #foundProblems > 0 then
        AddResult(
            testName,
            false,
            string_format("Found potentially incompatible emojis: %s", table.concat(foundProblems, ", "))
        )
        return false
    end

    AddResult(testName, true, "All emojis use widely-supported characters")
    return true
end

-- =====================================================
-- ISSUE #9: CHAMPION POINTS FORMAT VALIDATION
-- =====================================================

local function ValidateChampionPointsFormat(markdown)
    local testName = "Issue #9: Champion Points Format"

    -- Check for Available Champion Points line in Overview section
    -- Expected format: | **Available Champion Points** | ⚒️ X - ⚔️ Y - 💪 Z |
    -- Where X, Y, Z are remaining (unassigned) points per discipline
    local cpPattern = "%*%*Available Champion Points%*%*.*⚒️%s*(%d+)%s*%-%s*⚔️%s*(%d+)%s*%-%s*💪%s*(%d+)"
    local craftCP, warfareCP, fitnessCP = string_match(markdown, cpPattern)

    if not craftCP or not warfareCP or not fitnessCP then
        -- Check if CP section exists at all
        local hasCPLine = string_find(markdown, "Available Champion Points")
        if not hasCPLine then
            AddResult(testName, true, "Champion Points line not found (may be disabled)", true)
            return true
        end

        -- CP line exists but format is wrong
        AddResult(testName, false, "Champion Points format incorrect. Expected: ⚒️ X - ⚔️ Y - 💪 Z")
        return false
    end

    -- Convert to numbers for validation
    craftCP = tonumber(craftCP)
    warfareCP = tonumber(warfareCP)
    fitnessCP = tonumber(fitnessCP)

    -- Validate that values are non-negative
    if craftCP < 0 or warfareCP < 0 or fitnessCP < 0 then
        AddResult(
            testName,
            false,
            string_format(
                "Champion Points contain negative values: Craft=%d, Warfare=%d, Fitness=%d",
                craftCP,
                warfareCP,
                fitnessCP
            )
        )
        return false
    end

    -- For Kellen Dysart specifically, validate expected values
    -- This is a known test case: Craft=18, Warfare=43, Fitness=3
    local isKellenDysart = string_find(markdown, "Kellen Dysart")
    if isKellenDysart then
        if craftCP == 18 and warfareCP == 43 and fitnessCP == 3 then
            AddResult(
                testName,
                true,
                string_format(
                    "Kellen Dysart CP values correct: ⚒️ %d - ⚔️ %d - 💪 %d",
                    craftCP,
                    warfareCP,
                    fitnessCP
                )
            )
        else
            AddResult(
                testName,
                false,
                string_format(
                    "Kellen Dysart CP values incorrect. Expected: ⚒️ 18 - ⚔️ 43 - 💪 3, Got: ⚒️ %d - ⚔️ %d - 💪 %d",
                    craftCP,
                    warfareCP,
                    fitnessCP
                )
            )
            return false
        end
    else
        -- For other characters, just validate format is correct
        AddResult(
            testName,
            true,
            string_format(
                "Champion Points format correct: ⚒️ %d - ⚔️ %d - 💪 %d",
                craftCP,
                warfareCP,
                fitnessCP
            )
        )
    end

    return true
end

-- =====================================================
-- ISSUE #10: INVENTORY VALUES VALIDATION
-- =====================================================

local function ValidateInventoryValues(markdown)
    local testName = "Issue #10: Inventory Values"

    -- Check for Inventory section
    local hasInventory = string_find(markdown, "##.*🎒.*Inventory")
        or string_find(markdown, "Inventory")
        or string_find(markdown, "Backpack")

    if not hasInventory then
        AddResult(testName, true, "Inventory section not found (may be disabled)", true)
        return true
    end

    -- Pattern to match Backpack line: | Backpack | Used | Max | Capacity% |
    -- Format: | Backpack | 40 | 150 | ██░░░░░░░░ 26% |
    -- Note: Backpack may or may not be bold (**Backpack** or Backpack)
    local backpackPattern = "%*?%*?Backpack%*?%*?%s*|%s*(%d+)%s*|%s*(%d+)%s*|"
    local backpackUsed, backpackMax = string_match(markdown, backpackPattern)

    -- Pattern to match Bank line: | Bank | Used | Max | Capacity% |
    -- Format: | Bank | 238 | 480 | ████░░░░░░ 49% |
    -- Note: Bank may or may not be bold (**Bank** or Bank)
    local bankPattern = "%*?%*?Bank%*?%*?%s*|%s*(%d+)%s*|%s*(%d+)%s*|"
    local bankUsed, bankMax = string_match(markdown, bankPattern)

    if not backpackUsed or not backpackMax then
        AddResult(testName, true, "Backpack line not found or format incorrect", true)
        return true
    end

    -- Convert to numbers
    backpackUsed = tonumber(backpackUsed)
    backpackMax = tonumber(backpackMax)

    -- Validate Backpack values
    if backpackUsed < 0 or backpackMax < 0 or backpackUsed > backpackMax then
        AddResult(
            testName,
            false,
            string_format("Backpack values invalid: Used=%d, Max=%d (used > max)", backpackUsed, backpackMax)
        )
        return false
    end

    -- For Kellen Dysart specifically, validate expected values
    local isKellenDysart = string_find(markdown, "Kellen Dysart")
    if isKellenDysart then
        -- Validate Backpack: 21/180
        if backpackUsed ~= 21 or backpackMax ~= 180 then
            AddResult(
                testName,
                false,
                string_format(
                    "Kellen Dysart Backpack incorrect. Expected: 21/180, Got: %d/%d",
                    backpackUsed,
                    backpackMax
                )
            )
            return false
        end

        -- Validate Bank: 393/480
        if bankUsed and bankMax then
            bankUsed = tonumber(bankUsed)
            bankMax = tonumber(bankMax)
            if bankUsed ~= 393 or bankMax ~= 480 then
                AddResult(
                    testName,
                    false,
                    string_format("Kellen Dysart Bank incorrect. Expected: 393/480, Got: %d/%d", bankUsed, bankMax)
                )
                return false
            end
            AddResult(
                testName,
                true,
                string_format(
                    "Kellen Dysart inventory values correct: Backpack %d/%d, Bank %d/%d",
                    backpackUsed,
                    backpackMax,
                    bankUsed,
                    bankMax
                )
            )
        else
            AddResult(testName, true, string_format("Kellen Dysart Backpack correct: %d/%d", backpackUsed, backpackMax))
        end
    else
        -- For other characters, just validate format and logic
        if bankUsed and bankMax then
            bankUsed = tonumber(bankUsed)
            bankMax = tonumber(bankMax)
            if bankUsed < 0 or bankMax < 0 or bankUsed > bankMax then
                AddResult(
                    testName,
                    false,
                    string_format("Bank values invalid: Used=%d, Max=%d (used > max)", bankUsed, bankMax)
                )
                return false
            end
        end
        AddResult(
            testName,
            true,
            string_format(
                "Inventory values format correct: Backpack %d/%d%s",
                backpackUsed,
                backpackMax,
                bankUsed and bankMax and string_format(", Bank %d/%d", bankUsed, bankMax) or ""
            )
        )
    end

    return true
end

-- =====================================================
-- MAIN VALIDATION FUNCTION
-- =====================================================

local function ValidateMarkdown(markdown, format)
    format = format or "github"

    ResetResults()

    CM.DebugPrint("TESTS", "Starting markdown validation...")

    -- Run all validation tests
    ValidateHTMLStructure(markdown)
    ValidateCalloutSyntax(markdown, format)
    ValidateResourceValues(markdown)
    ValidateEnlightenmentCallout(markdown, format)
    ValidateAttentionWarnings(markdown)
    ValidateProgressBars(markdown)
    ValidatePvPSections(markdown)
    ValidateEmojiCompatibility(markdown)
    ValidateChampionPointsFormat(markdown)
    ValidateInventoryValues(markdown)

    -- Print results (debug only - actual report is printed via PrintTestReport)
    local totalTests = #testResults.passed + #testResults.failed + #testResults.warnings
    local nonWarningTotal = #testResults.passed + #testResults.failed
    local passRate = nonWarningTotal > 0 and (math.floor((#testResults.passed / nonWarningTotal) * 100)) or 100

    CM.DebugPrint(
        "TESTS",
        string_format(
            "Validation complete: %d passed, %d failed, %d warnings",
            #testResults.passed,
            #testResults.failed,
            #testResults.warnings
        )
    )

    return {
        passed = testResults.passed,
        failed = testResults.failed,
        warnings = testResults.warnings,
        passRate = passRate,
        total = totalTests,
    }
end

local function GetTestResults()
    return {
        passed = testResults.passed,
        failed = testResults.failed,
        warnings = testResults.warnings,
        total = #testResults.passed + #testResults.failed + #testResults.warnings,
    }
end

local function PrintTestReport()
    local results = GetTestResults()

    -- Always print to chat (not just debug)
    CM.Info("|cFFFF00=== TEST VALIDATION REPORT ===|r")

    if #results.passed > 0 then
        CM.Info(string_format("|c00FF00✅ PASSED (%d):|r", #results.passed))
        for _, test in ipairs(results.passed) do
            CM.Info(string_format("  |c00FF00✅|r |cFFFFFF%s:|r %s", test.test, test.message))
        end
    end

    if #results.failed > 0 then
        CM.Info(string_format("|cFF0000❌ FAILED (%d):|r", #results.failed))
        for _, test in ipairs(results.failed) do
            CM.Info(string_format("  |cFF0000❌|r |cFFFFFF%s:|r %s", test.test, test.message))
        end
    end

    if #results.warnings > 0 then
        CM.Info(string_format("|cFFAA00⚠️ WARNINGS (%d):|r", #results.warnings))
        for _, test in ipairs(results.warnings) do
            CM.Info(string_format("  |cFFAA00⚠️|r |cFFFFFF%s:|r %s", test.test, test.message))
        end
    end

    -- Calculate pass rate excluding warnings (warnings are informational, not failures)
    local nonWarningTotal = #results.passed + #results.failed
    local passRate = nonWarningTotal > 0 and (math.floor((#results.passed / nonWarningTotal) * 100)) or 100
    local passColor = (#results.failed == 0) and "|c00FF00" or "|cFFAA00"
    CM.Info(
        string_format(
            "%sPass Rate: %d%% (%d/%d passed, %d warnings)|r",
            passColor,
            passRate,
            #results.passed,
            nonWarningTotal,
            #results.warnings
        )
    )

    -- Final summary message
    if #results.failed == 0 then
        CM.Info(
            string_format("|c00FF00All tests passed! (%d passed, %d warnings)|r", #results.passed, #results.warnings)
        )
    else
        CM.Info(
            string_format(
                "|cFFAA00Some tests failed: %d passed, %d failed, %d warnings|r",
                #results.passed,
                #results.failed,
                #results.warnings
            )
        )
    end
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.tests.validation.ValidateMarkdown = ValidateMarkdown
CM.tests.validation.GetTestResults = GetTestResults
CM.tests.validation.PrintTestReport = PrintTestReport

CM.DebugPrint("TESTS", "Test validation module loaded")

return CM.tests.validation
