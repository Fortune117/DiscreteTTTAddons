
if SERVER then 
	util.AddNetworkString( "EShieldData" )
	util.AddNetworkString( "UpdateShieldCharge" )
end 

local PLY = FindMetaTable( 'Player' )

function PLY:GetShieldCharge()
	return self.EnergyShield.Charge
end

function PLY:SetShieldCharge( num )
	self.EnergyShield.Charge = num
	if SERVER then 
		net.Start( "UpdateShieldCharge" )
			net.WriteInt( self.EnergyShield.Charge, 8 )
			net.WriteEntity( self )
		net.Broadcast()
	end
end

function PLY:IncrementShieldCharge()
	self:SetShieldCharge( self.EnergyShield.Charge + 1  )
end

function PLY:GetShieldMax()
	return self.EnergyShield.Max
end

function PLY:GetShieldDelay()
	return self.EnergyShield.Delay
end

function PLY:GetShieldDelayTime()
	return self.EnergyShield.DelayTime
end

function PLY:SetShieldDelay( num )
	self.EnergyShield.DelayTime = CurTime() + num
end

function PLY:GetShieldColor()
	return self.EnergyShield.Color 
end 

function PLY:ShieldShouldCharge()
	return self:GetShieldCharge() < self:GetShieldMax() and self:GetShieldDelayTime() < CurTime()
end

function PLY:SetUpEnergyShield( max, delay, color )
	self.EnergyShield = {}
	self.EnergyShield.Max = max
	self.EnergyShield.Delay = delay 
	self.EnergyShield.DelayTime = 0
	self.EnergyShield.Charge = 0
	self.EnergyShield.Color = color or Color( 255, 70, 200, 180 )
	self:SetBloodColor( DONT_BLEED )

	net.Start( "EShieldData" )
		net.WriteTable( self.EnergyShield )
		net.WriteEntity( self )
	net.Broadcast()
end

function PLY:StartShieldBreakSound( v, p )
	if not self.shieldbreaksound then
		self.shieldbreaksound = CreateSound( self, "ambient/energy/electric_loop.wav" )
		self.shieldbreaksound:PlayEx( v, p )
	else
		self.shieldbreaksound:PlayEx( v, p )
	end
end

function PLY:ShieldBreakSoundPlaying()
	return self.shieldbreaksound and self.shieldbreaksound:IsPlaying()
end

function PLY:StopShieldBreakSound()
	if self.shieldbreaksound then 
		self.shieldbreaksound:Stop()
	end 
end

function PLY:ShieldChargeSoundPlaying()
	return self.shieldchargesound and self.shieldchargesound:IsPlaying()
end

function PLY:StartShieldChargeSound( v, p )
	if not self.shieldchargesound then
		self.shieldchargesound = CreateSound( self, "ambient/energy/force_field_loop1.wav" )
		self.shieldchargesound:PlayEx( v, p )
	else
		self.shieldchargesound:PlayEx( v, p )
	end
end

function PLY:StopShieldChargeSound()
	if self.shieldchargesound then 
		self.shieldchargesound:FadeOut( 2 )
	end 
end

local energysounds =
{
	"ambient/energy/weld1.wav",
	"ambient/energy/weld2.wav",
	"npc/roller/mine/rmine_explode_shock1.wav"
}
function PLY:DoEnergyDamageCheck( dmginfo )
	local chrg = self:GetShieldCharge()
	if chrg > 0 then

		local new_damage = dmginfo:GetDamage() - chrg
		local old_damage = dmginfo:GetDamage()
		dmginfo:SetDamage( new_damage )

		local new_chrg = math.max( math.Round( chrg-old_damage ), 0)

		if new_chrg == 0 then
			self:EmitSound( "ambient/energy/zap9.wav" )
			self:StartShieldBreakSound( 0.5, 100 )
		else
			self:EmitSound( tostring( table.Random( energysounds ) ), 75, 100, 0.5 )
		end

		self:SetShieldCharge( new_chrg )


	end
	self:SetShieldDelay( self:GetShieldDelay() )
 return dmginfo
end

function PLY:ShieldThink()
	if self:ShieldShouldCharge() then
		if self:ShieldBreakSoundPlaying() then
			self:StopShieldBreakSound()
			self:StartShieldChargeSound( 0.5, 100 )
		end
		self:IncrementShieldCharge()
		self:SetShieldDelay( 0.25 )
	end

	if self:GetShieldCharge() == self:GetShieldMax() then
		if self:ShieldChargeSoundPlaying() then
			self:StopShieldChargeSound()
		end
	end
end

function PLY:HasEnergyShield() 
	if self.EnergyShield != nil then
		return true
	end
	return false
end

function PLY:StripEnergyShield()
	self.EnergyShield = nil
	self:StopShieldChargeSound()
	self:StopShieldBreakSound()
	if SERVER then 
		self:SetBloodColor( BLOOD_COLOR_RED )
		net.Start( "EShieldData" )
			net.WriteTable( {} )
		net.Send( self )
	end 
end

hook.Add( "EntityTakeDamage", "EnergyShield", function( ply, dmginfo )
	if IsValid( ply ) and ply:IsPlayer() then
		if ply:HasEnergyShield() then
			dmginfo = ply:DoEnergyDamageCheck( dmginfo ) 
		end
	end
end)

hook.Add( "PostPlayerDeath", "StripEnergyShield", function( ply )
	if ply:HasEnergyShield() then
		ply:StripEnergyShield()
	end
end)

hook.Add( "TTTPrepareRound", "StripEnergyShield", function()
	for k,ply in pairs( player.GetAll() ) do 
		if ply:HasEnergyShield() then
			ply:StripEnergyShield()
		end
	end 
end)

hook.Add( "PlayerDisconnected", "StripEnergyShield", function( ply )
	if ply:HasEnergyShield() then
		ply:StripEnergyShield()
	end
end)

if SERVER then
	local p = pairs 
	local plys = player.GetAll 
	hook.Add( "Think", "EnergyShieldThink", function()
		for k,v in p( plys() ) do
			if v:HasEnergyShield() then
				v:ShieldThink()
			end
		end
	end)
end

if CLIENT then 

	net.Receive( "EShieldData", function( len )

		local tbl = net.ReadTable()
		if tbl == {} then 
			tbl = nil 
		end 
		local ply = net.ReadEntity()

		ply.EnergyShield = tbl 

	end)

	net.Receive( "UpdateShieldCharge", function( len )

		local charge = net.ReadInt( 8 )
		local ply = net.ReadEntity()

		if ply.EnergyShield then 
			ply:SetShieldCharge( charge )
		end

	end)

	local blackList = 
	{
		"weapon_ttt_teleport",
		"weapon_ttt_unarmed",
		"weapon_ttt_binoculars",
		"weapon_ttt_defuser",
		"weapon_ttt_radio",
		"weapon_ttt_decoy",
		"weapon_ttt_health_station",
		"weapon_ttt_wtester"
	}
	local playerGet = player.GetAll
	local pairs = pairs 
	local check = 800^2
	local halo = halo 
	local math = math 
	function drawShieldHalos()
		local ply = LocalPlayer()
		local shouldDraw = GetConVar( "ttt_drawshields" ):GetBool()
		if not shouldDraw then return end 
		for k,v in pairs( playerGet() ) do
			if v:HasEnergyShield() and v:Alive() and not v:isInvis() and not (v.IsGhost and v:IsGhost()) then
				local dist = ply:GetPos():DistToSqr( v:GetPos() )
				if dist <= check then 
					local scale = 1 - ( dist / check ) 
					p = v:GetShieldCharge()/v:GetShieldMax()
					local eclr = v:GetShieldColor()
					local clr = Color( eclr.r*(1-p), eclr.g*p, eclr.b*p, eclr.a*p )
					local blur = 1*(2-p) + math.Rand( -0.3, 0.3 )
					local wep = v:GetActiveWeapon()

					local sz = blur*scale
					if v == ply and IsValid( wep ) then 
						local vm = v:GetViewModel( )
						local wFOV = wep.ViewModelFOV 
						local fov = wFOV + 14
						if IsValid( vm ) and not table.HasValue( blackList, wep:GetClass() ) then 
							halo.Add( {vm}, clr, sz, sz, 1, true, true, fov )
						end 
					end
					halo.Add( {v}, clr, sz, sz, 1, true, false )
				end 
			end 
		end
	end 
	hook.Add( "PreDrawHalos", "EShieldHalo", drawShieldHalos )
end 