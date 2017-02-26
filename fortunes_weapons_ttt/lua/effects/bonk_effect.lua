
local backup_mdl = Model("models/player/phoenix.mdl")

function EFFECT:Init(data)
   self.BlurModel = data:GetEntity()

   self:SetPos(data:GetOrigin())

   local ang = data:GetAngles()
   -- pitch is done via aim_pitch, and roll shouldn't happen
   ang.r = 0
   ang.p = 0
   self:SetAngles(ang)
   
   self.Sequence = data:GetColor()
   self.Cycle    = data:GetScale()
   self.EndTime  = CurTime() + 0.5
	
   self.FadeTime = 2
   
   self.OldTime = CurTime()
   
   self.FadeIn   = CurTime() + self.FadeTime
   self.FadeOut  = self.EndTime - self.FadeTime
   
   self:SetRenderBounds(Vector(-18, -18, 0), Vector(18, 18, 64))

   self.Alpha = 0

   if IsValid(self.BlurModel) then
      local mdl = self.BlurModel:GetModel()
      mdl = util.IsValidModel(mdl) and mdl or backup_mdl
	
      self.Blur = ClientsideModel(mdl, RENDERGROUP_TRANSLUCENT)
      if not self.Blur then return end
      self.Blur:SetPos(data:GetOrigin())
      self.Blur:SetAngles(ang)
      self.Blur:AddEffects(EF_NODRAW)

      self.Blur:SetSequence(self.Sequence)
      self.Blur:SetCycle(self.Cycle)

      local pose = data:GetStart()
      self.Blur:SetPoseParameter("aim_yaw", pose.x)
      self.Blur:SetPoseParameter("aim_pitch", pose.y)
      self.Blur:SetPoseParameter("move_yaw", pose.z)
   else
      self.Blur = nil
   end
end

function EFFECT:Think()
   if self.EndTime < CurTime() then
      SafeRemoveEntity(self.Blur)
      return false
   end
   
   self.Alpha = 1 - ( (CurTime() + 0.5) - self.OldTime )
   
   return IsValid(self.Blur)
end

function EFFECT:Render()
   render.SuppressEngineLighting( true )
   render.SetColorModulation(0.4, 0.4, 1)
   render.SetBlend(0.8 * self.Alpha)

   if self.Blur then
      --self.Blur:ClearPoseParameters()
      self.Blur:DrawModel()
   end

   render.SetBlend(1)
   render.SetColorModulation(1, 1, 1)
   render.SuppressEngineLighting(false)
end

