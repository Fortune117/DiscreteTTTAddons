
local Power,Delay = 30, 5
hook.Add("Initialize", "InitializeCustomTTTItems", function()
	if !EquipmentItems then return end

	EQUIP_ESHIELD = 8

	for role,items in pairs(EquipmentItems) do
		for _,item in pairs(items) do
			if item.id > EQUIP_ESHIELD then
				EQUIP_ESHIELD = item.id*2
			end
		end
	end

	local tbl = { 
		id = EQUIP_ESHIELD,
		type = "item_passive",
		material = "vgui/ttt/icon_combineball",
		name = "Energy Shield",
		desc = "A powerful energyshield designed to protect the user."
	}

	--table.insert(EquipmentItems[ROLE_TRAITOR], tbl) -- Add the equipment to traitor menu
    table.insert(EquipmentItems[ROLE_DETECTIVE], tbl) 
end)

if SERVER then
    hook.Add("TTTOrderedEquipment", "TTTEnergyShield", function(ply, equip, is_item) 
        if equip == EQUIP_ESHIELD then
            ply:SetUpEnergyShield( Power, Delay )
        end
    end)
end