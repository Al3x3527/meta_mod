/*
============================================================

Vehicle_Truck

============================================================
*/

//forwards
$frame forward1 forward2
//right
$frame right1 right2
//left
$frame left1 left2

//calculate vehicle_truck velocity and avelocity from wheels post engine physics
void(float dist) truck_physics =
{
	local vector vec1, vec2, vec3, vec4;
	local entity truck = self;

	//=================================================================
	//steer and throttle inputs 
	//=================================================================

	//get input vectors
	//local float dist = 10; //temp
	local vector dir;
	if (self.driver)
	dir = aim(self.owner.driver, 1000);
	else dir = '0 1 0';
	//dir.z = 0; // steer in xy plane
	//dir.x = 0;
	//dir = normalize(dir);

	//truck vectors - velocity from wheels vs gravity, est grip
	local vector svec = truck.velocity;
	local vector avec = truck.avelocity;
	//local vector fakevelocity = dist * 10 * dir;
	//clamp steer yaw to +- 85 degrees from current yaw
	//local float fakedist = vlen(fakevelocity); //was - svec
	local vector fakeangles = truck.angles;
	fakeangles.x = -fakeangles.x;
	makevectors(fakeangles); //starting angles

	local float steer_yaw = vectoyaw(dir);
	//if ((dir * v_right) > 0) dprint("right\n");

	//=================================================================
	//front wheels work against momentum
	//=================================================================
	   
	//ideal work against momentum
	//front wheels
	self = truck.wheel1; //virtual
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	local vector view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin; //start from the resting position
	self.flyhack.z = self.origin.z - view.z;
	setorigin (self, view);  //make reset after finding delta
	subwalkmove(steer_yaw, dist); //movetype_step physics
	vec1 = self.origin - view; //get to current position from start position
	vec1.z = self.flyhack.z;
	//vec1 = 10 * vec1; //as velocity
	vec1.z = .6 * vec1.z + (self.velocity.z * 0.1); //damped spring ratio
	//local vector xvec1 = vec1; xvec1.z = 0;
	if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	self.velocity.z = vec1.z - 10; //for next think

	self = truck.wheel2;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	self.flyhack.z = self.origin.z - view.z;
	setorigin(self, view);
	subwalkmove(steer_yaw, dist);
	vec2 = self.origin - view;
	//vec2 = 10 * vec2;
	vec2.z = self.flyhack.z;
	vec2.z = .6 * vec2.z + (self.velocity.z * 0.1);
	
	//local vector xvec2 = vec1; xvec2.z = 0;
	if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	self.velocity.z = vec2.z - 10;
	
	//=================================================================
	//change in rear wheels velocity
	//=================================================================

	local vector pivot = (truck.wheel1.origin + truck.wheel2.origin) * 0.5;
	pivot.z = pivot.z - truck.wheel1.view_ofs.z; //level with vehicle
	local vector chassis_vec = pivot - truck.origin; //delta (forward vec)
	local float chassis_yaw = vectoyaw(chassis_vec); //new truck yaw

	//rear wheels
	self = truck.wheel3;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	self.flyhack.z = self.origin.z - view.z;
	setorigin(self, view);
	subwalkmove(chassis_yaw, dist); //move from view
	vec3 = self.origin - view; //movestep delta
	//vec3 = 10 * vec3;
	vec3.z = self.flyhack.z;
	vec3.z = .6 * vec3.z + (self.velocity.z * 0.1);
	//local vector xvec3 = vec3;	xvec3.z = 0;
	if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	self.velocity.z = vec3.z - 10;

	self = truck.wheel4;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	self.flyhack.z = self.origin.z - view.z;
	setorigin(self, view);
	subwalkmove(chassis_yaw, dist);
	vec4 = self.origin - view;
	//vec4 = 10 * vec4;
	vec4.z = self.flyhack.z;
	vec4.z = .6 * vec4.z + (self.velocity.z * 0.1);
	//local vector xvec4 = vec4;	xvec4.z = 0;
	if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	self.velocity.z = vec4.z - 10;

	//=================================================================
	//vehicle forces, moments
	//=================================================================
	//all fake wheels are in ideal locations and ideal velocities have been calculated for each wheel

	/*
	//grip
	chassis_vec = normalize(chassis_vec);
	local vector grip1, grip2, grip3, grip4;
	grip1 = normalize(vec1) * 3;
	grip2 = normalize(vec2) * 3;
	grip3 = normalize(vec3) * 3;
	grip4 = normalize(vec4) * 3;
	//if !(truck.wheel1.flags & FL_ONGROUND) does not work
	if (vec1.z < 0)
		grip1 = '0 0 0';
	else {
		grip1 = (10 - vec1.z) * grip1; //mu*m*svec1.z^2
	//	vec1.z = 0;
		}
	if (vec2.z < 0)
		grip2 = '0 0 0';
	else {
		grip2 = (10 - vec2.z) * grip2;
	//	vec2.z = 0;
		}
	if (vec3.z < 0)
		grip3 = '0 0 0';
	else {
		grip3 = (10 - vec3.z) * grip3;
	//	vec3.z = 0;
		}
	if (vec4.z < 0)
		grip4 = '0 0 0';
	else {
		grip4 = (10 - vec4.z) * grip4;
	//	vec4.z = 0;
		}
		*/
	local vector tvec = svec * 0.025;

	local vector work1 = vec1;	work1.z = 0;
	//work1 = vlimit(work1, grip1);
	//work1 = vcontrol(work1, tvec);
	work1.z = vec1.z;
	truck.wheel1.flyhack = work1;

	local vector work2 = vec2;	work2.z = 0;
	//work2 = vlimit(work2, grip2);
	//work2 = vcontrol(work2, tvec);
	work2.z = vec2.z;
	truck.wheel2.flyhack = work2;

	local vector work3 = vec3;	work3.z = 0;
	//work3 = vcontrol(work3, tvec);
	work3.z = vec3.z;
	truck.wheel3.flyhack = work3;

	local vector work4 = vec4;	work4.z = 0;
	//work4 = vcontrol(work4, tvec);
	work4.z = vec4.z;
	truck.wheel4.flyhack = work4;

	//actual travel
	//svec = (svec + (work1 + work2 + work3 + work4) * 10);
	svec = work1 + work2 + work3 + work4;
	//svec.x = svec.x * 10;
	//svec.y = svec.y * 10;
	//work1.z = 0.1 * work1.z; work2.z = 0.1 * work2.z;
	//work3.z = -0.1 * work3.z; work4.z = -0.1 * work4.z;
	local float dang;
	local vector final_vec = v_forward + work1 + work2 - work3 - work4;
	local vector final_angs = vectoangles(final_vec);
	//chassis_angs.x = -chassis_angs.x;
	dang = final_angs.x + truck.angles.x; //to flip
	if (dang > 180) dang = -360 + dang;
	else if (dang < -180) dang = 360 + dang;
	avec.x = ((dang) * 0.9);

	dang = (final_angs.y - truck.angles.y);
	if (dang > 180) dang = -360 + dang;
	else if (dang < -180) dang = 360 + dang;
	avec.y = ((dang) * 0.9);
	local float final_yaw = vectoyaw(final_vec);
	
	//makevectors(final_angs);
	//local float final_dist = (svec * v_forward * 0.1);
	/*
	self = truck.wheel1;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	setorigin(self, view);
	if !(self.flags & FL_ONGROUND) self.flags = self.flags + FL_ONGROUND;
	subwalkmove(final_yaw, final_dist);

	self = truck.wheel2;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	setorigin(self, view);
	if !(self.flags & FL_ONGROUND) self.flags = self.flags + FL_ONGROUND;
	subwalkmove(final_yaw, final_dist);

	self = truck.wheel3;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	setorigin(self, view);
	if !(self.flags & FL_ONGROUND) self.flags = self.flags + FL_ONGROUND;
	subwalkmove(final_yaw, final_dist);

	self = truck.wheel4;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	setorigin(self, view);
	if !(self.flags & FL_ONGROUND) self.flags = self.flags + FL_ONGROUND;
	subwalkmove(final_yaw, final_dist);
	*/

	dprint("\n");
	//dprint(vtos(dir));
	//dprint(" dir\n");
	//dprint(vtos(chassis_vec));
	//dprint(" chassis vec\n");
	dprint(vtos(final_angs));
	dprint(" final angs\n");
	//dprint(ftos(final_yaw));
	//dprint(" final yaw\n");
	//dprint(ftos(dang));
	//dprint(" dang\n");
	//dprint(ftos(steer_yaw));
	//dprint(" steer yaw\n");
	//dprint(ftos(vectoyaw(truck.angles)));
	//dprint(" start yaw\n");
	dprint(vtos(truck.angles));
	dprint(" start angles\n");
	//dprint(vtos(avec));
	//dprint(" avec\n");
	//=================================================================
	//vehicle velocity, avelocity
	//=================================================================

	//suspension, move chassis
	truck.avelocity = '0 0 0'; //from equalibrium
	//avec.x = 0;
	//avec.z = 0;
	truck.avelocity.y = avec.y * 1; //only yaw for now
	truck.avelocity.x = avec.x * 1; //pitch
	truck.velocity = svec;
	//truck.velocity.x = 0;
	//truck.velocity.y = 0;

	//fix stuck
	
	//if ((!(truck.velocity.z > 0) && (truck.flags & FL_ONGROUND))
	if ((truck.flags & FL_ONGROUND) && (truck.origin.z < (truck.height + (truck.velocity.z * 0.025))))
	{ 
		truck.velocity.z = 0;
		setorigin(truck, truck.origin + '0 0 18');
		setorigin(truck.wheel1, truck.wheel1.origin + '0 0 16');
		setorigin(truck.wheel2, truck.wheel2.origin + '0 0 16');
		setorigin(truck.wheel3, truck.wheel3.origin + '0 0 16');
		setorigin(truck.wheel4, truck.wheel4.origin + '0 0 16');
		truck.flags = truck.flags - FL_ONGROUND;
		dprint("truck stuck fix\n");
		}
	
	truck.height = truck.origin.z;
	truck.flyhack = truck.velocity;

	truck.ideal_yaw = final_yaw;
	//dprint(vtos(truck.velocity));
	//dprint("truck velocity\n");
	//passengers after return
	self = truck;
	subChangeYaw(); //stops things  from breaking
	//truck.angles.y = final_angs.y;
};

void() move_truck =
{
	//movestep
	local float dist = 0;
	if (self.driver) {
		dist = 15;
	//chassis physics / prethink
	truck_physics(dist); }

	//child physics
	//if (self.driver)
		//cpyall(self.driver, dist);
	//cpyall(self.passenger, dist);
	//cpyall(self.turret, dist);

	//animate
	self.nextthink = time + .1;
};

void() truck_touch =
{
	if (!CheckValidTouch()) return;// from Copper -- dumptruck_ds

	if (!(other.flags & FL_CLIENT))
		return;
	if (self.driver == other) return;
	if (self.count < time) {
		sprint(other, "Press E to drive Truck\n");
		}
	self.count = time + 0.02;
	if (other.impulse == 16) {
		other.impulse = 0;
		self.driver = other;
		}
}

//physics wheels
void(float i) spawn_truck_wheel =
{
	local entity truck = self;
	
	local entity wheel = spawn();
	self = wheel;
	self.movetype = MOVETYPE_STEP;
	self.owner = truck;
	self.solid = SOLID_TRIGGER;
	self.classname = "wheel";
	setsize(self, '-7 -7 -7', '7 7 7');
	if !(i) {
	truck.wheel1 = self;
	self.view_ofs = '70 35 7'; //placeholder
	}
	else if (i == 1) {
	truck.wheel2 = self;
	self.view_ofs = '70 -35 7';
	}
	else if (i == 2) {
	truck.wheel3 = self;
	self.view_ofs = '-70 35 7';
	}
	else if (i == 3) {
	truck.wheel4 = self;
	self.view_ofs = '-70 -35 7';
	}
	else dprint("too many wheels spawned!\n");
	setorigin(self, truck.origin + self.view_ofs);
	self = truck;
}

void() spawn_vehicle_truck =
{
	//body with wheels model
	self.solid = SOLID_TRIGGER;
	self.movetype = MOVETYPE_FLY;
	self.flags = FL_VEHICLE;
	body_model("progs/e_mdls/e_truck.mdl");
	setsize(self, '-112 -40 18', '112 40 80');

	//wheels -- not the visible model
	
	local float i = 0;
	while (i < 4)
	{
		spawn_truck_wheel(i);
		i++;
	}
	self.touch = truck_touch;
	self.think = move_truck;
	self.nextthink = time + 0.1;
};

//Vanilla Spawning
void() vehicle_truck =
{
	precache_model("progs/e_mdls/e_truck.mdl");
	if (SUB_Inhibit())
		return;
	spawn_vehicle_truck();
};

void() func_spawn_truck_use =
{
	local entity truck = spawn();
	self = truck;
	spawn_vehicle_truck();
};

void() func_spawn_truck =
{
	if (SUB_Inhibit())
		return;

	self.use = self.think = func_spawn_truck_use;
	func_spawn_start();
};