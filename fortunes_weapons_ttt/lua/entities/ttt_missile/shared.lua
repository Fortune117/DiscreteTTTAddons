
if SERVER then 
AddCSLuaFile("shared.lua")
 end

if CLIENT then
   ENT.PrintName = "missile"
end

ENT.Type = "anim"
ENT.Model = Model( "models/weapons/w_missile.mdl" )

function ENT:Initialize()
	util.PrecacheModel( self.Model )
	if SERVER then
		self:SetModel( self.Model )
		self:SetCollisionGroup( COLLISION_GROUP_PROJECTILE )
		self:SetMoveType( MOVETYPE_FLY )
		self:PhysicsInitSphere( 15 ) 
		self:PhysWake()

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then 
			phys:EnableGravity( false )
		end 
		self:StartScanSound()
	end

	if CLIENT then 
		self.drawModel = ents.CreateClientProp( self.Model )
	end 
end

local scanloop = "weapons/rpg/rocket1.wav" 
function ENT:StartScanSound()
   if not self.ScanSound then
      self.ScanSound = CreateSound(self, scanloop)
   end

   if not self.ScanSound:IsPlaying() then
      self.ScanSound:PlayEx(0.5, 100)
   end
end

function ENT:StopScanSound(force)
   if self.ScanSound and self.ScanSound:IsPlaying() then
      self.ScanSound:FadeOut(0.5)
   end

   if self.ScanSound and force then
      self.ScanSound:Stop()
   end
end


if SERVER then 
	function ENT:Think()
		local ply = self:GetOwner()
		local eyeAng = ply:EyeAngles()

		local phys = self:GetPhysicsObject()
		if IsValid( phys ) then 
			phys:SetVelocityInstantaneous( eyeAng:Forward()*1100 )
		end 
		self:NextThink( CurTime() )
		return true 
	end 
end 

function ENT:PhysicsCollide( data, phys )
	self:explode()
end

function ENT:explode()

	local ef = EffectData()
	ef:SetOrigin( self:GetPos() )
	util.Effect( "Explosion", ef )

   self.dead = true 

	util.BlastDamage( self, self:GetOwner(), self:GetPos(), 175, 150 )

	self:StopScanSound( true )
	self:Remove()

end 

function ENT:OnTakeDamage()
	if self.dead then return end 
	self:explode()
end 

function ENT:OnRemove()
	if IsValid( self.drawModel ) then 
		self.drawModel:Remove()
	end 
end 

if CLIENT then
	function ENT:Draw()
		local ply = self:GetOwner()
		local eyeAng = ply:EyeAngles()
		local pos = self:GetPos()

		if ply ~= LocalPlayer() then 
			self.drawModel:SetPos( pos )
			self.drawModel:SetAngles( eyeAng )
		end 

		local ef = EffectData()
		ef:SetOrigin( pos )
		ef:SetScale( 0.1 )
		util.Effect( "MuzzleEffect", ef )
	end 
end