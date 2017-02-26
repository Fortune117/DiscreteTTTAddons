

local ENT = FindMetaTable( "Entity" )

local hNames = {}
function ENT:setUpCorpseTrap( owner, snd, wep )
	local hname = "CorpseTrap"..owner:UniqueID()
	self:SetNWBool( "trapped", true )
	self.trapSound = snd 
	self.hookName = hname 
	self:SetNWEntity( "trapper", owner )
	hNames[ #hNames +1 ] = hname 
end 

function ENT:isCorpseTrapped()
	return self:GetNWBool( "trapped", false )
end 

if SERVER then 

	hook.Add( "TTTBodyFound", "DoCorpseTraps", function( ply, deadply, rag )
		if rag:isCorpseTrapped() and not ply:IsTraitor() then 
			local owner = rag:GetNWEntity( "trapper" )
			local delay = CurTime() + 1.59
			rag:EmitSound( rag.trapSound )
			hook.Add( "Think", rag.hookName, function()

				if CurTime() > delay then 

					if IsValid( rag ) and IsValid( owner ) then

						util.BlastDamage( Entity( 0 ), owner, rag:GetPos(), 400, 160 )

						local effect = EffectData()
						effect:SetStart( rag:GetPos() )
						effect:SetOrigin( rag:GetPos() )
						effect:SetScale( 400 )
						effect:SetRadius( 400 )
						effect:SetMagnitude(220 )
						effect:SetNormal( rag:GetUp() )
						util.Effect("Explosion", effect, true, true)
						rag:SetNWBool( "trapped", false )

					end

					hook.Remove( "Think", rag.hookName )
				end 

			end)
		end 
	end)

	hook.Add( "TTTPrepareRound", "RemoveRedundantHooks", function()
		for i = 1,#hNames do 
			hook.Remove( "Think", hNames[ i ] )
		end 
		hNames = {}
	end)

end 

if CLIENT then 
	local range = 600^2
	local clr = Color( 255, 50, 50, 230 )
	function drawCTrapHalos()
		local tbl = {}
		local ply = LocalPlayer()
		for k,v in pairs( ents.FindByClass( "prop_ragdoll" ) ) do
			local is_target = v:isCorpseTrapped()
			if is_target then 
				if ply:IsTraitor() then
					local dist = ply:GetPos():DistToSqr( v:GetPos() )
					local scale = 1 - ( dist / range ) 
					if dist < range then 
						halo.Add( {v}, clr, 4*scale, 4*scale, 1, true, false )
					end 
				end 
			end 
		end 
	end
	hook.Add( "PreDrawHalos", "IEDHalos", drawCTrapHalos )
end 