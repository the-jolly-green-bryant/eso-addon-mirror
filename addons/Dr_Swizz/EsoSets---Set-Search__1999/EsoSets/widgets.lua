function CreateDropdown(displayName,parentControl,tableOfOptions,onItemSelectedCallback)
    --[[
    local function ItemSelectCallback(comboBox, itemName, item, selectionChanged)
        d(itemName)
        -- Do whatever
    end
    --]]

    local comboBox = WINDOW_MANAGER:CreateControlFromVirtual("Esosets"..displayName, parentControl, "ZO_ComboBox")
    comboBox:SetDimensions(250, 30)
    comboBox:ClearAnchors()
    comboBox:SetAnchor(TOPLEFT, wrapper, TOPLEFT, 0, 0)

    -- tooltip text
    comboBox.data = { tooltipText = "" }

    -- tooltip handlers
    comboBox:SetHandler("OnMouseEnter", ZO_Options_OnMouseEnter)
    comboBox:SetHandler("OnMouseExit", ZO_Options_OnMouseExit)

    local m_comboBox = comboBox.m_comboBox
    m_comboBox:SetSortsItems(false)

    m_comboBox:ClearItems()



    --===============================================================--
    --====== Population Code  ============--
    --===============================================================--
    for k,name in ipairs(tableOfOptions) do
        local itemEntry = m_comboBox:CreateItemEntry(name, onItemSelectedCallback)

        -- suppress update until were done adding items
        m_comboBox:AddItem(itemEntry, ZO_COMBOBOX_SUPRESS_UPDATE)
    end
    --===============================================================--

    -- Update & select first item
    m_comboBox:UpdateItems()
    m_comboBox:SelectFirstItem()

    return comboBox
end

