
resource.AddWorkshop( "181231045" ) -- Pentagram Models

--Stimpack
local PLY = FindMetaTable( "Player" )

function PLY:IsInjured()
	return self:Health() < self:GetMaxHealth()
end 

local clamp = math.Clamp 
function PLY:Heal( heal )
	self:SetHealth( math.min( self:Health() + heal, self:GetMaxHealth() ) )
end 

--Door clamp
function damageDoorClamps( ent, dmginfo )
	if ent:GetNWBool( "clamped", false ) then 
		ent.clampHealth = ent.clampHealth - dmginfo:GetDamage()
		if not ent.damageSound and ent.clampHealth <= doorClamp.clampHealth*0.2 then
			ent:EmitSound( "npc/roller/mine/rmine_shockvehicle1.wav" )
			ent.damageSound = true 
		end
		if ent.clampHealth <= 0 then
			ent.clamp:detatch()
		end
	end
end 
hook.Add( "EntityTakeDamage", "RemoveDoorClamps", damageDoorClamps )