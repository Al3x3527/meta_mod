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
if (tother == world) {
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
	if (self.squad.enemy && self.squad.enemy.health <= 0) {remove(self.squad.enemy); dprint("memory no health\n");}
	else assign_danger(self.squad.enemy,.7);
if (self.squad.enemy1) {
	if (self.squad.enemy1.health <= 0) remove(self.squad.enemy1);
	else if (assign_danger(self.squad.enemy1, .6) == FALSE) return FALSE;
}
if (self.squad.enemy2) {
	if (self.squad.enemy2.health <= 0)  remove(self.squad.enemy2); 
	else if (assign_danger(self.squad.enemy2, .5) == FALSE) return FALSE;
}
if (self.squad.enemy3) {
	if (self.squad.enemy3.health <= 0) remove(self.squad.enemy3);
	else if (assign_danger(self.squad.enemy3, .4) == FALSE) return FALSE;
}
if (self.squad.enemy4) {
	if (self.squad.enemy4.health <= 0) remove(self.squad.enemy4);
	else if (assign_danger(self.squad.enemy4, .3) == FALSE) return FALSE;
}
if (self.squad.enemy5) {
	if (self.squad.enemy5.health <= 0) remove(self.squad.enemy5);
	else if (assign_danger(self.squad.enemy5, .2) == FALSE) return FALSE;
}
if (self.squad.enemy6) {
	if (self.squad.enemy6.health <= 0) remove(self.squad.enemy6);
	else if (assign_danger(self.squad.enemy6, .1) == FALSE) return FALSE;
}
if (self.squad.enemy7) {
	if (self.squad.enemy7.health <= 0) remove(self.squad.enemy7);
	else if (assign_danger(self.squad.enemy7, 0) == FALSE) return FALSE;
}
if (self.squad.enemy8) {
	if (self.squad.enemy8.health <= 0) remove(self.squad.enemy8);
	else if (assign_danger(self.squad.enemy8, 0) == FALSE) return FALSE;
}
return TRUE;
};

void() find_sdanger =
{
local float count = FALSE;
local entity sqs;
sqs = self.squad;

if (sqs.squad.health > 0) { assign_danger(sqs.squad, 0); count = TRUE;}
if (sqs.squad1.health > 0) { assign_danger(sqs.squad1, 0); count = TRUE;}
if (sqs.squad2.health > 0) { assign_danger(sqs.squad2, 0); count = TRUE;}
if (sqs.squad3.health > 0) { assign_danger(sqs.squad3, 0); count = TRUE;}
if (sqs.squad4.health > 0) { assign_danger(sqs.squad4, 0); count = TRUE;}
if (!count) { //doesn't work
	dprint("squad is dead\n");
	if (sqs.enemy) remove (sqs.enemy);
	if (sqs.enemy1) remove (sqs.enemy1);
	if (sqs.enemy2) remove (sqs.enemy2);
	if (sqs.enemy3) remove (sqs.enemy3);
	if (sqs.enemy4) remove (sqs.enemy4);
	if (sqs.enemy5) remove(sqs.enemy5);
	if (sqs.enemy6) remove(sqs.enemy6);
	if (sqs.enemy7) remove(sqs.enemy7);
	remove(sqs);
}
};



float(entity oqs, entity sqs) CompareDanger =
{
	local float odanger, sdanger;
if (sqs == world) { return FUBAR; }
if (oqs == world) { return FUBAR; }

if (oqs.squad) odanger = oqs.squad.danger;
if (oqs.squad1) odanger = odanger + oqs.squad1.danger;
if (oqs.squad2) odanger = odanger + oqs.squad2.danger;
if (oqs.squad3) odanger = odanger + oqs.squad3.danger;
if (oqs.squad4) odanger = odanger + oqs.squad4.danger;
if (oqs.squad5) odanger = odanger + oqs.squad5.danger;
if (oqs.squad6) odanger = odanger + oqs.squad6.danger;
if (oqs.squad7) odanger = odanger + oqs.squad7.danger;
find_sdanger();
if (sqs.squad) sdanger = sqs.squad.danger;
if (sqs.squad1) sdanger = sdanger + sqs.squad1.danger;
if (sqs.squad2) sdanger = sdanger + sqs.squad2.danger;
if (sqs.squad3) sdanger = sdanger + sqs.squad3.danger;
if (sqs.squad4) sdanger = sdanger + sqs.squad4.danger;

if (sdanger > odanger) return TRUE;
else return FALSE;
};



//should find closest enemy.
entity (entity ts, entity en) FindClosest =
{
local entity closest;
local float len, tlen;

if (ts.squad) {
	len = vlen(ts.squad.origin - en.origin);
	closest = ts.squad;
}
if (ts.squad1) {
	tlen = vlen(ts.squad1.origin - en.origin);
	if (tlen < len) { //length tvec < vec
		len = tlen;
		closest = ts.squad1;
	}
}
if (ts.squad2) {
	tlen = vlen(ts.squad2.origin - en.origin);
	if (tlen < len) {
		len = tlen;
		closest = ts.squad2;
	}
}
if (ts.squad3) {
	tlen = vlen(ts.squad3.origin - en.origin);
	if (tlen < len) {
		len = tlen;
		closest = ts.squad3;
	}
}
if (ts.squad4) {
	tlen = vlen(ts.squad4.origin - en.origin);
	if (tlen < len) {
		len = tlen;
		closest = ts.squad4;
	}
}
if (closest.squad) {
	//sprint(en.enemy, "FindClosest complete\n");
	return closest;
}
//sprint(en.enemy, "FindClosest Failed\n");
return world;
};

void (entity ts, entity member, entity player) RemoveFromSquad =
{
	entity null = spawn();
if (ts.squad == member) ts.squad = null;
else if (ts.squad1 == member) ts.squad1 = null;
else if (ts.squad2 == member) ts.squad2 = null;
else if (ts.squad3 == member) ts.squad3 = null;
else if (ts.squad4 == member) ts.squad4 = null;
else dprint("RemoveFromSquad Failed\n");
remove(null);
};

void() AssignTargets = 
{
local entity temp, temp1, temp2, temp3, player, sqs, oqs; //temp_squad;
entity temp_squad = spawn();
oqs = self.enemy;
sqs = self.squad;
player = oqs.squad.enemy;
temp_squad.squad = sqs.squad; //up to 5 now of 8 possible.

//sprint(player, temp_squad.squad.classname);
//sprint(player, " is temp_squad.squad\n");
temp_squad.squad1 = sqs.squad1;
temp_squad.squad2 = sqs.squad2;
temp_squad.squad3 = sqs.squad3;
temp_squad.squad4 = sqs.squad4;
//sprint(player, "AssignTargets\n");

temp = FindClosest(temp_squad, oqs.squad);
//sprint(player, temp.classname);
//sprint(player, " is temp\n");
temp.enemy = oqs.squad;
RemoveFromSquad(temp_squad, temp, player);
//sprint(player, "temp removed from temp squad.\n");
//assign up to 3 monsters to the most dangerous enemy

if (temp.danger < oqs.squad.danger && temp1.squad) {
	temp1 = FindClosest(temp_squad, oqs.squad);
	if (temp1 == temp) { dprint("found the same entity\n"); } else if (!temp) { dprint("temp not found\n"); }
	temp1.enemy = oqs.squad;
	RemoveFromSquad(temp_squad, temp1, player);

	if ((temp.danger + temp1.danger) < oqs.squad.danger && temp2.squad) {
		temp2 = FindClosest(temp_squad, oqs.squad);
		temp2.enemy = oqs.squad;
		RemoveFromSquad(temp_squad, temp2, player);

		if ((temp.danger + temp1.danger + temp2.danger) < oqs.squad.danger && temp3.squad) {
			temp3 = FindClosest(temp_squad, oqs.squad);
			temp3.enemy = oqs.squad;
			RemoveFromSquad(temp_squad, temp3, player);
		}
	}
}
//unassigned
if (sqs.squad && !(sqs.squad.enemy)) { sqs.squad.enemy = FindClosest(oqs, sqs.squad);
//sprint(player, "unassigned.\n"); 
}
if (sqs.squad1 && !(sqs.squad1.enemy)) sqs.squad1.enemy = FindClosest(oqs, sqs.squad1);
if (sqs.squad2 && !(sqs.squad2.enemy)) sqs.squad2.enemy = FindClosest(oqs, sqs.squad2);
if (sqs.squad3 && !(sqs.squad3.enemy)) sqs.squad3.enemy = FindClosest(oqs, sqs.squad3);
if (sqs.squad4 && !(sqs.squad4.enemy)) sqs.squad4.enemy = FindClosest(oqs, sqs.squad4);

remove(temp_squad);

};

void() start_encounter =
{
	entity n_encounter = spawn();
n_encounter.classname = "ai_encounter";
n_encounter.origin = self.origin;
self.squad.encounter = n_encounter;
//setmodel(n_encounter, "progs/backpack.mdl");
//setsize(n_encounter, '-16 -16 0', '16 16 56');
n_encounter.solid = SOLID_TRIGGER;

if (self.squad.squad) self.squad.squad.encounter = n_encounter;
if (self.squad.squad1) self.squad.squad1.encounter = n_encounter;
if (self.squad.squad2) self.squad.squad2.encounter = n_encounter;
if (self.squad.squad3) self.squad.squad3.encounter = n_encounter;
if (self.squad.squad4) self.squad.squad4.encounter = n_encounter;
};

float (entity memory) encounter_update =
{
//self is some monster at this point
if (self.squad.encounter) {
	if (!(self.squad.enemy)) { 
		remove(self.squad.encounter); 
	dprint("encounter end");  
	return; }
	remove(self.encounter.enemy);
}
else start_encounter();
//local float	state_winning;
entity	other_qside = spawn();
entity self_qside = spawn();
local entity player, sq;
player = self.squad.enemy.enemy;
sq = self.squad;
//oself = self;
self = self.encounter;

self.enemy = other_qside; //encounter.enemy is virtual enemy squad
//self.squad = self_qside;
self.squad = sq;
other_qside.classname = "ai_squad";
//self_qside.classname = "ai_squad";
//update encounter teams (qsides)
if (sq.enemy.health > 0) other_qside.squad = sq.enemy;
if (sq.enemy1.health > 0) other_qside.squad1 = sq.enemy1;
if (sq.enemy2.health > 0) other_qside.squad2 = sq.enemy2;
if (sq.enemy3.health > 0) other_qside.squad3 = sq.enemy3;
if (sq.enemy4.health > 0) other_qside.squad4 = sq.enemy4;
if (sq.enemy5.health > 0) other_qside.squad5 = sq.enemy5;
if (sq.enemy6.health > 0) other_qside.squad6 = sq.enemy6;
if (sq.enemy7.health > 0) other_qside.squad7 = sq.enemy7;
AssignTargets();
//sprint(player, "back to encounter update.\n");
return CompareDanger(other_qside, self_qside);//state_winning;
};


entity (entity  temp, entity  temp1, entity  temp2, entity  temp3, entity  temp4, entity  temp5, entity  temp6, entity  temp7, entity  temp8) SortEnemy =
{
	local entity field;
	entity null = spawn();
//if (!field) {
	field = temp8;
//}
	if (temp.danger) { field = temp;}
if (temp1.danger) {
	if (temp1.danger > field.danger) { field = temp1;} 
	//sprint(field.enemy, "field = temp1\n");
}
if (temp2.danger) {
	if (temp2.danger > field.danger) { field = temp2;}}
if (temp3.danger) {
	if (temp3.danger > field.danger) { field = temp3;}}
if (temp4.danger) {
	if (temp4.danger > field.danger) { field = temp4;}}
if (temp5.danger) {
	if (temp5.danger > field.danger) { field = temp5;}}
if (temp6.danger) {
	if (temp6.danger > field.danger) { field = temp6;}}
if (temp7.danger) {
	if (temp7.danger > field.danger) { field = temp7;}}
if (temp8.danger) {
	if (temp8.danger > field.danger) { field = temp8; 
	//sprint(field.enemy, "field = temp8\n");
	}
}
if (temp8 == field) {
	temp8 = null;
	//sprint(temp8.enemy, "temp8.enemy = null?\n");
} else if (temp7 == field) temp7 = null;
else if (temp6 == field) temp6 = null;
else if (temp5 == field) temp5 = null;
else if (temp4 == field) temp4 = null;
else if (temp3 == field) temp3 = null;
else if (temp2 == field) temp2 = null;
else if (temp1 == field) temp1 = null;
else temp = null;
remove(null);
return(field);
}


void() SortEnemies = 
{
local entity temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8;
local entity sq;
sq = self.squad;
//self.enemy
entity null = spawn();
//sprint(self.squad.enemy8.enemy, "self.squad.enemy8.enemy\n"); //works
if (sq.enemy) {temp = sq.enemy;}
if (sq.enemy1.health > 0) {
	temp1 = sq.enemy1;
}
if (sq.enemy2) {
	temp2 = sq.enemy2;
	}
if (sq.enemy3) {
	temp3 = sq.enemy3;
	}
if (sq.enemy4) {
	temp4 = sq.enemy4;
	}
if (sq.enemy5) {
	temp5 = sq.enemy5;
}
if (sq.enemy6) {
	temp6 = sq.enemy6;
}
if (sq.enemy7) {
	temp7 = sq.enemy7;
	}
if (sq.enemy8) {
	temp8 = sq.enemy8;
	}

sq.enemy = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
//sprint(sq.enemy.enemy, "sq.enemy.enemy\n");
sq.enemy1 = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
sq.enemy2 = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
sq.enemy3 = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
sq.enemy4 = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
sq.enemy5 = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
sq.enemy6 = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);
sq.enemy7 = SortEnemy(temp, temp1, temp2, temp3, temp4, temp5, temp6, temp7, temp8);

if (sq.enemy8.enemy != sq.enemy7.enemy)
remove (sq.enemy8);
if (sq.enemy8.enemy == sq.enemy7.enemy)
sq.enemy8 = null;
if (sq.enemy7.enemy == sq.enemy6.enemy)
sq.enemy7 = null;
if (sq.enemy6.enemy == sq.enemy5.enemy)
sq.enemy6 = null;
if (sq.enemy5.enemy == sq.enemy4.enemy)
sq.enemy5 = null;
if (sq.enemy4.enemy == sq.enemy3.enemy)
sq.enemy4 = null;
if (sq.enemy3.enemy == sq.enemy2.enemy)
sq.enemy3 = null;
if (sq.enemy2.enemy == sq.enemy1.enemy)
sq.enemy2 = null;
if (sq.enemy1.enemy == sq.enemy.enemy)
sq.enemy1 = null;
remove(null);
//sprint(sq.enemy.enemy, "sq.enemy.enemy\n");
};


//monster senses a change that demands new priorities
void(entity memory) sight_update =
{
local float state_winning; //debug
local entity oself;
oself = self;

if (self.squad) self.squad.enemy8 = memory;
else return;
if (prioritize_targets() == FALSE) {
	dprint("prioritize targets failed\n");
	return; //still works
}

//sort enemies by danger, kill off entities after 8 (remove(self.enemy8)).
if (memory) SortEnemies();
else return;
//sprint(self.squad.enemy.enemy, "sort complete\n"); //the sort doesn't work. spawn() temporaries

//get a target for the requester. not neccessarily the highest priority enemy.
//then jump into behavior tree
if (memory) state_winning = encounter_update(memory);
else return;
if (state_winning == FUBAR) dprint("state_winning is FUBAR");
//sprint(memory.enemy, "encounter update complete\n");
//self.enemy = memory;//debug only.

if (oself) squad_fight(); //test
else return;
//squad_action(encounter_update(memory));
self = oself;
};
//squad gives enemies to monsters
//squad gives additional instructions based on context from encounter



//at the beginning of an action. memories are shared in sqaud.
void(entity new_target) update_memory =
{
	//if (new_target.classname != "player") {
		//sprint(self.enemy.enemy, "memory update failed\n");
	//	return;
//}
	//dprint("update memory\n");
 if (self.enemy.enemy != new_target) {
	entity new_memory = spawn();
	new_memory.classname = "ai_memory";
	//setmodel(new_memory, "progs/armor.mdl"); //debug
	//setsize(new_memory, '-16 -16 0', '16 16 56');
	new_memory.solid = SOLID_TRIGGER;//SOLID_NOT;

	new_memory.movetype = MOVETYPE_NONE;
	new_memory.target = new_target.classname;
	new_memory.enemy = new_target;
	new_memory.team = new_target.team;
	new_memory.squad = self.squad;

	new_memory.origin = new_target.origin + '0 0 12';
	new_memory.health = new_target.health;
	
	sight_update(new_memory);
}
 else if (self.enemy.classname == "ai_memory") { //cleanup for ai_run
	//remove(self.enemy); //old memory
	 local entity memory;
	 memory = self.enemy;

	 memory.origin = new_target.origin + '0 0 12';
	 memory.health = new_target.health;
	 //memory.velocity = new_target.velocity;
	// sprint(new_target, "memory updated\n");
	 sight_update(memory);
 }
 //else crash probably
};


/*Memory Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Memory class for squad knowledge model
*/
void() ai_memory =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
};

void() create_waypoint = 
{
	entity new_waypoint = spawn();
	new_waypoint.classname = "ai_waypoint";
	//setmodel(new_waypoint, "progs/backpack.mdl");
	//setsize(new_waypoint, '-16 -16 0', '16 16 56');
	new_waypoint.solid = SOLID_TRIGGER;

	if (self.waypoint) { remove(self.waypoint); }
	self.waypoint = new_waypoint;
	self.goalentity = new_waypoint;
};

vector (float dist, entity  target) waypoint_offset = //untested
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

vector (float dist) waypoint_cast =
{
	local vector vec;
local float d;
d = dist + 48 * random();
makevectors(self.v_angle);
vec = (self.origin + v_forward * d);
return vec;
}


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
new_squad.squad = self; //unexpected behavior.

new_squad.solid = SOLID_NOT;
new_squad.movetype = MOVETYPE_NONE;
}

void(entity mobot) mobot_squad = 
{
	entity new_squad = spawn();
new_squad.classname = "ai_squad";
new_squad.squad_state_full = FALSE;
mobot.squad = new_squad;
new_squad.squad = mobot; //unexpected behavior.

new_squad.solid = SOLID_NOT;
new_squad.movetype = MOVETYPE_NONE;

new_squad.nextthink = time + 0.4;
new_squad.think = squad_spawn;
}


void (entity request) squad_fit =
{
	request.squad = self.squad;
	if (!(self.squad.squad)) self.squad.squad = request;
	else if (!(self.squad.squad1)) self.squad.squad1 = request;
	else if (!(self.squad.squad2)) self.squad.squad2 = request;
	else if (!(self.squad.squad3)) self.squad.squad3 = request;
	else if (!(self.squad.squad4)) self.squad.squad4 = request;
	else {
		dprint("squad fit failed\n"); 
	}
	//sprint(self.enemy.enemy, "squad merged\n");
};


//squad check merge. self = seer, request = seen, team checked
void(entity request) squad_check_merge =
{
	//dprint("squad check merge\n");
	local float self_count, other_count;
local entity os;
if (request.squad.squad_state_full) return;
if (request.squad == self.squad) return;
if (!request.squad) return;
os = request.squad;

self_count = 0;
//self count
if (self.squad.squad) self_count = self_count + 1;
if (self.squad.squad1) self_count = self_count + 1;
if (self.squad.squad2) self_count = self_count + 1;
if (self.squad.squad3) self_count = self_count + 1;
if (self.squad.squad4) self_count = self_count + 1;
if (self_count == 5) { self.squad.squad_state_full = TRUE; return; }
other_count = 0;
//other count
if (request.squad.squad) other_count = other_count + 1;
if (request.squad.squad1) other_count = other_count + 1;
if (request.squad.squad2) other_count = other_count + 1;
if (request.squad.squad3) other_count = other_count + 1;
if (request.squad.squad4) other_count = other_count + 1;
//can squads merge?
if ((self_count + other_count) <= 5) {
	self.squad.squad_state_full = TRUE;
	if (os.squad) squad_fit(os.squad) ;
	if (os.squad1) squad_fit(os.squad1);
	if (os.squad2) squad_fit(os.squad2);
	if (os.squad3) squad_fit(os.squad3);
	if (os.squad4) squad_fit(os.squad4);
	remove(os);
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