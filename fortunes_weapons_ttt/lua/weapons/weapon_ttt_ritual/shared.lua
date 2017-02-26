if SERVER then
   AddCSLuaFile( "shared.lua" )
end

if CLIENT then
   SWEP.PrintName			= "The Ritual"			
   SWEP.Author				= "Fortune"

   SWEP.Slot				= 7


   SWEP.EquipMenuData = {
      type = "item_weapon",
      desc = "Used to resurrect dead allies."
   };
   SWEP.Icon = "vgui/ttt/icon_skull"

end

SWEP.HoldType = "slam"
SWEP.ViewModelFOV = 70
SWEP.ViewModelFlip = false
SWEP.UseHands = true
SWEP.ViewModel = "models/weapons/c_slam.mdl"
SWEP.WorldModel = "models/weapons/w_pistol.mdl"
SWEP.ShowViewModel = false
SWEP.ShowWorldModel = false
SWEP.ViewModelBoneMods = {
	["ValveBiped.Bip01_R_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-3.333, -5.557, 7.777) },
	["ValveBiped.Bip01_L_Finger1"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, 10, 0) },
	["ValveBiped.Bip01_L_Finger01"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -30, 0) },
	["ValveBiped.Bip01_L_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(0, -5.557, -85.556) },
	["ValveBiped.Bip01_Spine4"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(1.11, 0, 0) },
	["ValveBiped.Bip01_L_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(36.666, -12.223, 0) },
	["ValveBiped.Bip01_L_Forearm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(14.444, 7.777, -12.223) },
	["Detonator"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Finger0"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(-7.778, -7.778, 0) },
	["ValveBiped.Bip01_L_UpperArm"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(14.444, -12.223, 0) },
	["Slam_base"] = { scale = Vector(0.009, 0.009, 0.009), pos = Vector(0, 0, 0), angle = Angle(0, 0, 0) },
	["ValveBiped.Bip01_R_Hand"] = { scale = Vector(1, 1, 1), pos = Vector(0, 0, 0), angle = Angle(23.333, 5.556, -21.112) }
}

SWEP.VElements = {
	["eye_sprite2"] = { type = "Sprite", sprite = "lasersights/laserglow1", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(-1, 6.849, -1.201), size = { x = 4.8, y = 4.8 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false},
	["skull"] = { type = "Model", model = "models/Gibs/HGIBS.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(4.675, 3.635, 0), angle = Angle(19.87, -132.079, -180), size = Vector(0.755, 0.755, 0.755), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} },
	["eye_sprite1"] = { type = "Sprite", sprite = "lasersights/laserglow1", bone = "ValveBiped.Bip01_L_Hand", rel = "", pos = Vector(-3.6, 7.9, 0), size = { x = 3.805, y = 3.805 }, color = Color(255, 255, 255, 255), nocull = true, additive = true, vertexalpha = true, vertexcolor = true, ignorez = false}
}
SWEP.WElements = {
	["skull"] = { type = "Model", model = "models/Gibs/HGIBS.mdl", bone = "ValveBiped.Bip01_R_Hand", rel = "", pos = Vector(2.596, 4, -0.519), angle = Angle(143.766, 78.311, -19.871), size = Vector(0.755, 0.755, 0.755), color = Color(255, 255, 255, 255), surpresslightning = false, material = "", skin = 0, bodygroup = {} }
}

SWEP.Base	= "weapon_tttbase"

SWEP.Kind = WEAPON_EQUIP2
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

SWEP.ghostModel = ritual.model 
SWEP.range = 120

SWEP.AllowDrop = true


function SWEP:Initialize()

   self.delay = 0

   self:SetDeploySpeed( 100 )

   if CLIENT then
   
      // Create a new table for every weapon instance
      self.VElements = table.FullCopy( self.VElements )
      self.WElements = table.FullCopy( self.WElements )
      self.ViewModelBoneMods = table.FullCopy( self.ViewModelBoneMods )

      self:CreateModels(self.VElements) // create viewmodels
      self:CreateModels(self.WElements) // create worldmodels
      
      // init view model bone build function
      if IsValid(self.Owner) then
         local vm = self.Owner:GetViewModel()
         if IsValid(vm) then
            self:ResetBonePositions(vm)
            
            // Init viewmodel visibility
            if (self.ShowViewModel == nil or self.ShowViewModel) then
               vm:SetColor(Color(255,255,255,255))
            else
               // we set the alpha to 1 instead of 0 because else ViewModelDrawn stops being called
               vm:SetColor(Color(255,255,255,1))
               // ^ stopped working in GMod 13 because you have to do Entity:SetRenderMode(1) for translucency to kick in
               // however for some reason the view model resets to render mode 0 every frame so we just apply a debug material to prevent it from drawing
               vm:SetMaterial("Debug/hsv")         
            end
         end
      end
      
   end

end

function SWEP:createGhost()
	self.ghost = ents.CreateClientProp()
	local g = self:getGhost()
	g:SetModel( self.ghostModel )
	g:SetColor( Color( 0, 255, 255, 150 ) )
	g:SetRenderMode( RENDERMODE_TRANSALPHA )
	g:Spawn()
end

function SWEP:positionGhost( body, norm )
	local pos = body:GetPos()
	local g = self:getGhost()
	local tr2 = util.QuickTrace( body:GetPos(), Vector( 0, 0, -1 ), { self.Owner, body, g } )
	g:SetPos( tr2.HitPos - Vector( 0, 0, 6 ) )
	g:SetAngles( Angle( 0, 0, 0 ) )
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


local ValidEnts = 
{
	"prop_ragdoll"
}
function SWEP:Think()

	local ply = self.Owner
	
	local tr = ply:GetEyeTrace()

	if CLIENT then
		if tr.Hit and not tr.HitWorld then
			local e = tr.Entity 
			local dist = tr.StartPos:Distance( tr.HitPos )
			if IsValid( e ) and table.HasValue( ValidEnts, e:GetClass() ) then
				if dist < self.range then 
					if not IsValid( self:getGhost() ) then
						self:createGhost()
					end
					self:positionGhost( e, tr.HitNormal )
					return 
				end 
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

function SWEP:canAttack()
	return CurTime() > self.delay 
end 

function SWEP:PrimaryAttack()

	if not self:canAttack() then return end  
	local ply = self.Owner
	local tr = ply:GetEyeTrace()
	
	if CLIENT then return end 
	if tr.Hit and not tr.HitWorld then

		local e = tr.Entity 
		local dist = tr.StartPos:Distance( tr.HitPos )
		if IsValid( e ) and table.HasValue( ValidEnts, e:GetClass() ) then
			if dist < self.range then 
				local tr2 = util.QuickTrace( e:GetPos(), Vector( 0, 0, -1 ), {self,self.Owner,e } )
				if self:validSpawnPoint( tr2.HitPos, e ) then 
					local ef = EffectData()
					ef:SetEntity( e )
					ef:SetOrigin( tr2.HitPos )
					util.Effect( "ef_ritual", ef, true, true )
					addRitualThinkFunction( self.Owner, e )
					e:Dissolve()
					self:Remove()
				end 
			end 
		end 

	end
	self.delay = CurTime() + 0.5
end 

function SWEP:Holster()
	if IsValid( self.ghost ) then
		self:removeGhost()
	end
	if CLIENT and IsValid(self.Owner) then
      local vm = self.Owner:GetViewModel()
      if IsValid(vm) then
         self:ResetBonePositions(vm)
      end
   end
	return true 
end 

function SWEP:PreDrop()
	self:Holster()
end 

function SWEP:OnRemove()
	self:Holster()
end 



