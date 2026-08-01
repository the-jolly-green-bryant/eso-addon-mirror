local DsRBeam = DsRGuildBeam
DsRBeam.UI = DsRBeam.UI or { }

---[ Sounds  ]---

do
	local soundReadyTime = 0

	function DsRBeam.UI.PlaySound( sound, duration )

		duration = duration or 1000

		local currentTime = GetFrameTimeMilliseconds()
		if currentTime < soundReadyTime then return end

		soundReadyTime = currentTime + duration
		PlaySound( sound )

	end
end

---[ Modal Dialogs ]---

function DsRBeam.UI.HideAllDialogs()
	ZO_Dialogs_ReleaseAllDialogs()
end

function DsRBeam.UI.SetupAlertDialog()
    if not ESO_Dialogs[ DsRBeam.Const.DialogAlert ] then
		ESO_Dialogs[ DsRBeam.Const.DialogAlert ] = {
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

	return ESO_Dialogs[ DsRBeam.Const.DialogAlert ]
end

function DsRBeam.UI.ShowAlertDialog( message, confirmCallback )
    local dialog = DsRBeam.UI.SetupAlertDialog()
    dialog.title.text = DsRBeam.Const.AddonTitle
    dialog.mainText.text = message
    dialog.buttons[1].callback = function()
		if nil ~= confirmCallback then
			confirmCallback()
		end
	end

    ZO_Dialogs_ShowDialog( DsRBeam.Const.DialogAlert )
end

function DsRBeam.UI.SetupConfirmDialog()
    if not ESO_Dialogs[ DsRBeam.Const.DialogConfirm ] then
		ESO_Dialogs[ DsRBeam.Const.DialogConfirm ] = {
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

	return ESO_Dialogs[ DsRBeam.Const.DialogConfirm ]
end

function DsRBeam.UI.ShowConfirmationDialog( title, body, confirmCallback, cancelCallback )
    local dialog = DsRBeam.UI.SetupConfirmDialog()
    dialog.title.text = DsRBeam.Const.AddonTitle
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

    ZO_Dialogs_ShowDialog( DsRBeam.Const.DialogConfirm )
end

---[ Notification ]---

function DsRBeam.UI.SetupNotificationDialog()
	local ui = DsRBeam.UI.NotificationDialog

	if nil == ui then
		ui = { }
		DsRBeam.UI.NotificationDialog = ui

		local prefix = "DsRBeamNotificationDialog"
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

function DsRBeam.UI.HideNotification()
	local ui = DsRBeam.UI.SetupNotificationDialog()
	ui.Window:SetHidden( true )
end

function DsRBeam.UI.FadeNotification()
	local ui = DsRBeam.UI.NotificationDialog
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
		DsRBeam.UI.HideNotification()
		EVENT_MANAGER:UnregisterForUpdate( DsRBeam.Const.AddonName .. "FadeNotification" )
	end
end

function DsRBeam.UI.DisplayNotification( message )
	local ui = DsRBeam.UI.SetupNotificationDialog()
	ui.Message:SetText( message )
	ui.Window:SetHidden( false )
	ui.Window:SetAlpha( 0 )
	ui.CurrentAlpha = 0
	ui.IsFading = false

	EVENT_MANAGER:RegisterForUpdate( DsRBeam.Const.AddonName .. "FadeNotification", 20, DsRBeam.UI.FadeNotification )
end
