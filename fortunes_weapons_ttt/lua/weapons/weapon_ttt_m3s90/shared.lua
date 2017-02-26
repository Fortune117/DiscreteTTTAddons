if SERVER then
   AddCSLuaFile( "shared.lua" )
   resource.AddFile( "materials/vgui/ttt/icon_m3s90.vmt" )
end

if CLIENT then
   SWEP.PrintName = "M3S90"
   SWEP.Slot = 2
   SWEP.Icon = "vgui/ttt/icon_m3s90"

   SWEP.crossWidth      = 1
   SWEP.crossHeight     = 16
   SWEP.crossGapMax     = 50

end

-- Always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

-- Standard GMod values
SWEP.HoldType = "shotgun"

SWEP.Primary.Ammo = "Buckshot"
SWEP.Primary.Delay = 0.9
SWEP.Primary.Recoil	= 7
SWEP.Primary.Cone               = 0.05
SWEP.Primary.ConeMax            = 0.25
SWEP.Primary.ConeScaleTime      = 0.2
SWEP.Primary.ConeScaleDownTime  = 0.7
SWEP.Primary.ConeDelay          = 0.1
SWEP.Primary.Damage = 11
SWEP.Primary.Automatic = true
SWEP.Primary.ClipSize = 8
SWEP.Primary.ClipMax = 24
SWEP.Primary.DefaultClip = 8
SWEP.Primary.Sound = Sound( "Weapon_M3.Single" )
SWEP.Primary.NumShots = 8

-- Model settings
SWEP.UseHands = true
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 50
SWEP.ViewModel = "models/weapons/cstrike/c_shot_m3super90.mdl"
SWEP.WorldModel	= "models/weapons/w_shot_m3super90.mdl"

SWEP.IronSightsPos = Vector( -7.67, -12.86, 3.371 )
SWEP.IronSightsAng = Vector( 0.637, 0.01, -1.458 )

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_HEAVY

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon.
SWEP.AutoSpawnable = true

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
SWEP.AmmoEnt = "item_box_buckshot_ttt"

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = { nil }

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = false

SWEP.reloadtimer = 0

SWEP.reloadTime  = 4

function SWEP:Initialize()

    if self.SetHoldType then
       self:SetHoldType(self.HoldType or "pistol")
    end

    self.setReloading =
    function( self, b )
        self:SetReloading( b )
        self.firstLoad = b
        if not b then
            self:SetReloadCount( 0 )
        end
    end

    self:setReloading( false )

    self.isReloading = self.GetReloading

    self:SetShootTime( 0 )

    self:SetConeScale( self.Primary.Cone )

    self.coneDelay = 0

    self.crossGap = 0

   if CLIENT and self:Clip1() == -1 then
      self:SetClip1(self.Primary.DefaultClip)
   elseif SERVER then
      self.fingerprints = {}

      self:SetIronsights(false)
   end

   self:SetDeploySpeed(self.DeploySpeed)

    self.pumpDelay = math.huge

    self.firstLoad = false

end

function SWEP:SetupDataTables()

   self:NetworkVar( "Bool", 0, "Reloading" )
   self:NetworkVar( "Bool", 1, "FirstLoad" )
   self:NetworkVar( "Bool", 3, "Ironsights")
   self:NetworkVar( "Float", 0, "ReloadDelay" )
   self:NetworkVar( "Int", 0, "ReloadCount" )

   self:NetworkVar( "Float", 1, "ShootTime" )
   self:NetworkVar( "Float", 2, "ConeScale" )

end

function SWEP:Deploy()
    self:SendWeaponAnim( ACT_VM_DEPLOY )
end

function SWEP:getReloadTime()
   return self.reloadTime
end

function SWEP:canReload()
    local hasAmmo = self.Owner:GetAmmoCount( self.Primary.Ammo ) > 0
    return (not self:isReloading()) and self:Clip1() < self.Primary.ClipSize and hasAmmo
end

function SWEP:Reload()
    if self:canReload() then
        local diff = self.Primary.ClipSize - self:Clip1()
        self:SetReloadCount( diff )
        self:setReloading( true )
    end
end

function SWEP:getReloadAnim()
    local clip = self:Clip1()
    if self.firstLoad then
        return ACT_SHOTGUN_RELOAD_START
    elseif clip == (self.Primary.ClipSize) then
     return ACT_SHOTGUN_RELOAD_FINISH
    else
        return ACT_VM_RELOAD
    end
end

function SWEP:finishReload()
    local t = self:getReloadTime()/self.Primary.ClipSize
    self:SetReloadDelay( CurTime() + t )

    local anim = self:getReloadAnim()

    local seq = self:SelectWeightedSequence( anim )
    local len = self:SequenceDuration( seq )

    local n = len/t

    self:SendWeaponAnim( anim )
    self.Owner:GetViewModel():SetPlaybackRate( n )
end

local coneDelay = 0.05
function SWEP:Think()

    if self:isReloading() then

        if CurTime() > self:GetReloadDelay() then

            local ammo = self.Owner:GetAmmoCount( self.Primary.Ammo )
            local hasAmmo = ammo > 0

            if self:GetReloadCount() <= 0 or not hasAmmo then
                self:setReloading( false )
                self:finishReload()
                return
            end

            local t = self:getReloadTime()/self.Primary.ClipSize
            self:SetReloadDelay( CurTime() + t )

            local anim = self:getReloadAnim()

            local seq = self:SelectWeightedSequence( anim )
            local len = self:SequenceDuration( seq )

            local n = len/t

            self:SendWeaponAnim( anim )
            self.Owner:GetViewModel():SetPlaybackRate( n )

            if self.firstLoad then
                self.firstLoad = false
            else
                self:SetClip1( self:Clip1() + 1 )
                self.Owner:SetAmmo( ammo - 1, self.Primary.Ammo )
                self:SetReloadCount( self:GetReloadCount() - 1 )
            end


        end

    end

    if CurTime() > self.pumpDelay then
        self:EmitSound( "weapons/m3/m3_pump.wav" )
        self.pumpDelay = math.huge
    end

    if CurTime() > self.coneDelay then
        local c = self:GetConeScale()
        if c > self.Primary.Cone then
            local lastShoot = self:GetShootTime()
            local diff = CurTime() - lastShoot
            if diff > self.Primary.ConeDelay then
                local a = (coneDelay/self.Primary.ConeScaleDownTime)*(self.Primary.ConeMax - self.Primary.Cone)
                local b = math.max( c - a, self.Primary.Cone )
                self:SetConeScale( b )
            end
        end
        self.coneDelay = CurTime() + coneDelay
    end

end

-- The shotgun's headshot damage multiplier is based on distance. The closer it
-- is, the more damage it does. This reinforces the shotgun's role as short
-- range weapon by reducing effectiveness at mid-range, where one could score
-- lucky headshots relatively easily due to the spread.
function SWEP:GetHeadshotMultiplier(victim, dmginfo)
   local att = dmginfo:GetAttacker()
   if not IsValid(att) then return 3 end

   local dist = victim:GetPos():Distance(att:GetPos())
   local d = math.max(0, dist - 140)

   -- decay from 3.1 to 1 slowly as distance increases
   return 1 + math.max(0, (2.1 - 0.002 * (d ^ 1.25)))
end

function SWEP:SecondaryAttack()
   if self.NoSights or (not self.IronSightsPos) or self:isReloading() then return end
   --if self:GetNextSecondaryFire() > CurTime() then return end

   self:SetIronsights(not self:GetIronsights())

   self:SetNextSecondaryFire(CurTime() + 0.3)
end
