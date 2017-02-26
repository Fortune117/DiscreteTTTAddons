
local PLY = FindMetaTable( "Player" )

function getEquipmentNumber()
	return 2^(#EquipmentItems[ ROLE_DETECTIVE ] + #EquipmentItems[ ROLE_TRAITOR ] )
end 

hook.Add("InitPostEntity", "InitializeInvisEquipment", function() 

	if !EquipmentItems then return end 
	EQUIP_WATCH = getEquipmentNumber()

	local tbl = {
		id = EQUIP_WATCH,
		type = "Inviswatch",
		material = "vgui/ttt/icon_armor",
		name = "Inviswatch",
		desc = "Allows the user to go invisible."
	}

    table.insert(EquipmentItems[ROLE_TRAITOR], tbl)

end )

if SERVER then 

	function PLY:setWatch( ent )
		self:SetNWEntity( "invisWatch", ent )
	end 

	function invisWatchApply( ply, equip, is_item )
		if equip == EQUIP_WATCH then 
			local watch = ents.Create( "ttt_inviswatch" )
			watch:SetPos( ply:GetShootPos() )
			watch:SetAngles( ply:EyeAngles() )
			watch:SetMoveType( MOVETYPE_NONE )
			watch:SetCollisionGroup( COLLISION_GROUP_NONE )
			watch:SetParent( ply, ply:LookupAttachment("eyes") )
			watch:SetOwner( ply )
			watch:Spawn()
			watch:Activate()
			ply:setWatch( watch )
		end 
	end 	
	hook.Add( "TTTOrderedEquipment", "invisWatchApply", invisWatchApply )

end 

function PLY:getWatch()
	return self:GetNWEntity( "invisWatch", nil )
end 	

if CLIENT then 
	function watchViewModel( vm, ply, weapon )
		local watch = ply:getWatch()
		if IsValid( watch ) then 
			local dModel = watch.drawModel
			dModel:SetPos( EyePos() )
			dModel:SetAngles( EyeAngles() ) 
		end 
	end 
	hook.Add( "PostDrawViewModel", "watchViewModel", watchViewModel )
end 