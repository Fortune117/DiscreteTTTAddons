
AddCSLuaFile()

SWEP.HoldType = "normal"


if CLIENT then
   SWEP.PrintName = "Pocket IED"
   SWEP.Slot = 6
   
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Place this device on a player or a\ncorpse with left click, then right click to\n detonate! Have fun!"
   };
   
  SWEP.Icon = "vgui/ttt/icons/icon_ied"

end


SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_slam.mdl"

SWEP.Base				= "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.Spawnable = false

SWEP.AutoSpawnable      = true

SWEP.Weight			= 5

SWEP.DrawAnim = ACT_SLAM_TRIPMINE_DRAW
SWEP.CanPlaceAnim = ACT_SLAM_TRIPMINE_ATTACH
SWEP.IdleAnim = ACT_SLAM_TRIPMINE_IDLE
SWEP.PlaceAnim = ACT_SLAM_TRIPMINE_ATTACH2

SWEP.DrawAnim_Placed = ACT_SLAM_DETONATOR_DRAW
SWEP.Detonate = ACT_SLAM_DETONATOR_DETONATE
SWEP.DetIdle = ACT_SLAM_DETONATOR_IDLE
SWEP.ChangeAnim = ACT_SLAM_TRIPMINE_TO_THROW_ND

SWEP.range = 110^2
SWEP.sound = "nokia.wav"

function SWEP:Initialize()

   	self.planted = false 
   	self.raised = false 
	self:SetDeploySpeed( 100 )

end

function SWEP:canPlant( anims )

	if self.planted then return false end 

	local ply = self.Owner 
	local tr = ply:GetEyeTrace()

	if tr.HitNonWorld and IsValid( tr.Entity ) then 
		local e = tr.Entity 
		local in_range = tr.StartPos:DistToSqr( tr.HitPos ) <= self.range
		if in_range then 
			if e:IsPlayer() or e:GetClass() == "prop_ragdoll" and not e:isIEDTarget() then 
				if anims then 
					self:setRaised( true )
				end 
				return true, e 
			end 
		end 
	end 

	if anims then 
		self:setRaised( false )
	end 

	return false 

end

function SWEP:isRaised()
	return self.raised 
end 

function SWEP:setRaised( b )

	if b and not self:isRaised() then 
		self:SendWeaponAnim( self.CanPlaceAnim )
	elseif not b and self:isRaised() then 
		self:SendWeaponAnim( self.IdleAnim )
	end 

	self.raised = b  

end 

function SWEP:Think()
	if not self.planted then 
		self:canPlant( true )
	elseif CurTime() > self.doPlaceAnim and not self.animPlayed then 
		self:SendWeaponAnim( self.DrawAnim_Placed )
		self.animPlayed = true 
	end 
end 

local placeSounds = 
{
	"physics/cardboard/cardboard_box_break1.wav",
	"physics/cardboard/cardboard_box_break2.wav",
	"physics/cardboard/cardboard_box_break3.wav"
}
function SWEP:PrimaryAttack()
	if SERVER then 
		local canPlant, targ = self:canPlant( false )
		if canPlant then

			self.Owner:setIEDTarget( targ )

			if SERVER then 
				self.Owner:EmitSound( tostring( table.Random( placeSounds ) ), 75, 100, 0.1 )
			end 

			self:SendWeaponAnim( self.PlaceAnim )
			self.doPlaceAnim = CurTime() + 1.8
			self.animPlayed = false 
			self.planted = true 
		end 
	end 
end 


local detSound = "buttons/button9.wav"
function SWEP:SecondaryAttack()
	local targ = self.Owner:getIEDTarget()
	if IsValid( targ ) and self.planted and not self.detonated then 

		if not targ:IsPlayer() or targ:Alive() then 
			targ:doIEDExplosionThink( self.Owner, self.sound, self )
			targ:EmitSound( self.sound )
			self:SendWeaponAnim( self.Detonate )

			if SERVER then 
				self.Owner:EmitSound( "buttons/button9.wav", 75, 100, 0.6 )
			end 

			self.detonated = true 
		end

	end 
end

function SWEP:Holster()
	if self.planted and not self.animPlayed then 
		self.animPlayed = true 
	end 
	return true 
end 

function SWEP:Deploy()
	if self.planted and not self.animPlayed then 
		self.animPlayed = true 
	end 

	if self.planted then 
		self:SendWeaponAnim( self.DrawAnim_Placed )
	else 
		self:SendWeaponAnim( self.DrawAnim )
	end 

	return true 
end 