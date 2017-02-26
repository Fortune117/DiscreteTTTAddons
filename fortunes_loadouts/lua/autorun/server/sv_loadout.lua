
util.AddNetworkString( "SelectPrimary" )
util.AddNetworkString( "SelectSecondary" )
util.AddNetworkString( "SelectPerk" )
util.AddNetworkString( "LoadLoadout" )

net.Receive( "SelectPrimary", function( len, ply )
	local wep = net.ReadString()
	ply:SetPData( "PrimaryWeapon", wep )
end )

net.Receive( "SelectSecondary", function( len, ply )
	local wep = net.ReadString()
	ply:SetPData( "SecondaryWeapon", wep )
end )

net.Receive( "SelectPerk", function( len, ply ) -- unutilised
	local p = net.ReadString()
	ply:SetPData( "Perk", p )
end )

local function giveLoadouts()
	for k,ply in pairs( player.GetAll() ) do 

		local prim = ply:GetPData( "PrimaryWeapon", "" )
		local sec = ply:GetPData( "SecondaryWeapon", "" )
		local perk = ply:GetPData( "Perk", "" )

		if ply:Alive() and not ply:IsSpec() then 

			if weapons.Get( prim ) then 
				ply:Give( prim )
			end 

			if weapons.Get( sec ) then
				ply:Give( sec )
			end 
		end 

	end 
end 

hook.Add( "PlayerSpawn", "GiveLoadout", function( ply )
		local prim = ply:GetPData( "PrimaryWeapon", "" )
		local sec = ply:GetPData( "SecondaryWeapon", "" )
		local perk = ply:GetPData( "Perk", "" )

		if ply:Alive() and not ply:IsSpec() then 
			if weapons.Get( prim ) then 
				ply:Give( prim )
			end 

			if weapons.Get( sec ) then
				ply:Give( sec )
			end 
		end 
end)
hook.Add( "TTTBeginRound", "GiveLoadout", giveLoadouts )

hook.Add( "PlayerInitialSpawn", "LoadLoadout", function( ply )

	local prim = ply:GetPData( "PrimaryWeapon", "" )
	local sec = ply:GetPData( "SecondaryWeapon", "" )
	local perk = ply:GetPData( "Perk", "" )

	if ply:Alive() and not ply:IsSpec() then 
		local tbl = {}
		if weapons.Get( prim ) then 
			tbl[ 1 ] = prim 
		end 

		if weapons.Get( sec ) then
			tbl[ 2 ] = sec 
		end 

		net.Start( "LoadLoadout" )
			net.WriteTable( tbl )
		net.Send( ply )
	end 

end)

hook.Add( "ShowSpare1", "ShowLoadoutMenu", function(ply)
	ply:ConCommand( "loadout_menu" )
end)