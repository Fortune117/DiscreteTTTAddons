
hook.Add( "ShowSpare2", "ShowACHMenu", function(ply)
	ply:ConCommand( "ach_menu" ) -- run this command to open the menu
end)

util.AddNetworkString( "SendAchData" )
util.AddNetworkString( "CompleteChallenge" )

local PLY = FindMetaTable( "Player" )
function PLY:GiveCPoint( id, num ) -- used to give points towards a players goal

	local challenge = CHALLENGES:GetChallenge( id )
	if not challenge then return end 

	local name = challenge.name 
	local cData = self:GetPData( name, 0 )

	if num == "reset" then 
		cData = 0 
	else 
		cData = math.Clamp( cData + num, 0, challenge.goal ) 
	end 

	if cData >= challenge.goal then 
		self:OnCompleteChallenge( challenge )
	end 

	self:SetPData( name, cData )

	net.Start( "SendAchData" )
		net.WriteString( name )
		net.WriteInt( cData, 32 )
	net.Send( self )

end 

function PLY:OnCompleteChallenge( data ) -- called when a player completes a challenge, can be hooked into
	net.Start( "CompleteChallenge" )
		net.WriteTable( data )
	net.Send( self )
	hook.Call( "OnPlayerCompleteChallenge", GAMEMODE, self, data )
end 

function PLY:IsInno() -- utility function
	return self:GetRole() == ROLE_INNOCENT
end

function PLY:WasHeadshot( dmginfo ) -- utility function
	if dmginfo:IsBulletDamage() then 
		return self:LastHitGroup() == HITGROUP_HEAD
	end 
	return false 
end 

