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

float(entity tother, float f) assign_danger =
{
	 float c_factor, h_factor, w_factor;
	//multiply normalized factors: class*health*weapon
	//what's more important, finishing off a weak enemy or fighting a strong one?
		//assign higher danger to hero classes and vehicles
		//work out a tree when enemies and vehicles are more implemented
if (!tother) { //dprint("bad target"); 
return FALSE; }
if (tother == world) { //dprint("bad target1"); 
return FALSE; }
		if (tother.target == "monster_human") //target represents a monster_human class. 
			c_factor = 0.5;
		else c_factor = 1;
		h_factor = TargetHealthPercent(tother);
		if (tother.weapon == 32)
			w_factor = 1;
		else w_factor = 0.8;
		tother.danger = c_factor * h_factor * w_factor + f;
		return TRUE;
};

float() prioritize_targets =
{
//for each self.enemy
	//what is it's danger rating?
	//apply previous priority to danger
//self.enemy.danger = self.enemy.danger + [.7; .6; .5; .4; .3; .2; .1; 0; 0; ]
	if (self.squad.enemy)
		assign_danger(self.squad.enemy,.7);
if (self.squad.enemy1)
	if (assign_danger(self.squad.enemy1,.6) == FALSE) return FALSE;
if (self.squad.enemy2)
	if (assign_danger(self.squad.enemy2,.5) == FALSE) return FALSE;
if (self.squad.enemy3)
	if (assign_danger(self.squad.enemy3,.4) == FALSE) return FALSE;
if (self.squad.enemy4)
	if (assign_danger(self.squad.enemy4,.3) == FALSE) return FALSE;
if (self.squad.enemy5)
	if (assign_danger(self.squad.enemy5,.2) == FALSE) return FALSE;
if (self.squad.enemy6)
	if (assign_danger(self.squad.enemy6,.1) == FALSE) return FALSE;
if (self.squad.enemy7)
	if (assign_danger(self.squad.enemy7,0) == FALSE) return FALSE;
if (self.squad.enemy8)
	if (assign_danger(self.squad.enemy8,0) == FALSE) return FALSE;
return TRUE;
};



float(entity other_qside, entity self_qside) CompareDanger =
{
	local float other_danger, self_danger;
if (self_qside == world) { return FUBAR; }
if (other_qside == world) { return FUBAR; }
//other_danger = other_qside.squad.danger + other_qside.squad1.danger + other_qside.squad2.danger + other_qside.squad3.danger + other_qside.squad4.danger + other_qside.squad5.danger + other_qside.squad6.danger + other_qside.squad7.danger;
if (other_qside.squad)
other_danger = other_qside.squad.danger;
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
self_danger = self_qside.squad.danger;
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



//should find closest enemy.
entity (entity temp_squad, entity assign) FindClosest =
{
local entity closest;
local float len, tlen;

if (temp_squad.squad) {
	len = vlen(temp_squad.squad.origin - assign.origin);
	closest = temp_squad.squad;
}
if (temp_squad.squad1) {
	tlen = vlen(temp_squad.squad1.origin - assign.origin);
	if (tlen < len) { //length tvec < vec
		len = tlen;
		closest = temp_squad.squad1;
	}
}
if (temp_squad.squad2) {
	tlen = vlen(temp_squad.squad2.origin - assign.origin);
	if (tlen < len) {
		len = tlen;
		closest = temp_squad.squad2;
	}
}
if (temp_squad.squad3) {
	tlen = vlen(temp_squad.squad3.origin - assign.origin);
	if (tlen < len) {
		len = tlen;
		closest = temp_squad.squad3;
	}
}
if (temp_squad.squad4) {
	tlen = vlen(temp_squad.squad4.origin - assign.origin);
	if (tlen < len) {
		len = tlen;
		closest = temp_squad.squad4;
	}
}
if (closest.squad) {
	//sprint(assign.enemy, "FindClosest\n");
}
return closest;
};

void (entity temp_squad, entity member, entity player) RemoveFromSquad =
{
	entity null = spawn();
if (temp_squad.squad) {
	if (temp_squad.squad == member) {
		temp_squad.squad = null;
		remove(null);
		sprint(player, "squad\n");
		return;
	}
}
if (temp_squad.squad1) {
	if (temp_squad.squad1 == member) {
		temp_squad.squad1 = null;
		remove(null);
		sprint(player, "squad1\n");
		return;
	}
}
if (temp_squad.squad2) {
	if (temp_squad.squad2 == member) {
		temp_squad.squad2 = null;
		remove(null);
		sprint(player, "squad2\n");
		return;
	}
}
if (temp_squad.squad3) {
	if (temp_squad.squad3 == member) {
		temp_squad.squad3 = null;
		remove(null);
		sprint(player, "squad3\n");
		return;
	}
}
if (temp_squad.squad4) {
	if (temp_squad.squad4 == member) {
		temp_squad.squad4 = null;
		remove(null);
		sprint(player, "squad4\n");
		return;
	}
}
	remove(null);
	sprint(player, "RemoveFromSquad Failed\n");
};

void(entity other_qside, entity self_squad) AssignTargets = 
{
	local entity temp, temp1, temp2, temp3, player; //temp_squad;
	//entity temp = spawn();
//entity temp1 = spawn();
//entity temp2 = spawn();
//entity temp3 = spawn();
entity temp_squad = spawn();
//entity null = spawn();
//work from lowest priority up, reassign in passes
	//who is available
temp_squad = self_squad;
player = other_qside.squad.enemy;
	//who is closest, is he stronger
	//who else is next, are they stronger
//closest to enemy0
temp = FindClosest(temp_squad, other_qside.squad);
/*if (temp.squad) { //now this part crashes.
	sprint(other_qside.squad.enemy, "temp\n");
}
else sprint(other_qside.squad.enemy, "no temp\n");*/
//temp = temp_squad.squad; //test
temp.enemy = other_qside.squad; 
//sprint(temp.enemy.enemy, "temp.enemy.enemy\n");
RemoveFromSquad(temp_squad, temp, player);
sprint(player, "temp removed from temp squad.\n");
//who is stronger?

if (temp.danger < other_qside.squad.danger) {
	temp1 = FindClosest(temp_squad, other_qside.squad);
	temp1.enemy = other_qside.squad;
	//sprint(player, "temp1.enemy\n");
	RemoveFromSquad(temp_squad, temp1, player);
	sprint(player, "temp1\n");
	if ((temp.danger + temp1.danger) < other_qside.squad.danger) {
		temp2 = FindClosest(temp_squad, other_qside.squad);
		temp2.enemy = other_qside.squad;
		RemoveFromSquad(temp_squad, temp2, player);
		sprint(player, "temp2\n");
		if ((temp.danger + temp1.danger + temp2.danger) < other_qside.squad.danger) {
			temp3 = FindClosest(temp_squad, other_qside.squad);
			temp3.enemy = other_qside.squad;
			RemoveFromSquad(temp_squad, temp3, player);
			sprint(player, "temp3\n");
		}
	}
}

//unassigned
sprint(player, "unassigned.\n");
if (self_squad.squad && !(self_squad.squad.enemy)) self_squad.squad.enemy = FindClosest(other_qside, self_squad.squad);
if (self_squad.squad1 && !(self_squad.squad1.enemy)) self_squad.squad1.enemy = FindClosest(other_qside, self_squad.squad1);
if (self_squad.squad2 && !(self_squad.squad2.enemy)) self_squad.squad2.enemy = FindClosest(other_qside, self_squad.squad2);
if (self_squad.squad3 && !(self_squad.squad3.enemy)) self_squad.squad3.enemy = FindClosest(other_qside, self_squad.squad3);
if (self_squad.squad4 && !(self_squad.squad4.enemy)) self_squad.squad4.enemy = FindClosest(other_qside, self_squad.squad4);

//remove(temp);
//remove(temp1);
//remove(temp2);
//remove(temp3);
remove(temp_squad);
//temp = null;
//temp1 = null;
//temp2 = null;
//temp3 = null;

sprint(player, "temp squad removed.\n");
//player = null;
//remove(null);
return;
};

void() start_encounter =
{
	entity n_encounter = spawn();
n_encounter.classname = "ai_encounter";
self.squad.encounter = n_encounter;

if (self.squad.squad) self.squad.squad.encounter = n_encounter;
if (self.squad.squad1) self.squad.squad1.encounter = n_encounter;
if (self.squad.squad2) self.squad.squad2.encounter = n_encounter;
if (self.squad.squad3) self.squad.squad3.encounter = n_encounter;
if (self.squad.squad4) self.squad.squad4.encounter = n_encounter;

};



void(entity memory) encounter_update =
{
//self is some monster at this point
if (self.squad.encounter) { //self = monster
	if (!(self.squad.enemy)) { 
		remove(self.squad.encounter); 
	sprint(self.squad.enemy, "encounter end");  
	return; }
	remove(self.squad.encounter.enemy);
	remove(self.squad.encounter.squad);
}
else start_encounter();
local float	state_winning;
entity	other_qside = spawn();
entity self_qside = spawn();
self.encounter.enemy = other_qside;
self.encounter.squad = self_qside;
other_qside.classname = "ai_squad";
self_qside.classname = "ai_squad";
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
self_qside = self.squad;
//winning or losing perceived
state_winning = CompareDanger(other_qside, self_qside);
if (state_winning == FUBAR) {
	sprint(memory.enemy, "CompareDanger is FUBAR\n"); 
	return 0;
}
else if (state_winning == 0) {
	sprint(memory.enemy, "Losing\n");
}
else if (state_winning == 1) {
	sprint(memory.enemy, "Winning\n");
}
//re-assign targets to requesting squad
//closest (distance) match to danger algorithm
//AssignTargets(other_qside, memory.squad); //remember memories are associated with squad that perceives them

local entity self_squad;
self_squad = memory.squad;
local entity temp, temp1, temp2, temp3, player; //temp_squad;
	//entity temp = spawn();
//entity temp1 = spawn();
//entity temp2 = spawn();
//entity temp3 = spawn();
entity temp_squad = spawn();
//entity null = spawn();
//work from lowest priority up, reassign in passes
	//who is available
temp_squad = self_squad;
player = other_qside.squad.enemy;
//who is closest, is he stronger
//who else is next, are they stronger
//closest to enemy0
temp = FindClosest(temp_squad, other_qside.squad);
/*if (temp.squad) { //now this part crashes.
	sprint(other_qside.squad.enemy, "temp\n");
}
else sprint(other_qside.squad.enemy, "no temp\n");*/
//temp = temp_squad.squad; //test
temp.enemy = other_qside.squad;
//sprint(temp.enemy.enemy, "temp.enemy.enemy\n");
RemoveFromSquad(temp_squad, temp, player);
sprint(player, "temp removed from temp squad.\n");
//who is stronger?

if (temp.danger < other_qside.squad.danger && temp1.squad) {
	temp1 = FindClosest(temp_squad, other_qside.squad);
	if (temp1 == temp) { sprint(player, "found the same entity\n"); }
	else if (!temp) { sprint(player, "temp not found\n"); }
	temp1.enemy = other_qside.squad;
	if (temp1.enemy) {
		sprint(player, "temp1.enemy\n");
		RemoveFromSquad(temp_squad, temp1, player);
		sprint(player, "temp1\n");
	}
	else sprint(player, "temp1 failed\n");
	if ((temp.danger + temp1.danger) < other_qside.squad.danger && temp2.squad) {
		temp2 = FindClosest(temp_squad, other_qside.squad);
		temp2.enemy = other_qside.squad;
		RemoveFromSquad(temp_squad, temp2, player);
		sprint(player, "temp2\n");
		if ((temp.danger + temp1.danger + temp2.danger) < other_qside.squad.danger && temp3.squad) {
			temp3 = FindClosest(temp_squad, other_qside.squad);
			temp3.enemy = other_qside.squad;
			RemoveFromSquad(temp_squad, temp3, player);
			sprint(player, "temp3\n");
		}
	}
}

//unassigned
//sprint(player, "unassigned.\n");
if (self_squad.squad && !(self_squad.squad.enemy)) self_squad.squad.enemy = FindClosest(other_qside, self_squad.squad);
if (self_squad.squad1 && !(self_squad.squad1.enemy)) self_squad.squad1.enemy = FindClosest(other_qside, self_squad.squad1);
if (self_squad.squad2 && !(self_squad.squad2.enemy)) self_squad.squad2.enemy = FindClosest(other_qside, self_squad.squad2);
if (self_squad.squad3 && !(self_squad.squad3.enemy)) self_squad.squad3.enemy = FindClosest(other_qside, self_squad.squad3);
if (self_squad.squad4 && !(self_squad.squad4.enemy)) self_squad.squad4.enemy = FindClosest(other_qside, self_squad.squad4);

//remove(temp);
//remove(temp1);
//remove(temp2);
//remove(temp3);
remove(temp_squad);
//temp = null;
//temp1 = null;
//temp2 = null;
//temp3 = null;

//sprint(player, "temp squad removed.\n");
//player = null;
//remove(null);

//return the encounter state to the squad for action processing.
sprint(player, "back to encounter update.\n");
//crash here?
//return state_winning;
};


void(entity enemy, entity  temp, entity  temp1, entity  temp2, entity  temp3, entity  temp4, entity  temp5, entity  temp6, entity  temp7, entity  temp8) SortEnemy =
{
	//local entity null;
	entity null = spawn();
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
remove(null);
};


void() SortEnemies = //this works despite passing local entities. probably because they have no relations.
{
	local entity temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8;// null;
//self.enemy
entity null = spawn();
//sprint(self.squad.enemy8.enemy, "self.squad.enemy8.enemy\n"); //works
if (self.squad.enemy) {temp = self.squad.enemy;}
if (self.squad.enemy1) {
	temp1 = self.squad.enemy1;
	if (temp1.danger > self.squad.enemy.danger) {self.squad.enemy = temp1;}}
if (self.squad.enemy2) {
	temp2 = self.enemy2;
	if (temp2.danger > self.squad.enemy.danger) {self.squad.enemy = temp2;}}
if (self.squad.enemy3) {
	temp3 = self.squad.enemy3;
	if (temp3.danger > self.squad.enemy.danger) {self.squad.enemy = temp3;}}
if (self.squad.enemy4) {
	temp4 = self.squad.enemy4;
	if (temp4.danger > self.squad.enemy.danger) {self.squad.enemy = temp4;}}
if (self.squad.enemy5) {
	temp5 = self.squad.enemy5;
	if (temp5.danger > self.squad.enemy.danger) {self.squad.enemy = temp5;}}
if (self.squad.enemy6) {
	temp6 = self.squad.enemy6;
	if (temp6.danger > self.squad.enemy.danger) {self.squad.enemy = temp6;}}
if (self.squad.enemy7) {
	temp7 = self.squad.enemy7;
	if (temp7.danger > self.squad.enemy.danger) {self.squad.enemy = temp7;}}
if (self.squad.enemy8) {
	temp8 = self.squad.enemy8;
	if (temp8.danger > self.squad.enemy.danger) {self.squad.enemy = temp8;}}
if (temp == self.squad.enemy)
temp = null;
else if (temp1 == self.squad.enemy)
temp1 = null;
else if (temp2 == self.squad.enemy)
temp2 = null;
else if (temp3 == self.squad.enemy)
temp3 = null;
else if (temp4 == self.squad.enemy)
temp4 = null;
else if (temp5 == self.squad.enemy)
temp5 = null;
else if (temp6 == self.squad.enemy)
temp6 = null;
else if (temp7 == self.squad.enemy)
temp7 = null;
else if (temp8 == self.squad.enemy)
temp8 = null;
SortEnemy(self.squad.enemy1, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.squad.enemy2, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.squad.enemy3, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.squad.enemy4, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.squad.enemy5, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.squad.enemy6, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.squad.enemy7, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
SortEnemy(self.squad.enemy8, temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
remove (self.squad.enemy8);
if (self.squad.enemy7 == self.enemy6)
self.squad.enemy7 = null;
if (self.squad.enemy6 == self.enemy5)
self.squad.enemy6 = null;
if (self.squad.enemy5 == self.enemy4)
self.squad.enemy5 = null;
if (self.squad.enemy4 == self.enemy3)
self.squad.enemy4 = null;
if (self.squad.enemy3 == self.enemy2)
self.squad.enemy3 = null;
if (self.squad.enemy2 == self.enemy1)
self.squad.enemy2 = null;
if (self.squad.enemy1 == self.enemy)
self.squad.enemy1 = null;
remove(null);
//sprint(self.squad.enemy.enemy, "self.squad.enemy.enemy\n");
};


//monster senses a change that demands new priorities
void(entity memory) sight_update =
{
	if (!self.squad.squad) sprint(memory.enemy, "no squad leader\n");
//else remove(self.squad.squad);
if (!self.squad.squad == self && !self.squad.squad1 == self && !self.squad.squad2 == self && !self.squad.squad3 == self && !self.squad.squad4 == self) {
	sprint(memory.enemy, "squad generation fail\n");
	self.squad.squad = self; //does nothing. need a work around.
}
	local float state_winning; //debug
	//sprint(memory.enemy, "memory.enemy\n");
	self.squad.enemy8 = memory;
if (prioritize_targets() == FALSE) return; //does not break game. does not stop in-fighting.
	
//sort enemies by danger, kill off entities after 8 (remove(self.enemy8)).
SortEnemies(); //SV sort fields containing pointers.
sprint(memory.enemy, "sort complete\n");
//get a target for the requester. not neccessarily the highest priority enemy.
//then jump into behavior tree
encounter_update(memory); //crash sandwiched to here.
sprint(memory.enemy, "encounter update complete\n");

	squad_fight(); //test
//squad_action(encounter_update(memory));
};
//squad gives enemies to monsters
//squad gives additional instructions based on context from encounter



//at the beginning of an action. memories are shared in sqaud.
void(entity new_target) update_memory =
{
	if (!new_target.classname == "player") {
		sprint(self.enemy.enemy, "memory update failed\n");
		return;
}
if (new_target == self.enemy.enemy && self.enemy.classname == "ai_memory") { //cleanup for ai_run
	//remove(self.enemy); //old memory
	local entity memory;
	memory = self.enemy;
}
 else {
	entity memory = spawn();
	//for debug
	//precache_model("progs/e_mdls/human.mdl");
	setmodel(memory, "progs/e_mdls/human.mdl");
	setsize(self, '-16 -16 -32', '16 16 32');
	memory.classname = "ai_memory";
	memory.solid = SOLID_TRIGGER;//SOLID_NOT;
	memory.movetype = MOVETYPE_NONE;
	memory.target = new_target.classname;
	memory.enemy = new_target;
	memory.team = new_target.team;
	memory.squad = self.squad;
}
memory.origin = new_target.origin;
memory.health = new_target.health;
sprint(new_target, "memory updated\n");
sight_update(memory);
};


/*Memory Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Memory class for squad knowledge model
*/
void() ai_memory =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
//debug
precache_body_model("progs/e_mdls/human.mdl");
body_model("progs/e_mdls/human.mdl");
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
	entity new_squad = spawn();
new_squad.classname = "ai_squad";
new_squad.squad_state_full = FALSE;
self.squad = new_squad;
new_squad.squad = self;
if (!self.squad.squad == self) self.squad.squad = self;
new_squad.solid = SOLID_NOT;
new_squad.movetype = MOVETYPE_NONE;
//sprint(other, "squad start"); //will error on level start
}


void (entity request) squad_fit =
{
if (request.squad.squad) {
	//assign squad to other
	request.squad = self.squad;
	//assign others to squad slots
	//if (!(self.squad.squad)) self.squad.squad = request;
	if (!(self.squad.squad1)) self.squad.squad1 = request;
	else if (!(self.squad.squad2)) self.squad.squad2 = request;
	else if (!(self.squad.squad3)) self.squad.squad3 = request;
	else if (!(self.squad.squad4)) self.squad.squad4 = request;
	else return;
	//sprint(self, "squad merged");//want an error
	}
};


//squad check merge. self = seer, request = seen, team checked
void(entity request) squad_check_merge =
{
	sprint(self.enemy.enemy, "check merge\n");
	local float self_count, other_count;
//if (self.squad.squad_state_full) return; figure this out here.
if (request.squad.squad_state_full) return;
//self count
if (self.squad.squad) self_count = self_count + 1;
if (self.squad.squad1) self_count = self_count + 1;
if (self.squad.squad2) self_count = self_count + 1;
if (self.squad.squad3) self_count = self_count + 1;
if (self.squad.squad4) self_count = self_count + 1;
if (self_count == 5) { self.squad.squad_state_full = TRUE; return; }
//other count
if (request.squad.squad) other_count = other_count + 1;
if (request.squad.squad1) other_count = other_count + 1;
if (request.squad.squad2) other_count = other_count + 1;
if (request.squad.squad3) other_count = other_count + 1;
if (request.squad.squad4) other_count = other_count + 1;
//can squads merge?
if ((self_count + other_count) <= 5) {
	if ((self_count + other_count) == 5) self.squad.squad_state_full = TRUE;
	squad_fit(request.squad.squad);
	squad_fit(request.squad.squad1);
	squad_fit(request.squad.squad2);
	squad_fit(request.squad.squad3);
	squad_fit(request.squad.squad4);
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