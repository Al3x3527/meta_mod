/*QUAKED item_oil (1 1 1) (0 0 0) (32 32 32) SPAWN_SILENT TRIGGER_SPAWNED SUSPENDED_IN_AIR NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER RESPAWN_WITH_DM_EFFECTS NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY

Motor Oil 5qt. give 15 health.
*/

void() item_oil =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	if (!self.mdl_body && world.oil_mdl)
	{
	  self.mdl_body = world.oil_mdl;
	}

	self.touch = health_touch;
	precache_body_model("progs/e_mdls/oil.mdl");
	body_model("progs/e_mdls/oil.mdl");
	precache_sound_misc("items/r_item1.wav");
	if !(self.skin) // dumptruck_ds custom models and sounds END
	self.skin = 0;
	setsize(self, '-16 -16 0', '16 16 56');

	// if !(self.healamount) //set your custom health amount here -- dumptruck_ds
	self.healamount = 15;
	self.healtype = 0;
	self.snd_misc = "items/r_item1.wav";
	self.noise = self.snd_misc;

	StartItem();
};

/* 
Goblin
=====================================================================================================================================
*/

$cd id1 / models / soldier3
$origin 0 - 6 24
$base base
$skin skin

$frame stand1

$frame walk1 walk2 walk3

$frame shoot1 shoot2

/*
Goblin code
*/

void()	goblin_stand1 = [$stand1, goblin_stand2] {ai_stand(); };
void()	goblin_stand2 = [$stand1, goblin_stand1] {ai_stand(); };


void()	goblin_walk1 = [$walk1, goblin_walk2] {
	if (random() < 0.2)
		sound_idle(self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE); //dumptruck_ds
	ai_walk(2); };
void()	goblin_walk2 = [$walk2, goblin_walk3] {ai_walk(4); };
void()	goblin_walk3 = [$walk3, goblin_walk1] {ai_walk(4); };

void()	goblin_run1 = [$walk1, goblin_run2] {
	//dprint("goblin run1\n");
	ai_run(6); //move to waypoint, face enemy
};
void()	goblin_run2 = [$walk2, goblin_run3] {ai_run(6);	};
void()	goblin_run3 = [$walk3, goblin_run1] {ai_run(6);	};

void()	goblin_atk1 = [$shoot1, goblin_atk2] {ai_face(); self.count = 0; self.t_length = 4 + floor(random() * 4); };
void()	goblin_atk2 = {
	//dprint("goblin atk2\n");
self.frame = $shoot2;
self.nextthink = time + .1;
self.think = goblin_atk3;
ai_face();
goblin_fire();
self.effects = self.effects | EF_MUZZLEFLASH; };
void()	goblin_atk3 = [$shoot1, goblin_atk4] {ai_face(); };
void()	goblin_atk4 = [$shoot1, goblin_atk1] {ai_face(); SUB_CheckRefire(goblin_atk1); };

void() goblin_fire =
{
	local	vector	dir;
	local	entity	en;

	ai_face();

	sound_attack(self, CHAN_WEAPON, "soldier/sattck1.wav", 1, ATTN_NORM);

	// fire somewhat behind the player, so a dodging player is harder to hit
	en = self.enemy;

	dir = en.origin - en.velocity*0.2;
	dir = normalize(dir - self.origin);

	FireBullets(4, dir, '0.1 0.1 0');

};

void(entity attacker, float damage) goblin_pain =
{
	if (self.pain_finished > time)
		return;
self.pain_finished = time + 0.6;
sound_pain(self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
goblin_pain1();
};

void() goblin_pain1 = { ai_pain(1); };

void()	goblin_hit1 = [$shoot1, goblin_hit2] {ai_melee();	//dprint("shortguy melee\n"); 
};
void()	goblin_hit2 = [$shoot2, goblin_hit1] {ai_melee();	};

void() goblin_melee = { goblin_hit1();}

void() goblin_death1 = { goblin_die();}

void() goblin_die =
{
	remove(self);
	return;
}


void() monster_goblin =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_body_model2("progs/e_mdls/goblin.mdl");  // custom_mdls function -- dumptruck_ds
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

	body_model("progs/e_mdls/goblin.mdl");
	setsize(self, '-16 -16 16', '16 16 56');

	if (!self.health) //thanks RennyC -- dumptruck_ds
		self.health = 80;

	self.th_stand = goblin_stand1;
	self.th_walk = goblin_walk1;
	self.th_run = goblin_run1;
	self.th_melee = goblin_melee;
	self.th_missile = goblin_atk1;
	if !(self.berserk) //Berserk test from http://celephais.net/board/view_thread.php?id=4&start=3465 -- dumptruck_ds
		self.th_pain = goblin_pain;
	else
		self.th_pain = SUB_NullPain;
	self.th_die = goblin_death1;
	walkmonster_start();
};

void() monster_dead_goblin =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	precache_model("progs/e_mdls/goblin.mdl");
	setmodel(self, "progs/e_mdls/goblin.mdl");
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
