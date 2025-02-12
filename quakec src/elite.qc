/*
==============================================================================

Lemurian --ALEX

==============================================================================
*/

//$cd id1 / models / human
//$origin 0 - 6 24
//$base base
//$skin skin

$frame stand1

//============================================================================

void() elite_fire =
{
	local vector org;

	self.effects = self.effects | EF_MUZZLEFLASH;
	makevectors(self.angles);

	org = self.origin + v_forward * 30 + v_right * 8.5 + '0 0 16';

	LaunchLaser(org, self.enemy.origin - self.origin);
	self.attack_finished = time + 0.5;
};

void()	elite_stand1 = [$stand1, elite_stand1] {ai_stand(); };

void()	elite_walk1 = [$stand1, elite_walk1] {ai_walk(4); };

void() elite_run1 = [$stand1, elite_run1] {ai_run(14); };

void()	elite_atk1 = [$stand1, elite_atk2] {ai_face(); };
void()	elite_atk2 = [$stand1, elite_atk3] {ai_face(); };
void()	elite_atk3 = [$stand1, elite_atk4] {ai_face(); };
void()	elite_atk4 = [$stand1, elite_atk5] {ai_face(); };
void()	elite_atk5 = [$stand1, elite_atk6] {ai_face(); };
void()	elite_atk6 = [$stand1, elite_atk7] {elite_fire(); };
void()	elite_atk7 = [$stand1, elite_atk8] {ai_face(); };
void()	elite_atk8 = [$stand1, elite_atk9] {ai_face(); };
void()	elite_atk9 = [$stand1, elite_atk10] {ai_face(); };
void()	elite_atk10 = [$stand1, elite_atk11] {elite_fire(); };
void()	elite_atk11 = [$stand1, elite_atk12] {ai_face(); };
void()	elite_atk12 = [$stand1, elite_atk13] {ai_face(); };
void()	elite_atk13 = [$stand1, elite_atk14] {ai_face(); };
void()	elite_atk14 = [$stand1, elite_run1] {ai_face(); SUB_CheckRefire(enf_atk1);
};

void(entity attacker, float damage) elite_pain = {
return;};

void() elite_die =
{

if (self.health < -35)
{
	sound(self, CHAN_VOICE, "player/udeath.wav", 1, ATTN_NORM);
	if (self.mdl_head != "") //dumptruck_ds custom_mdls
	{
		ThrowHead(self.mdl_head, self.health);
	} else
	{
		ThrowHead("progs/h_mega.mdl", self.health);
	}
	if (self.mdl_gib1 != "") // custom models -- dumptruck_ds
	{
		ThrowGib(self.mdl_gib1, self.health);
	} else
	{
		ThrowGib("progs/gib1.mdl", self.health);
	}
	if (self.mdl_gib2 != "")
	{
		ThrowGib(self.mdl_gib2, self.health);
	} else
	{
		ThrowGib("progs/gib2.mdl", self.health);
	}
	if (self.mdl_gib3 != "")
	{
		ThrowGib(self.mdl_gib3, self.health);
	} else
	{
		ThrowGib("progs/gib3.mdl", self.health);
	}

	//DropStuff();
	return;
}
else
self.solid = SOLID_NOT;
}

void() monster_elite =
{
	if (SUB_Inhibit())  // new spawnflags for all entities -- iw
		return;

	//if (self.style >= 6)
		//objerror("style key set too high\n");

	precache_body_model2("progs/e_mdls/elite.mdl");  // custom_mdls function -- dumptruck_ds
	precache_proj_model2("progs/laser.mdl");
	precache_sound2_attack("enforcer/enfire.wav");

	precache_gib1("progs/gib1.mdl");
	precache_gib2("progs/gib2.mdl");
	precache_gib3("progs/gib3.mdl");

	spawn_monster_elite();
	walkmonster_start();
};

void() spawn_monster_elite =
{
self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	body_model("progs/e_mdls/elite.mdl");
	setsize(self, '-16 -16 0', '16 16 96');

	if (!self.proj_speed_mod)
	{
		self.proj_speed_mod = 1;
	}
	if (!self.health)
		self.health = 80;

	self.th_stand = elite_stand1;
	self.th_walk = elite_walk1;
	self.th_run = elite_run1;
	self.th_missile = elite_atk1;
	if !(self.berserk) //Berserk test from http://celephais.net/board/view_thread.php?id=4&start=3465 -- dumptruck_ds
		self.th_pain = elite_pain;
	else
		self.th_pain = SUB_NullPain;
	self.th_die = elite_die;

	self.classname = "monster_elite";
	self.ideal_yaw = self.angles * '0 1 0';
	self.yaw_speed = 120;
	//if !(self.view_ofs)
		self.view_ofs = '0 0 80';
}

void() func_spawn_elite_use =
{
	think_respawn(spawn_monster_elite);
}

/*QUAKED func_spawn_elite (.75 0 .75) (-8 -8 -8) (8 8 8) REUSABLE X X X X X X X NOT_ON_EASY NOT_ON_NORMAL NOT_ON_HARD_OR_NIGHTMARE NOT_IN_DEATHMATCH NOT_IN_COOP NOT_IN_SINGLEPLAYER X NOT_ON_HARD_ONLY NOT_ON_NIGHTMARE_ONLY
Spawns monsters to targeted info_monster_spawnpoint
*/
void() func_spawn_elite =
{
	precache_body_model2("progs/e_mdls/elite.mdl");  // custom_mdls function -- dumptruck_ds
	precache_proj_model2("progs/laser.mdl");
	precache_sound2_attack("enforcer/enfire.wav");

	precache_gib1("progs/gib1.mdl");
	precache_gib2("progs/gib2.mdl");
	precache_gib3("progs/gib3.mdl");

	if (SUB_Inhibit ())
		return;

	self.use = self.think = func_spawn_elite_use;
	func_spawn_start();
}