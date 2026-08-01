local IFG = { name = "IFG" }
local isLinked = false

-- 1. THE SEARCH ENGINE
function IFG.Search(query)
    if not IFG_ResultsDisplay or not IFGSavedVariables then return end
    
    local q = query:lower()
    if #q < 3 then 
        IFG_ResultsDisplay:SetText("Type at least 3 letters...")
        return 
    end

    local db = IFGSavedVariables["$AccountWide"]
    local found = {}

    if db.bank then
        for name, qty in pairs(db.bank) do
            if name:lower():find(q, 1, true) then
                table.insert(found, "|c00FFFF[Bank]|r " .. name .. " (x" .. qty .. ")")
            end
        end
    end

    if db.inventory then
        for char, items in pairs(db.inventory) do
            for name, qty in pairs(items) do
                if name:lower():find(q, 1, true) then
                    table.insert(found, "|cEECA2A["..char.."]|r " .. name .. " (x" .. qty .. ")")
                end
            end
        end
    end

    if #found > 0 then
        IFG_ResultsDisplay:SetText(table.concat(found, "\n"))
    else
        IFG_ResultsDisplay:SetText("|cFF0000No items found for: |r" .. query)
    end
end

-- 2. THE SCANNER
function IFG.Scan()
    local char = GetUnitName("player")
    
    if not IFGSavedVariables then IFGSavedVariables = {} end
    if not IFGSavedVariables["$AccountWide"] then IFGSavedVariables["$AccountWide"] = {} end
    if not IFGSavedVariables["$AccountWide"].inventory then IFGSavedVariables["$AccountWide"].inventory = {} end
    if not IFGSavedVariables["$AccountWide"].bank then IFGSavedVariables["$AccountWide"].bank = {} end

    local db = IFGSavedVariables["$AccountWide"]
    db.inventory[char] = {}

    for i = 0, GetBagSize(1) do
        local name = GetItemName(1, i)
        if name and name ~= "" then
            local _, stack = GetItemInfo(1, i)
            local cleanName = zo_strformat("<<t:1>>", name)
            db.inventory[char][cleanName] = stack
        end
    end
end

-- 3. INITIALIZATION
function IFG.OnLoad(event, addon)
    if addon ~= IFG.name then return end
    
    IFGSavedVariables = IFGSavedVariables or { ["$AccountWide"] = { inventory = {}, bank = {} } }
    IFG.Scan()

    SLASH_COMMANDS["/ifg"] = function() 
        if _G["IFG_GUI"] then 
            if not isLinked then
                IFG_SearchInput:SetHandler("OnTextChanged", function(self) IFG.Search(self:GetText()) end)
                isLinked = true
            end
            IFG_GUI:SetHidden(false)
            SCENE_MANAGER:SetInUIMode(true) 
            IFG_SearchInput:TakeFocus()
            IFG_ResultsDisplay:SetText("Ready to search inventory...")
        else
            d("|cFF0000[IFG] UI Error: IFG_GUI not registered.|r")
        end
    end

    d("|c00FF00[IFG] v1.0 Loaded. Type /ifg to begin.|r")
end

EVENT_MANAGER:RegisterForEvent("IFG_LOAD", EVENT_ADD_ON_LOADED, function(event, addon) IFG.OnLoad(event, addon) end)