local L = LANG.GetLanguageTableReference("ru")

-- GENERAL ROLE LANGUAGE STRINGS
L[WRATH.name] = "Гнев"
L["info_popup_" .. WRATH.name] = [[Вы Гнев, работай с невинными, чтобы победить!]]
L["body_found_" .. WRATH.abbr] = "Он был гневом."
L["search_role_" .. WRATH.abbr] = "Этот человек был гневом!"
L["target_" .. WRATH.name] = "Гнев"
L["ttt2_desc_" .. WRATH.name] = [[Гнев - это невиновная роль, и она работает с невиновными для победы. Однако, если его убьёт другой невиновный, он будет воскрешён,
 и превратится в предателя.]]

-- OTHER ROLE LANGUAGE STRINGS
L["ttt2_role_wrath_revive_keys"] = "Вы будете воскрешены как предатель!\nНажмите {keycorpse}, чтобы возродиться у вашего трупа.\nНажмите {keyspawn}, чтобы возродиться на месте возрождения."

--L["label_wrath_cannot_see_own_role"] = "Wrath sees themselves as innocent"
--L["label_wrath_revival_time"] = "Time until revival"
--L["label_wrath_min_revival_time"] = "Time until the player may use a key to respawn"

--L["label_wrath_binding_header"] = "Roles"
--L["label_wrath_binding_corpse"] = "Wrath - Respawn at corpse"
--L["label_wrath_binding_spawn"] = "Wrath - Respawn at spawn"
