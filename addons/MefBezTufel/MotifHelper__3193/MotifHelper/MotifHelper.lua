MotifHelper = {}

MotifHelper.name = "MotifHelper"
MotifHelper.slashcmd = "/motif"

local libScroll = LibScroll

function MotifHelper.CreateData()
    local motifsData = {}
    local categoryIndex = GetLoreBookCategoryIndexFromCategoryId(4)
    local _, numCollections = GetLoreCategoryInfo(categoryIndex)
    for collectionIndex = 1, numCollections do
        local collectionName, _, known, total, _, _, collectionId = GetLoreCollectionInfo(categoryIndex, collectionIndex)
        if known < total and collectionId ~= 43 then
            local missingPages = {[1] = GetString(SI_MOTIF_HELPER_LEFT_PAGES)}
            for bookIndex = 1, total do
                local bookName, _, isKnown = GetLoreBookInfo(categoryIndex, collectionIndex, bookIndex)
                if not isKnown then
                    local start = string.find(bookName, ":")
                    table.insert(missingPages, string.sub(bookName, start + 2))
                end
            end
            table.insert(motifsData, {name = collectionName, pagesLeft = total - known, pages = missingPages})
        end
    end

    table.sort(
        motifsData,
        function(a, b)
            return a.pagesLeft == b.pagesLeft
                and a.name < b.name
                or a.pagesLeft < b.pagesLeft
        end
    )

    return motifsData
end

function MotifHelper.SetupDataRow(rowControl, data, scrollList)
    local text = ZO_CachedStrFormat(GetString(SI_MOTIF_HELPER_PAGES_LEFT_FORMAT), data.name, data.pagesLeft)

    rowControl:SetText(text)
    rowControl:SetFont("ZoFontWinH4")
    rowControl:SetHandler(
        "OnMouseEnter",
        function(self)
            ZO_Tooltips_ShowTextTooltip(self, BOTTOM, table.concat(data.pages, "\n    "))
        end
    )

    rowControl:SetHandler(
        "OnMouseExit",
        function(self)
            ZO_Tooltips_HideTextTooltip()
        end
    )
end

function MotifHelper.ShowWindow()
    MotifHelper.scrollList:Update(MotifHelper.CreateData())

    MotifHelperWindow:SetHidden(false)
end

function MotifHelper.HideWindow()
    MotifHelperWindow:SetHidden(true)
end

function MotifHelper.Initialize()
    SLASH_COMMANDS[MotifHelper.slashcmd] = function(param)
        MotifHelper.ShowWindow()
    end

    MotifHelper.scrollData = {
        name = "MotifsList",
        parent = MotifHelperWindow,
        setupCallback = MotifHelper.SetupDataRow
    }

    MotifHelper.scrollList = libScroll:CreateScrollList(MotifHelper.scrollData)
    MotifHelper.scrollList:SetAnchor(TOPLEFT, motifHelperWindow, TOPLEFT, 5, 45)
    MotifHelper.scrollList:SetAnchor(BOTTOMRIGHT, motifHelperWindow, BOTTOMRIGHT, -5, -5)
end

function MotifHelper.OnAddOnLoaded(event, addonName)
    if addonName == MotifHelper.name then
        MotifHelper.Initialize()
    end
end

EVENT_MANAGER:RegisterForEvent(MotifHelper.name, EVENT_ADD_ON_LOADED, MotifHelper.OnAddOnLoaded)
