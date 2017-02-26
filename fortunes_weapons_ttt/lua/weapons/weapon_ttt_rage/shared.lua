
AddCSLuaFile()

SWEP.HoldType = "slam"

if SERVER then 
	resource.AddFile( "vgui/ttt/icon_nervegas.vmt" )
end 

if CLIENT then
   SWEP.PrintName = "Rage Virus"
   SWEP.Slot = 6
   
   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Gives you "..rage.duration.." seconds of super strength!\nThen you die!\nHave fun, made by Fortune."
   };
   
  SWEP.Icon = "vgui/ttt/icon_nervegas"

end

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 50
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel      = "models/weapons/c_medkit.mdl" 
SWEP.WorldModel     = "models/weapons/w_medkit.mdl"

SWEP.Base				= "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.Weight			= 5

SWEP.DeploySpeed = 100 


function SWEP:PrimaryAttack()
	local o = self.Owner 
	if SERVER then 
		o:rage()
	end 
end 

function SWEP:SecondaryAttack()
	return 
end 

function SWEP:Holster()
	return true 
end 

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	return true 
end 
