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

void() prioritize_targets =
int i; float c_factor, h_factor, w_factor;
{
	//for each self.enemy
	while (i < self.memory)
	{
	//what is it's danger rating?
		other = self.enemy[i];
		if (!(other))
			return;
	//multiply normalized factors: class*health*weapon
	//what's more important, finishing off a weak enemy or fighting a strong one?
		//assign higher danger to hero classes and vehicles
		//work out a tree when enemies and vehicles are more implemented
		if (other.target == monster_human) //target represents a monster_human class. different ways to handle this.
			c_factor = 0.5;
		else c_factor = 1;
		h_factor = TargetHealthPercent; //a qc division function exists but I've not seen it used. only need one decimal point.
		if (other.weapon == weapon_rocket)
			w_factor = 1;
		else w_factor = 0.8;
		other.danger = c_factor * h_factor * w_factor;
		i = i + 1;
	}
};

//monsters request enemies to squad
//maximum memory 8 entities per squad
//memories are prioritized and culled
void(target) request_target =
//int memory = SquadMemory(); possibly a waste of a field as this can be found using C code.
{
	self.memory = self.memory + 1; //how many entities are we tracking?
prioritize_targets();
//apply previous priority to danger
	//+.7; .6; .5; .4; .3; .2; .1; 0; 0;
	//then sort priorities
SortTargets(); //sorting numbers belongs in C code.

if (self.memory > 8)
{
	//cull lowest priority
	self.enemy[self.memory] = 0;
	self.memory = self.memory - 1;
}

//get a target for the requester. not neccessarily the highest priority enemy.

}
//squad gives enemies to monsters
//squad gives additional instructions based on context from encounter

/*Squad Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Squad class which monster classes can attach themselves to. Manages memory and waypoint entities and issues actions with modifiers to monsters.
*/
void() squad =
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

//Encounter states -encounter class
/*Encounter Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Encounter class which squad classes can attach themselves to. Manages encounter states.
*/
void() encounter =
{
	//float squad
	//vec3 origin
	//float winning

	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	//self.squad = squad1; squad2; ...
	//squad utility AI requests to join encounter.
	//monster first requests squad to join encounter.
	//if no encounter exists, it must request a new one be created at its location.

	//strength - full strength 5 in a squad
// if 2 squads in an encounter add up to <= 5 combine the squads.
	
	//what squads are involved in an encounter- this squad plus allies and enemies

	//winning or losing compare to enemy strength
};