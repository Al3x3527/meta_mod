/*
potentially temporary document (combine with ai.qc)
AI behavior tree
--Alex
*/


void() squad_fight =
{
	local entity sq;
	sq = self;
	
	sq.attack_state = fight;
	//dprint("squad fight\n");
	if (!sq) { 
		dprint("squad failed at ACTION\n");
		return;
	}
	if (sq.ally) { //was not the problem
		if (sq.ally.health > 0) {
			self = sq.ally;
			self.goalentity = self.enemy;//squad leader
			if (self.attack_state == 0) {
				self.think = self.th_run;// dprint("th_run set\n");
			}
			//else {
			//	dprint("ally busy\n");
				
			//}
		}
	}
	if (sq.ally1) {
		if (sq.ally1.health > 0) {
			self = sq.ally1;
			create_waypoint(waypoint_offset(48, self.enemy));
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
	if (sq.ally2) {
		if (sq.ally2.health > 0) {
			self = sq.ally2;
			create_waypoint(waypoint_offset(-48, self.enemy));
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
	if (sq.ally3) {
		if (sq.ally3.health > 0) {
			self = sq.ally3;
			create_waypoint(waypoint_offset(48, self.enemy));
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
	if (sq.ally4) {
		if (sq.ally4.health > 0) {
			self = sq.ally4;
			create_waypoint(waypoint_offset(-48, self.enemy));
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
	//dprint("squad fight complete\n");
	self = sq;
};

void() squad_spawn =
{
	local entity sq = self;
	if (self.ally.health > 0) {
		self.attack_state = 0;
		//if ((self.spawnflags & MOBOT_DONT_SPAWN_ANGRY)) {
		if (!self.ally.enemy) {
			self = self.ally;
			self.ideal_yaw = self.angles_y + 70 * random();
			ChangeYaw();
			create_waypoint(waypoint_cast(48));//placeholder
			self.think = self.th_walk;
			self = sq;
		}
		else squad_fight();
}
};

void() squad_wait =
{
	local entity sq = self;

	sq.attack_state = ss_wait;
	//dprint("squad wait\n");

	if (sq.ally.health > 0) {
		self = sq.ally;
	if (!self.movetarget)	self.think = self.th_stand;
	else self.think = self.th_walk;
	}
	if (sq.ally1.health > 0) {
		self = sq.ally1;
		if (!self.movetarget)	self.think = self.th_stand;
		else self.think = self.th_walk;
	}
	if (sq.ally2.health > 0) {
		self = sq.ally2;
		if (!self.movetarget)	self.think = self.th_stand;
		else self.think = self.th_walk;
	}
	if (sq.ally3.health > 0) {
		self = sq.ally3;
		if (!self.movetarget)	self.think = self.th_stand;
		else self.think = self.th_walk;
	}
	if (sq.ally4.health > 0) {
		self = sq.ally4;
		if (!self.movetarget)	self.think = self.th_stand;
		else self.think = self.th_walk;
	}
	self = sq;
	//if (self.encounter) 
	//	if (self.encounter.health > 0 ) dprint("waiting in encounter\n");
};

void() squad_charge = 
{
local entity sq = self;
//sq.attack_state = charge;
dprint("squad_charge\n");

if (sq.ally.health > 0) {
	self = sq.ally;
	self.think = self.th_run;
	self.attack_state = charge; 
	if (!(self.movetarget) || self.movetarget == self.enemy) {
		self.goalentity = self.movetarget = find(world, targetname, self.target);
		self.ideal_yaw = vectoyaw(self.goalentity.origin - self.origin);
	}
	sq.goalentity = self.goalentity;
}
if (sq.ally1.health > 0) {
	self = sq.ally1;
	self.think = self.th_run;
	self.attack_state = charge;
	self.goalentity = self.movetarget = sq.goalentity;
}
if (sq.ally2.health > 0) {
	self = sq.ally2;
	self.think = self.th_run;
	self.attack_state = charge;
	self.goalentity = self.movetarget = sq.goalentity;
}
if (sq.ally3.health > 0) {
	self = sq.ally3;
	self.think = self.th_run;
	self.attack_state = charge;
	self.goalentity = self.movetarget = sq.goalentity;
}
if (sq.ally4.health > 0) {
	self = sq.ally4;
	self.think = self.th_run;
	self.attack_state = charge;
	self.goalentity = self.movetarget = sq.goalentity;
}
};

void() squad_guard = 
{

};

void() squad_action =
{
	//dprint("squad_action\n");
	if (self.attack_state == ss_spawn) { squad_spawn(); return; }
	if (self.attack_state == charge) {squad_charge(); return;}
	if !(self.memory.health > 0) {squad_wait(); return;} //default
	if (self.memory.health > 0) { squad_fight(); return; } //should just move waypoint around most of the time.
	//problem detecting when no enemy
	dprint("squad_action exception\n");
};

void() act_touch =
{
	//if (self.estate != STATE_ACTIVE) return;
	if !(other.flags & FL_MONSTER) return;
local entity sq = other.squad;
//if !(sq.health > 0) return;
if (sq.attack_state != self.attack_state)
sq.attack_state = self.attack_state;
dprint("act_touch\n");
};

/*trigger_monsteract (.5 .5 .5) ? X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
forces squad attack_state of any monster that activates the trigger.
*/
void() trigger_monsteract = 
{
	if (SUB_Inhibit()) return;
InitTrigger();
self.touch = act_touch;
SUB_CheckWaiting();
};


//something has changed, decide what to do next
//assuming self = a monster
/*
void(float state_winning) squad_action =
{

	if (self.squad.attack_state = 0)
	return; //no state = do nothing/play dead
	else {
		if (self.squad.encounter) {
			if (self.squad.attack_state == sleep) {
				self.squad.attack_state = alert;
			} //sleep
			else if (self.squad.attack_state == guard) {
				if (!(state_winning))
					if (squad_state_leader == 0)
						self.squad.attack_state = flee;
			} //guard
			else if (self.squad.attack_state == vehicle) {
				//handle vehicle/combined combat in its own way
				;
			} //vehicle
			else if (self.squad.attack_state == obey) {
				//when scripted movement overrides combat loop
				;
			} //obey
			//generic tree
			else {
				if (state_winning) {
					if (squad_state_full) {
						squad_fight();
					} //not full	
					else {
						if (squad_state_leader) {
							self.squad.attack_state = fight;
						} //no leader
						else {
							if (self.squad.frustration > 2) {
								self.squad.attack_state = charge;
							} else
								self.squad.attack_state = avoid;
						}
					}
				} //not winning
				else {
					if (squad_state_full) {
						self.squad.attack_state = fight;
					} //not full
					else {
						if (squad_state_leader) {
							if (self.squad.frustration > 2) {
								self.squad.attack_state = charge;
							} else {
								self.squad.attack_state = avoid;
							}
						} //no leader
						else
							self.squad.attack_state = flee; //modify to retreat or scram
					} //not full
				} //not winning
			} //generic tree
		} //encounter -can this function be called outside an encounter?
	} //there is an attack state
}


//set monster state and dest for each monster in squad
	if (self.classname == human)
		human_fight(yaw);
	else if (self.classname == hero)
		hero_fight(yaw);
	else if (self.classname == elite)
		elite_fight(yaw);
	else if (self.classname == drake)
		drake_fight(yaw);
	else if (self.classname == toad)
		toad_fight(yaw);
	else if (self.classname == robot)
		robot_fight(yaw);
	else if (self.classname == zombie)
		zombie_fight(yaw);
	else if (self.classname == hornet)
		hornet_fight(yaw);
	else if (self.classname == beast)
		beast_fight(yaw);
		*/

void() trigger_monsteraction_touch =
{
	if (self.estate != STATE_ACTIVE) return;

	if (other.flags != FL_MONSTER)
		return;

//behavior here
	other.squad.attack_state = self.attack_state;
};

/*QUAKED trigger_monsteraction (.5 .5 .5) ? X X X DT_STARTOFF X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Walking monsters that touch this will be forced into an action state. This will affect the whole squad.


If DT_STARTOFF flag is set, this makes the trigger
inactive. This can be targeted and toggled off and on.
*/
void() trigger_monsteraction =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	self.use = push_toggle;
	if (self.spawnflags & DT_STARTOFF) // dumptruck_ds
		 {
			 self.estate = STATE_INACTIVE;
		 }
	//defaults here
	if !(self.attack_state)
		self.attack_state = ss_wait;

	InitTrigger();
	self.touch = trigger_monsteraction_touch;

	SUB_CheckWaiting();
};