-- ONE global table for the whole addon (ESOUI best practice: a single, unique,
-- longish global; everything else is namespaced under it. Each other .lua file uses
-- `local STLxxx = Stylich.Xxx` at the top, and XML/Bindings reference Stylich.UI.* etc.)
Stylich = {}
Stylich.Model = {}
Stylich.UI = {}
Stylich.App = {}
Stylich.Lang = {}
Stylich.ESPD = {}
