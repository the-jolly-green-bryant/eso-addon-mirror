-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- LAMPanel: A simple API for creating ESO Settings Panels using LibAddonMenu2 
--
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 
-- Version 1.0.0 by Teebow Ganx
-- Copyright (c) 2023 Trailing Zee Productions, LLC.
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
-- 
-- The above copyright notice and this permission notice shall be included in all
-- copies or substantial portions of the Software.
-- 
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
-- SOFTWARE.
-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- --

local objLAMPanel = ZO_CallbackObject:Subclass()
LAMPanel = objLAMPanel

-- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- -- 

function LAMPanel:New(inAddonName, inVersion, inDisplayName, inSlashCmd, inAuthor, inWebsiteURL, inDonationURL)
    
    assert(inAddonName ~= nil)
    assert(inAddonName ~= "")
    assert(inVersion ~= nil)
    assert(inVersion ~= "")
    
    local panelObj = ZO_Object.New(self)

    panelObj.data = {
		type = "panel",
        name = inAddonName,
        displayName = inAddonName,
        version = inVersion,
		registerForRefresh = true
	}

    -- All of these are optional in a LAM settings panel
    if inDisplayName and inDisplayName ~= "" then panelObj.data.displayName = inDisplayName end
    if inSlashCmd and inSlashCmd ~= "" then panelObj.data.slashCommand = inSlashCmd end
    if inAuthor and inAuthor ~= "" then panelObj.data.author = inAuthor end
    if inWebsiteURL and inWebsiteURL ~= "" then panelObj.data.website = inWebsiteURL end
    if inDonationURL and inDonationURL ~= "" then panelObj.data.donation = inDonationURL end

    panelObj.addonID = inAddonName.."_Settings_Panel"
    panelObj.panel = LibAddonMenu2:RegisterAddonPanel(panelObj.addonID, panelObj.data)
    panelObj.controls = {}

    return panelObj
end

-- Call RegisterControls once you've added all your controls
function LAMPanel:RegisterControls()
    LibAddonMenu2:RegisterOptionControls(self.addonID, self.controls)
end

function LAMPanel:AddHeader(data) AddControl("header", data) end
function LAMPanel:AddIconPicker(data) AddControl("iconpicker", data) end
function LAMPanel:AddSlider(data) AddControl("slider", data) end
function LAMPanel:AddColorPicker(data) AddControl("colorpicker", data) end
function LAMPanel:AddCheckbox(data) AddControl("checkbox", data) end
function LAMPanel:AddDescription(data) AddControl("description", data) end
function LAMPanel:AddDropdown(data) AddControl("dropdown", data) end
function LAMPanel:AddDivider(data) AddControl("divider", data) end
function LAMPanel:AddListBox(data) AddControl("orderlistbox", data) end

function LAMPanel:AddControl(inControlType, inControlData)
    inControlData.type = inControlType
    table.insert(self.controls, inControlData)
end