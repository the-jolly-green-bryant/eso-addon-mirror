--[[
    Traveller by Patrick Smyth
    
    This module is what remains of a sub-project of Traveller which was to make the output of
    tables more visually cohesive. The idea was to make a table look more like a spreadsheet
    using a combination of a symbolic font and a fixed-width font. However, the ZOS API does
    not appear to be capable of on-the-fly font changes.

--]]

Tab = { }

-- ==========================================================================================
--
--  Local variables
--

local l_EmptyWorkTab = { rowCount = 0,
                            title = "",
                            header1 = "",
                            header2 = "",
                            rows = { } }

-- ==========================================================================================
--
--  External Interface
--

function Tab:Start()
    local workTab = { }

    ZO_DeepTableCopy(l_EmptyWorkTab, workTab)

    return workTab
end

function Tab:Title(workTab, titleStr)
    workTab.title = Utils:Trim(titleStr)
end

function Tab:ColumnHeaders(workTab, header1Str, header2Str)
    workTab.header1 = Utils:Trim(header1Str)
    workTab.header2 = Utils:Trim(header2Str)
end

function Tab:AddRow(workTab, rowKey, rowValue)
    local keyStr = ""
    local itemStr = ""

    workTab.rowCount = (workTab.rowCount) + 1

    keyStr = Utils:Trim(rowKey)
    if keyStr == "" then
        keyStr = tostring(workTab.rowCount)
    end

    itemStr = Utils:Trim(rowValue)

    workTab.rows[keyStr] = itemStr
end

function Tab:PrintTab(workTab)
    d(workTab.title)
    d(" ")
    d(workTab.header1 .. " = " .. workTab.header2)

    for akey, avalue in pairs(workTab.rows) do
        d(akey .. " = " .. avalue)
    end

    d(workTab.header1 .. " = " .. workTab.header2)
    d("Entries: " .. tostring(workTab.rowCount))
end