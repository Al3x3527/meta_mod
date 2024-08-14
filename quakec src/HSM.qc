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

//temp
float (target) TargetHealthPercent =
{
	local float percent;
percent = target.health / 80;
return percent;
};

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
		h_factor = TargetHealthPercent(other);
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
	if (self.enemy)
		assign_danger(self.enemy,.7);
if (self.enemy1)
assign_danger(self.enemy1,.6);
if (self.enemy2)
assign_danger(self.enemy2,.5);
if (self.enemy3)
assign_danger(self.enemy3,.4);
if (self.enemy4)
assign_danger(self.enemy4,.3);
if (self.enemy5)
assign_danger(self.enemy5,.2);
if (self.enemy6)
assign_danger(self.enemy6,.1);
if (self.enemy7)
assign_danger(self.enemy7,0);
if (self.enemy8)
assign_danger(self.enemy8,0);
};

float(other_qside, self_qside) CompareDanger =
{
	local float other_danger, self_danger;
//other_danger = other_qside.squad.danger + other_qside.squad1.danger + other_qside.squad2.danger + other_qside.squad3.danger + other_qside.squad4.danger + other_qside.squad5.danger + other_qside.squad6.danger + other_qside.squad7.danger;
if (other_qside.squad)
other_danger = other_danger + other_qside.squad.danger;
if (other_qside.squad1)
other_danger = other_danger + other_qside.squad1.danger;
if (other_qside.squad2)
other_danger = other_danger + other_qside.squad2.danger;
if (other_qside.squad3)
other_danger = other_danger + other_qside.squad3.danger;
if (other_qside.squad4)
other_danger = other_danger + other_qside.squad4.danger;
if (other_qside.squad5)
other_danger = other_danger + other_qside.squad5.danger;
if (other_qside.squad6)
other_danger = other_danger + other_qside.squad6.danger;
if (other_qside.squad7)
other_danger = other_danger + other_qside.squad7.danger;
//self_danger = self_qside.squad.danger + self_qside.squad1.danger + self_qside.squad2.danger + self_qside.squad3.danger + self_qside.squad4.danger;
if (self_qside.squad)
self_danger = self_danger + self_qside.squad.danger;
if (self_qside.squad1)
self_danger = self_danger + self_qside.squad1.danger;
if (self_qside.squad2)
self_danger = self_danger + self_qside.squad2.danger;
if (self_qside.squad3)
self_danger = self_danger + self_qside.squad3.danger;
if (self_qside.squad4)
self_danger = self_danger + self_qside.squad4.danger;
if (self_danger > other_danger)
return TRUE;
else return FALSE;
};

entity (entity enemy, entity squad) FindClosest =
{
	local vector vec, tvec;
local entity closest;

if (squad.squad) {
	vec = squad.squad.origin - enemy.origin;
	closest = squad.squad;
}
if (squad.squad1) {
	tvec = squad.squad1.origin - enemy.origin;
	if (tvec < vec) {
		vec = tvec;
		closest = squad.squad1;
	}
}
if (squad.squad2) {
	tvec = squad.squad2.origin - enemy.origin;
	if (tvec < vec) {
		vec = tvec;
		closest = squad.squad2;
	}
}
if (squad.squad3) {
	tvec = squad.squad3.origin - enemy.origin;
	if (tvec < vec) {
		vec = tvec;
		closest = squad.squad3;
	}
}
if (squad.squad4) {
	tvec = squad.squad4.origin - enemy.origin;
	if (tvec < vec) {
		vec = tvec;
		closest = squad.squad4;
	}
}
return closest;
}

void(entity other_qside, entity squad) AssignTargets =
{
	local entity assign;
	//who is available
	//who is closest, is he stronger
	//who else is next, are they stronger

if (other_qside.squad) {
	assign = FindClosest(other_qside.squad, squad);
	assign.enemy = other_qside.squad;
}
if (other_qside.squad1) {
	assign = FindClosest(other_qside.squad1, squad);
	assign.enemy = other_qside.squad1;
}
if (other_qside.squad2) {
	assign = FindClosest(other_qside.squad2, squad);
	assign.enemy = other_qside.squad2;
}
if (other_qside.squad3) {
	assign = FindClosest(other_qside.squad3, squad);
	assign.enemy = other_qside.squad3;
}
if (other_qside.squad4) {
	assign = FindClosest(other_qside.squad4, squad);
	assign.enemy = other_qside.squad4;
}
if (other_qside.squad5) {
	assign = FindClosest(other_qside.squad5, squad);
	assign.enemy = other_qside.squad5;
}
if (other_qside.squad6) {
	assign = FindClosest(other_qside.squad6, squad);
	assign.enemy = other_qside.squad6;
}
if (other_qside.squad7) {
	assign = FindClosest(other_qside.squad7, squad);
	assign.enemy = other_qside.squad7;
}

};

float(entity memory) encounter_update =
{
	//self = encounter
	local entity	other_qside, self_qside;
local float	state_winning;
//update encounter teams (qsides)
//other qside is made up of perceived targets
if (memory.squad.enemy)
other_qside.squad = memory.squad.enemy;
if (memory.squad.enemy1)
other_qside.squad1 = memory.squad.enemy1;
if (memory.squad.enemy2)
other_qside.squad2 = memory.squad.enemy2;
if (memory.squad.enemy3)
other_qside.squad3 = memory.squad.enemy3;
if (memory.squad.enemy4)
other_qside.squad4 = memory.squad.enemy4;
if (memory.squad.enemy5)
other_qside.squad5 = memory.squad.enemy5;
if (memory.squad.enemy6)
other_qside.squad6 = memory.squad.enemy6;
if (memory.squad.enemy7)
other_qside.squad7 = memory.squad.enemy7;
//qside.team = qside.squad.team ===fix this part===
if (memory.squad.team == self.squad.team)
//encounter.squad = qside (class) made up of involved squads
self_qside = self.squad;
else self_qside = self.squad1;
//winning or losing perceived
state_winning = CompareDanger(other_qside, self_qside);
//re-assign targets to requesting squad
//closest (distance) match to danger algorithm
AssignTargets(other_qside, memory.squad); //remember memories are associated with squad that perceives them
//return the encounter state to the squad for action processing.
return state_winning;
};

void(enemy, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8) SortEnemy =
{
	if (temp) {enemy = temp;}
if (temp1) {
	if (temp1.danger > enemy.danger) {enemy = temp1;}}
if (temp2) {
	if (temp2.danger > enemy.danger) {enemy = temp2;}}
if (temp3) {
	if (temp3.danger > enemy.danger) {enemy = temp3;}}
if (temp4) {
	if (temp4.danger > enemy.danger) {enemy = temp4;}}
if (temp5) {
	if (temp5.danger > enemy.danger) {enemy = temp5;}}
if (temp6) {
	if (temp6.danger > enemy.danger) {enemy = temp6;}}
if (temp7) {
	if (temp7.danger > enemy.danger) {enemy = temp7;}}
if (temp8) {
	if (temp8.danger > enemy.danger) {enemy = temp8;}}
if (temp == enemy)
temp = null;
else if (temp1 == enemy)
temp1 = null;
else if (temp2 == enemy)
temp2 = null;
else if (temp3 == enemy)
temp3 = null;
else if (temp4 == enemy)
temp4 = null;
else if (temp5 == enemy)
temp5 = null;
else if (temp6 == enemy)
temp6 = null;
else if (temp7 == enemy)
temp7 = null;
else if (temp8 == enemy)
temp8 = null;
};

void() SortEnemies =
{
	local entity temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8, null;
//self.enemy
if (self.enemy) {temp = self.enemy;}
if (self.enemy1) {
	temp1 = self.enemy1;
	if (temp1.danger > self.enemy.danger) {self.enemy = temp1;}}
if (self.enemy2) {
	temp2 = self.enemy2;
	if (temp2.danger > self.enemy.danger) {self.enemy = temp2;}}
if (self.enemy3) {
	temp3 = self.enemy3;
	if (temp3.danger > self.enemy.danger) {self.enemy = temp3;}}
if (self.enemy4) {
	temp4 = self.enemy4;
	if (temp4.danger > self.enemy.danger) {self.enemy = temp4;}}
if (self.enemy5) {
	temp5 = self.enemy5;
	if (temp5.danger > self.enemy.danger) {self.enemy = temp5;}}
if (self.enemy6) {
	temp6 = self.enemy6;
	if (temp6.danger > self.enemy.danger) {self.enemy = temp6;}}
if (self.enemy7) {
	temp7 = self.enemy7;
	if (temp7.danger > self.enemy.danger) {self.enemy = temp7;}}
if (self.enemy8) {
	temp8 = self.enemy8;
	if (temp8.danger > self.enemy.danger) {self.enemy = temp8;}}
if (temp == self.enemy)
temp = null;
else if (temp1 == self.enemy)
temp1 = null;
else if (temp2 == self.enemy)
temp2 = null;
else if (temp3 == self.enemy)
temp3 = null;
else if (temp4 == self.enemy)
temp4 = null;
else if (temp5 == self.enemy)
temp5 = null;
else if (temp6 == self.enemy)
temp6 = null;
else if (temp7 == self.enemy)
temp7 = null;
else if (temp8 == self.enemy)
temp8 = null;
SortEnemy(self.enemy1, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.enemy2, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.enemy3, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.enemy4, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.enemy5, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.enemy6, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.enemy7, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.enemy8, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
remove (self.enemy8);
if (self.enemy7 == self.enemy6) 
self.enemy7 = null;
if (self.enemy6 == self.enemy5) 
self.enemy6 = null;
if (self.enemy5 == self.enemy4) 
self.enemy5 = null;
if (self.enemy4 == self.enemy3) 
self.enemy4 = null;
if (self.enemy3 == self.enemy2) 
self.enemy3 = null;
if (self.enemy2 == self.enemy1) 
self.enemy2 = null;
if (self.enemy1 == self.enemy) 
self.enemy1 = null;
};

//monster senses a change that demands new priorities
void(memory) sight_update =
{
prioritize_targets();
	
//sort enemies by danger, kill off entities after 8 (remove(self.enemy8)).
SortEnemies(); //SV sort fields containing pointers

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

void(offset, target) waypoint_offset =
{
	local vector vec, d;
vec = target.origin - self.origin;
d = normalize(vec) * offset;
//offset waypoint.origin by offset normal to vector, abs of offset along vector from target.origin
if (offset > 0)
self.waypoint.origin = target.origin + d + transpose(d);
else
self.waypoint.origin = target.origin - d + transpose(d); //I think
};

/*Waypoint Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Waypoint class for squad tactics
*/
void() ai_waypoint =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
};

/*Squad Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Squad class which monster classes can attach themselves to. Manages memory and waypoint entities and issues actions with modifiers to monsters.
*/
void() ai_squad =
{
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