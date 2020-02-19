-- Icon Materials

if SERVER then
	AddCSLuaFile()
	
	resource.AddFile('materials/vgui/ttt/dynamic/roles/icon_wra.vmt')
end

-- General settings

function ROLE:PreInitialize()
	self.color = Color(085, 107, 047, 255) -- role colour
    
    -- settings for the role iself

	self.abbr = 'wra'                       -- Abbreviation
	self.survivebonus = 1                   -- points for suurviving longer
	self.preventFindCredits = true          -- can't take credits from bodies
	self.preventKillCredits = true		    -- does not get awarded credits for kills
	self.preventTraitorAloneCredits = true  -- no credits.
	self.preventWin = false                 -- cannot win unless he switches roles
	self.scoreKillsMultiplier       = 2     -- gets points for killing enemies of their team
    self.scoreTeamKillsMultiplier   = -8    -- loses points for killing teammates
    self.defaultEquuipment = INNO_EQUIPMENT -- here you can set up your own default equipment
	
	-- settings for this roles teaminteraction

    self.unknownTeam = true -- Doesn't know his teammates -> Is innocent
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

-- Role specific code

-- Check if killer was TEAM_INNOCENT. If yes respawn Wrath as traitor.

if SERVER then
	hook.Add("PlayerDeath", "WrathDeath", function(victim, infl, attacker)
		
		-- check if victim was wrath and check if killer was team_innocent and is a player etc

		if victim:GetSubRole() == ROLE_WRATH and IsValid(attacker) and attacker:IsPlayer() and attacker:GetTeam() == TEAM_INNOCENT then
			
			--add revive function that revives after 15 seconds.

			victim:Revive(15, function(p)

			-- Set role to Traitor upon revive

			p:SetRole(ROLE_TRAITOR)
			
			-- Set default credits for a new traitor
			
			p:SetDefaultCredits()

			-- Send update to other traitors

			SendFullStateUpdate()
			end)
		end
	end)
end