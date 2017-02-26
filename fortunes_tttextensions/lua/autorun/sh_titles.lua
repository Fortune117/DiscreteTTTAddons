
local PLY = FindMetaTable( "Player" )

if SERVER then 
	hook.Add( "PlayerInitialSpawn", "findPlayerTitle", function( ply )
		local title = ply:GetPData( "ttt_title", "notitle" )
		local titlecolor = ply:GetPData( "ttt_title_color", "notitle" )
		if title ~= "notitle" then 
			ply:SetNWString( "ttt_title", title )
		end 

		if titlecolor ~= "notitle" then 
			ply:SetNWString( "ttt_title_color", titlecolor )
		end 
	end )

	function PLY:setTitle( title )
		self:SetPData( "ttt_title", title )
		self:SetNWString( "ttt_title", title )
	end 

	function PLY:setTitleColor( color )
		self:SetPData( "ttt_title_color", color )
		self:SetNWString( "ttt_title_color", color )
	end 

	function PLY:removeTitle()
		self:setTitle( nil, nil )
	end 
end 

function PLY:getTitle()
	return self:GetNWString( "ttt_title", "notitle" )
end 

function PLY:getTitleColor()
	local vec = self:GetNWString( "ttt_title_color", "notitle")
	if vec ~= "notitle" then 
		vec = string.ToColor( vec )
		return vec
	end 
end 