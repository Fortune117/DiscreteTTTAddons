if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile( "materials/vgui/ttt/icon_galil.vmt" )
end

if CLIENT then
   SWEP.PrintName = "Galil"
   SWEP.Slot = 2
   SWEP.Icon = "vgui/ttt/icon_galil"

   SWEP.crossWidth      = 1
   SWEP.crossHeight     = 13
   SWEP.crossGapMax     = 32

end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "ar2"

SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Delay = 0.095
SWEP.Primary.Recoil = 0.8
SWEP.Primary.Cone               = 0.01
SWEP.Primary.ConeMax            = 0.04
SWEP.Primary.ConeScaleTime      = 0.5
SWEP.Primary.ConeScaleDownTime  = 0.25
SWEP.Primary.ConeDelay          = 0.1
SWEP.Primary.Damage = 12
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound( "Weapon_Galil.Single" )

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 58
SWEP.ViewModel = "models/weapons/cstrike/c_rif_galil.mdl"
SWEP.WorldModel = "models/weapons/w_rif_galil.mdl"

SWEP.IronSightsPos = Vector( -6.361, -11.103, 2.519 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_HEAVY

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = true

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_ammo_smg1_ttt"

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = { nil }

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false
