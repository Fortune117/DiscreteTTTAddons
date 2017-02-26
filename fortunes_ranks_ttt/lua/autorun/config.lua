-- this is where medals are added
-- here is an example:
--[[
MEDAL.example_medal = 
{
	name = "Example", -- The medals name
	desc = "Got an example medal.", -- How you get it
	mat = Material( "medals/kill.png", "noclamp smooth nocull" ), -- the material used for it
	sound = nil, -- sound to play when you get it
	value = 10 -- how much XP it should give you
}

could be given to a player with:
player:GiveXP( "example_medal" )

]]
MEDAL = {}

MEDAL.DoubleKill = 
{
	name = "Double Kill",
	desc = "Get two kills within 4 seconds of each other.",
	mat = Material( "medals/doublekill.png", "noclamp smooth nocull" ),
	sound = Sound( "medals/doublekill.wav" ),
	value = 15
}
MEDAL.TripleKill =
{
	name = "Triple Kill",
	desc = "Get three kills, each within 4 seconds of each other.",
	mat =  Material( "medals/triplekill.png", "noclamp smooth" ), 
	sound = Sound( "medals/triplekill.wav" ),
	value = 30
}
MEDAL.OverKill =
{
	name = "Overkill",
	desc = "Get four kills, each within 4 seconds of each other.",
	mat = Material( "medals/overkill.png", "noclamp smooth" ), 
	sound = Sound( "medals/overkill.wav" ),
	value = 45
}
MEDAL.Killtacular =
{
	name = "Killtacular",
	desc = "Get five kills, each within 4 seconds of each other.",
	mat = Material( "medals/killtacular.png", "noclamp smooth" ), 
	sound = Sound( "medals/killtacular.wav" ),
	value = 60
}
MEDAL.Killtrocity =
{
	name = "Killtrocity",
	desc = "Get six kills, each within 4 seconds of each other.",
	mat = Material( "medals/killtrocity.png", "noclamp smooth" ), 
	sound = Sound( "medals/killtrocity.wav" ),
	value = 75
}
MEDAL.Killimanjaro =
{
	name = "Killimanjaro",
	desc = "Get seven kills, each within 4 seconds of each other.",
	mat = Material( "medals/killamanjaro.png", "noclamp smooth" ), 
	sound = Sound( "medals/killamanjaro.wav" ),
	value = 90
}
MEDAL.Killtastrophe =
{
	name = "Killtastrophe",
	desc = "Get eight kills, each within 4 seconds of each other.",
	mat = Material( "medals/killtastrophe.png", "noclamp smooth" ), 
	sound = Sound( "medals/killtastrophe.wav" ),
	value = 105
}
MEDAL.Killpocalypse =
{
	name = "Killpocalypse",
	desc = "Get nine kills, each within 4 seconds of each other.",
	mat = Material( "medals/killpocalypse.png", "noclamp smooth" ), 
	sound = Sound( "medals/killpocalypse.wav" ),
	value = 120
}
MEDAL.Killionaire =
{
	name = "Killionaire",
	desc = "Get 10 kills, each within 4 seconds of each other.",
	mat = Material( "medals/killionaire.png", "noclamp smooth" ), 
	sound = Sound( "medals/killionaire.wav" ),
	value = 135
}
MEDAL.Assist =
{
	name = "Assist",
	desc = "Assist in killing another player.", 
	mat = Material( "medals/assist.png", "noclamp smooth" ), 
	sound = nil,
	value = 15 
}
MEDAL.Avenger =
{
	name = "Avenger",
	desc = "Kill a player who has just killed one of your allies.",
	mat = Material( "medals/avenger.png", "noclamp smooth" ), 
	sound = nil,
	value = 15
}
MEDAL.KnifeKill =
{
	name = "Backstabber",
	desc = "Kill a player with a knife.",
	mat = Material( "medals/knife.png", "noclamp smooth" ), 
	sound = nil,
	value = 15 
}
MEDAL.Survivor =
{
	name = "Survivor",
	desc = "Survive the round as an innocent.",
	mat = Material( "medals/survivor.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 20
}
MEDAL.KillJoy =
{
	name = "Killjoy",
	desc = "Defeat all the Detectives as a traitor.",
	mat = Material( "medals/killjoy.png", "noclamp smooth" ), 
	sound = nil,
	value = 30 
}
MEDAL.Extermination =
{
	name = "Extermination",
	desc = "Defeat all the innocents as a traitor.",
	mat =  Material( "medals/exterm.png", "noclamp smooth" ),   
	sound = nil,
	value = 30
}
MEDAL.Angel =
{
	name = "Guardian Angel",
	desc = "Save a teammate over a large distance.",
	mat = Material( "medals/angel.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 25
}
MEDAL.Protector =
{
	name = "Protector",
	desc = "Save a teammate who is under attack.",
	mat = Material( "medals/protector.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 20
}
MEDAL.CloseCall =
{
	name = "Close Call",
	desc = "Kill an enemy while on very low hp.",
	mat = Material( "medals/closecall.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 35
}
MEDAL.Distraction =
{
	name = "Distraction",
	desc = "Distract an enemy and have your teammate kill them.",
	mat = Material( "medals/distraction.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 20
}
MEDAL.SniperKill =
{
	name = "Sniper Kill",
	desc = "Get a kill with a sniper rifle.",
	mat = Material( "medals/sniper_kill.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 30
}
MEDAL.Snapshot =
{
	name = "Snapshot",
	desc = "Kill an enemy with the sniper, without using your scope.",
	mat = Material( "medals/snapshot.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 45
}
MEDAL.Pummel =
{
	name = "Pummel",
	desc = "Kill an enemy with melee.",
	mat = Material( "medals/melee.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 50
}
MEDAL.Headshot =
{
	name = "Headshot",
	desc = "Kill an enemy with a headshot.",
	mat = Material( "medals/headshot.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 50
}
MEDAL.Headcase =
{
	name = "Headcase",
	desc = "Kill a fast moving enemy with a headshot.",
	mat =  Material( "medals/headcase.png", "noclamp smooth" ), 
	sound = nil,
	value = 70
}
MEDAL.Kill =
{
	name = "Kill",
	desc = "Kill an enemy.",
	mat = Material( "medals/kill.png", "noclamp smooth" ),  
	sound = nil,
	value = 35,
	value = 35
}
MEDAL.ShowStopper =
{
	name = "Show Stopper",
	desc = "Kill an enemy who has a knife out.",
	mat = Material( "medals/show_stopper.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 50
}
MEDAL.Splatter =
{
	name = "Splattered",
	desc = "Propkill an enemy.",
	mat = Material( "medals/splatter.png", "noclamp smooth" ), 
	sound = nil,
	value = 65
}
MEDAL.FirstStrike =
{
	name = "First Strike",
	desc = "Get the first kill of the round as traitor.",
	mat = Material( "medals/first_strike.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 70
}
MEDAL.LastStrike =
{
	name = "Last Strike",
	desc = "Get the last kill of the round as traitor.",
	mat = Material( "medals/last_strike.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 70
}
MEDAL.Grave =
{
	name = "Beyond the Grave",
	desc = "Get a kill post mortem.",
	mat = Material( "medals/grave.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 60
}
MEDAL.Beatdown =
{
	name = "Sneaky",
	desc = "Kill an enemy while they're not looking at you.",
	mat = Material( "medals/beatdown.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 40
}
MEDAL.GrenadeKill =
{
	name = "Grenadier",
	desc = "Kill an enemy with an explosion.",
	mat = Material( "medals/grenade_kill.png", "noclamp smooth nocull" ),
	sound = nil,
	value = 40
}