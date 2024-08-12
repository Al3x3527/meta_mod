/*
Hierarchical State Machine
-Director AI balances arranges levels-
Spawn locations, overall aggressiveness, music, arranging encounters and AI goals
-Squad Utility AI manages encounters-
Squad class, waypoint class, memory class, issues actions with modifiers, encounter class
-Monster AI react to stimuli-
Senses, priority reactions, animations, mechanics
--ALEX
*/

//make the monsters search for a squad when they spawn. same method as searching for encounters.

void(other, f) assign_danger =
{
	 float c_factor, h_factor, w_factor;
	//multiply normalized factors: class*health*weapon
	//what's more important, finishing off a weak enemy or fighting a strong one?
		//assign higher danger to hero classes and vehicles
		//work out a tree when enemies and vehicles are more implemented
		if (other.target == monster_human) //target represents a monster_human class. different ways to handle this.
			c_factor = 0.5;
		else c_factor = 1;
		h_factor = TargetHealthPercent;
		if (other.weapon == weapon_rocket)
			w_factor = 1;
		else w_factor = 0.8;
		other.danger = c_factor * h_factor * w_factor + f;
};

void() prioritize_targets =
{
//for each self.enemy
	//what is it's danger rating?
	//apply previous priority to danger
//self.enemy.danger = self.enemy.danger + [.7; .6; .5; .4; .3; .2; .1; 0; 0; ]
		assign_danger(self.enemy,.7);
assign_danger(self.enemy1,.6);
assign_danger(self.enemy2,.5);
assign_danger(self.enemy3,.4);
assign_danger(self.enemy4,.3);
assign_danger(self.enemy5,.2);
assign_danger(self.enemy6,.1);
assign_danger(self.enemy7,0);
assign_danger(self.enemy8,0);
};

int(memory) encounter_update =
{
	//self = encounter
	local entity	other_qside, self_qside;
local int	winning;
//update encounter teams (qsides)
//other qside is made up of perceived targets
other_qside.squad = memory.squad.enemy;
//qside.team = qside.squad.team
if (memory.squad.team == self.target.team)
//encounter.target = qside (class) made up of involved squads
self_qside = self.target;
else self_qside = self.target1;
//winning or losing perceived
winning = CompareDanger(other_qside, self_qside);
//re-assign targets to requesting squad
//closest (distance) match to danger algorithm
AssignTargets(other_qside, memory.squad); //remember memories are associated with squad that perceives them
//return the encounter state to the squad for action processing.
return winning;
};

//monster senses a change that demands new priorities
void(memory) sight_update =
{
prioritize_targets();
	
//sort enemies by danger, kill off entities after 8 (.enemy7).
SortAndCull(self.enemy, danger, 8); //SV sort fields containing pointers

//=== can the server process fields with multiple entries or only the map compiler? ===
//I may have to create a fuckton of fields for squad class. (13)

//get a target for the requester. not neccessarily the highest priority enemy.
//then jump into behavior tree
monster_actions(encounter_update(memory),self);
};
//squad gives enemies to monsters
//squad gives additional instructions based on context from encounter

/*Memory Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Memory class for squad knowledge model
*/
void() ai_memory =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
};


/*Squad Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Squad class which monster classes can attach themselves to. Manages memory and waypoint entities and issues actions with modifiers to monsters.
*/
void() ai_squad =
{
	//float squad
	//float encounter_origin

	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

if (!(self.squad)) {
	//generate a unique id based on total monsters spawned and origin
	self.squad = //total monsters + origin as float
}

};

/*Qside Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Qside class which squad classes can attach themselves to in an encounter.
*/
void() ai_qside =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
};

//Encounter states -encounter class
/*Encounter Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Encounter class which squad classes can attach themselves to. Manages encounter states.
*/
void() ai_encounter =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	//squad utility AI requests to join encounter.
	//monster first requests squad to join encounter.
	//if no encounter exists, it must request a new one be created at its location.

// if 2 squads in an encounter add up to <= 5 combine the squads.
};