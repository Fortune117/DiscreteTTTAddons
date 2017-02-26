
if SERVER then 
AddCSLuaFile("shared.lua")
 end

if CLIENT then
   ENT.PrintName = "Trip Mine"
end

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"


function ENT:Initialize()
		
	self.Entity:PhysicsInit( SOLID_NONE )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE)
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE )
	self.Entity:SetModel( "models/weapons/w_slam.mdl" )
		
	self.SpawnTime = CurTime() + 5
	self.Time = CurTime() + 5
end

function ENT:Beep()
	self:EmitSound( "buttons/blip1.wav" )
	self.LightTime = CurTime() + self.LightDelay
	self.Light = true
end

ENT.ThinkDelay = 1
ENT.BeepDelay = 1
ENT.BeepTime = 1
ENT.LightDelay = 0.1
ENT.LightTime = 1
ENT.Light = false
function ENT:Think()

	if CLIENT then
		if CurTime() > self.LightTime then
			self.Light = false
		end
		if CurTime() > self.BeepTime then
			self:Beep()
			self.BeepTime = CurTime() + self.BeepDelay
		end
	end
	
	if CurTime() > self.ThinkDelay then
		self.Time = self.SpawnTime - CurTime()
		self.BeepDelay = self.BeepDelay - 0.15
		if self.Time <= 0 then
			self:Detonate()
		end
		self.ThinkDelay = CurTime() + 1
	end
	
end

function ENT:GetDoor()
	return self.door
end

function ENT:Detonate()
	if SERVER then
		local _door = self:GetDoor()
		local door = ents.Create( "prop_physics" )
		door:SetPos( _door:GetPos() )
		door:SetModel( _door:GetModel() )
		door:SetAngles( _door:GetAngles() )
		door:Spawn()
		door:Activate()
		
		local phys = door:GetPhysicsObject()
		if IsValid( phys ) then
			phys:ApplyForceCenter( self.doornorm*-80000 )
		end
		self:Remove()
		_door:Remove()
		--_door.IsCharged = false
		
		local effect = EffectData()
		effect:SetStart(self:GetPos())
		effect:SetOrigin(self:GetPos())
		effect:SetScale(400)
		effect:SetRadius(400)
		effect:SetMagnitude(220)
		effect:SetNormal( self.doornorm*-1 )
		util.Effect("Explosion", effect, true, true)
			
	end
end

function ENT:Attach( door, norm )
	local pos = door:GetPos() + door:GetRight()*-23
	self:SetPos( pos + norm*5 )
	self:SetAngles( norm:Angle() + Angle( 90, 0, 0 ) )
	self.door = door
	self.doornorm = norm
	
	self:GetDoor():Fire("lock", "", 0)
	
	self:SetNWVector( "lightpos", self:GetPos() + self:GetRight()*-1.4 + self:GetForward()*-2.25 )
end

if CLIENT then
	local dot = Material("lasersights/laserglow1")
	function ENT:Draw()
	
		if self.Light == true then
			local rand = math.Rand(125,150)
			render.SetMaterial(dot)
			render.DrawSprite( self:GetNWVector( "lightpos" ) ,rand,rand, Color(255,0,0,255) )
		end
		self:DrawModel()
		
	end
end