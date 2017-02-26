
if SERVER then 
	resource.AddFile( "sound/nokia.wav" )
end 

local PLY = FindMetaTable( "Player" )

function PLY:setIEDTarget( targ )
	self:SetNWEntity( "IEDTarget", targ )

	if targ and IsValid( targ ) then 
		targ:setIED( true, self )
	end 
end 

function PLY:getIEDTarget()
	return self:GetNWEntity( "IEDTarget" )
end 


local ENT = FindMetaTable( "Entity" )

function ENT:setIED( bool, ply )

	self:SetNWBool( "isTarget", bool )

	self:SetNWEntity( "IEDOwner", ply )

end 

function ENT:doIEDExplosionThink( ply, snd, wep, delay )
	local delay = delay or CurTime() + 3.2

	self.detonating = true 
	self.timeUntilDet = delay 

	if SERVER then 
		hook.Add( "Think", "IEDExplosion"..self:EntIndex(), function()

			if CurTime() > delay then 
				self.timeUntilDet = delay - CurTime()
				if not self:IsPlayer() or self:Alive() then 

					self.detonating = false 

					util.BlastDamage( Entity( 0 ), ply and ply or Entity( 0 ), self:GetPos(), 800, 200 )

					local effect = EffectData()
					effect:SetStart( self:GetPos() )
					effect:SetOrigin( self:GetPos() )
					effect:SetScale( 400 )
					effect:SetRadius( 400 )
					effect:SetMagnitude(220 )
					effect:SetNormal( self:GetUp() )
					util.Effect("Explosion", effect, true, true)

					hook.Remove( "Think", "IEDExplosion"..self:EntIndex() )

					ply:setIEDTarget( nil )
					self:setIED( false )

				else 

					hook.Remove( "Think", "IEDExplosion"..self:EntIndex() )

				end

			end 

		end)
	end 
end 

function ENT:isIEDTarget()
	if self:GetNWBool( "isTarget", false ) then 
		return true, self:GetNWEntity( "IEDOwner" )
	else 
		return false 
	end 
end 

function resetIEDs()
	for k,v in pairs( player.GetAll() ) do
		v:setIEDTarget( nil )
		v:setIED( false )
		hook.Remove( "Think", "RagdollIEDTransfer"..v:UniqueID() )
	end
end 
hook.Add( "TTTPrepareRound", "Reset IEDs", resetIEDs )


function transferIEDToRag( ply, atk, dmginfo )

	local dti = CORPSE.dti

	local inf = dmginfo:GetInflictor()
	local is_target, owner = ply:isIEDTarget()
	
	if is_target then
		local delay = CurTime() + 0.1
		hook.Add( "Think", "RagdollIEDTransfer"..ply:UniqueID(), function() 
			if CurTime() > delay then 
				if IsValid( owner ) and IsValid( owner:getIEDTarget() ) then 
					if ply.server_ragdoll then 
						owner:setIEDTarget( ply.server_ragdoll )
						if ply.detonating then 
							ply.server_ragdoll:doIEDExplosionThink( owner, "nokia.wav", owner, ply.timeUntilDet )
						end 
					end 
					hook.Remove( "Think", "RagdollIEDTransfer"..ply:UniqueID() )
				end 
			end 
		end )
	end 

end 
hook.Add( "DoPlayerDeath", "transferIED", transferIEDToRag )

if CLIENT then 
	local range = 600^2
	local clr = Color( 255, 50, 50, 230 )
	function drawIEDHalos()
		local tbl = {}
		local ply = LocalPlayer()
		for k,v in pairs( player.GetAll() ) do
			local is_target,owner = v:isIEDTarget()
			if is_target then 
				if ply:IsTraitor() or ply == owner then 
					local dist = ply:GetPos():DistToSqr( v:GetPos() )
					local scale = 1 - ( dist / range ) 
					if dist < range then 
						halo.Add( {v}, clr, 3*scale, 3*scale, 5, true, false )
					end
				end 
			end 
		end 

		for k,v in pairs( ents.FindByClass( "prop_ragdoll" ) ) do
			local is_target,owner = v:isIEDTarget()
			if is_target then 
				if ply:IsTraitor() or ply == owner then
					local dist = ply:GetPos():DistToSqr( v:GetPos() )
					local scale = 1 - ( dist / range ) 
					if dist < range then 
						halo.Add( {v}, clr, 3*scale, 3*scale, 5, true, false )
					end 
				end 
			end 
		end 
	end
	hook.Add( "PreDrawHalos", "IEDHalos", drawIEDHalos )
end 