
CHALLENGES = {}
CHALLENGES.List = {}

function CHALLENGES:GetList()
	return self.List
end 

function CHALLENGES:GetChallenge( name )
	return self.List[ name ]
end 

function CHALLENGES.Add( data, hooks, funcs )
	CHALLENGES.List[ data.id ] = data
	if SERVER then
		if istable( hooks ) then 
			for i = 1,#hooks do 
				hook.Add( hooks[ i ], data.name, funcs[ i ] ) 
				print( "[ACH] Adding hook for "..data.name..".")
			end 
		else 
			hook.Add( hooks, data.name, funcs )
			print( "[ACH] Adding hook for "..data.name..".")
		end 
	end
end 

function CHALLENGES.GetData( id )
	return CHALLENGES.List[ id ]
end 

function CHALLENGES:GetPlayerChallengeInfo( ply, id ) -- this is an internal function to the info about a players particular challenge data
	local data = self.GetData( id )
	local p = ply:GetPData( data.name, 0 )
	local g = data.goal 
	return p, g, p/g 
end


local PLY = FindMetaTable( "Player" )
function PLY:CompletedChallenge( id ) -- this can be used to check if the player has completed a challenge. 
	local __,_,p = CHALLENGES:GetPlayerChallengeInfo( self, id )
	if p >= 1 then
		return true 
	end
end 


local cData = 
{
	name = "Baby Steps",
	desc = "Kill your first innocent.",
	goal = 1,
	value = 5,
	id = 1
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() then
		if atk:IsTraitor() then 
			if ply:IsInno() then
				atk:GiveCPoint( cData.id, 1 )
			end
		end
	end
end)

local cData = 
{
	name = "Wolf Among Sheep",
	desc = "Kill 10 innocents.",
	goal = 10,
	value = 10,
	id = 2
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsInno() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Slaughterhouse",
	desc = "Kill 100 innocents.",
	goal = 100,
	value = 15,
	id = 3
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsInno() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Bringer of Death",
	desc = "Kill 1000 innocents.",
	goal = 1000,
	value = 25,
	id = 4
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsInno() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Bipedal Holocaust",
	desc = "Kill 10000 innocents.",
	goal = 10000,
	value = 75,
	id = 5
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsInno() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Detect This!",
	desc = "Kill your first detective.",
	goal = 1,
	value = 5,
	id = 6
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsDetective() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Sleuth Slayer",
	desc = "Kill 10 detectives.",
	goal = 10,
	value = 10,
	id = 7
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsDetective() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Private Eye-remover",
	desc = "Kill 100 detectives.",
	goal = 100,
	value = 20,
	id = 8
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsDetective() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Master of Disguise",
	desc = "Kill 1000 detectives.",
	goal = 1000,
	value = 50,
	id = 9
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and atk:IsTraitor() then
		if ply:IsDetective() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Counter-Counter-Terrorist",
	desc = "Kill your first traitor.",
	goal = 1,
	value = 5,
	id = 10
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and not ply:IsAlly( atk ) then
		if ply:IsTraitor() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Trigger Happy",
	desc = "Kill 10 traitors.",
	goal = 10,
	value = 10,
	id = 11
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and not ply:IsAlly( atk ) then
		if ply:IsTraitor() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Innocent Avenger",
	desc = "Kill 100 traitors.",
	goal = 100,
	value = 20,
	id = 12
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and not ply:IsAlly( atk ) then
		if ply:IsTraitor() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Virtual Vigilante",
	desc = "Kill 1000 traitors.",
	goal = 1000,
	value = 50,
	id = 13
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and atk:IsPlayer() and not ply:IsAlly( atk ) then
		if ply:IsTraitor() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Lucky Shot",
	desc = "Get your first headshot.",
	goal = 1,
	value = 5,
	id = 14
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if ply:WasHeadshot( dmginfo ) then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Bullseye",
	desc = "Get 10 headshots.",
	goal = 10,
	value = 10,
	id = 15
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if ply:WasHeadshot( dmginfo ) then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Marksman",
	desc = "Get 100 headshots.",
	goal = 100,
	value = 20,
	id = 16
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if ply:WasHeadshot( dmginfo ) then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Eagle Eye",
	desc = "Get 1000 headshots.",
	goal = 1000,
	value = 50,
	id = 17
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if ply:WasHeadshot( dmginfo ) then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "The Human Aimbot",
	desc = "Get 5000 headshots.",
	goal = 5000,
	value = 75,
	id = 18
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if ply:WasHeadshot( dmginfo ) then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Lightning Assault",
	desc = "Get a kill while moving faster than 1000 units. With a gun. I don't know how, you figure it out.",
	goal = 1,
	value = 15,
	id = 19
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo ) 
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if atk:GetVelocity():Length() > 1000 and dmginfo:IsBulletDamage() then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Beyond the Grave",
	desc = "Get a kill from beyond the grave.",
	goal = 1,
	value = 10,
	id = 20
}
CHALLENGES.Add( cData, "OnPlayerGetXP", function( ply, num, medal, didlevel ) 
	if medal and medal == "Grave" then
		ply:GiveCPoint( cData.id, 1 )
	end
end)

local cData = 
{
	name = "Double Kill Master",
	desc = "Get 100 double kills.",
	goal = 100,
	value = 10,
	id = 21
}
CHALLENGES.Add( cData, "OnPlayerGetXP", function( ply, num, medal, didlevel ) 
	if medal and medal == "DoubleKill" then
		ply:GiveCPoint( cData.id, 1 )
	end
end)

local cData = 
{
	name = "Triple Kill Master",
	desc = "Get 50 triple kills.",
	goal = 50,
	value = 10,
	id = 22
}
CHALLENGES.Add( cData, "OnPlayerGetXP", function( ply, num, medal, didlevel ) 
	if medal and medal == "TripleKill" then
		ply:GiveCPoint( cData.id, 1 )
	end
end)

local cData = 
{
	name = "Overkill Master",
	desc = "Get 25 over kills.",
	goal = 25,
	value = 15,
	id = 23
}
CHALLENGES.Add( cData, "OnPlayerGetXP", function( ply, num, medal, didlevel ) 
	if medal and medal == "OverKill" then
		ply:GiveCPoint( cData.id, 1 )
	end
end)

local cData = 
{
	name = "Killtacular Master",
	desc = "Get 5 killtaculars.",
	goal = 5,
	value = 20,
	id = 24
}
CHALLENGES.Add( cData, "OnPlayerGetXP", function( ply, num, medal, didlevel ) 
	if medal and medal == "Killtacular" then
		ply:GiveCPoint( cData.id, 1 )
	end
end)

local cData = 
{
	name = "Show Stopper!",
	desc = "Kill a traitor who has their knife out.",
	goal = 1,
	value = 5,
	id = 25
}
CHALLENGES.Add( cData, "OnPlayerGetXP", function( ply, num, medal, didlevel ) 
	if medal and medal == "ShowStopper" then
		ply:GiveCPoint( cData.id, 1 )
	end
end)

local cData = 
{
	name = "Blast Warning",
	desc = "Kill 3 players with one explosion.",
	goal = 1,
	value = 15,
	id = 26
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo )
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if dmginfo:IsExplosionDamage() then
			if not atk.lastexplosivekill then
				atk.lastexplosivekill = CurTime()
			end
			if atk.lastexplosivekill < CurTime()+0.5 then
				atk.explosivekillcombo = ( atk.explosivekillcombo and atk.explosivekillcombo+1 or 1 )
			else 
				atk.explosivekillcombo = 0
			end

			if atk.explosivekillcombo >= 3 then
				atk:GiveCPoint( cData.id, 1 )
			end
		end
	end
end)

local cData = 
{
	name = "Long Shot",
	desc = "Kill a player from at least 2500 units away.",
	goal = 1,
	value = 15,
	id = 27
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo )
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if dmginfo:IsBulletDamage() then
			if ply:GetPos():Distance( atk:GetPos() ) > 2500 then
				atk:GiveCPoint( cData.id, 1 )
			end
		end
	end
end)

local cData = 
{
	name = "Hail Mary",
	desc = "Get a kill with a thrown knife from over 15 meters.",
	goal = 1,
	value = 10,
	id = 28
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo )
	local wep = dmginfo:GetInflictor()
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if IsValid( wep ) and wep:GetClass() == "ttt_knife_proj" then
			if ply:GetPos():Distance( atk:GetPos() ) > 750 then
				atk:GiveCPoint( cData.id, 1 )
			end
		end
	end
end)

local cData = 
{
	name = "Counter Espionage",
	desc = "Kill a traitor with a knife.",
	goal = 1,
	value = 10,
	id = 29
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo )
	local wep = dmginfo:GetInflictor()
	if IsValid( atk ) and not ply:IsAlly( atk ) and ply:IsTraitor() then
		if IsValid( wep ) and wep:GetClass() == "weapon_ttt_knife" then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

local cData = 
{
	name = "Police Brutality",
	desc = "Kill a traitor with a crowbar as a detective.",
	goal = 1,
	value = 10,
	id = 30,
	secret = true 
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo )
	local wep = dmginfo:GetInflictor()

	if IsValid( atk ) then 

		if not atk:IsPlayer() then 
			local pAtk = atk:GetPhysicsAttacker()
			if IsValid( pAtk ) and pAtk:IsPlayer() then 
				atk = pAtk 
			end 
		end 

		if atk:IsPlayer() and not atk:IsDetective( ply ) and ply:IsTraitor() then
			if IsValid( wep ) and wep:GetClass() == "weapon_zm_improvised" then
				atk:GiveCPoint( cData.id, 1 )
			end
		end 

	end
end)

local cData = 
{
	name = "Mario Style",
	desc = "Kill an enemy with a goomba stomp.",
	goal = 1,
	value = 10,
	id = 31,
	secret = true 
}
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo )
	if IsValid( atk ) and not ply:IsAlly( atk ) then
		if dmginfo:GetDamageType() == DMG_PHYSGUN + DMG_CRUSH then
			atk:GiveCPoint( cData.id, 1 )
		end
	end
end)

function minuteThink()
	for k,v in pairs( player.GetAll() ) do 
		if not v.minuteDelay then 
			v.minuteDelay = CurTime() + 60
		end
		if CurTime() > v.minuteDelay then 
			hook.Call( "PlayerMinutePassed", GAMEMODE, v )
			v.minuteDelay = CurTime() + 60 
		end 
	end 
end 
hook.Add( "Think", "MinuteThink", minuteThink )

local cData = 
{
	name = "Recruit",
	desc = "Spend 10 minutes on the server.",
	goal = 5,
	value = 1,
	id = 32,
}
CHALLENGES.Add( cData, "PlayerMinutePassed", function( ply )
	ply:GiveCPoint( cData.id, 1 )
end)

local cData = 
{
	name = "New Guy",
	desc = "Spend 3 hours on the server.",
	goal = 180,
	value = 10,
	id = 33,
}
CHALLENGES.Add( cData, "PlayerMinutePassed", function( ply )
	ply:GiveCPoint( cData.id, 1 )
end)

local cData = 
{
	name = "Regular",
	desc = "Spend 24 hours on the server.",
	goal = 1440,
	value = 15,
	id = 34,
}
CHALLENGES.Add( cData, "PlayerMinutePassed", function( ply )
	ply:GiveCPoint( cData.id, 1 )
end)

local cData = 
{
	name = "Veteran",
	desc = "Spend 3 days on the server.",
	goal = 4320,
	value = 25,
	id = 35,
}
CHALLENGES.Add( cData, "PlayerMinutePassed", function( ply )
	ply:GiveCPoint( cData.id, 1 )
end)

local cData = 
{
	name = "Addict",
	desc = "Spend 1 week on the server.",
	goal = 10080,
	value = 50,
	id = 36,
}
CHALLENGES.Add( cData, "PlayerMinutePassed", function( ply )
	ply:GiveCPoint( cData.id, 1 )
end)

local cData = 
{
	name = "No Life, No Worries",
	desc = "Spend one month on the server.",
	goal = 40320,
	value = 100,
	id = 37,
}
CHALLENGES.Add( cData, "PlayerMinutePassed", function( ply )
	ply:GiveCPoint( cData.id, 1 )
end)



concommand.Add( "ResetAchievements", function( ply )
	local clist = CHALLENGES:GetList()
	for i = 1,#clist do
		local tbl = clist[ i ]
		ply:GiveCPoint( i, "reset" )
	end
end)