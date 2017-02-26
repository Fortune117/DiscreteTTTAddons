
local PLY = FindMetaTable( "Player" )

rage = {}
rage.hp = 200
rage.speed = 1.8
rage.damage = 60
rage.critMult = 3
rage.critChange = 0.08
rage.damageReduction = 0.1
rage.duration = 25

local tauntData = 
{
	anim = ACT_GMOD_GESTURE_TAUNT_ZOMBIE,
	sound = { Sound( "npc/zombie_poison/pz_alert1.wav" ), Sound( "npc/zombie_poison/pz_alert2.wav" ) }
}

function PLY:rage()
	self.raged = true 
	self:SetHealth( rage.hp )
	self:SetMaxHealth( rage.hp )

	local seq = self:SelectWeightedSequence( tauntData.anim )
	local len = self:SequenceDuration( seq )
	tauntData.time = len + 0.1

	self:StartTaunt( tauntData )

	self:SetRenderMode( RENDERMODE_TRANSCOLOR )
	self:SetColor( Color( 255, 0, 0, 255 ) )
	self:StripWeapons()
	self:Give( "weapon_ttt_ragefists" )
	self:SelectWeapon( "weapon_ttt_ragefists" )

	self:addDeathThink( rage.duration )

end 

function PLY:addDeathThink( dur )
	local start = CurTime()
	hook.Add( "Think", "DeathThink"..self:UniqueID(), function()
		if CurTime() > start + dur then 
			if IsValid( self ) and self:Alive() then
				self:Kill()
			end
			self.raged = false 
			hook.Remove( "Think", "DeathThink"..self:UniqueID() )
		end 
	end )
end 

function PLY:removeDeathThink()
	hook.Remove( "Think", "DeathThink"..self:UniqueID() )
end 

hook.Add( "TTTPrepareRound", "RemoveDeathThinks", function()
	for k,ply in pairs( player.GetAll() ) do
		ply:removeDeathThink()
		ply.raged = false 
	end
end )

hook.Add( "TTTPlayerSpeed", "RemoveDeathThinks", function( ply )
	if ply.raged then 
		return rage.speed
	end 
end )