
if CLIENT then

	surface.CreateFont( "HUD_Smooth", { font = "Trebuchet18", size = 24, weight = 500, antialias = true } )
	surface.CreateFont( "HUD_SmoothS", { font = "Trebuchet18", size = 18, weight = 500, antialias = true } )
	function draw.AAText( text, font, x, y, color, align )

		draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,math.min(color.a,120)), align )
		draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,math.min(color.a,50)), align )
		draw.SimpleText( text, font, x+2, y+1, Color(0,0,0,255), align )
		draw.SimpleText( text, font, x, y, color, align )

	end

	local medal_display = {}
	local medal_add = 0
	local medal_data

	surface.CreateFont( "Deathrun_SmoothBig", { font = "Trebuchet18", size = 34, weight = 700, antialias = true } )
	net.Receive( "SyncXP", function( len )
	end)
	
	local xp_total = 0
	local xp_display_time = 0
	local xp_display_alpha = 255

	local medal_sounds = {}
	local medal_sounds_time = CurTime()
 
	net.Receive("XPNotification", function( len )
	
		local xp = net.ReadInt( 32 )
		local medal_name = net.ReadString()
		
		xp_total = xp_total + xp
		xp_display_time = CurTime() + 3
		xp_display_alpha = 255

	 	medal_data = MEDAL[ medal_name ]

		if not medal_data then return end 
		if medal_data.sound then
			
			medal_sounds[ #medal_sounds+1 ] = medal_data.sound
		end

		local icon = medal_data.mat
		local base_x = 0
		local duration = 4
		local alpha = 255

		table.insert( medal_display, 1, { icon, base_x, CurTime() + duration, alpha, xp, medal_data.name } )

	end)
	

	local medal_sz = 60
	local y = 30
	local x = 25

	local xp_y = 135
	local xp_w = 161
	local xp_h = 5

	local xp_b_sz = 2
	local xp_draw_p = 0

	hook.Add("HUDPaint", "XP Notification", function()
		local ply = LocalPlayer()

		if xp_total > 0 then
			surface.SetFont("HUD_Smooth")
			local xsz, ysz = surface.GetTextSize( "+"..xp_total )
			draw.AAText( "+"..xp_total, "HUD_Smooth", 32, ScrH()/2 - ysz, Color(255,255,255,xp_display_alpha), TEXT_ALIGN_LEFT)
		end

		if medal_display and #medal_display > 0 then
			for i = 1,#medal_display do
				medal_display[ i ][ 2 ] = math.Approach( medal_display[ i ][ 2 ], (medal_sz*1.5)*(i-1) + 45, 2*(i*3) )
				surface.SetDrawColor( Color( 255, 255, 255, medal_display[ i ][ 4 ] ) ) 
				surface.SetMaterial( medal_display[ i ][ 1 ] )
				surface.DrawTexturedRect( medal_display[ i ][ 2 ], ScrH()/2, medal_sz, medal_sz )

				local mdlname = medal_display[ i ][ 6 ]
				surface.SetFont("HUD_SmoothS")
				local xsz, ysz = surface.GetTextSize( mdlname )
				draw.AAText( mdlname, "HUD_SmoothS", medal_display[ i ][ 2 ] + medal_sz/2 - xsz/2, ScrH()/2 + medal_sz, Color(255,255,255,medal_display[ i ][ 4 ]), TEXT_ALIGN_LEFT)

				local xp_text = "+"..medal_display[ i ][ 5 ]
				surface.SetFont("HUD_SmoothS")
				local xsz, ysz2 = surface.GetTextSize( xp_text )
				draw.AAText( xp_text, "HUD_SmoothS", medal_display[ i ][ 2 ] + medal_sz/2 - xsz/2 - 4, ScrH()/2 + medal_sz + ysz + ysz2/2, Color(255,255,255,medal_display[ i ][ 4 ]), TEXT_ALIGN_LEFT)
			end

		end

	end)
	
	local medal_cleanup = 0.01
	local medal_cleanup_time = 0.01
	local medal_table_i = 1
	hook.Add("Think", "CleanUpXPNotificationsTable", function()

		if CurTime() > medal_cleanup_time then
			if medal_display and #medal_display > 0 then
				for i = 1,#medal_display do
					if medal_display[ i ][ 3 ] <= CurTime() then
						medal_display[ i ][ 4 ] = medal_display[ i ][ 4 ] - 4

						if medal_display[ i ][ 4 ] <= 0 then
							medal_display[ i ] = nil
						end
					end
				end
			else
				medal_add = 0
			end

			if xp_display_time < CurTime() then
				xp_display_alpha = xp_display_alpha - 4

				if xp_display_alpha <= 0 then
					xp_total = 0
				end
			end
			medal_cleanup_time = CurTime() + medal_cleanup
		end

		if #medal_sounds > 0 and medal_sounds_time < CurTime() then

			local snd = medal_sounds[ medal_table_i ]
			surface.PlaySound( snd )

			medal_sounds_time = CurTime() + SoundDuration( snd ) + 0.2
			medal_table_i = medal_table_i + 1

			if medal_table_i > #medal_sounds then
				medal_sounds = {} 
				medal_table_i = 1
			end
		end
	end)	
end