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
float (entity target) TargetHealthPercent =
{
	local float percent;
percent = target.health / 80;
return percent;
};

void(entity tother, float f) assign_danger =
{
	 float c_factor, h_factor, w_factor;
	//multiply normalized factors: class*health*weapon
	//what's more important, finishing off a weak enemy or fighting a strong one?
		//assign higher danger to hero classes and vehicles
		//work out a tree when enemies and vehicles are more implemented
		if (tother.target == "monster_human") //target represents a monster_human class. 
			c_factor = 0.5;
		else c_factor = 1;
		h_factor = TargetHealthPercent(tother);
		if (tother.weapon == 32)
			w_factor = 1;
		else w_factor = 0.8;
		tother.danger = c_factor * h_factor * w_factor + f;
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

float(entity other_qside, entity self_qside) CompareDanger =
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
else self_qside.squad_state_full = 0; //hack
if (self_qside.squad1)
self_danger = self_danger + self_qside.squad1.danger;
else self_qside.squad_state_full = 0;
if (self_qside.squad2)
self_danger = self_danger + self_qside.squad2.danger;
else self_qside.squad_state_full = 0;
if (self_qside.squad3)
self_danger = self_danger + self_qside.squad3.danger;
else self_qside.squad_state_full = 0;
if (self_qside.squad4)
self_danger = self_danger + self_qside.squad4.danger;
else self_qside.squad_state_full = 0;
if (self_danger > other_danger)
return TRUE;
else return FALSE;
};

//should find closest enemy.
entity (entity tother, entity assign) FindClosest =
{
local entity closest;
local float len, tlen;

if (tother.squad) {
	len = vlen(tother.squad.origin - assign.origin);
	closest = tother.squad;
}
if (tother.squad1) {
	tlen = vlen(tother.squad1.origin - assign.origin);
	if (tlen < len) { //length tvec < vec
		len = tlen;
		closest = tother.squad1;
	}
}
if (tother.squad2) {
	tlen = vlen(tother.squad2.origin - assign.origin);
	if (tlen < len) {
		len = tlen;
		closest = tother.squad2;
	}
}
if (tother.squad3) {
	tlen = vlen(tother.squad3.origin - assign.origin);
	if (tlen < len) {
		len = tlen;
		closest = tother.squad3;
	}
}
if (tother.squad4) {
	tlen = vlen(tother.squad4.origin - assign.origin);
	if (tlen < len) {
		len = tlen;
		closest = tother.squad4;
	}
}
return closest;
};

void (entity tsquad, entity member) RemoveFromSquad = 
{
	local entity null;
	if (tsquad.squad == member) tsquad.squad = null;
else if (tsquad.squad1 == member) tsquad.squad1 = null;
else if (tsquad.squad2 == member) tsquad.squad2 = null;
else if (tsquad.squad3 == member) tsquad.squad3 = null;
else if (tsquad.squad4 == member) tsquad.squad4 = null;
};

void(entity other_qside, entity tsquad) AssignTargets =
{
	local entity temp, temp1, temp2, temp3, temp_squad;
//work from lowest priority up, reassign in passes
	//who is available
temp_squad = tsquad;
	//who is closest, is he stronger
	//who else is next, are they stronger
//closest to enemy0
temp = FindClosest(temp_squad, other_qside.squad);
temp.enemy = other_qside.squad;
RemoveFromSquad(temp_squad, temp);
//who is stronger?
if (temp.danger < other_qside.squad.danger) {
	temp1 = FindClosest(temp_squad, other_qside.squad);
	temp1.enemy = other_qside.squad;
	RemoveFromSquad(temp_squad, temp1);
	if ((temp.danger + temp1.danger) < other_qside.squad.danger) {
		temp2 = FindClosest(temp_squad, other_qside.squad);
		temp2.enemy = other_qside.squad;
		RemoveFromSquad(temp_squad, temp2);
		if ((temp.danger + temp1.danger + temp2.danger) < other_qside.squad.danger) {
			temp3 = FindClosest(temp_squad, other_qside.squad);
			temp3.enemy = other_qside.squad;
			RemoveFromSquad(temp_squad, temp3);
		}
	}
}

//unassigned
if (!(tsquad.squad.enemy)) tsquad.squad.enemy = FindClosest(other_qside, tsquad.squad);
if (!(tsquad.squad1.enemy)) tsquad.squad1.enemy = FindClosest(other_qside, tsquad.squad1);
if (!(tsquad.squad2.enemy)) tsquad.squad2.enemy = FindClosest(other_qside, tsquad.squad2);
if (!(tsquad.squad3.enemy)) tsquad.squad3.enemy = FindClosest(other_qside, tsquad.squad3);
if (!(tsquad.squad4.enemy)) tsquad.squad4.enemy = FindClosest(other_qside, tsquad.squad4);
};

void() start_encounter =
{
	entity n_encounter;
n_encounter.classname = "ai_encounter";
self.squad.encounter = n_encounter;
/*
if (self.squad.squad) self.squad.squad.encounter = encounter;
if (self.squad.squad1) self.squad.squad1.encounter = encounter;
if (self.squad.squad2) self.squad.squad2.encounter = encounter;
if (self.squad.squad3) self.squad.squad3.encounter = encounter;
if (self.squad.squad4) self.squad.squad4.encounter = encounter;
*/
};

float(entity memory) encounter_update =
{
	local entity	other_qside, self_qside, tencounter;
//self is some monster at this point
	if (!(self.squad.enemy)) { remove(self.squad.encounter); return; }
	if (!(self.encounter)) { start_encounter(); }
local float	state_winning;
tencounter = self.squad.encounter;
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
if (memory.squad.team == tencounter.squad.team)
//encounter.squad(1) = qside (class) containing a squad or percieved squad
self_qside = tencounter.squad;
else self_qside = tencounter.squad1;
//winning or losing perceived
state_winning = CompareDanger(other_qside, self_qside);
//re-assign targets to requesting squad
//closest (distance) match to danger algorithm
AssignTargets(other_qside, memory.squad); //remember memories are associated with squad that perceives them
//return the encounter state to the squad for action processing.
return state_winning;
};

void(entity enemy, entity  temp, entity  temp1, entity  temp2, entity  temp3, entity  temp4, entity  temp5, entity  temp6, entity  temp7, entity  temp8) SortEnemy =
{
	local entity null;
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
void(entity memory) sight_update =
{
prioritize_targets();
	
//sort enemies by danger, kill off entities after 8 (remove(self.enemy8)).
SortEnemies(); //SV sort fields containing pointers

//get a target for the requester. not neccessarily the highest priority enemy.
//then jump into behavior tree
squad_action(encounter_update(memory));
};
//squad gives enemies to monsters
//squad gives additional instructions based on context from encounter

//at the beginning of an action. memories are shared in sqaud.
void(entity target) update_memory =
{
 entity memory;
memory = target; //real target
memory.classname = "ai_memory";
memory.squad = self.squad;
if (self.enemy.enemy == target) { //cleanup for ai_run
	remove(self.enemy); //old memory
}
sight_update(memory);
};

/*Memory Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Memory class for squad knowledge model
*/
void() ai_memory =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
};

vector (float dist, entity  target) waypoint_offset =
{
	local vector vec, d, b;
vec = target.origin - self.origin;
d = normalize(vec) * dist;
b_x = -d_y;
b_y = d_x;
//offset waypoint.origin by offset normal to vector, abs of offset along vector from target.origin
if (dist > 0)
vec = target.origin + d + b;
else
vec = target.origin - d + b;
return vec;
};

/*Waypoint Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Waypoint class for squad tactics
*/
void() ai_waypoint =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
};

//start squad called in walkmonster_start
void() start_squad =
{
	entity tsquad;
tsquad.classname = "ai_squad";
tsquad.squad_state_full = 0;
self.squad = tsquad;
tsquad.squad = self;
}

void (entity tother) squad_fit =
{
if (tother.squad.squad) {
	//assign squad to others
	tother.squad = self.squad;
	//assign others to squad slots
	if (!(other)) self.squad.squad = other;
	else if (!(self.squad.squad1)) self.squad.squad1 = tother;
	else if (!(self.squad.squad2)) self.squad.squad2 = tother;
	else if (!(self.squad.squad3)) self.squad.squad3 = tother;
	else if (!(self.squad.squad4)) self.squad.squad4 = tother;
	}
};

//squad check merge. self = seer, other = seen, team checked
void(entity tother) squad_check_merge =
{
	local float self_count, other_count;
if (self.squad.squad_state_full) return;
if (tother.squad.squad_state_full) return;
//self count
if (self.squad.squad) self_count = self_count + 1;
if (self.squad.squad1) self_count = self_count + 1;
if (self.squad.squad2) self_count = self_count + 1;
if (self.squad.squad3) self_count = self_count + 1;
if (self.squad.squad4) self_count = self_count + 1;
//other count
if (tother.squad.squad) other_count = other_count + 1;
if (tother.squad.squad1) other_count = other_count + 1;
if (tother.squad.squad2) other_count = other_count + 1;
if (tother.squad.squad3) other_count = other_count + 1;
if (tother.squad.squad4) other_count = other_count + 1;
//can squads merge?
if ((self_count + other_count) <= 5) {
	if ((self_count + other_count) == 5) self.squad.squad_state_full = 0;
	squad_fit(other.squad.squad);
	squad_fit(other.squad.squad1);
	squad_fit(other.squad.squad2);
	squad_fit(other.squad.squad3);
	squad_fit(other.squad.squad4);
}
};

/*Squad Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Squad class which monster classes can attach themselves to. Manages memory and waypoint entities and issues actions with modifiers to monsters.
*/
void() ai_squad =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
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