if SERVER then
   AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.PrintName			= "Missile Launcher"			
   SWEP.Author				= "Fortune"

   SWEP.Slot				= 6


   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "A remote controlled missile."
   };
   SWEP.Icon = "vgui/ttt/icon_splode"

end

SWEP.HoldType = "rpg"
SWEP.ViewModelFOV = 54
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel			= "models/weapons/v_rpg.mdl"
SWEP.WorldModel			= "models/weapons/w_rocket_launcher.mdl"

SWEP.Base	= "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.Primary.Ammo       = "none" 
SWEP.Primary.Recoil			= -1
SWEP.Primary.Damage = -1
SWEP.Primary.Delay = -1
SWEP.Primary.Cone = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

SWEP.checkDist = 100 

SWEP.fireSound = Sound( "weapons/rpg/rocketfire1.wav" )
function SWEP:canFire()
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	local dist = tr.StartPos:Distance( tr.HitPos )
	if dist < self.checkDist then return false end 
	if self.missleSpawned then return false end 
	return true
end 

function SWEP:PrimaryAttack()
	if self:canFire() then 
		self:spawnMissile()
	end 
end 

function SWEP:spawnMissile()

	local ply = self.Owner 
	local shootPos = ply:GetShootPos()
	local aimDir = ply:GetAimVector()

	if SERVER then 
		local mis = ents.Create( "ttt_missile" )
		mis:SetPos( shootPos + aimDir*5 )
		mis:SetAngles( aimDir:Angle() )
		mis:SetOwner( self.Owner )
		mis:Spawn()
		mis:Activate()

		self.Owner:SetNWEntity( "specMissile", mis )
		self.Owner:EmitSound( self.fireSound )
	end 
		
	self.missleSpawned = true 

end 

if CLIENT then 
	function SWEP:AdjustMouseSensitivity()
		local ply = LocalPlayer()
		if IsValid( ply:GetNWEntity( "specMissile" ) ) then 
			return 0.8
		end 
	end 
end 