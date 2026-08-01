--- @class LibGroupBroadcastInternal
local internal = LibGroupBroadcast.internal

local function CreateOptionsData(saveData, handlerManager, protocolManager)
    local optionsData = {}

    local handlers = handlerManager:GetHandlers()
    for i = 1, #handlers do
        local handlerData = handlers[i]
        local handlerControls = {}

        if handlerData.description then
            handlerControls[#handlerControls + 1] = {
                type = "description",
                text = handlerData.description,
            }
        end

        if handlerData.settings then
            for j = 1, #handlerData.settings do
                handlerControls[#handlerControls + 1] = handlerData.settings[j]
            end
        end

        for j = 1, #handlerData.customEvents do
            local eventId, eventName, displayName, userSettings = unpack(handlerData.customEvents[j])
            handlerControls[#handlerControls + 1] = {
                type = "header",
                name = displayName or eventName,
            }

            handlerControls[#handlerControls + 1] = {
                type = "checkbox",
                name = "Allow Sending",
                getFunc = function() return protocolManager:IsProtocolEnabled(eventId) end,
                setFunc = function(value) protocolManager:SetProtocolEnabled(eventId, value) end,
            }

            if userSettings then
                local options = userSettings:GetOptions()
                for k = 1, #options do
                    handlerControls[#handlerControls + 1] = options[k]
                end
            end
        end

        for j = 1, #handlerData.protocols do
            local protocol = handlerData.protocols[j]
            if protocol:IsFinalized() then
                handlerControls[#handlerControls + 1] = {
                    type = "header",
                    name = protocol:GetDisplayName() or protocol:GetName(),
                }

                local description = protocol:GetDescription()
                if description then
                    handlerControls[#handlerControls + 1] = {
                        type = "description",
                        text = description,
                    }
                end

                handlerControls[#handlerControls + 1] = {
                    type = "checkbox",
                    name = "Allow Sending",
                    getFunc = function() return protocolManager:IsProtocolEnabled(protocol:GetId()) end,
                    setFunc = function(value) protocolManager:SetProtocolEnabled(protocol:GetId(), value) end,
                }

                local userSettings = protocol:GetUserSettings()
                if userSettings then
                    local options = userSettings:GetOptions()
                    for k = 1, #options do
                        handlerControls[#handlerControls + 1] = options[k]
                    end
                end
            end
        end

        optionsData[#optionsData + 1] = {
            type = "submenu",
            name = handlerData.displayName or handlerData.handlerName,
            controls = handlerControls,
        }
    end

    return optionsData
end

function internal:InitializeSettingsPanel(saveData)
    local LAM = LibAddonMenu2
    local DONATION_URL = "https://www.esoui.com/downloads/info1337-LibGroupBroadcast.html#donate"
    local panelData = {
        type = "panel",
        name = "LibGroupBroadcast",
        author = "sirinsidiator",
        version = "2.0.0.95",
        website = "https://www.esoui.com/downloads/info1337-LibGroupBroadcast.html",
        feedback = "https://www.esoui.com/portal.php?id=218&a=bugreport",
        donation = DONATION_URL,
        registerForRefresh = true,
        registerForDefaults = true
    }
    local panel = LAM:RegisterAddonPanel("LibGroupBroadcastOptions", panelData)
    CALLBACK_MANAGER:RegisterCallback("LAM-BeforePanelControlsCreated", function(currentPanel)
        if currentPanel == panel then
            local optionsData = CreateOptionsData(saveData, self.handlerManager, self.protocolManager)
            LAM:RegisterOptionControls("LibGroupBroadcastOptions", optionsData)
        end
    end)
end
