windexAddon.buildMenuOptions("Item Condition Alert", "itemConditionAlert", "baseAddons")

function windexAddon.pluginLoadFunctions.itemConditionAlert(noToggleCall)
  if not ItemConditionAlertTopControl then return end

  if windexAddonDB.itemConditionAlert and not windexAddon.itemConditionAlertHook then
    windexAddon.itemConditionAlertHook = ItemConditionAlert.Show

    function ItemConditionAlert:Show()
      if (not windexAddonDB.isDisabled and windexAddonDB.itemConditionAlert) then return end

      ItemConditionAlertTopControl:SetHidden(false)
    end

  elseif windexAddon.itemConditionAlertHook and not windexAddonDB.itemConditionAlert then
    ItemConditionAlertTopControl:SetHidden(false)

    ItemConditionAlert.Show            = windexAddon.itemConditionAlertHook
    windexAddon.itemConditionAlertHook = nil
  end

  if not noToggleCall then ItemConditionAlertTopControl:SetHidden((not windexAddonDB.isDisabled and windexAddonDB.itemConditionAlert) and true or false) end
end

function windexAddon.pluginToggleFunctions.itemConditionAlert()
  if not ItemConditionAlertTopControl then return end

  if windexAddonDB.itemConditionAlert and not windexAddon.itemConditionAlertHook then
    windexAddon.pluginLoadFunctions.itemConditionAlert(true)
  end

  ItemConditionAlertTopControl:SetHidden((not windexAddonDB.isDisabled and windexAddonDB.itemConditionAlert) and true or false)
end

windexAddon.pluginFocusFunctions.itemConditionAlert = windexAddon.pluginToggleFunctions.itemConditionAlert
windexAddon.pluginPushFunctions.itemConditionAlert  = windexAddon.pluginToggleFunctions.itemConditionAlert
windexAddon.pluginPopFunctions.itemConditionAlert   = windexAddon.pluginToggleFunctions.itemConditionAlert