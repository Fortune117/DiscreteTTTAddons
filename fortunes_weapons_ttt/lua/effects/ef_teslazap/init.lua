
function EFFECT:Init(data)

	local ent = data:GetEntity()
	local start = data:GetStart()
	local origin = data:GetOrigin()
	local attach = data:GetAttachment()
	local dmg = data:GetScale()
	local hp = data:GetMagnitude()

	local ef = EffectData()
	ef:SetOrigin( origin )
	ef:SetStart( start )
	ef:SetEntity( ent )
	ef:SetAttachment( attach )
	util.Effect( "ToolTracer", ef  )

	local sparkle = dmg > hp and "cball_explode" or "cball_bounce"
	local ef = EffectData()
	ef:SetOrigin( origin )
	util.Effect( sparkle, ef )
end

function EFFECT:Render()
	return true 
end 