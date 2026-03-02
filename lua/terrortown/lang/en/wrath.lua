local L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[WRATH.name] = "Wrath"
L["info_popup_" .. WRATH.name] = [[You are a Wrath, work with the innocents to win!]]
L["body_found_" .. WRATH.abbr] = "They were a Wrath."
L["search_role_" .. WRATH.abbr] = "This person was a Wrath!"
L["target_" .. WRATH.name] = "Wrath"
L["ttt2_desc_" .. WRATH.name] = [[The Wrath is an innocent role and works with the innocents to win. However, if they are killed by another innocent, they will be revived
 and turned into a traitor.]]

-- OTHER ROLE LANGUAGE STRINGS
L["ttt2_role_wrath_revive_keys"] = "You will be revived as a Traitor!\nPress {keycorpse} to respawn at your corpse.\nPress {keyspawn} to respawn at spawn."

L["label_wrath_cannot_see_own_role"] = "Wrath sees themselves as innocent"
L["label_wrath_revival_time"] = "Time until revival"
L["label_wrath_min_revival_time"] = "Time until the player may use a key to respawn"

L["label_wrath_binding_header"] = "Roles"
L["label_wrath_binding_corpse"] = "Wrath - Respawn at corpse"
L["label_wrath_binding_spawn"] = "Wrath - Respawn at spawn"
