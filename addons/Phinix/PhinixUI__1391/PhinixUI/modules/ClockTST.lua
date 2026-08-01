
function PUIAddon.ClockTST()

----------------------------------------------------------------------------------------------------------------
-- Initialize Saved Variable Database Reference
----------------------------------------------------------------------------------------------------------------
	local db = ClockTST_Settings.Default[GetDisplayName()]["$AccountWide"]

----------------------------------------------------------------------------------------------------------------
-- Configure Addon Settings
----------------------------------------------------------------------------------------------------------------
	booleans = {
		moon = {
			isMovable = true,
			hasTooltip = true,
			isMouseEnabled = true,
			isVisible = true,
			hasBackground = true,
			highlightWhenHover = false,
			scaleWhenHover = true,
		},
		time = {
			hasJapFormat = false,
			isMouseEnabled = true,
			addZeroMin = true,
			highlightWhenHover = true,
			hasFakeLoreDate = true,
			addZeroDay = false,
			isVisible = true,
			hasBackground = false,
			addZeroMonth = false,
			hasTooltip = true,
			isMovable = false,
			addZero = false,
			hasUSFormat = true,
			addZeroSec = true,
			addZeroHour = false,
			ampm = true,
			hasLoreDate = true,
			hasRealDate = false,
			minAMPM = true,
			scaleWhenHover = false,
		},
		core = {
			timeAndMoonAreLinked = false,
			hideInGroup = false,
			hideInFight = true,
			onlyShowOnMap = false,
		},
	}
	account = {
		saveAccountWide = true,
	}
	styles = {
		moon = {
			secunda = "Ghost",
			masser = "Pale",
			backgroundColour = {
				a = 0.5000000000,
				r = 0,
				b = 0.0823529412,
				g = 0,
			},
			alpha = 1,
			backgroundHoverColour = {
				a = 0.6600000000,
				r = 0.3450980392,
				b = 0.7176470588,
				g = 0.6470588235,
			},
			background = "Solid",
		},
		time = {
			backgroundColour = {
				a = 0,
				r = 0.0784313753,
				b = 0.0784313753,
				g = 0.0784313753,
			},
			size = 18,
			background = "EsoUI-Item",
			font = "Univers 67",
			colour = {
				a = 0.8606557250,
				r = 1,
				b = 1,
				g = 1,
			},
			backgroundHoverColour = {
				a = 0.6600000000,
				r = 0.3450980392,
				b = 0.7176470588,
				g = 0.6470588235,
			},
			format = "#H:#M #p",
			lineCount = 1,
			style = "soft-shadow-thick",
			backgroundOffset = {
				x = 0,
				y = 0,
			},
		},
	}
	presets = {
		saved = {
			["Small"] = {
				booleans = {
					moon = {
						isMovable = false,
						highlightWhenHover = true,
						scaleWhenHover = false,
					},
					time = {
						isMovable = false,
						hasFakeLoreDate = true,
						addZero = true,
						hasUSFormat = false,
						hasBackground = false,
						highlightWhenHover = false,
					},
					core = {
						hideInGroup = true,
					},
				},
				attributes = {
					time = {
						dimension = {
							height = 80,
							width = 102.8571428571,
						},
						anchor = {
							offsetY = 17,
							offsetX = 1776.2143554688,
						},
					},
					moon = {
						dimension = {
							height = 331,
						},
						scale = 0.3800000000,
						anchor = {
							offsetY = 8,
							offsetX = 1778.4240722656,
						},
					},
				},
				styles = {
					time = {
						font = "Futura Condensed",
						backgroundOffset = {
							y = 20,
						},
						format = "%H:%M:%S\n#H:#M:#S",
						lineCount = 1,
						colour = {
							a = 0.8823529482,
							r = 0,
							b = 0.9647058845,
							g = 1,
						},
						size = 24,
					},
					moon = {
						backgroundColour = {
							a = 0.7500000000,
						},
					},
				},
			},
			["Map"] = {
				booleans = {
					moon = {
						isMovable = false,
						highlightWhenHover = true,
						scaleWhenHover = false,
					},
					time = {
						isMovable = false,
						hasFakeLoreDate = true,
					},
					core = {
						hideInFight = false,
						onlyShowOnMap = true,
					},
				},
				attributes = {
					time = {
						dimension = {
							height = 40,
							width = 360,
						},
						anchor = {
							offsetY = 949,
							offsetX = 506.4999869211,
						},
					},
					moon = {
						scale = 0.3400000000,
						anchor = {
							offsetY = 910,
							offsetX = 469,
						},
					},
				},
				styles = {
					time = {
						format = "#A, #d #B #Y #H:#M -- %H:%M",
						lineCount = 1,
						size = 16,
					},
					moon = {
						masser = "Crimson",
						background = "Brush",
					},
				},
			},
		},
	}
	attributes = {
		moon = {
			dimension = {
				height = 311,
				width = 336,
			},
			masser = {
				dimension = {
					height = 256,
					width = 256,
				},
				anchor = {
					offsetX = 0,
					relativePoint = 3,
					relativeTo = "Clock_TST_Moon",
					point = 3,
					offsetY = 0,
				},
			},
			scale = 0.0900000000,
			anchor = {
				offsetX = 10.4285583496,
				relativeTo = "GuiRoot",
				offsetY = 1406.5000000000,
				point = 3,
			},
			secunda = {
				dimension = {
					height = 160,
					width = 160,
				},
				anchor = {
					offsetX = 0,
					relativePoint = 12,
					relativeTo = "Clock_TST_Moon",
					point = 12,
					offsetY = 0,
				},
			},
		},
		time = {
			dimension = {
				height = 45,
				width = 67.5000000000,
			},
			anchor = {
				offsetX = 39.1786248341,
				relativeTo = "GuiRoot",
				offsetY = 1400,
				point = 3,
			},
		},
		core = {
			scaleFactor = 1.1000000000,
		},
	}

end
