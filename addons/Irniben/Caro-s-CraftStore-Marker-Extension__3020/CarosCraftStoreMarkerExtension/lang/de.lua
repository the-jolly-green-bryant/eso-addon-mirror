local L = {}

L.CCSME_IconChoose = "Icon auswählen"
L.CCSME_IconColorDescr = "Das Einfärben des Icons kann eventuell zu Problemen mit anderen Chat-Addons wie pChat etc. führen und ist daher optional."
L.CCSME_IconColorize = "Icon einfärben"
L.CCSME_IconColorChoose = "Farbe auswählen"
L.CCSME_ShowKnownByAll = "Zeige Haken im Tooltip, wenn alle Charaktere ein Rezept/eine Stilseite kennen"
L.CCSME_ShowKnownByAllCustomColor = "Farbe"
L.CCSME_ShowKnownByAllUseCustomColor = "Verwende benutzerdefinierte Farbe"
L.CCSME_AutoMarkKnownByAllAsJunk = "Markiere diese Stilseiten/Rezepte automatisch als permamenten Trödel in PersonalAssistant (wird angewendet, sobald der Tooltip gezeigt wird)"
L.CCSME_UnmarkUnknownJunk = "Rezepte/Stilseiten, die der aktuelle Charakter nicht kennt, nicht mehr als permanenten Trödel markieren"

for stringId, stringValue in pairs(L) do
	SafeAddString(_G[stringId], stringValue, 0)
end