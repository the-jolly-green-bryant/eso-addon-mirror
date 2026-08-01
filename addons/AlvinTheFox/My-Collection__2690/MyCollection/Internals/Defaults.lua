local Internals = MyCollection.Internals
Internals.Saved.Defaults = {}
local Defaults = Internals.Saved.Defaults
local Classes = Internals.Classes
local Constants = Internals.Constants

Defaults.Collection = {
    sets = {},
}
Defaults.Inventory = {
    banks = {
        [Constants.BagTypes.Bank] = {},
        [Constants.BagTypes.SubscriberBank] = {},
    },
    bags = {},
}
Defaults.Settings = {
    Logging = false,
    Window = {
        Position = {
            Left = 200,
            Top = 200,
        },
        Scale = 1,
    }
}