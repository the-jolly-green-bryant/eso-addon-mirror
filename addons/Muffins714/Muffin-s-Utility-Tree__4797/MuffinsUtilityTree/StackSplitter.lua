-- Create a local shortcut for global
local MUT = MuffinsUtilityTree

---------------------------------------------------------------------------------------------
-- Multi Split
---------------------------------------------------------------------------------------------
-- StackSplitterDialog.xml creates the control
local MUT_MULTI_SPLIT_DIALOG = "MUT_GAMEPAD_MULTI_SPLIT"

local multiSplitSelector = nil

local function ExecuteMultiSplit(bagId, slotIndex, splitSize)
    if not splitSize or splitSize <= 0 then return end

    local startingStackSize = GetSlotStackSize(bagId, slotIndex)
    if not startingStackSize or startingStackSize <= splitSize then return end

    -- Compute splits
    local numSplits = zo_floor(startingStackSize / splitSize)
    -- Leave at least 1 item in the original stack
    if startingStackSize % splitSize == 0 then
        numSplits = numSplits - 1
    end

    -- Reserve empty slots first so each split goes to a different slot
    local destSlots = {}
    for i = 0, GetBagSize(bagId) - 1 do
        if #destSlots >= numSplits then break end
        if i ~= slotIndex and not GetItemInstanceId(bagId, i) then
            destSlots[#destSlots + 1] = i
        end
    end
    if #destSlots < numSplits then
        d(string.format(GetString(MUT_MULTI_SPLITTER_ERROR),
            #destSlots, numSplits))
        numSplits = #destSlots
    end
    for i = 1, numSplits do
        CallSecureProtected("PickupInventoryItem", bagId, slotIndex, splitSize)
        CallSecureProtected("PlaceInInventory", bagId, destSlots[i])
    end
end

-- Called from StackSplitterDialog.xml's OnInitialized
function MUT_MultiSplitDialog_Gamepad_OnInitialized(self)
    ZO_GenericGamepadDialog_OnInitialized(self)

    local selectorControl = self:GetNamedChild("Selector")
    if not selectorControl then
        return
    end

    multiSplitSelector = ZO_CurrencySelector_Gamepad:New(selectorControl)
    -- Currency type is only used to keep narration safe but this isnt money
    multiSplitSelector:SetCurrencyType(CURT_MONEY)
    multiSplitSelector:SetClampValues(true)

    -- Real split cap changes per item, clamp manually because display max stays 199
    local currentItemMaxSplitSize = 199
    local isClampingValue = false

    multiSplitSelector:RegisterCallback("OnValueChanged", function()
        if isClampingValue then return end
        local value = multiSplitSelector:GetValue()
        if value > currentItemMaxSplitSize then
            isClampingValue = true
            multiSplitSelector:SetValue(currentItemMaxSplitSize)
            isClampingValue = false
        end
    end)

    ZO_Dialogs_RegisterCustomDialog(MUT_MULTI_SPLIT_DIALOG,
        {
            customControl = self,
            canQueue = true,

            gamepadInfo =
            {
                dialogType = GAMEPAD_DIALOGS.CUSTOM,
            },

            setup = function(dialog, data)
                -- Fixed max keeps the selector at 3 digits for every item
                multiSplitSelector:SetMaxValue(199)
                currentItemMaxSplitSize = data.sliderMax
                multiSplitSelector:SetValue(data.sliderStartValue)
                multiSplitSelector:Activate()
                dialog:setupFunc()
            end,

            finishedCallback = function(dialog)
                multiSplitSelector:Deactivate()
            end,

            title =
            {
                text = MUT_MULTI_SPLITTER_TITLE,
            },

            mainText =
            {
                text = MUT_MULTI_SPLITTER_PROMPT,
            },

            buttons =
            {
                {
                    keybind = "DIALOG_NEGATIVE",
                    text = GetString(SI_DIALOG_CANCEL),
                },
                {
                    keybind = "DIALOG_PRIMARY",
                    text = GetString(SI_GAMEPAD_SELECT_OPTION),
                    callback = function(dialog)
                        local dialogData = dialog.data
                        local splitSize = multiSplitSelector:GetValue()
                        ExecuteMultiSplit(dialogData.bagId, dialogData.slotIndex, splitSize)
                    end,
                },
            }
        })
end

---------------------------------------------------------------------------------------------
-- Slot action hook
---------------------------------------------------------------------------------------------
-- Adds the Multi Split action after the game's normal item actions
local function OnDiscoverSlotActions(inventorySlot, slotActions)
    if not IsInGamepadPreferredMode() then return end

    local settings = MUT.GetSettings()
    if not settings.splitterEnabled then return end

    if not ZO_InventorySlot_IsSplittableType(inventorySlot) then return end
    if not ZO_InventorySlot_CanSplitItemStack(inventorySlot) then return end

    local bagId, slotIndex = ZO_Inventory_GetBagAndIndex(inventorySlot)
    local stackSize = GetSlotStackSize(bagId, slotIndex)
    if not stackSize or stackSize <= 1 then return end

    slotActions:AddSlotAction(
        MUT_MULTI_SPLITTER_ACTION_NAME,
        function()
            ZO_Dialogs_ShowGamepadDialog(MUT_MULTI_SPLIT_DIALOG, {
                bagId = bagId,
                slotIndex = slotIndex,
                stackSize = stackSize,
                -- Cap at stack at -1 and 199, start at 0 so the player picks the size
                sliderMax = zo_min(stackSize - 1, 199),
                sliderStartValue = 0,
            })
        end,
        "secondary"
    )
end

---------------------------------------------------------------------------------------------
-- Initialization
---------------------------------------------------------------------------------------------
function MUT_Initialize_MultiSplitter()
    SecurePostHook("ZO_InventorySlot_DiscoverSlotActionsFromActionList", OnDiscoverSlotActions)
end
