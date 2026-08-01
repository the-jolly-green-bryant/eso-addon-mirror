CurrentlyEquipped = CurrentlyEquipped or {}
local CE = CurrentlyEquipped
local LSD = LibSetDetection
local LS = LibSets
local lang = "en"
--Must stay 3000 so that on initial player load CE loads properly
--CE.delay = 3000

--DEBUG--
--function CE.DEBUG()
--    EVENT_MANAGER:RegisterForEvent(CE.name, EVENT_RETICLE_TARGET_CHANGED, CE.EquippedSetInfo)
--end

--Breaks table returned by GetEquippedSetsList() into 3 more manageable tables
function CE.OnSetUpdate()
    if not CE.show_UI then return end
    --d("OnSetUpdate")

    CE.equip_sets = LSD.GetEquippedSetsTable()

    --Reset tables for next UI update
    CE.set_names = {}
    CE.set_max_equip = {}
    CE.set_num_equip = {}
    CE.num_str = {}
    CE.set_ids = {}
    
    --setID -> setName, maxEquip, numEquip{}, table.insert(table, value)
    local temp_name
    local temp_max_equip
    for setID, info in pairs(CE.equip_sets) do
        table.insert(CE.set_ids, setID)
        --Crafted sets require LibSets as ZO_shallowTableCopy doesn't return their info properly
        if (info["name"] == "") then
            temp_name = LS.GetSetName(setID, lang)
            table.insert(CE.set_names, temp_name)
        else
            table.insert(CE.set_names, info["name"])                 
        end

        if (info["maxEquipped"] == 0) then 
            _, temp_max_equip, _ = LS.GetNumEquippedItemsBySetId(setID)
            table.insert(CE.set_max_equip, temp_max_equip)
        else
            table.insert(CE.set_max_equip, info["maxEquipped"]) 
        end

        --If body pieces, add them, if weapons, add highest value, otherwise double barred set will add front and back
        local tot_equip = 0
        local temp_bar = 0
        for loc, num_equip in pairs(info["numEquipped"]) do
            if loc == "body" then 
                tot_equip = tot_equip + num_equip
            elseif num_equip > temp_bar then -- >= ?
                tot_equip = (tot_equip + num_equip) - temp_bar
                temp_bar = num_equip
            end            
        end
        table.insert(CE.set_num_equip, tot_equip)
    end
    CE.FormatStrings()
    CE.UpdateUI()
end

--NOTE: need to reset num_str after use
function CE.FormatStrings()
    --init, max, step
    for i=1, table.getn(CE.set_names), 1 do
        table.insert(CE.num_str, CE.set_num_equip[i] .. "/" .. CE.set_max_equip[i])
    end
end 

function CE.UpdateUI()
    CE.ResetUI()

    if CE.show_UI then CEFrame:SetHidden(false) end

    for i=1, table.getn(CE.set_names), 1 do
        --local temp_table = StringEdit(CE.set_names[i], i)
        local format_name = zo_strformat(SI_ABILITY_NAME, CE.set_names[i])

        CE.rows[i].nums:SetText(CE.num_str[i])
        CE.rows[i].names:SetText(format_name)    
        
        if (CE.set_num_equip[i] == CE.set_max_equip[i]) then
            CE.rows[i].nums:SetColor(unpack(CE.comp_color))
            CE.rows[i].names:SetColor(unpack(CE.comp_color))

        elseif (CE.set_num_equip[i] > CE.set_max_equip[i]) or (LS.IsMonsterSet(CE.set_ids[i])) then
            CE.rows[i].nums:SetColor(unpack(CE.warn_color))
            CE.rows[i].names:SetColor(unpack(CE.warn_color))
        else
            CE.rows[i].nums:SetColor(unpack(CE.incomp_color))
            CE.rows[i].names:SetColor(unpack(CE.incomp_color))
        end

        CE.rows[i].enabled = true
        CE.rows[i]:SetHidden(false)
    end
    CEFrameTitle:SetColor(unpack(CE.head_color))
end