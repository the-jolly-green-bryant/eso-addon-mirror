SaveEquip = {}
 
SaveEquip.name = "SaveEquip"

ZO_EquipItem = EquipItem

ZO_CreateStringId("SI_SAVE_EQUIP_CONFIRM_TITLE", "Equip Item")
ZO_CreateStringId("SI_SAVE_EQUIP_CONFIRM_EQUIP_BOE", "Equipping <<t:1>> will bind it to you. Continue?")
ZO_CreateStringId("SI_SAVE_EQUIP_EQUIP", "Equip")

local LAM = LibStub('LibAddonMenu-2.0')

function SaveEquip:Initialize()
    local defaults = {["enabled"] = true}

    local sv = ZO_SavedVars:New('SaveEquip_SavedVariables', 1, nil, defaults)

	local panelData = {
		type = "panel",
		name = "SaveEquip",
		displayName = "SaveEquip",
		author = "@nooblybear",
		version = "1.0.2",
		slashCommand = "/equip",
		registerForRefresh = true,
		registerForDefaults = true,
	}

    optionsTable = {
    [1] = {
            type = "header",
            name = "SaveEquip",
            width = "full",
          },
    [2] = {
            type = "checkbox",
            name = "Enable protection",
            tooltip = "Prompt before equipping BoE items.",
            getFunc = function () return sv.enabled end,
            setFunc = function (nv) sv.enabled = nv end,
            default = true,
            width = "full",
        }
    }

	LAM:RegisterAddonPanel("SaveEquipOptions", panelData)
	LAM:RegisterOptionControls("SaveEquipOptions", optionsTable)

    ZO_Dialogs_RegisterCustomDialog("CONFIRM_EQUIP_BOE", {
        gamepadInfo =
        {
            dialogType = GAMEPAD_DIALOGS.BASIC,
        },
        title =
        {
            text = SI_SAVE_EQUIP_CONFIRM_TITLE,
        },
        mainText = 
        {
            text = SI_SAVE_EQUIP_CONFIRM_EQUIP_BOE,
        },
        buttons =
        {
            [1] =
            {
                text =      SI_SAVE_EQUIP_EQUIP,
                callback =  function(dialog)
                                dialog.data.callback()
                            end
            },
            
            [2] =
            {
                text =      SI_DIALOG_CANCEL,
            }
        }
    })

    EquipItem = function (bagId, slotIndex, equipSlotIndex)
        local bound = IsItemBound(bagId, slotIndex)
        local link = GetItemLink(bagId, slotIndex)
        local bind_type = GetItemLinkBindType(link)

        local function callback ()
            ZO_EquipItem(bagId, slotIndex, equipSlotIndex)
        end

        if not bound and bind_type == BIND_TYPE_ON_EQUIP and sv.enabled then
            ZO_Dialogs_ShowPlatformDialog("CONFIRM_EQUIP_BOE", {callback=callback}, {mainTextParams={link}})
        else
            callback()
        end
    end
end
 
function SaveEquip.OnAddOnLoaded(event, addonName)
    if addonName == SaveEquip.name then
        SaveEquip:Initialize()
    end
end
 
EVENT_MANAGER:RegisterForEvent(SaveEquip.name, EVENT_ADD_ON_LOADED, SaveEquip.OnAddOnLoaded)
