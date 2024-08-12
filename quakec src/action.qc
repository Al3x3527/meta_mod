/*
potentially temporary
AI behavoir tree
--Alex
*/

//last action is complete, decide what to do next
//assuming self = a monster
void(state_winning, state_full, state_leader) squad_action = 
{
	if (self.squad.encounter) {
		if (self.squad.attack_state == sleep) {
			self.squad.attack_state == alert;
		} //sleep
		if (self.squad.attack_state == alert) {
			if (winning) {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full	
				else {
					if (state_leader) {
						self.squad.attack_state = fight;
					} //no leader
					else {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else
							self.squad.attack_state = guard;
					}
				}
			} //not winning
			else {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full
				else {
					if (state_leader) {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else {
							self.squad.attack_state = guard;
						}
					} //no leader
					else
						self.squad.attack_state = flee; //modify to retreat or scram
				} //not full
			} //not winning
		} //alert
		if (self.squad.attack_state == fight) {
			if (winning) {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full	
				else {
					if (state_leader) {
						self.squad.attack_state = fight;
					} //no leader
					else {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else
							self.squad.attack_state = guard;
					}
				}
			} //not winning
			else {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full
				else {
					if (state_leader) {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} 
						else {
							self.squad.attack_state = guard;
						}
					} //no leader
					else
						self.squad.attack_state = flee; //modify to retreat or scram
				} //not full
			} //not winning
		} //state = fight
		if (self.squad.attack_state == flee) {
			if (winning) {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full	
				else {
					if (state_leader) {
						self.squad.attack_state = fight;
					} //no leader
					else {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else
							self.squad.attack_state = guard;
					}
				}
			} //not winning
			else {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full
				else {
					if (state_leader) {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else {
							self.squad.attack_state = guard;
						}
					} //no leader
					else
						self.squad.attack_state = flee; //modify to retreat or scram
				} //not full
			} //not winning
		} //flee
		if (self.squad.attack_state == uncover) {
			if (winning) {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full	
				else {
					if (state_leader) {
						self.squad.attack_state = fight;
					} //no leader
					else {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else
							self.squad.attack_state = guard;
					}
				}
			} //not winning
			else {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full
				else {
					if (state_leader) {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else {
							self.squad.attack_state = guard;
						}
					} //no leader
					else
						self.squad.attack_state = flee; //modify to retreat or scram
				} //not full
			} //not winning
		} //uncover
		if (self.squad.attack_state == guard) {
			;
		} //guard
		if (self.squad.attack_state == search) {
			if (winning) {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full	
				else {
					if (state_leader) {
						self.squad.attack_state = fight;
					} //no leader
					else {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else
							self.squad.attack_state = guard;
					}
				}
			} //not winning
			else {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full
				else {
					if (state_leader) {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else {
							self.squad.attack_state = guard;
						}
					} //no leader
					else
						self.squad.attack_state = flee; //modify to retreat or scram
				} //not full
			} //not winning
		} //search
		if (self.squad.attack_state == wait) {
			;
		} //wait
		if (self.squad.attack_state == vehicle) {
			;
		} //vehicle
		if (self.squad.attack_state == charge) {
			if (winning) {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full	
				else {
					if (state_leader) {
						self.squad.attack_state = fight;
					} //no leader
					else {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else
							self.squad.attack_state = guard;
					}
				}
			} //not winning
			else {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full
				else {
					if (state_leader) {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else {
							self.squad.attack_state = guard;
						}
					} //no leader
					else
						self.squad.attack_state = flee; //modify to retreat or scram
				} //not full
			} //not winning
		} //charge
		if (self.squad.attack_state == obey) {
			;
		} //obey
		if (self.squad.attack_state == converse) {
			;
		} //converse
		if (self.squad.attack_state == avoid) {
			if (winning) {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full	
				else {
					if (state_leader) {
						self.squad.attack_state = fight;
					} //no leader
					else {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else
							self.squad.attack_state = guard;
					}
				}
			} //not winning
			else {
				if (state_full) {
					self.squad.attack_state = fight;
				} //not full
				else {
					if (state_leader) {
						if (self.squad.frustration > 2) {
							self.squad.attack_state = charge;
						} else {
							self.squad.attack_state = guard;
						}
					} //no leader
					else
						self.squad.attack_state = flee; //modify to retreat or scram
				} //not full
			} //not winning
		} //avoid
	} //encounter -can this function be called outside an encounter?
}