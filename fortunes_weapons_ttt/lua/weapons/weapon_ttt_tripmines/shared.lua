
if( SERVER ) then
	AddCSLuaFile( "shared.lua" )
end

SWEP.HoldType = "slam" 

if( CLIENT ) then
	SWEP.PrintName = "S.L.A.M Mines"
	SWEP.Slot = 6
	SWEP.DrawAmmo = false
	SWEP.DrawCrosshair = true
	
	SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Three powerful S.L.A.M mines the user\ncan place down. Useful for setting up traps."
    };

   SWEP.Icon = "vgui/ttt/icons/icon_tripmine"
end

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_TRAITOR}
SWEP.LimitedStock = false

SWEP.ViewModelFOV	= 64
SWEP.ViewModelFlip	= false

SWEP.Base = "weapon_tttbase"

SWEP.UseHands 			= true
SWEP.ViewModel			= "models/weapons/c_slam.mdl"
SWEP.WorldModel			= "models/weapons/w_slam.mdl"

SWEP.Primary.Delay				= 1
SWEP.Primary.Recoil				= 0
SWEP.Primary.Damage				= -1
SWEP.Primary.NumShots			= -1
SWEP.Primary.Cone				= -1
SWEP.Primary.ClipSize			= 3
SWEP.Primary.DefaultClip		= 3
SWEP.Primary.Automatic   		= false
SWEP.Primary.Ammo         		= "none"

SWEP.Secondary.Delay			= 1
SWEP.Secondary.Recoil			= 0
SWEP.Secondary.Damage			= -1
SWEP.Secondary.NumShots			= -1
SWEP.Secondary.Cone				= -1
SWEP.Secondary.ClipSize			= -1
SWEP.Secondary.DefaultClip		= -1
SWEP.Secondary.Automatic  	 	= false
SWEP.Secondary.Ammo         	= "none"

SWEP.DrawAnim = ACT_SLAM_TRIPMINE_DRAW
SWEP.AttachAnim = ACT_SLAM_TRIPMINE_ATTACH
SWEP.LowerAnim = ACT_SLAM_TRIPMINE_IDLE
SWEP.DetAnim = ACT_SLAM_STICKWALL_DETONATE


function SWEP:SendAnim( anim, delay )
	if CurTime() >= self.Animdelay then
		if IsFirstTimePredicted() then
			self:SendWeaponAnim( anim )
		end
	end
	self.Animdelay = CurTime() + delay
end

function SWEP:Initialize()
	self:SetDeploySpeed(100)
	self.Animdelay = CurTime()
	self.TriggerPlaced = false
end

function SWEP:Holster()
	return true
end

function SWEP:Deploy()
	self:SendAnim( self.DrawAnim, 0.2 )
	return true
end

function SWEP:CanPlaceMine()
	local tr = self.Owner:GetEyeTrace()
	
	if tr.HitPos:Distance(self.Owner:GetShootPos()) <= 50 and tr.HitWorld  then
		return true
	end
	return false
end

function SWEP:PlaceMine()
	local tr = self.Owner:GetEyeTrace()
	
	if self:CanPlaceMine() then
		self:SendAnim( ACT_SLAM_TRIPMINE_ATTACH2, 1 )
		if SERVER then		
			local slam = ents.Create("ttt_slam")
			slam:SetPos(tr.HitPos + tr.HitNormal*2)
			slam:SetAngles((tr.HitNormal):Angle() + Angle(90,0,0))
			slam:SetOwner( self.Owner )
			slam:Spawn()
			slam:Activate()
			self.Owner:EmitSound("weapons/slam/mine_mode.wav")
		end
		self:TakePrimaryAmmo(1)
		
		if SERVER then
			if self:Clip1() == 0 then
				self:Remove()
			end
		end
	end
end 

SWEP.HoldUp = false
function SWEP:Think()
	if self:CanPlaceMine() and self.HoldUp == false then
		self.HoldUp = true
		self:SendAnim( self.AttachAnim, 0)
	elseif !self:CanPlaceMine() and self.HoldUp == true then
		self.HoldUp = false
		self:SendAnim( self.LowerAnim, 0 )
	end
end


function SWEP:PrimaryAttack()
	if (!self:CanPrimaryAttack()) then return end
		self:PlaceMine()
	return true
end


function SWEP:SecondaryAttack()
	local E = ents.FindByClass("ttt_slam")
	for k,v in pairs(E) do
		if v.Placer == self.Owner then
			v:Detonate()
		end
	end
end

function SWEP:SetOwner( ent )
	self:SetNWInt( "Owner", ent )
end 

function SWEP:GetOwner()
	return self:GetNWInt( "Owner" )
end 

function SWEP:Reload()
	return 
end 

function SWEP:Holster()
	return true 
end 


	