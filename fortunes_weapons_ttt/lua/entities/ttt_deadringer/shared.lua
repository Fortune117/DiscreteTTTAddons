if SERVER then
   AddCSLuaFile("shared.lua")
   util.AddNetworkString( "SendWatchAnim" )
end

ENT.Type = "anim"

ENT.Model = Model("models/weapons/v_models/v_invis_spy.mdl")

ENT.data = {}
ENT.data.flashAlpha = 255
ENT.data.flashTime = 0.6
ENT.data.canFlash = true 
ENT.data.Material = "sprites/heatwave"
ENT.data.flashMaterial = "models/props_c17/fisheyelens"
ENT.data.cloakTime = 1
ENT.data.unCloakTime = 0.5
ENT.data.duration = 25
ENT.data.chargeTime = 13
ENT.data.damageReduction = 0.25
ENT.data.speedBoost = 1.3
ENT.data.cloakReduction = 0
ENT.data.minimumCharge = 0.15

local delayTime = 0.2
function ENT:Initialize()
	self:setCloak( 1 )
	self:SetModel( self.Model )

	if CLIENT then 
        hook.Add( "HUDPaint", self, self.DrawHUD )
        self.drawCloak = 1
	end 

end 

function ENT:canInvis()
	return ( CurTime() > self.delay )
end 

function ENT:isInvis()
  	return self.Owner:isInvis()
end 

function ENT:setCloakStart( time )
	self:SetNWFloat( "cloakStart", time )
end 

function ENT:getCloakStart()
	return self:GetNWFloat( "cloakStart", 0 )
end 

function ENT:setCloakEnd( n )
	self:SetNWFloat( "cloakEnd", n )
end 
function ENT:setCloakEndNum( n )
	self:SetNWFloat( "cloakEndNum", n )
end 

function ENT:getCloakEnd()
	return self:GetNWFloat( "cloakEnd", 0 )
end 

function ENT:getCloakEndNum()
	return self:GetNWFloat( "cloakEndNum", 0 )
end 

function ENT:setCloakDuration( dur )
	self:SetNWFloat( "cloakDuration", dur )
end 

function ENT:getCloakDuration()
	return self:GetNWFloat( "cloakDuration", self.data.duration )
end 

function ENT:setCloak( cloak )
	self:SetNWFloat( "cloak", cloak )
end 

function ENT:getCloak()
	return self:GetNWFloat( "cloak", 1 )
end 

function ENT:Think()

	if SERVER then 
		if self:isInvis() then 
			local start = self:getCloakStart() 
			local dur = self:getCloakDuration()
			if CurTime() > start + dur then 
				self:disableInvis()
			end 
		else 

			local cEnd = self:getCloakEnd()
			local cEndNum = self:getCloakEndNum()

			local c = math.Clamp( cEndNum + (CurTime()-cEnd)/self.data.chargeTime, 0, 1 )
			self:setCloak( c )

		end 

	end 

end 

function ENT:onUncloak()
	return 
end 

function ENT:sendWatchAnim( seq )
	net.Start( "SendWatchAnim" )
		net.WriteInt( self:LookupSequence( seq ), 8 )
	net.Send( self.Owner )
end 

function ENT:doCloak()
	if self:canCloak() then

		local dur = self.data.duration*( 1 - ( 1 - self:getCloak()) ) 
		self:setCloakStart( CurTime() ) 
		self:setCloakDuration( dur )

		if SERVER then 
			self.Owner:setInvis( true, self.data )
		end 

		self.delay = CurTime() + delayTime

	end 
end 

function ENT:doUncloak()
	local o = self.Owner
	if IsValid( o ) then 
		if o:isInvis() then 
			if SERVER then 
				o:setInvis( false, self.data )
				net.Start( "DisableCloakViewModel" )
				net.Send( o )
			end 
			local start = self:getCloakStart()
			local dur = self:getCloakDuration()
			local c = math.Clamp( ( (start + dur - CurTime() )/self.data.duration  ) - self.data.cloakReduction, 0, 1 )
			self:setCloak( c )
			self:setCloakEnd( CurTime() )
			self:setCloakEndNum( self:getCloak() )
			self:onUncloak()

		end
	end 
end 

function ENT:canCloak()
	if self:getCloak() >= self.data.minimumCharge and not self.Owner:isInvis() then
		return true 
	end 
	return false 
end 

function ENT:OnRemove()
	self:doUncloak()
	if CLIENT then
		if IsValid( self.drawModel ) then 
			self.drawModel:Remove()
		end 
	end 
end 

if CLIENT then 
	function ENT:Draw()
	end 

   	local w = 400
  	local h = 20 
	function ENT:DrawHUD()
		local start = self:getCloakStart() 
		local dur = self:getCloakDuration()
		local fullDur = self.data.duration 
		local c = self:getCloak()
		if self.Owner:isInvis() then
			local trueP = math.Clamp( c - ((CurTime()-start)/dur)*(dur/fullDur), 0, 1 )
			self.drawCloak = Lerp( FrameTime()*18, self.drawCloak, trueP )
		else 
			self.drawCloak = Lerp( FrameTime()*18, self.drawCloak, c )
		end

		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawRect( ScrW()/2 - w/2, ScrH() - h - 70, w, h )

		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawRect( ScrW()/2 - w/2, ScrH() - h - 70, w*self.drawCloak+1, h )
	end
end 