
surface.CreateFont( "TTTHUDL", { font = "Trebuchet18", size = 80, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUD", { font = "Trebuchet18", size = 60, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDML", { font = "Trebuchet18", size = 40, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDScoreL", { font = "Trebuchet18", size = 20, weight = 400, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDS", { font = "Trebuchet18", size = 24, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDMS", { font = "Trebuchet18", size = 20, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSS", { font = "Trebuchet18", size = 16, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSSS", { font = "Trebuchet18", size = 11, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSSSS", { font = "Trebuchet18", size = 9, weight = 450, scanlines = true, antialias = true } )

function CutUpString( str, width, font )
	local str_pieces = {}
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( str )
	if xsz < width then
		return { str }
	end
	local str_table = string.Explode( " ", str )
	local cur_string = ""
	for i = 1,#str_table do
		surface.SetFont( font )
		local text = i > 1 and cur_string.." "..str_table[ i ] or str_table[ i ]
		local xsz,ysz = surface.GetTextSize( text )
		if string.find( str_table[ i ], "/n", string.len( str_table[ i ] )-2, string.len( str_table[ i ] ) ) then
			str_pieces[ #str_pieces+1 ] = cur_string
			cur_string = str_table[ i ]
		elseif xsz >= width then
			str_pieces[ #str_pieces+1 ] = cur_string
			cur_string = str_table[ i ]
		else
			cur_string = text
		end
		if i == #str_table then
			str_pieces[ #str_pieces+1 ] = cur_string
		end
	end
	return str_pieces
end

local tColors = {}
tColors.DGBlue = Color( 0, 102, 255, 255 )
tColors.Black = Color( 0, 0, 0, 180 )
tColors.DarkGrey = Color( 22, 22, 22, 230 )
tColors.Grey = Color( 33, 33, 33, 250 )
tColors.DGRed = Color( 255, 60, 60, 250 )
tColors.DGYellow = Color( 255, 150, 23, 250 )
tColors.TextBlack = Color( 0, 0, 0, 255 )
tColors.White = Color( 235, 235, 235, 255 )

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
local colglow2 = Color( 235/2, 235/2, 235/2, 0 )
local colglow3 = Color( 235/2, 235/2, 235/2, 0 )

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

local PANEL = {}
local g = 30
function PANEL:Init()
	local w,h = ScrW()*0.55, ScrH()*0.55
	self:SetSize( w, h )
	self:Center()
	self:SetTitle( "" )
	self:MakePopup()

	local scroll = vgui.Create( "DScrollPanel", self )
	scroll:SetSize( w, h - g - 22 )
	scroll:SetPos( 0, g )

	local sbar = scroll:GetVBar()
	sbar:SetWide( sbar:GetWide()/2 )
	sbar.Paint = function( self, w, h )
		surface.SetDrawColor( 0, 0, 0, 230 )
		surface.DrawRect( 0, 0, w, h )
	end 

	function sbar.btnUp:Paint( w, h )
		surface.SetDrawColor( Color( 230, 230, 230, 255 ) )
		surface.DrawRect( 0, 0, w, h )
	end
	function sbar.btnDown:Paint( w, h )
		surface.SetDrawColor( Color( 230, 230, 230, 255 ) )
		surface.DrawRect( 0, 0, w, h )
	end
	function sbar.btnGrip:Paint( w, h )
		surface.SetDrawColor( Color( 0, 102, 255 ) )
		surface.DrawRect( 0, 0, w, h )
	end

	self.tpoints = 0
	self.maxpoints = 0

	local clist = CHALLENGES:GetList()
	local desc_font = "TTTHUDSS"
	for i = 1,#clist do
		local tbl = clist[ i ]
		local name = tbl.name 
		local c = vgui.Create( "DPanel", scroll )
		c:DockMargin( 4, 4, 4, 4)
		c:Dock( TOP )	
		local csz = (h-g)/5
		c:SetTall( csz )

		local is_secret = tbl.secret 	

		local cp, cg, p = CHALLENGES:GetPlayerChallengeInfo( LocalPlayer(), i )
		p = math.min( p, 1 )
		local complete = LocalPlayer():CompletedChallenge( i )

		if complete then
			self.tpoints = self.tpoints + tbl.value 
		end
		self.maxpoints = self.maxpoints+tbl.value 

		local pts = tbl.value.."pt"..( tbl.value > 1 and "s" or "")
		local tick = Material( "icon16/tick.png" )
		local tsz = csz*0.4
		function c:Paint( w, h )
			surface.SetDrawColor( Color( 22, 22, 22, 240 ) )
			surface.DrawRect( 0, 0, w, h )


			local font = "TTTHUDSS"
			surface.SetFont( font )

			if is_secret and not complete then 
				local xsz,ysz = surface.GetTextSize( "SECRET" )
				draw.GlowingText( "SECRET", font, w/2 - xsz/2, csz/6 - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			else
				local xsz,ysz = surface.GetTextSize( name )
				draw.GlowingText( name, font, w/2 - xsz/2, csz/6 - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end 

			local font = "TTTHUDSS"
			surface.SetFont( font )
			if is_secret and not complete then 
				local xsz,ysz = surface.GetTextSize( "This is a secret achievement, complete it to see what it is." )
				draw.GlowingText( "This is a secret achievement, complete it to see what it is.", font, w/2 - xsz/2, (csz/2) - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			else
				local xsz,ysz = surface.GetTextSize( tbl.desc )
				draw.GlowingText( tbl.desc, font, w/2 - xsz/2, (csz/2) - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
			end 

			local b_h = math.ceil( h/5 )
			surface.SetDrawColor( Color( 0, 0, 0, 240 ) )
			surface.DrawRect( 0, h - b_h, w, b_h )			

			surface.SetDrawColor( Color( 0, 102, 255, 240 ) )
			surface.DrawRect( 0, h - b_h, w*p, b_h )

			local ct = cp.."/"..cg 
			if cg == 1 then
				ct = "INCOMPLETE"
			end
			if complete then
				ct = cg > 1 and "COMPLETE("..ct..")" or "COMPLETE"
				surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
				surface.SetMaterial( tick )
				surface.DrawTexturedRect( w - tsz*1.5, (h-b_h)/2 - tsz/2, tsz, tsz )
			end

			local font = "TTTHUDSS"
			surface.SetFont( font )
			local xsz,ysz = surface.GetTextSize( ct )
			draw.GlowingText( ct, font, w/2 - xsz/2, h - b_h/2 - ysz/2, tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

			local font = "TTTHUDSS"
			surface.SetFont( font )
			local xsz,ysz = surface.GetTextSize( pts )
			draw.GlowingText( pts, font, w-xsz-2, h - b_h/2 - ysz/2, tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )


		end 	

	end
end

function PANEL:Paint( w, h )
	surface.SetDrawColor( Color( 44, 44, 44, 240 ) )
	surface.DrawRect( 0, 0, w, h )

	surface.SetDrawColor( Color( 11, 11, 11, 240 ) )
	surface.DrawRect( 0, 0, w, g )

	local text = "Achievements"
	local font = "TTTHUDMS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( text )
	draw.GlowingText(text, font, w/2 - xsz/2, g/2 - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

	surface.SetDrawColor( Color( 11, 11, 11, 240 ) )
	surface.DrawRect( 0, h-20, w, 20 )

	local p = self.tpoints/self.maxpoints
	surface.SetDrawColor( Color( 11, 200, 11, 240 ) )
	surface.DrawRect( 0, h-20, w*p, 20 )

	local text = self.tpoints.."/"..self.maxpoints.." pts"
	local font = "TTTHUDMS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( text )
	draw.GlowingText(text, font, w/2 - xsz/2, h-20/2  - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

end 
derma.DefineControl( "ach_menu", "Achievements", PANEL, "DFrame" )

net.Receive( "SendAchData", function( len )
	local name = net.ReadString()
	local cData = net.ReadInt( 32 )
	LocalPlayer():SetPData( name, cData )
end)

net.Receive( "CompleteChallenge", function( len )
	local data = net.ReadTable()
	hook.Call( "OnPlayerCompleteChallenge", GAMEMODE, LocalPlayer(), data )
end)


concommand.Add( "ach_menu", function( ply )
	if not ply.ACHMenu then 
		ply.ACHMenu = vgui.Create( "ach_menu" )
	else 
		ply.ACHMenu = nil 
	end 
end)