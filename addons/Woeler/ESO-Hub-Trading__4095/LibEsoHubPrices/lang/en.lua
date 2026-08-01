local strings = { 
    -- Localization Start

    -- Item Tooltip

    EHP_STRING_TOOLTIP_TITLE            = "ESO-Hub.com <<C:1>> Data",
    EHP_STRING_TOOLTIP_TITLE_DURATION   = " (Last 14 days)",
    EHP_STRING_TOOLTIP_AVERAGE          = "Average price: <<1>>",
    EHP_STRING_TOOLTIP_LISTINGS         = "<<1>> - <<2>> in <<3>> <<4>>",
    EHP_STRING_TOOLTIP_SUGGESTED_SINGLE = "Suggested price: <<1>>",
    EHP_STRING_TOOLTIP_SUGGESTED_RANGE  = "Suggested price: <<1>> - <<2>>",
    EHP_STRING_TOOLTIP_TIMESTAMP        = "Price data from <<1>>, <<2>>",

    -- Settings

    EHP_STRING_SETTING_ACCOUNTWIDE                    = "Account-wide Settings",
    EHP_STRING_SETTING_INVENTORY                      = "Inventory",
    EHP_STRING_SETTING_INVENTORY_TOOLTIP              = "Display suggested auction prices in inventory instead of their NPC selling value.",
    EHP_STRING_SETTING_INVENTORY_TOOLTIP_DISABLED     = "Display suggested auction prices in inventory instead of their NPC selling value.\nSetting disabled due to conflicting option in: <<1>>\nAfter disabling the conflicting setting(s) a UI reload is required to enable this setting.",
    -- EHP_STRING_SETTING_USESALESDATA                   = "Use sales data",
    -- EHP_STRING_SETTING_USESALESDATA_TOOLTIP           = "Use data from item sales instead of data from item listings.",
    EHP_STRING_SETTING_LISTINGS_TOOLTIP               = "Listing Tooltips",
    EHP_STRING_SETTING_LISTINGS_TOOLTIP_TOOLTIP       = "Show listing price information in item tooltips",
    EHP_STRING_SETTING_SALES_TOOLTIP                  = "Sales Tooltips",
    EHP_STRING_SETTING_SALES_TOOLTIP_TOOLTIP          = "Show sales price information in item tooltips",
    EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT         = "Context Menu: Post to Chat",
    EHP_STRING_SETTING_CONTEXTMENU_POSTTOCHAT_TOOLTIP = "Add a context menu entry to inventory and item links to post ESO-Hub.com price data to chat",
    EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE         = "Context Menu: View Online",
    EHP_STRING_SETTING_CONTEXTMENU_VIEWONLINE_TOOLTIP = "Add a context menu entry to inventory and item links to view the item on ESO-Hub.com",

    -- Inventory Context Menu

    EHP_STRING_CONTEXTMENU_POSTTOCHAT_LISTINGS  = "ESO-Hub Listing Price to Chat",
    EHP_STRING_CONTEXTMENU_POSTTOCHAT_SALES     = "ESO-Hub Sales Price to Chat",
    EHP_STRING_CONTEXTMENU_POSTTOCHAT_FORMAT    = "ESO-Hub.com price for <<1>>: <<2>> (<<3>> <<4>>)", -- <<1>> itemLink, <<2>> suggested/average price, <<3>> number of listings <<4>> 'sales' or 'listings')
    EHP_STRING_SALES                            = "sales",
    EHP_STRING_LISTINGS                         = "listings",
    EHP_STRING_CONTEXTMENU_VIEWONLINE           = "View on ESO-Hub.com",
    EHP_STRING_CONTEXTMENU_VIEWONLINE_URLFORMAT = "https://ESO-Hub.com/<<1>>/trading-addon-redirect/<<2>>", -- <<1>> language, <<2>> Reduced Itemlink

    -- Slash Commands

    EHP_STRING_SLASHCOMMAND_HELP1 = "[LibEsoHubPrices] The following slash commands are available:",
    EHP_STRING_SLASHCOMMAND_HELP2 = "/ehp accountwide (on/off): Toggles account-wide settings",
    -- EHP_STRING_SLASHCOMMAND_HELP3 = "/ehp usesales (on/off): Use data from sales instead of listings",
    EHP_STRING_SLASHCOMMAND_HELP4 = "/ehp inventory (none/listings/sales): Toggles override of item values in the inventory", -- do not translate (none/listings/sales)
    EHP_STRING_SLASHCOMMAND_HELP5 = "/ehp listingstooltip (on/off): Toggles display of listing price information in inventory",
    EHP_STRING_SLASHCOMMAND_HELP6 = "/ehp salestooltip (on/off): Toggles display of sales price information in inventory",
    EHP_STRING_SLASHCOMMAND_HELP7 = "/ehp contextmenu chat (on/off): Toggles addition of a context menu entry to post ESO-Hub.com price data to chat",
    EHP_STRING_SLASHCOMMAND_HELP8 = "/ehp contextmenu online (on/off): Toggles addition of a context menu entry to view items on ESO-Hub.com",
    EHP_STRING_SLASHCOMMAND_HELP9 = "/ehp: Displays this help",

    EHP_STRING_SETTING_MESSAGE_INVENTORY              = "Override inventory item values in inventory",
    EHP_STRING_SETTING_MESSAGE_LISTING_TOOLTIP        = "Show listing price information in item tooltips",
    EHP_STRING_SETTING_MESSAGE_SALES_TOOLTIP          = "Show sales price information in item tooltips",
    EHP_STRING_SETTING_MESSAGE_ACCOUNTWIDE            = "Use account-wide settings",
    -- EHP_STRING_SETTING_MESSAGE_SALES                  = "Use data from sales instead of listings",
    EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_POSTTOCHAT = "Add a context menu entry to inventory and item links to post ESO-Hub.com price data to chat",
    EHP_STRING_SETTING_MESSAGE_CONTEXTMENU_VIEWONLINE = "Add a context menu entry to inventory and item links to view the item on ESO-Hub.com",

    EHP_STRING_ON  = "on",
    EHP_STRING_OFF = "off",

    -- Localization End
}

for stringId, stringValue in pairs(strings) do
    if _G[stringId] then 
        SafeAddString(_G[stringId], stringValue, 1)
    else
        ZO_CreateStringId(stringId, stringValue)
        SafeAddVersion(stringId, 1)
    end
end
