
if SERVER then
	util.AddNetworkString( "DisableCloakViewModel" )
	util.AddNetworkString( "EnableCloakViewModel" )
	util.AddNetworkString( "SyncClientAlpha" )
	util.AddNetworkString( "DeadRingerWorldModel" )
end

invisDefault = {}
invisDefault.data = {}
invisDefault.data.flashAlpha = 255
invisDefault.data.flashTime = 0.6
invisDefault.data.canFlash = true
invisDefault.data.Material = "sprites/heatwave"
invisDefault.data.flashMaterial = "models/props_c17/fisheyelens"
invisDefault.data.cloakTime = 0
invisDefault.data.unCloakTime = 0
invisDefault.data.duration = 10
invisDefault.data.chargeTime = 10
invisDefault.data.damageReduction = 0
invisDefault.data.speedBoost = 1
invisDefault.data.cloakReduction = 0
invisDefault.data.minimumCharge = 0

local PLY = FindMetaTable( "Player" )

function PLY:setInvis( bool, data )

	if not data then
		data = invisDefault.data
	end

	local oldInvis = self.bInvis or false
	self.bInvis = bool
	self:SetNWBool( "invis", bool )
	self.bInvisThink = true
	self:SetRenderMode( RENDERMODE_TRANSALPHADD )
	self:SetCustomCollisionCheck( true )
	self.invisDelay = CurTime()
	self.canFlash = data.canFlash
	self.flashed = false
	self.flashMaterial = data.flashMaterial
	self.Material = data.Material
	self.flashTime = data.flashTime
	self.invisDR = data.damageReduction
	self.speedBoost = data.speedBoost
	self:DrawShadow( not bool )
	self:SetMaterial( "" )

	if not self.invisAlpha then
		self.invisAlpha = 255
	end


	local p
	if bool then

		self:EmitSound("cloak.wav")

		p = 1 - ( self.invisAlpha/255 )
		self.cloakStartTime = CurTime() - data.cloakTime*p
		self.cloakTime = data.cloakTime

	elseif oldInvis then

		self:EmitSound("uncloak.wav")

		p = ( self.invisAlpha/255 )
		self.cloakStartTime = CurTime() - data.unCloakTime*p
		self.cloakTime = data.unCloakTime

	end
end

function PLY:feignDeath( bool, atk, dmginfo, data )
	if not data then
		data = invisDefault.data
	end
	local oldInvis = self.bInvis or false
	self.bInvis = bool
	self:SetNWBool( "invis", bool )
	self.bInvisThink = true
	self:SetRenderMode( RENDERMODE_TRANSALPHADD )
	self:SetCustomCollisionCheck( true )
	self.invisDelay = CurTime()
	self.canFlash = data.canFlash
	self.flashed = false
	self.flashMaterial = data.flashMaterial
	self.flashTime = data.flashTime
	self.Material = data.Material
	self.invisDR = data.damageReduction
	self.speedBoost = data.speedBoost
	self:DrawShadow( not bool )
	self:SetMaterial( "" )
	if not self.invisAlpha then
		self.invisAlpha = 255
	end

	local p
	if bool then

		if SERVER then
			local rag = CORPSE.Create( self, atk, dmginfo )
			CORPSE.SetCredits( rag, 0 )
			dmginfo:ScaleDamage( 1 - data.damageReduction )
		end

		p = 1 - ( self.invisAlpha/255 )
		self.cloakStartTime = CurTime() - data.cloakTime*p
		self.cloakTime = data.cloakTime

	elseif oldInvis then

		self:EmitSound("feign.wav")

		p = ( self.invisAlpha/255 )
		self.cloakStartTime = CurTime() - data.unCloakTime*p
		self.cloakTime = data.unCloakTime

	end


end

function PLY:isCloakedFully()
	local cStart = self.cloakStartTime
	local cTime = self.cloakTime
	p = math.Clamp( (CurTime() - cStart )/cTime, 0, 1 )

	if self.bInvis and p == 1 then
		return true
	end
	return false
end

function PLY:isUnCloakedFully()

	local cStart = self.cloakStartTime
	local cTime = self.cloakTime

	if not cStart or not cTime then
		return true
	end
	p = math.Clamp( (CurTime() - cStart )/cTime, 0, 1 )

	if not self.bInvis and p == 1 then
		return true
	end

	return false

end

function PLY:isInvis()
	return self:GetNWBool( "invis", false )
end

function PLY:invisThink()
	if not self.bInvisThink then return end
	if not SERVER then return end

	local p = math.Clamp( (CurTime() - self.cloakStartTime)/self.cloakTime, 0, 1 )
	local pColor
	local vColor
	if self.flashed then
		pColor = Color( 255, 255, 255, self.flashAlpha )
		self.invisAlpha = self.flashAlpha or 150


		self:SetMaterial( self.flashMaterial )
		if self.flashDelay < CurTime() then
			self.flashed = false
			pColor = Color( 255, 255, 255, self.invisAlpha )
			self:SetMaterial( "" )
		end
	elseif self.bInvis then

		self.invisAlpha = 255*(1-p)
		pColor = Color( 255, 255, 255, self.invisAlpha )

	elseif self.invisAlpha ~= 255 then

		self.invisAlpha = 255*p
		pColor = Color( 255, 255, 255, self.invisAlpha )

	end

	if pColor then
	--	self:SetColor( pColor )
		self:SetNWFloat( "invisAlpha", self.invisAlpha )
	end

end

function PLY:flashInvis()
	self.flashed = true
	self.flashDelay = CurTime() + self.flashTime
end

function doInvisThink()
	for k,v in pairs( player.GetAll() ) do
		v:invisThink()
	end
end
hook.Add( "Think", "InvisThink", doInvisThink )

function doDamageInvisFlash( ply, dmginfo )
	if IsValid( ply ) and ply:IsPlayer() then
		local wep = ply:GetActiveWeapon()
		if ply.bInvis then
			dmginfo:ScaleDamage( 1-ply.invisDR )

			if ply.canFlash then
				ply:flashInvis()
			end
		elseif IsValid( wep ) and wep:GetClass() == "weapon_ttt_deadringer" then
			if wep:canCloak() and dmginfo:GetDamage() > 0 then
				dmginfo:ScaleDamage( 1-wep.data.damageReduction )
				if dmginfo:GetDamage() < ply:Health() then
					wep:doFeign( dmginfo:GetAttacker(), dmginfo )
				end
			end
		elseif ply:HasWeapon( "weapon_ttt_autodeadringer" ) then
			if dmginfo:GetDamage() > ply:Health() then
				dmginfo:ScaleDamage( ply:GetWeapon( "weapon_ttt_autodeadringer" ).data.damageReduction )
				if dmginfo:GetDamage() < ply:Health() then
					ply:SelectWeapon( "weapon_ttt_autodeadringer" )
					local wep = ply:GetActiveWeapon()
					wep:doFeign( dmginfo:GetAttacker(), dmginfo )
				end
			end
		end
	end
end
hook.Add( "EntityTakeDamage", "InvisDamageFlash", doDamageInvisFlash )

function invisSpeedBoost( ply )

	if ply:isInvis() then
		return ply.speedBoost
	end

end
hook.Add( "TTTPlayerSpeed", "InvisSeedBoost", invisSpeedBoost )

if SERVER then
	function resetInvisPeople()
		for k,ply in pairs( player.GetAll() ) do
			if ply:isInvis() then
				ply:setInvis( false )
				ply:feignDeath( false )
			end
		end
	end
	hook.Add( "TTTPrepareRound", "ResetInvisibility", resetInvisPeople )
end

if CLIENT then
	function preDrawInvisPlayer( ply )
		local a = ply:GetNWFloat( "invisAlpha", 255 )
		if a <= 20 and not LocalPlayer():HasEquipmentItem( EQUIP_EYES ) then
			return true
		end
	end
	hook.Add( "PrePlayerDraw", "InvisDrawing", preDrawInvisPlayer )
end

hook.Add( "PlayerSwitchWeapon", "deadRingerHack", function( ply, old, new )
	if new:GetClass() == "weapon_ttt_deadringer" then
		if SERVER then
			net.Start( "DeadRingerWorldModel" )
				net.WriteTable( { old, new } )
			net.Broadcast()
		end
		if old.GetHoldType then
			new:SetHoldType( old:GetHoldType() )
		end
	end
end )

if CLIENT then

	net.Receive( "DeadRingerWorldModel", function()
		local tbl = net.ReadTable()
		local old = tbl[ 1 ]
		local new = tbl[ 2 ]
		if IsValid( old ) and IsValid( new ) then
			new.WorldModel = old:GetWeaponWorldModel()
			new.DrawWorldModel = old.DrawWorldModel
			new.DrawWorldModelTranslucent = old.DrawWorldModelTranslucent
			new:SetHoldType( old:GetHoldType() )
		end
	end)


	local fadeTime = 1
	local tab =
	{
		["$pp_colour_addr"] = 0,
		["$pp_colour_addg"] = 0,
		["$pp_colour_addb"] = 0,
		["$pp_colour_brightness"] = 0,
		["$pp_colour_contrast"] = 1,
		["$pp_colour_colour"] = 0,
		["$pp_colour_mulr"] = 0,
		["$pp_colour_mulg"] = 0,
		["$pp_colour_mulb"] = 0
	}
	shadowWalkColor = 1
	hook.Add( "RenderScreenspaceEffects", "shadowwalkOverlay", function()
		local ply = LocalPlayer()
		if ply:isInvis() then
			shadowWalkColor = Lerp( FrameTime()*5, shadowWalkColor, 0 )
		else
			shadowWalkColor = Lerp( FrameTime()*5, shadowWalkColor, 1 )
		end
		tab[ "$pp_colour_colour" ] = shadowWalkColor
		if shadowWalkColor < 0.99 then
			DrawColorModify( tab )
		end
	end)


end
