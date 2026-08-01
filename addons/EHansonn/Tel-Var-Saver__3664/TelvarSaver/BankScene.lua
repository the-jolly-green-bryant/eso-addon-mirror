TelVarSaver = TelVarSaver or {}
local TVS = TelVarSaver

function TVS.HideUi() TVSView:SetHidden(true) end

function TVS.ShowUi()
	TVS.UpdateText()
	TVS.UpdateBankControls()
	TVSView:SetHidden(false)
end

function TVS.SetHidden()
	TVS.HideUi()
	TVS.SV.BankScene = false
end

function TVS.UpdateText()
	local currentTelvarOnChar = GetCarriedCurrencyAmount(CURT_TELVAR_STONES)
	local currentTelvarStonesInBank = GetBankedCurrencyAmount(CURT_TELVAR_STONES)
	TVSViewCurrentTextValue:SetText(TVS.TELVAR_CHAT_ICON .. " |c8080ff" .. ZO_CommaDelimitNumber(currentTelvarOnChar) .. "|r")
	TVSViewBankTextValue:SetText(TVS.TELVAR_CHAT_ICON .. " |c8080ff" .. ZO_CommaDelimitNumber(currentTelvarStonesInBank) .. "|r")
	TVSViewButtonDepo1k:SetAlpha(1)
	TVSViewButtonDepo10k:SetAlpha(1)
	-- Dim a button when the player can't reach that amount (not enough telvar
	-- carried, and not enough in the bank to withdraw up to it).
	if (currentTelvarStonesInBank < 10000) and (currentTelvarOnChar < 10000) then
		TVSViewButtonDepo10k:SetAlpha(0.5)
	end
	if (currentTelvarStonesInBank < 1000) and (currentTelvarOnChar < 1000) then
		TVSViewButtonDepo1k:SetAlpha(0.5)
	end
end

-- -------------------------------------------------------------------------------
-- In-window auto manage controls (mirror the addon menu settings)
-- -------------------------------------------------------------------------------

-- One-time setup of the native checkbox toggles (label + click behavior).
function TVS.SetupBankCheckButtons()
	if TVSViewAutoDepoToggle == nil then return end

	ZO_CheckButton_SetLabelText(TVSViewAutoDepoToggle, "Auto deposit Tel Var")
	ZO_CheckButton_SetToggleFunction(TVSViewAutoDepoToggle, function(_, checked)
		TVS.SV.AutoDepoTelvar = checked
		TVS.UpdateBankControls()
	end)

	ZO_CheckButton_SetLabelText(TVSViewAutoWithdrawToggle, "Auto withdraw Tel Var")
	ZO_CheckButton_SetToggleFunction(TVSViewAutoWithdrawToggle, function(_, checked)
		TVS.SV.AutoWithdrawTelvar = checked
		TVS.UpdateBankControls()
	end)
end

-- Sync the checkbox states and the desired-amount editbox with the saved settings.
function TVS.UpdateBankControls()
	if TVSView == nil then return end

	-- SetCheckState only updates the visual; it does not call the toggle function.
	ZO_CheckButton_SetCheckState(TVSViewAutoDepoToggle, TVS.SV.AutoDepoTelvar)
	ZO_CheckButton_SetCheckState(TVSViewAutoWithdrawToggle, TVS.SV.AutoWithdrawTelvar)

	-- Keep the editbox in sync unless the user is currently typing in it.
	if TVSViewDesiredBackdropEdit:HasFocus() == false then
		TVSViewDesiredBackdropEdit:SetText(tostring(TVS.SV.DesiredTelvarAmount))
	end
end

-- Validate and store the desired carried amount typed into the in-window editbox.
function TVS.CommitDesiredEdit()
	local amount = tonumber(TVSViewDesiredBackdropEdit:GetText())
	if not amount then amount = TVS.SV.DesiredTelvarAmount end
	if (amount < 0) or (amount > 10000) then
		amount = TVS.SV.DesiredTelvarAmount
		TVS.dtvs("Invalid amount. Must be between 0 and 10000", "notifyBank")
	end
	TVS.SV.DesiredTelvarAmount = amount
	TVS.UpdateBankControls()
end

function TVS.SaveLocation()
	TVS.SV.locationx = TVSView:GetLeft()
	TVS.SV.locationy = TVSView:GetTop()
end

function TVS.UpdateAnchors()
	TVSView:ClearAnchors()
	TVSView:SetAnchor(TOPLEFT, GuiRoot, TOPLEFT, TVS.SV.locationx, TVS.SV.locationy)
	TVSView:SetMovable(TVS.SV.draggable)
end

function TVS.UpdateUi() TVS.UpdateAnchors() end
