/*
==============================================================================

SOLDIER --ALEX

==============================================================================
*/

//$cd id1 / models / human
//$origin 0 - 6 24
//$base base
//$skin skin

$frame stand1 walk1 walk2

//============================================================================

void()	man_stand1 = [$stand1, man_stand2] {ai_stand(); };
void()	man_stand2 = [$stand1, man_stand1] {ai_stand(); };


void()	man_walk1 = [$walk1, man_walk2] {
	//if (random() < 0.2)
		//sound_idle(self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE); //dumptruck_ds
	ai_walk(2); };
void()	man_walk2 = [$walk2, man_walk3] {ai_walk(4); };
void()	man_walk3 = [$walk1, man_walk4] {ai_walk(4); };
void()	man_walk4 = [$walk2, man_walk1] {ai_walk(3); };

void()	man_run1 = [$walk1, man_run2] {
		ai_run(6); //move to waypoint, face enemy
};
void()	man_run2 = [$walk2, man_run1] {ai_run(6);	};
/*
void()	man_fire1 = [$fire1, man_fire2] {ai_face(); };
void()	man_fire2 = [$fire2, man_fire3] {ai_face(); };
void()	man_fire3 = [$fire3, man_fire4] {ai_face(); };
void()	man_fire4 = [$fire4, man_fire5] {ai_face(); };
void()	man_fire5 = [$fire5, man_fire6] {ai_face(); };
void()	man_fire6 = [$fire6, man_fire7] {ai_fire(); };//
void()	man_fire7 = [$fire7, man_fire8] {ai_face(); };
void()	man_fire8 = [$fire8, man_fire9] {ai_face(); };
void()	man_fire9 = [$fire5, man_fire10] {ai_face(); };
void()	man_fire10 = [$fire6, man_fire11] {ai_fire(); };//
void()	man_fire11 = [$fire7, man_fire12] {ai_face(); };
void()	man_fire12 = [$fire8, man_fire13] {ai_face(); };
void()	man_fire13 = [$fire9, man_fire14] {ai_face(); };
void()	man_fire14 = [$fire10, man_fire1] {ai_face(); SUB_CheckRefire(man_fire1);
}; */

void (entity attacker, float damage) human_pain =
{
	if (self.pain_finished > time)
		return;
self.pain_finished = time + 0.6;
sound_pain(self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
man_pain();
};

void() man_pain = { ai_pain(1); };

void()	man_hit1 = [$walk1, man_hit2] {ai_melee();	};
void()	man_hit2 = [$walk2, man_hit1] {ai_melee();	};

void() human_melee =
{
	//if (random() > 0.5)
		man_hit1();
	//else
	//	man_smack1();
}

void() h_death1 =
{
	man_die();
}

void() man_die =
{
	remove(self);
	return;
}


void() monster_human =
//int team, squad, squadnumber;
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	if (deathmatch)
	{
		remove(self);
		return;
	}
	if (self.style >= 6)
		objerror("style key set too high\n");

	precache_body_model2("progs/e_mdls/human.mdl");  // custom_mdls function -- dumptruck_ds
	//precache_head_model2("progs/h_man.mdl");
	precache_proj_model2("progs/laser.mdl");
	precache_proj_model2("progs/s_spike.mdl");
	precache_proj_model2("progs/missile.mdl");
	//dumptruck_ds
	precache_sound2_death("enforcer/death1.wav");
	precache_sound2_attack("enforcer/enfire.wav");
	precache_sound2_hit("enforcer/enfstop.wav");
	precache_sound2_idle("enforcer/idle1.wav");
	precache_sound2_pain("enforcer/pain1.wav");
	precache_sound2_misc3("enforcer/pain2.wav");
	precache_sound2_sight("enforcer/sight1.wav");
	precache_sound2_misc("enforcer/sight2.wav"); // these will be replaced with custom noise fields eventually - dumptruck_ds
	precache_sound2_misc1("enforcer/sight3.wav");
	precache_sound2_misc2("enforcer/sight4.wav");

	precache_gib1("progs/gib1.mdl");
	precache_gib2("progs/gib2.mdl");
	precache_gib3("progs/gib3.mdl");

	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	body_model("progs/e_mdls/human.mdl"); 
	setsize(self, '-16 -16 -40', '16 16 40');

	if (!self.health) //thanks RennyC -- dumptruck_ds
		self.health = 80;

	self.th_stand = man_stand1;
	self.th_walk = man_walk1;
	self.th_run = man_run1;
	self.th_melee = human_melee;
	//self.th_missile = man_fire1; //placeholder until weapon system for AI implemented
	if !(self.berserk) //Berserk test from http://celephais.net/board/view_thread.php?id=4&start=3465 -- dumptruck_ds
		self.th_pain = human_pain;
	else
		self.th_pain = SUB_NullPain;
	self.th_die = h_death1;
	walkmonster_start();
};

void() monster_dead_human =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	precache_model("progs/e_mdls/human.mdl");
	setmodel(self, "progs/e_mdls/human.mdl");
	if (self.spawnflags & 2)
	{
		//self.frame = $fdeath11;

		if (self.spawnflags & 1)
		{
			self.solid = SOLID_BBOX;
					setsize(self,'-41.16 -45.65 -51.95','21.45 25.49 30');
		} else
		{
			self.solid = SOLID_NOT;
		}
	} else
	{
		//self.frame = $death14;
		if (self.spawnflags & 1)
		{
			self.solid = SOLID_BBOX;
					setsize(self,'-39.85 -29.35 -49.07','20.52 33.17 30');
		} else
		{
			self.solid = SOLID_NOT;
		}
	}
};
