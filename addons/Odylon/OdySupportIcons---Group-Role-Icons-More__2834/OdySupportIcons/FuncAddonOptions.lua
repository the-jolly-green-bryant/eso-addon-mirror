OSI.LAMControls = { }

local OPTIONS = nil
local DEFAULT = {
    -- general
    ["interval"]    = 10,       -- update interval in ms
    ["iconsize"]    = 128,      -- icon size in px
    ["scaling"]     = true,     -- 3d scaling
    ["offset"]      = 3.0,      -- vertical offset in m
    ["alpha"]       = 1,        -- overall opacity
    ["fadeout"]     = true,     -- fade out close to camera
    ["fadedist"]    = 7.5,      -- distance to start fading in m
    ["showOwnIcon"]     = false,-- shows icon of the player itself
    -- custom
    ["customuse"]   = true,     -- show custom 3d icons
    ["save"]        = true,     -- store assigned custom icons
    ["cache"]       = { },      -- custom icon cache
    -- unique
    ["ignore"]      = false,    -- show unique 3d icons
    ["hodoruse"]    = true,     -- show LibCustomIcons icons
    ["hodoranim"]   = true,     -- show LibCustomIcons animations
    ["hodorprio"]   = false,    -- prioritize LibCustomIcons over unique icons
    -- raid
    ["raidallow"]   = false,    -- show raid icons assigned by group leader
    ["raidforce"]   = false,    -- show raid icon context menu for group leader
    -- world map
    ["wmuse"]       = false,    -- show custom icons on world map
    ["wmunique"]    = false,    -- show unique icons on world map
    ["wmdead"]      = false,    -- show dead players on world map
    ["wmroles"]     = false,    -- show role icons on world map
    ["wmsize"]      = 32,       -- world map icon size in px
    -- group window
    ["gwuse"]       = true,     -- show custom icons in group window
    ["gwunique"]    = true,     -- show unique icons in group window
    ["gwdead"]      = false,    -- show dead players in group window
    ["gwroles"]     = false,    -- show role icons in group window
    ["gwcrown"]     = true,     -- show crown overlay
    -- chat window
    ["cwuse"]       = true,     -- show custom 2d icons in chat window
    ["cwunique"]    = true,     -- show unique 2d icons in chat window
    ["cwsize"]      = 20,       -- chat window icon size in px
    -- friends list
    ["fluse"]       = true,     -- show custom 2d icons in friends list
    ["flunique"]    = true,     -- show unique 2d icons in friends list
    ["flstatus"]    = true,     -- show player status overlay
    -- guild roster
    ["gruse"]       = true,     -- show custom 2d icons in guild roster
    ["grunique"]    = true,     -- show unique 2d icons in guild roster
    ["grstatus"]    = true,     -- show player status overlay
    -- roles
    [OSI.ROLE_LEAD] = {
        ["show"]     = true,
        ["priority"] = false,
        ["usesize"]  = false,
        ["size"]     = 128,
        ["color"]    = { 1, 0, 1 },  -- pink
        ["icon"]     = "esoui/art/icons/mapkey/mapkey_groupleader.dds",
    },
    [OSI.ROLE_TANK] = {
        ["show"]     = true,
        ["priority"] = false,
        ["color"]    = { 1, 1, 0 },  -- yellow
        ["icon"]     = "esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
    },
    [OSI.ROLE_HEAL] = {
        ["show"]     = true,
        ["priority"] = false,
        ["color"]    = { 0, 1, 1 },  -- teal
        ["icon"]     = "esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
    },
    [OSI.ROLE_DEAD] = {
        ["show"]     = false,
        ["priority"] = false,
        ["useoff"]   = true,
        ["offset"]   = 0.5,
        ["color"]    = {   1,   0, 0 }, -- red
        ["colrez"]   = {   1, 0.5, 0 }, -- orange
        ["colrdy"]   = { 0.5,   1, 0 }, -- lime
        ["icon"]     = "esoui/art/icons/mapkey/mapkey_groupboss.dds",
    },
    [OSI.ROLE_DPS]  = {
        ["show"]     = false,
        ["priority"] = false,
        ["color"]    = { 0, 0, 1 },  -- blue
        ["icon"]     = "esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
    },
    [OSI.ROLE_BG]   = {
        ["show"]     = false,
        ["priority"] = false,
        ["color"]    = { 0, 1, 0 },  -- green
        ["icon"]     = "esoui/art/tutorial/gamepad/gp_lfg_veteranldungeon.dds",
    },
    -- not used atm, maybe use it for group member companions later...
    -- [OSI.ALLY_COMPANION] = {
    --     ["show"]     = true,
    --     ["dead"]     = false,
    --     ["color"]    = { 1, 1, 1 },
    --     ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    -- },
    -- allies
    [OSI.ALLY_BASTIAN]   = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
    [OSI.ALLY_MIRRI]     = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
    [OSI.ALLY_BANKER]    = {
        ["show"]     = true,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/icons/servicemappins/servicepin_bank.dds",
    },
    [OSI.ALLY_VENDOR]    = {
        ["show"]     = true,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/icons/servicemappins/servicepin_vendor.dds",
    },
    [OSI.ALLY_FENCE]     = {
        ["show"]     = true,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/icons/mapkey/mapkey_fence.dds",
    },
    [OSI.ALLY_EMBER]     = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
    [OSI.ALLY_ISOBEL]     = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
    [OSI.ALLY_DECON]     = {
        ["show"]     = true,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/crafting/gamepad/gp_crafting_menuicon_deconstruct.dds",
    },
    [OSI.ALLY_ARMORY]     = {
        ["show"]     = true,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/icons/servicemappins/servicepin_armory.dds",
    },
    [OSI.ALLY_SHARP]     = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
    [OSI.ALLY_AZANDAR]     = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
    [OSI.ALLY_TANLORIN]     = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
    [OSI.ALLY_ZERITHVAR]     = {
        ["show"]     = true,
        ["dead"]     = false,
        ["color"]    = { 1, 1, 1 },
        ["icon"]     = "esoui/art/mappins/activecompanion_pin.dds",
    },
}

local ICONS_GROUP = {
    -- game icons
    "esoui/art/icons/mapkey/mapkey_groupleader.dds",
    "esoui/art/icons/guildranks/guild_rankicon_leader_large.dds",
    "esoui/art/lfg/gamepad/lfg_roleicon_tank.dds",
    "esoui/art/lfg/gamepad/lfg_roleicon_healer.dds",
    "esoui/art/lfg/gamepad/lfg_roleicon_dps.dds",
    "esoui/art/tutorial/gamepad/gp_lfg_normaldungeon.dds",
    "esoui/art/tutorial/gamepad/gp_lfg_veteranldungeon.dds",
    "esoui/art/icons/mapkey/mapkey_groupboss.dds",
    "esoui/art/icons/servicemappins/servicepin_undaunted.dds",
    "esoui/art/icons/mapkey/mapkey_bg_murderball.dds",
    "esoui/art/icons/servicemappins/servicepin_shadowysupplier.dds",
    "esoui/art/icons/mapkey/mapkey_dock.dds",
    "esoui/art/icons/mapkey/mapkey_thievesguild.dds",
    "esoui/art/icons/mapkey/mapkey_fence.dds",
    "esoui/art/icons/mapkey/mapkey_portal.dds",

    -- ally icons
    "esoui/art/mappins/activecompanion_pin.dds",
    "esoui/art/icons/servicemappins/servicepin_bank.dds",
    "esoui/art/icons/servicemappins/servicepin_vendor.dds",
    -- "esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_generalgoods.dds",
    -- "esoui/art/icons/servicetooltipicons/gamepad/gp_servicetooltipicon_banker.dds",

    -- custom icons
    "odysupporticons/icons/arrow.dds",
    "odysupporticons/icons/cross.dds",
}

local function UpdateControlColor( role )
    if OSI.LAMControls[role] then
        local color = OPTIONS[role].color
        local icon  = OSI.LAMControls[role].icon
        icon:SetColor( color[1], color[2], color[3], 1, true )
    end
end

function OSI.TableAppend( tab, add )
	for _, v in ipairs( add ) do
		table.insert( tab, v )
	end
end

function OSI.LoadOptions()
    OPTIONS = ZO_SavedVars:NewAccountWide( "OSIStore", 1, nil, DEFAULT )
    OPTIONS.raidforce = false
end

function OSI.GetOption( key )
    return OPTIONS[key]
end

function OSI.UpdateCache( key, value )
    if not key then
        OPTIONS.cache = { }
    else
        OPTIONS.cache[key] = value
    end
end

function OSI.CreateMenu( LAM )
	local panelData = {
		type				= "panel",
		name				= OSI.name,
		displayName			= OSI.name,
		author				= OSI.author,
		version				= OSI.version,
		slashCommand		= "/osi",
		registerForRefresh	= true,
		registerForDefaults = true,
    }

    local icon3dOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
            type    = "slider",
            name    = "Update Interval",
            tooltip = "Milliseconds, lower numbers lead to higher accuracy but require more performance",
            min     = 0,
            max     = 100,
            step    = 10,
            default = DEFAULT.interval,
            getFunc = function() return OPTIONS.interval end,
            setFunc = function( newValue ) OPTIONS.interval = newValue; OSI.StartPolling() end,
        },
        {
            type    = "slider",
            name    = "Icon Size",
            tooltip = "Width/height in pixels, if scaling is turned on, chosen size will apply around 10m in front of the camera",
            min     = 32,
            max     = 256,
            step    = 4,
            default = DEFAULT.iconsize,
            getFunc = function() return OPTIONS.iconsize end,
            setFunc = function( newValue ) OPTIONS.iconsize = newValue end,
        },
        {
            type     = "checkbox",
            name     = "Scaling",
            default  = DEFAULT.scaling,
            getFunc  = function() return OPTIONS.scaling end,
            setFunc  = function( newValue ) OPTIONS.scaling = newValue end,
        },
        {
            type     = "slider",
            name     = "Vertical Offset",
            tooltip  = "Distance from ground to icon bottom in meters",
            min      = 0.0,
            max      = 5.0,
            step     = 0.1,
            decimals = 2,
            default  = DEFAULT.offset,
            getFunc  = function() return OPTIONS.offset end,
            setFunc  = function( newValue ) OPTIONS.offset = newValue end,
        },
        {
            type     = "slider",
            name     = "Opacity",
            min      = 0.1,
            max      = 1,
            step     = 0.05,
            decimals = 2,
            default  = DEFAULT.alpha,
            getFunc  = function() return OPTIONS.alpha end,
            setFunc  = function( newValue ) OPTIONS.alpha = newValue end,
        },
        {
            type     = "checkbox",
            name     = "Fade out close to Camera",
            default  = DEFAULT.fadeout,
            getFunc  = function() return OPTIONS.fadeout end,
            setFunc  = function( newValue ) OPTIONS.fadeout = newValue end,
        },
        {
            type     = "slider",
            name     = "Distance to start fading",
            tooltip  = "Distance from the camera in meters",
            min      = 1,
            max      = 10,
            step     = 0.25,
            decimals = 2,
            default  = DEFAULT.fadedist,
            getFunc  = function() return OPTIONS.fadedist end,
            setFunc  = function( newValue ) OPTIONS.fadedist = newValue end,
            disabled = function() return not OPTIONS.fadeout end,
        },

    }

    local groupIconOptions = { }

    local function RoleOptions( role, description )
        local s = ( role == OSI.ROLE_LEAD or role == OSI.ALLY_BASTIAN or role == OSI.ALLY_MIRRI or role == OSI.ALLY_EMBER or role == OSI.ALLY_ISOBEL or role == OSI.ALLY_SHARP or role == OSI.ALLY_AZANDAR or role == OSI.ALLY_TANLORIN or role == OSI.ALLY_ZERITHVAR) and "" or "s"

        local roleOptions = {
            {
                type  = "description",
                text  = "",
                title = "\n|cffff00" .. string.upper( description ) .. " ICON|r",
            },
            {
                type    = "checkbox",
                name    = "Show 3D Icon" .. s .. " for " .. description .. s,
                default = DEFAULT[role].show,
                getFunc = function() return OPTIONS[role].show end,
                setFunc = function( newValue ) OPTIONS[role].show = newValue end,
            },
        }

        if DEFAULT[role].dead ~= nil then
            local deadOption = {
                {
                    type    = "checkbox",
                    name    = "Use dead Group Member Icon",
                    default = DEFAULT[role].dead,
                    getFunc = function() return OPTIONS[role].dead end,
                    setFunc = function( newValue ) OPTIONS[role].dead = newValue end,
                },
            }
            OSI.TableAppend( roleOptions, deadOption )
        end

        if DEFAULT[role].priority ~= nil then
            local priorityOption = {
                {
                    type     = "checkbox",
                    name     = "Prioritize over " .. ( role == OSI.ROLE_DEAD and "other" or "custom" ) .. " Icons",
                    default  = DEFAULT[role].priority,
                    getFunc  = function() return OPTIONS[role].priority end,
                    setFunc  = function( newValue ) OPTIONS[role].priority = newValue; OSI.RefreshData() end,
                },
            }
            OSI.TableAppend( roleOptions, priorityOption )
        end

        if DEFAULT[role].usesize ~= nil then
            local sizeOptions = {
                {
                    type     = "checkbox",
                    name     = "Use custom Icon Size",
                    default  = DEFAULT[role].usesize,
                    getFunc  = function() return OPTIONS[role].usesize end,
                    setFunc  = function( newValue ) OPTIONS[role].usesize = newValue end,
                    disabled = function() return not OPTIONS[role].show end,
                },
                {
                    type     = "slider",
                    name     = "Custom Icon Size",
                    tooltip  = "Width/height in pixels, if scaling is turned on, chosen size will apply around 10m in front of the camera",
                    min      = 32,
                    max      = 256,
                    step     = 4,
                    default  = DEFAULT[role].size,
                    getFunc  = function() return OPTIONS[role].size end,
                    setFunc  = function( newValue ) OPTIONS[role].size = newValue end,
                    disabled = function() return not OPTIONS[role].show or not OPTIONS[role].usesize end,
                },
            }
            OSI.TableAppend( roleOptions, sizeOptions )
        end

        if DEFAULT[role].useoff ~= nil then
            local offOptions = {
                {
                    type     = "checkbox",
                    name     = "Use custom vertical Offset",
                    default  = DEFAULT[role].useoff,
                    getFunc  = function() return OPTIONS[role].useoff end,
                    setFunc  = function( newValue ) OPTIONS[role].useoff = newValue end,
                },
                {
                    type     = "slider",
                    name     = "Custom vertical Offset",
                    tooltip  = "Distance from ground to icon bottom in meters",
                    min      = 0.0,
                    max      = 5.0,
                    step     = 0.1,
                    decimals = 2,
                    default  = DEFAULT[role].offset,
                    getFunc  = function() return OPTIONS[role].offset end,
                    setFunc  = function( newValue ) OPTIONS[role].offset = newValue end,
                },
            }
            OSI.TableAppend( roleOptions, offOptions )
        end

        local iconOptions = role ~= OSI.ROLE_DEAD and {
            {
                type     = "colorpicker",
                name     = "Icon Color",
                default  = { r = DEFAULT[role].color[1], g = DEFAULT[role].color[2], b = DEFAULT[role].color[3] },
                getFunc  = function() return unpack( OPTIONS[role].color ) end,
                setFunc  = function( r, g, b, a ) OPTIONS[role].color = { r, g, b }; UpdateControlColor( role ); OSI.RefreshData() end,
            },
            {
                type       = "iconpicker",
                name       = "Texture",
                osirole    = role,
                iconSize   = 48,
                maxColumns = 5,
                default    = DEFAULT[role].icon,
                getFunc    = function() return OPTIONS[role].icon end,
                setFunc    = function( newValue ) OPTIONS[role].icon = newValue; OSI.RefreshData() end,
                choices    = ICONS_GROUP,
            },
        } or {
            {
                type     = "colorpicker",
                name     = "Icon Color while beeing dead",
                default  = { r = DEFAULT[role].color[1], g = DEFAULT[role].color[2], b = DEFAULT[role].color[3] },
                getFunc  = function() return unpack( OPTIONS[role].color ) end,
                setFunc  = function( r, g, b, a ) OPTIONS[role].color = { r, g, b }; UpdateControlColor( role ); OSI.RefreshData() end,
            },
            {
                type     = "colorpicker",
                name     = "Icon Color while beeing resurrected",
                default  = { r = DEFAULT[role].colrez[1], g = DEFAULT[role].colrez[2], b = DEFAULT[role].colrez[3] },
                getFunc  = function() return unpack( OPTIONS[role].colrez ) end,
                setFunc  = function( r, g, b, a ) OPTIONS[role].colrez = { r, g, b }; OSI.RefreshData() end,
            },
            {
                type     = "colorpicker",
                name     = "Icon Color with pending resurrection",
                default  = { r = DEFAULT[role].colrdy[1], g = DEFAULT[role].colrdy[2], b = DEFAULT[role].colrdy[3] },
                getFunc  = function() return unpack( OPTIONS[role].colrdy ) end,
                setFunc  = function( r, g, b, a ) OPTIONS[role].colrdy = { r, g, b }; OSI.RefreshData() end,
            },
            {
                type       = "iconpicker",
                name       = "Texture",
                osirole    = role,
                iconSize   = 48,
                maxColumns = 5,
                default    = DEFAULT[role].icon,
                getFunc    = function() return OPTIONS[role].icon end,
                setFunc    = function( newValue ) OPTIONS[role].icon = newValue; OSI.RefreshData() end,
                choices    = ICONS_GROUP,
            },
        }

        -- disabled functions for allies
        if DEFAULT[role].priority == nil then
            if #roleOptions > 2 then
                roleOptions[3].disabled = function() return not OPTIONS[role].show end
            end
            iconOptions[1].disabled = function() return not OPTIONS[role].show end
            iconOptions[2].disabled = function() return not OPTIONS[role].show end
        end

        OSI.TableAppend( roleOptions, iconOptions )
        OSI.TableAppend( groupIconOptions, roleOptions )
    end

    -- not used atm, maybe use it for group member companions later...
    -- RoleOptions( OSI.ALLY_COMPANION, "Companion" )

    -- ally icon options
    RoleOptions( OSI.ALLY_BANKER,  "Banker" )
    RoleOptions( OSI.ALLY_VENDOR,  "Merchant" )
    RoleOptions( OSI.ALLY_FENCE,   "Fence" )
    RoleOptions( OSI.ALLY_ARMORY,  "Armory Assistant" )
    RoleOptions( OSI.ALLY_DECON,   "Deconstruction Assistant" )
    RoleOptions( OSI.ALLY_BASTIAN, "Bastian Hallix" )
    RoleOptions( OSI.ALLY_MIRRI,   "Mirri Elendis" )
    RoleOptions( OSI.ALLY_ISOBEL, "Isobel Veloise" )
    RoleOptions( OSI.ALLY_EMBER,  "Ember" )
    RoleOptions( OSI.ALLY_SHARP, "Sharp-as-Night" )
    RoleOptions( OSI.ALLY_AZANDAR,  "Azandar al-Cybiades" )
    RoleOptions( OSI.ALLY_TANLORIN,  "Tanlorin" )
    RoleOptions( OSI.ALLY_ZERITHVAR,  "Zerith-var" )


    local allyIconOptions = groupIconOptions

    -- role icon options
    groupIconOptions = {}
    RoleOptions( OSI.ROLE_LEAD, "Leader" )
    RoleOptions( OSI.ROLE_TANK, "Tank" )
    RoleOptions( OSI.ROLE_HEAL, "Healer" )
    RoleOptions( OSI.ROLE_DPS,  "Damage Dealer" )
    RoleOptions( OSI.ROLE_BG,   "Battleground Team Member" )
    RoleOptions( OSI.ROLE_DEAD, "Dead Player" )

    -- custom icon options
    local customIconOptions = {
        {
            type  = "description",
            text  = "",
        },
        {
            type  = "description",
            text  = "To assign custom icons to individual players, right-click on that person in your group window, friends list or guild roster and select |c00ffffAssign Custom Icon|r. Right-click again to |c00ffffChange Custom Icon|r or |c00ffffRemove Custom Icon|r.\n",
        },
        {
            type  = "divider",
        },
        {
            type    = "checkbox",
            name    = "Show custom 3D Icons",
            default = DEFAULT.customuse,
            getFunc = function() return OPTIONS.customuse end,
            setFunc = function( newValue ) OPTIONS.customuse = newValue end,
        },
        {
            type     = "checkbox",
            name     = "Remember assigned Icons",
            default  = DEFAULT.save,
            getFunc  = function() return OPTIONS.save end,
            setFunc  = function( newValue ) OPTIONS.save = newValue end,
        },
        {
            type    = "button",
            name    = "Clear Group",
            width   = "half",
            func    = function() OSI.CacheClearIcons( false ) end,
            warning = "This will remove all assigned icons for your current group members.",
        },
        {
            type    = "button",
            name    = "Empty Cache",
            width   = "half",
            func    = function() OSI.CacheClearIcons( true ) end,
            warning = "This will remove all previously cached icons for individual players.",
        },
    }

    -- unique and LibCustomIcons icon options
    local uniqueIconOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
			type = "description",
            text = "Unique icons are automatically assigned to the respective player and can not be removed. If you don't want to see them, simply turn off the option to show them.",
		},
        {
			type = "description",
            text = "Requires |cffff00LibCustomIcons|r to be active if you want to show the icons and animations provided by this addon.\n",
        },
        {
            type  = "divider",
        },
        {
            type     = "checkbox",
            name     = "Show unique 3D Icons",
            default  = not DEFAULT.ignore,
            getFunc  = function() return not OPTIONS.ignore end,
            setFunc  = function( newValue ) OPTIONS.ignore = not newValue end,
        },
        {
        disabled = function() return OPTIONS.ignore end,
        type     = "checkbox",
        name     = "Show Own Icon",
        default  = DEFAULT.showOwnIcon,
        getFunc  = function() return OPTIONS.showOwnIcon end,
        setFunc  = function( newValue ) OPTIONS.showOwnIcon = newValue end,
        },
        {
            type     = "checkbox",
            name     = "Use LibCustomIcons Icons",
            default  = DEFAULT.hodoruse,
            getFunc  = function() return OPTIONS.hodoruse end,
            setFunc  = function( newValue ) OPTIONS.hodoruse = newValue; OSI.RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Use LibCustomIcons Animations",
            default  = DEFAULT.hodoranim,
            getFunc  = function() return OPTIONS.hodoranim end,
            setFunc  = function( newValue ) OPTIONS.hodoranim = newValue; OSI.RefreshData() end,
            disabled = function() return not OPTIONS.hodoruse end,
        },
        {
            type     = "checkbox",
            name     = "Prioritize LibCustomIcons over unique Icons",
            default  = DEFAULT.hodorprio,
            getFunc  = function() return OPTIONS.hodorprio end,
            setFunc  = function( newValue ) OPTIONS.hodorprio = newValue; OSI.RefreshData() end,
            disabled = function() return not OPTIONS.hodoruse end,
        },
    }

--[[     -- raid icon options
    local raidIconOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
			type = "description",
            text = "Experimental feature allowing group leaders to force raid specific icons on group members. |cffff00LibCustomIcons|r is required to share the icon information amongst the group.",
		},
        {
			type = "description",
            text = "Make sure that your group is ready and everbody is online since icon information is only shared when an icon gets assigned. Once a group member disconnects or reloads the UI, raid icons are lost for this person. Group leaders can share already assigned icons again by clicking on |c00ffffChange Raid Icon|r and pressing the |c00ffffSave|r button.\n",
		},
        {
            type  = "divider",
        },
        {
            type     = "checkbox",
            name     = "Show Raid Icons assigned by Group Lead",
            default  = DEFAULT.raidallow,
            getFunc  = function() return OPTIONS.raidallow end,
            setFunc  = function( newValue ) OPTIONS.raidallow = newValue; OSI.OverloadAIGW(); GROUP_LIST:RefreshData(); ZO_WorldMap_RefreshGroupPins(); end,
        },
        {
            type     = "checkbox",
            name     = "Activate Context Menu for Group Lead",
            default  = DEFAULT.raidforce,
            getFunc  = function() return OPTIONS.raidforce end,
            setFunc  = function( newValue ) OPTIONS.raidforce = newValue end,
            disabled = function() return not OPTIONS.raidallow end,
        },
    } ]]

    -- world map options
    local worldmapOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
			type = "description",
            text = "Shows your group members icons on the World Map as well as on |cffff00Votan's Minimap|r but does not work with |cffff00Minimap by Fyrakin|r.\n",
		},
        {
            type  = "divider",
        },
        {
            type     = "checkbox",
            name     = "Show custom Icons",
            default  = DEFAULT.wmuse,
            getFunc  = function() return OPTIONS.wmuse end,
            setFunc  = function( newValue ) OPTIONS.wmuse = newValue; ZO_WorldMap_RefreshGroupPins() end,
        },
        {
            type     = "checkbox",
            name     = "Show unique Icons",
            default  = DEFAULT.wmunique,
            getFunc  = function() return OPTIONS.wmunique end,
            setFunc  = function( newValue ) OPTIONS.wmunique = newValue; ZO_WorldMap_RefreshGroupPins() end,
        },
        {
            type     = "checkbox",
            name     = "Show dead Group Member Icons",
            default  = DEFAULT.wmdead,
            getFunc  = function() return OPTIONS.wmdead end,
            setFunc  = function( newValue ) OPTIONS.wmdead = newValue; ZO_WorldMap_RefreshGroupPins() end,
        },
        {
            type     = "checkbox",
            name     = "Show Group Role Icons",
            default  = DEFAULT.wmroles,
            getFunc  = function() return OPTIONS.wmroles end,
            setFunc  = function( newValue ) OPTIONS.wmroles = newValue; ZO_WorldMap_RefreshGroupPins() end,
        },
        {
            type     = "slider",
            name     = "Icon Size",
            min      = 16,
            max      = 48,
            step     = 1,
            default  = DEFAULT.wmsize,
            getFunc  = function() return OPTIONS.wmsize end,
            setFunc  = function( newValue ) OPTIONS.wmsize = newValue; ZO_WorldMap_RefreshGroupPins() end,
        },
    }

    -- chat window options
    local chatwindowOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
			type = "description",
            text = "Modifies incoming Chat Messages and adds icons to Display Names. Also shows icons for Character Names but the respective player needs to be on your Friends List, in your Group or one of your Guilds. Any changes to settings will only apply to upcoming Chat Messages.\n",
		},
        {
            type  = "divider",
        },
        {
            type     = "checkbox",
            name     = "Show custom Icons",
            default  = DEFAULT.cwuse,
            getFunc  = function() return OPTIONS.cwuse end,
            setFunc  = function( newValue ) OPTIONS.cwuse = newValue end,
        },
        {
            type     = "checkbox",
            name     = "Show unique Icons",
            default  = DEFAULT.cwunique,
            getFunc  = function() return OPTIONS.cwunique end,
            setFunc  = function( newValue ) OPTIONS.cwunique = newValue end,
        },
        {
            type     = "slider",
            name     = "Icon Size",
            min      = 16,
            max      = 48,
            step     = 1,
            default  = DEFAULT.cwsize,
            getFunc  = function() return OPTIONS.cwsize end,
            setFunc  = function( newValue ) OPTIONS.cwsize = newValue; d( "|t" .. newValue .. ":" .. newValue .. ":odysupporticons/icons/twp/lamierina7.dds|t Chat Window Icon Size set to " .. newValue .. "px" ) end,
        },
    }

    -- group window options
    local groupwindowOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
            type     = "checkbox",
            name     = "Show custom Icons",
            default  = DEFAULT.gwuse,
            getFunc  = function() return OPTIONS.gwuse end,
            setFunc  = function( newValue ) OPTIONS.gwuse = newValue; OSI.OverloadAIGW(); GROUP_LIST:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show unique Icons",
            default  = DEFAULT.gwunique,
            getFunc  = function() return OPTIONS.gwunique end,
            setFunc  = function( newValue ) OPTIONS.gwunique = newValue; OSI.OverloadAIGW(); GROUP_LIST:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show dead Group Member Icons",
            default  = DEFAULT.gwdead,
            getFunc  = function() return OPTIONS.gwdead end,
            setFunc  = function( newValue ) OPTIONS.gwdead = newValue; OSI.OverloadAIGW(); GROUP_LIST:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show Group Role Icons",
            default  = DEFAULT.gwroles,
            getFunc  = function() return OPTIONS.gwroles end,
            setFunc  = function( newValue ) OPTIONS.gwroles = newValue; OSI.OverloadAIGW(); GROUP_LIST:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show Crown Overlay",
            default  = DEFAULT.gwcrown,
            getFunc  = function() return OPTIONS.gwcrown end,
            setFunc  = function( newValue ) OPTIONS.gwcrown = newValue; OSI.OverloadAIGW(); GROUP_LIST:RefreshData() end,
        },
    }

    -- friends list options
    local friendslistOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
            type     = "checkbox",
            name     = "Show custom Icons",
            default  = DEFAULT.fluse,
            getFunc  = function() return OPTIONS.fluse end,
            setFunc  = function( newValue ) OPTIONS.fluse = newValue; FRIENDS_LIST_MANAGER:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show unique Icons",
            default  = DEFAULT.flunique,
            getFunc  = function() return OPTIONS.flunique end,
            setFunc  = function( newValue ) OPTIONS.flunique = newValue; FRIENDS_LIST_MANAGER:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show Player Status Overlay",
            default  = DEFAULT.flstatus,
            getFunc  = function() return OPTIONS.flstatus end,
            setFunc  = function( newValue ) OPTIONS.flstatus = newValue; FRIENDS_LIST_MANAGER:RefreshData() end,
        },
    }

    -- guild roster options
    local guildrosterOptions = {
        {
			type  = "description",
			text  = "",
        },
        {
            type     = "checkbox",
            name     = "Show custom Icons",
            default  = DEFAULT.gruse,
            getFunc  = function() return OPTIONS.gruse end,
            setFunc  = function( newValue ) OPTIONS.gruse = newValue; GUILD_ROSTER_MANAGER:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show unique Icons",
            default  = DEFAULT.grunique,
            getFunc  = function() return OPTIONS.grunique end,
            setFunc  = function( newValue ) OPTIONS.grunique = newValue; GUILD_ROSTER_MANAGER:RefreshData() end,
        },
        {
            type     = "checkbox",
            name     = "Show Player Status Overlay",
            default  = DEFAULT.grstatus,
            getFunc  = function() return OPTIONS.grstatus end,
            setFunc  = function( newValue ) OPTIONS.grstatus = newValue; GUILD_ROSTER_MANAGER:RefreshData() end,
        },
    }

	local optionsTable = {
		{
			type = "description",
            text = "This addon shows icons for players in your group and works in dungeons and trials as well as when hiding group members with the Crown Crate trick.",
		},
		{
			type = "description",
            text = "Use the |cffff00/osi|r command to open the addon settings, settings are saved account-wide. Don't forget to assign a |c00ffffkeybinding|r in your controls settings to quickly toggle icon visibility.\n",
		},
        {
            type     = "submenu",
            name     = "|cfffacdGENERAL SETTINGS|r",
            controls = icon3dOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdGROUP ICONS|r",
            controls = groupIconOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdALLY ICONS|r",
            controls = allyIconOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdCUSTOM ICONS|r",
            controls = customIconOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdUNIQUE ICONS|r",
            controls = uniqueIconOptions,
        },
--[[         {
            type     = "submenu",
            name     = "|cfffacdRAID ICONS|r |cff0000BETA|r",
            controls = raidIconOptions,
        }, ]]
        {
            type     = "submenu",
            name     = "|cfffacdWORLD MAP|r",
            controls = worldmapOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdGROUP WINDOW|r",
            controls = groupwindowOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdCHAT WINDOW|r",
            controls = chatwindowOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdFRIENDS LIST|r",
            controls = friendslistOptions,
        },
        {
            type     = "submenu",
            name     = "|cfffacdGUILD ROSTER|r",
            controls = guildrosterOptions,
        },
        -- end of options
        {
            type = "description",
            text = "",
        },
    }

	LAM:RegisterAddonPanel( OSI.name .. "Options", panelData )
	LAM:RegisterOptionControls( OSI.name .. "Options", optionsTable )
end
