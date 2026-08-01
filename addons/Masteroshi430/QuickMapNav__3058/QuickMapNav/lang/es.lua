
local strings = {
	DEFAULT_TOPLEFT = "Nombres de zona y hora arriba a la izquierda",
	PERFECT_PIXEL = "Útil para usuarios de PerfectPixel ;-)",
	LESS_FLASHY = "Brillo del mapa",
	LESS_FLASHY_TOOLTIP = "Atenúa el brillo del mapa para reducir el daño ocular durante la noche.\n87 está bien\n100 es la configuración predeterminada de ESO",
	DESATURATION = "Desaturación del mapa",
	DESATURATION_TOOLTIP = "Desaturar los colores del mapa.\n20 está bien\n0 esta es la configuración predeterminada de ESO",
	SECONDS = "Forzar formato 24h con segundos en el reloj de la tarjeta",
	SECONDS_TOOLTIP = ":-)",
	TO = "A ",
	WAYSHRINE = "Ermita",
	WAYSHRINE_ONLY = "Solo se puede visitar a través de una ermita.",
	ABBR = "Castillos Abreviados",
	ABBR_TOOLTIP = "Muestre el nombre internacional abreviado de los castillos en Cyrodiil.",
}

for stringId, stringValue in pairs(strings) do
	ZO_CreateStringId(stringId, stringValue)
	SafeAddVersion(stringId, 1)
end