L = LANG.GetLanguageTableReference("en")

-- GENERAL ROLE LANGUAGE STRINGS
L[WRATH.name] = "Wrath"
L["info_popup_" .. WRATH.name] = [[You are a Wrath, work with the innocents to win!]]
L["body_found_" .. WRATH.abbr] = "They were a Wrath."
L["search_role_" .. WRATH.abbr] = "This person was a Wrath!"
L["target_" .. WRATH.name] = "Wrath"
L["ttt2_desc_" .. WRATH.name] = [[The Wrath is an innocent role and works with the innocents to win. However, if they are killed by another innocent, they will be revived
 and turned into a traitor.]]

-- OTHER ROLE LANGUAGE STRINGS

L["ttt2_role_wrath_revival_message"] = "You will be revived as a Traitor!"

L["label_wrath_cannot_see_own_role"] = "Wrath sees themselves as innocent"
L["label_wrath_revival_time"] = "Time until revival"
