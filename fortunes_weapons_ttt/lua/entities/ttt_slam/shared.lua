
if SERVER then 
AddCSLuaFile("shared.lua")
 end

if CLIENT then
   ENT.PrintName = "Trip Mine"
end

ENT.Type = "anim"
ENT.Model = "models/weapons/w_slam.mdl"

ENT.CanUseKey = false

ENT.On = false

function ENT:Initialize()
	if SERVER then
		self.Entity:SetModel( self.Model )
		self.Entity:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		self.Entity:SetMoveType( MOVETYPE_NONE )
		self.Entity:SetSolid(SOLID_VPHYSICS)
		self.Entity:SetTrigger( true )
		self:DrawShadow(false)
	end
	
	self:SetHealth(15)
	
	timer.Simple(2,function()
		if IsValid(self) then
			self.On = true
			if IsFirstTimePredicted() then
				sound.Play( "buttons/blip2.wav", self:GetPos() )
			end
		end
	end)
	
		self:SetBodygroup( 0, 1 )
end


function ENT:Detonate( mult )

	if mult == nil then mult = 1 end
	
	if IsValid(self) then
		if SERVER then
			if self.Detonated then
				return
			end
			
			self.Detonated = true
			util.BlastDamage( self.Owner, self.Owner, self:GetPos(), 400*mult, 220*mult)
			
			local effect = EffectData()
			effect:SetStart(self:GetPos())
			effect:SetOrigin(self:GetPos())
			effect:SetScale(400*mult)
			effect:SetRadius(400*mult)
			effect:SetMagnitude(220*mult)
			effect:SetNormal( self:GetUp() )
			util.Effect("Explosion", effect, true, true)
				
			self:Remove()
		end
	end
end

 
function ClampWorldVector(vec)
	vec.x = math.Clamp( vec.x , -16380, 16380 )
	vec.y = math.Clamp( vec.y , -16380, 16380 )
	vec.z = math.Clamp( vec.z , -16380, 16380 )
	return vec
end

function ENT:FireTracer()
	local spos = self:GetPos() + self:GetRight()*-1.4 + self:GetForward()*-2.1
	local trd = {}
	trd.start = spos
	trd.endpos = spos + self:GetUp()*9000
	trd.filter = self
	trd.mask = MASK_SOLID
			
	local tr = util.TraceLine(trd)
	
	local wmult = 4
	
	local E = ents.FindInBox( ClampWorldVector( (self:GetPos() + self:GetRight()*2.4 + self:GetForward()*wmult)) ,ClampWorldVector( ( tr.HitPos + self:GetRight()*-2.4 + self:GetForward()*-wmult) ) )

	return tr, E
end

function ENT:ShouldDetonate( tr, E )
	for k,v in pairs(E) do
	
		if not v:IsPlayer() then continue end
		if v == self.Owner then return end
		if not v:Alive() or v:IsSpec() then return end

		if v:IsTraitor() and not self.Owner:IsTraitor() then
			return true
		elseif not v:IsTraitor() then
			return true
		end
		
	end
return false
end

function ENT:Think()

	if not self.On then return end
	
	if IsValid(self) then
	
		local tr,E = self:FireTracer()
		if self:ShouldDetonate( tr, E ) then
			self:Detonate()
		end
		
	end
	
end

function ENT:OnTakeDamage( dmginfo )
   self:TakePhysicsDamage(dmginfo)
   
	if IsValid(self) then
		if dmginfo:GetDamageType() == DMG_BLAST or dmginfo:GetDamageType() == DMG_BURN then
			self:Detonate(0.5)
		else
		
			self:SetHealth(self:Health() - dmginfo:GetDamage() )
			
			if self:Health() <= 0 then
				self:Detonate(0.5)
			end
		end
	end
end

if CLIENT then
	function ENT:Draw()
		self:DrawModel()
	end
end