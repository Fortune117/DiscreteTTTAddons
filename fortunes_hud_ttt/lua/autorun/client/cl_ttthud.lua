
local table = table
local surface = surface
local draw = draw
local math = math
local string = string

local tColors = {}
tColors.DGBlue = Color( 0, 102, 255, 255 )
tColors.Black = Color( 0, 0, 0, 180 )
tColors.DarkGrey = Color( 22, 22, 22, 230 )
tColors.Grey = Color( 33, 33, 33, 250 )
tColors.DGRed = Color( 255, 60, 60, 250 )
tColors.DGYellow = Color( 255, 150, 23, 250 )
tColors.TextBlack = Color( 0, 0, 0, 255 )
tColors.White = Color( 235, 235, 235, 255 )

local bg_colors = {
   background_main = Color(0, 0, 10, 200),

   noround = Color(100,100,100,230),
   traitor = Color(200, 25, 25, 230),
   innocent = Color(25, 200, 25, 230),
   detective = tColors.DGBlue
};

surface.CreateFont( "TTTHUDL", { font = "Trebuchet18", size = 80, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUD", { font = "Trebuchet18", size = 60, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDML", { font = "Trebuchet18", size = 40, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDScoreL", { font = "Trebuchet18", size = 20, weight = 400, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDS", { font = "Trebuchet18", size = 24, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDMS", { font = "Trebuchet18", size = 20, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSS", { font = "Trebuchet18", size = 14, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSSS", { font = "Trebuchet18", size = 11, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSSSS", { font = "Trebuchet18", size = 9, weight = 450, scanlines = true, antialias = true } )


function surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise)
	local triarc = {}
	local deg2rad = math.pi / 180
	
	-- Correct start/end ang
	local startang,endang = startang or 0, endang or 0
	if bClockwise and (startang < endang) then
		local temp = startang
		startang = endang
		endang = temp
		temp = nil
	elseif (startang > endang) then 
		local temp = startang 
		startang = endang
		endang = temp
		temp = nil
	end
	
	
	-- Define step
	local roughness = math.max(roughness or 1, 1)
	local step = roughness
	if bClockwise then
		step = math.abs(roughness) * -1
	end
	
	
	-- Create the inner circle's points.
	local inner = {}
	local r = radius - thickness
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		table.insert(inner, {
			x=cx+(math.cos(rad)*r),
			y=cy+(math.sin(rad)*r)
		})
	end
	
	
	-- Create the outer circle's points.
	local outer = {}
	for deg=startang, endang, step do
		local rad = deg2rad * deg
		table.insert(outer, {
			x=cx+(math.cos(rad)*radius),
			y=cy+(math.sin(rad)*radius)
		})
	end
	
	
	-- Triangulate the points.
	for tri=1,#inner*2 do -- twice as many triangles as there are degrees.
		local p1,p2,p3
		p1 = outer[math.floor(tri/2)+1]
		p3 = inner[math.floor((tri+1)/2)+1]
		if tri%2 == 0 then --if the number is even use outer.
			p2 = outer[math.floor((tri+1)/2)]
		else
			p2 = inner[math.floor((tri+1)/2)]
		end
	
		table.insert(triarc, {p1,p2,p3})
	end
	
	-- Return a table of triangles to draw.
	return triarc
	
end

function surface.DrawArc(arc)
	for k,v in ipairs(arc) do
		surface.DrawPoly(v)
	end
end

function draw.Arc(cx,cy,radius,thickness,startang,endang,roughness,color,bClockwise)
	surface.SetDrawColor(color)
	surface.DrawArc(surface.PrecacheArc(cx,cy,radius,thickness,startang,endang,roughness,bClockwise))
end

local disabled = { "TTTInfoPanel" }
hook.Add( "HUDShouldDraw", "TTTOverwrite", function( name )
	if table.HasValue( disabled, name ) then
		return false 
	end
end )

function draw.Cross( x, y, sz, t )
	surface.DrawRect( x - sz/2, y - t/2, sz, t )
	surface.DrawRect( x - t/2, y - sz/2, t, sz )
end

function DrawBullet( x, y, w, h, col )
	local arc_sz = w*0.5
	draw.Arc( x + arc_sz, y + arc_sz + 1, arc_sz, arc_sz, 180, 360, 5, col , true )
	surface.DrawRect( x, y + h/3, w, h/3*2 )
	surface.DrawRect( x, y + h*1.03, w, h*0.1)
	surface.DrawRect( x, y + h*1.03, w, h*0.1)
end

local fontdata = {
	blursize = 2;
	italic = false;
	strikeout = false;
	additive = false;
	outline = false;
	underline = false;
	antialias = true;
};
local header = "glow_text_";
surface.madefonts = surface.madefonts or {};
local made = surface.madefonts;

local colglow = Color( 235, 235, 235, 255 )
local colglow2 = Color( 235/2, 235/2, 235/2, 255 )
local colglow3 = Color( 235/2, 235/2, 235/2, 255 )

local roundstate_string = {
   [1]   = "round_wait",
   [2]   = "round_prep",
   [3] = "round_active",
   [4]   = "round_post"
}; 

function draw.GlowingText(text, font, x, y, col, colglow, colglow2, align )
	align = align or TEXT_ALIGN_LEFT
	local bfont1 = header..font;
	local bfont2 = header..font.."2";
	fontdata.font = font;
	if(not made[font]) then
		local _, h = surface.GetTextSize("A");
		fontdata.blursize = 2;
		fontdata.size = h;
		surface.CreateFont(bfont1, fontdata);
		made[font] = true;
		fontdata.blursize = 4;
		fontdata.size = h;
		surface.CreateFont(bfont2, fontdata);
	end

	draw.SimpleText( text, bfont1, x, y, colglow or ColorAlpha(col,150), align )
    draw.SimpleText( text, bfont2, x, y, colglow2 or colglow and ColorAlpha(colglow,50) or ColorAlpha(col, 50), align )
    draw.SimpleText( text, font, x, y, col, align )

end

local x = 30
local y = 20
local h = 90
local w = 250

local c_x = 22
local c_y = math.ceil( h*0.3 )
local c_sz = 26
local c_t = 6

local hp_h = math.ceil( h*0.25 )

local bul_w = 16
local bul_h = 23

local tab_h = math.ceil( h*0.3 )

local bLoadedTTTLangs = false 
local hud_desiredsize = h
local hud_drawsize = hud_desiredsize

local xp_y = y + 5
local xp_h = 5

local ttt_health_label = CreateClientConVar("ttt_health_label", "0", true)
local L 
hook.Add( "HUDPaint", "TTTHUD", function()

	hud_drawsize = Lerp( FrameTime()*15, hud_drawsize, hud_desiredsize )
	local GetLang = LANG.GetUnsafeLanguageTable
	if GetLang then 
		L = GetLang()
		if not bLoadedTTTLangs then
			bLoadedTTTLangs = true
			print( "[DGT] Loaded TTT Langauges for HUD.")
		end
	else
	    return 
	end 
	local ply = LocalPlayer()
	local ob = ply:GetObserverTarget()
	if IsValid( ob ) and ob:IsPlayer() then ply = ob end 
	local hp = math.max( ply:Health(), 0 )
	local maxhp = ply:GetMaxHealth()
	local hp_p = math.min( hp/maxhp, 1 )  

	surface.SetDrawColor( tColors.Grey )
	surface.DrawRect( x, ScrH() - y - h, w, hud_drawsize )

	local col = bg_colors.innocent
	if GAMEMODE.round_state != 3 then
	  	col = bg_colors.noround
	elseif ply:GetTraitor() then
	  	col = bg_colors.traitor
	elseif ply:GetDetective() then
	  	col = bg_colors.detective
	end

	local round_state = GAMEMODE.round_state
	local text = nil
	if round_state == 3 then
		text = L[ ply:GetRoleStringRaw() ]
	else
		text = L[ roundstate_string[round_state] ]
	end

	local tab_y = ScrH() - y - h - tab_h
	surface.SetDrawColor( col )
	surface.DrawRect( x, tab_y, w, 6 )

	surface.SetDrawColor( tColors.DarkGrey )
	surface.DrawRect( x, tab_y + 6, w, ( (ScrH()- y - h) - tab_y ) - 5 )

	local font = "TTTHUDMS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( text )
	draw.GlowingText(text, font, x + 15, tab_y + ysz/2 - 5 ,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )


   local is_haste = HasteMode() and round_state == ROUND_ACTIVE
   local is_traitor = ply:IsActiveTraitor()

   local endtime = GetGlobalFloat("ttt_round_end", 0) - CurTime()

	if is_haste then
      local hastetime = GetGlobalFloat("ttt_haste_end", 0) - CurTime()
      if hastetime < 0 then
         if (not is_traitor) or (math.ceil(CurTime()) % 7 <= 2) then
            -- innocent or blinking "overtime"
            text = L.overtime
         else
            -- traitor and not blinking "overtime" right now, so standard endtime display
            text  = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
            color = tColors.DGRed
         end
      else
         -- still in starting period
         local t = hastetime
         if is_traitor and math.ceil(CurTime()) % 6 < 2 then
            t = endtime
            color = tColors.DGRed
         end
         text = util.SimpleTime(math.max(0, t), "%02i:%02i")
      end
   else
      -- bog standard time when haste mode is off (or round not active)
      text = util.SimpleTime(math.max(0, endtime), "%02i:%02i")
   end

   	local font = "TTTHUDMS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( text )
	draw.GlowingText(text, font, x + w - 15 - xsz, tab_y + ysz/2 - 5 ,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )


	surface.SetDrawColor( tColors.DGBlue )
	draw.Cross( x + c_x, ScrH() - h - y + c_y, c_sz, c_t )

	local hp_gap = x + c_x + c_sz/2 + 5
	local hp_y = ScrH() - h - y + c_y - hp_h/2
	local hp_w = w - hp_gap/2 - (c_x - c_sz/2) - 3
	surface.SetDrawColor( tColors.Black )
	surface.DrawRect( hp_gap, hp_y, hp_w, hp_h )

	surface.SetDrawColor( tColors.DGBlue )
	surface.DrawRect( hp_gap, hp_y, hp_w*hp_p, hp_h )

	local hp_text =  hp..( ttt_health_label:GetBool() and " ("..L[ util.HealthToString(hp) ]..")" or "" )
	local font = "TTTHUDS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( hp_text )
	draw.GlowingText(hp_text, font, hp_gap + hp_w/2 - xsz/2, hp_y + hp_h/2 - ysz/2 - 2, tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

	hud_desiredsize = h
	local draw_ammo = true 
	local wep = ply:GetActiveWeapon()
	if not IsValid( wep ) then 
		hud_desiredsize = h/2
		draw_ammo = false 
	elseif wep.Primary.ClipSize <= -1 then 
		hud_desiredsize = h/2
		draw_ammo = false 
	end 
	if hud_drawsize >= hud_desiredsize*0.9 and draw_ammo then
		local clip = wep:Clip1()
		local clipmax = wep.Primary.ClipSize
		local clip_p = clip/clipmax

		local bul_y =  ScrH() - ( (ScrH() - y ) - ( ScrH() - h - y + c_y ) )  + 5
		local bul_x =  x + c_x - bul_w/2
		DrawBullet( bul_x, bul_y, bul_w, bul_h, tColors.DGYellow )

		local amm_y = bul_y + (bul_h*1.13)/2 - hp_h/2
		surface.SetDrawColor( tColors.Black )
		surface.DrawRect( hp_gap, amm_y, hp_w, hp_h )

		surface.SetDrawColor( tColors.DGYellow )
		surface.DrawRect( hp_gap, amm_y, hp_w*clip_p, hp_h )

		local ammo_text = clip.."/"..clipmax
		local font = "TTTHUDS"
		surface.SetFont( font )
		local xsz,ysz = surface.GetTextSize( ammo_text )
		draw.GlowingText(ammo_text, font, hp_gap + hp_w/2 - xsz/2, amm_y + hp_h/2 - ysz/2 - 1, tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

		local ammo_text = "+"..ply:GetAmmoCount( wep.Primary.Ammo )
		local font = "TTTHUDSS"
		surface.SetFont( font )
		local xsz2,ysz2 = surface.GetTextSize( ammo_text )
		draw.GlowingText(ammo_text, font, hp_gap + hp_w/2 + xsz/2 + xsz2/3, amm_y + hp_h/2 - 1 - ysz/2, tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

	end 

	/*
	local rank = ply:GetRank()
	local xp_p = ply:GetXPPercentage()
	local xp_p_draw = math.Approach( xp_p_draw or 0, xp_p, 5 )

	surface.SetDrawColor( Color( 11, 11, 11, 230 ) )
	surface.DrawRect( x, tab_y - xp_y, w, xp_h ) 

	surface.SetDrawColor( Color( 0, 102, 255, 255 ) )
	surface.DrawRect( x, tab_y - xp_y, w*xp_p, xp_h )

	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawRect( x, tab_y - xp_y, 2, xp_h )

	surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
	surface.DrawRect( x + w - 2, tab_y - xp_y, 2, xp_h )

	local font = "TTTHUDSS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( rank )
	draw.GlowingText( rank, font, x + w/2 - xsz/2, tab_y - xp_y - ysz, tColors.White, colglow2, colglow3 )

	local xp_text = math.Round( xp_p*100 )
	local font = "TTTHUDSS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( xp_text )
	draw.GlowingText( xp_text.."%", font, x + w/2 - xsz/2, tab_y - xp_y + ysz/2, tColors.White, colglow2, colglow3 )
	*/

end)