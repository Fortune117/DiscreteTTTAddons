
local PLY = FindMetaTable( "Player" )

util.AddNetworkString( "syncData" )
util.AddNetworkString( "setUpData" )

function PLY:setData( str, n )
	net.Start( "syncData" )
		net.WriteString( str )
		net.WriteFloat( n )
	net.Send( self )
	self.netData[ str ] = n 
end 

booster.hooks = 
{

	[ "onSpawn" ] = function( ply )
		ply:setBoostDur( booster.duration )
		ply.nextCharge = 0 
	end,

	[ "keyPress" ] =
	function( ply, key )
		if not ply:IsOnGround() then 
			if key == IN_JUMP and ply:canBoost() then 
				ply:setBoosting( true )
			end 
		end 
	end, 


	[ "keyRelease" ] =
	function( ply, key )
		if key == IN_JUMP and ply:isBoosting() then 
			ply:setBoosting( false )
		end 
	end, 

	[ "think" ] =
	function( ply )
		if ply:isBoosting() then 
			local p = ply:getBoostPercentage()
			if p <= 0 then 
				ply:setBoosting( false )
			end 
		elseif CurTime() > ply:getNextCharge() then 
			local old = ply.oldBoostDur or 0 
			local p = (old/booster.duration) + (CurTime()-(ply:getNextCharge()))/booster.chargeTime
			ply:setBoostDur( math.min( p*booster.duration, booster.duration ) )
		end 
	end,

	["onMove" ] =
	function( ply, mv )

		if ply:isBoosting() then

			local ang = mv:GetMoveAngles()
			local pos = mv:GetOrigin()
			local vel = mv:GetVelocity()

			local power = booster.power*FrameTime()
			local dirBoost = power*(ply:getBoostPercentage()*0.6)

			vel = vel + ply:GetUp()*power

			if mv:KeyDown( IN_MOVELEFT ) then 
				vel = vel + ang:Right()*-dirBoost
			end 

			if mv:KeyDown( IN_MOVERIGHT ) then 
				vel = vel + ang:Right()*dirBoost 
			end 

			if mv:KeyDown( IN_FORWARD ) then 
				vel = vel + ply:GetForward()*dirBoost 
			end 

			if mv:KeyDown( IN_BACK ) then
				vel = vel + ply:GetForward()*-dirBoost
			end 

			pos = pos + vel 

			mv:SetVelocity( vel )

			return true 
		end 

		return false 

	end 

}

function PLY:setBoostStartTime( n )
	self:SetNWFloat( "boostStart", n )
end 


function PLY:setBoostEndTime( n )
	self:SetNWFloat( "boostEnd", n )
end 

function PLY:getNextCharge()
	return self.nextCharge or 0
end 

function PLY:setBoosting( b ) 
	if b and not self:isBoosting() then 
		self:setBoostStartTime( CurTime() )
		self:boostTrail()
	elseif self:isBoosting() then
		local p = self:getBoostPercentage()
		self:setBoostDur( booster.duration*p )
		self:setBoostEndTime( CurTime() )
		self.nextCharge = CurTime() + booster.chargeDelay
		self.oldBoostDur = self:getBoostDur()
		self:removeTrail()
	end
	self:SetNWBool( "boosting", b )
end 


function PLY:setBoostDur( n )
	self:SetNWFloat( "boostDur", n )
end 

function PLY:boostTrail()
	if not (self.IsGhost and self:IsGhost()) and not self:isInvis() then 
		local startWidth = 5
		local endWidth = 1
		local lifeTime = 0.8
		self.trail = util.SpriteTrail( self, 0, Color( 0, 102, 255, 255 ), true, startWidth, endWidth, lifeTime, 1 / ( startWidth + endWidth ) * 0.5, "trails/plasma.vmt" )
		self:EmitSound( Sound( "player/suit_sprint.wav" ), 75, 100, 0.5 )
	end 
end 

function PLY:removeTrail()
	if IsValid( self.trail ) then 
		self.trail:Remove()
	end 
end 

function cyberKeyCheck( ply, key )
	local up = ply:getCyberUpgrade()
	if up then 
		local f = booster.hooks[ "keyPress" ]
		if f then 
			f( ply, key )
		end 
	end 
end 
hook.Add( "KeyPress", "cyberKeyCheck", cyberKeyCheck )

function cyberKeyReleaseCheck( ply, key )
	local up = ply:getCyberUpgrade()
	if up then 
		local f = booster.hooks[ "keyRelease" ]
		if f then 
			f( ply, key )
		end 
	end 
end 
hook.Add( "KeyRelease", "cyberKeyReleaseCheck", cyberKeyReleaseCheck )

function cyberThink()
	for k,ply in pairs( player.GetAll() ) do 
		if ply:Alive() and not ply:IsSpec() or (ply.IsGhost and ply:IsGhost()) then 
			local up = ply:getCyberUpgrade()
			if up then 
				local f = booster.hooks[ "think" ]
				if f then 
					f( ply )
				end 
			end 
		end 	
	end 
end 
hook.Add( "Think", "cyberThink", cyberThink )

function cyberSpawn( ply )
	local up = ply:getCyberUpgrade()
	if up then 
		local f = booster.hooks[ "onSpawn" ]
		if f then 
			f( ply )
		end 
	end 
end 
hook.Add( "PlayerSpawn", "playerSpawn", cyberSpawn )

function cyberDeath( ply )
	local up = ply:getCyberUpgrade()
	if up then 
		local f = booster.hooks[ "onDeath" ]
		if f then 
			f( ply )
		end 
	end
end 
hook.Add( "DoPlayerDeath", "playerDeath", cyberDeath )

function cyberMoveSpeed( ply )
	local up = ply:getCyberUpgrade()
	if up then 
		local f = booster.hooks[ "moveSpeed" ]
		if f then 
			return f( ply )
		end 
	end 
end 
hook.Add( "TTTPlayerSpeed", "cyberSpeed", cyberMoveSpeed )

function cyberMove( ply, mv )
	local up = ply:getCyberUpgrade()
	if up then 
		local f = booster.hooks[ "onMove" ]
		if f then 
			return f( ply, mv )
		end 
	end 
end 
hook.Add( "SetupMove", "cyberMove", cyberMove )










