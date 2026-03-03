local L = LANG.GetLanguageTableReference("de")

-- GENERAL ROLE LANGUAGE STRINGS
L[WRATH.name] = "Groll"
L["info_popup_" .. WRATH.name] = [[Du bist ein Groll, arbeite mit den Unschuldigen um zu gewinnen!]]
L["body_found_" .. WRATH.abbr] = "Er war ein Groll."
L["search_role_" .. WRATH.abbr] = "Diese Person war ein Groll!"
L["target_" .. WRATH.name] = "Groll"
L["ttt2_desc_" .. WRATH.name] = [[Der Groll versucht mit den Unschuldigen zu gewinnen, wenn er jedoch von einem Unschuuldigen getötet wird tritt er dem Verräterteam bei 
und wird Wiederbelebt.]]

-- OTHER ROLE LANGUAGE STRINGS
L["ttt2_role_wrath_revive_keys"] = "Du wirst als Verräter wiederbelebt werden!\nDrücke {keycorpse}, um an deiner Leiche wiederbelebt zu werden.\nDrücke {keyspawn}, um am Spawnpunkt wiederbelebt zu werden."

L["label_wrath_cannot_see_own_role"] = "Groll sieht sich selbst als Unschuldiger"
L["label_wrath_revival_time"] = "Zeit bis zur Wiederbelebung"
L["label_wrath_min_revival_time"] = "Zeit bis der Spieler eine Taste zum Wiederbeleben benutzen darf"

L["label_wrath_binding_header"] = "Rollen"
L["label_wrath_binding_corpse"] = "Groll - Wiederbelebung an Leiche"
L["label_wrath_binding_spawn"] = "Groll - Wiederbelebung am Spawn"
