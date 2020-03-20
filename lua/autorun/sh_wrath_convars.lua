CreateConVar("ttt_wrath_cannot_see_own_role", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
CreateConVar("ttt_wrath_revival_time", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_wrath_convars", function(tbl)
	tbl[ROLE_WRATH] = tbl[ROLE_WRATH] or {}
	
	-- Implementing a ConVar for the Wraths revival time.
	
	table.insert(tbl[ROLE_WRATH], {cvar = "ttt_wrath_revival_time", slider = true, min = 0, max = 100, decimal = 0, desc = "ttt_wrath_revival_time (def. 15)"})

	-- Implementing a ConVar that decides if the Wrath knows his role.

	table.insert(tbl[ROLE_WRATH], {cvar = "ttt_wrath_cannot_see_own_role", checkbox = true, desc = "ttt_wrath_cannot_see_own_role (def. 1)"})
end)