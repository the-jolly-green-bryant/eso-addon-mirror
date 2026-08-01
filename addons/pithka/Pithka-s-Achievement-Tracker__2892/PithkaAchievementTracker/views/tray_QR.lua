PITHKA = PITHKA or {}
PITHKA.views = PITHKA.views or {}
PITHKA.views.QR = PITHKA.views.QR or {}


-- convenient namespacing
local savedVars = PITHKA.data.savedVars
local ui = PITHKA.ui
local data = PITHKA.data
local constants = PITHKA.common.constants

local qrTooltipText = "This encodes the clears on this page into a format that's easily readable by a bot to help tag clears."

function PITHKA.views.QR.initialize()
    local QRContainer = PITHKA_GUI:GetNamedChild("QRContainer")
    
    -- create click function for QR and label
    local function clickFn()
        d("|cFF8800[Pithka]|r ESOClearsBot Discord: |cFFFFFF https://discord.gg/72NKKm5964|r")
    end

    -- build QR control
    local control = ui.other.qrCode{parent=QRContainer, tooltipText=qrTooltipText}
    control:SetMouseEnabled(true)
    control:SetHandler("OnMouseUp", clickFn)
	
	local function updateQR()
		local qrString = data.generateQR.getCompressed()
		LibQRCode.DrawQRCode(control, qrString)
	end
	
	--whenever the QR Container becomes visible, draw the QR code
	QRContainer:SetHandler("OnEffectivelyShown", updateQR)
	
    -- update visibility based on currentTray
    local function updateQRVisibility(var, value)
        if var == 'currentTray' then 
			--if the user hides the Export panel, then hide the QR Container, 
			--and if they show the export panel, then show the QR Container
            local isVisible = value == 'Export'
            QRContainer:SetHidden(not isVisible)
        end
    end
    savedVars.registerCallback(updateQRVisibility)

    -- update QR code data on currentScreen change while tray is visible
    local function updateQRData(var, value)
        if (not QRContainer:IsHidden()) and var == 'currentScreen' and savedVars.get('currentTray') == 'Export' then
			--if the user clicks a different screen and the QR panel is visible and we're trying to update the Export panel
			--then update the QR Code.
            updateQR()
        end
    end
    savedVars.registerCallback(updateQRData)

    -- set initial visibility
    updateQRVisibility('currentTray', savedVars.get('currentTray'))

    -- add label
    local infoLabel = ui.label.basic{
        parent = QRContainer, 
        width = 300,
        height = 100,
        vAlign = TEXT_ALIGN_TOP,
        hAlign = TEXT_ALIGN_CENTER,
        wrapMode = TEXT_WRAP_MODE_ELLIPSIS,
        text = "Used by discord bot ESOClearsBot to auto update clears.  Click for Discord link.", 
        font = constants.font.smallThinFont,
        clickFn = clickFn,
    }
    infoLabel:SetAnchor(TOP, control, BOTTOM, 0, 10)

    -- add tooltip
    --InitializeTooltip(InformationTooltip, infoLabel, TOP, 0, 0, BOTTOM)
end


