
AddCSLuaFile()

SWEP.HoldType = "slam"


if CLIENT then
   SWEP.PrintName = "Corpse Trapper"
   SWEP.Slot = 6
   
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Place this device on a player or a corpse\nand when a player identifies it, it will set off an\n explosion.\nMade by Fortune."
   };
   
  SWEP.Icon = "vgui/ttt/icon_corpse"

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

SWEP.range = 90^2
SWEP.sound = "nokia.wav"

function SWEP:Initialize()

   	self.planted = false 
   	self.raised = false 
	self:SetDeploySpeed( 100 )

end

function SWEP:Deploy()
	self:SendWeaponAnim( self.DrawAnim )
	return true 
end 

function SWEP:canPlant( anims )

	if self.planted then return false end 

	local ply = self.Owner 
	local tr = ply:GetEyeTrace()

	if tr.HitNonWorld and IsValid( tr.Entity ) then 
		local e = tr.Entity 
		local in_range = tr.StartPos:DistToSqr( tr.HitPos ) <= self.range
		if in_range then 
			if e:GetClass() == "prop_ragdoll" and e.player_ragdoll then
				if not e:isCorpseTrapped() and not CORPSE.GetFound( e, false ) then 
					if anims then 
						self:setRaised( true )
					end 
					return true, e
				end 
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
	elseif self.removeDelay and CurTime() > self.removeDelay then
		if SERVER then 
			self:Remove()
		end 
	end 
end 

local placeSounds = 
{
	"physics/cardboard/cardboard_box_break1.wav",
	"physics/cardboard/cardboard_box_break2.wav",
	"physics/cardboard/cardboard_box_break3.wav"
}
function SWEP:PrimaryAttack()
	local canPlant, targ = self:canPlant( false )
	if canPlant then

		targ:setUpCorpseTrap( self.Owner, "npc/attack_helicopter/aheli_charge_up.wav" )

		if SERVER then 
			self.Owner:EmitSound( tostring( table.Random( placeSounds ) ), 75, 100, 0.1 )
			self:Remove()
		end 

	end 
end 
