if SERVER then
   AddCSLuaFile( "shared.lua" )
end
   
SWEP.HoldType     = "slam"

if CLIENT then
   SWEP.PrintName     = "Stimpack"      
   SWEP.Author        = "Fortune"

   SWEP.Slot  = 6

   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Use this for a quick health boost. Made by Fortune"
   };

   SWEP.Icon = "vgui/ttt/discrete/stimpack"

end

SWEP.Base = "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = true

SWEP.UseHands     = true
SWEP.ViewModel      = "models/weapons/c_medkit.mdl" 
SWEP.WorldModel     = "models/weapons/w_medkit.mdl"
SWEP.ViewModelFlip   = false
SWEP.ViewModelFOV   = 60

SWEP.Primary.DefaultClip = -1
SWEP.Primary.ClipSize = -1
SWEP.Primary.ClipMax  = -1

SWEP.healAmount     = 15
SWEP.healAllyBoost  = 2
SWEP.maxCharges     = 2

SWEP.chargeTime     = 30

SWEP.range          = 80

local HealSound = Sound( "items/smallmedkit1.wav" )
local DenySound = Sound( "items/medshotno1.wav" )

function SWEP:SetupDataTables()
   self:NetworkVar("Float", 0, "ChargeDelay")
   self:NetworkVar("Int", 0, "Charges")
end

function SWEP:Initialize()

    self:SetCharges( self.maxCharges ) 

    self:SetDeploySpeed( 3 )

   if self.SetHoldType then
      self:SetHoldType(self.HoldType or "pistol")
   end

end 

function SWEP:Deploy()
    self:SendWeaponAnim( ACT_VM_DEPLOY )
    return true 
end 

function SWEP:Holster()
    return true 
end 

function SWEP:PrimaryAttack()
    if SERVER then
        local ply = self.Owner 
        local spos = ply:GetShootPos()

        ply:LagCompensation( true )
            local tr = util.QuickTrace( spos, ply:GetAimVector()*self.range, { self, ply } )
        ply:LagCompensation( false )

        if tr.Hit and IsValid( tr.Entity ) then 
            if self:canHeal( tr.Entity ) then 
                 self:heal( tr.Entity )
            end 
        end 
    end
end

function SWEP:SecondaryAttack()
    if SERVER then
        if self:canHeal( self.Owner ) then 
            self:heal()
        end 
    end
    return 
end

function SWEP:canHeal( target )

    if self:GetCharges() <= 0 then 
         self.Owner:EmitSound( DenySound )
        return false 
    end 

    if target:IsPlayer() then 
        if target:Health() < target:GetMaxHealth() then 
            return true 
        end 
    end 

    return false 
end 

function SWEP:heal( targ )

    if not targ then 

        local ply = self.Owner 
        local newhp = math.min( ply:Health() + self.healAmount, ply:GetMaxHealth() )
        ply:SetHealth( newhp )

        self:onHeal()

    else

        local ply = targ 
        local newhp = math.min( ply:Health() + self.healAmount*self.healAllyBoost, ply:GetMaxHealth() )
        ply:SetHealth( newhp )

        self:onHeal()

    end 

end 

function SWEP:onHeal()

    local maxCharges = self:GetCharges() == self.maxCharges

    self:SetCharges( self:GetCharges() - 1 )

    if not maxCharges then  
        local delay = self:GetChargeDelay()
        local p = ( CurTime() - delay )/( self.chargeTime/self.maxCharges)

        self:SetChargeDelay( CurTime() - p*(self.chargeTime/self.maxCharges) )
    else 
        self:SetChargeDelay( CurTime() )
    end 

    self.Weapon:SendWeaponAnim( ACT_VM_PRIMARYATTACK )
    self.Owner:EmitSound( HealSound )

end 

function SWEP:Think()
    if SERVER then 
        if self:GetCharges() < self.maxCharges then 
            if CurTime() > self:GetChargeDelay() + self.chargeTime/self.maxCharges then 
                self:SetCharges( self:GetCharges() + 1 )
                self:SetChargeDelay( CurTime() )
            end 
        end 
    end 
end 

if CLIENT then


    function SWEP:DrawHUD()

        local fullw = ScrW()/5
        local w = fullw/self.maxCharges
        local h = 10
        local x = (ScrW() - fullw)/2
        local y = ScrH() - 60

        surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
        for i = 1, self.maxCharges do 
            local barx = x + w*(i-1) + i*4 - 1
            local bary = y - 1
            local barw = w + 2
            local barh = h + 2
            surface.DrawRect( barx, bary, barw, barh ) 
        end    

        local p = 1
        local r = 255*( 1 - p )
        local g = 255*( p )
        local b = 80*( p )
        surface.SetDrawColor( Color( r, g, b, 255 ) )

        local charges = self:GetCharges()
        for i = 1, self.maxCharges do 
            if i <= charges then 
                local barx = x + w*(i-1) + i*4
                local bary = y 
                local barw = w 
                local barh = h 
                surface.DrawRect( barx, bary, barw, barh )
            elseif i == charges + 1 then 
                local p = math.min( (( CurTime() - self:GetChargeDelay() )/(self.chargeTime/self.maxCharges)), 1 )
                local barx = x + w*(i-1) + i*4
                local bary = y 
                local barw = w*p
                local barh = h 
                surface.DrawRect( barx, bary, barw, barh )
            end 
        end    

    end

end 