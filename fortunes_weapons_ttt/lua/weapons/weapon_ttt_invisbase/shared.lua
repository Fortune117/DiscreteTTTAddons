if SERVER then
	AddCSLuaFile( "shared.lua" )
   
	resource.AddFile("sound/cloak.wav")
	resource.AddFile("sound/uncloak.wav")

end
   
SWEP.HoldType     = "slam"

if CLIENT then
   SWEP.PrintName     = "Invisbility Device"      
   SWEP.Author        = "Fortune"

   SWEP.Slot  = 7

   SWEP.EquipMenuData = {
      type = "Invis Watch",
      desc = "Allows the user to turn invisible.\nLasts for 14 seconds and recharges overtime.\nMade by Fortune."
   };

   SWEP.Icon = "vgui/ttt/discrete/inviswatch"

   local w = 400
   local h = 20
   function SWEP:DrawHUD()
		local start = self:getCloakStart() 
		local dur = self:getCloakDuration()
		local fullDur = self.data.duration 
		local p 
		if self.Owner:isInvis() then
			p = math.Clamp( self:getCloak() - ((CurTime()-start)/dur)*(dur/fullDur), 0, 1 )
		else 
			p = self:getCloak()
		end

		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawRect( ScrW()/2 - w/2, ScrH() - h - 70, w, h )

		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawRect( ScrW()/2 - w/2, ScrH() - h - 70, w*p, h )

   end 

     SWEP.DrawCrosshair   = false

end

SWEP.data = {}
SWEP.data.flashAlpha = 255
SWEP.data.flashTime = 0.6
SWEP.data.canFlash = true 
SWEP.data.Material = "sprites/heatwave"
SWEP.data.flashMaterial = "models/props_c17/fisheyelens"
SWEP.data.cloakTime = 2
SWEP.data.unCloakTime = 1
SWEP.data.duration = 15
SWEP.data.chargeTime = 15
SWEP.data.damageReduction = 0.2
SWEP.data.speedBoost = 1.2
SWEP.data.cloakReduction = 0
SWEP.data.minimumCharge = 0.1

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.UseHands     = true

SWEP.ViewModelFlip = true
SWEP.ViewModel          = "models/weapons/c_slam.mdl"
SWEP.WorldModel         = "models/weapons/w_slam.mdl"
SWEP.ViewModelFOV   = 70
SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax  = -1

local delayTime = 0.2
function SWEP:Initialize()

	self:SetHoldType( self.HoldType )
	self:SetDeploySpeed( 1 )
	self.delay = CurTime()

	self:setCloak( 1 )

	self.BaseClass.Initialize( self )
end 

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_SLAM_DETONATOR_DRAW )
	return self:canHolster()
end 

function SWEP:canInvis()
	return ( CurTime() > self.delay )
end 

function SWEP:isInvis()
  	return self.Owner:isInvis()
end 

function SWEP:canHolster()

	local ply = self.Owner 

	if not IsValid( ply ) then return false end 
	if self:isInvis() then return false end 
	if not ply:isUnCloakedFully() then return false end 
	return true 

end 

function SWEP:setCloakStart( time )
	self:SetNWFloat( "cloakStart", time )
end 

function SWEP:getCloakStart()
	return self:GetNWFloat( "cloakStart", 0 )
end 

function SWEP:setCloakEnd( n )
	self:SetNWFloat( "cloakEnd", n )
end 
function SWEP:setCloakEndNum( n )
	self:SetNWFloat( "cloakEndNum", n )
end 

function SWEP:getCloakEnd()
	return self:GetNWFloat( "cloakEnd", 0 )
end 

function SWEP:getCloakEndNum()
	return self:GetNWFloat( "cloakEndNum", 0 )
end 

function SWEP:setCloakDuration( dur )
	self:SetNWFloat( "cloakDuration", dur )
end 

function SWEP:getCloakDuration()
	return self:GetNWFloat( "cloakDuration", self.data.duration )
end 

function SWEP:setCloak( cloak )
	self:SetNWFloat( "cloak", cloak )
end 

function SWEP:getCloak()
	return self:GetNWFloat( "cloak", 1 )
end 

function SWEP:Think()

	self.AllowDrop = self:canHolster()

	if SERVER then 
		if self:isInvis() then 
			local start = self:getCloakStart() 
			local dur = self:getCloakDuration()
			if CurTime() > start + dur then 
				self:disableInvis()
			end 
		else 

			local cEnd = self:getCloakEnd()
			local cEndNum = self:getCloakEndNum()

			local c = math.Clamp( cEndNum + (CurTime()-cEnd)/self.data.chargeTime, 0, 1 )
			self:setCloak( c )

		end 

	end 

end 

function SWEP:onUncloak()
	return 
end 

function SWEP:disableInvis()
	local o = self.Owner
	if IsValid( o ) then 
		if o:isInvis() then 
			if SERVER then 
				o:setInvis( false, self.data )
				net.Start( "DisableCloakViewModel" )
				net.Send( o )
			end 
			local start = self:getCloakStart()
			local dur = self:getCloakDuration()
			local c = math.Clamp( ( (start + dur - CurTime() )/self.data.duration  ) - self.data.cloakReduction, 0, 1 )
			self:setCloak( c )
			self:setCloakEnd( CurTime() )
			self:setCloakEndNum( self:getCloak() )
			self:onUncloak()
		end
	end 
end 

function SWEP:canAttack()
	return CurTime() > self.delay 
end 

function SWEP:canCloak()
	if self:getCloak() >= self.data.minimumCharge and not self.Owner:isInvis() then
		return true 
	end 
	return false 
end 

function SWEP:PrimaryAttack()
	if self:canAttack() and self:canCloak() then

		local dur = self.data.duration*( 1 - ( 1 - self:getCloak()) ) 
		self:setCloakStart( CurTime() ) 
		self:setCloakDuration( dur )

		if SERVER then 
			self.Owner:setInvis( true, self.data )
		end 

		self:SendWeaponAnim( ACT_SLAM_DETONATOR_DETONATE )

		self.delay = CurTime() + delayTime
	end 
end 

function SWEP:SecondaryAttack()
	if self:canInvis() then 
		self:disableInvis()
		self:SendWeaponAnim( ACT_SLAM_DETONATOR_DETONATE )
		self.delay = CurTime() + delayTime 
	end
end 

function SWEP:Holster()
	if self:canHolster() then 
		self:disableInvis()
		return true 
	end 
	return false 
end 

function SWEP:PreDrop()
  	self:disableInvis()
end 

function SWEP:Remove()
  	self:disableInvis()
end 

function SWEP:DrawWorldModel()
	if IsValid( self.Owner ) then 
		return false 
	else 
		self:DrawModel()
	end 
end 