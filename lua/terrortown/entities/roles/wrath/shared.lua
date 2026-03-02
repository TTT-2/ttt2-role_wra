if SERVER then
	AddCSLuaFile()

	-- Icon Materials
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_wra.vmt")

	-- Network strings for respawn choice interface
	util.AddNetworkString("ttt2_wrath_key_respawn")
	util.AddNetworkString("ttt2_wrath_show_reason")
end

-- General settings
function ROLE:PreInitialize()
	self.color = Color(085, 107, 047, 255) -- role colour

	-- settings for the role iself
	self.abbr = "wra"                       -- Abbreviation
	self.survivebonus = 1                   -- points for surviving longer
	self.preventFindCredits = true          -- can't take credits from bodies
	self.preventKillCredits = true          -- does not get awarded credits for kills
	self.preventTraitorAloneCredits = true  -- no credits.
	self.preventWin = false                 -- cannot win unless he switches roles
	self.score.killsMultiplier = 2          -- gets points for killing enemies of their team
	self.score.teamKillsMultiplier = -8     -- loses points for killing teammates
	self.defaultEquipment = INNO_EQUIPMENT  -- here you can set up your own default equipment
	self.disableSync = true                 -- dont tell the player about his role

	-- settings for this roles teaminteraction
	self.unknownTeam = true -- Doesn't know his teammates -> Is innocent also disables voicechat
	self.defaultTeam = TEAM_INNOCENT -- Is part of team innocent

	-- ULX convars
	self.conVarData = {
		pct = 0.17,                         -- necessary: percentage of getting this role selected (per player)
		maximum = 1,                        -- maximum amount of roles in a round
		minPlayers = 8,                     -- minimum amount of players until this role is able to get selected
		credits = 0,                        -- the starting credits of a specific role
		shopFallback = SHOP_DISABLED,       -- Setting wether the role has a shop and who's shop it will use if no custom shop is set
		togglable = true,                   -- option to toggle a role for a client if possible (F1 menu)
		random = 33                         -- percentage of the chance that this role will be in a round (if set to 100 it will spawn in all rounds)
	}
end

function ROLE:Initialize()
	roles.SetBaseRole(self, ROLE_INNOCENT)
end

-- Role specific code

if SERVER then
	-- Check if killer was TEAM_INNOCENT. If yes respawn Wrath as traitor.
	hook.Add("PlayerDeath", "WrathDeath", function(victim, infl, attacker)
		-- Create local variables for convars
		local revive_wra_timer = GetConVar("ttt_wrath_revival_time"):GetInt()
		local min_revive_wra_timer = GetConVar("ttt_wrath_min_revival_time"):GetInt()

		-- Some check for some stuff
		if GetRoundState() ~= ROUND_ACTIVE then return end
		if victim:GetSubRole() ~= ROLE_WRATH or not IsValid(attacker) or not attacker:IsPlayer() or attacker:GetTeam() ~= TEAM_INNOCENT or victim == attacker then return end
		if SpecDM and (victim.IsGhost and victim:IsGhost() or (attacker.IsGhost and attacker:IsGhost())) then return end

		-- Start a revival process that defaults to respawning at corpse.
		local function OnWrathRevive(p)
			-- Set role to Traitor upon revive
			p:SetRole(ROLE_TRAITOR)

			-- Set default credits for a new traitor
			p:SetDefaultCredits()

			-- Reset their confirmation status, so innocents do not see the player as a traitor
			p:ResetConfirmPlayer()

			-- Send update to other traitors
			SendFullStateUpdate()
		end

		-- Function to call if the revival fails for some reason
		local function OnFail(ply, failMessage)
			if IsValid(ply) then
				ply:SendRevivalReason(nil)
				ply:TTT2NETSetBool("WrathRespawningAllowkey", false)
				LANG.Msg(ply, failMessage, nil, MSG_MSTACK_WARN)
			end
		end

		-- Default: Respawn at corpse
		victim:Revive(revive_wra_timer, OnWrathRevive, nil, false, REVIVAL_BLOCK_ALL, OnFail)
		-- nil - DoCheck -> Nil (no need) | An additional checking @{function}
		-- false - NeedsCorpse -> false | Whether the dead @{Player} @{CORPSE} is needed
		-- REVIVAL_BLOCK_ALL - Stops the round from ending if this is set to true until the player is alive again

		-- Allow the player to choose spawn after a short delay
		timer.Simple(min_revive_wra_timer, function()
			if not IsValid(victim) then return end
			victim:TTT2NETSetBool("WrathRespawningAllowkey", true)
			net.Start("ttt2_wrath_show_reason")
			net.Send(victim)
		end)
	end)

	-- Add a convar to make the wrath see himself as an Innocent
	hook.Add("TTT2SpecialRoleSyncing", "TTT2RoleWraMod", function(ply, tbl)
		local convarHide = GetConVar("ttt_wrath_cannot_see_own_role"):GetBool()

		-- If convar is off and no Wrath was previously confirmed, do nothing.
		local hasConfirmed = false
		for _, q in ipairs(player.GetAll()) do
			if IsValid(q) and q:GetNWBool("WrathConfirmed", false) then
				hasConfirmed = true
				break
			end
		end

		if not convarHide and not hasConfirmed then return end

		local deadPly = ply and not ply:Alive()

		-- Iterate all players (includes dead ones)
		for _, p in ipairs(player.GetAll()) do
			if IsValid(p) and p:GetSubRole() == ROLE_WRATH then
				-- If this Wrath was confirmed earlier, always show them as Innocent
				if p:GetNWBool("WrathConfirmed", false) then
					tbl[p] = {ROLE_INNOCENT, TEAM_INNOCENT}
				elseif convarHide then
					-- When convar enabled, hide from others but show to self and
					-- dead viewers only if the Wrath player is actually dead.
					if ply == p or (deadPly and not p:Alive()) then
						tbl[p] = {ROLE_INNOCENT, TEAM_INNOCENT}
					else
						tbl[p] = {ROLE_NONE, TEAM_NONE}
					end
				end
			end
		end
	end)

	-- Add that the Wrath will be confirmed as an Innocent
	hook.Add("TTTCanSearchCorpse", "TTT2WraChangeCorpseToInnocent", function(ply, corpse)
		-- Check if the Corpse is valid and if the Role was Wrath
		if IsValid(corpse) and corpse.was_role == ROLE_WRATH then
			-- Make the Role show as Innocent
			corpse.was_role = ROLE_INNOCENT

			-- Make the Role Colour be that of an Innocent
			corpse.role_color = INNOCENT.color

			-- Save the Corpse's true role for reference
			corpse.is_wrath_corpse = true
		end
	end)

	-- Add that the Wrath will be shown as an Innocent on the Scoreboard
	hook.Add("TTT2ConfirmPlayer", "TTT2WrathChangeRoleToTraitor", function(confirmed, finder, corpse)
		-- Check if the corse is valid and if the Role was Wrath
		if IsValid(confirmed) and corpse and corpse.is_wrath_corpse then
			-- Make the Role show as Innocent on the scoreboard
			confirmed:ConfirmPlayer(true)

			-- Mark this player as having been confirmed as a Wrath
			confirmed:SetNWBool("WrathConfirmed", true)

			SendRoleListMessage(ROLE_INNOCENT, TEAM_INNOCENT, {confirmed:EntIndex()})
			events.Trigger(EVENT_BODYFOUND, finder, corpse)

			return false
		end
	end)

	-- Clear WrathConfirmed and WrathRespawningAllowkey flags at round prepare
	hook.Add("TTTPrepareRound", "TTT2WrathClearFlags", function()
		for _, p in ipairs(player.GetAll()) do
			if IsValid(p) then
				p:SetNWBool("WrathConfirmed", false)
				p:TTT2NETSetBool("WrathRespawningAllowkey", false)
			end
		end
	end)

	-- Handle key respawn: Cancel current revival and respawn immediately
	net.Receive("ttt2_wrath_key_respawn", function(len, ply)
		if GetRoundState() ~= ROUND_ACTIVE then return end
		if not IsValid(ply) or not ply:TTT2NETGetBool("WrathRespawningAllowkey", false) or ply:IsTerror() then return end
		local respawnAtCorpse = net.ReadBool()

		-- Cancel existing revival and respawn immediately with chosen spawn
		ply:CancelRevival(nil, true)
		ply:SendRevivalReason(nil)
		ply:TTT2NETSetBool("WrathRespawningAllowkey", false)

		local spawnPos, spawnAngle
		if not respawnAtCorpse then
			local spawnPoint = plyspawn.GetRandomSafePlayerSpawnPoint(ply)
			if spawnPoint then
				spawnPos = spawnPoint.pos
				spawnAngle = spawnPoint.ang
			end
		end

		-- Immediately revive at chosen position
		ply:Revive(0,
			function(p)
				p:SetRole(ROLE_TRAITOR)
				p:SetDefaultCredits()
				p:ResetConfirmPlayer()
				SendFullStateUpdate()
			end,
			nil,
			false,
			REVIVAL_BLOCK_ALL,
			function(p, failMessage)
				if IsValid(p) then
					p:TTT2NETSetBool("WrathRespawningAllowkey", false)
					LANG.Msg(p, failMessage, nil, MSG_MSTACK_WARN)
				end
			end,
			spawnPos,
			spawnAngle
		)
	end)
end

if CLIENT then
	function ROLE:AddToSettingsMenu(parent)
		local form = vgui.CreateTTT2Form(parent, "header_roles_additional")

		form:MakeCheckBox({
			serverConvar = "ttt_wrath_cannot_see_own_role",
			label = "label_wrath_cannot_see_own_role"
		})

		form:MakeSlider({
			serverConvar = "ttt_wrath_revival_time",
			label = "label_wrath_revival_time",
			min = 0,
			max = 100,
			decimal = 0
		})

		form:MakeSlider({
			serverConvar = "ttt_wrath_min_revival_time",
			label = "label_wrath_min_revival_time",
			min = 0,
			max = 100,
			decimal = 0
		})
	end

	net.Receive("ttt2_wrath_show_reason", function()
		local corpseKey = bind.Find("ttt2_wrath_respawn_corpse") == KEY_NONE and "NONE" or string.upper(input.GetKeyName(bind.Find("ttt2_wrath_respawn_corpse")))
		local spawnKey = bind.Find("ttt2_wrath_respawn_spawn") == KEY_NONE and "NONE" or string.upper(input.GetKeyName(bind.Find("ttt2_wrath_respawn_spawn")))
		LocalPlayer():SetRevivalReason("ttt2_role_wrath_revive_keys", {keycorpse = corpseKey, keyspawn = spawnKey})
	end)

	hook.Add("Initialize", "TTT2WrathKeyBinds", function()
		bind.Register("ttt2_wrath_respawn_corpse", function()
			if not LocalPlayer():TTT2NETGetBool("WrathRespawningAllowkey", false) then return end
			net.Start("ttt2_wrath_key_respawn")
			net.WriteBool(true)
			net.SendToServer()
		end, nil, "label_wrath_binding_header", "label_wrath_binding_corpse", KEY_R)

		bind.Register("ttt2_wrath_respawn_spawn", function()
			if not LocalPlayer():TTT2NETGetBool("WrathRespawningAllowkey", false) then return end
			net.Start("ttt2_wrath_key_respawn")
			net.WriteBool(false)
			net.SendToServer()
		end, nil, "label_wrath_binding_header", "label_wrath_binding_spawn", KEY_SPACE)
	end)
end
