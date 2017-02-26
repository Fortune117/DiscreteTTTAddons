
net.Receive( "syncData", function( len )
	local ply = LocalPlayer()
	local str = net.ReadString()
	local n = net.ReadFloat()

	if not ply.netData then 
		ply.netData = {}
	end 

	ply.netData[ str ] = n 
end )


net.Receive( "setUpData", function( len )
	local ply = LocalPlayer()
	ply.netData = {}
end )

local gap = 120
local barH = 10
local lerpMul = 1

local canBoostColor = Color( 0, 102, 255 )
local cannotBoostColor = Color( 255, 102, 0 )
function boostHUD()

	local ply = LocalPlayer()

	if not ply:getCyberUpgrade() then return end

	if not (ply.IsGhost and ply:IsGhost()) then
		if not ply:Alive() or ply:IsSpec() then return end 
	end 
	
	local w,h = ScrW(),ScrH()
	local barW = w*0.25
	surface.SetDrawColor( Color( 0, 0, 0, 200 ) )

	local x,y = (w - barW)/2, h - gap - barH
	surface.DrawRect( x, y, barW, barH )

	local p = ply:getBoostPercentage()
	lerpMul = Lerp( FrameTime()*22, lerpMul, p )

	surface.SetDrawColor( canBoostColor )

	x = x+1
	y = y+1 
	barW = barW-2
	local barH = barH-2
	surface.DrawRect( x, y, barW*lerpMul, barH ) 

	surface.SetDrawColor( Color( 255, 255, 255, 255 ) ) 

	local bh = barH*1.5
	surface.DrawRect( x + barW*booster.canBoostVal, y + (barH - bh)*0.5, 2, bh )

end 
hook.Add( "HUDPaint", "boostHUD", boostHUD )