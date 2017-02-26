
--[[
Here is where you can control what appears in the loadout menu.
Its pretty easy to use, but I'll give you a quick example:
inside the {} of loadout.primary or loadout.secondary you'll want to a add something like this:
{ 	
	"weapon_ttt_m16",

	function( ply )
		return true
	end, 

	"Powerful assault rifle.",

	"Disabled"
},	
so if you had only that it'd look like this:
loadout.primary =
{
	{ 	
		"weapon_ttt_m16",

		function( ply )
			return true
		end, 

		"Powerful assault rifle.",

		"Disabled"
	},	
}

Now as for what everything does.
{ 	
	"weapon_ttt_m16", -- this is the weapon entity name, in this case the m16

	function( ply ) -- This is a function used to determine if the player can access the weapon in the loadout menu. If it returns true, they can use it.
		return true
	end, 

	-- In this case, the weapon is Disabled as the function always returns true
	-- You can make items VIP only/admin only by doing something like this:

	function( ply ) -- This is a function used to determine if the player can access the weapon in the loadout menu. If it returns true, they can use it.
		return ply:IsAdmin() or ply:IsVIP()
	end, 

	"Powerful assault rifle.", -- this a description displayed in the menu.

	"Disabled" -- this describes how to unlock the item if you need. otherwise leave "".
},	
]]
loadout = {}
loadout.primary =
{
	{ 	
		"weapon_ttt_m16",

		function( ply )
			return false
		end, 

		"Powerful assault rifle.",

		"Disabled"
	},	

	{ 	
		"weapon_zm_mac10",

		function( ply )
			return false
		end, 

		"Rapid fire SMG, great for fast kills. Mind the mess.",

		"Disabled"
	},	

	{ 	
		"weapon_zm_rifle",

		function( ply )
			return false
		end, 

		"Weapon of choice for long distance picks.",

		"Disabled"
	},		

	{ 	
		"weapon_zm_shotgun",

		function( ply )
			return false
		end, 

		"A powerful semi auto shotgun, one shot kill at point blank.",

		"Disabled"
	},	

	{ 	
		"weapon_zm_sledge",

		function( ply )
			return false
		end, 

		"Spray and pray: the weapon.",

		"Disabled"
	},

}




loadout.secondary = 
{
	{ 	
		"weapon_zm_pistol",

		function( ply )
			return false 
		end, 

		"A reliable sidearm. Large clip with modest damage.",

		"Disabled"
	},

	{ 	
		"weapon_ttt_glock",

		function( ply )
			return true
		end, 

		"A fast firing pistol - reliable as a potato.",

		"Default unlock."
	},

	{ 	
		"weapon_zm_revolver",

		function( ply )
			return false
		end, 

		"A one-shot-headshot weapon. The big boss of sidearms.",

		"Disabled"
	},		

}

loadout.perks =
{

}