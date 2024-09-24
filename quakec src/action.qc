/*
potentially temporary document (combine with ai.qc)
AI behavior tree
--Alex
*/

//squad actions called every ai think
void() squad_fight =
{
	entity new_waypoint = spawn();
	new_waypoint.classname = "ai_waypoint";
	setmodel(new_waypoint, "progs/backpack.mdl");
	setsize(new_waypoint, '-16 -16 0', '16 16 56');
	new_waypoint.solid = SOLID_TRIGGER;

	if (self.waypoint) {remove(self.waypoint);}
	self.waypoint = new_waypoint;
	self.goalentity = new_waypoint;
	self.squad.attack_state = fight;
		//modify squad action
			//push or flank?
				//look for a place near self.enemy which the target can't see
	//apply offset to squad dest
		//turn monster dest into waypoint entity
	if (!self.squad) { 
		sprint(self.enemy.enemy, "squad failed.\n"); //no print
		return;
	}
	if (self.squad.squad == self) {
		sprint(self.enemy.enemy, "leader found.\n");
		self.waypoint.origin = self.enemy.origin; //squad leader
	}
	else if (self.squad.squad1 == self)
		self.waypoint.origin = waypoint_offset(48, self.enemy);
	else if (self.squad.squad2 == self)
		self.waypoint.origin = waypoint_offset(-48, self.enemy);
	else if (self.squad.squad3 == self)
		self.waypoint.origin = waypoint_offset(48, self.enemy);
	else if (self.squad.squad4 == self)
		self.waypoint.origin = waypoint_offset(-48, self.enemy);
	else {
		sprint(self.enemy.enemy, "squad_fight failed.\n");
		new_waypoint.origin = self.enemy.origin - '0 0 12'; //force it to work.
	}
//run towards waypoint while attacking self.enemy
	if (self.think != self.th_run) self.think = self.th_run;
	//let ai complete their last think. ai will check squad.attack_state.
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