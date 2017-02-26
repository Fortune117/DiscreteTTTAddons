
local PLY = FindMetaTable( "Player" )

function PLY:getData( str, def )

	if not self.netData then 
		self.netData = {}
	end 

	local n = self.netData[ str ]
	if n then 
		return n 
	else 
		return def or 0 
	end 

end 

--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
-- This is where you determine whether or not the player should have access to the jumpack
-- SuperAdmin only by default
function PLY:getCyberUpgrade()
	return self:IsSuperAdmin()
end 
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------
--------------------------------------------------------

-- booster stats. modify to your desire
booster = {}
booster.power = 1150 -- how powerful the thrust it
booster.duration = 0.45 -- how long the thrust lasts for
booster.chargeDelay = 0.4 -- how long before the boost begins charging after use
booster.chargeTime = 1 -- how long it takes to fully charge
booster.canBoostVal = 0.15 -- percentage of boost you need to be able to use it. 15% by default.

function PLY:isBoosting()
	return self:GetNWBool( "boosting", false )
end 

function PLY:getBoostDur()
	return self:GetNWFloat( "boostDur", 0 )
end 

function PLY:getBoostStartTime()
	return self:GetNWFloat( "boostStart", 0 )
end 
function PLY:getBoostEndTime()
	return self:GetNWFloat( "boostEnd", 0 ) 
end 

function PLY:getBoostPercentage()
	if self:isBoosting() then 
		local start = self:getBoostStartTime()
		local dec = CurTime() - start 
		local p = math.Clamp( (self:getBoostDur() - dec)/booster.duration, 0, 1 )
		return p
	else 
		return self:getBoostDur()/booster.duration 
	end 	
end 

function PLY:canBoost()
	return self:getBoostPercentage() > booster.canBoostVal
end

function dataSetUp( ply )
	ply.netData = {}
	net.Start( "setUpData" )
	net.Send( ply )
end 
hook.Add( "PlayerAuthed", "dataSetUp", dataSetUp )
