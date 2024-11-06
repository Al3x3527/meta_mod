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
float (entity targ) TargetHealthPercent =
{
	local float percent;
percent = targ.health / 80;
return percent;
};

float(entity tother, float f) assign_danger =
{
	 float c_factor, h_factor, w_factor;
	//multiply normalized factors: class*health*weapon
	//what's more important, finishing off a weak enemy or fighting a strong one?
		//assign higher danger to hero classes and vehicles
		//work out a tree when enemies and vehicles are more implemented
if (!tother || tother == world) { 
	dprint("danger bad target\n");
	return FALSE; 
}
if (tother.target == "monster_human") //target represents a monster_human class. 
c_factor = 0.5;
else if (tother.target == "monster_soldier")
c_factor = 0.55;
else if (tother.target == "monster_enforcer")
c_factor = 0.7;
else c_factor = 1;
h_factor = TargetHealthPercent(tother);
//if (tother.weapon == 32)
w_factor = 1;
//else w_factor = 0.8;
tother.danger = c_factor * h_factor * w_factor + f;
return TRUE;
};

float() prioritize_targets =
{
	local entity sq = self;
//dprint("prioritize targets\n");
if (sq.memory) {
	if (sq.memory.health > 0) { 
	//	dprint("memory assign danger\n");
		assign_danger(sq.memory, .7); 
	}
	else if (sq.memory.classname == "ai_memory") {
		dprint("prioritize targets dead memory\n");
		//remove(sq.memory);
	}
}
if (sq.memory1)
	if (sq.memory1.health > 0) assign_danger(sq.memory1, .6);
if (sq.memory2)
	if (sq.memory2.health > 0) assign_danger(sq.memory2, .5);
if (sq.memory3)
	if (sq.memory3.health > 0) assign_danger(sq.memory3, .4);
if (sq.memory4)
	if (sq.memory4.health > 0) assign_danger(sq.memory4, .3);
if (sq.memory5)
	if (sq.memory5.health > 0) assign_danger(sq.memory5, .2);
if (sq.memory6)
	if (sq.memory6.health > 0) assign_danger(sq.memory6, .1);
if (sq.memory7)
	if (sq.memory7.health > 0) assign_danger(sq.memory7, 0);

if (sq.memory8)
	if (sq.memory8.health > 0) {
		//dprint("memory8 assign danger\n");
		assign_danger(sq.memory8, 0);
		//dprint("memory8 prioritized\n");
	}
	//else dprint("memory8 is world\n");
//dprint("prioritize targets complete\n");
return TRUE;
};

void() find_sdanger =
{
local float dcount = FALSE;
local entity sqs;
sqs = self.squad;

if (sqs.ally.health > 0) { assign_danger(sqs.ally, 0); dcount = TRUE;}
if (sqs.ally1.health > 0) { assign_danger(sqs.ally1, 0); dcount = TRUE;}
if (sqs.ally2.health > 0) { assign_danger(sqs.ally2, 0); dcount = TRUE;}
if (sqs.ally3.health > 0) { assign_danger(sqs.ally3, 0); dcount = TRUE;}
if (sqs.ally4.health > 0) { assign_danger(sqs.ally4, 0); dcount = TRUE;}
if (!dcount) { //doesn't work
	dprint("squad is dead\n");
	if (sqs.memory) remove (sqs.memory);
	if (sqs.memory1) remove (sqs.memory1);
	if (sqs.memory2) remove (sqs.memory2);
	if (sqs.memory3) remove (sqs.memory3);
	if (sqs.memory4) remove (sqs.memory4);
	if (sqs.memory5) remove(sqs.memory5);
	if (sqs.memory6) remove(sqs.memory6);
	if (sqs.memory7) remove(sqs.memory7);
	remove(sqs);
}
};



float(entity oqs, entity sqs) CompareDanger =
{
	local float odanger, sdanger;
if (sqs == world) { return FUBAR; }
if (oqs == world) { return FUBAR; }

if (oqs.ally) odanger = oqs.ally.danger;
if (oqs.ally1) odanger = odanger + oqs.ally1.danger;
if (oqs.ally2) odanger = odanger + oqs.ally2.danger;
if (oqs.ally3) odanger = odanger + oqs.ally3.danger;
if (oqs.ally4) odanger = odanger + oqs.ally4.danger;
if (oqs.ally5) odanger = odanger + oqs.ally5.danger;
if (oqs.ally6) odanger = odanger + oqs.ally6.danger;
if (oqs.ally7) odanger = odanger + oqs.ally7.danger;
find_sdanger();
if (sqs.ally) sdanger = sqs.ally.danger;
if (sqs.ally1) sdanger = sdanger + sqs.ally1.danger;
if (sqs.ally2) sdanger = sdanger + sqs.ally2.danger;
if (sqs.ally3) sdanger = sdanger + sqs.ally3.danger;
if (sqs.ally4) sdanger = sdanger + sqs.ally4.danger;
dprint("compare danger\n");
if (sdanger > odanger) return TRUE;
else return FALSE;
};



//should find closest enemy.
entity (entity ts, entity en) FindClosest =
{
local entity closest;
local float len, tlen;

if (ts.ally.health > 0) {
	len = vlen(ts.ally.origin - en.origin);
	closest = ts.ally;
}
if (ts.ally1.health > 0) {
	tlen = vlen(ts.ally1.origin - en.origin);
		if (!(len) || (tlen < len)) { //length tvec < vec
			len = tlen;
			closest = ts.ally1;
		}
}
if (ts.ally2.health > 0) {
	tlen = vlen(ts.ally2.origin - en.origin);
	if (!(len) || (tlen < len)) {
		len = tlen;
		closest = ts.ally2;
	}
}
if (ts.ally3.health > 0) {
	tlen = vlen(ts.ally3.origin - en.origin);
	if (!(len) || (tlen < len)) {
		len = tlen;
		closest = ts.ally3;
	}
}
if (ts.ally4.health > 0) {
	tlen = vlen(ts.ally4.origin - en.origin);
	if (!(len) || (tlen < len)) {
		len = tlen;
		closest = ts.ally4;
	}
}
if (closest.health > 0) {
//	dprint("FindClosest complete\n");
	return closest;
}
//dprint("FindClosest Failed\n"); //called when squad not full
return closest;
};

void (entity ts, entity member) RemoveFromSquad =
{
	entity null = spawn();
if (ts.ally == member) ts.ally = null;
else if (ts.ally1 == member) ts.ally1 = null;
else if (ts.ally2 == member) ts.ally2 = null;
else if (ts.ally3 == member) ts.ally3 = null;
else if (ts.ally4 == member) ts.ally4 = null;
else dprint("RemoveFromSquad Failed\n");
remove(null);
/*if (ts.ally == member) dprint("RemoveFromSquad Failed\n");
else if (ts.ally1 == member) dprint("RemoveFromSquad Failed\n");
else if (ts.ally2 == member) dprint("RemoveFromSquad Failed\n");
else if (ts.ally3 == member) dprint("RemoveFromSquad Failed\n");
else if (ts.ally4 == member) dprint("RemoveFromSquad Failed\n");
else dprint("RemoveFromSquad Works\n");*/
};

void() AssignTargets = 
{
local entity temp, temp1, temp2, temp3, sqs, oqs; //temp_squad;
entity temp_squad = spawn();
oqs = self.enemy;
sqs = self.squad;
temp_squad.ally = sqs.ally; //up to 5 now of 8 possible.
temp_squad.ally1 = sqs.ally1;
temp_squad.ally2 = sqs.ally2;
temp_squad.ally3 = sqs.ally3;
temp_squad.ally4 = sqs.ally4;
//dprint("AssignTargets\n");

temp = FindClosest(temp_squad, oqs.ally);
if (temp) { //if temp = world
	if (temp.enemy != oqs.ally) temp.enemy = oqs.ally;
	RemoveFromSquad(temp_squad, temp);
}
else {
	//dprint("Assign failed\n"); //only called when monster dies
	return;
}
//assign up to 3 monsters to the most dangerous enemy
if (temp.danger < oqs.ally.danger) {
	//dprint("assigned by danger\n");
	if ((temp1 = FindClosest(temp_squad, oqs.ally))) { 
		if (temp1 == temp) { dprint("found the same entity\n"); } else if (!temp) { dprint("temp not found\n"); }
		if (temp1.enemy != oqs.ally) temp1.enemy = oqs.ally;
		RemoveFromSquad(temp_squad, temp1);
		if (((temp.danger + temp1.danger) < oqs.ally.danger) && temp2) {
			temp2 = FindClosest(temp_squad, oqs.ally);
			if (temp2.enemy != oqs.ally) temp2.enemy = oqs.ally;
			RemoveFromSquad(temp_squad, temp2);
			if (((temp.danger + temp1.danger + temp2.danger) < oqs.ally.danger) && temp3) {
				temp3 = FindClosest(temp_squad, oqs.squad);
				if (temp3.enemy != oqs.ally) temp3.enemy = oqs.ally;
				RemoveFromSquad(temp_squad, temp3);
			}
		}
	}
	//else dprint("no temp1\n"); //no return or unassigned is never figured out.
}
//unassigned
if (sqs.ally && !(sqs.ally.enemy)) {
	if (!(sqs.ally.enemy = FindClosest(oqs, sqs.ally))) dprint("unassigned failed\n"); return;
}
if (sqs.ally1 && !(sqs.ally1.enemy)) sqs.ally1.enemy = FindClosest(oqs, sqs.ally1);
if (sqs.ally2 && !(sqs.ally2.enemy)) sqs.ally2.enemy = FindClosest(oqs, sqs.ally2);
if (sqs.ally3 && !(sqs.ally3.enemy)) sqs.ally3.enemy = FindClosest(oqs, sqs.ally3);
if (sqs.ally4 && !(sqs.ally4.enemy)) sqs.ally4.enemy = FindClosest(oqs, sqs.ally4);

remove(temp_squad);
//dprint("targets assigned\n");
};

void() start_encounter =
{//self = squad
	entity n_encounter = spawn();
n_encounter.classname = "ai_encounter";
n_encounter.origin = self.origin;
self.encounter = n_encounter;
n_encounter.squad = self;
n_encounter.flags = FL_NOTARGET;
//setmodel(n_encounter, "progs/backpack.mdl");
//setsize(n_encounter, '-16 -16 0', '16 16 56');
n_encounter.solid = SOLID_NOT;
n_encounter.health = 1;
//encounter_update(); new encounter just react.
//dprint("new encounter\n");
n_encounter.think = encounter_update;
n_encounter.nextthink = time + 0.4;
};

float() check_encounter =
{//self = encounter
	local entity enc = self;
	if (enc.squad.memory)
		if (enc.squad.memory.health > 0)
			return TRUE;
//encounter must reference something real
//entity null = spawn();
	self.health = 0;
self = enc.squad;
remove(enc);
//self.encounter = null;
//remove(null); //really gone
//dprint("encounter end\n");
//if (enc) dprint("remove encounter failed?\n");
//if (enc.squad) dprint("remove encounter failed\n");
//if (self.encounter) dprint("check will fail\n");
//if (self.encounter.classname == "ai_encounter") dprint("idk\n");
//if (self.encounter.health = 0) dprint("encounter no health test\n");
return FALSE;
}

void () encounter_update =
{//self = encounter
if (self.enemy.classname == "ai_squad") remove(self.enemy); //worldspawn fist pass.
//self now encounter.

if (check_encounter() == FALSE) return; 
SortEnemies();
entity	other_qside = spawn();
//entity self_qside = spawn();
local entity sq;
sq = self.squad;
self.enemy = other_qside; //encounter.enemy is virtual enemy squad
other_qside.classname = "ai_squad";
//update encounter teams (qsides)
if (sq.memory.health > 0) other_qside.ally = sq.memory;
if (sq.memory1.health > 0) other_qside.ally1 = sq.memory1;
if (sq.memory2.health > 0) other_qside.ally2 = sq.memory2;
if (sq.memory3.health > 0) other_qside.ally3 = sq.memory3;
if (sq.memory4.health > 0) other_qside.ally4 = sq.memory4;
if (sq.memory5.health > 0) other_qside.ally5 = sq.memory5;
if (sq.memory6.health > 0) other_qside.ally6 = sq.memory6;
if (sq.memory7.health > 0) other_qside.ally7 = sq.memory7;
AssignTargets();
//dprint("back to encounter update.\n");
//CompareDanger(other_qside, sq);//state_winning;
//dprint("encounter update complete\n");
self.nextthink = time + 0.43;
};

void(entity ts, entity member) RemoveMemory =
{
	entity null = spawn();
/*if (ts.memory == member) ts.memory = null;
else if (ts.memory1 == member) ts.memory1 = null;
else if (ts.memory2 == member) ts.memory2 = null;
else if (ts.memory3 == member) ts.memory3 = null;
else if (ts.memory4 == member) ts.memory4 = null;
else if (ts.memory5 == member) ts.memory5 = null;
else if (ts.memory6 == member) ts.memory6 = null;
else if (ts.memory7 == member) ts.memory7 = null;
else if (ts.memory8 == member) ts.memory8 = null;
else dprint("RemoveMemory Failed\n");*/
if (ts.memory == member) ts.memory = null;
if (ts.memory1 == member) ts.memory1 = null;
if (ts.memory2 == member) ts.memory2 = null;
if (ts.memory3 == member) ts.memory3 = null;
if (ts.memory4 == member) ts.memory4 = null;
if (ts.memory5 == member) ts.memory5 = null;
if (ts.memory6 == member) ts.memory6 = null;
if (ts.memory7 == member) ts.memory7 = null;
if (ts.memory8 == member) ts.memory8 = null;
remove(null);
/*if (ts.memory == member) dprint("RemoveMemory Failed\n");
else if (ts.memory1 == member) dprint("RemoveMemory Failed\n");
else if (ts.memory2 == member) dprint("RemoveMemory Failed\n");
else if (ts.memory3 == member) dprint("RemoveMemory Failed\n");
else if (ts.memory4 == member) dprint("RemoveMemory Failed\n");
else if (ts.memory5 == member) dprint("RemoveMemory Failed\n");
else if (ts.memory6 == member) dprint("RemoveMemory Failed\n");
else if (ts.memory7 == member) dprint("RemoveMemory Failed\n");
else if (ts.memory8 == member) dprint("RemoveMemory Failed\n");*/
};

entity (entity  ts) FindStrongest =
{
	entity null = spawn();
	null.danger = 0;
	local entity str = null; //strongest

	if (ts.memory.health > 0) { str = ts.memory;}
	if (ts.memory1.danger > str.danger) { str = ts.memory1;}
	if (ts.memory2.danger > str.danger) { str = ts.memory2;}
	if (ts.memory3.danger > str.danger) { str = ts.memory3;}
	if (ts.memory4.danger > str.danger) { str = ts.memory4;}
	if (ts.memory5.danger > str.danger) { str = ts.memory5;}
	if (ts.memory6.danger > str.danger) { str = ts.memory6;}
	if (ts.memory7.danger > str.danger) { str = ts.memory7;}
	if (ts.memory8.danger > str.danger) {
		str = ts.memory8;
	}
	remove(null);
	if (str.health <= 0) {
		//dprint("strongest return nothing\n"); 
		return(world); //void unsafe
	}
//else dprint("strongest found\n");
return(str);
}

void() SortEnemies = 
{
entity ts = spawn(); //temp squad
local entity sq;
sq = self.squad;
entity null = spawn();

if (sq.memory.classname == "ai_memory") ts.memory = sq.memory;
if (sq.memory1.classname == "ai_memory") ts.memory1 = sq.memory1;
if (sq.memory2.classname == "ai_memory") ts.memory2 = sq.memory2;
if (sq.memory3.classname == "ai_memory") ts.memory3 = sq.memory3;
if (sq.memory4.classname == "ai_memory") ts.memory4 = sq.memory4;
if (sq.memory5.classname == "ai_memory") ts.memory5 = sq.memory5;
if (sq.memory6.classname == "ai_memory") ts.memory6 = sq.memory6;
if (sq.memory7.classname == "ai_memory") ts.memory7 = sq.memory7;
if (sq.memory8.classname == "ai_memory") ts.memory8 = sq.memory8;

if (!(sq.memory = FindStrongest(ts))) dprint("sq.enemy unfilled by sort\n");
else RemoveMemory(ts, sq.memory);
if ((sq.memory1 = FindStrongest(ts)))
RemoveMemory(ts, sq.memory1);
if ((sq.memory2 = FindStrongest(ts)))
RemoveMemory(ts, sq.memory2);
if ((sq.memory3 = FindStrongest(ts)))
RemoveMemory(ts, sq.memory3);
if ((sq.memory4 = FindStrongest(ts)))
RemoveMemory(ts, sq.memory4);
if ((sq.memory5 = FindStrongest(ts)))
RemoveMemory(ts, sq.memory5);
if ((sq.memory6 = FindStrongest(ts)))
RemoveMemory(ts, sq.memory6);
if ((sq.memory7 = FindStrongest(ts)))
RemoveMemory(ts, sq.memory7);

sq.memory8 = null;

remove(null);
remove(ts);
//if (sq.memory.health > 0) dprint("enemies sorted\n");
if (sq.memory.health <= 0) dprint("sort failed\n");
if (sq.memory8.health > 0) dprint("failed to sort out memory8\n");
};

void() squad_update =
{
	//local entity oself = self;
float f = 0;
if (self.ally) f = f + self.ally.health;
if (self.ally1) f = f + self.ally1.health;
if (self.ally2) f = f + self.ally2.health;
if (self.ally3) f = f + self.ally3.health;
if (self.ally4) f = f + self.ally4.health;
//squad entity
if (f <= 0) {
	//dprint("squad expired\n");
	if (self.memory) remove(self.memory);
	if (self.memory1) remove(self.memory1);
	if (self.memory2) remove(self.memory2);
	if (self.memory3) remove(self.memory3);
	if (self.memory4) remove(self.memory4);
	if (self.memory5) remove(self.memory5);
	if (self.memory6) remove(self.memory6);
	if (self.memory7) remove(self.memory7);
	if (self.memory8) remove(self.memory8);
	remove(self);
	//if (oself) 
	//	if (oself.classname == "ai_squad") dprint("remove squad failed\n");
	return;
}
//dprint("squad update\n");
squad_action();
self.nextthink = time + 1;
};

//monster senses a change that demands new priorities
void(entity nm) sight_update = //new memory
{
//local float state_winning; //debug
local entity oself;
oself = self;
self = self.squad;
if (nm.squad != self) {
	self.memory8 = nm;
	nm.squad = self;
	//dprint("sight update new memory\n");
}
//else dprint("memory8 not set\n");

if (prioritize_targets() == FALSE) {
	dprint("prioritize targets failed\n");
	return; //still works
}
//dprint("prioritize targets did not fail\n");
//if (oself.squad) self = oself.squad;
//else {
	//dprint("sight update bad squad\n");
	//return;
//}
if (self.encounter.health > 0) {
//	dprint("sight update complete\n");
	self = oself;
	return;
}
//dprint("sight update no encounter\n");
start_encounter();
if (self.ally) self.ally.enemy = nm;
if (self.ally1) self.ally1.enemy = nm;
if (self.ally2) self.ally2.enemy = nm;
if (self.ally3) self.ally3.enemy = nm;
if (self.ally4) self.ally4.enemy = nm;
if !(self.memory.health > 0) self.memory = nm;
//dprint("initial response\n");
squad_action();
self = oself;
};

void() memorythink =
{
	remove(self);
dprint("memory expired\n");
};

//at the beginning of an action. memories are shared in sqaud.
void(entity nt) update_memory =
{
	local entity sq = self.squad;
local entity nm;
 //if (self.enemy.enemy != new_target) { //need a more robust check
if (sq.memory.enemy == nt) {
	nm = sq.memory;
	//dprint("target was memory\n");
}
	else if (sq.memory1.enemy == nt) nm = sq.memory1;
	else if (sq.memory2.enemy == nt) nm = sq.memory2;
	else if (sq.memory3.enemy == nt) nm = sq.memory3;
	else if (sq.memory4.enemy == nt) nm = sq.memory4;
	else if (sq.memory5.enemy == nt) nm = sq.memory5;
	else if (sq.memory6.enemy == nt) nm = sq.memory6;
	else if (sq.memory7.enemy == nt) nm = sq.memory7;
	else if (sq.memory8.enemy == nt) {
		nm = sq.memory8;
	//	dprint("target was memory8\n");
		if (nm.enemy.classname == "ai_memory") {
			dprint("bad chain memory update\n");
			remove(nm.enemy);
			remove(nm);
			return;
		}
	}
	else {
	//	dprint("new memory\n");
		entity new_memory = spawn();
		new_memory.classname = "ai_memory";
		new_memory.think = memorythink;
	//	setmodel(new_memory, "progs/armor.mdl"); //debug
	//	setsize(new_memory, '-16 -16 0', '16 16 56');
		new_memory.solid = SOLID_NOT;
		new_memory.movetype = MOVETYPE_NONE;
		new_memory.target = nt.classname;
		new_memory.enemy = nt;
		new_memory.team = nt.team;
		new_memory.flags = FL_NOTARGET;
		//new_memory.squad = sq; sight update
		nm = new_memory;
		//if (nt.classname == "player") dprint("new target is player\n");
	}
	if !(nm.classname == "ai_memory") {
		dprint("bad memory update\n");
		if (nm.classname == "world")
			dprint("memory is world\n");
		return;
	}
nm.origin = nt.origin + '0 0 12';
nm.health = nt.health;
if !(nm.health > 0) { //reducing causes for bad sort
	dprint("memory update no health\n");
	remove(nm);
	return;
}
nm.nextthink = time + 4.7; //when memory should expire
//dprint("memory updated\n");
sight_update(nm);
//else dprint("memory update failed\n");
};


/*Memory Point Entity (.5 .5 .5) (-8 -8 -8) (8 8 8) X X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Memory class for squad knowledge model
*/
void() ai_memory =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;
};

void() waypointthink =
{
	remove(self);
dprint("waypoint expired\n");
};

void(vector spawnpoint) create_waypoint = 
{
	entity new_waypoint = spawn();
	new_waypoint.classname = "ai_waypoint";
//	setmodel(new_waypoint, "progs/backpack.mdl");
//	setsize(new_waypoint, '-16 -16 0', '16 16 56');
	new_waypoint.solid = SOLID_NOT;
	new_waypoint.think = waypointthink;
	new_waypoint.origin = spawnpoint;

	if (self.movetarget.classname == "ai_waypoint") { remove(self.movetarget); }

	self.movetarget = new_waypoint; //was self.waypoint
	self.goalentity = new_waypoint; //what is the difference between goalentity and movetarget?
	new_waypoint.nextthink = time + 4.9;
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
new_squad.think = squad_update;
new_squad.squad_state_full = FALSE;
self.squad = new_squad;
new_squad.ally = self;
new_squad.flags = FL_NOTARGET;//test
new_squad.solid = SOLID_NOT;
new_squad.movetype = MOVETYPE_NONE;
//setmodel(new_squad, "progs/armor.mdl");
//setsize(new_squad, '-16 -16 0', '16 16 56');
new_squad.nextthink = time + 0.3 + .5 * random();
}

void(entity mobot) mobot_squad = 
{
	entity new_squad = spawn();
new_squad.classname = "ai_squad";
new_squad.think = squad_update;
new_squad.squad_state_full = FALSE;
mobot.squad = new_squad;
new_squad.ally = mobot;
new_squad.flags = FL_NOTARGET;//test
new_squad.solid = SOLID_NOT;
new_squad.movetype = MOVETYPE_NONE;
new_squad.attack_state = ss_spawn;
new_squad.nextthink = time + 0.3 + .5 * random();
}


void (entity request) squad_fit =
{
	local entity sq = self.squad;
	request.squad = sq;
	if (!(sq.ally)) sq.ally = request;
	else if (!(sq.ally1)) sq.ally1 = request;
	else if (!(sq.ally2)) sq.ally2 = request;
	else if (!(sq.ally3)) sq.ally3 = request;
	else if (!(sq.ally4)) sq.ally4 = request;
	else {
		dprint("squad fit failed\n"); 
	}
//	dprint("squad merged\n");
};


//squad check merge. self = seer, request = seen, team checked
void(entity request) squad_check_merge =
{
	//dprint("squad check merge\n");
	local float self_count, other_count;
local entity os, sq;
if (request.squad.squad_state_full) return;
if (request.squad == self.squad) return;
if (!request.squad) return;
os = request.squad;
sq = self.squad;

self_count = 0;
//self count
if (sq.ally) self_count = self_count + 1;
if (sq.ally1) self_count = self_count + 1;
if (sq.ally2) self_count = self_count + 1;
if (sq.ally3) self_count = self_count + 1;
if (sq.ally4) self_count = self_count + 1;
if (self_count == 5) { sq.squad_state_full = TRUE; return; }
other_count = 0;
//other count
if (os.ally) other_count = other_count + 1;
if (os.ally1) other_count = other_count + 1;
if (os.ally2) other_count = other_count + 1;
if (os.ally3) other_count = other_count + 1;
if (os.ally4) other_count = other_count + 1;
//can squads merge?
if ((self_count + other_count) <= 5) {
	sq.squad_state_full = TRUE;
	if (os.ally) squad_fit(os.ally) ;
	if (os.ally1) squad_fit(os.ally1);
	if (os.ally2) squad_fit(os.ally2);
	if (os.ally3) squad_fit(os.ally3);
	if (os.ally4) squad_fit(os.ally4);
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