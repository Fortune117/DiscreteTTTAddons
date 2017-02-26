
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )
include( 'shared.lua' )


function ENT:Initialize()

	self.Entity:PhysicsInit( SOLID_VPHYSICS )
	self.Entity:SetMoveType( MOVETYPE_VPHYSICS )
	self.Entity:SetSolid( SOLID_VPHYSICS )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
	self.Entity:SetMaterial( "models/flesh" )
	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
		
	local phys = self.Entity:GetPhysicsObject()
	
	if IsValid( phys ) then
	
		phys:Wake()
		phys:SetMass( math.random( 20, 40 ) )
		phys:ApplyForceCenter( VectorRand() * 8000 )
		phys:AddAngleVelocity( VectorRand() * 500 )
		phys:SetMaterial( "flesh" )

	end

	self.spawnTime = CurTime() 
	self.liveTime = 15
	self.dieTime = self.spawnTime + self.liveTime 
	
end
 
function ENT:Think() 
	local timePassed = CurTime()-self.spawnTime
	local p = 1 - (timePassed - self.liveTime/2)/(self.liveTime/2)
	self:SetColor( Color( 255, 255, 255, 255*p ) )
	if CurTime() > self.dieTime then 
		self:Remove()
	end 
end

ENT.GoreSplat = { "physics/flesh/flesh_squishy_impact_hard1.wav",
"physics/flesh/flesh_squishy_impact_hard2.wav",
"physics/flesh/flesh_squishy_impact_hard3.wav",
"physics/flesh/flesh_squishy_impact_hard4.wav",
"physics/flesh/flesh_bloody_impact_hard1.wav",
"physics/body/body_medium_break3.wav",
"npc/antlion_grub/squashed.wav",
"ambient/levels/canals/toxic_slime_sizzle1.wav",
"ambient/levels/canals/toxic_slime_gurgle8.wav"}

function ENT:PhysicsCollide( data, phys )

	if data.Speed > 50 and data.DeltaTime > 0.35 then
	
		self.Entity:EmitSound( table.Random( self.GoreSplat ), 75, math.random( 80, 120 ) )
		
		if not self.Splat then
		
			self.Splat = true
			
			util.Decal( "Blood", data.HitPos + data.HitNormal, data.HitPos - data.HitNormal )
		
		end
		
	end
	
end

function ENT:OnTakeDamage( dmginfo )

	self.Entity:TakePhysicsDamage( dmginfo )

end