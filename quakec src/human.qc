/*
==============================================================================

SOLDIER --ALEX

==============================================================================
*/

$cd id1 / models / human
$origin 0 - 6 24
$base base
$skin skin

//============================================================================

void()	man_stand1 = ai_stand();// [$stand1, man_stand2] {ai_stand(); };
//void()	man_stand2 = [$stand2, man_stand1] {ai_stand(); };


void()	man_walk1 = ai_walk();// [$walk1, man_walk2] {
	//if (random() < 0.2)
		//sound_idle(self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE); //dumptruck_ds
	//ai_walk(2); };
//void()	man_walk2 = [$walk2, man_walk3] {ai_walk(4); };
//void()	man_walk3 = [$walk3, man_walk4] {ai_walk(4); };
//void()	man_walk4 = [$walk4, man_walk1] {ai_walk(3); };

void()	enf_run1 = ai_run(); /* [$run1, enf_run2] {
	if (random() < 0.2)
		sound_idle(self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE); //dumptruck_ds
	ai_run(18); };
void()	enf_run2 = [$run2, enf_run3] {ai_run(14); };
void()	enf_run3 = [$run3, enf_run4] {ai_run(7); };
void()	enf_run4 = [$run4, enf_run5] {ai_run(12); };
void()	enf_run5 = [$run5, enf_run6] {ai_run(14); };
void()	enf_run6 = [$run6, enf_run7] {ai_run(14); };
void()	enf_run7 = [$run7, enf_run8] {ai_run(7); };
void()	enf_run8 = [$run8, enf_run1] {ai_run(11); };

void()	enf_atk1 = [$attack1, enf_atk2] {ai_face(); };
void()	enf_atk2 = [$attack2, enf_atk3] {ai_face(); };
void()	enf_atk3 = [$attack3, enf_atk4] {ai_face(); };
void()	enf_atk4 = [$attack4, enf_atk5] {ai_face(); };
void()	enf_atk5 = [$attack5, enf_atk6] {ai_face(); };
void()	enf_atk6 = [$attack6, enf_atk7] {enforcer_fire(); };
void()	enf_atk7 = [$attack7, enf_atk8] {ai_face(); };
void()	enf_atk8 = [$attack8, enf_atk9] {ai_face(); };
void()	enf_atk9 = [$attack5, enf_atk10] {ai_face(); };
void()	enf_atk10 = [$attack6, enf_atk11] {enforcer_fire(); };
void()	enf_atk11 = [$attack7, enf_atk12] {ai_face(); };
void()	enf_atk12 = [$attack8, enf_atk13] {ai_face(); };
void()	enf_atk13 = [$attack9, enf_atk14] {ai_face(); };
void()	enf_atk14 = [$attack10, enf_run1] {ai_face(); SUB_CheckRefire(enf_atk1);
}; */

void() human_melee =
{

}

void() h_death1 =
{

}

void() man_die =
{

}


void() monster_human =
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

	precache_body_model2("progs/human.mdl");  // custom_mdls function -- dumptruck_ds
	precache_head_model2("progs/h_man.mdl");
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
	setsize(self, '-16 -16 -24', '16 16 40');

	if (!self.health) //thanks RennyC -- dumptruck_ds
		self.health = 80;

	self.th_stand = man_stand1;
	self.th_walk = man_walk1;
	self.th_run = man_run1;
	if !(self.berserk) //Berserk test from http://celephais.net/board/view_thread.php?id=4&start=3465 -- dumptruck_ds
		self.th_pain = man_pain;
	else
		self.th_pain = SUB_NullPain;
	self.th_die = man_die;
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
		self.frame = $fdeath11;

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
		self.frame = $death14;
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
