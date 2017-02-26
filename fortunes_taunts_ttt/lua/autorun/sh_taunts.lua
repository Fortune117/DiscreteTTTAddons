
local PLY = FindMetaTable( "Player" )

-- This is where taunts are defined.
-- Fairly self explanitory
/*
Example:
TAUNTS.Laugh =
{
	name = "Laugh", -- name displayed on taunt menu
	anim = ACT_GMOD_TAUNT_LAUGH, -- action the player will do.
	sound = Sound( "taunts/laugh.mp3" ) -- sound to be played when used.
}
*/
TAUNTS = {}
TAUNTS.Laugh =
{
	name = "Laugh",
	anim = ACT_GMOD_TAUNT_LAUGH,
	sound = Sound( "taunts/laugh.mp3" )
}
TAUNTS.Dance =
{
	name = "Dance",
	anim = ACT_GMOD_TAUNT_DANCE,
	sound = Sound( "taunts/dance.mp3" )
}
TAUNTS.Wave =
{
	name = "Wave",
	anim = ACT_GMOD_GESTURE_WAVE,
	sound = { Sound( "vo/npc/male01/hellodrfm01.wav" ), Sound( "vo/npc/male01/hellodrfm02.wav" ) }
}
TAUNTS.Sexy =
{
	name = "Sexy Dance",
	anim = ACT_GMOD_TAUNT_MUSCLE,
	sound = Sound( "taunts/sexy.mp3" )
}
TAUNTS.Robot =
{
	name = "Robot",
	anim = ACT_GMOD_TAUNT_ROBOT,
	sound = Sound( "taunts/dance2.mp3" )
}
TAUNTS.Cheer =
{
	name = "Cheer",
	anim = ACT_GMOD_TAUNT_CHEER,
	sound = Sound( "taunts/dance2.mp3" )
}




if SERVER then
	util.AddNetworkString( "TauntAnimationBroadcast" )
	util.AddNetworkString( "RequestTaunt" )
	function AddDir(dir) // recursively adds everything in a directory to be downloaded by client  
		local files, directories = file.Find( dir.."/*", "GAME")
		for k,v in pairs( files ) do
			resource.AddFile(dir.."/"..v)
			print( "[FAST DL] Adding "..v.." to FastDL.")
		end

		for k,v in pairs( directories ) do
			AddDir( dir.."/"..v )
		end 
	end

	AddDir( "sound/taunts" )

	hook.Add( "PlayerSpawn", "OverwriteZoom", function( ply )
		ply:SetCanZoom( false )
		ply:StopTaunting()
	end)

	local t_think_delay = 0.05
	local t_think_time = CurTime()
	hook.Add( "Think", "TauntThink", function()
		if CurTime() > t_think_time then
			for k,ply in pairs( player.GetAll() ) do
				if ply:IsTaunting() then
					if not ply:Alive() or ply:GetTauntTime() <= CurTime() then
						ply:StopTaunting()
					end
				end
			end
			t_think_time = CurTime() + t_think_delay 
		end
	end)

	net.Receive( "RequestTaunt", function( len, ply )
		local taunt = net.ReadString()
		local t = TAUNTS[ taunt ]
		if t then
			if ply:CanTaunt() then
				local seq = ply:SelectWeightedSequence( t.anim )
				local len = ply:SequenceDuration( seq )
				t.time = len + 0.2
				ply:StartTaunt( t )
			end
		end
	end)

	function PLY:StartTaunt( taunt_data )
		local snd 
		if istable( taunt_data.sound ) then
			snd = tostring( table.Random( taunt_data.sound ) )
		else
		    snd = taunt_data.sound
		end
		if not snd then
			ErrorNoHalt( "[TAUNTS] Taunt had no sound!")
			snd = ""
		end
		if not taunt_data.anim then
			ErrorNoHalt( "[TAUNTS] Taunt had no animation!")
		end
		self:EmitSound( snd )
		self:SetTauntTime( taunt_data.time )
		self:SetNWBool( "Taunting", true )
		self:Freeze( true )
		net.Start( "TauntAnimationBroadcast" )
			net.WriteEntity( self )
			net.WriteInt( taunt_data.anim, 32 )
		net.Broadcast()
	end

	function PLY:StopTaunting()
		self:SetNWBool( "Taunting", false )
		self:Freeze( false )
	end

	function PLY:SetTauntTime( time )
		self.TauntTime = CurTime() + time
	end

	function PLY:GetTauntTime()
		return self.TauntTime 
	end

	function PLY:PS_ItemsEquippedFromCategory( cat_name )

		local items = {}
		for item_id, item in pairs(self.PS_Items) do
			local ITEM = PS.Items[item_id]
			if ITEM.Category == cat_name and item.Equipped then
				items[ #items+1 ] = ITEM 
			end
		end

		return items
	end

	function PLY:GetTauntData()
		local taunt = self:PS_ItemsEquippedFromCategory( "Taunts" )[ 1 ]
		if taunt then
			local t_data = {}
			t_data.anim = taunt.tdata.Animation
			local s 
			if istable( taunt.tdata.Sound ) then 
				s = table.Random( taunt.tdata.Sound )
			else 
				s = taunt.tdata.Sound 
			end 
			t_data.sound = s
			local seq = self:SelectWeightedSequence( taunt.tdata.Animation )
			local len = self:SequenceDuration( seq )
			t_data.time = len + 0.2
			return t_data
		end
		return false  
	end
end

function PLY:IsTaunting()
	return self:GetNWBool( "Taunting", false )
end

function PLY:CanTaunt()
	if self:IsTaunting() then return false end
	if not self:Alive() then return false end 
	if self:IsSpec() then return false end 
	return true 
end

function GetTauntTable()
	local t = {}
	for k,v in pairs( TAUNTS ) do
		t[ #t+1 ] = { tdata = v, key = k } 
	end
	return t
end

if CLIENT then

	local tColors = {}
	tColors.DGBlue = Color( 0, 102, 255, 255 )
	tColors.Black = Color( 0, 0, 0, 180 )
	tColors.DarkGrey = Color( 22, 22, 22, 230 )
	tColors.Grey = Color( 33, 33, 33, 250 )
	tColors.DGRed = Color( 255, 60, 60, 250 )
	tColors.DGYellow = Color( 255, 150, 23, 250 )
	tColors.TextBlack = Color( 0, 0, 0, 255 )
	tColors.White = Color( 235, 235, 235, 255 )

	function math.Rad2Deg( num )
		return math.deg( num )
	end 

	local DrawText = surface.DrawText
	local SetTextColor = surface.SetTextColor
	local SetFont = surface.SetFont
	local SetTextPos = surface.SetTextPos
	local PopModelMatrix = cam.PopModelMatrix
	local PushModelMatrix = cam.PushModelMatrix

	local function drawRotatedText(text, x, y, xScale, yScale, angle, centered)
		local matrix = Matrix()
		local matrixAngle = Angle(0, 0, 0)
		local matrixScale = Vector(0, 0, 0)
		local matrixTranslation = Vector(0, 0, 0)

		matrixAngle.y = math.floor( angle )
		matrix:SetAngles(matrixAngle)
		
		matrixTranslation.x = math.floor( x )
		matrixTranslation.y = math.floor( y )

		if centered	then
			local sizeX, sizeY = surface.GetTextSize( text )
			sizeX = sizeX * xScale
			sizeY = sizeY * yScale

			matrixTranslation.x = math.floor( matrixTranslation.x - math.sin( math.rad( -angle + 90 ) ) * sizeX / 2 - math.sin( math.rad( -angle ) ) * sizeY / 2)
			matrixTranslation.y = math.floor( matrixTranslation.y - math.cos( math.rad( -angle + 90 ) ) * sizeX / 2 - math.cos( math.rad( -angle ) ) * sizeY / 2)
		end
		matrix:SetTranslation(matrixTranslation)

		matrixScale.x = xScale
		matrixScale.y = yScale
		matrix:Scale(matrixScale)
		
		SetTextPos(0, 0)
		
		PushModelMatrix(matrix)
			DrawText(text)
		PopModelMatrix()
	end

	net.Receive( "TauntAnimationBroadcast", function() 
		local ply = net.ReadEntity()
		local anim = net.ReadInt( 32 )
		ply:DoAnimationEvent( anim )
	end )

	hook.Add( "CalcView", "Taunting Stuff", function(ply, origin, angles, fov )
		ply.view = {} 
		ply.view.origin 		= origin
		ply.view.angles			= angles
		ply.view.fov 			= fov
		ply.view.znear			= znear
		ply.view.zfar			= zfar
		ply.view.drawviewer		= false
		
		local tr = util.QuickTrace( origin, ply:GetAimVector()*-110, player.GetAll() )
		
		if ply:IsTaunting() then
			ply.view.angles = ply.tauntangles
			ply.view.origin = ply.tauntpos
			ply.view.fov    = fov
		
			local wep = ply:GetActiveWeapon()
			if IsValid(wep) then
				local func = wep.GetViewModelPosition
				if func then
					ply.view.vm_origin,  ply.view.vm_angles = func( wep, origin*1, angles*1 )
				end

				func = wep.CalcView
				if func then
					ply.view.origin, view.angles, view.fov = func( wep, ply, origin*1, angles*1, fov )
				end

			end

		   return ply.view
		end
		
	end)


	hook.Add("InputMouseApply", "TauntingCamera", function(cmd, x, y, angle)
		local ply = LocalPlayer()
		if ply:IsTaunting() then
		
			if not ply.view.angles then return end
			
			local frameTime   = FrameTime()
			local ply         = LocalPlayer()
			local pitchFactor = GetConVarNumber("m_pitch")
			local yawFactor   = GetConVarNumber("m_yaw")
			local sensitivity = 3
			
			local tr = util.QuickTrace( ply:GetPos() + Vector( 0, 0, 40 ), ply.view.angles:Forward() * -140 , player.GetAll() )

			ply.tauntangles = Angle(math.Clamp((ply.view.angles.p + y * pitchFactor * sensitivity),-40,90), (ply.view.angles.y - x * yawFactor * sensitivity), 0 )
			ply.tauntpos = LerpVector( FrameTime()*20, ply.tauntpos or tr.HitPos, tr.HitPos )
			return true
			
		end
	end)

	hook.Add("ShouldDrawLocalPlayer", "TauntDrawCheck", function( ply )
		if ply:IsTaunting() then
			return true 
		end
	end)

	TauntMenu = false 
	TauntMenuSize = 0
	TauntMenuAimSize = ScrH()*0.25
	TauntSelected = ""

	hook.Add( "PlayerBindPress", "CloseTauntMenu", function( ply, bind, bool )

		if bool and bind == "taunt" and not TauntMenu and ply:CanTaunt() then 
			TauntMenu = true 
			gui.EnableScreenClicker( TauntMenu ) 
		elseif bind == "taunt" and TauntMenu then
			TauntMenu = false

			local w, h = ScrW(),ScrH()
			local mx, my = gui.MousePos()

			gui.EnableScreenClicker( TauntMenu )

			if math.Distance( mx, my, w/2, h/2 ) > TauntMenuAimSize then 
				net.Start( "RequestTaunt" )
					net.WriteString( TauntSelected )
				net.SendToServer()
			end 
		end
	end)

	hook.Add( "Think", "TauntMenuThink", function()
		if TauntMenu then
			TauntMenuSize = Lerp( FrameTime()*15, TauntMenuSize, TauntMenuAimSize )
		else
			TauntMenuSize = Lerp( FrameTime()*15, TauntMenuSize, 0 ) 
		end
	end)

	local cos = math.cos 
	local sin = math.sin 
	local rad = math.rad
	local drawpoly = surface.DrawPoly
	local deg = 360
	local gap = 0.5
	local comp = 360/deg
	local b_Incr = 30
	hook.Add( "HUDPaint", "DrawTauntMenu", function()

		local w,h = ScrW(), ScrH()
		local r = TauntMenuSize
		local r2 = r*0.7
		local _Taunts = GetTauntTable()
		local nT = #_Taunts
		local incr = deg/nT
		for k,t in pairs( _Taunts ) do

			local i = (k-1)*incr
			local mx,my = gui.MousePos()
			local mB = (math.deg( math.atan2( w/2 - mx, h/2 - my ) ) - 90)*-1 + incr

			if mB < 0 then 
				mB = 330 + mB*-1
			end 

			if not t.tdata.r then 
				t.tdata.r = r 
				t.tdata.r2 = r
				t.tdata.c = { 0, 0, 0, 230 } 
			end 

			--drawRotatedText(i, w/2 - r*cos( rad( i-gap ) ), h/2 - r*sin( rad( i-gap ) ), 1, 1, 0, false )

			local ftime = FrameTime()*20
			if mB > i and mB < i + incr and math.Distance( mx, my, w/2, h/2 ) > r and TauntMenu then
				local g = t.tdata.c[ 2 ]
				local b = t.tdata.c[ 3 ]
				t.tdata.c[ 2 ] = Lerp( ftime, g, 102 )
				t.tdata.c[ 3 ] = Lerp( ftime, b, 255 )
				surface.SetDrawColor( Color( 0, g, b, 245 ) )
				t.tdata.r = Lerp( ftime, t.tdata.r, r+b_Incr )
				t.tdata.r2 = Lerp( ftime, t.tdata.r2, r2+b_Incr )
				TauntSelected = t.key 
			else 
				local g = t.tdata.c[ 2 ]
				local b = t.tdata.c[ 3 ]
				t.tdata.c[ 2 ] = Lerp( ftime, g, 0 )
				t.tdata.c[ 3 ] = Lerp( ftime, b, 0 )
				surface.SetDrawColor( Color( 0, g, b, 230 ) )
				t.tdata.r = Lerp( ftime, t.tdata.r, r )
				t.tdata.r2 = Lerp( ftime, t.tdata.r2, r2 )
			end 

			local poly = {}
			local x = w/2 - t.tdata.r*cos( rad( i - gap ) )
			local y = h/2 - t.tdata.r*sin( rad( i - gap ) ) 
			local x2 = w/2 - t.tdata.r*cos( rad( i-incr+gap ) )
			local y2 = h/2 - t.tdata.r*sin( rad( i-incr+gap ) )
			local x3 = w/2 - t.tdata.r2*cos( rad( i - gap ) )
			local y3 = h/2 - t.tdata.r2*sin( rad( i - gap ) ) 
			local x4 = w/2 - t.tdata.r2*cos( rad( i-incr+gap ) )
			local y4 = h/2 - t.tdata.r2*sin( rad( i-incr+gap ) )
			poly[ #poly+1 ] = { x = x3, y = y3 }
			poly[ #poly+1 ] = { x = x, y = y }
			poly[ #poly+1 ] = { x = x2, y = y2 }
			poly[ #poly+1 ] = { x = x4, y = y4 }

			drawpoly( poly )

			local r3 = t.tdata.r*0.75
			if r >= TauntMenuAimSize*0.9 then 
				local tAng = Vector( poly[4].x-poly[1].x ,poly[4].y-poly[1].y ,0 ):Angle().y %360 - 180		
				tAng = math.NormalizeAngle( tAng - 180 )
				if tAng >= 89 or tAng <= -89 then tAng = tAng - 180 end

				local tx = w/2 - r3*cos( rad( i - incr/2 ) )
				local ty = h/2 - r3*sin( rad( i - incr/2 ) ) 
				surface.SetFont( "HiddenHUDSS" )
				surface.SetDrawColor( Color( 255, 255, 255, 255 ) )	 
				drawRotatedText(t.tdata.name, tx, ty, 1, 1, tAng, true )
			end 

		end
		if not TauntMenu then
			TauntSelected = ""
		end
	end)
end 
		