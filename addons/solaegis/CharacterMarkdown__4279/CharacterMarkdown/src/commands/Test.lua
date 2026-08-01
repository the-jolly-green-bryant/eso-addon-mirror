-- CharacterMarkdown - Test Command Handlers
-- Diagnostic tests, validation, and layout tests

local CM = CharacterMarkdown
CM.commands = CM.commands or {}
CM.commands.test = {}

-- =====================================================
-- MAIN TEST HANDLER
-- =====================================================

local function HandleTest(args)
    CM.Info("=== CharacterMarkdown Diagnostic & Validation ===")
    CM.Info(" ")

    -- ================================================
    -- PHASE 1: SETTINGS DIAGNOSTIC
    -- ================================================
    CM.Info("|cFFD700[1/4] Settings Diagnostic|r")
    CM.Info(" ")

    if not CharacterMarkdownSettings then
        CM.Error("CharacterMarkdownSettings is NIL!")
        CM.Info("  This means your settings aren't being saved")
        CM.Info("  Try: /reloadui")
        return
    end
    CM.Success("✓ CharacterMarkdownSettings exists")

    if not CM.GetSettings then
        CM.Error("✗ CM.GetSettings() not available")
        return
    end
    CM.Success("✓ CM.GetSettings() available")

    local criticalSettings = {
        "includeChampionPoints",
        "includeChampionDiagram",
        "includeSkillBars",
        "includeSkills",
        "includeEquipment",
        "includeCompanion",
        "includeCurrency",
        "includeInventory",
        "includeCollectibles",
        "includeQuickStats",
        "includeTableOfContents",
    }

    CM.Info(" ")
    CM.Info("Critical Setting Values:")
    local merged = CM.GetSettings()
    local hasMismatch = false

    for _, setting in ipairs(criticalSettings) do
        local raw = CharacterMarkdownSettings[setting]
        local merged_val = merged[setting]

        if raw ~= merged_val then
            CM.Info(
                string.format(
                    "  |cFFFF00⚠ %s = %s (raw) vs %s (merged)|r",
                    setting,
                    tostring(raw),
                    tostring(merged_val)
                )
            )
            hasMismatch = true
        else
            local color = raw == true and "|c00FF00" or "|cFF0000"
            CM.Info(string.format("  %s%s = %s|r", color, setting, tostring(raw)))
        end
    end

    if hasMismatch then
        CM.Info(" ")
        CM.DebugPrint("TEST", "⚠ Settings merge has mismatches - this may cause issues")
        CM.Warn("|cFFAA00⚠ Settings merge has mismatches - this may cause issues|r")
    else
        CM.Info(" ")
        CM.Success("✓ Settings merge working correctly")
    end

    -- ================================================
    -- PHASE 2: DATA COLLECTION TEST
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[2/4] Data Collection Test|r")

    if CM.collectors and CM.collectors.CollectChampionPointData then
        local success, cpData = pcall(CM.collectors.CollectChampionPointData)
        if success and cpData then
            CM.Success("✓ Champion Points data collected")
            CM.Info(
                string.format(
                    "  Total: %d | Spent: %d | Available: %d",
                    cpData.total or 0,
                    cpData.spent or 0,
                    (cpData.total or 0) - (cpData.spent or 0)
                )
            )

            if cpData.disciplines and #cpData.disciplines > 0 then
                CM.Info(string.format("  Disciplines: %d", #cpData.disciplines))
                for _, disc in ipairs(cpData.disciplines) do
                    local skillCount = 0
                    if disc.allStars then
                        skillCount = #disc.allStars
                    elseif disc.slottableSkills and disc.passiveSkills then
                        skillCount = #disc.slottableSkills + #disc.passiveSkills
                    end
                    CM.Info(
                        string.format("    %s: %d CP, %d skills", disc.name or "Unknown", disc.total or 0, skillCount)
                    )
                end
            else
                CM.Warn("  ⚠ No disciplines data")
            end
        else
            CM.Error("✗ Failed to collect CP data: " .. tostring(cpData))
        end
    else
        CM.Error("✗ CollectChampionPointData not available")
    end

    -- ================================================
    -- PHASE 3: MARKDOWN GENERATION TEST
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[3/4] Markdown Generation Test|r")

    if not CM.tests or not CM.tests.validation then
        CM.Error("✗ Test validation module not loaded")
        return
    end

    local testFormatter = CM.currentFormatter or "markdown"
    CM.Info(string.format("Generating %s formatter with current settings...", testFormatter))

    local success, markdown = pcall(function()
        return CM.formatters.GenerateMarkdown()
    end)

    if not success or not markdown then
        CM.Error("✗ Failed to generate markdown: " .. tostring(markdown))
        return
    end

    local isChunksArray = type(markdown) == "table"
    local markdownString = markdown
    if isChunksArray then
        CM.Info(string.format("  Generated %d chunks", #markdown))
        local fullMarkdown = ""
        for _, chunk in ipairs(markdown) do
            fullMarkdown = fullMarkdown .. chunk.content
        end
        markdownString = fullMarkdown
    end

    CM.Info(string.format("  Total size: %d chars", #markdownString))

    local testSettings = {}
    if CharacterMarkdownSettings then
        for key, value in pairs(CharacterMarkdownSettings) do
            if type(value) ~= "function" and key:sub(1, 1) ~= "_" then
                testSettings[key] = value
            end
        end
    end

    -- ================================================
    -- PHASE 4: VALIDATION TESTS
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[4/4] Validation Tests|r")

    local validationResults = CM.tests.validation.ValidateMarkdown(markdownString, testFormatter)

    local sectionResults = nil
    if CM.tests and CM.tests.sectionPresence then
        sectionResults = CM.tests.sectionPresence.ValidateSectionPresence(markdownString, testFormatter, testSettings)
    end

    CM.tests.validation.PrintTestReport()

    -- ================================================
    -- PHASE 5: UNIT TESTS
    -- ================================================
    CM.Info(" ")
    CM.Info("|cFFD700[5/5] Unit Tests|r")

    if CM.tests.chunking then
        CM.tests.chunking.RunTests()
    else
        CM.Warn("Chunking tests not available")
    end

    if CM.tests.skillsSlots and CM.tests.skillsSlots.RunTests then
        CM.tests.skillsSlots.RunTests()
    else
        CM.Warn("Action bar slot tests not available")
    end

    if CM.tests.equipmentSetCount and CM.tests.equipmentSetCount.RunTests then
        CM.tests.equipmentSetCount.RunTests()
    else
        CM.Warn("Equipment set count tests not available")
    end

    if sectionResults and CM.tests.sectionPresence then
        CM.tests.sectionPresence.PrintSectionTestReport()
    end

    CM.Info(" ")
    CM.Info("=== Test Summary ===")

    local totalFailed = #validationResults.failed
    local totalWarnings = #validationResults.warnings
    if sectionResults then
        totalFailed = totalFailed + #sectionResults.failed
    end

    if totalFailed == 0 and totalWarnings == 0 then
        CM.Success(
            string.format(
                "✓ ALL TESTS PASSED! (%d validation, %d sections)",
                #validationResults.passed,
                sectionResults and #sectionResults.passed or 0
            )
        )
    elseif totalFailed == 0 then
        CM.Warn(string.format("⚠ Tests passed with %d warnings", totalWarnings))
    else
        CM.Error(
            string.format(
                "✗ TESTS FAILED: %d passed, %d failed, %d warnings",
                #validationResults.passed,
                totalFailed,
                totalWarnings
            )
        )
    end
    CM.Info("Tip: Run '/markdown' to see the actual generated output")
end

-- =====================================================
-- LAYOUT TEST HANDLER
-- =====================================================

local function HandleTestLayout(args)
    CM.Info("=== Layout Calculator Test Suite ===")
    CM.Info(" ")

    local LayoutCalculatorTests = CM.utils and CM.utils.LayoutCalculatorTests
    if LayoutCalculatorTests and LayoutCalculatorTests.RunAllTests then
        local success = LayoutCalculatorTests.RunAllTests()
        if success then
            CM.Success("All layout calculator tests passed!")
        else
            CM.DebugPrint("TEST", "Some layout calculator tests failed - see output above")
            CM.Warn("|cFFAA00⚠ Some layout calculator tests failed - see output above|r")
        end
    else
        CM.Error("LayoutCalculatorTests not loaded!")
        CM.Info("  Make sure the addon is fully initialized")
    end
end

-- =====================================================
-- EXPORTS
-- =====================================================

CM.commands.test.HandleTest = HandleTest
CM.commands.test.HandleTestLayout = HandleTestLayout

CM.DebugPrint("COMMANDS", "Test commands module loaded")
