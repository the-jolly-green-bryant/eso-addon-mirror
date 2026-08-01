--	Bindings
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_OVERRIDE_SMART", "Sobreescribir robo automático")
ZO_CreateStringId("SI_BINDING_NAME_NTLOOT_TOGGLE_AUTOLOOT", "Activar/desactivar saqueo automático")


--	Options
NTLnS_Texts = {
	choices = {
		hPosition = {
			"Izquierda",
			"Centro",
			"Derecha",
		},
		vPosition = {
			"Arriba",
			"Centro",
			"Abajo",
		}
	},
	actions = {
		take	= "Coger",
		use		= "Usar",
	},
	insects = {
		"Mariposa",
		"Torchbug",
		"Avispa",
		"Moscas",
		"Luciérnaga",
		"Netch Calf",
		"Fetcherfly",
		"Seth's Dovah-Fly",
	},
	seats = {
		"Asiento",
	},
	isNeeded	= " necesita ser activado.",
	align		= "Alineación",
	alpha		= "Opacidad",
	cat00 = {
		title	= "OPCIONES CROSS-CHARACTERS",
	},
	cat0 = {
		title	= "OPCIONES DE SAQUEO PREFERIDAS",
		desc0	= "Estas opciones sobreescriben las opciones de saqueo normales.",
		opt1	= "Auto saqueo",
		opt2	= "Auto saquear ítems robados",
	},
	cat1 = {
		title	= "AJUSTES DE SAQUEO",
		opt1	= "Prevenir autosaquear si tienes poco espacio",
		warn1	= "Las opciones de “Auto saquear ítems” se cambiarán dinámicamente.",
		opt1b	= "Límite bajo para el espacio del inventario",
		opt11	= "Esconder la interacción para containers vacíos",
		opt12	= "Esconder la interacción para insectos",
	},
	cat2 = {
		title	= "AJUSTES DE ROBAR",
		opt1	= "Usar “Robo inteligente”",
		opt1b	= "Override by double-tap (in ms)",	-- TO DO
		warn1	= "“Auto saquear ítems robados” se cambiará dinámicamente.",
		desc1	= "“Robo inteligente” puede prevenir robos no intencionados o accidentales.\nSi no estás oculto, los contenedores se abrirán pero no se saquearán,\ny prevendrá robar directamente a la gente o en el mundo.\nNota: Puede vincularse una tecla para sobreescribir (mantener pulsado para sobreescribir).",
		menu	= "Opciones avanzadas",
			desc10	= "Elige activar o desactivar “Robo inteligente” para acciones específicas.\n¡No le eches la culpa si te atrapan!",
			opt10	= "Usar opciones avanzadas",
			opt11	= "Usar “Robo inteligente” para contenedores",
			opt11b	= "Usar “Robo inteligente” para forzar cerraduras",
			opt12	= "Usar “Robo inteligente” para ítems de mundo",
			opt13	= "Usar “Robo inteligente” para robar carteras",
		opt2	= "Vinculación de teclas al prevenir un robo", -- icon ..
		opt2b	= "Posición alternativa para ", -- .. icon
		opt3	= "Mostrar tiempos de busca y captura",
		opt4	= "Impedir la acción de sentarse estando oculto",
	},
	cat3 = {
		title	= "PANTALLA DE INFORMACIÓN",
		sub0	= "EN INVENTARIO",
			opt01	= "Reemplazar “Espacio de inventario” por ", -- .. icon
			opt02	= "Añadir el filtro de “Robado” en el inventario",
			opt03	= "Skip a line (compatibility with other addons)",
			-- opt02tt = "¡Requiere la biblioteca \'LibFilters 3.0\' instalada y activada!",
		sub1	= "EN LA VENTANA DE SAQUEO",
		sub2	= "CONTENIDO",
			opt21	= "Num. de espacios usados …",
			opt21b	= "Num. de ítems robados",
			opt22	= "Num. de ítems vendidos …",
			opt23	= "Num. de ítems blanqueados …",
			opt223	= "Agrupar vendidos y blanqueados",
			optRed	= "… en rojo si está por debajo de:",
			opt24	= "Tiempo de reinicio para ventas/blanqueamiento",
	},
}