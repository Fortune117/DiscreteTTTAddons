
CreateClientConVar( "ttt_drawshields", "1", true, false )
function addDiscreteOptions( dtab )

	local w,h = dtab:GetSize()

	local dlist = vgui.Create( "DPanelList", dtab )
	dlist:StretchToParent( 0, 0, 0, 0 )
	dlist:EnableVerticalScrollbar(true)
  	dlist:SetPadding(10)
  	dlist:SetSpacing(10)

	local shieldSettings = vgui.Create( "DForm", dlist )
	shieldSettings:SetName( "Energy Shield Settings" ) 
	shieldSettings:CheckBox( "Draw Energy Shields. Disabling may improve performance.", "ttt_drawshields" )

	dlist:AddItem( shieldSettings )

	dtab:AddSheet( "TTT Custom Settings", dlist, "icon16/wrench_orange.png" ) 
end 
hook.Add( "TTTSettingsTabs", "discreteSettings", addDiscreteOptions )