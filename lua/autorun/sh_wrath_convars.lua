-- Implementing a ConVar for the Wraths revival time.

CreateConVar("ttt_wrath_revival_time", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

hook.Add("TTTUlxDynamicRCVars", "ttt2_ulx_dynamic_wrath_convars", function(tbl)
	tbl[ROLE_WRATH] = tbl[ROLE_WRATH] or {}
	table.insert(tbl[ROLE_WRATH], {cvar = "ttt_wrath_revival_time", slider = true, min = 0, max = 100, decimal = 0, desc = "ttt_wrath_revival_time (def. 15)"})
end)