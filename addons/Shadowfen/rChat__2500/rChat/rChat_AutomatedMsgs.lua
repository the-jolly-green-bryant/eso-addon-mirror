local SF = LibSFUtils
local L = GetString

rChat = rChat or {}

rChat.AutoMsg = {}

local RAM = rChat.AutoMsg

--[[
ZO_CreateStringId("RCHAT_AUTOMSG_NAME_DEFAULT_TEXT",    L(RCHAT_RCHAT_AUTOMSG_NAME_DEFAULT_TEXT))
ZO_CreateStringId("RCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT", L(RCHAT_RCHAT_AUTOMSG_MESSAGE_DEFAULT_TEXT))
ZO_CreateStringId("RCHAT_AUTOMSG_MESSAGE_TIP1_TEXT",    L(RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP1_TEXT))
ZO_CreateStringId("RCHAT_AUTOMSG_MESSAGE_TIP2_TEXT",    L(RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP2_TEXT))
ZO_CreateStringId("RCHAT_AUTOMSG_MESSAGE_TIP3_TEXT",    L(RCHAT_RCHAT_AUTOMSG_MESSAGE_TIP3_TEXT))
ZO_CreateStringId("RCHAT_AUTOMSG_NAME_HEADER",          L(RCHAT_RCHAT_AUTOMSG_NAME_HEADER))
ZO_CreateStringId("RCHAT_AUTOMSG_MESSAGE_HEADER",       L(RCHAT_RCHAT_AUTOMSG_MESSAGE_HEADER))
ZO_CreateStringId("RCHAT_AUTOMSG_ADD_TITLE_HEADER",     L(RCHAT_RCHAT_AUTOMSG_ADD_TITLE_HEADER))
ZO_CreateStringId("RCHAT_AUTOMSG_EDIT_TITLE_HEADER",    L(RCHAT_RCHAT_AUTOMSG_EDIT_TITLE_HEADER))
ZO_CreateStringId("RCHAT_AUTOMSG_ADD_AUTO_MSG",         L(RCHAT_RCHAT_AUTOMSG_ADD_AUTO_MSG))
ZO_CreateStringId("RCHAT_AUTOMSG_EDIT_AUTO_MSG",        L(RCHAT_RCHAT_AUTOMSG_EDIT_AUTO_MSG))
ZO_CreateStringId("SI_BINDING_NAME_RCHAT_SHOW_AUTO_MSG", L(RCHAT_SI_BINDING_NAME_RCHAT_SHOW_AUTO_MSG))
ZO_CreateStringId("RCHAT_AUTOMSG_REMOVE_AUTO_MSG",      L(RCHAT_RCHAT_AUTOMSG_REMOVE_AUTO_MSG))
--]]

-- These require access to rChat.save and rChat.data (local vars in rChat.lua that have
-- been stuffed in rChat table so that we can get to them from here.
-- Readdress this properly.
-- When this file is loaded, most of the rChat stuff has not been initialized yet.
-- So when we want access to .save or .data, we must do it when the function is
-- called, not when the file is loaded.

-- Called by XML
function RAM.HoverRow(control)
    local rChatData = rChat.data
    rChatData.autoMessagesShowKeybind = true
    rChatData.automatedMessagesList:Row_OnMouseEnter(control)
end

-- Called by XML
function RAM.ExitRow(control)
    local rChatData = rChat.data
    rChatData.autoMessagesShowKeybind = false
    rChatData.automatedMessagesList:Row_OnMouseExit(control)
end


function RAM.FindSavedAutomatedMsg(name)
    local dataList = rChat.save.automatedMessages
    for index, data in pairs(dataList) do
        if(data.name == name) then
            return data, index
        end
    end
end

function RAM.FindAutomatedMsg(name)
    local dataList = rChat.data.automatedMessagesList.list.data
    for i = 1, #dataList do
        local data = dataList[i].data
        if(data.name == name) then
            return data, i
        end
    end
end


function RAM.CleanAutomatedMessageList(dbs)
    -- :RefreshData() adds dataEntry recursively, delete it to avoid overflow in SavedVars
    for _, v in pairs(dbs.automatedMessages) do
        if v.dataEntry then
            v.dataEntry = nil
        end
    end
end

function RAM.RemoveAutomatedMessage(dbs)
    local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
    local _, index = RAM.FindSavedAutomatedMsg(data.name)
    table.remove(dbs.automatedMessages, index)

    local rChatData = rChat.data
    rChatData.automatedMessagesList:RefreshData()
    RAM.CleanAutomatedMessageList(dbs)

end

function RAM.ShowAutoMsg(am_menu)
    if not SCENE_MANAGER:IsShowing("rChatAutomatedMessagesScene") then
        SCENE_MANAGER:Toggle("rChatAutomatedMessagesScene")
    end
end

function RAM.BuildAutomatedMessagesDialog(control, saveFunc)

    local function AddDialogSetup(dialog, data)

        local name = GetControl(dialog, "NameEdit")
        local message = GetControl(dialog, "MessageEdit")

        name:SetText("")
        message:SetText("")
        name:SetEditEnabled(true)

    end

    ZO_Dialogs_RegisterCustomDialog("RCHAT_AUTOMSG_SAVE_MSG",
    {
        customControl = control,
        setup = AddDialogSetup,
        title = {
            text = RCHAT_AUTOMSG_ADD_TITLE_HEADER,
        },
        buttons = {
            [1] = {
                control  = GetControl(control, "Request"),
                text     = RCHAT_AUTOMSG_ADD_AUTO_MSG,
                callback = function(dialog)
                    local name = GetControl(dialog, "NameEdit"):GetText()
                    local message = GetControl(dialog, "MessageEdit"):GetText()
                    if(name ~= "") and (message ~= "") then
                        saveFunc(name, message, true)
                    end
                end,
            },
            [2] = {
                control = GetControl(control, "Cancel"),
                text = SI_DIALOG_CANCEL,
            }
        }
    })

    local function EditDialogSetup(dialog)
        local data = ZO_ScrollList_GetData(WINDOW_MANAGER:GetMouseOverControl())
        local name = GetControl(dialog, "NameEdit")
        local edit = GetControl(dialog, "MessageEdit")


        name:SetText(data.name)
        name:SetEditEnabled(false)
        edit:SetText(data.message)
        edit:TakeFocus()

    end

    ZO_Dialogs_RegisterCustomDialog("RCHAT_AUTOMSG_EDIT_MSG",
		{
			customControl = control,
			setup = EditDialogSetup,
			title = {
				text = RCHAT_AUTOMSG_EDIT_TITLE_HEADER,
			},
			buttons = {
				[1] = {
					control  = GetControl(control, "Request"),
					text     = RCHAT_AUTOMSG_EDIT_AUTO_MSG,
					callback = function(dialog)
						local name = GetControl(dialog, "NameEdit"):GetText()
						local message = GetControl(dialog, "MessageEdit"):GetText()
						if(name ~= "") and (message ~= "") then
							saveFunc(name, message, false)
						end
					end,
				},
				[2] = {
					control = GetControl(control, "Cancel"),
					text = SI_DIALOG_CANCEL,
				}
			}
		})

end

