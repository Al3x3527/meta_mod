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
	dprint("squad fight\n");
	if (!sq) { 
		dprint("squad failed at ACTION\n");
		return;
	}
	if (sq.ally) { //was not the problem
		if (sq.ally.health > 0) {
			self = sq.ally;
			create_waypoint();
			self.waypoint.origin = self.enemy.origin; //squad leader
			if (self.attack_state == 0) {
				self.think = self.th_run; dprint("th_run set\n");
			}
			//else {
			//	dprint("ally busy\n");
				
			//}
		}
	}
	if (sq.ally1) {
		if (sq.ally1.health > 0) {
			self = sq.ally1;
			create_waypoint();
			self.waypoint.origin = waypoint_offset(48, self.enemy);
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
	if (sq.ally2) {
		if (sq.ally2.health > 0) {
			self = sq.ally2;
			create_waypoint();
			self.waypoint.origin = waypoint_offset(-48, self.enemy);
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
	if (sq.ally3) {
		if (sq.ally3.health > 0) {
			self = sq.ally3;
			create_waypoint();
			self.waypoint.origin = waypoint_offset(48, self.enemy);
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
	if (sq.ally4) {
		if (sq.ally4.health > 0) {
			self = sq.ally4;
			create_waypoint();
			self.waypoint.origin = waypoint_offset(-48, self.enemy);
			if (self.attack_state == 0) self.think = self.th_run;
		}
	}
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
			create_waypoint();
			self.waypoint.origin = waypoint_cast(48); //placeholder
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
}

void() squad_action =
{
	//dprint("squad_action\n");
	if (self.attack_state == ss_spawn) {squad_spawn();}
else if (self.memory.health > 0) {squad_fight();} //should just move waypoint around most of the time.
//problem detecting when no enemy
else squad_wait();
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