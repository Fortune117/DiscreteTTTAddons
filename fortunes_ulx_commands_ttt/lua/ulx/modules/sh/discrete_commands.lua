
local CATEGORY_NAME  = "Fortunes' Commands"
local gamemode_error = "The current gamemode is not trouble in terrorist town!"



--[Ulx Completes]------------------------------------------------------------------------------
ulx.target_role = {}
function updateRoles()
	table.Empty( ulx.target_role )
	    
    table.insert(ulx.target_role,"traitor")
    table.insert(ulx.target_role,"detective")
    table.insert(ulx.target_role,"innocent")
end
hook.Add( ULib.HOOK_UCLCHANGED, "ULXRoleNamesUpdate", updateRoles )
updateRoles()
--[End]----------------------------------------------------------------------------------------



--[Global Helper Functions][Used by more than one command.]------------------------------------
--[[send_messages][Sends messages to player(s)]
@param  {[PlayerObject]} v       [The player(s) to send the message to.]
@param  {[String]}       message [The message that will be sent.]
--]]
function send_messages(v, message)
	if type(v) == "Players" then
		v:ChatPrint(message)
	elseif type(v) == "table" then
		for i=1, #v do
			v[i]:ChatPrint(message)
		end
	end
end

--[[corpse_find][Finds the corpse of a given player.]
@param  {[PlayerObject]} v       [The player that to find the corpse for.]
--]]
function corpse_find(v)
	for _, ent in pairs( ents.FindByClass( "prop_ragdoll" )) do
		if ent.uqid == v:UniqueID() and IsValid(ent) then
			return ent or false
		end
	end
end

--[[corpse_remove][removes the corpse given.]
@param  {[Ragdoll]} corpse [The corpse to be removed.]
--]]
function corpse_remove(corpse)
	CORPSE.SetFound(corpse, false)
	if string.find(corpse:GetModel(), "zm_", 6, true) then
        player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", false )
        corpse:Remove()
        SendFullStateUpdate()
	elseif corpse.player_ragdoll then
        player.GetByUniqueID( corpse.uqid ):SetNWBool( "body_found", false )
		corpse:Remove()
        SendFullStateUpdate()
	end
end

--[[corpse_identify][identifies the given corpse.]
@param  {[Ragdoll]} corpse [The corpse to be identified.]
--]]
function corpse_identify(corpse)
	if corpse then
		local ply = player.GetByUniqueID(corpse.uqid)
		ply:SetNWBool("body_found", true)
		CORPSE.SetFound(corpse, true)
	end
end
--[End]----------------------------------------------------------------------------------------



function ulx.setTitle( calling_ply, target_ply, title )
	target_ply:setTitle( title )
	local msg = "#A set the title of #T to '"..title.."'." 
	ulx.fancyLogAdmin( calling_ply, msg, target_ply )
end
local setTitle = ulx.command( CATEGORY_NAME, "ulx title", ulx.setTitle, "!title" )
setTitle:addParam{ type=ULib.cmds.PlayerArg }
setTitle:addParam{ type=ULib.cmds.StringArg, ULib.cmds.takeRestOfLine }
setTitle:defaultAccess( ULib.ACCESS_SUPERADMIN )
setTitle:help( "Sets the title of a player." )



function ulx.removetitle( calling_ply, target_ply )
	target_ply:setTitle( "notitle" )
	target_ply:setTitleColor( "notitle" )
	local msg = "#A removed the title of #T." 
	ulx.fancyLogAdmin( calling_ply, msg, target_ply )
end
local removetitle = ulx.command( CATEGORY_NAME, "ulx removetitle", ulx.removetitle, "!removetitle" )
removetitle:addParam{ type=ULib.cmds.PlayerArg }
removetitle:defaultAccess( ULib.ACCESS_SUPERADMIN )
removetitle:help( "Removes the title of a player." )



function ulx.removetitlecolor( calling_ply, target_ply )
	target_ply:setTitleColor( "notitle" )
	local msg = "#A removed the title colour of #T." 
	ulx.fancyLogAdmin( calling_ply, msg, target_ply )
end
local removetitle = ulx.command( CATEGORY_NAME, "ulx removetitlecolor", ulx.removetitlecolor, "!removetitlecolour" )
removetitle:addParam{ type=ULib.cmds.PlayerArg }
removetitle:defaultAccess( ULib.ACCESS_SUPERADMIN )
removetitle:help( "Removes the title colour of a player." )



function ulx.setTitleColor( calling_ply, target_ply, r, g, b ) 
	target_ply:setTitleColor( r.." "..g.." "..b.." 255" )
	local msg = "#A set the title colour of #T to RGB( "..r..", "..g..", "..b.." )."
	ulx.fancyLogAdmin( calling_ply, msg, target_ply )
end
local titlecolor = ulx.command( CATEGORY_NAME, "ulx titlecolor", ulx.setTitleColor, "!titlecolour" )
titlecolor:addParam{ type=ULib.cmds.PlayerArg }
titlecolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Red value for title color.", ULib.cmds.round }
titlecolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Green value for title color.", ULib.cmds.round }
titlecolor:addParam{ type=ULib.cmds.NumArg, min=0, max=255, default=255, hint="Blue value for title color.", ULib.cmds.round }
titlecolor:defaultAccess( ULib.ACCESS_SUPERADMIN )
titlecolor:help( "Sets the title colour of a player." )




local meta = FindMetaTable( "Entity" )	
function meta:dissolve()
	if self:IsPlayer() then return end

	local dissolver = ents.Create( "env_entity_dissolver" )
	dissolver:SetPos( self:LocalToWorld(self:OBBCenter()) )
	dissolver:SetKeyValue( "dissolvetype", 0 )
	dissolver:Spawn()
	dissolver:Activate()
	
	local name = "Dissolving_"..math.random()
	self:SetName( name )
	dissolver:Fire( "Dissolve", name, 0 )
	dissolver:Fire( "Kill", self, 0.10 )
	
end

local largeBodyParts = 
{
	Model( "models/gibs/fast_zombie_torso.mdl" ),
	Model( "models/humans/charple02.mdl" ),
	Model( "models/humans/charple03.mdl" ),
	Model( "models/humans/charple04.mdl" )
}

local mediumBodyParts =
{
	Model( "models/gibs/HGIBS.mdl" ),
	Model( "models/weapons/w_bugbait.mdl" ),
	Model( "models/gibs/antlion_gib_medium_1.mdl" ),
	Model( "models/gibs/antlion_gib_medium_2.mdl" ),
	Model( "models/gibs/shield_scanner_gib5.mdl" ),
	Model( "models/gibs/shield_scanner_gib6.mdl" ),
	Model( "models/props_junk/shoe001a.mdl" ),
	Model( "models/props_junk/rock001a.mdl" ),
	Model( "models/props_combine/breenbust_chunk03.mdl" ),
	Model( "models/props_debris/concrete_chunk03a.mdl" ),
	Model( "models/props_debris/concrete_spawnchunk001g.mdl" ),
	Model( "models/props_debris/concrete_spawnchunk001k.mdl" ),
	Model( "models/props_wasteland/prison_sinkchunk001c.mdl" ),
	Model( "models/props_wasteland/prison_toiletchunk01j.mdl" ),
	Model( "models/props_wasteland/prison_toiletchunk01k.mdl" ),
	Model( "models/props_junk/watermelon01_chunk01b.mdl" ),
	Model( "models/props/cs_italy/bananna.mdl" ) 
}

local smallBodyParts =
{
	Model( "models/gibs/HGIBS_scapula.mdl" ),
	Model( "models/gibs/HGIBS_spine.mdl" ),
	Model( "models/props_phx/misc/potato.mdl" ),
	Model( "models/gibs/antlion_gib_small_1.mdl" ),
	Model( "models/gibs/antlion_gib_small_2.mdl" ),
	Model( "models/gibs/shield_scanner_gib1.mdl" ),
	Model( "models/props_debris/concrete_chunk04a.mdl" ),
	Model( "models/props_debris/concrete_chunk05g.mdl" ),
	Model( "models/props_wasteland/prison_sinkchunk001h.mdl" ),
	Model( "models/props_wasteland/prison_toiletchunk01f.mdl" ),
	Model( "models/props_wasteland/prison_toiletchunk01i.mdl" ),
	Model( "models/props_wasteland/prison_toiletchunk01l.mdl" ),
	Model( "models/props_combine/breenbust_chunk02.mdl" ),
	Model( "models/props_combine/breenbust_chunk04.mdl" ),
	Model( "models/props_combine/breenbust_chunk05.mdl" ),
	Model( "models/props_combine/breenbust_chunk06.mdl" ),
	Model( "models/props_junk/watermelon01_chunk02a.mdl" ),
	Model( "models/props_junk/watermelon01_chunk02b.mdl" ),
	Model( "models/props_junk/watermelon01_chunk02c.mdl" ),
	Model( "models/props/cs_office/computer_mouse.mdl" ),
	Model( "models/props/cs_italy/banannagib1.mdl" ),
	Model( "models/props/cs_italy/banannagib2.mdl" ),
	Model( "models/props/cs_italy/orangegib1.mdl" ),
	Model( "models/props/cs_italy/orangegib2.mdl" )
}

local PLY = FindMetaTable( "Player" )
function PLY:gore()
	local dir = Vector( math.random( -1, 1 ), math.random( -1, 1 ), math.random( 25, 75 ) )
	for i = 1,math.Rand( 13, 26 ) do

		local tbl = smallBodyParts

		if i == 1 then

			local doll = ents.Create( "prop_ragdoll" )
			doll:SetModel( table.Random( largeBodyParts ) )
			doll:SetPos( self:GetPos() )
			doll:SetAngles( self:GetAngles() )
			doll:Spawn()
			doll:SetCollisionGroup( COLLISION_GROUP_WEAPON )
			doll:SetMaterial( "models/flesh" )
			doll:Ignite( 10 )

			local phys = doll:GetPhysicsObject()
					
			if IsValid( phys ) then
					
				phys:AddAngleVelocity( VectorRand() * 2000 )
				phys:ApplyForceCenter( dir * math.random( 2000, 3000 ) )

			end	

			local ed = EffectData()
			ed:SetOrigin( doll:GetPos() )
			util.Effect( "hdn_gore", ed, true, true )

			continue

		elseif i < 3 then

			tbl = mediumBodyParts

		end

		local gib = ents.Create( "ent_gore" )
		gib:SetPos( self:GetPos() + VectorRand()*20 )
		gib:SetModel( table.Random( tbl ) )
		gib:Spawn()

	end 
end 

function PLY:uberSlay()

	local vec = Vector( math.random( -700, 700 ), math.random( -700, 700 ), math.random( 25, 75 ) )
	self:SetVelocity( vec )
	self:gore()
	self:Kill()

	local effectdata = EffectData()
    effectdata:SetStart( self:GetShootPos() )
    effectdata:SetOrigin( self:GetShootPos() )
    effectdata:SetMagnitude( 100 )
    effectdata:SetScale( 10000 )
    effectdata:SetRadius( 1006 )
    effectdata:SetEntity( self )
    util.Effect( "TeslaHitBoxes", effectdata, true, true)

	local explosioneffect = ents.Create( "prop_combine_ball" )
    explosioneffect:SetPos( self:GetPos() - Vector( 0, 0, 25 ) ) 
    explosioneffect:Spawn()
    explosioneffect:Fire( "explode", "", 0 )

	timer.Simple( 0.01, function() 
		if IsValid( self ) then 
			local c = corpse_find( self )
			if IsValid( c ) then 
				corpse_identify( c )
				corpse_remove( c )
			end 
		end 
	end )

end 

function ulx.uberslay( calling_ply, target_plys )

	local affected_plys = {}

	for i = 1, #target_plys do
		local v = target_plys[ i ]
		if v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		
		elseif not v:Alive() then
		ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
		else
		
			v:uberSlay()
			table.insert( affected_plys, v )
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A UBERSLAYED #T", affected_plys )

end
local uberslay = ulx.command( CATEGORY_NAME, "ulx uberslay", ulx.uberslay, "!uberslay" )
uberslay:addParam{ type=ULib.cmds.PlayersArg }
uberslay:defaultAccess( ULib.ACCESS_SUPERADMIN )
uberslay:help( "Destroys a player with the might of a god." )

function ulx.push( calling_ply, target_plys, force )

	local affected_plys = {}

	for i = 1, #target_plys do
		local v = target_plys[ i ]
		if v:IsFrozen() then
			ULib.tsayError( calling_ply, v:Nick() .. " is frozen!", true )
		
		elseif not v:Alive() then
		ULib.tsayError( calling_ply, v:Nick() .. " is dead!", true )
		else
		
			v:SetVelocity( v:GetForward()*force + Vector( 0, 0, 250 ) )
			table.insert( affected_plys, v )
		end
	end

	ulx.fancyLogAdmin( calling_ply, "#A pushed #T", affected_plys )

end
local push = ulx.command( CATEGORY_NAME, "ulx push", ulx.push, "!push" )
push:addParam{ type=ULib.cmds.PlayersArg }
push:addParam{ type=ULib.cmds.NumArg, min=100, max=10000, default=150, hint="Force of the push.", ULib.cmds.round, ULib.cmds.optional }
push:defaultAccess( ULib.ACCESS_SUPERADMIN )
push:help( "Gives a player a gental push." )