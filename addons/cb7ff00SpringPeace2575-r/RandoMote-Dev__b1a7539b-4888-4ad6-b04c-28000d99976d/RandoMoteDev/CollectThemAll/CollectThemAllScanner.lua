-----------------------------------------------------------
-- Author: SpringPeace2575 | Version: 0.9.0
-- Scanner helpers for CollectThemAll add-on
-----------------------------------------------------------

CollectThemAllScanner = CollectThemAllScanner or {}
local CTAScanner = CollectThemAllScanner
local CTAData = CollectThemAllData

CTAScanner.defaultBatchSize = 10
CTAScanner.collectionItems = {}
CTAScanner.outputLines = {}
CTAScanner.outputIndex = 1
CTAScanner.lastScan = nil

local function AddOutputLine(line)
    CTAScanner.outputLines[#CTAScanner.outputLines + 1] = line
end

local function ResetOutput()
    CTAScanner.outputLines = {}
    CTAScanner.outputIndex = 1
end

function CTAScanner.BuildOutputLines(collectibleItems)
    ResetOutput()

    for _, collectibleItem in ipairs(collectibleItems) do
        local fragmentsCount = 0
        local fragmentsUnlockedCount = 0
        if collectibleItem.fragments then
            fragmentsCount = #collectibleItem.fragments
            for _, fragment in ipairs(collectibleItem.fragments) do
                if fragment.unlocked then
                    fragmentsUnlockedCount = fragmentsUnlockedCount + 1
                end
            end
        end
        local fragmentsOutput = ""
        if fragmentsCount > 0 then
            fragmentsOutput = string.format(" - (%d / %d)", fragmentsUnlockedCount, fragmentsCount)
        end
        AddOutputLine(string.format(
            "CTA: [%d - %d] %s [%s%s]",
            collectibleItem.ix,
            collectibleItem.id,
            tostring(collectibleItem.name),
            collectibleItem.unlocked and "Y" or "N",
            fragmentsOutput
        ))
    end
end

function CTAScanner.PrintNextBatch(batchSize)
    batchSize = tonumber(batchSize) or CTAScanner.defaultBatchSize
    if batchSize < 1 then
        batchSize = CTAScanner.defaultBatchSize
    end

    local total = #CTAScanner.outputLines
    if total == 0 then
        d("CTA: no output prepared. Use /cta s first.")
        return
    end

    if CTAScanner.outputIndex > total then
        d("CTA: end of output.")
        return
    end

    local startIndex = CTAScanner.outputIndex
    local endIndex = zo_min(startIndex + batchSize - 1, total)

    for i = startIndex, endIndex do
        d(CTAScanner.outputLines[i])
    end

    CTAScanner.outputIndex = endIndex + 1

    if CTAScanner.outputIndex <= total then
        d(string.format(
            "CTA: printed %d-%d / %d. Use /cta n [count].",
            startIndex,
            endIndex,
            total
        ))
    else
        d(string.format(
            "CTA: printed %d-%d / %d. End of output.",
            startIndex,
            endIndex,
            total
        ))
    end
end

function CTAScanner.VarToString(name, value)
	return " ; "..name..": "..tostring(value)
end

function CTAScanner.Scan()
    local collection = CTAData.groups[1].collection
    CTAScanner.collectionItems = {}
    local fragmentsMap = {}

    for _, items in pairs(collection) do
        for _, item in ipairs(items) do
            if item.fragments then
                for _, fragment in ipairs(item.fragments) do
                    fragmentsMap[fragment] = { name = fragment, unlocked = false }
                end
            end
        end
    end

    local categoryType = COLLECTIBLE_CATEGORY_TYPE_COMBINATION_FRAGMENT
    for i = 1, GetTotalCollectiblesByCategoryType(categoryType) do
        local collectibleId = GetCollectibleIdFromType(categoryType, i)
        -- local isUnlocked = IsCollectibleUnlocked(collectibleId)
        -- if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
        -- if id and IsCollectibleUnlocked(collectibleId) then table.insert(available, collectibleId) end
        local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)

        for fragmentName, fragment in pairs(fragmentsMap) do
            if string.find(name, fragmentName) then
                fragment.ix = i
                fragment.id = collectibleId
                fragment.unlocked = unlocked
            end
        end
    end

    for categoryType, items in pairs(collection) do
        for i = 1, GetTotalCollectiblesByCategoryType(categoryType) do
            local collectibleId = GetCollectibleIdFromType(categoryType, i)
            -- local isUnlocked = IsCollectibleUnlocked(collectibleId)
            -- if GetCollectibleCategoryType(collectibleId) ~= COLLECTIBLE_CATEGORY_TYPE_MEMENTO then return end
            -- if id and IsCollectibleUnlocked(collectibleId) then table.insert(available, collectibleId) end
            local name, _, _, _, unlocked = GetCollectibleInfo(collectibleId)

            for _, item in ipairs(items) do
                if string.find(name, item.name) then
                    local collectionItem = {
                        ix = i,
                        id = collectibleId,
                        name = name,
                        unlocked = unlocked,
                    }
                    if not unlocked then
                        local fragments = {}
                        if item.fragments then
                            for _, fragment in ipairs(item.fragments) do
                                table.insert(fragments, fragmentsMap[fragment] or {})
                            end
                            collectionItem.fragments = fragments
                        end
                    end
                    table.insert(CTAScanner.collectionItems, collectionItem)
                end
            end
        end
    end

    d(string.format("CTA: Found %d collectible items", #CTAScanner.collectionItems))
    d("CTA: Use /cta n or /cta n [count] to continue output.")
    CTAScanner.BuildOutputLines(CTAScanner.collectionItems)
end

function CTAScanner.ResetCursor()
    CTAScanner.outputIndex = 1
    d("CTA: output cursor reset. Use /cta next [count].")
end
