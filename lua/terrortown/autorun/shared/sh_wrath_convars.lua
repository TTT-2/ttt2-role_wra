CreateConVar("ttt_wrath_cannot_see_own_role", 1, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})
CreateConVar("ttt_wrath_revival_time", 15, {FCVAR_ARCHIVE, FCVAR_NOTIFY, FCVAR_REPLICATED})

if SERVER then
	hook.Add("TTT2SyncGlobals", "ttt2_wrath_sync_convars", function()
		SetGlobalBool("ttt_wrath_cannot_see_own_role", GetConVar("ttt_wrath_cannot_see_own_role"):GetBool())
		SetGlobalInt("ttt_wrath_revival_time", GetConVar("ttt_wrath_revival_time"):GetInt())
	end)

	cvars.AddChangeCallback("ttt_wrath_cannot_see_own_role", function(cv, old, new)
		SetGlobalBool("ttt_wrath_cannot_see_own_role", tobool(tonumber(new)))
	end)

	cvars.AddChangeCallback("ttt_wrath_revival_time", function(cv, old, new)
		SetGlobalInt("ttt_wrath_revival_time", tonumber(new))
	end)
end
