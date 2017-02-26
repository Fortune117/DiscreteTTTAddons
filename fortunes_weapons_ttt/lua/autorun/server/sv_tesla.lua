
local tesla = {}
tesla.range = 800

local sqrrange = tesla.range^2
function teslaDamageCheck( ply, dmginfo )

	if ply:IsPlayer() and dmginfo:GetAttacker():IsPlayer() then 
		local coils = ents.FindByClass( "ttt_tesla" )
		local atk = dmginfo:GetAttacker()
		if #coils > 0 then 
			for k,v in pairs( coils ) do 

				if atk:GetPos():DistToSqr( v:GetPos() ) <= sqrrange and ply:GetPos():DistToSqr( v:GetPos() ) <= sqrrange then 
					local tr = v:canZap( atk, v, dmginfo, ply )
					if tr then 
						v:zap( atk, dmginfo, tr )
					end 
				end 

			end 
		end 
	end

end 
hook.Add( "EntityTakeDamage", "teslaDamageCheck", teslaDamageCheck )