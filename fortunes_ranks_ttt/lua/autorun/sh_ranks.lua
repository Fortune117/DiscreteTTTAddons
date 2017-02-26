
local PLY = FindMetaTable('Player')
local WEP = FindMetaTable( "Weapon" )

ROLE_INNOCENT  = 0
ROLE_TRAITOR   = 1
ROLE_DETECTIVE = 2
ROLE_NONE = ROLE_INNOCENT

-- this is a list of sniper rifles, used to determine what medals the player should get
local snipers = 
{
	"weapon_zm_rifle",
}
function WEP:IsSniper()
	return table.HasValue( snipers, self:GetClass() )
end

-- same purpose as above, but for melee
local melee = 
{
	"weapon_zm_improvised",
}
function WEP:IsMelee()
	return table.HasValue( melee, self:GetClass() )
end

function WEP:IsKnife()
	if self.bIsKnife then 
		return self.bIsKnife
	else
		return false 
	end 
end

RANKS = {}
RANKS.LIST = {}
RANKS.LIST.Player = -- This is a list of all the ranks a player can get. First value is the rank name, second is the xp required.
{
	{ "New Guy", 0 },
	{ "Recruit", 750 },
	{ "Regular I", 1050 }, 
	{ "Regular II", 1470 },
	{ "Regular III", 2058 },
	{ "Frequently Terrorising", 2881 },
	{ "Isolated Innocent", 4033 },
	{ "Back-Stabber", 5647 },
	{ "Tireless Traitor", 7906 },
	{ "Private Investigator", 11068 },
	{ "Diligent Detective", 15495 },
	{ "Professional Terrorist", 21693 },
	{ "Accomplished Terrorist", 30370 },
	{ "Master Terrorist", 42518 },
	{ "Terrifying Tactitian", 59525 },
	{ "Veteran", 83335 },
	{ "Puppet Master", 116669 },
	{ "Master of Deceit", 163337 },
	{ "Terrorist Leader", 228672 },
	{ "The Shadow", 320140 },
	{ "Lord of Darkness", 448197 },
	{ "Death Incarnate", 627475 },
	{ "The Master", 878466 },
	{ "Demon", 1229852 },
	{ "God King", 1721794 },
	{ "The Serpent", 2410511 },
	{ "The Overseer.", 3374716 }
}

function util.GetLivingPlayers(class)
   local count = 0
   local players = {}
   for k, v in ipairs(team.GetPlayers(class)) do
      if (v:Alive() and not v:IsSpec()) then
         count = count + 1
         players[ #players+1 ] = v
      end
   end
   return count, players
end

function SelectRankTable( ply )
	return RANKS.LIST.Player
end

function GetXPName( ply )
	return "XP_TTT"
end

function PLY:IsInnocent()
	return self:GetRole() == ROLE_INNOCENT
end

if SERVER then

	___FastDLLoaded = ___FastDLLoaded or false 
	function AddDir(dir) // recursively adds everything in a directory to be downloaded by client  
		local files, directories = file.Find( dir.."/*", "GAME")
		for k,v in pairs( files ) do
			resource.AddFile(dir.."/"..v)
		end

		for k,v in pairs( directories ) do
			AddDir( dir.."/"..v )
		end
	end

	AddDir( "materials/medals" )
	AddDir( "sound/medals" )


	hook.Add("PlayerInitialSpawn", "SetUpXP", function( ply )
		local xp_name = GetXPName( ply )
		if not ply:GetPData(xp_name,0) then
			ply:SetPData(xp_name, 0 )
		end

		if not ply:GetPData( "pointxp", 0 ) then 
			ply:SetPData( "pointxp", 0 )
		end 
		ply:SetNWInt(xp_name, ply:GetPData( xp_name ) )
		ply:SetNWInt("pointxp", ply:GetPData( "pointxp" ) )
	end)

end

function util.GetPlayersInRole( ROLE )
	local plys = {}
	for k, v in pairs( player.GetAll() ) do
		if v:GetRole() == ROLE then
			plys[ #plys+1 ] = v
		end
	end
	return plys 
end 

local role_allys = 
{
	[ ROLE_INNOCENT ] = { ROLE_INNOCENT, ROLE_DETECTIVE },
	[ ROLE_DETECTIVE ] = { ROLE_INNOCENT, ROLE_DETECTIVE },
	[ ROLE_TRAITOR ] = { ROLE_TRAITOR }
}
function PLY:IsAlly( ply )
	if not ply:IsPlayer() then
		return false 
	end
	if ply.IsGhost and ply:IsGhost() then return false end 
	if GetRoundState() == ROUND_POST then return false end 
	local self_role = self:GetRole()
	local ply_role = ply:GetRole()
	if role_allys[ self_role ] and role_allys[ ply_role ] then
		if table.HasValue( role_allys[ self_role ], ply_role ) then
			return true 
		end
		return false
	else 
		print( "[MEDALS] One of the players roles were not valid." )
		return false 
	end
end

if SERVER then

	util.AddNetworkString("XPNotification")
	util.AddNetworkString("SyncXP")
	util.AddNetworkString("LevelUp")

	_FirstKill = true

	hook.Add( "TTTBeginRound", "ResetMedalValues", function()
		for k,ply in pairs( player.GetAll() ) do
			ply.LastVictim = nil
			ply.LastTarget = nil
			ply.LastAttackTime = nil
			ply.lastattacker = nil
			ply.lastattacktime = nil
		end
		_FirstKill = true
	end)
	
	
	function PLY:SyncXP()
		local xp_name = GetXPName( self )
		self:SetPData(xp_name, self:GetNWInt(xp_name) )
		net.Start("SyncXP")
			net.WriteInt( self:GetNWInt(xp_name), 32 )
		net.Send( self )
	end
	
	function PLY:SyncRoundData()
		self:SetPData("Rounds", self:GetNWInt("Rounds") )
		self:SetPData("Wins", self:GetNWInt("Wins") )
		net.Start("SyncRoundData")
			net.WriteInt( self:GetNWInt("Rounds"), 32 )
			net.WriteInt( self:GetNWInt("Wins"), 28 )
		net.Send( self )
	end
	
	function PLY:SetXP( num ) -- use this function to set a players XP
		local xp_name = GetXPName( self )
		self:SetPData(xp_name, num )
		self:SyncXP()
	end
	

	function PLY:GiveXP( medal ) -- use this function to give a player XP. can be a medal name or a number as an arguement

		local xp_name = GetXPName( self )
		local rank = self:GetRank()
		local lvlup = false 

		if type( medal ) == "number" then 
			self:SetNWInt(xp_name, self:GetNWInt( xp_name ) + medal )

			self:SyncXP()
			if self:GetRank() != rank then
				OnLevelUp( self )
				lvlup = true 
			end
			hook.Call( "OnPlayerGetXP", GAMEMODE, self, num, medal, lvlup )
			return 
		end 

		local medal_data = MEDAL[ medal ]
		local num
		if medal_data then 
			num = medal_data.value
		else 
			num = 50 
		end  
		self:SetNWInt(xp_name, self:GetNWInt( xp_name ) + num )

		net.Start("XPNotification")
			net.WriteInt( num, 32 )
			if medal then
				net.WriteString( medal )
			end
		net.Send( self )

		self:SyncXP()
		if self:GetRank() != rank then
			OnLevelUp( self )
			lvlup = true 
		end
		hook.Call( "OnPlayerGetXP", GAMEMODE, self, num, medal, lvlup )
	end

	function PLY:WasLastPlayer()
		local p_role = self:GetRole()
		local plys = player.GetAll()
		local ply_count = 0
		for k,v in pairs( plys ) do
			if v:GetRole() == p_role then
				if v:Alive() then
					ply_count = ply_count + 1

					if ply_count >= 2 then
						return false 
					end
				end
			end
		end
		return true 
	end

	function OnLevelUp( ply )
		ply:PrintMessage( HUD_PRINTTALK, "[RANKS] You ranked up!" )
		net.Start( "LevelUp" )
		net.Send( ply )
		hook.Call( "OnLevelUp", GAMEMODE, ply )
	end

	local kill_combos =
	{
		[ 2 ] = "DoubleKill",
		[ 3 ] = "TripleKill",
		[ 4 ] = "OverKill",
		[ 5 ] = "Killtacular",
		[ 6 ] = "Killtrocity",
		[ 7 ] = "Killimanjaro",
		[ 8 ] = "Killtastrophe",
		[ 9 ] = "Killpocalypse",
		[ 10 ]= "Killionaire"
	}


	local XpRewards = -- This table is iterated through when player dies in order to give XP.
	{

		function( ply, atk, dmginfo, tbl )
			if not atk.LastKillTime then
				atk.LastKillTime = CurTime()
				atk.KillCombo = 0
			end
			local combo_time = hook.Call( "PlayerComboTime", GAMEMODE, ply ) or 4
			if CurTime() - atk.LastKillTime <= combo_time then
				atk.LastKillTime = CurTime()
				atk.KillCombo = atk.KillCombo + 1
				local combo = math.min( #kill_combos, atk.KillCombo )
				atk:GiveXP( kill_combos[ combo ] )
			else
				atk.LastKillTime = CurTime()
				atk.KillCombo = 1
			end
		end,	

		function( ply, atk, dmginfo, tbl )
			local lastatk = ply.lastattacker
			if lastatk and lastatk != atk then
				if IsValid( lastatk ) and CurTime() - ply.lastattacktime < 4 then
					lastatk:GiveXP( "Assist" )
				end
			end
		end,

		function( ply, atk, dmginfo, tbl )
			if ply.LastKillTime and CurTime() - ply.LastKillTime < 3 then
				if ply.LastVictim and IsValid( ply.LastVictim ) then 
					if atk:IsAlly( ply.LastVictim ) then
						atk:GiveXP( "Avenger" ) 
					end
				end
			end
		end,

		function( ply, atk, dmginfo, tbl )
			if not atk:Alive() then
				atk:GiveXP( "Grave" )
				tbl.bool = false 
			end
		end,			

		function( ply, atk, dmginfo, tbl )
			if ply:IsInnocent() and ply:WasLastPlayer() then
				for k,v in pairs( util.GetPlayersInRole( ROLE_TRAITOR ) ) do
					v:GiveXP( "Extermination" )
				end
				atk:GiveXP( "LastStrike" )
			end
		end,

		function( ply, atk, dmginfo, tbl )
			if _FirstKill then
				atk:GiveXP( "FirstStrike" )
				_FirstKill = false 
			end
		end,

		function( ply, atk, dmginfo, tbl )
			if ply:IsTraitor() and ply:WasLastPlayer() then
				for k,v in pairs( util.GetPlayersInRole( ROLE_INNOCENT ) ) do
					if v:Alive() and not (v.IsGhost and v:IsGhost()) then 
						v:GiveXP( "Survivor" )
					end 
				end
				atk:GiveXP( "LastStrike" )
			end
		end,

		function( ply, atk, dmginfo, tbl )
			if ply.LastTarget then 
				if ply.LastTarget != ply.LastVictim then
					if CurTime() - ply.LastAttackTime < 1.5 then
						if ply.LastTarget != atk then

							if ply:GetPos():Distance( atk:GetPos() ) > 1000 then
								atk:GiveXP( "Angel" )
							else 
								atk:GiveXP( "Protector" )
							end
							
							if IsValid( ply.LastTarget ) then
								ply.LastTarget:GiveXP( "Distraction" )
							end

						end 
					end
				end
			end 
		end,

		function( ply, atk, dmginfo, tbl )
			if ply.LastTarget and ply.LastTarget == atk then
				if atk:Health()/atk:GetMaxHealth() <= 0.25 then
					atk:GiveXP( "CloseCall" )
				end
			end
		end,


		function( ply, atk, dmginfo, tbl )
			if ply.was_headshot then 
				if ply:GetVelocity():Length() > 500 then
					atk:GiveXP( "Headcase")
					tbl.bool = false 
				else 
					atk:GiveXP( "Headshot" )
					tbl.bool = false 
				end 
			end
		end,

		function( ply, atk, dmginfo, tbl )
			local inf = dmginfo:GetInflictor()
			if IsValid( inf ) and inf:GetClass() == "prop_physics" then
				atk:GiveXP( "Splatter" )
				tbl.bool = false 
			end 
		end,

		function( ply, atk, dmginfo, tbl )
			local wep = atk:GetActiveWeapon()
			local inf = dmginfo:GetInflictor()
			if dmginfo:IsBulletDamage() then
				if IsValid( wep ) then 
					if wep:IsSniper() then 
						if wep:GetIronsights() then
							atk:GiveXP( "SniperKill" )
						else 
							atk:GiveXP( "Snapshot" )
						end
						tbl.bool = false 
					end
				end 
			elseif IsValid( inf ) then 
				if inf:GetClass() == "weapon_ttt_knife" or inf:GetClass() == "ttt_knife_proj" then 
					atk:GiveXP( "KnifeKill" )
					tbl.bool = false 
				elseif inf:IsWeapon() and inf:IsMelee() then 
					atk:GiveXP( "Pummel" )
					tbl.bool = false 
				end 
			end 
		end,

		function( ply, atk, dmginfo, tbl )
			if dmginfo:IsExplosionDamage() then
				atk:GiveXP( "GrenadeKill" )
				tbl.bool = false 
			end
		end,	

		function( ply, atk, dmginfo, tbl )
			local pVec = ply:GetAimVector()
			local aVec = atk:GetAimVector()
			if aVec:DotProduct( pVec ) >= 0.5 then 
				atk:GiveXP( "Beatdown" )
			end 
		end,

		function( ply, atk, dmginfo, tbl )
			local wep = ply:GetActiveWeapon()
			if IsValid( wep ) and wep:GetClass() == "weapon_ttt_knife" then 
				atk:GiveXP( "ShowStopper" )
			end 
		end,

		function( ply, atk, dmginfo, tbl )
			if ply:IsDetective() and ply:WasLastPlayer() and not( ply.IsGhost and ply:IsGhost() ) then
				for k,v in pairs( util.GetPlayersInRole( ROLE_TRAITOR ) ) do
					v:GiveXP( "KillJoy" )
				end
			end
		end

	}

	function CalculateXP( vic, atk, dmginfo, xp_tbl )
		local mdl = {}
		mdl.bool = true 
		for k,rewardCheck in pairs( xp_tbl ) do
			rewardCheck( vic, atk, dmginfo, mdl )
		end
		return mdl.bool
	end

	hook.Add( "DoPlayerDeath", "XPCalculations", function( ply, atk, dmginfo )

		ply.KillStreak = 0

		if atk == ply then return end
		
		if atk:IsPlayer() then
			if not atk:IsAlly( ply ) then

				atk.LastVictim = ply

				local give_kill_medal = CalculateXP(ply, atk, dmginfo, XpRewards )

				if give_kill_medal then
					atk:GiveXP( "Kill" )
				end

			end
		end 

	end)

	hook.Add( "ScalePlayerDamage", "HeadShotWorkAround", function( ply, hitgroup, dmginfo )

		if hitgroup == HITGROUP_HEAD and dmginfo:IsBulletDamage() then
			ply.was_headshot = true 
		else
			ply.was_headshot = false
		end

		local atk = dmginfo:GetAttacker()
		if IsValid( atk ) and atk:IsPlayer() then
			if dmginfo:GetDamage() < ply:Health() then
				ply.lastattacker = atk
				ply.lastattacktime = CurTime() 
			end
			atk.LastTarget = ply
			atk.LastAttackTime = CurTime()
		end

	end)

	timer.Create( "XPSync", 60, 0, function()
		for k,v in pairs( player.GetAll() ) do 
			v:SyncXP()
		end
	end)

	concommand.Add( "xp_reset", function( ply )
		ply:GiveXP( -ply:GetXP(), "XP Reset!" )
	end)


	function PLY:AddRound()
		self:SetNWInt( "Rounds", self:GetRounds() + 1 )
	end

	function PLY:AddWin()
		self:SetNWInt( "Wins", self:GetWins() + 1 )
	end

end


function PLY:GetRounds()
	return self:GetNWInt("Rounds")
end

function PLY:GetWins()
	return self:GetNWInt("Wins")
end

function PLY:GetXP() -- gets a players current XP
	local xp_name = GetXPName( self )
	return tonumber(self:GetNWInt(xp_name ,0))
end


function PLY:GetRank() -- returns a players current the XP required to reach it
	local r_tbl = SelectRankTable( self )
	for k,v in pairs( r_tbl ) do
		if self:GetXP() < v[2] then
			return r_tbl[k-1][1], k-1
		end
	end
return r_tbl[ #r_tbl ][ 1 ], r_tbl[ #r_tbl ][ 2 ]
end

function PLY:GetRankXP() -- gets the XP required to reach the players current rank
	local r_tbl = SelectRankTable( self )
	for k,v in pairs( r_tbl ) do
		if self:GetXP() < v[2] then
			return r_tbl[k-1][2]
		end
	end
return r_tbl[ #r_tbl ][ 2 ]
end

function PLY:GetRankNumber() -- returns the rank number the player has
	local r_tbl = SelectRankTable( self )
	for k,v in pairs( r_tbl ) do
		if self:GetXP() < v[2] then
			return k-1
		end
	end
	return #r_tbl 
end

function PLY:GetXPToNextRank() -- gets the xp required until the next rank
	local r_tbl = SelectRankTable( self )
	for k,v in pairs( r_tbl ) do
		if self:GetXP() < v[2] then
			return v[2] - r_tbl[k-1][2]
		end
	end
return 0
end
 
function PLY:GetNextRankXP() -- gets the xp required for the next rank
	local r_tbl = SelectRankTable( self )
	for k,v in pairs( r_tbl ) do
		if self:GetXP() < v[2] then
			return v[2]
		end
	end
	return r_tbl[ #r_tbl ][ 2 ]
end

function PLY:GetNextRank() -- gets the next ranks name
	local r_tbl = SelectRankTable( self )
	for k,v in pairs( r_tbl ) do
		if self:GetXP() < v[2] then
			return v[1]
		end
	end
	return r_tbl[ #r_tbl ][ 1 ]
end

function PLY:GetRelativeXP()
	local r_tbl = SelectRankTable( self )
	local _,pos = self:GetRank()
	return ( self:GetXP() - r_tbl[pos][2])
end

function PLY:GetXPPercentage() -- retunrs a value between 0 and 1, representing a players progress on their levels. e.g 0.5 means 50% to next rank
	local r_tbl = SelectRankTable( self )
	local _,pos = self:GetRank()
	return ( self:GetXP() - r_tbl[pos][2])/self:GetXPToNextRank()
end

if CLIENT then
	net.Receive( "LevelUp", function( len )
		surface.PlaySound( "garrysmod/content_downloaded.wav" )
		hook.Call( "OnLevelUp", GAMEMODE, LocalPlayer() )
	end)
end
