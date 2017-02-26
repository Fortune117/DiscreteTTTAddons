if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile( "materials/vgui/ttt/icon_famas.vmt" )
end

if CLIENT then
   SWEP.PrintName = "Famas"
   SWEP.Slot = 2
   SWEP.Icon = "vgui/ttt/icon_famas"

   SWEP.crossWidth      = 1
   SWEP.crossHeight     = 13
   SWEP.crossGapMax     = 24

end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "ar2"

SWEP.Primary.Ammo = "SMG1"
SWEP.Primary.Delay = 0.35
SWEP.Primary.Recoil = 1
SWEP.Primary.Cone               = 0.005
SWEP.Primary.ConeMax            = 0.04
SWEP.Primary.ConeScaleTime      = 0.7
SWEP.Primary.ConeScaleDownTime  = 0.4
SWEP.Primary.ConeDelay          = 0.2
SWEP.Primary.Damage = 34
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 30
SWEP.Primary.ClipMax = 60
SWEP.Primary.DefaultClip = 30
SWEP.Primary.Sound = Sound( "Weapon_FAMAS.Single" )

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel = "models/weapons/w_rif_famas.mdl"

SWEP.IronSightsPos = Vector( -6.24, -2.757, 1.36 )
SWEP.IronSightsAng = Vector( 0, 0, 0 )

SWEP.HeadShotMult = 2

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
