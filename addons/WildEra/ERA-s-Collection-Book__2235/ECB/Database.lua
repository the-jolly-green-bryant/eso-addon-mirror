
function ECB_ResetDatabase()
	ECB_InitializeCollectibles()
	ECB_LoadTracker()
end

function ECB_InitializeCategories()
	ECB.database = {}
	ECB.database.categories = {
		{ -- hats
			id = ECB.constants.categories.HATS,
			title = SI_ECB_TITLE_HATS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_HATS,
					body = ECB_TRACKER_CONTENT_BODY_HATS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_HATS_LIST_HAT_" },
				list = {
					{ id = 174, name = "", unlocked = false, label = nil }, { id = 220, name = "", unlocked = false, label = nil },
					{ id = 439, name = "", unlocked = false, label = nil }, { id = 440, name = "", unlocked = false, label = nil },
					{ id = 754, name = "", unlocked = false, label = nil }, { id = 755, name = "", unlocked = false, label = nil },
					{ id = 1107, name = "", unlocked = false, label = nil }, { id = 1248, name = "", unlocked = false, label = nil },
					{ id = 1338, name = "", unlocked = false, label = nil }, { id = 1339, name = "", unlocked = false, label = nil },
					{ id = 1368, name = "", unlocked = false, label = nil }, { id = 4692, name = "", unlocked = false, label = nil },
					{ id = 5016, name = "", unlocked = false, label = nil }, { id = 5019, name = "", unlocked = false, label = nil },
					{ id = 5235, name = "", unlocked = false, label = nil }, { id = 5911, name = "", unlocked = false, label = nil },
					{ id = 6398, name = "", unlocked = false, label = nil }, { id = 6438, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- markings
			id = ECB.constants.categories.MARKINGS,
			title = SI_ECB_TITLE_MARKINGS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_MARKINGS,
					body = ECB_TRACKER_CONTENT_BODY_MARKINGS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_MARKINGS_LIST_MARKING_" },
				list = {
					{ id = 1233, name = "", unlocked = false, label = nil }, { id = 1235, name = "", unlocked = false, label = nil },
					{ id = 1302, name = "", unlocked = false, label = nil }, { id = 1308, name = "", unlocked = false, label = nil },
					{ id = 5028, name = "", unlocked = false, label = nil }, { id = 5029, name = "", unlocked = false, label = nil },
					{ id = 5910, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- costumes
			id = ECB.constants.categories.COSTUMES,
			title = SI_ECB_TITLE_COSTUMES,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_COSTUMES,
					body = ECB_TRACKER_CONTENT_BODY_COSTUMES_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_COSTUMES_LIST_COSTUME_"
				},
				list = {
					{ id = 44, name = "", unlocked = false, label = nil }, { id = 47, name = "", unlocked = false, label = nil },
					{ id = 48, name = "", unlocked = false, label = nil }, { id = 49, name = "", unlocked = false, label = nil },
					{ id = 50, name = "", unlocked = false, label = nil }, { id = 206, name = "", unlocked = false, label = nil },
					{ id = 228, name = "", unlocked = false, label = nil }, { id = 229, name = "", unlocked = false, label = nil },
					{ id = 230, name = "", unlocked = false, label = nil }, { id = 252, name = "", unlocked = false, label = nil },
					{ id = 289, name = "", unlocked = false, label = nil }, { id = 358, name = "", unlocked = false, label = nil },
					{ id = 359, name = "", unlocked = false, label = nil }, { id = 753, name = "", unlocked = false, label = nil },
					{ id = 1166, name = "", unlocked = false, label = nil }, { id = 1230, name = "", unlocked = false, label = nil },
					{ id = 5589, name = "", unlocked = false, label = nil }, { id = 6292, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- skins
			id = ECB.constants.categories.SKINS,
			title = SI_ECB_TITLE_SKINS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_SKINS,
					body = ECB_TRACKER_CONTENT_BODY_SKINS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_SKINS_LIST_SKIN_"
				},
				list = {
					{ id = 161, name = "", unlocked = false, label = nil }, { id = 312, name = "", unlocked = false, label = nil },
					{ id = 481, name = "", unlocked = false, label = nil }, { id = 482, name = "", unlocked = false, label = nil },
					{ id = 1238, name = "", unlocked = false, label = nil }, { id = 1316, name = "", unlocked = false, label = nil },
					{ id = 4661, name = "", unlocked = false, label = nil }, { id = 4793, name = "", unlocked = false, label = nil },
					{ id = 5109, name = "", unlocked = false, label = nil }, { id = 5241, name = "", unlocked = false, label = nil },
					{ id = 5725, name = "", unlocked = false, label = nil }, { id = 5727, name = "", unlocked = false, label = nil },
					{ id = 5914, name = "", unlocked = false, label = nil }, { id = 6272, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- personalities
			id = ECB.constants.categories.PERSONALITIES,
			title = SI_ECB_TITLE_PERSONALITIES,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_PERSONALITIES,
					body = ECB_TRACKER_CONTENT_BODY_PERSONALITIES_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_PERSONALITIES_LIST_PERSONALITY_"
				},
				list = {
					{ id = 373, name = "", unlocked = false, label = nil }, { id = 374, name = "", unlocked = false, label = nil },
					{ id = 1234, name = "", unlocked = false, label = nil }, { id = 4725, name = "", unlocked = false, label = nil },
					{ id = 5218, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- polymorphs
			id = ECB.constants.categories.POLYMORPHS,
			title = SI_ECB_TITLE_POLYMORPHS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_POLYMORPHS,
					body = ECB_TRACKER_CONTENT_BODY_POLYMORPHS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_POLYMORPHS_LIST_POLYMORPH_"
				},
				list = {
					{ id = 34, name = "", unlocked = false, label = nil }, { id = 146, name = "", unlocked = false, label = nil },
					{ id = 147, name = "", unlocked = false, label = nil }, { id = 148, name = "", unlocked = false, label = nil },
					{ id = 213, name = "", unlocked = false, label = nil }, { id = 387, name = "", unlocked = false, label = nil },
					{ id = 4660, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- furnishings
			id = ECB.constants.categories.FURNISHINGS,
			title = SI_ECB_TITLE_FURNISHINGS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_FURNISHINGS,
					body = ECB_TRACKER_CONTENT_BODY_FURNISHINGS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_FURNISHINGS_LIST_FURNISHING_"
				},
				list = {
					{ id = 1171, name = "", unlocked = false, label = nil }, { id = 4664, name = "", unlocked = false, label = nil },
					{ id = 5460, name = "", unlocked = false, label = nil }, { id = 5539, name = "", unlocked = false, label = nil },
					{ id = 5930, name = "", unlocked = false, label = nil }, { id = 6596, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- storage
			id = ECB.constants.categories.STORAGE,
			title = SI_ECB_TITLE_STORAGE,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_STORAGE,
					body = ECB_TRACKER_CONTENT_BODY_STORAGE_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_STORAGE_LIST_STORAGE_"
				},
				list = {
					{ id = 4673, name = "", unlocked = false, label = nil }, { id = 4674, name = "", unlocked = false, label = nil },
					{ id = 4675, name = "", unlocked = false, label = nil }, { id = 4676, name = "", unlocked = false, label = nil },
					{ id = 4677, name = "", unlocked = false, label = nil }, { id = 4678, name = "", unlocked = false, label = nil },
					{ id = 4679, name = "", unlocked = false, label = nil }, { id = 4680, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- busts
			id = ECB.constants.categories.BUSTS,
			title = SI_ECB_TITLE_BUSTS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_BUSTS,
					body = ECB_TRACKER_CONTENT_BODY_BUSTS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_BUSTS_LIST_BUST_"
				},
				list = {
					{ id = 1110, name = "", unlocked = false, label = nil }, { id = 1111, name = "", unlocked = false, label = nil },
					{ id = 1112, name = "", unlocked = false, label = nil }, { id = 1113, name = "", unlocked = false, label = nil },
					{ id = 1114, name = "", unlocked = false, label = nil }, { id = 1115, name = "", unlocked = false, label = nil },
					{ id = 1116, name = "", unlocked = false, label = nil }, { id = 1117, name = "", unlocked = false, label = nil },
					{ id = 1118, name = "", unlocked = false, label = nil }, { id = 1119, name = "", unlocked = false, label = nil },
					{ id = 1120, name = "", unlocked = false, label = nil }, { id = 1121, name = "", unlocked = false, label = nil },
					{ id = 1122, name = "", unlocked = false, label = nil }, { id = 1123, name = "", unlocked = false, label = nil },
					{ id = 1124, name = "", unlocked = false, label = nil }, { id = 1125, name = "", unlocked = false, label = nil },
					{ id = 1126, name = "", unlocked = false, label = nil }, { id = 1127, name = "", unlocked = false, label = nil },
					{ id = 1128, name = "", unlocked = false, label = nil }, { id = 1129, name = "", unlocked = false, label = nil },
					{ id = 1130, name = "", unlocked = false, label = nil }, { id = 1131, name = "", unlocked = false, label = nil },
					{ id = 1132, name = "", unlocked = false, label = nil }, { id = 1133, name = "", unlocked = false, label = nil },
					{ id = 1134, name = "", unlocked = false, label = nil }, { id = 1135, name = "", unlocked = false, label = nil },
					{ id = 1136, name = "", unlocked = false, label = nil }, { id = 1137, name = "", unlocked = false, label = nil },
					{ id = 1138, name = "", unlocked = false, label = nil }, { id = 1139, name = "", unlocked = false, label = nil },
					{ id = 1140, name = "", unlocked = false, label = nil }, { id = 1141, name = "", unlocked = false, label = nil },
					{ id = 1142, name = "", unlocked = false, label = nil }, { id = 1143, name = "", unlocked = false, label = nil },
					{ id = 1237, name = "", unlocked = false, label = nil }, { id = 1258, name = "", unlocked = false, label = nil },
					{ id = 1259, name = "", unlocked = false, label = nil }, { id = 4666, name = "", unlocked = false, label = nil },
					{ id = 4753, name = "", unlocked = false, label = nil }, { id = 4754, name = "", unlocked = false, label = nil },
					{ id = 5459, name = "", unlocked = false, label = nil }, { id = 5604, name = "", unlocked = false, label = nil },
					{ id = 5605, name = "", unlocked = false, label = nil }, { id = 6013, name = "", unlocked = false, label = nil },
					{ id = 6061, name = "", unlocked = false, label = nil }, { id = 6063, name = "", unlocked = false, label = nil },
					{ id = 6611, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- trophies
			id = ECB.constants.categories.TROPHIES,
			title = SI_ECB_TITLE_TROPHIES,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_TROPHIES,
					body = ECB_TRACKER_CONTENT_BODY_TROPHIES_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_TROPHIES_LIST_TROPHY_"
				},
				list = {
					{ id = 1265, name = "", unlocked = false, label = nil }, { id = 1266, name = "", unlocked = false, label = nil },
					{ id = 1267, name = "", unlocked = false, label = nil }, { id = 1268, name = "", unlocked = false, label = nil },
					{ id = 1269, name = "", unlocked = false, label = nil }, { id = 1270, name = "", unlocked = false, label = nil },
					{ id = 1271, name = "", unlocked = false, label = nil }, { id = 1272, name = "", unlocked = false, label = nil },
					{ id = 1273, name = "", unlocked = false, label = nil }, { id = 1274, name = "", unlocked = false, label = nil },
					{ id = 1275, name = "", unlocked = false, label = nil }, { id = 1276, name = "", unlocked = false, label = nil },
					{ id = 1277, name = "", unlocked = false, label = nil }, { id = 1278, name = "", unlocked = false, label = nil },
					{ id = 1279, name = "", unlocked = false, label = nil }, { id = 1280, name = "", unlocked = false, label = nil },
					{ id = 1281, name = "", unlocked = false, label = nil }, { id = 1282, name = "", unlocked = false, label = nil },
					{ id = 1283, name = "", unlocked = false, label = nil }, { id = 1284, name = "", unlocked = false, label = nil },
					{ id = 1285, name = "", unlocked = false, label = nil }, { id = 1286, name = "", unlocked = false, label = nil },
					{ id = 1287, name = "", unlocked = false, label = nil }, { id = 1288, name = "", unlocked = false, label = nil },
					{ id = 1289, name = "", unlocked = false, label = nil }, { id = 1290, name = "", unlocked = false, label = nil },
					{ id = 1291, name = "", unlocked = false, label = nil }, { id = 1292, name = "", unlocked = false, label = nil },
					{ id = 1293, name = "", unlocked = false, label = nil }, { id = 1300, name = "", unlocked = false, label = nil },
					{ id = 1294, name = "", unlocked = false, label = nil }, { id = 1295, name = "", unlocked = false, label = nil },
					{ id = 1296, name = "", unlocked = false, label = nil }, { id = 1297, name = "", unlocked = false, label = nil },
					{ id = 1298, name = "", unlocked = false, label = nil }, { id = 1299, name = "", unlocked = false, label = nil },
					{ id = 1301, name = "", unlocked = false, label = nil }, { id = 4665, name = "", unlocked = false, label = nil },
					{ id = 4751, name = "", unlocked = false, label = nil }, { id = 4752, name = "", unlocked = false, label = nil },
					{ id = 5458, name = "", unlocked = false, label = nil }, { id = 5602, name = "", unlocked = false, label = nil },
					{ id = 5603, name = "", unlocked = false, label = nil }, { id = 6014, name = "", unlocked = false, label = nil },
					{ id = 6060, name = "", unlocked = false, label = nil }, { id = 6062, name = "", unlocked = false, label = nil },
					{ id = 6610, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- mementos
			id = ECB.constants.categories.MEMENTOS,
			title = SI_ECB_TITLE_MEMENTOS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_MEMENTOS,
					body = ECB_TRACKER_CONTENT_BODY_MEMENTOS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_MEMENTOS_LIST_MEMENTO_"
				},
				list = {
					{ id = 335, name = "", unlocked = false, label = nil }, { id = 336, name = "", unlocked = false, label = nil },
					{ id = 337, name = "", unlocked = false, label = nil }, { id = 338, name = "", unlocked = false, label = nil },
					{ id = 339, name = "", unlocked = false, label = nil }, { id = 340, name = "", unlocked = false, label = nil },
					{ id = 341, name = "", unlocked = false, label = nil }, { id = 342, name = "", unlocked = false, label = nil },
					{ id = 343, name = "", unlocked = false, label = nil }, { id = 344, name = "", unlocked = false, label = nil },
					{ id = 345, name = "", unlocked = false, label = nil }, { id = 346, name = "", unlocked = false, label = nil },
					{ id = 347, name = "", unlocked = false, label = nil }, { id = 348, name = "", unlocked = false, label = nil },
					{ id = 349, name = "", unlocked = false, label = nil }, { id = 350, name = "", unlocked = false, label = nil },
					{ id = 351, name = "", unlocked = false, label = nil }, { id = 352, name = "", unlocked = false, label = nil },
					{ id = 353, name = "", unlocked = false, label = nil }, { id = 354, name = "", unlocked = false, label = nil },
					{ id = 361, name = "", unlocked = false, label = nil }, { id = 389, name = "", unlocked = false, label = nil },
					{ id = 390, name = "", unlocked = false, label = nil }, { id = 479, name = "", unlocked = false, label = nil },
					{ id = 597, name = "", unlocked = false, label = nil }, { id = 598, name = "", unlocked = false, label = nil },
					{ id = 600, name = "", unlocked = false, label = nil }, { id = 601, name = "", unlocked = false, label = nil },
					{ id = 602, name = "", unlocked = false, label = nil }, { id = 1108, name = "", unlocked = false, label = nil },
					{ id = 1158, name = "", unlocked = false, label = nil }, { id = 1167, name = "", unlocked = false, label = nil },
					{ id = 1168, name = "", unlocked = false, label = nil }, { id = 1228, name = "", unlocked = false, label = nil },
					{ id = 1229, name = "", unlocked = false, label = nil }, { id = 1236, name = "", unlocked = false, label = nil },
					{ id = 1382, name = "", unlocked = false, label = nil }, { id = 4663, name = "", unlocked = false, label = nil },
					{ id = 4789, name = "", unlocked = false, label = nil }, { id = 4797, name = "", unlocked = false, label = nil },
					{ id = 5035, name = "", unlocked = false, label = nil }, { id = 5036, name = "", unlocked = false, label = nil },
					{ id = 5234, name = "", unlocked = false, label = nil }, { id = 5242, name = "", unlocked = false, label = nil },
					{ id = 5590, name = "", unlocked = false, label = nil }, { id = 5732, name = "", unlocked = false, label = nil },
					{ id = 5885, name = "", unlocked = false, label = nil }, { id = 5886, name = "", unlocked = false, label = nil },
					{ id = 5887, name = "", unlocked = false, label = nil }, { id = 6046, name = "", unlocked = false, label = nil },
					{ id = 6367, name = "", unlocked = false, label = nil }, { id = 6368, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- mounts
			id = ECB.constants.categories.MOUNTS,
			title = SI_ECB_TITLE_MOUNTS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_MOUNTS,
					body = ECB_TRACKER_CONTENT_BODY_MOUNTS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = {
					pattern = "ECB_TRACKER_CONTENT_BODY_MOUNTS_LIST_MOUNT_"
				},
				list = {
					{ id = 2, name = "", unlocked = false, label = nil }, { id = 3, name = "", unlocked = false, label = nil },
					{ id = 4, name = "", unlocked = false, label = nil }, { id = 5, name = "", unlocked = false, label = nil },
					{ id = 5067, name = "", unlocked = false, label = nil }, { id = 5068, name = "", unlocked = false, label = nil },
					{ id = 5549, name = "", unlocked = false, label = nil }, { id = 5550, name = "", unlocked = false, label = nil },
					{ id = 5710, name = "", unlocked = false, label = nil }, { id = 6466, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- pets
			id = ECB.constants.categories.PETS,
			title = SI_ECB_TITLE_PETS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_PETS,
					body = ECB_TRACKER_CONTENT_BODY_PETS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_PETS_LIST_PET_" },
				list = {
					{ id = 8, name = "", unlocked = false, label = nil }, { id = 62, name = "", unlocked = false, label = nil },
					{ id = 133, name = "", unlocked = false, label = nil }, { id = 149, name = "", unlocked = false, label = nil },
					{ id = 160, name = "", unlocked = false, label = nil }, { id = 163, name = "", unlocked = false, label = nil },
					{ id = 360, name = "", unlocked = false, label = nil }, { id = 1232, name = "", unlocked = false, label = nil },
					{ id = 4659, name = "", unlocked = false, label = nil }, { id = 4996, name = "", unlocked = false, label = nil },
					{ id = 5656, name = "", unlocked = false, label = nil }, { id = 5713, name = "", unlocked = false, label = nil },
					{ id = 5085, name = "", unlocked = false, label = nil }, { id = 5087, name = "", unlocked = false, label = nil },
					{ id = 5856, name = "", unlocked = false, label = nil }, { id = 6064, name = "", unlocked = false, label = nil },
					{ id = 6381, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- emotes
			id = ECB.constants.categories.EMOTES,
			title = SI_ECB_TITLE_EMOTES,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_EMOTES,
					body = ECB_TRACKER_CONTENT_BODY_EMOTES_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_EMOTES_LIST_EMOTE_" },
				list = {
					{ id = 1334, name = "", unlocked = false, label = nil }, { id = 4662, name = "", unlocked = false, label = nil },
					{ id = 5047, name = "", unlocked = false, label = nil }, { id = 5746, name = "", unlocked = false, label = nil },
					{ id = 6197, name = "", unlocked = false, label = nil }, { id = 6365, name = "", unlocked = false, label = nil },
					{ id = 6493, name = "", unlocked = false, label = nil }, { id = 6494, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- others
			id = ECB.constants.categories.OTHERS,
			title = SI_ECB_TITLE_OTHERS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_OTHERS,
					body = ECB_TRACKER_CONTENT_BODY_OTHERS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_OTHERS_LIST_OTHER_" },
				list = {
					{ id = 300, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- houses
			id = ECB.constants.categories.HOUSES,
			title = SI_ECB_TITLE_HOUSES,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_HOUSES,
					body = ECB_TRACKER_CONTENT_BODY_HOUSES_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_HOUSES_LIST_HOUSE_" },
				list = {
					{ id = 1060, name = "", unlocked = false, label = nil }, { id = 1061, name = "", unlocked = false, label = nil },
					{ id = 1062, name = "", unlocked = false, label = nil }, { id = 1063, name = "", unlocked = false, label = nil },
					{ id = 1064, name = "", unlocked = false, label = nil }, { id = 1065, name = "", unlocked = false, label = nil },
					{ id = 1069, name = "", unlocked = false, label = nil }, { id = 1072, name = "", unlocked = false, label = nil },
					{ id = 1081, name = "", unlocked = false, label = nil }, { id = 1066, name = "", unlocked = false, label = nil },
					{ id = 1075, name = "", unlocked = false, label = nil }, { id = 1087, name = "", unlocked = false, label = nil },
					{ id = 1090, name = "", unlocked = false, label = nil }, { id = 1078, name = "", unlocked = false, label = nil },
					{ id = 1084, name = "", unlocked = false, label = nil }, { id = 1093, name = "", unlocked = false, label = nil },
					{ id = 1073, name = "", unlocked = false, label = nil }, { id = 1070, name = "", unlocked = false, label = nil },
					{ id = 1310, name = "", unlocked = false, label = nil }, { id = 1067, name = "", unlocked = false, label = nil },
					{ id = 1076, name = "", unlocked = false, label = nil }, { id = 1088, name = "", unlocked = false, label = nil },
					{ id = 1085, name = "", unlocked = false, label = nil }, { id = 1094, name = "", unlocked = false, label = nil },
					{ id = 1079, name = "", unlocked = false, label = nil }, { id = 1091, name = "", unlocked = false, label = nil },
					{ id = 1082, name = "", unlocked = false, label = nil }, { id = 1071, name = "", unlocked = false, label = nil },
					{ id = 1074, name = "", unlocked = false, label = nil }, { id = 1312, name = "", unlocked = false, label = nil },
					{ id = 1077, name = "", unlocked = false, label = nil }, { id = 1089, name = "", unlocked = false, label = nil },
					{ id = 1068, name = "", unlocked = false, label = nil }, { id = 1080, name = "", unlocked = false, label = nil },
					{ id = 1083, name = "", unlocked = false, label = nil }, { id = 1086, name = "", unlocked = false, label = nil },
					{ id = 1092, name = "", unlocked = false, label = nil }, { id = 1095, name = "", unlocked = false, label = nil },
					{ id = 1096, name = "", unlocked = false, label = nil }, { id = 1097, name = "", unlocked = false, label = nil },
					{ id = 1098, name = "", unlocked = false, label = nil }, { id = 1311, name = "", unlocked = false, label = nil },
					{ id = 1242, name = "", unlocked = false, label = nil }, { id = 1244, name = "", unlocked = false, label = nil },
					{ id = 1243, name = "", unlocked = false, label = nil }, { id = 5167, name = "", unlocked = false, label = nil },
					{ id = 5168, name = "", unlocked = false, label = nil }, { id = 6380, name = "", unlocked = false, label = nil },
					{ id = 6400, name = "", unlocked = false, label = nil }
				}
			}
		},
		{ -- motifs
			id = ECB.constants.categories.MOTIFS,
			title = SI_ECB_TITLE_MOTIFS,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_MOTIFS,
					body = ECB_TRACKER_CONTENT_BODY_MOTIFS_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_MOTIFS_LIST_MOTIF_" },
				list = {
					{	id = "HIGH_ELF", name = SI_ECB_MOTIF_HIGH_ELF, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2859, name = "", unlocked = false, label = nil } } },
					{	id = "DARK_ELF", name = SI_ECB_MOTIF_DARK_ELF, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2161, name = "", unlocked = false, label = nil } } },
					{	id = "WOOD_ELF", name = SI_ECB_MOTIF_WOOD_ELF, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 1724, name = "", unlocked = false, label = nil } } },
					{	id = "NORD", name = SI_ECB_MOTIF_NORD, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2326, name = "", unlocked = false, label = nil } } },
					{	id = "BRETON", name = SI_ECB_MOTIF_BRETON, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 1600, name = "", unlocked = false, label = nil } } },
					{	id = "REDGUARD", name = SI_ECB_MOTIF_REDGUARD, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 1960, name = "", unlocked = false, label = nil } } },
					{	id = "KHAJIIT", name = SI_ECB_MOTIF_KHAJIIT, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3079, name = "", unlocked = false, label = nil } } },
					{	id = "ORC", name = SI_ECB_MOTIF_ORC, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 1777, name = "", unlocked = false, label = nil } } },
					{	id = "ARGONIAN", name = SI_ECB_MOTIF_ARGONIAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2548, name = "", unlocked = false, label = nil } } },
					{	id = "IMPERIAL", name = SI_ECB_MOTIF_IMPERIAL, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3156, name = "", unlocked = false, label = nil } } },
					{	id = "ANCIENT_ELF", name = SI_ECB_MOTIF_ANCIENT_ELF, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2684, name = "", unlocked = false, label = nil } } },
					{	id = "BARBARIC", name = SI_ECB_MOTIF_BARBARIC, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2399, name = "", unlocked = false, label = nil } } },
					{	id = "PRIMAL", name = SI_ECB_MOTIF_PRIMAL, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 1614, name = "", unlocked = false, label = nil } } },
					{	id = "DAEDRIC", name = SI_ECB_MOTIF_DAEDRIC, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2527, name = "", unlocked = false, label = nil } } },
					{
						id = "DWEMER", name = SI_ECB_MOTIF_DWEMER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3007, name = "", unlocked = false, label = nil }, { id = 3008, name = "", unlocked = false, label = nil },
								 { id = 3009, name = "", unlocked = false, label = nil }, { id = 3010, name = "", unlocked = false, label = nil },
								 { id = 3011, name = "", unlocked = false, label = nil }, { id = 3012, name = "", unlocked = false, label = nil },
								 { id = 3013, name = "", unlocked = false, label = nil }, { id = 4872, name = "", unlocked = false, label = nil },
								 { id = 2972, name = "", unlocked = false, label = nil }, { id = 2973, name = "", unlocked = false, label = nil },
								 { id = 2977, name = "", unlocked = false, label = nil }, { id = 2979, name = "", unlocked = false, label = nil },
								 { id = 2983, name = "", unlocked = false, label = nil }, { id = 2985, name = "", unlocked = false, label = nil } }
					},
					{
						id = "GLASS", name = SI_ECB_MOTIF_GLASS, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3555, name = "", unlocked = false, label = nil }, { id = 3556, name = "", unlocked = false, label = nil },
								 { id = 3557, name = "", unlocked = false, label = nil }, { id = 3558, name = "", unlocked = false, label = nil },
								 { id = 3559, name = "", unlocked = false, label = nil }, { id = 3560, name = "", unlocked = false, label = nil },
								 { id = 3561, name = "", unlocked = false, label = nil }, { id = 4885, name = "", unlocked = false, label = nil },
								 { id = 3453, name = "", unlocked = false, label = nil }, { id = 3454, name = "", unlocked = false, label = nil },
								 { id = 3455, name = "", unlocked = false, label = nil }, { id = 3456, name = "", unlocked = false, label = nil },
								 { id = 3457, name = "", unlocked = false, label = nil }, { id = 3458, name = "", unlocked = false, label = nil } }
					},
					{
						id = "AKAVIRI", name = SI_ECB_MOTIF_AKAVIRI, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2955, name = "", unlocked = false, label = nil }, { id = 2956, name = "", unlocked = false, label = nil },
								 { id = 2957, name = "", unlocked = false, label = nil }, { id = 2958, name = "", unlocked = false, label = nil },
								 { id = 2959, name = "", unlocked = false, label = nil }, { id = 2960, name = "", unlocked = false, label = nil },
								 { id = 2961, name = "", unlocked = false, label = nil }, { id = 4870, name = "", unlocked = false, label = nil },
								 { id = 2887, name = "", unlocked = false, label = nil }, { id = 2891, name = "", unlocked = false, label = nil },
								 { id = 2894, name = "", unlocked = false, label = nil }, { id = 2896, name = "", unlocked = false, label = nil },
								 { id = 2900, name = "", unlocked = false, label = nil }, { id = 2903, name = "", unlocked = false, label = nil } }
					},
					{
						id = "MERCENARY", name = SI_ECB_MOTIF_MERCENARY, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3680, name = "", unlocked = false, label = nil }, { id = 3681, name = "", unlocked = false, label = nil },
								 { id = 3682, name = "", unlocked = false, label = nil }, { id = 3683, name = "", unlocked = false, label = nil },
								 { id = 3684, name = "", unlocked = false, label = nil }, { id = 3685, name = "", unlocked = false, label = nil },
								 { id = 3686, name = "", unlocked = false, label = nil }, { id = 4887, name = "", unlocked = false, label = nil },
								 { id = 3549, name = "", unlocked = false, label = nil }, { id = 3550, name = "", unlocked = false, label = nil },
								 { id = 3551, name = "", unlocked = false, label = nil }, { id = 3552, name = "", unlocked = false, label = nil },
								 { id = 3553, name = "", unlocked = false, label = nil }, { id = 3554, name = "", unlocked = false, label = nil } }
					},
					{
						id = "YOKUDAN", name = SI_ECB_MOTIF_YOKUDAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3334, name = "", unlocked = false, label = nil }, { id = 3335, name = "", unlocked = false, label = nil },
								 { id = 3336, name = "", unlocked = false, label = nil }, { id = 3337, name = "", unlocked = false, label = nil },
								 { id = 3338, name = "", unlocked = false, label = nil }, { id = 3339, name = "", unlocked = false, label = nil },
								 { id = 3340, name = "", unlocked = false, label = nil }, { id = 4881, name = "", unlocked = false, label = nil },
								 { id = 3313, name = "", unlocked = false, label = nil }, { id = 3314, name = "", unlocked = false, label = nil },
								 { id = 3318, name = "", unlocked = false, label = nil }, { id = 3321, name = "", unlocked = false, label = nil },
								 { id = 3323, name = "", unlocked = false, label = nil }, { id = 3326, name = "", unlocked = false, label = nil } }
					},
					{
						id = "RA_GADA", name = SI_ECB_MOTIF_RA_GADA, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3927, name = "", unlocked = false, label = nil }, { id = 3928, name = "", unlocked = false, label = nil },
								 { id = 3929, name = "", unlocked = false, label = nil }, { id = 3930, name = "", unlocked = false, label = nil },
								 { id = 3931, name = "", unlocked = false, label = nil }, { id = 3932, name = "", unlocked = false, label = nil },
								 { id = 3987, name = "", unlocked = false, label = nil }, { id = 4897, name = "", unlocked = false, label = nil },
								 { id = 3918, name = "", unlocked = false, label = nil }, { id = 3919, name = "", unlocked = false, label = nil },
								 { id = 3920, name = "", unlocked = false, label = nil }, { id = 3921, name = "", unlocked = false, label = nil },
								 { id = 3922, name = "", unlocked = false, label = nil }, { id = 3923, name = "", unlocked = false, label = nil } }
					},
					{	id = "SOUL_SHRIVEN", name = SI_ECB_MOTIF_SOUL_SHRIVEN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3505, name = "", unlocked = false, label = nil } } },
					{
						id = "EBONY", name = SI_ECB_MOTIF_EBONY, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4136, name = "", unlocked = false, label = nil }, { id = 4135, name = "", unlocked = false, label = nil },
								 { id = 4137, name = "", unlocked = false, label = nil }, { id = 4138, name = "", unlocked = false, label = nil },
								 { id = 4139, name = "", unlocked = false, label = nil }, { id = 4140, name = "", unlocked = false, label = nil },
								 { id = 4141, name = "", unlocked = false, label = nil }, { id = 4904, name = "", unlocked = false, label = nil },
								 { id = 4080, name = "", unlocked = false, label = nil }, { id = 4081, name = "", unlocked = false, label = nil },
								 { id = 4082, name = "", unlocked = false, label = nil }, { id = 4083, name = "", unlocked = false, label = nil },
								 { id = 4084, name = "", unlocked = false, label = nil }, { id = 4085, name = "", unlocked = false, label = nil } }
					},
					{
						id = "DRAUGR", name = SI_ECB_MOTIF_DRAUGR, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 2783, name = "", unlocked = false, label = nil }, { id = 2784, name = "", unlocked = false, label = nil },
								 { id = 2785, name = "", unlocked = false, label = nil }, { id = 2786, name = "", unlocked = false, label = nil },
								 { id = 2787, name = "", unlocked = false, label = nil }, { id = 2788, name = "", unlocked = false, label = nil },
								 { id = 2789, name = "", unlocked = false, label = nil }, { id = 4867, name = "", unlocked = false, label = nil },
								 { id = 2799, name = "", unlocked = false, label = nil }, { id = 2800, name = "", unlocked = false, label = nil },
								 { id = 2801, name = "", unlocked = false, label = nil }, { id = 2802, name = "", unlocked = false, label = nil },
								 { id = 2803, name = "", unlocked = false, label = nil }, { id = 2804, name = "", unlocked = false, label = nil } }
					},
					{
						id = "CELESTIAL", name = SI_ECB_MOTIF_CELESTIAL, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3341, name = "", unlocked = false, label = nil }, { id = 3342, name = "", unlocked = false, label = nil },
								 { id = 3343, name = "", unlocked = false, label = nil }, { id = 3344, name = "", unlocked = false, label = nil },
								 { id = 3345, name = "", unlocked = false, label = nil }, { id = 3346, name = "", unlocked = false, label = nil },
								 { id = 3347, name = "", unlocked = false, label = nil }, { id = 4910, name = "", unlocked = false, label = nil },
								 { id = 4302, name = "", unlocked = false, label = nil }, { id = 4303, name = "", unlocked = false, label = nil },
								 { id = 4304, name = "", unlocked = false, label = nil }, { id = 4305, name = "", unlocked = false, label = nil },
								 { id = 4306, name = "", unlocked = false, label = nil }, { id = 4307, name = "", unlocked = false, label = nil } }
					},
					{
						id = "DOMINION", name = SI_ECB_MOTIF_DOMINION, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3608, name = "", unlocked = false, label = nil }, { id = 3609, name = "", unlocked = false, label = nil },
								 { id = 3610, name = "", unlocked = false, label = nil }, { id = 3611, name = "", unlocked = false, label = nil },
								 { id = 3612, name = "", unlocked = false, label = nil }, { id = 3613, name = "", unlocked = false, label = nil },
								 { id = 3614, name = "", unlocked = false, label = nil }, { id = 4889, name = "", unlocked = false, label = nil },
								 { id = 3618, name = "", unlocked = false, label = nil }, { id = 3619, name = "", unlocked = false, label = nil },
								 { id = 3620, name = "", unlocked = false, label = nil }, { id = 3621, name = "", unlocked = false, label = nil },
								 { id = 3622, name = "", unlocked = false, label = nil }, { id = 3623, name = "", unlocked = false, label = nil } }
					},
					{
						id = "COVENANT", name = SI_ECB_MOTIF_COVENANT, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3664, name = "", unlocked = false, label = nil }, { id = 3665, name = "", unlocked = false, label = nil },
								 { id = 3666, name = "", unlocked = false, label = nil }, { id = 3667, name = "", unlocked = false, label = nil },
								 { id = 3668, name = "", unlocked = false, label = nil }, { id = 3669, name = "", unlocked = false, label = nil },
								 { id = 3670, name = "", unlocked = false, label = nil }, { id = 4890, name = "", unlocked = false, label = nil },
								 { id = 3674, name = "", unlocked = false, label = nil }, { id = 3675, name = "", unlocked = false, label = nil },
								 { id = 3676, name = "", unlocked = false, label = nil }, { id = 3677, name = "", unlocked = false, label = nil },
								 { id = 3678, name = "", unlocked = false, label = nil }, { id = 3679, name = "", unlocked = false, label = nil } }
					},
					{
						id = "PACT", name = SI_ECB_MOTIF_PACT, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3569, name = "", unlocked = false, label = nil }, { id = 3570, name = "", unlocked = false, label = nil },
								 { id = 3571, name = "", unlocked = false, label = nil }, { id = 3572, name = "", unlocked = false, label = nil },
								 { id = 3573, name = "", unlocked = false, label = nil }, { id = 3574, name = "", unlocked = false, label = nil },
								 { id = 3575, name = "", unlocked = false, label = nil }, { id = 4888, name = "", unlocked = false, label = nil },
								 { id = 3602, name = "", unlocked = false, label = nil }, { id = 3603, name = "", unlocked = false, label = nil },
								 { id = 3604, name = "", unlocked = false, label = nil }, { id = 3605, name = "", unlocked = false, label = nil },
								 { id = 3606, name = "", unlocked = false, label = nil }, { id = 3607, name = "", unlocked = false, label = nil } }
					},
					{
						id = "XIVKYN", name = SI_ECB_MOTIF_XIVKYN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3428, name = "", unlocked = false, label = nil }, { id = 3429, name = "", unlocked = false, label = nil },
								 { id = 3430, name = "", unlocked = false, label = nil }, { id = 3431, name = "", unlocked = false, label = nil },
								 { id = 3432, name = "", unlocked = false, label = nil }, { id = 3433, name = "", unlocked = false, label = nil },
								 { id = 3434, name = "", unlocked = false, label = nil }, { id = 4883, name = "", unlocked = false, label = nil },
								 { id = 3392, name = "", unlocked = false, label = nil }, { id = 3393, name = "", unlocked = false, label = nil },
								 { id = 3394, name = "", unlocked = false, label = nil }, { id = 3395, name = "", unlocked = false, label = nil },
								 { id = 3396, name = "", unlocked = false, label = nil }, { id = 3397, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ANCIENT_ORC", name = SI_ECB_MOTIF_ANCIENT_ORC, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3466, name = "", unlocked = false, label = nil }, { id = 3467, name = "", unlocked = false, label = nil },
								 { id = 3468, name = "", unlocked = false, label = nil }, { id = 3469, name = "", unlocked = false, label = nil },
								 { id = 3470, name = "", unlocked = false, label = nil }, { id = 3471, name = "", unlocked = false, label = nil },
								 { id = 3472, name = "", unlocked = false, label = nil }, { id = 4884, name = "", unlocked = false, label = nil },
								 { id = 3401, name = "", unlocked = false, label = nil }, { id = 3402, name = "", unlocked = false, label = nil },
								 { id = 3403, name = "", unlocked = false, label = nil }, { id = 3404, name = "", unlocked = false, label = nil },
								 { id = 3405, name = "", unlocked = false, label = nil }, { id = 3406, name = "", unlocked = false, label = nil } }
					},
					{
						id = "TRINIMAC", name = SI_ECB_MOTIF_TRINIMAC, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3780, name = "", unlocked = false, label = nil }, { id = 3781, name = "", unlocked = false, label = nil },
								 { id = 3782, name = "", unlocked = false, label = nil }, { id = 3783, name = "", unlocked = false, label = nil },
								 { id = 3784, name = "", unlocked = false, label = nil }, { id = 3785, name = "", unlocked = false, label = nil },
								 { id = 3786, name = "", unlocked = false, label = nil }, { id = 4894, name = "", unlocked = false, label = nil },
								 { id = 3819, name = "", unlocked = false, label = nil }, { id = 3820, name = "", unlocked = false, label = nil },
								 { id = 3821, name = "", unlocked = false, label = nil }, { id = 3822, name = "", unlocked = false, label = nil },
								 { id = 3823, name = "", unlocked = false, label = nil }, { id = 3824, name = "", unlocked = false, label = nil } }
					},
					{
						id = "MALACATH", name = SI_ECB_MOTIF_MALACATH, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3787, name = "", unlocked = false, label = nil }, { id = 3788, name = "", unlocked = false, label = nil },
								 { id = 3789, name = "", unlocked = false, label = nil }, { id = 3790, name = "", unlocked = false, label = nil },
								 { id = 3791, name = "", unlocked = false, label = nil }, { id = 3792, name = "", unlocked = false, label = nil },
								 { id = 3793, name = "", unlocked = false, label = nil }, { id = 4893, name = "", unlocked = false, label = nil },
								 { id = 3733, name = "", unlocked = false, label = nil }, { id = 3734, name = "", unlocked = false, label = nil },
								 { id = 3735, name = "", unlocked = false, label = nil }, { id = 3736, name = "", unlocked = false, label = nil },
								 { id = 3737, name = "", unlocked = false, label = nil }, { id = 3738, name = "", unlocked = false, label = nil } }
					},
					{
						id = "OUTLAW", name = SI_ECB_MOTIF_OUTLAW, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3287, name = "", unlocked = false, label = nil }, { id = 3288, name = "", unlocked = false, label = nil },
								 { id = 3289, name = "", unlocked = false, label = nil }, { id = 3290, name = "", unlocked = false, label = nil },
								 { id = 3291, name = "", unlocked = false, label = nil }, { id = 3292, name = "", unlocked = false, label = nil },
								 { id = 3293, name = "", unlocked = false, label = nil }, { id = 4878, name = "", unlocked = false, label = nil },
								 { id = 3255, name = "", unlocked = false, label = nil }, { id = 3260, name = "", unlocked = false, label = nil },
								 { id = 3263, name = "", unlocked = false, label = nil }, { id = 3265, name = "", unlocked = false, label = nil },
								 { id = 3268, name = "", unlocked = false, label = nil }, { id = 3271, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ABAHS_WATCH", name = SI_ECB_MOTIF_ABAHS_WATCH, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3939, name = "", unlocked = false, label = nil }, { id = 3940, name = "", unlocked = false, label = nil },
								 { id = 3941, name = "", unlocked = false, label = nil }, { id = 3942, name = "", unlocked = false, label = nil },
								 { id = 3943, name = "", unlocked = false, label = nil }, { id = 3944, name = "", unlocked = false, label = nil },
								 { id = 3945, name = "", unlocked = false, label = nil }, { id = 4898, name = "", unlocked = false, label = nil },
								 { id = 3957, name = "", unlocked = false, label = nil }, { id = 3958, name = "", unlocked = false, label = nil },
								 { id = 3959, name = "", unlocked = false, label = nil }, { id = 3960, name = "", unlocked = false, label = nil },
								 { id = 3961, name = "", unlocked = false, label = nil }, { id = 3962, name = "", unlocked = false, label = nil } }
					},
					{
						id = "THIEVES_GUILD", name = SI_ECB_MOTIF_THIEVES_GUILD, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3833, name = "", unlocked = false, label = nil }, { id = 3838, name = "", unlocked = false, label = nil },
								 { id = 3834, name = "", unlocked = false, label = nil }, { id = 3835, name = "", unlocked = false, label = nil },
								 { id = 3836, name = "", unlocked = false, label = nil }, { id = 3837, name = "", unlocked = false, label = nil },
								 { id = 3871, name = "", unlocked = false, label = nil }, { id = 4895, name = "", unlocked = false, label = nil },
								 { id = 3855, name = "", unlocked = false, label = nil }, { id = 3856, name = "", unlocked = false, label = nil },
								 { id = 3857, name = "", unlocked = false, label = nil }, { id = 3858, name = "", unlocked = false, label = nil },
								 { id = 3859, name = "", unlocked = false, label = nil }, { id = 3860, name = "", unlocked = false, label = nil } }
					},
					{
						id = "DROMATHRA", name = SI_ECB_MOTIF_DROMATHRA, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3864, name = "", unlocked = false, label = nil }, { id = 3865, name = "", unlocked = false, label = nil },
								 { id = 3866, name = "", unlocked = false, label = nil }, { id = 3867, name = "", unlocked = false, label = nil },
								 { id = 3868, name = "", unlocked = false, label = nil }, { id = 3869, name = "", unlocked = false, label = nil },
								 { id = 3870, name = "", unlocked = false, label = nil }, { id = 4905, name = "", unlocked = false, label = nil },
								 { id = 4099, name = "", unlocked = false, label = nil }, { id = 4100, name = "", unlocked = false, label = nil },
								 { id = 4101, name = "", unlocked = false, label = nil }, { id = 4102, name = "", unlocked = false, label = nil },
								 { id = 4103, name = "", unlocked = false, label = nil }, { id = 4104, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ASSASSINS_LEAGUE", name = SI_ECB_MOTIF_ASSASSINS_LEAGUE, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3414, name = "", unlocked = false, label = nil }, { id = 3415, name = "", unlocked = false, label = nil },
								 { id = 3416, name = "", unlocked = false, label = nil }, { id = 3417, name = "", unlocked = false, label = nil },
								 { id = 3418, name = "", unlocked = false, label = nil }, { id = 3419, name = "", unlocked = false, label = nil },
								 { id = 3420, name = "", unlocked = false, label = nil }, { id = 4882, name = "", unlocked = false, label = nil },
								 { id = 3375, name = "", unlocked = false, label = nil }, { id = 3376, name = "", unlocked = false, label = nil },
								 { id = 3377, name = "", unlocked = false, label = nil }, { id = 3378, name = "", unlocked = false, label = nil },
								 { id = 3379, name = "", unlocked = false, label = nil }, { id = 3380, name = "", unlocked = false, label = nil } }
					},
					{
						id = "DARK_BROTHERHOOD", name = SI_ECB_MOTIF_DARK_BROTHERHOOD, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3745, name = "", unlocked = false, label = nil }, { id = 3746, name = "", unlocked = false, label = nil },
								 { id = 3747, name = "", unlocked = false, label = nil }, { id = 3748, name = "", unlocked = false, label = nil },
								 { id = 3749, name = "", unlocked = false, label = nil }, { id = 3750, name = "", unlocked = false, label = nil },
								 { id = 4048, name = "", unlocked = false, label = nil }, { id = 4891, name = "", unlocked = false, label = nil },
								 { id = 3707, name = "", unlocked = false, label = nil }, { id = 3708, name = "", unlocked = false, label = nil },
								 { id = 3709, name = "", unlocked = false, label = nil }, { id = 3710, name = "", unlocked = false, label = nil },
								 { id = 3711, name = "", unlocked = false, label = nil }, { id = 3712, name = "", unlocked = false, label = nil } }
					},
					{
						id = "MINOTAUR", name = SI_ECB_MOTIF_MINOTAUR, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4010, name = "", unlocked = false, label = nil }, { id = 4011, name = "", unlocked = false, label = nil },
								 { id = 4012, name = "", unlocked = false, label = nil }, { id = 4013, name = "", unlocked = false, label = nil },
								 { id = 4014, name = "", unlocked = false, label = nil }, { id = 4015, name = "", unlocked = false, label = nil },
								 { id = 4016, name = "", unlocked = false, label = nil }, { id = 4900, name = "", unlocked = false, label = nil },
								 { id = 3995, name = "", unlocked = false, label = nil }, { id = 3996, name = "", unlocked = false, label = nil },
								 { id = 3997, name = "", unlocked = false, label = nil }, { id = 3998, name = "", unlocked = false, label = nil },
								 { id = 3999, name = "", unlocked = false, label = nil }, { id = 4000, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ORDER_HOUR", name = SI_ECB_MOTIF_ORDER_HOUR, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4058, name = "", unlocked = false, label = nil }, { id = 4059, name = "", unlocked = false, label = nil },
								 { id = 4060, name = "", unlocked = false, label = nil }, { id = 4061, name = "", unlocked = false, label = nil },
								 { id = 4062, name = "", unlocked = false, label = nil }, { id = 4063, name = "", unlocked = false, label = nil },
								 { id = 4064, name = "", unlocked = false, label = nil }, { id = 4901, name = "", unlocked = false, label = nil },
								 { id = 4004, name = "", unlocked = false, label = nil }, { id = 4005, name = "", unlocked = false, label = nil },
								 { id = 4006, name = "", unlocked = false, label = nil }, { id = 4007, name = "", unlocked = false, label = nil },
								 { id = 4008, name = "", unlocked = false, label = nil }, { id = 4009, name = "", unlocked = false, label = nil } }
					},
					{
						id = "SILKEN_RING", name = SI_ECB_MOTIF_SILKEN_RING, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3760, name = "", unlocked = false, label = nil }, { id = 3761, name = "", unlocked = false, label = nil },
								 { id = 3762, name = "", unlocked = false, label = nil }, { id = 3763, name = "", unlocked = false, label = nil },
								 { id = 3764, name = "", unlocked = false, label = nil }, { id = 3765, name = "", unlocked = false, label = nil },
								 { id = 3766, name = "", unlocked = false, label = nil }, { id = 4886, name = "", unlocked = false, label = nil },
								 { id = 3540, name = "", unlocked = false, label = nil }, { id = 3541, name = "", unlocked = false, label = nil },
								 { id = 3542, name = "", unlocked = false, label = nil }, { id = 3543, name = "", unlocked = false, label = nil },
								 { id = 3544, name = "", unlocked = false, label = nil }, { id = 3545, name = "", unlocked = false, label = nil } }
					},
					{
						id = "MAZZATUN", name = SI_ECB_MOTIF_MAZZATUN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4161, name = "", unlocked = false, label = nil }, { id = 4162, name = "", unlocked = false, label = nil },
								 { id = 4163, name = "", unlocked = false, label = nil }, { id = 4164, name = "", unlocked = false, label = nil },
								 { id = 4165, name = "", unlocked = false, label = nil }, { id = 4166, name = "", unlocked = false, label = nil },
								 { id = 4167, name = "", unlocked = false, label = nil }, { id = 4902, name = "", unlocked = false, label = nil },
								 { id = 4034, name = "", unlocked = false, label = nil }, { id = 4035, name = "", unlocked = false, label = nil },
								 { id = 4036, name = "", unlocked = false, label = nil }, { id = 4037, name = "", unlocked = false, label = nil },
								 { id = 4038, name = "", unlocked = false, label = nil }, { id = 4039, name = "", unlocked = false, label = nil } }
					},
					{
						id = "MORAG_TONG", name = SI_ECB_MOTIF_MORAG_TONG, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 3911, name = "", unlocked = false, label = nil }, { id = 3912, name = "", unlocked = false, label = nil },
								 { id = 3913, name = "", unlocked = false, label = nil }, { id = 3914, name = "", unlocked = false, label = nil },
								 { id = 3924, name = "", unlocked = false, label = nil }, { id = 3925, name = "", unlocked = false, label = nil },
								 { id = 3926, name = "", unlocked = false, label = nil }, { id = 4896, name = "", unlocked = false, label = nil },
								 { id = 3875, name = "", unlocked = false, label = nil }, { id = 3876, name = "", unlocked = false, label = nil },
								 { id = 3877, name = "", unlocked = false, label = nil }, { id = 3878, name = "", unlocked = false, label = nil },
								 { id = 3879, name = "", unlocked = false, label = nil }, { id = 3880, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ARMIGER", name = SI_ECB_MOTIF_ARMIGER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4481, name = "", unlocked = false, label = nil }, { id = 4482, name = "", unlocked = false, label = nil },
								 { id = 4483, name = "", unlocked = false, label = nil }, { id = 4484, name = "", unlocked = false, label = nil },
								 { id = 4485, name = "", unlocked = false, label = nil }, { id = 4486, name = "", unlocked = false, label = nil },
								 { id = 4487, name = "", unlocked = false, label = nil }, { id = 4916, name = "", unlocked = false, label = nil },
								 { id = 4461, name = "", unlocked = false, label = nil }, { id = 4462, name = "", unlocked = false, label = nil },
								 { id = 4463, name = "", unlocked = false, label = nil }, { id = 4464, name = "", unlocked = false, label = nil },
								 { id = 4465, name = "", unlocked = false, label = nil }, { id = 4466, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ASHLANDER", name = SI_ECB_MOTIF_ASHLANDER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4527, name = "", unlocked = false, label = nil }, { id = 4528, name = "", unlocked = false, label = nil },
								 { id = 4529, name = "", unlocked = false, label = nil }, { id = 4530, name = "", unlocked = false, label = nil },
								 { id = 4531, name = "", unlocked = false, label = nil }, { id = 4532, name = "", unlocked = false, label = nil },
								 { id = 4533, name = "", unlocked = false, label = nil }, { id = 4915, name = "", unlocked = false, label = nil },
								 { id = 4394, name = "", unlocked = false, label = nil }, { id = 4395, name = "", unlocked = false, label = nil },
								 { id = 4396, name = "", unlocked = false, label = nil }, { id = 4397, name = "", unlocked = false, label = nil },
								 { id = 4398, name = "", unlocked = false, label = nil }, { id = 4399, name = "", unlocked = false, label = nil } }
					},
					{
						id = "MILITANT_ORDINATOR", name = SI_ECB_MOTIF_MILITANT_ORDINATOR, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4490, name = "", unlocked = false, label = nil }, { id = 4491, name = "", unlocked = false, label = nil },
								 { id = 4492, name = "", unlocked = false, label = nil }, { id = 4493, name = "", unlocked = false, label = nil },
								 { id = 4494, name = "", unlocked = false, label = nil }, { id = 4495, name = "", unlocked = false, label = nil },
								 { id = 4509, name = "", unlocked = false, label = nil }, { id = 4537, name = "", unlocked = false, label = nil },
								 { id = 4538, name = "", unlocked = false, label = nil }, { id = 4539, name = "", unlocked = false, label = nil },
								 { id = 4540, name = "", unlocked = false, label = nil }, { id = 4541, name = "", unlocked = false, label = nil },
								 { id = 4542, name = "", unlocked = false, label = nil }, { id = 4918, name = "", unlocked = false, label = nil } }
					},
					{
						id = "TELVANNI", name = SI_ECB_MOTIF_TELVANNI, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4441, name = "", unlocked = false, label = nil }, { id = 4442, name = "", unlocked = false, label = nil },
								 { id = 4443, name = "", unlocked = false, label = nil }, { id = 4444, name = "", unlocked = false, label = nil },
								 { id = 4445, name = "", unlocked = false, label = nil }, { id = 4446, name = "", unlocked = false, label = nil },
								 { id = 4447, name = "", unlocked = false, label = nil }, { id = 4909, name = "", unlocked = false, label = nil },
								 { id = 4293, name = "", unlocked = false, label = nil }, { id = 4294, name = "", unlocked = false, label = nil },
								 { id = 4295, name = "", unlocked = false, label = nil }, { id = 4296, name = "", unlocked = false, label = nil },
								 { id = 4297, name = "", unlocked = false, label = nil }, { id = 4298, name = "", unlocked = false, label = nil } }
					},
					{
						id = "HLAALU", name = SI_ECB_MOTIF_HLAALU, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4403, name = "", unlocked = false, label = nil }, { id = 4402, name = "", unlocked = false, label = nil },
								 { id = 4404, name = "", unlocked = false, label = nil }, { id = 4405, name = "", unlocked = false, label = nil },
								 { id = 4406, name = "", unlocked = false, label = nil }, { id = 4407, name = "", unlocked = false, label = nil },
								 { id = 4408, name = "", unlocked = false, label = nil }, { id = 4914, name = "", unlocked = false, label = nil },
								 { id = 4385, name = "", unlocked = false, label = nil }, { id = 4386, name = "", unlocked = false, label = nil },
								 { id = 4387, name = "", unlocked = false, label = nil }, { id = 4388, name = "", unlocked = false, label = nil },
								 { id = 4389, name = "", unlocked = false, label = nil }, { id = 4390, name = "", unlocked = false, label = nil } }
					},
					{
						id = "REDORAN", name = SI_ECB_MOTIF_REDORAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4422, name = "", unlocked = false, label = nil }, { id = 4421, name = "", unlocked = false, label = nil },
								 { id = 4428, name = "", unlocked = false, label = nil }, { id = 4430, name = "", unlocked = false, label = nil },
								 { id = 4431, name = "", unlocked = false, label = nil }, { id = 4432, name = "", unlocked = false, label = nil },
								 { id = 4456, name = "", unlocked = false, label = nil }, { id = 4913, name = "", unlocked = false, label = nil },
								 { id = 4354, name = "", unlocked = false, label = nil }, { id = 4355, name = "", unlocked = false, label = nil },
								 { id = 4356, name = "", unlocked = false, label = nil }, { id = 4357, name = "", unlocked = false, label = nil },
								 { id = 4358, name = "", unlocked = false, label = nil }, { id = 4359, name = "", unlocked = false, label = nil } }
					},
					{
						id = "BLOODFORGE", name = SI_ECB_MOTIF_BLOODFORGE, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4580, name = "", unlocked = false, label = nil }, { id = 4581, name = "", unlocked = false, label = nil },
								 { id = 4582, name = "", unlocked = false, label = nil }, { id = 4583, name = "", unlocked = false, label = nil },
								 { id = 4584, name = "", unlocked = false, label = nil }, { id = 4585, name = "", unlocked = false, label = nil },
								 { id = 4586, name = "", unlocked = false, label = nil }, { id = 4919, name = "", unlocked = false, label = nil },
								 { id = 4568, name = "", unlocked = false, label = nil }, { id = 4569, name = "", unlocked = false, label = nil },
								 { id = 4570, name = "", unlocked = false, label = nil }, { id = 4571, name = "", unlocked = false, label = nil },
								 { id = 4572, name = "", unlocked = false, label = nil }, { id = 4573, name = "", unlocked = false, label = nil } }
					},
					{
						id = "DREADHORN", name = SI_ECB_MOTIF_DREADHORN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4621, name = "", unlocked = false, label = nil }, { id = 4622, name = "", unlocked = false, label = nil },
								 { id = 4623, name = "", unlocked = false, label = nil }, { id = 4624, name = "", unlocked = false, label = nil },
								 { id = 4625, name = "", unlocked = false, label = nil }, { id = 4626, name = "", unlocked = false, label = nil },
								 { id = 4627, name = "", unlocked = false, label = nil }, { id = 4920, name = "", unlocked = false, label = nil },
								 { id = 4600, name = "", unlocked = false, label = nil }, { id = 4601, name = "", unlocked = false, label = nil },
								 { id = 4602, name = "", unlocked = false, label = nil }, { id = 4603, name = "", unlocked = false, label = nil },
								 { id = 4604, name = "", unlocked = false, label = nil }, { id = 4605, name = "", unlocked = false, label = nil } }
					},
					{
						id = "APOSTLE", name = SI_ECB_MOTIF_APOSTLE, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4947, name = "", unlocked = false, label = nil }, { id = 4948, name = "", unlocked = false, label = nil },
								 { id = 4949, name = "", unlocked = false, label = nil }, { id = 4950, name = "", unlocked = false, label = nil },
								 { id = 4951, name = "", unlocked = false, label = nil }, { id = 4952, name = "", unlocked = false, label = nil },
								 { id = 4953, name = "", unlocked = false, label = nil }, { id = 4925, name = "", unlocked = false, label = nil },
								 { id = 4926, name = "", unlocked = false, label = nil }, { id = 4927, name = "", unlocked = false, label = nil },
								 { id = 4928, name = "", unlocked = false, label = nil }, { id = 4929, name = "", unlocked = false, label = nil },
								 { id = 4930, name = "", unlocked = false, label = nil }, { id = 4931, name = "", unlocked = false, label = nil } }
					},
					{
						id = "EBONSHADOW", name = SI_ECB_MOTIF_EBONSHADOW, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4961, name = "", unlocked = false, label = nil }, { id = 4962, name = "", unlocked = false, label = nil },
								 { id = 4963, name = "", unlocked = false, label = nil }, { id = 4964, name = "", unlocked = false, label = nil },
								 { id = 4965, name = "", unlocked = false, label = nil }, { id = 4966, name = "", unlocked = false, label = nil },
								 { id = 4967, name = "", unlocked = false, label = nil }, { id = 4979, name = "", unlocked = false, label = nil },
								 { id = 4980, name = "", unlocked = false, label = nil }, { id = 4981, name = "", unlocked = false, label = nil },
								 { id = 4982, name = "", unlocked = false, label = nil }, { id = 4983, name = "", unlocked = false, label = nil },
								 { id = 4984, name = "", unlocked = false, label = nil }, { id = 4985, name = "", unlocked = false, label = nil } }
					},
					{
						id = "FANG_LAIR", name = SI_ECB_MOTIF_FANG_LAIR, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5377, name = "", unlocked = false, label = nil }, { id = 5333, name = "", unlocked = false, label = nil },
								 { id = 5341, name = "", unlocked = false, label = nil }, { id = 5340, name = "", unlocked = false, label = nil },
								 { id = 5344, name = "", unlocked = false, label = nil }, { id = 5343, name = "", unlocked = false, label = nil },
								 { id = 5342, name = "", unlocked = false, label = nil }, { id = 5348, name = "", unlocked = false, label = nil },
								 { id = 5349, name = "", unlocked = false, label = nil }, { id = 5350, name = "", unlocked = false, label = nil },
								 { id = 5351, name = "", unlocked = false, label = nil }, { id = 5352, name = "", unlocked = false, label = nil },
								 { id = 5353, name = "", unlocked = false, label = nil }, { id = 5354, name = "", unlocked = false, label = nil } }
					},
					{
						id = "SCALECALLER", name = SI_ECB_MOTIF_SCALECALLER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5403, name = "", unlocked = false, label = nil }, { id = 5404, name = "", unlocked = false, label = nil },
								 { id = 5405, name = "", unlocked = false, label = nil }, { id = 5406, name = "", unlocked = false, label = nil },
								 { id = 5407, name = "", unlocked = false, label = nil }, { id = 5408, name = "", unlocked = false, label = nil },
								 { id = 5409, name = "", unlocked = false, label = nil }, { id = 5413, name = "", unlocked = false, label = nil },
								 { id = 5414, name = "", unlocked = false, label = nil }, { id = 5415, name = "", unlocked = false, label = nil },
								 { id = 5416, name = "", unlocked = false, label = nil }, { id = 5417, name = "", unlocked = false, label = nil },
								 { id = 5418, name = "", unlocked = false, label = nil }, { id = 5419, name = "", unlocked = false, label = nil } }
					},
					{
						id = "PSIJIC", name = SI_ECB_MOTIF_PSIJIC, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5317, name = "", unlocked = false, label = nil }, { id = 5318, name = "", unlocked = false, label = nil },
								 { id = 5319, name = "", unlocked = false, label = nil }, { id = 5320, name = "", unlocked = false, label = nil },
								 { id = 5321, name = "", unlocked = false, label = nil }, { id = 5322, name = "", unlocked = false, label = nil },
								 { id = 5323, name = "", unlocked = false, label = nil }, { id = 5295, name = "", unlocked = false, label = nil },
								 { id = 5296, name = "", unlocked = false, label = nil }, { id = 5297, name = "", unlocked = false, label = nil },
								 { id = 5298, name = "", unlocked = false, label = nil }, { id = 5299, name = "", unlocked = false, label = nil },
								 { id = 5300, name = "", unlocked = false, label = nil }, { id = 5301, name = "", unlocked = false, label = nil } }
					},
					{
						id = "SAPIARCH", name = SI_ECB_MOTIF_SAPIARCH, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5532, name = "", unlocked = false, label = nil }, { id = 5533, name = "", unlocked = false, label = nil },
								 { id = 5534, name = "", unlocked = false, label = nil }, { id = 5535, name = "", unlocked = false, label = nil },
								 { id = 5536, name = "", unlocked = false, label = nil }, { id = 5537, name = "", unlocked = false, label = nil },
								 { id = 5538, name = "", unlocked = false, label = nil }, { id = 5510, name = "", unlocked = false, label = nil },
								 { id = 5511, name = "", unlocked = false, label = nil }, { id = 5512, name = "", unlocked = false, label = nil },
								 { id = 5513, name = "", unlocked = false, label = nil }, { id = 5514, name = "", unlocked = false, label = nil },
								 { id = 5515, name = "", unlocked = false, label = nil }, { id = 5516, name = "", unlocked = false, label = nil } }
					},
					{
						id = "PYANDONEAN", name = SI_ECB_MOTIF_PYANDONEAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5485, name = "", unlocked = false, label = nil }, { id = 5486, name = "", unlocked = false, label = nil },
								 { id = 5487, name = "", unlocked = false, label = nil }, { id = 5488, name = "", unlocked = false, label = nil },
								 { id = 5489, name = "", unlocked = false, label = nil }, { id = 5490, name = "", unlocked = false, label = nil },
								 { id = 5491, name = "", unlocked = false, label = nil }, { id = 5478, name = "", unlocked = false, label = nil },
								 { id = 5479, name = "", unlocked = false, label = nil }, { id = 5480, name = "", unlocked = false, label = nil },
								 { id = 5481, name = "", unlocked = false, label = nil }, { id = 5482, name = "", unlocked = false, label = nil },
								 { id = 5483, name = "", unlocked = false, label = nil }, { id = 5484, name = "", unlocked = false, label = nil } }
					},
					{
						id = "WELKYNAR", name = SI_ECB_MOTIF_WELKYNAR, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5665, name = "", unlocked = false, label = nil }, { id = 5666, name = "", unlocked = false, label = nil },
								 { id = 5667, name = "", unlocked = false, label = nil }, { id = 5668, name = "", unlocked = false, label = nil },
								 { id = 5669, name = "", unlocked = false, label = nil }, { id = 5670, name = "", unlocked = false, label = nil },
								 { id = 5671, name = "", unlocked = false, label = nil }, { id = 5690, name = "", unlocked = false, label = nil },
								 { id = 5691, name = "", unlocked = false, label = nil }, { id = 5692, name = "", unlocked = false, label = nil },
								 { id = 5693, name = "", unlocked = false, label = nil }, { id = 5694, name = "", unlocked = false, label = nil },
								 { id = 5695, name = "", unlocked = false, label = nil }, { id = 5696, name = "", unlocked = false, label = nil } }
					},
					{
						id = "HUNTSMAN", name = SI_ECB_MOTIF_HUNTSMAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5781, name = "", unlocked = false, label = nil }, { id = 5782, name = "", unlocked = false, label = nil },
								 { id = 5783, name = "", unlocked = false, label = nil }, { id = 5784, name = "", unlocked = false, label = nil },
								 { id = 5785, name = "", unlocked = false, label = nil }, { id = 5786, name = "", unlocked = false, label = nil },
								 { id = 5787, name = "", unlocked = false, label = nil }, { id = 5791, name = "", unlocked = false, label = nil },
								 { id = 5792, name = "", unlocked = false, label = nil }, { id = 5793, name = "", unlocked = false, label = nil },
								 { id = 5794, name = "", unlocked = false, label = nil }, { id = 5795, name = "", unlocked = false, label = nil },
								 { id = 5796, name = "", unlocked = false, label = nil }, { id = 5797, name = "", unlocked = false, label = nil } }
					},
					{
						id = "SILVER_DAWN", name = SI_ECB_MOTIF_SILVER_DAWN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5813, name = "", unlocked = false, label = nil }, { id = 5814, name = "", unlocked = false, label = nil },
								 { id = 5815, name = "", unlocked = false, label = nil }, { id = 5816, name = "", unlocked = false, label = nil },
								 { id = 5817, name = "", unlocked = false, label = nil }, { id = 5818, name = "", unlocked = false, label = nil },
								 { id = 5819, name = "", unlocked = false, label = nil }, { id = 5823, name = "", unlocked = false, label = nil },
								 { id = 5824, name = "", unlocked = false, label = nil }, { id = 5825, name = "", unlocked = false, label = nil },
								 { id = 5826, name = "", unlocked = false, label = nil }, { id = 5827, name = "", unlocked = false, label = nil },
								 { id = 5828, name = "", unlocked = false, label = nil }, { id = 5829, name = "", unlocked = false, label = nil } }
					},
					{
						id = "HONOR_GUARD", name = SI_ECB_MOTIF_HONOR_GUARD, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6124, name = "", unlocked = false, label = nil }, { id = 6125, name = "", unlocked = false, label = nil },
								 { id = 6126, name = "", unlocked = false, label = nil }, { id = 6127, name = "", unlocked = false, label = nil },
								 { id = 6128, name = "", unlocked = false, label = nil }, { id = 6129, name = "", unlocked = false, label = nil },
								 { id = 6130, name = "", unlocked = false, label = nil }, { id = 6110, name = "", unlocked = false, label = nil },
								 { id = 6111, name = "", unlocked = false, label = nil }, { id = 6112, name = "", unlocked = false, label = nil },
								 { id = 6113, name = "", unlocked = false, label = nil }, { id = 6114, name = "", unlocked = false, label = nil },
								 { id = 6115, name = "", unlocked = false, label = nil }, { id = 6116, name = "", unlocked = false, label = nil } }
					},
					{
						id = "DEAD-WATER", name = SI_ECB_MOTIF_DEAD_WATER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5939, name = "", unlocked = false, label = nil }, { id = 5940, name = "", unlocked = false, label = nil },
								 { id = 5941, name = "", unlocked = false, label = nil }, { id = 5942, name = "", unlocked = false, label = nil },
								 { id = 5943, name = "", unlocked = false, label = nil }, { id = 5944, name = "", unlocked = false, label = nil },
								 { id = 5945, name = "", unlocked = false, label = nil }, { id = 5964, name = "", unlocked = false, label = nil },
								 { id = 5965, name = "", unlocked = false, label = nil }, { id = 5966, name = "", unlocked = false, label = nil },
								 { id = 5967, name = "", unlocked = false, label = nil }, { id = 5968, name = "", unlocked = false, label = nil },
								 { id = 5969, name = "", unlocked = false, label = nil }, { id = 5970, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ELDER_ARGONIAN", name = SI_ECB_MOTIF_ELDER_ARGONIAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5971, name = "", unlocked = false, label = nil }, { id = 5972, name = "", unlocked = false, label = nil },
								 { id = 5973, name = "", unlocked = false, label = nil }, { id = 5974, name = "", unlocked = false, label = nil },
								 { id = 5975, name = "", unlocked = false, label = nil }, { id = 5976, name = "", unlocked = false, label = nil },
								 { id = 5977, name = "", unlocked = false, label = nil }, { id = 5996, name = "", unlocked = false, label = nil },
								 { id = 5997, name = "", unlocked = false, label = nil }, { id = 5998, name = "", unlocked = false, label = nil },
								 { id = 5999, name = "", unlocked = false, label = nil }, { id = 6000, name = "", unlocked = false, label = nil },
								 { id = 6001, name = "", unlocked = false, label = nil }, { id = 6002, name = "", unlocked = false, label = nil } }
					},
					{
						id = "MERIDIA", name = SI_ECB_MOTIF_MERIDIA, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6299, name = "", unlocked = false, label = nil }, { id = 6300, name = "", unlocked = false, label = nil },
							{ id = 6301, name = "", unlocked = false, label = nil }, { id = 6302, name = "", unlocked = false, label = nil },
							{ id = 6303, name = "", unlocked = false, label = nil }, { id = 6304, name = "", unlocked = false, label = nil },
							{ id = 6305, name = "", unlocked = false, label = nil }, { id = 6324, name = "", unlocked = false, label = nil },
							{ id = 6325, name = "", unlocked = false, label = nil }, { id = 6326, name = "", unlocked = false, label = nil },
							{ id = 6327, name = "", unlocked = false, label = nil }, { id = 6328, name = "", unlocked = false, label = nil },
							{ id = 6329, name = "", unlocked = false, label = nil }, { id = 6330, name = "", unlocked = false, label = nil } }
					},
					{
						id = "COLDSNAP_GOBLIN", name = SI_ECB_MOTIF_COLDSNAP_GOBLIN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6331, name = "", unlocked = false, label = nil }, { id = 6332, name = "", unlocked = false, label = nil },
							{ id = 6333, name = "", unlocked = false, label = nil }, { id = 6334, name = "", unlocked = false, label = nil },
							{ id = 6335, name = "", unlocked = false, label = nil }, { id = 6336, name = "", unlocked = false, label = nil },
							{ id = 6337, name = "", unlocked = false, label = nil }, { id = 6277, name = "", unlocked = false, label = nil },
							{ id = 6278, name = "", unlocked = false, label = nil }, { id = 6279, name = "", unlocked = false, label = nil },
							{ id = 6280, name = "", unlocked = false, label = nil }, { id = 6281, name = "", unlocked = false, label = nil },
							{ id = 6282, name = "", unlocked = false, label = nil }, { id = 6283, name = "", unlocked = false, label = nil } }
					},
					{
						id = "PELLITINE", name = SI_ECB_MOTIF_PELLITINE, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6509, name = "", unlocked = false, label = nil }, { id = 6510, name = "", unlocked = false, label = nil },
							{ id = 6511, name = "", unlocked = false, label = nil }, { id = 6512, name = "", unlocked = false, label = nil },
							{ id = 6513, name = "", unlocked = false, label = nil }, { id = 6514, name = "", unlocked = false, label = nil },
							{ id = 6515, name = "", unlocked = false, label = nil }, { id = 6534, name = "", unlocked = false, label = nil },
							{ id = 6535, name = "", unlocked = false, label = nil }, { id = 6536, name = "", unlocked = false, label = nil },
							{ id = 6537, name = "", unlocked = false, label = nil }, { id = 6538, name = "", unlocked = false, label = nil },
							{ id = 6539, name = "", unlocked = false, label = nil }, { id = 6540, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ANEQUINA", name = SI_ECB_MOTIF_ANEQUINA, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6541, name = "", unlocked = false, label = nil }, { id = 6542, name = "", unlocked = false, label = nil },
							{ id = 6543, name = "", unlocked = false, label = nil }, { id = 6544, name = "", unlocked = false, label = nil },
							{ id = 6545, name = "", unlocked = false, label = nil }, { id = 6546, name = "", unlocked = false, label = nil },
							{ id = 6547, name = "", unlocked = false, label = nil }, { id = 6566, name = "", unlocked = false, label = nil },
							{ id = 6567, name = "", unlocked = false, label = nil }, { id = 6568, name = "", unlocked = false, label = nil },
							{ id = 6569, name = "", unlocked = false, label = nil }, { id = 6570, name = "", unlocked = false, label = nil },
							{ id = 6571, name = "", unlocked = false, label = nil }, { id = 6572, name = "", unlocked = false, label = nil } }
					},
					{
						id = "SKINCHANGER", name = SI_ECB_MOTIF_SKINCHANGER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4086, name = "", unlocked = false, label = nil }, { id = 4087, name = "", unlocked = false, label = nil },
								 { id = 4088, name = "", unlocked = false, label = nil }, { id = 4089, name = "", unlocked = false, label = nil },
								 { id = 4090, name = "", unlocked = false, label = nil }, { id = 4091, name = "", unlocked = false, label = nil },
								 { id = 4092, name = "", unlocked = false, label = nil }, { id = 4903, name = "", unlocked = false, label = nil },
								 { id = 4071, name = "", unlocked = false, label = nil }, { id = 4072, name = "", unlocked = false, label = nil },
								 { id = 4073, name = "", unlocked = false, label = nil }, { id = 4074, name = "", unlocked = false, label = nil },
								 { id = 4075, name = "", unlocked = false, label = nil }, { id = 4076, name = "", unlocked = false, label = nil } }
					},
					{
						id = "HOLLOWJACK", name = SI_ECB_MOTIF_HOLLOWJACK, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4258, name = "", unlocked = false, label = nil }, { id = 4246, name = "", unlocked = false, label = nil },
								 { id = 4247, name = "", unlocked = false, label = nil }, { id = 4248, name = "", unlocked = false, label = nil },
								 { id = 4249, name = "", unlocked = false, label = nil }, { id = 4250, name = "", unlocked = false, label = nil },
								 { id = 4251, name = "", unlocked = false, label = nil }, { id = 4907, name = "", unlocked = false, label = nil },
								 { id = 4239, name = "", unlocked = false, label = nil }, { id = 4240, name = "", unlocked = false, label = nil },
								 { id = 4241, name = "", unlocked = false, label = nil }, { id = 4242, name = "", unlocked = false, label = nil },
								 { id = 4243, name = "", unlocked = false, label = nil }, { id = 4244, name = "", unlocked = false, label = nil } }
					},
					{
						id = "WORM_CULT", name = SI_ECB_MOTIF_WORM_CULT, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4214, name = "", unlocked = false, label = nil }, { id = 4215, name = "", unlocked = false, label = nil },
								 { id = 4216, name = "", unlocked = false, label = nil }, { id = 4217, name = "", unlocked = false, label = nil },
								 { id = 4218, name = "", unlocked = false, label = nil }, { id = 4219, name = "", unlocked = false, label = nil },
								 { id = 4220, name = "", unlocked = false, label = nil }, { id = 4906, name = "", unlocked = false, label = nil },
								 { id = 4208, name = "", unlocked = false, label = nil }, { id = 4209, name = "", unlocked = false, label = nil },
								 { id = 4210, name = "", unlocked = false, label = nil }, { id = 4211, name = "", unlocked = false, label = nil },
								 { id = 4212, name = "", unlocked = false, label = nil }, { id = 4213, name = "", unlocked = false, label = nil } }
					},
					{
						id = "DREMORA", name = SI_ECB_MOTIF_DREMORA, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4652, name = "", unlocked = false, label = nil }, { id = 4653, name = "", unlocked = false, label = nil },
								 { id = 4654, name = "", unlocked = false, label = nil }, { id = 4655, name = "", unlocked = false, label = nil },
								 { id = 4656, name = "", unlocked = false, label = nil }, { id = 4657, name = "", unlocked = false, label = nil },
								 { id = 4658, name = "", unlocked = false, label = nil }, { id = 4921, name = "", unlocked = false, label = nil },
								 { id = 4631, name = "", unlocked = false, label = nil }, { id = 4632, name = "", unlocked = false, label = nil },
								 { id = 4633, name = "", unlocked = false, label = nil }, { id = 4634, name = "", unlocked = false, label = nil },
								 { id = 4635, name = "", unlocked = false, label = nil }, { id = 4636, name = "", unlocked = false, label = nil } }
					}
				}
			}
		},
		{ -- styles
			id = ECB.constants.categories.STYLES,
			title = SI_ECB_TITLE_STYLES,
			parameters = {
				tracker = {
					label = ECB_TRACKER_CONTENT_BODY_STYLES,
					body = ECB_TRACKER_CONTENT_BODY_STYLES_LIST,
					active = true,
					open = false,
					unlockedCount = 0
				},
				book = {
					settings = {
						value = true
					}
				}
			},
			collectibles = {
				parameters = { pattern = "ECB_TRACKER_CONTENT_BODY_STYLES_LIST_STYLE_" },
				list = {
					{
						id = "PRISONER", name = SI_ECB_STYLE_PRISONER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 4986, name = "", unlocked = false, label = nil }, { id = 4987, name = "", unlocked = false, label = nil },
								 { id = 4988, name = "", unlocked = false, label = nil }, { id = 4989, name = "", unlocked = false, label = nil },
								 { id = 4990, name = "", unlocked = false, label = nil }, { id = 4991, name = "", unlocked = false, label = nil },
								 { id = 4992, name = "", unlocked = false, label = nil } }
					},
					{	id = "PSIJIC_STYLE", name = SI_ECB_STYLE_PSIJIC_STYLE, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5111, name = "", unlocked = false, label = nil }, { id = 5114, name = "", unlocked = false, label = nil } } },
					{
						id = "FANGED_WORM", name = SI_ECB_STYLE_FANGED_WORM, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5355, name = "", unlocked = false, label = nil }, { id = 5356, name = "", unlocked = false, label = nil },
								 { id = 5357, name = "", unlocked = false, label = nil }, { id = 5358, name = "", unlocked = false, label = nil },
								 { id = 5359, name = "", unlocked = false, label = nil }, { id = 5360, name = "", unlocked = false, label = nil },
								 { id = 5361, name = "", unlocked = false, label = nil }, { id = 5362, name = "", unlocked = false, label = nil },
								 { id = 5363, name = "", unlocked = false, label = nil }, { id = 5364, name = "", unlocked = false, label = nil },
								 { id = 5365, name = "", unlocked = false, label = nil }, { id = 5366, name = "", unlocked = false, label = nil },
								 { id = 5367, name = "", unlocked = false, label = nil }, { id = 5368, name = "", unlocked = false, label = nil },
								 { id = 5369, name = "", unlocked = false, label = nil }, { id = 5370, name = "", unlocked = false, label = nil },
								 { id = 5371, name = "", unlocked = false, label = nil }, { id = 5372, name = "", unlocked = false, label = nil },
								 { id = 5373, name = "", unlocked = false, label = nil }, { id = 5374, name = "", unlocked = false, label = nil },
								 { id = 5375, name = "", unlocked = false, label = nil }, { id = 5376, name = "", unlocked = false, label = nil },
								 { id = 5378, name = "", unlocked = false, label = nil }, { id = 5379, name = "", unlocked = false, label = nil },
								 { id = 5380, name = "", unlocked = false, label = nil }, { id = 5381, name = "", unlocked = false, label = nil },
								 { id = 5382, name = "", unlocked = false, label = nil }, { id = 5383, name = "", unlocked = false, label = nil },
								 { id = 5384, name = "", unlocked = false, label = nil }, { id = 5385, name = "", unlocked = false, label = nil },
								 { id = 5386, name = "", unlocked = false, label = nil }, { id = 5387, name = "", unlocked = false, label = nil } }
					},
					{
						id = "HORNED_DRAGON", name = SI_ECB_STYLE_HORNED_DRAGON, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5420, name = "", unlocked = false, label = nil }, { id = 5421, name = "", unlocked = false, label = nil },
								 { id = 5422, name = "", unlocked = false, label = nil }, { id = 5423, name = "", unlocked = false, label = nil },
								 { id = 5424, name = "", unlocked = false, label = nil }, { id = 5425, name = "", unlocked = false, label = nil },
								 { id = 5426, name = "", unlocked = false, label = nil }, { id = 5427, name = "", unlocked = false, label = nil },
								 { id = 5428, name = "", unlocked = false, label = nil }, { id = 5429, name = "", unlocked = false, label = nil },
								 { id = 5430, name = "", unlocked = false, label = nil }, { id = 5431, name = "", unlocked = false, label = nil },
								 { id = 5432, name = "", unlocked = false, label = nil }, { id = 5433, name = "", unlocked = false, label = nil },
								 { id = 5434, name = "", unlocked = false, label = nil }, { id = 5435, name = "", unlocked = false, label = nil },
								 { id = 5436, name = "", unlocked = false, label = nil }, { id = 5437, name = "", unlocked = false, label = nil },
								 { id = 5438, name = "", unlocked = false, label = nil }, { id = 5439, name = "", unlocked = false, label = nil },
								 { id = 5440, name = "", unlocked = false, label = nil }, { id = 5441, name = "", unlocked = false, label = nil },
								 { id = 5442, name = "", unlocked = false, label = nil }, { id = 5443, name = "", unlocked = false, label = nil },
								 { id = 5444, name = "", unlocked = false, label = nil }, { id = 5445, name = "", unlocked = false, label = nil },
								 { id = 5446, name = "", unlocked = false, label = nil }, { id = 5447, name = "", unlocked = false, label = nil },
								 { id = 5448, name = "", unlocked = false, label = nil }, { id = 5449, name = "", unlocked = false, label = nil },
								 { id = 5450, name = "", unlocked = false, label = nil }, { id = 5451, name = "", unlocked = false, label = nil } }
					},
					{
						id = "PIT_DAEMON", name = SI_ECB_STYLE_PIT_DAEMON, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5621, name = "", unlocked = false, label = nil }, { id = 5622, name = "", unlocked = false, label = nil },
								 { id = 5623, name = "", unlocked = false, label = nil }, { id = 5624, name = "", unlocked = false, label = nil },
								 { id = 5625, name = "", unlocked = false, label = nil }, { id = 5626, name = "", unlocked = false, label = nil },
								 { id = 5627, name = "", unlocked = false, label = nil }, { id = 6229, name = "", unlocked = false, label = nil },
								 { id = 6230, name = "", unlocked = false, label = nil }, { id = 6231, name = "", unlocked = false, label = nil },
								 { id = 6232, name = "", unlocked = false, label = nil }, { id = 6233, name = "", unlocked = false, label = nil },
								 { id = 6234, name = "", unlocked = false, label = nil }, { id = 6235, name = "", unlocked = false, label = nil },
								 { id = 6236, name = "", unlocked = false, label = nil }, { id = 6237, name = "", unlocked = false, label = nil },
								 { id = 6238, name = "", unlocked = false, label = nil } }
					},
					{
						id = "STORMLORD", name = SI_ECB_STYLE_STORMLORD, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5628, name = "", unlocked = false, label = nil }, { id = 5629, name = "", unlocked = false, label = nil },
								 { id = 5630, name = "", unlocked = false, label = nil }, { id = 5631, name = "", unlocked = false, label = nil },
								 { id = 5632, name = "", unlocked = false, label = nil }, { id = 5633, name = "", unlocked = false, label = nil },
								 { id = 5634, name = "", unlocked = false, label = nil }, { id = 6209, name = "", unlocked = false, label = nil },
								 { id = 6210, name = "", unlocked = false, label = nil }, { id = 6211, name = "", unlocked = false, label = nil },
								 { id = 6212, name = "", unlocked = false, label = nil }, { id = 6213, name = "", unlocked = false, label = nil },
								 { id = 6214, name = "", unlocked = false, label = nil }, { id = 6215, name = "", unlocked = false, label = nil },
								 { id = 6216, name = "", unlocked = false, label = nil }, { id = 6217, name = "", unlocked = false, label = nil },
								 { id = 6218, name = "", unlocked = false, label = nil } }
					},
					{
						id = "FIREDRAKE", name = SI_ECB_STYLE_FIREDRAKE, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5645, name = "", unlocked = false, label = nil }, { id = 5646, name = "", unlocked = false, label = nil },
								 { id = 5647, name = "", unlocked = false, label = nil }, { id = 5648, name = "", unlocked = false, label = nil },
								 { id = 5649, name = "", unlocked = false, label = nil }, { id = 5650, name = "", unlocked = false, label = nil },
								 { id = 5651, name = "", unlocked = false, label = nil }, { id = 6219, name = "", unlocked = false, label = nil },
								 { id = 6220, name = "", unlocked = false, label = nil }, { id = 6221, name = "", unlocked = false, label = nil },
								 { id = 6222, name = "", unlocked = false, label = nil }, { id = 6223, name = "", unlocked = false, label = nil },
								 { id = 6224, name = "", unlocked = false, label = nil }, { id = 6225, name = "", unlocked = false, label = nil },
								 { id = 6226, name = "", unlocked = false, label = nil }, { id = 6227, name = "", unlocked = false, label = nil },
								 { id = 6228, name = "", unlocked = false, label = nil } }
					},
					{	id = "ILAMBRIS", name = SI_ECB_STYLE_ILAMBRIS, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5452, name = "", unlocked = false, label = nil }, { id = 5453, name = "", unlocked = false, label = nil } } },
					{	id = "MOLAG_KENA", name = SI_ECB_STYLE_MOLAG_KENA, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5454, name = "", unlocked = false, label = nil }, { id = 5455, name = "", unlocked = false, label = nil } } },
					{	id = "SHADOWREND", name = SI_ECB_STYLE_SHADOWREND, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5456, name = "", unlocked = false, label = nil }, { id = 5457, name = "", unlocked = false, label = nil } } },
					{	id = "GROTHDARR", name = SI_ECB_STYLE_GROTHDARR, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5545, name = "", unlocked = false, label = nil }, { id = 5546, name = "", unlocked = false, label = nil } } },
					{	id = "TROLL_KING", name = SI_ECB_STYLE_TROLL_KING, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5607, name = "", unlocked = false, label = nil }, { id = 5608, name = "", unlocked = false, label = nil } } },
					{	id = "ICEHEART", name = SI_ECB_STYLE_ICEHEART, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5615, name = "", unlocked = false, label = nil }, { id = 5616, name = "", unlocked = false, label = nil } } },
					{	id = "SELLISTRIX", name = SI_ECB_STYLE_SELLISTRIX, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5763, name = "", unlocked = false, label = nil }, { id = 5764, name = "", unlocked = false, label = nil } } },
					{	id = "BLOODSPAWN", name = SI_ECB_STYLE_BLOODSPAWN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5924, name = "", unlocked = false, label = nil }, { id = 5925, name = "", unlocked = false, label = nil } } },
					{	id = "SWARM_MOTHER", name = SI_ECB_STYLE_SWARM_MOTHER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5926, name = "", unlocked = false, label = nil }, { id = 5927, name = "", unlocked = false, label = nil } } },
					{	id = "ENGINE_GUARDIAN", name = SI_ECB_STYLE_ENGINE_GUARDIAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6044, name = "", unlocked = false, label = nil }, { id = 6045, name = "", unlocked = false, label = nil } } },
					{	id = "VALKYN_SKORIA", name = SI_ECB_STYLE_VALKYN_SKORIA, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6174, name = "", unlocked = false, label = nil }, { id = 6175, name = "", unlocked = false, label = nil } } },
					{	id = "NIGHTFLAME", name = SI_ECB_STYLE_NIGHTFLAME, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6251, name = "", unlocked = false, label = nil }, { id = 6252, name = "", unlocked = false, label = nil } } },
					{	id = "LORD_WARDEN", name = SI_ECB_STYLE_LORD_WARDEN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6388, name = "", unlocked = false, label = nil }, { id = 6389, name = "", unlocked = false, label = nil } } },
					{	id = "MIGHTY_CHUDAN", name = SI_ECB_STYLE_MIGHTY_CHUDAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6690, name = "", unlocked = false, label = nil }, { id = 6691, name = "", unlocked = false, label = nil } } },
					{	id = "VELIDRETH", name = SI_ECB_STYLE_VELIDRETH, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6692, name = "", unlocked = false, label = nil }, { id = 6693, name = "", unlocked = false, label = nil } } },
					{
						id = "CADWELL", name = SI_ECB_STYLE_CADWELL, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6097, name = "", unlocked = false, label = nil }, { id = 6098, name = "", unlocked = false, label = nil },
								 { id = 6099, name = "", unlocked = false, label = nil }, { id = 6100, name = "", unlocked = false, label = nil },
								 { id = 6101, name = "", unlocked = false, label = nil }, { id = 6102, name = "", unlocked = false, label = nil },
								 { id = 6103, name = "", unlocked = false, label = nil }, { id = 6104, name = "", unlocked = false, label = nil },
								 { id = 6105, name = "", unlocked = false, label = nil }, { id = 6106, name = "", unlocked = false, label = nil } }
					},
					{
						id = "PROPHET", name = SI_ECB_STYLE_PROPHET, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6141, name = "", unlocked = false, label = nil }, { id = 6142, name = "", unlocked = false, label = nil },
								 { id = 6143, name = "", unlocked = false, label = nil }, { id = 6144, name = "", unlocked = false, label = nil },
								 { id = 6145, name = "", unlocked = false, label = nil }, { id = 6146, name = "", unlocked = false, label = nil },
								 { id = 6295, name = "", unlocked = false, label = nil } }
					},
					{
						id = "LYRIS_TITANBORN", name = SI_ECB_STYLE_LYRIS_TITANBORN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6147, name = "", unlocked = false, label = nil }, { id = 6148, name = "", unlocked = false, label = nil },
								 { id = 6149, name = "", unlocked = false, label = nil }, { id = 6150, name = "", unlocked = false, label = nil },
								 { id = 6151, name = "", unlocked = false, label = nil }, { id = 6152, name = "", unlocked = false, label = nil },
								 { id = 6153, name = "", unlocked = false, label = nil }, { id = 6155, name = "", unlocked = false, label = nil } }
					},
					{
						id = "SAI_SAHAN", name = SI_ECB_STYLE_SAI_SAHAN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6158, name = "", unlocked = false, label = nil }, { id = 6159, name = "", unlocked = false, label = nil },
								 { id = 6160, name = "", unlocked = false, label = nil }, { id = 6161, name = "", unlocked = false, label = nil },
								 { id = 6162, name = "", unlocked = false, label = nil }, { id = 6163, name = "", unlocked = false, label = nil },
								 { id = 6164, name = "", unlocked = false, label = nil }, { id = 6157, name = "", unlocked = false, label = nil } }
					},
					{
						id = "ABNUR_THARN", name = SI_ECB_STYLE_ABNUR_THARN, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6167, name = "", unlocked = false, label = nil }, { id = 6168, name = "", unlocked = false, label = nil },
								 { id = 6169, name = "", unlocked = false, label = nil }, { id = 6170, name = "", unlocked = false, label = nil },
								 { id = 6171, name = "", unlocked = false, label = nil }, { id = 6172, name = "", unlocked = false, label = nil },
								 { id = 6173, name = "", unlocked = false, label = nil }, { id = 6165, name = "", unlocked = false, label = nil } }
					},
					{	id = "MOON_CRESCENT", name = SI_ECB_STYLE_MOON_CRESCENT, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6496, name = "", unlocked = false, label = nil }, { id = 6497, name = "", unlocked = false, label = nil } } },
					{	id = "SKYTERROR_DRAGONSLAYER", name = SI_ECB_STYLE_SKYTERROR_DRAGONSLAYER, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6593, name = "", unlocked = false, label = nil }, { id = 6594, name = "", unlocked = false, label = nil } } },
					{
						id = "SECOND_LEGION", name = SI_ECB_STYLE_SECOND_LEGION, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 6467, name = "", unlocked = false, label = nil }, { id = 6468, name = "", unlocked = false, label = nil },
								 { id = 6469, name = "", unlocked = false, label = nil }, { id = 6470, name = "", unlocked = false, label = nil },
								 { id = 6471, name = "", unlocked = false, label = nil }, { id = 6472, name = "", unlocked = false, label = nil },
								 { id = 6473, name = "", unlocked = false, label = nil }, { id = 6474, name = "", unlocked = false, label = nil },
								 { id = 6475, name = "", unlocked = false, label = nil }, { id = 6476, name = "", unlocked = false, label = nil },
								 { id = 6586, name = "", unlocked = false, label = nil }, { id = 6587, name = "", unlocked = false, label = nil },
								 { id = 6588, name = "", unlocked = false, label = nil }, { id = 6589, name = "", unlocked = false, label = nil },
								 { id = 6590, name = "", unlocked = false, label = nil }, { id = 6591, name = "", unlocked = false, label = nil },
								 { id = 6592, name = "", unlocked = false, label = nil }
						}
					},
					{	id = "OTHERS", name = SI_ECB_STYLE_OTHERS, label = nil, body = nil, active = true, open = false, unlockedCount = 0,
						list = { { id = 5472, name = "", unlocked = false, label = nil } } }
				}
			}
		}
	}
end

