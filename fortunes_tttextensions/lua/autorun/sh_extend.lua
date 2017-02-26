
local PLY = FindMetaTable( "Player" )

-- made to support ulx.
local groups =
{
	["superadmin"] = { "Owner", Color( 0, 150, 225 ) },
	["developer"] = { "Developer", Color( 0, 150, 225 ) },
	["admin"] = { "Admin", Color( 0, 102, 255 ) },
	["operator"] = { "Moderator", Color( 204, 102, 0 ) },
	["respected"] = { "Respected", Color( 0, 255, 0 ) },
	["guest"] = { "Guest", Color( 255, 255, 255 ) },
	["user"] = { "Guest", Color( 255, 255, 255 ) },
	["default"] = {"unregistered group", Color( 255, 255, 255 ) }
}
function PLY:getGroup()

	local g = self:GetUserGroup()
	local title = self:getTitle()
	local titlecolor = self:getTitleColor() 

	local name
	local clr 

	if groups[ g ] then 
		name,clr = groups[ g ][ 1 ],groups[ g ][ 2 ]
	else 
		name,clr = groups[ "default" ][ 1 ],groups[ "default"][ 2 ]
	end 

	if title ~= "notitle" then 
		name = title 
	end 

	if titlecolor ~=  nil then 
		clr = titlecolor 
	end 

	return name,clr

end  

hook.Add( "TTTScoreboardColumns", "DisplayRanks", function( pnl )

	pnl:AddColumn( "", function( ply, label ) -- honestly don't remember why this is here. remove at your own peril
		return ""
	end, 1 ) 

	/* -- Uncomment to enable ranks/titles in the scoreboard
	pnl:AddColumn( "Rank", function( ply, label ) 
		local n = ply:GetRankNumber()
		local nP = n/(#RANKS.LIST.Player)
		label:SetTextColor( Color( 50*( 1 - nP ), 255 - 153*nP, 100 + 155*nP ) )
		return ply:GetRank()
	end, 140 ) 


	pnl:AddColumn( "Title", function( ply, label ) 

		local name,clr = ply:getGroup()
		label:SetTextColor( clr )
		return name

	end, 120 ) 
	*/

end )