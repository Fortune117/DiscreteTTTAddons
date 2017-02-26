
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

surface.CreateFont( "TTTHUDS", { font = "Trebuchet18", size = 24, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSmall", { font = "Trebuchet18", size = 20, weight = 450, scanlines = true, antialias = true } )
surface.CreateFont( "TTTHUDSuperSmall", { font = "Trebuchet18", size = 16, weight = 450, scanlines = true, antialias = true } )
function createMedalsWindow( dtabs )

	local ply = LocalPlayer()
	local panel = vgui.Create( "DPanel", dtabs )

	local w,h = dtabs:GetSize()
	local sW = w/2 
	local sz = sW/2

	local mScroll = vgui.Create( "DScrollPanel", panel )
	mScroll:SetSize( sW, h*0.91 )

	local sbar = mScroll:GetVBar()
	sbar:SetWide( sbar:GetWide()/2 )

	function panel:Paint( w, h )
		surface.SetDrawColor( Color( 44, 44, 44, 255 ) )
		surface.DrawRect( 0, 0, w, h )

		if self.image then 
			local x = sW + sW/2 - sbar:GetWide()
			surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
			surface.SetMaterial( self.image )
			surface.DrawTexturedRect( x - sz/2, 25, sz, sz )

			surface.SetFont( "TTTHUDS" )
			local xsz,ysz = surface.GetTextSize( self.medalName )
			draw.GlowingText( self.medalName, "TTTHUDS", x - xsz/2, 25 + sz + 10, Color( 255, 255, 255, 255 ) )

			for i = 1,#self.medalDesc do 
				surface.SetFont( "TTTHUDS" )
				local xsz2,ysz2 = surface.GetTextSize( self.medalDesc[ i ] )
				draw.GlowingText( self.medalDesc[ i ], "TTTHUDS", w/2 + 12 + sbar:GetWide(), 35 + sz + ysz + 20*i, Color( 255, 255, 255, 255 ), nil )
			end 
		end 
	end

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

	local grid = vgui.Create( "DGrid", mScroll )
	grid:SetPos( 0, 0 )
	grid:SetCols( 3 )
	grid:SetColWide( sW/3 )
	grid:SetRowHeight( sW/3 )
	grid:Dock( FILL )

	for k,v in pairs( MEDAL ) do 

		local medal = vgui.Create( "DImageButton" )
		medal:SetSize( sW/3 - 2, sW/3 - 2 )
		medal:SetMaterial( v.mat )
		medal.DoClick = function()
			panel.image = v.mat 
			panel.medalName = v.name
			panel.medalDesc = CutUpString( v.desc, w/2 - 24 - sbar:GetWide(), "TTTHUDS" )
		end 
		grid:AddItem( medal )

	end 

	dtabs:AddSheet( "Medals", panel, "icon16/medal_gold_1.png" ) 

end 
hook.Add( "TTTSettingsTabs", "TTTMedalsWindow", createMedalsWindow )



local function createRanksWindow( dtabs )

	local w,h = dtabs:GetSize()
	local rpnl = vgui.Create( "DPanel", dtabs )
	rpnl:SetSize( w, h )

	local ply = LocalPlayer()
	local rank = ply:GetRank()
	local rankNum = ply:GetRankNumber()
	local p = ply:GetXPPercentage()
	local xpCurrent = ply:GetRankXP()
	local xp = ply:GetRelativeXP()
	local xpNextRelative = ply:GetNextRankXP() - xpCurrent 
	local xpNext = ply:GetNextRankXP()
	local nextRank = ply:GetNextRank()
	local prevRank 
	if RANKS.LIST.Player[ rankNum - 1 ] then 
		prevRank = RANKS.LIST.Player[ rankNum - 1 ][ 1 ]
	else 
		prevRank = ""
	end 

	local barH = 5
	local barW = w*0.8
	local buffW = 2
	function rpnl:Paint( w, h )

		surface.SetDrawColor( Color( 33, 33, 33, 255 ) )
		surface.DrawRect( 0, 0, w, h )

		surface.SetDrawColor( Color( 255, 255, 255, 255 ) )
		surface.DrawRect( w/2 - barW/2-buffW, h/4 - barH/2, buffW, barH )
		
		surface.DrawRect( w/2 + barW/2, h/4 - barH/2, buffW, barH )

		surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
		surface.DrawRect( w/2 - barW/2, h/4 - barH/2, barW, barH )

		surface.SetDrawColor( Color( 0, 102, 255, 255 ) )
		surface.DrawRect( w/2 - barW/2, h/4 - barH/2, barW*p, barH )

		surface.SetFont( "TTTHUDSmall" )
		local xsz,ysz = surface.GetTextSize( rank )
		draw.GlowingText( rank, "TTTHUDSmall", w/2 - xsz/2, h/4 - barH*1.5 - ysz, Color( 255, 255, 255, 255 ) )

		local xpText = xp.."/"..xpNextRelative.." ("..( math.Round( xp/xpNextRelative, 2 )*100 ).."%)"
		surface.SetFont( "TTTHUDSmall" )
		local xsz,ysz = surface.GetTextSize( xpText )
		draw.GlowingText( xpText, "TTTHUDSmall", w/2 - xsz/2, h/4 + barH/2, Color( 255, 255, 255, 255 ) )

		surface.SetFont( "TTTHUDSuperSmall" )
		local xsz,ysz = surface.GetTextSize( prevRank )
		draw.GlowingText( prevRank, "TTTHUDSuperSmall", 5, h/4 - barH*1.5 - ysz, Color( 255, 255, 255, 255 ) )

		surface.SetFont( "TTTHUDSuperSmall" )
		local xsz,ysz = surface.GetTextSize( xpCurrent )
		draw.GlowingText( xpCurrent, "TTTHUDSuperSmall", 5, h/4 + barH/2, Color( 255, 255, 255, 255 ) )

		surface.SetFont( "TTTHUDSuperSmall" )
		local xsz,ysz = surface.GetTextSize( nextRank )
		draw.GlowingText( nextRank, "TTTHUDSuperSmall", w - xsz - 5, h/4 - barH*1.5 - ysz, Color( 255, 255, 255, 255 ) )

		surface.SetFont( "TTTHUDSuperSmall" )
		local xsz,ysz = surface.GetTextSize( xpNext )
		draw.GlowingText( xpNext, "TTTHUDSuperSmall", w - xsz - 5, h/4 + barH/2, Color( 255, 255, 255, 255 ) )


	end 

	local rankScroll = vgui.Create( "DScrollPanel", rpnl )
	rankScroll:SetPos( 0, h/3 )
	rankScroll:SetSize( w*0.97, (h*0.86)/1.5 )

	local sbar = rankScroll:GetVBar()
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

	local pad = 2
	for i = 1,#RANKS.LIST.Player do
		local r = RANKS.LIST.Player[ i ]
		local rName = r[ 1 ]
		local rXP = r[ 2 ]
		local p = math.min( ply:GetXP()/rXP, 1 )
		local pnl = vgui.Create( "DPanel", rankScroll )
		pnl:Dock( TOP )
		pnl:SetTall( (h/2)/4 )
		pnl:DockMargin( sbar:GetWide() + pad, pad, pad, pad )
		function pnl:Paint( w, h )
			surface.SetDrawColor( Color( 22, 22, 22, 255 ) )
			surface.DrawRect( 0, 0, w, h )

			surface.SetDrawColor( Color( 0, 0, 0, 255 ) )
			surface.DrawRect( 0, h - 5, w, 5 )

			surface.SetDrawColor( Color( 0, 102, 255, 255 ) )
			surface.DrawRect( 0, h - 5, w*p, 5 )

			local t = (math.Round( p, 3 )*100).."%"
			surface.SetFont( "TTTHUDSuperSmall" )
			local xsz,ysz = surface.GetTextSize( t )
			draw.GlowingText( t, "TTTHUDSuperSmall", w/2 - xsz/2, h-5-ysz, Color( 255, 255, 255, 255 ) )

			surface.SetFont( "TTTHUDSuperSmall" )
			local xsz,ysz = surface.GetTextSize( rName )
			draw.GlowingText( rName, "TTTHUDSuperSmall", w/2 - xsz/2, 0, Color( 255, 255, 255, 255 ) )
		end 
	end 

	dtabs:AddSheet( "Rank Info", rpnl, "icon16/shield.png" ) 

end 
hook.Add( "TTTSettingsTabs", "TTTRanksWindow", createRanksWindow )