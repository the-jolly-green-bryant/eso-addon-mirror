AetheriusBadgeFilter:RegisterGuild(AetheriusBadgeFilter.SERVER_EU, "Your Guild Name", {
    {
        badges = {
            {
                name = "MyBadge", -- mandatory field, this name must match what is used in the badge list
                description = "My Description", -- optional, shows a tooltip when hovering the mouse over the entry in the filter list
                color = "FF0000", -- optional, if not specified it will use the first color found in the notes, or a grey color if the badge is not in use
                relations = {"MyOtherBadge"}, -- optional, allows to show other badges simultaneously when this badge is selected
                limit = 1, -- optional, sets an upper limit for the member badge editor when incrementing badges. Defaults to 1 and can be turned off by setting it to false
                turnsInto = "MyOtherBadge", -- optional, tells the member badge editor that the badge should turn into a different badge when the limit is reached
            },
            {
                name = "MyOtherBadge",
                limit = false,
            },
        }
    },
    {
        name = "MyGroup", -- optional, groups without a name do not have a header. This is only really useful for the first group in the list.
        description = "My Group Description", -- optional, shows a tooltip when hovering the mouse over the entry in the filter list
        badges = {
            {
                name = "MyGroupBadge",
            },
        }
    },
})
