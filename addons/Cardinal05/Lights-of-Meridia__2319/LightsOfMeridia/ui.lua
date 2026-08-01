local LOM = LightsOfMeridia
LOM.UI = LOM.UI or { }

---[ Sounds  ]---

do
	local soundReadyTime = 0

	function LOM.UI.PlaySound( sound, duration )

		duration = duration or 1000

		local currentTime = GetFrameTimeMilliseconds()
		if currentTime < soundReadyTime then return end

		soundReadyTime = currentTime + duration
		PlaySound( sound )

	end
end

---[ Modal Dialogs ]---

function LOM.UI.HideAllDialogs()
	ZO_Dialogs_ReleaseAllDialogs()
end

function LOM.UI.SetupAlertDialog()
    if not ESO_Dialogs[ LOM.Const.DialogAlert ] then
		ESO_Dialogs[ LOM.Const.DialogAlert ] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_OK,
                    callback = function( dialog ) end,
                },
            }
        }
    end

	return ESO_Dialogs[ LOM.Const.DialogAlert ]
end

function LOM.UI.ShowAlertDialog( message, confirmCallback )
    local dialog = LOM.UI.SetupAlertDialog()
    dialog.title.text = LOM.Const.AddonTitle
    dialog.mainText.text = message
    dialog.buttons[1].callback = function()
		if nil ~= confirmCallback then
			confirmCallback()
		end
	end

    ZO_Dialogs_ShowDialog( LOM.Const.DialogAlert )
end

function LOM.UI.SetupConfirmDialog()
    if not ESO_Dialogs[ LOM.Const.DialogConfirm ] then
		ESO_Dialogs[ LOM.Const.DialogConfirm ] = {
            canQueue = true,
            title = {
                text = "",
            },
            mainText = {
                text = "",
            },
            buttons = {
                [1] = {
                    text = SI_DIALOG_CONFIRM,
                    callback = function( dialog ) end,
                },
                [2] = {
                    text = SI_DIALOG_CANCEL,
					callback = function( dialog ) end,
                }
            }
        }
    end

	return ESO_Dialogs[ LOM.Const.DialogConfirm ]
end

function LOM.UI.ShowConfirmationDialog( title, body, confirmCallback, cancelCallback )
    local dialog = LOM.UI.SetupConfirmDialog()
    dialog.title.text = LOM.Const.AddonTitle
    dialog.mainText.text = body
    dialog.buttons[1].callback = function()
		if nil ~= confirmCallback then
			confirmCallback()
		end
	end
	dialog.buttons[2].callback = function()
		if nil ~= cancelCallback then
			cancelCallback()
		end
	end

    ZO_Dialogs_ShowDialog( LOM.Const.DialogConfirm )
end

---[ Notification ]---

function LOM.UI.SetupNotificationDialog()
	local ui = LOM.UI.NotificationDialog

	if nil == ui then
		ui = { }
		LOM.UI.NotificationDialog = ui

		local prefix = "LOMNotificationDialog"
		local c, grp, win

		-- Window

		win = WINDOW_MANAGER:CreateTopLevelWindow( prefix )
		ui.Window = win
		win:SetAlpha( 0.5 )
		win:SetClampedToScreen( true )
		win:SetMouseEnabled( false )
		win:SetMovable( false )
		win:SetResizeHandleSize( 0 )
		win:SetAnchor( BOTTOM, GuiRoot, BOTTOM, 0, -340 )
		win:SetDimensions( 1, 100 )
		win:SetHidden( true )

		-- Controls

		c = WINDOW_MANAGER:CreateControl( prefix .. "Message", win, CT_LABEL )
		ui.Message = c
		c:SetColor( 1, 1, 0.5, 1 )
		c:SetText( "" )
		c:SetFont( "$(BOLD_FONT)|$(KB_32)|soft-shadow-thick" )
		c:SetHorizontalAlignment( TEXT_ALIGN_CENTER )
		c:SetVerticalAlignment( TEXT_ALIGN_TOP )
		c:SetAnchor( CENTER, win, CENTER, 0, 0 )
	end

	return ui
end

function LOM.UI.HideNotification()
	local ui = LOM.UI.SetupNotificationDialog()
	ui.Window:SetHidden( true )
end

function LOM.UI.FadeNotification()
	local ui = LOM.UI.NotificationDialog
	local alpha = ui.CurrentAlpha

	if not ui.IsFading then
		if 1 > alpha then
			alpha = alpha + 0.01
		else
			ui.IsFading = true
		end
	else
		alpha = alpha - 0.01
	end

	ui.Window:SetAlpha( alpha )
	ui.CurrentAlpha = alpha

	if ui.IsFading and 0.01 > alpha then
		LOM.UI.HideNotification()
		EVENT_MANAGER:UnregisterForUpdate( LOM.Const.AddonName .. "FadeNotification" )
	end
end

function LOM.UI.DisplayNotification( message )
	local ui = LOM.UI.SetupNotificationDialog()
	ui.Message:SetText( message )
	ui.Window:SetHidden( false )
	ui.Window:SetAlpha( 0 )
	ui.CurrentAlpha = 0
	ui.IsFading = false

	EVENT_MANAGER:RegisterForUpdate( LOM.Const.AddonName .. "FadeNotification", 20, LOM.UI.FadeNotification )
end
