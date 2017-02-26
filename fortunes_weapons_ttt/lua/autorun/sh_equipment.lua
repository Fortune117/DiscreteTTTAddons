
function getEquipmentNumber()
	return 2^(#EquipmentItems[ ROLE_DETECTIVE ] + #EquipmentItems[ ROLE_TRAITOR ] )
end 

hook.Add("InitPostEntity", "InitializeCustomTTTItems", function() 

	if !EquipmentItems then return end 
	EQUIP_EYES = getEquipmentNumber()

	local tbl = {
		id = EQUIP_EYES,
		type = "item_passive",
		material = "vgui/ttt/icon_armor",
		name = "Cybernetic Eyes",
		desc = "Allows the user to see invisible traitors,\ntrip mines and IED targets.\nAlso gives a 35% accuracy boost."
	}

    table.insert(EquipmentItems[ROLE_DETECTIVE], tbl)

    EQUIP_LEGS = getEquipmentNumber()

	local tbl = { 
		id = EQUIP_LEGS,
		type = "item_passive",
		material = "vgui/ttt/icon_armor",
		name = "Cybernetic Legs",
		desc = "Increases run speed by 50%."
	}

    table.insert(EquipmentItems[ROLE_DETECTIVE], tbl)

    EQUIP_TESLASHIELD = getEquipmentNumber()

	local tbl = { 
		id = EQUIP_TESLASHIELD,
		type = "item_passive",
		material = "vgui/ttt/icon_armor",
		name = "Tesla Shield",
		desc = "The tesla coil will not target you."
	}

    table.insert(EquipmentItems[ROLE_TRAITOR], tbl)

end)

if SERVER then
	hook.Add( "TTTPlayerSpeed", "CyberLegs", function( ply )
		if ply:HasEquipmentItem( EQUIP_LEGS ) then 
			return 1.5
		end 
	end)
end

function cyberEyeAccuracy( ply )
	if ply:HasEquipmentItem( EQUIP_EYES ) then 
		return 0.65
	end 
end 	
hook.Add( "TTTAccuracyCheck", "cyberEyeAccuracy", cyberEyeAccuracy )

if CLIENT then 
	local drawEnts =
	{
		"ttt_slam"
	}
	local dist = 1000^2
	function cyberEyesDraw()
		local ply = LocalPlayer()

		if ply:HasEquipmentItem( EQUIP_EYES ) then  

			local tbl = {}
			for k,v in pairs( ents.GetAll() ) do

				local d = v:GetPos():DistToSqr( ply:GetPos() )
				local scale = 1 - ( d / dist ) 

				if d <= dist then 

					if table.HasValue( drawEnts, v:GetClass() ) then 
						
						halo.Add( {v}, Color( 255, 0, 255 ), 5*scale, 5*scale, 1, true, false ) 

					elseif v:IsPlayer() and v:isInvis() then 

						halo.Add( {v}, Color( 255, 0, 255 ), 5*scale, 5*scale, 1, true, false ) 

					elseif v:isIEDTarget() then 

						halo.Add( {v}, Color( 255, 0, 255 ), 5*scale, 5*scale, 1, true, false ) 

					elseif v:isCorpseTrapped() then 

						halo.Add( {v}, Color( 255, 0, 255 ), 5*scale, 5*scale, 1, true, false ) 
						
					end 

		 		end 

			end 

		end 

	end 	
	hook.Add( "PreDrawHalos", "CyberEyes", cyberEyesDraw )

	local ColorMod = {}
	ColorMod[ "$pp_colour_addr" ] 			= 0.09
	ColorMod[ "$pp_colour_addg" ] 			= 0.03
	ColorMod[ "$pp_colour_addb" ] 			= 0
	ColorMod[ "$pp_colour_brightness" ] 	= -.1
	ColorMod[ "$pp_colour_contrast" ] 		= 0.8
	ColorMod[ "$pp_colour_colour" ] 		= 1
	ColorMod[ "$pp_colour_mulr" ] 			= 1  
	ColorMod[ "$pp_colour_mulg" ] 			= 1 
	ColorMod[ "$pp_colour_mulb" ] 			= 1 

	function cyberEyeEffects()
		local ply = LocalPlayer()
		if ply:HasEquipmentItem( EQUIP_EYES ) then 
			DrawColorModify( ColorMod )
		end 
	end 
	hook.Add( "RenderScreenspaceEffects", "cyberEyeEffects", cyberEyeEffects )
end 