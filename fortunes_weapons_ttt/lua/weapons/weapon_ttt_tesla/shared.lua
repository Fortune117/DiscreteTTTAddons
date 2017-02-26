if SERVER then
   AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType = "normal"

if CLIENT then
   SWEP.PrintName			= "Tesla Coil"			
   SWEP.Author				= "Fortune"

   SWEP.Slot				= 7


   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "A bubble of protection."
   };
   SWEP.Icon = "vgui/ttt/icon_skull"

end

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 10
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel			= "models/weapons/c_crowbar.mdl"
SWEP.WorldModel			= "models/weapons/w_crowbar.mdl"

SWEP.Base	= "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP2
SWEP.CanBuy = {ROLE_DETECTIVE}
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

SWEP.ghostModel = Model( "models/props_combine/combine_light001a.mdl" ) 
SWEP.range = 120

SWEP.AllowDrop = true


function SWEP:Initialize()

	self:SetHoldType( self.HoldType )

   	self:SetDeploySpeed( 100 )

end

function SWEP:createGhost()
	self.ghost = ents.CreateClientProp()
	local g = self:getGhost()
	g:SetModel( self.ghostModel )
	g:SetColor( Color( 0, 255, 255, 150 ) )
	g:SetRenderMode( RENDERMODE_TRANSALPHA )
	g:Spawn()
end

function SWEP:positionGhost( tr )
	local g = self:getGhost()
	g:SetPos( tr.HitPos )
	g:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
end 

function SWEP:getGhost()
	return self.ghost 
end 

function SWEP:removeGhost()
	local g = self:getGhost()
	if IsValid( g ) then 
		g:Remove()
	end 
end 

function SWEP:Deploy()
	self:SendWeaponAnim( ACT_VM_DRAW )
	return true 
end


function SWEP:Think()

	local ply = self.Owner
	
	local tr = ply:GetEyeTrace()

	if CLIENT then
		if tr.HitWorld then
			local dist = tr.StartPos:Distance( tr.HitPos )
			if dist < self.range then 
				if not IsValid( self:getGhost() ) then
					self:createGhost()
				end
				self:positionGhost( tr )
				return 
			end 
		end
		self:removeGhost()
	end 

end 

function SWEP:validSpawnPoint( pos, body )
	local tr = util.TraceHull( {
	start = pos,
	endpos = pos,
	filter = {self.Owner, body }, 
	mins = Vector( -16, -16, 0 ),
	maxs = Vector( 16, 16, 72 ),
	mask = MASK_SHOT_HULL
	} )

	if tr.Hit then 
		self.Owner:PrintMessage( HUD_PRINTTALK, "Not enough room or something is in the way!" )
		return false 
	end 
	return true 
end 

function SWEP:PrimaryAttack()
	if SERVER then 
		local tr = self.Owner:GetEyeTrace()
		if tr.HitWorld then 
			local dist = tr.StartPos:Distance( tr.HitPos )
			if dist < self.range then 
				self:spawnTesla( tr )
				self:Remove()
			end 
		end 
	end
end 

function SWEP:spawnTesla( tr )
	local tesla = ents.Create( "ttt_tesla" )
	tesla:SetPos( tr.HitPos )
	tesla:SetAngles( tr.HitNormal:Angle() + Angle( 90, 0, 0 ) )
	tesla:setDamageOwner( self.Owner )
	tesla:Spawn()
	tesla:SetHealth( self.Owner.teslaHealth or 500 )
end 

function SWEP:Holster()
	if IsValid( self.ghost ) then
		self:removeGhost()
	end
	return true 
end 

function SWEP:OnDrop()
	self:Holster()
end 

function SWEP:OnRemove()
	self:Holster()
end 

function SWEP:WasBought(buyer)
   if IsValid(buyer) then -- probably already self.Owner
      buyer.teslaHealth = 500 
   end
end
