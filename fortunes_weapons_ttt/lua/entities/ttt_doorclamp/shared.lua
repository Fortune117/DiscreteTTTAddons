
if SERVER then 
AddCSLuaFile("shared.lua")
 end

if CLIENT then
   ENT.PrintName = "Trip Mine"
end

ENT.Type 			= "anim"
ENT.Base 			= "base_anim"

ENT.clampHealth = doorClamp.clampHealth

function ENT:Initialize()
		
	self.Entity:PhysicsInit( SOLID_NONE )
	self.Entity:SetMoveType( MOVETYPE_NONE )
	self.Entity:SetSolid( SOLID_NONE )
	self.Entity:SetCollisionGroup( COLLISION_GROUP_NONE )
	self.Entity:SetModel( "models/props_combine/combinebutton.mdl" )
		
	self.SpawnTime = CurTime() + 5
	self.Time = CurTime() + 5

	self:SetHealth( 300 )
end

function ENT:Think()
	local d = self:getDoor()
	if IsValid( d ) then 
		d:Fire("lock", "", 0)
	end 
end

function ENT:getDoor()
	return self.door
end

function ENT:Attach( door, norm )
	local pos = door:GetPos() + door:GetRight()*-37.5 - Vector( 0, 0, 12 )
	self:SetPos( pos + norm*6 )
	self:SetAngles( norm:Angle())
	self.door = door
	self.doornorm = norm

	door:SetNWBool( "clamped", true )
	door.clampHealth = self.clampHealth
	door.clamp = self 
	
	self:getDoor():Fire("lock", "", 0)

	self:SetParent( door )
	
	self:SetNWVector( "lightpos", self:GetPos() + self:GetRight()*2 + self:GetForward()*5 + Vector( 0, 0, 2 ) )
end


local detachSound = "npc/roller/mine/rmine_explode_shock1.wav"
function ENT:detatch()

	local p = ents.Create( "prop_physics" )
	p:SetModel( self:GetModel() )
	p:SetPos( self:GetPos() )
	p:SetAngles( self:GetAngles() )
	p:SetCollisionGroup( COLLISION_GROUP_WORLD )
	p:Spawn()

	p:PhysWake()
	p:SetVelocity( self.doornorm*50 )

	self:EmitSound( detachSound )

	local d = self:getDoor()
	d:Fire("unlock", "", 0)
	d.clamp = nil 
	d:SetNWBool( "clamped", false )
	self:Remove()
end 

if CLIENT then
	local dot = Material("lasersights/laserglow1")
	function ENT:Draw()
		
		self:DrawModel()
		local rand = math.Rand(125,150)
		render.SetMaterial(dot)
		render.DrawSprite( self:GetNWVector( "lightpos" ) ,rand, rand, Color(255,0,0,255) )
		
	end
end