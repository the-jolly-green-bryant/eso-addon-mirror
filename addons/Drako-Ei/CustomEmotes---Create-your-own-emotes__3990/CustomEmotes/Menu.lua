local CE = CustomEmotes
local internal = CE.internal
local LAM = LibAddonMenu2
local CONS = internal.constants


internal.ui = {}
internal.ui.editor = internal.editor.editorContainerReference
internal.ui.emotes = internal.list.listContainerReference
internal.ui.settings = internal.settings.settingsContainerReference
internal.ui.import = internal.import.importContainerReference


 
-- Util function to control menus
function internal.toggleMenu(menuName, state)
    local control = GetControl(menuName)
    if control and control.btmToggle then
        local onMouseUpHandler = control.btmToggle:GetHandler("OnMouseUp")
        if onMouseUpHandler then
            if control.open ~= state then
                onMouseUpHandler(control.btmToggle)
            end
        end
    end
end

-- Main menu
function internal.initializeUI()

    local submenus = {}
    table.insert(submenus, {
        type = "submenu",
        name = CONS.SUBMENU_SETTINGS_NAME,
        controls = internal.settings.initializeUI(),
        reference = internal.ui.settings
    })
    table.insert(submenus, {
		type = "submenu",
		name = CONS.SUBMENU_EMOTES_NAME,
		controls = internal.list.initializeUI(),
        reference = internal.ui.emotes
	})
    table.insert(submenus, {
		type = "submenu",
		name = CONS.SUBMENU_EDITOR_NAME,
		controls = internal.editor.initializeUI(),
        reference = internal.ui.editor
	})

    table.insert(submenus, {
		type = "submenu",
		name = CONS.SUBMENU_IMPORT_NAME,
		controls = internal.import.initializeUI(),
        reference = internal.ui.import
	})

    local panel = {
        type = "panel",
        registerForRefresh = true,
        name = CE.menuName,
        author = CE.author,
        slashCommand = CE.menuCommand,
    }
    
    LAM:RegisterAddonPanel(CE.menuName, panel)
    LAM:RegisterOptionControls(CE.menuName, submenus)
    
end