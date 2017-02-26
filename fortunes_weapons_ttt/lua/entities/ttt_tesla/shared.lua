
if SERVER then 
   AddCSLuaFile("shared.lua")
end

if CLIENT then
   ENT.PrintName = "Trip Mine"
end

ENT.Type = "anim"
ENT.Model = Model( "models/props_combine/combine_light001a.mdl" )

ENT.onSound = Sound( "npc/roller/remote_yes.wav" )
ENT.offSound = Sound( "npc/turret_floor/retract.wav" )
ENT.pingSound = Sound( "npc/turret_floor/ping.wav" )
ENT.loopSound = Sound( "ambient/energy/electric_loop.wav" )
ENT.zapSoundTable =
{
	Sound( "npc/roller/mine/rmine_explode_shock1.wav" ),
	Sound( "weapons/airboat/airboat_gun_energy1.wav" ),
	Sound( "weapons/airboat/airboat_gun_energy2.wav" )
}



ENT.maxHealth = 500 
ENT.zapDelayDefault = 0.2
ENT.pingDelayDefault = 1 
ENT.zapForce = 1000 
function ENT:Initialize()

	if SERVER then 

		self:SetHealth( self.maxHealth )
		self:SetMaxHealth( self.maxHealth )

		self:setOn( false )
		self:setZapDelay( self.zapDelayDefault )
		self:setNextZap( self:getZapDelay() )

		self:setPingDelay( self.pingDelayDefault )
		self:setNextPing( self:getPingDelay() )

		self:SetModel( self.Model )

		self:SetUseType( SIMPLE_USE )

		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetCollisionGroup( COLLISION_GROUP_PUSHAWAY )
		self:SetMoveType( MOVETYPE_NONE )
	else 
		self.PixVis = util.GetPixelVisibleHandle()
	end 

end 	

function ENT:setZapDelay( n )
	self.zapDelay = n 
end 

function ENT:setNextZap( n )
	self.nextZap = CurTime() + n
end 

function ENT:getNextZap()
	return self.nextZap
end 

function ENT:getZapDelay()
	return self.zapDelay 
end 

function ENT:setNextPing( n )
	self.nextPing = CurTime() + n 
end 

function ENT:getNextPing()
	return self.nextPing 
end 

function ENT:canPing()
	return CurTime() > self:getNextPing()
end 

function ENT:setPingDelay( n )
	self.pingDelay = n 
end 	

function ENT:getPingDelay()
	return self.pingDelay 
end 

function ENT:ping()
	self:EmitSound( self.pingSound )
end 

function ENT:pingThink()
	if self:canPing() then 
		self:ping()
		self:setNextPing( self:getPingDelay() )
	end 
end 

if SERVER then 
	function ENT:Think()
		if self:isOn() then 
			self:pingThink()
		end 
	end 
end 

function ENT:getZapForce()
	return self.zapForce
end 

function ENT:getZapOrigin()
	return self:GetPos() + self:GetUp()*35 + self:GetForward()*-10
end 

function ENT:canZap( targ, coil, dmginfo, vic )

	local atk = dmginfo:GetAttacker()
	local inf = dmginfo:GetInflictor()
	if inf then 
		if inf:GetClass() == "ttt_tesla" then 
			return false 
		end 
	end 

	if atk:IsDetective() then 
		return false 
	end 	

	if targ == self:getDamageOwner() or atk == self:getDamageOwner() then 
		return false 
	end 

	if targ:HasEquipmentItem( EQUIP_TESLASHIELD ) then 
		return false 
	end 

	if targ.IsGhost and targ:IsGhost() then
		return false 
	end
	
	if dmginfo:GetDamage() <= 0 then return false end 

	if (CurTime() < self:getNextZap()) then return false end
	if not self:isOn() then return false end   

	local zapOrigin = self:getZapOrigin()
	local boneIndex = targ:LookupBone( "ValveBiped.Bip01_Spine" )
	local bonePos = targ:GetBonePosition( boneIndex )

	local dir = ( bonePos - zapOrigin ):GetNormalized()*800
	local trace = util.QuickTrace( zapOrigin, dir, { self, vic } )

	if trace.Hit and trace.Entity == targ then 
		return trace 
	end 

	return false 

end

function ENT:zap( targ, dmginfo, trace )

	self:setNextPing( self:getPingDelay()*2 )

	local dmg = dmginfo:GetDamage()

	local ef = EffectData()
	ef:SetOrigin( trace.HitPos )
	ef:SetStart( self:getZapOrigin() )
	ef:SetEntity( self )
	ef:SetAttachment( 1 )
	ef:SetScale( dmg )
	ef:SetMagnitude( targ:Health() )
	util.Effect( "ef_teslazap", ef  )

	local zapDmg = DamageInfo()
	zapDmg:SetDamage( dmg*2 )
	zapDmg:SetAttacker( self )
	zapDmg:SetInflictor( self )
	zapDmg:SetDamageForce( trace.HitNormal*(300*dmg)*-1 )
	zapDmg:SetDamagePosition( trace.HitPos )
	zapDmg:SetDamageType( DMG_DISSOLVE )
	targ:TakeDamageInfo( zapDmg )

	self:EmitSound( table.Random( self.zapSoundTable ), 100 )

	self:setNextZap( self:getZapDelay() )

end 

function ENT:setDamageOwner( ply )
	self.damageOwner = ply 
end 

function ENT:getDamageOwner()
	if IsValid( self.damageOwner ) then 
		return self.damageOwner 
	else 
		return self 
	end 
end

function ENT:playerPickup( ply )
   for k,v in pairs( ply:GetWeapons() ) do 
      if v.Kind and v.Kind == WEAPON_EQUIP2 then 
         return 
      end 
   end 
   ply:Give( "weapon_ttt_tesla" )
   ply.teslaHealth = self:Health()
   self:Remove()
end 

if SERVER then 
	function ENT:Use( ply )
		if ply == self:getDamageOwner() then 
			if ply:KeyDown( IN_WALK ) then 
            self:playerPickup( ply )
			else 
				self:setOn( not self:isOn() )
			end 
		end 
	end 
end 

function ENT:setOn( b )
	self:SetNWBool( "isActive", b )
	self:onStateChange( b )
end 

function ENT:onStateChange( b )
	if b and not self:isOn() then 
		self:EmitSound( self.onSound )
		self:setNextPing( self:getPingDelay() )
	elseif not b and self:isOn() then 
		self:EmitSound( self.offSound )
	end 
end 

function ENT:isOn()
	return self:GetNWBool( "isActive", false )
end 

function ENT:getLightPos()
	return self:GetPos() + self:GetUp()*35 + self:GetForward()*-10
end 

if CLIENT then 
	local matLight 	= Material( "sprites/light_ignorez" )
	local cRed = Color( 255, 25, 25, 35 )
	local cGreen = Color( 25, 255, 25, 35 )
	function ENT:Draw()
		self:DrawModel()

		local color = cRed 
		if self:isOn() then 
			color = cGreen 
		end 

		local lPos =  self:getLightPos()
		local Visibile	= util.PixelVisible( lPos, 4, self.PixVis )	
	
		if ( !Visibile || Visibile < 0.1 ) then return end
		
		local Alpha = 255 * Visibile
		color = ColorAlpha( color, Alpha )

		render.SetMaterial( matLight )
		render.DrawSprite( lPos, 8, 8, color, 1 )
		render.DrawSprite( lPos, 8, 8, color, 1 )
		render.DrawSprite( lPos, 8, 8, color, 1 )
		render.DrawSprite( lPos, 64, 64, ColorAlpha( color, 64), 1 )

	end 
end 

function ENT:gib()

	local ef = EffectData()
	ef:SetOrigin( self:GetPos() )
	util.Effect( "Explosion", ef )

end 

function ENT:OnTakeDamage( dmginfo )
	local dmg = dmginfo:GetDamage()
	self:SetHealth( self:Health() - dmg )
	if self:Health() < 0 then 
		self:gib()
		self:Remove()
	end 
end 

