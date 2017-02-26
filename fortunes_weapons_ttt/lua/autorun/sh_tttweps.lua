
doorClamp = {}
doorClamp.clampHealth = 4000
doorClamp.ValidEnts =
{
	"prop_door_rotating"
}
function traceHitValidDoor( tr )
	if tr.HitNonWorld then
		local e = tr.Entity
		if IsValid( e ) then 
			if table.HasValue( doorClamp.ValidEnts, e:GetClass() ) then
				if e:GetNWBool( "clamped", false ) then 
					return true 
				end 
			end
		end 
	end
end 

-- Ritual
game.AddDecal( "ritual_pentagram", { "pentagram/pentagramdrips", "pentagram/pentagramdripless" })
ritual = {}
ritual.time = 20 -- How long the ritual takes.
ritual.hp = 0.7 -- What percentage of HP is restored.
ritual.weapons = {} -- What weapons the player gets.
ritual.credits = 1 -- How many credits the player gets.
ritual.model = "models/pentagram/pentagram_giant.mdl" 
ritual.skulls = 5 --How many skulls appear during the ritual :^)

function addRitualThinkFunction( ply, body )
	local dti = CORPSE.dti
	local delay = CurTime() + ritual.time 
	local hName = "RitualThink"..ply:UniqueID()
	local targ = body:GetDTEntity(dti.ENT_PLAYER)
	local p = body:GetPos()
	hook.Add( "Think", hName, function()
		if CurTime() > delay then 
			if IsValid( targ ) then
				if not targ:Alive() or (targ.IsGhost and targ:IsGhost()) then 
					local e = ents.FindInBox(p + Vector( -16, -16, 0 ), p + Vector( 16, 16, 64 ))
					for k,v in pairs( e ) do 
						if v:IsPlayer() and v:Alive() and not (v.IsGhost and v:IsGhost()) then 
							v:Kill()
						end 
					end 
					targ:SpawnForRound( true )
	                targ:SetCredits( ritual.credits )
	                targ:SetPos( p )
					util.Decal( "ritual_pentagram", p, p - Vector(0,0,8000) )
				end 
			end 
			hook.Remove( "Think", hName )
		end 
	end )
end 

function isValidCorpse( e )
 	local ply = rag:GetDTEntity(dti.ENT_PLAYER)
 	if IsValid( ply ) and not ply:Alive() then
 		return true 
 	end
end 

local meta = FindMetaTable( "Entity" )	
function meta:Dissolve()
	if self:IsPlayer() then return end

	local dissolver = ents.Create( "env_entity_dissolver" )
	dissolver:SetPos( self:LocalToWorld(self:OBBCenter()) )
	dissolver:SetKeyValue( "dissolvetype", 0 )
	dissolver:Spawn()
	dissolver:Activate()
	
	local name = "Dissolving_"..math.random()
	self:SetName( name )
	dissolver:Fire( "Dissolve", name, 0 )
	dissolver:Fire( "Kill", self, 0.10 )
	
end

--Upgrades
upgrades = {}
upgrades.functions = 
{
	["damage"] = function( wep, mod, level )
		local dmg = wep.originalDamage
		return dmg*(mod*level)
	end,
	["firerate"] = function( wep, mod, level )
		local rate = 1/wep.originalDelay
		return 1/(rate*(mod*level))
	end,
	["recoil"] = function( wep, mod, level )
		local rec = wep.originalRecoil
		return rec*(1-(mod*level))
	end,
	["acc"] = function( wep, mod, level )
		local acc = wep.originalAcc 
		return acc*(1-(mod*level))
	end 
}