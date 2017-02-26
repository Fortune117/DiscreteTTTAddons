

function sinr( deg )
	return  math.sin( math.rad(deg) )
end

function cosr( deg )
	return math.cos( math.rad( deg ) )
end

function rsin( deg )
	return  math.sin( math.rad(deg) )
end

function rcos( deg )
	return math.cos( math.rad( deg ) )
end

local startsound = "ambient/explosions/explode_6.wav"
local firesound = "ambient/fire/mtov_flame2.wav"
local endsound = "ambient/explosions/explode_8.wav"
function EFFECT:Init(data)

	local ent = data:GetEntity()
	local pos = data:GetOrigin()

	self.origin = pos 
	self.body = ent 

	self.size = 65
	self.speed = 300

	self.LiveTime = CurTime() + ritual.time
	self.startTime = CurTime()

	self.pent = ClientsideModel( ritual.model, RENDERGROUP_TRANSLUCENT )

	self.pOrigin = pos - Vector( 0, 0, 14 )
	self.pent:SetPos( self.pOrigin )

	local normal = ent:GetUp()*-1
    local distance = normal:Dot(Vector(0,0,self.origin.z)-normal)
    self.pent:SetRenderClipPlaneEnabled(true)
	self.pent:SetRenderClipPlane( normal, distance )

	self.skulls = {}

	self.incr = 360/ritual.skulls 
	for i = 1,ritual.skulls do
		self.skulls[ i ] = ClientsideModel( "models/Gibs/HGIBS.mdl" )
	end

	util.ScreenShake( self.origin, 2, 7, ritual.time, 1000 ) 

	self.em = ParticleEmitter( self.origin )

	sound.Play( startsound, self.origin, 75, 100, 1 ) 

	self.fSize = 30
end

function EFFECT:getProgress()
	return ( CurTime() - self.startTime )/( ritual.time )
end 



function EFFECT:Think()
	local p = self:getProgress()
	local add = Vector( 0, 0, 8 )*math.min( (p*4), 1 )

	self.pent:SetPos( self.pOrigin + add )

	local skullP = math.min( p*8, 1 )
	local p2 = (p-0.8)/0.2
	local sz
	if p <= 0.8 then
		sz = skullP*self.size
	else 
		sz = self.size*( 1 - p2 )
	end 
	local speed = self.speed 

	if p >= 0.25 then
		local dirmax = 5
		local dirmin = 5
		for i = 1,8 do
			
			local pPos = self.origin + Vector( sinr( math.random( 1,360) ), cosr( math.random( 1,360) ), 0 )*math.Rand( self.size/4, self.size )

			local particle = self.em:Add( "effects/blood", pPos )

			particle:SetVelocity( Vector( 0, 0, 8 ) )
			particle:SetDieTime( 1.5 )
			particle:SetStartAlpha(210)
			particle:SetStartSize( 12 )
			particle:SetEndSize( 8 )
			particle:SetRoll( math.random( 360, 480 ) )
			particle:SetGravity( Vector( 0, 0, -3 ) )
			particle:SetColor( 255, 0, 0 )
			
		end
		if not self.firesound then 
			self.firesound = true 
			sound.Play( startsound, self.origin, 75, 100, 1 ) 
		end 
	end

	for k,v in pairs( self.skulls or {} ) do 
		local i = self.incr*(k-1)
		local cur = CurTime()
		local cAdd = self.incr*(k-1) 
		local add = Vector( sinr( cur*speed + cAdd )*sz, cosr( cur*speed + cAdd )*sz, 11 )
		local pos = self.origin + add 
		v:SetPos( pos )

		local ang = ( pos - self.origin ):GetNormal():Angle()
		v:SetAngles( ang )
	end 

	if CurTime() > self.LiveTime then 
		self.pent:Remove()
		for i = 1,#self.skulls do
			self.skulls[ i ]:Remove()
		end
		sound.Play( endsound, self.origin, 75, 100, 1 ) 

		local e = EffectData()
		e:SetOrigin( self.origin )
		e:SetScale( 1000 )
		e:SetMagnitude( 1 )
		util.Effect( "ThumperDust", e )

		util.ScreenShake( self.origin, 5, 7, 0.5, 1000 ) 

		self.em:Finish()
		self:Remove()
	end  
	return true 
end

function EFFECT:Render()
	self.pent:DrawModel()
	for i = 1,#self.skulls do
		self.skulls[ i ]:DrawModel()
	end
	return true
end

