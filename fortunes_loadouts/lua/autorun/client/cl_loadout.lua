-- leave while you still can
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


net.Receive( "LoadLoadout", function()
	local tbl = net.ReadTable()
	LocalPlayer().loadoutTable = tbl 
end )


local PANEL = {}

local g = 26
local pad = 8 
function PANEL:Init()

	local w,h = ScrW(), ScrH()
	local pW,pH = w/6, h/4
	self:SetSize( pW, pH )
	self:Center()
	self:SetTitle( "" )
	self:SetDraggable( false )
	self:MakePopup()

	local origin = self 

	self.stats = vgui.Create( "DPanel" )
	self.stats:SetSize( pW, pH )
	local x,y = self:GetPos()
	self.stats:SetPos( x + pW + 5, y )

	function self.stats:Paint( w, h )
		surface.SetDrawColor( Color( 28, 28, 28, 250 ) )
		surface.DrawRect( 0, 0, w, h )

		surface.SetDrawColor( Color( 11, 11, 11, 240 ) )
		surface.DrawRect( 0, 0, w, g - pad/2 )

		local text = "Info Panel"
		local font = "TTTHUDMS"
		surface.SetFont( font )
		local xsz,ysz = surface.GetTextSize( text )
		draw.GlowingText(text, font, w/2 - xsz/2, (g-pad/2)/2 - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end

	local icon = vgui.Create( "DImage", self.stats )
	local iW,iH = self.stats:GetWide()*0.25,self.stats:GetWide()*0.25
	icon:SetSize( iW, iH )
	icon:SetPos( self.stats:GetWide()/2 - iW/2, g + 10 )

	local x, y = icon:GetPos()
	self.stats.name = vgui.Create( "DLabel", self.stats )
	self.stats.name:SetText( "" )
	function self.stats.name:update( text )
		self:SetFont( "TTTHUDMS" )
		self:SetText( text )
		self:SizeToContents()
		local statW,statH = self:GetSize()
		self:SetPos( origin.stats:GetWide()/2 - statW/2, y + iH + 5 )
	end 

	function self.stats:clear()
		self.name:SetText( "" )
		self.desc:SetText( "" )
		icon:SetImageColor( Color( 0, 0, 0, 0 ) )
	end 

	self.stats.desc = vgui.Create( "DLabel", self.stats )
	self.stats.desc:SetText( "" )
	self.stats.desc:SetWrap( true )
	function self.stats.desc:update( text )
		self:SetFont( "TTTHUDSS" )
		self:SetText( text )
		self:SetSize( origin.stats:GetWide() - 8, origin.stats:GetTall()/2 )
		local statW,statH = self:GetSize()
		self:SetPos( origin.stats:GetWide()/2 - statW/2, origin.stats:GetTall()/2.5 )
	end 


	function self.stats:update( data, tData, is_wep, pnl, unlocked )
		if is_wep then 
			icon:SetImage( data.Icon )
			icon:SetImageColor( Color( 255, 255, 255, 255 ) )
			self.name:update( data.PrintName )
			self.wep = tData[ 1 ]
			self.targPanel = pnl 
			self.select:SetEnabled( unlocked )
			if unlocked then 
				self.desc:update( tData[ 3 ] )
				self.select:SetText( "Select" )
			else 
				self.desc:update( tData[ 4 ] )
				self.select:SetText( "Locked" )
			end 
		end 
	end 

	self.stats.select = vgui.Create( "DButton", self.stats )
	local selectH = (self.stats:GetTall()/2-self.stats:GetTall()/2.5)
	self.stats.select:SetSize( self.stats:GetWide(), selectH )
	self.stats.select:SetPos( 0, self.stats:GetTall() - selectH )
	self.stats.select:SetText( "" )
	self.stats.select:SetTextColor( Color( 0, 0, 0, 0 ) )

	function self.stats.select:Paint( w, h )
		surface.SetDrawColor( Color( 11, 11, 11, 240 ) )
		surface.DrawRect( 0, 0, w, h )

		local text = self:GetText()
		local font = "TTTHUDSS"
		surface.SetFont( font )
		local xsz,ysz = surface.GetTextSize( text )
		draw.GlowingText(text, font, w/2 - xsz/2, h/2 - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
	end 

	function self.stats.select:DoClick()
		origin.stats:clear()
		if origin.sMenu then 
			origin.sMenu:Remove()
		end
		origin.stats.targPanel:SelectWeapon( weapons.Get( origin.stats.wep ) )
	end 

	self.loadout = {}
	for i = 1,3 do 
		local t = self.loadout 
		t[ i ] = vgui.Create( "DPanel", self )
		local pnl = t[ i ]

		if i == 1 then pnl.primary = true end 

		local pnlW, pnlH = pW - pad, (pH-g)/3 - pad/2
		pnl:SetSize( pnlW, pnlH )
		pnl:SetPos( pad/2, ((pH-g)/3)*(i-1) + g )

		function pnl:Paint( w, h )
			surface.SetDrawColor( Color( 0, 0, 0, 230 ) )
			surface.DrawRect( 0, 0, w, h )
		end 

		local ply = LocalPlayer()
		function pnl:SelectWeapon( wep )

			pnl.icon.image = wep.Icon
			pnl.label:SetText( wep.PrintName )
			pnl.label:SizeToContents()
			pnl.label:Center()
			pnl.weapon = wep

			if not ply.loadoutTable then 
				ply.loadoutTable = {}
			end 

			if self.primary then 
				net.Start( "SelectPrimary" )
					net.WriteString( wep.ClassName )
				net.SendToServer()
				ply.loadoutTable[ 1 ] = wep.ClassName
			else 
				net.Start( "SelectSecondary" )
					net.WriteString( wep.ClassName )
				net.SendToServer()
				ply.loadoutTable[ 2 ] = wep.ClassName
			end 

		end 

		local pad = 10
		if i < 3 then 
			local sz = pnlH*0.8
			local x = pnlH/2  - sz/2 
			pnl.icon = vgui.Create( "DPanel", pnl )
			pnl.icon:SetPos( x, pnlH/2  - sz/2 )
			pnl.icon:SetSize( sz, sz )

			function pnl.icon:Paint( w, h )
				if self.image then 
					surface.SetDrawColor( 255, 255, 255, 255 )
					surface.SetTexture( surface.GetTextureID( self.image ) )
					surface.DrawTexturedRect( 0, 0, w, h )
				else 
					surface.SetDrawColor( 33, 33, 33, 255 )
					surface.DrawRect( 0, 0, w, h )
				end 
			end 


			pnl.label = vgui.Create( "DLabel", pnl )
			pnl.label:Center()
			local text 
			local wep = pnl.wep 
			if wep then 
				text = wep.PrintName 
			else 
				text = "Select a weapon."
			end 
			pnl.label:SetFont( "TTTHUDSS" )
			pnl.label:SetText( text )
			pnl.label:SizeToContents()
			pnl.label:SetMouseInputEnabled( true )

			local ply = LocalPlayer()
			if ply.loadoutTable then 
				if pnl.primary then 
					local w = weapons.Get( ply.loadoutTable[ 1 ] )
					if w then 
						pnl:SelectWeapon( w )
					end 
				else
					local w = weapons.Get( ply.loadoutTable[ 2 ] )
					if w then 
						pnl:SelectWeapon( w )
					end 
				end 
			end 

			local tbl 
			if i == 1 then 
				tbl = loadout.primary 
			elseif i == 2 then 
				tbl = loadout.secondary 
			else 
				tbl = loadout.perk 
			end 
			function pnl.label:DoClick()
				if origin.sMenu then 
					origin.sMenu:Remove()
				end 
				origin.sMenu = vgui.Create( "DFrame" )
				local sW,sH = origin:GetSize()
				local x,y = origin:GetPos()
				origin.sMenu:SetSize( sW, sH )
				origin.sMenu:SetPos( x - sW - 5, y )
				origin.sMenu:SetDraggable( false )
				origin.sMenu:MakePopup()

				function origin.sMenu:Paint( w, h )
					surface.SetDrawColor( Color( 28, 28, 28, 255 ) )
					surface.DrawRect( 0, 0, w, h )

					surface.SetDrawColor( Color( 11, 11, 11, 255 ) )
					surface.DrawRect( 0, 0, w, g )

					local text = ""
					local font = "TTTHUDMS"
					surface.SetFont( font )
					local xsz,ysz = surface.GetTextSize( text )
					draw.GlowingText(text, font, w/2 - xsz/2, g/2 - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
				end 

				local grid = vgui.Create( "DGrid", origin.sMenu )
				grid:Dock( FILL )
				grid:SetCols( 4 )
				grid:SetColWide( sW/grid:GetCols() )
				grid:SetRowHeight( sW/grid:GetCols() )

				for i2 = 1,#tbl do  
					print( tbl[ i2 ][ 1 ] )
					local wepData = weapons.Get( tbl[ i2 ][ 1 ] )
					local wep = vgui.Create( "DImageButton" )
					wep:SetImage( wepData.Icon )
					local sz = grid:GetColWide()
					wep:SetSize( sz - 4, sz - 4 )

					if tbl[ i2 ][ 2 ]( ply ) then
						function wep:DoClick()
							origin.stats:update( wepData, tbl[ i2 ], i < 3 and true or false, pnl, true  )
						end 
					else 
						function wep:DoClick()
							origin.stats:update( wepData, tbl[ i2 ], i < 3 and true or false, pnl, false  )
						end 
						function wep:PaintOver( w, h )
							surface.SetDrawColor( Color( 0, 0, 0, 200 ) )
							surface.DrawRect( 0, 0, w, h )
							local text = "Locked"
							local font = "TTTHUDMS"
							surface.SetFont( font )
							local xsz,ysz = surface.GetTextSize( text )
							draw.GlowingText(text, font, w/2 - xsz/2, h/2 - ysz/2, tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )
						end 
					end 

					grid:AddItem( wep )
				end 
			end

		end 

	end 

end 

function PANEL:Paint( w, h )

	surface.SetDrawColor( Color( 28, 28, 28, 250 ) )
	surface.DrawRect( 0, 0, w, h )

	surface.SetDrawColor( Color( 11, 11, 11, 240 ) )
	surface.DrawRect( 0, 0, w, g - pad/2 )

	local text = "Loadout Menu"
	local font = "TTTHUDMS"
	surface.SetFont( font )
	local xsz,ysz = surface.GetTextSize( text )
	draw.GlowingText(text, font, w/2 - xsz/2, (g-pad/2)/2 - ysz/2,tColors.White, colglow2, colglow3, TEXT_ALIGN_LEFT, TEXT_ALIGN_LEFT )

end 

function PANEL:OnRemove()
	self.stats:Remove()
	if self.sMenu then 
		self.sMenu:Remove()
	end 
end

derma.DefineControl( "loadout_menu", "Loadout Menu", PANEL, "DFrame" )

concommand.Add( "loadout_menu", function( ply )
	if not ply.loadOut then 
		ply.loadOut = vgui.Create( "loadout_menu" )
	else 
		ply.loadOut = nil 
	end 
end)