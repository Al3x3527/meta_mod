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
Short Guy
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
Guy code
*/

void()	short_stand1 = [$stand1, short_stand2] {ai_stand(); };
void()	short_stand2 = [$stand1, short_stand1] {ai_stand(); };


void()	short_walk1 = [$walk1, short_walk2] {
	if (random() < 0.2)
		sound_idle(self, CHAN_VOICE, "enforcer/idle1.wav", 1, ATTN_IDLE); //dumptruck_ds
	ai_walk(2); };
void()	short_walk2 = [$walk2, short_walk3] {ai_walk(4); };
void()	short_walk3 = [$walk3, short_walk1] {ai_walk(4); };

void()	short_run1 = [$walk1, short_run2] {
	ai_run(6); //move to waypoint, face enemy
};
void()	short_run2 = [$walk2, short_run3] {ai_run(6);	};
void()	short_run3 = [$walk3, short_run1] {ai_run(6);	};

void()	short_atk1 = [$shoot1, short_atk2] {ai_face(); self.count = 0; self.t_length = 4 + floor(random() * 4); };
void()	short_atk2 = {
	//dprint("short atk2\n");
self.frame = $shoot2;
self.nextthink = time + .1;
self.think = short_atk3;
ai_face();
short_fire();
self.effects = self.effects | EF_MUZZLEFLASH; };
void()	short_atk3 = [$shoot1, short_atk4] {ai_face(); };
void()	short_atk4 = [$shoot1, short_atk1] {ai_face(); SUB_CheckRefire(short_atk1); };

void() short_fire =
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

void(entity attacker, float damage) shortguy_pain =
{
	if (self.pain_finished > time)
		return;
self.pain_finished = time + 0.6;
sound_pain(self, CHAN_VOICE, "soldier/pain1.wav", 1, ATTN_NORM);
short_pain();
};

void() short_pain = { ai_pain(1); };

void()	short_hit1 = [$shoot1, short_hit2] {ai_melee();	//dprint("shortguy melee\n"); 
};
void()	short_hit2 = [$shoot2, short_hit1] {ai_melee();	};

void() shortguy_melee = {short_hit1();}

void() short_death1 = {short_die();}

void() short_die =
{
	remove(self);
	return;
}


void() monster_shortguy =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	if (deathmatch)
	{
		remove(self);
		return;
	}

	precache_body_model2("progs/e_mdls/shortguy.mdl");  // custom_mdls function -- dumptruck_ds
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

	body_model("progs/e_mdls/shortguy.mdl");
	setsize(self, '-16 -16 16', '16 16 56');

	if (!self.health) //thanks RennyC -- dumptruck_ds
		self.health = 80;

	self.th_stand = short_stand1;
	self.th_walk = short_walk1;
	self.th_run = short_run1;
	self.th_melee = shortguy_melee;
	self.th_missile = short_atk1;
	if !(self.berserk) //Berserk test from http://celephais.net/board/view_thread.php?id=4&start=3465 -- dumptruck_ds
		self.th_pain = shortguy_pain;
	else
		self.th_pain = SUB_NullPain;
	self.th_die = short_death1;
	walkmonster_start();
};

void() monster_dead_shortguy =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	precache_model("progs/e_mdls/shortguy.mdl");
	setmodel(self, "progs/e_mdls/shortguy.mdl");
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
