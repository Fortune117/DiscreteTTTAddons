
local PLY = FindMetaTable( "Player" )

if SERVER then 
	util.AddNetworkString( "specMissile" )
	util.AddNetworkString( "syncMissileAngles" )

	local function missilePVS( ply )
		local mis = ply:GetNWEntity( "specMissile" )
		if IsValid( mis ) then 
			AddOriginToPVS( mis:GetPos() )
		end 
	end
	hook.Add( "SetupPlayerVisibility", "AddMissileCamera", missilePVS )
end 

if CLIENT then 
	local ColorMod = {}
	ColorMod[ "$pp_colour_addr" ] 			= 0.35
	ColorMod[ "$pp_colour_addg" ] 			= 0.15
	ColorMod[ "$pp_colour_addb" ] 			= 0
	ColorMod[ "$pp_colour_brightness" ] 	= -.2
	ColorMod[ "$pp_colour_contrast" ] 		= 1
	ColorMod[ "$pp_colour_colour" ] 		= 1
	ColorMod[ "$pp_colour_mulr" ] 			= 1  
	ColorMod[ "$pp_colour_mulg" ] 			= 1 
	ColorMod[ "$pp_colour_mulb" ] 			= 1 

	hook.Add( "CalcView", "specMissile", function( ply, pos, ang, fov, znear, zfar )
		local ent = ply:GetNWEntity( "specMissile" )
		if IsValid( ent ) then 
			local view = {}
			view.origin 		= ent:GetPos()
			view.angles 		= ang
			view.fov 			= fov 
			view.znear			= znear
			view.zfar			= zfar
			view.drawviewer		= false
			return view 
		end
	end)

	local Colo
	local missileOverlayColor = Color( 255, 102, 0, 80 )
	function missileHUD()
		local ply = LocalPlayer()
		local mis = ply:GetNWEntity( "specMissile" )
		if IsValid( mis ) then 
			DrawColorModify( ColorMod )
		end 
	end 
	hook.Add( "RenderScreenspaceEffects", "missileHUD", missileHUD )

	hook.Add( "ShouldDrawLocalPlayer", "missileDraw", function()
		local ply = LocalPlayer()
		local mis = ply:GetNWEntity( "specMissile" )
		if IsValid( mis ) then 
			return true 
		end 
	end )
end 