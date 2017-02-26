The file you'll want to be making new achievements in is sh_achievements. You'll need to know how to code to actually make them though.
It should work for everything, not just TTT. So have fun! (you will need to remove the TTT dependant achievements here first tho)
Here's an example:

-- Here we're defining a table called cData for 'challenge data'.
local cData = 
{
	name = "Baby Steps", -- This is the name of the achievement, what will be displayed in the menu.
	desc = "Kill your first innocent.", -- The description displayed. Use this to explain how to get it.
	goal = 1, -- this ones a little confusing, this is the 'goal'. I'll explain this in the achievement code.
	value = 5, -- how much the achievement is worth
	id = 1 -- the id is important. now unfortunately, you have to do this manually. make sure its a number.
}
/*
the three arguements here are:
	achievement data
	hooks
	functions

how the goal works:
	basically, each achievement assigns a goal value to each player
	in the achievement hook, you can add points to players so as to reach the goal
	in this example the goal is one, and we give them a point for killing someone.

hooks and functions can be a table and it will iterate through them
*/
CHALLENGES.Add( cData, "DoPlayerDeath", function( ply, atk, dmginfo )
	if IsValid( atk ) and atk:IsPlayer() then
		if atk:IsTraitor() then 
			if ply:IsInno() then
				atk:GiveCPoint( cData.id, 1 ) -- This adds 1 point towards the 'goal' value of the achievement.
			end
		end
	end
end)
