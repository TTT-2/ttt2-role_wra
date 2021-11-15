if SERVER then
	AddCSLuaFile()

	-- Icon Materials
	resource.AddFile("materials/vgui/ttt/dynamic/roles/icon_wra.vmt")
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
		-- create a thing for a convar
		local revive_wra_timer = GetConVar("ttt_wrath_revival_time"):GetInt()

		-- Some check for some stuff
		if victim:GetSubRole() ~= ROLE_WRATH or not IsValid(attacker) or not attacker:IsPlayer() or attacker:GetTeam() ~= TEAM_INNOCENT or victim == attacker then return end
		if SpecDM and (victim.IsGhost and victim:IsGhost() or (attacker.IsGhost and attacker:IsGhost())) then return end

		--add revive function that revives after 15 seconds.
		victim:Revive(revive_wra_timer,
			function(p)
				-- Set role to Traitor upon revive
				p:SetRole(ROLE_TRAITOR)

				-- Set default credits for a new traitor
				p:SetDefaultCredits()

				-- Reset their confirmation status, so innocents do not see the player as a traitor
				p:ResetConfirmPlayer()

				-- Send update to other traitors
				SendFullStateUpdate()
			end,
			nil, -- DoCheck -> Nil (no need) | An additional checking @{function}
			false, -- NeedsCorpse -> false | Whether the dead @{Player} @{CORPSE} is needed
			REVIVAL_BLOCK_ALL -- Stops the round from ending if this is set to true until the player is alive again
		)

		-- Add a revival message shown in the new revival hud element.
		victim:SendRevivalReason("ttt2_role_wrath_revival_message")
	end)

	-- Add a convar to make the wrath see himself as an Innocent
	hook.Add("TTT2SpecialRoleSyncing", "TTT2RoleWraMod", function(ply, tbl)
		if not GetConVar("ttt_wrath_cannot_see_own_role"):GetBool() then return end

		-- hide the role from all players (including himself)
		for wra in pairs(tbl) do
			if wra:GetSubRole() == ROLE_WRATH and wra:GetNWBool("SpawnedAsWra", -1) == -1 then
				if ply == wra then
					-- show innocent for himself
					tbl[wra] = {ROLE_INNOCENT, TEAM_INNOCENT}
				else
					-- show none for everyone else
					tbl[wra] = {ROLE_NONE, TEAM_NONE}
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
			SendRoleListMessage(ROLE_INNOCENT, TEAM_INNOCENT, {confirmed:EntIndex()})
			events.Trigger(EVENT_BODYFOUND, finder, corpse)

			return false
		end
	end)
end
