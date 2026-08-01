local _n = "HyboremDaily"
local _r, _s, _f = false, 0, false

-- GLOBAL EXECUTOR (Visible to XML and LAM)
function HyboremJump(step)
    if not step or step == 0 then return end
    
    -- Safety check for database
    if not HyboremDaily_DB or not HyboremDaily_DB["step"..step] then 
        d("Hyborem: Please configure house settings in Addon Options!")
        return 
    end
    
    local c = HyboremDaily_DB["step"..step]
    if not c.houseId or c.houseId == 0 then 
        d("Hyborem: Invalid House ID for Step " .. step)
        return 
    end

    local currentZone = GetUnitZoneIndex("player")
    
    local function doJumpAction()
        if c.isOwn then 
            RequestJumpToHouse(c.houseId, c.outside)
        elseif not c.isOwn and c.owner ~= "" then 
            JumpToSpecificHouse(c.owner, c.houseId) 
        end
    end

    -- Initial jump attempt
    doJumpAction()
    
    -- Retry after 5 seconds if zone hasn't changed
    zo_callLater(function()
        if GetUnitZoneIndex("player") == currentZone then
            doJumpAction()
        end
    end, 5000)
end

local function OnEnd()
    local wr = 0
    for i = 1, 25 do 
        if IsValidQuestIndex(i) and GetJournalQuestType(i) == QUEST_TYPE_CRAFTING then 
            wr = wr + 1 
        end 
    end
    
    if _r then
        if _s == 1 and wr == 7 then 
            zo_callLater(function() HyboremJump(1) end, 1500)
        elseif _s == 2 and wr == 0 then 
            zo_callLater(function() HyboremJump(2) end, 1500) 
        end
        _r, _s = false, 0
    end
    if _f then 
        zo_callLater(function() HyboremJump(3) end, 1500) 
        _f = false 
    end
end

local function OnStart()
    local name = GetUnitName("interact")
    if not name then return end
    
    _r, _s, _f = false, 0, false
    if name:find("Consumables") or name:find("Equipment") then 
        _r, _s = true, 1
    elseif name:find("Delivery") or name:find("Quartermaster") or name:find("Writ") then 
        _r, _s = true, 2
    elseif name:find("Remains%-Silent") or name:find("Milczy-Cień") then 
        _f = true 
    end
end

function HyboremDaily_OnLoad(_, addon)
    if addon ~= _n then return end
    
    -- DB Initialization
    HyboremDaily_DB = HyboremDaily_DB or {}
    for i=1, 3 do
        local k = "step"..i
        if not HyboremDaily_DB[k] then
            HyboremDaily_DB[k] = {houseId=0, isOwn=true, owner="@hyboreminfernal", outside=true}
        end
    end

    -- Bindings Strings
    ZO_CreateStringId("SI_BINDING_NAME_HYBOREM_STEP1", "Jump: Step 1 (Boards)")
    ZO_CreateStringId("SI_BINDING_NAME_HYBOREM_STEP2", "Jump: Step 2 (Boxes)")
    ZO_CreateStringId("SI_BINDING_NAME_HYBOREM_STEP3", "Jump: Step 3 (Silent)")
    
    EVENT_MANAGER:RegisterForEvent(_n, EVENT_CHATTER_BEGIN, OnStart)
    EVENT_MANAGER:RegisterForEvent(_n, EVENT_CHATTER_END, OnEnd)
    
    zo_callLater(function()
        local LAM = LibAddonMenu2
        if not LAM then return end

        local names, ids = {}, {}
        for i=1, 1000 do 
            local id = GetCollectibleIdForHouse(i) 
            if id > 0 then 
                local n = GetCollectibleName(id) 
                table.insert(names, n) 
                ids[n] = i 
            end 
        end
        table.sort(names)

        local opts = {
            {type="description", text="|cFFFF00Automatic teleportation after interacting with boards, delivery boxes, or Remains-Silent.|r"},
            {type="header", name="|c00FF00Teleport Settings|r"}
        }

        for i=1, 3 do
            local k = "step"..i
            local label = (i==1 and "|c00FFFFStep 1 (After Boards)|r" or i==2 and "|c00FFFFStep 2 (After Delivery)|r" or "|c00FFFFStep 3 (After Remains-Silent)|r")
            
            table.insert(opts, {
                type = "submenu",
                name = label,
                controls = {
                    {
                        type = "checkbox",
                        name = "Own House",
                        getFunc = function() return HyboremDaily_DB[k].isOwn end,
                        setFunc = function(v) HyboremDaily_DB[k].isOwn = v end,
                    },
                    {
                        type = "editbox",
                        name = "Owner Name",
                        getFunc = function() return HyboremDaily_DB[k].owner end,
                        setFunc = function(v) HyboremDaily_DB[k].owner = v end,
                        disabled = function() return HyboremDaily_DB[k].isOwn end,
                    },
                    {
                        type = "dropdown",
                        name = "House Name",
                        choices = names,
                        getFunc = function() 
                            for n, id in pairs(ids) do 
                                if id == HyboremDaily_DB[k].houseId then return n end 
                            end 
                            return "Not Selected"
                        end,
                        setFunc = function(v) HyboremDaily_DB[k].houseId = ids[v] end,
                    },
                    {
                        type = "checkbox",
                        name = "Outside teleport",
                        getFunc = function() return HyboremDaily_DB[k].outside end,
                        setFunc = function(v) HyboremDaily_DB[k].outside = v end,
                        disabled = function() return not HyboremDaily_DB[k].isOwn end,
                    },
                    {
                        type = "button",
                        name = "Test Jump",
                        func = function() HyboremJump(i) end,
                    }
                }
            })
        end

        LAM:RegisterAddonPanel(_n.."Panel", {
            type = "panel", 
            name = "|c00FF00Hyborem Daily|r", 
            author = "Hyborem", 
            version = "1.2", 
            slashCommand = "/hyborem", 
            registerForRefresh = true
        })
        LAM:RegisterOptionControls(_n.."Panel", opts)
    end, 2000)
end

EVENT_MANAGER:RegisterForEvent(_n, EVENT_ADD_ON_LOADED, HyboremDaily_OnLoad)