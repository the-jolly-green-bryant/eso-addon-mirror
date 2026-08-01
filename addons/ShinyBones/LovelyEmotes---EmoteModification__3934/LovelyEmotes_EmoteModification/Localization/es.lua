local _es = {
	SI_LE_EMOTEDATAMOD_ADD_BUTTON_TOOLTIP = "Agregar entrada",
	SI_LE_EMOTEDATAMOD_APPLY_BUTTON_TOOLTIP = "Guardar cambios y recargar",
	SI_LE_EMOTEDATAMOD_CANCEL_BUTTON_TOOLTIP = "Descartar cambios",
	SI_LE_EMOTEDATAMOD_CLEAN_BUTTON_TOOLTIP = "Elimina todas las entradas inválidas y vacías",

	SI_LE_EMOTEDATAMOD_CLEAN = "Limpiar",
	SI_LE_EMOTEDATAMOD_REPLACE_NAME = "Reemplazar nombre",
	SI_LE_EMOTEDATAMOD_SELECT_OR_ADD = "Seleccionar o agregar una entrada",
}

for k, v in pairs(_es) do
	SafeAddString(_G[k], v, 1)
end
