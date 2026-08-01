--Register with LibStub
local MAJOR, MINOR = "Up_FloatingWindowPresenter", 2
local LIB, _ = LibStub:NewLibrary(MAJOR, MINOR)
if not LIB then return end -- avoid double loading.

--[[
-- Handles displaying of ThiefHelper window.
]] --
LIB.name = "Up_FloatingWindowPresenter"

local UiTools = LibStub:GetLibrary("Up_UiTools")

-- Creates an base for presenter.
function LIB:new(addon, window, widgetFactory, type, options)
    local instance = {
        Addon = addon,
        Window = window,
        WidgetFactory = widgetFactory,
        LabelsList = {}, -- List of created labels.
        Type = type, -- type of window, used as suffix for naming.
        Options = options, -- Options to configure presenter.
    }
    self.__index = self
    return setmetatable(instance, self)
end

-- Returns size of specified table.
local function getTableSize(table)
    local size = 0
    for key, value in pairs(table) do
        size = size + 1
    end
    return size
end

-- Checks that labels exists for each provider and adds new if not.
function LIB:checkAndUpdateLabels()
    local providers = self.Addon.ProvidersController
    local labels = self.LabelsList
    local factory = self.WidgetFactory
    local labelsNumber = getTableSize(labels)
    if providers.Size > labelsNumber then
        -- we need to add more labels
        local container = UiTools.getContainer(self.Window)
        local labelsToAdd = providers.Size - labelsNumber
        for i = 1, labelsToAdd do
            local index = labelsNumber + 1 -- index for new label in list
            local label = factory.createNormalLabel(self.Addon.name .. "_label_" .. index, container)
            if labelsNumber > 0 then
                local lastLabel = labels[labelsNumber]
                label:SetAnchor(TOPLEFT, lastLabel, BOTTOMLEFT, 0, 0)
            else
                label:SetAnchor(TOPLEFT, container, TOPLEFT, 0, 0)
            end
            label:SetText("")
            labels[index] = label -- save new label
            labelsNumber = labelsNumber + 1 -- calc new number of labels
        end
    end
    --d(self.Addon.name .. " has " .. providers.Size .. " providers")
end

-- Updates info window with new data retrieved from providers.
function LIB:onUpdateRequired()
    local providers = self.Addon.ProvidersController
    local labels = self.LabelsList
    self:checkAndUpdateLabels()
    local index = 1
    local labelsNumber = getTableSize(labels)
    for _, provider in pairs(providers.OrderedList) do
        local label = labels[index]
        if provider == nil and label ~= nil then
            label:SetHidden(true)
        elseif provider ~= nil and label ~= nil then
            local text = provider:getText(self.Addon)
            if text ~= nil then
                label:SetText(text)
                label:SetHidden(false)
                index = index + 1 -- increase index only if label used.
            else
                label:SetText("") -- clean text of unused labels.
                label:SetHidden(true) -- hide label if there are no data.
            end
        end
    end
    local window = UiTools.getBackdrop(self.Window)
    if index == 1 then
        -- No data displayed - hide window.
        window:SetHidden(true)
    else
        window:SetHidden(false)
    end
    if index <= labelsNumber then
        for i = index, labelsNumber do
            local label = labels[index]
            label:SetText("") -- clean text of unused labels.
            label:SetHidden(true) -- hide label if there are no data.
        end
    end
end

-- Starts displaying of data for Window.
function LIB:start()
    local function callback()
        self:onUpdateRequired()
    end
    local key = self.Addon.name .. "_" .. LIB.name .. "_" .. self.Type
    EVENT_MANAGER:RegisterForUpdate(key, self.Options.UpdateInterval, callback)
end
