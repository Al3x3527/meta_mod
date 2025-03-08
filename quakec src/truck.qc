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
	//dir.y = -dir.y;
	dir.z = 0; // steer in xy plane
	dir = normalize(dir);

	//truck vectors - velocity from wheels vs gravity, est grip
	local vector svec = truck.velocity;
	local vector avec = truck.avelocity;
	local vector fakevelocity = dist * 10 * dir;
	//clamp steer yaw to +- 85 degrees from current yaw
	local float fakedist = vlen(fakevelocity); //was - svec
	local vector fakeangles = truck.angles;
	fakeangles.x = -fakeangles.x;
	makevectors(fakeangles); //starting angles


		//dprint(vtos(dir));
		//dprint("\n");
	local float steer_yaw = vectoyaw(dir);
	local vector oldpivot = (truck.wheel1.origin + truck.wheel2.origin) * 0.5;
	if ((dir * v_right) > 0) dprint("right\n");

	//=================================================================
	//front wheels work against momentum
	//=================================================================
	   
	//ideal work against momentum
	//front wheels
	self = truck.wheel1; //virtual
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	local vector view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin; //start from the resting position
	vec1 = self.origin - view; //ideal distance traveled after walk physics (gravity?)
	//dprint(vtos(vec1));
	//dprint("vec1\n");
	vec1 = 10 * vec1; //as velocity
	vec1.z = .6 * vec1.z; //damped spring ratio
	setorigin (self, view);  //make reset after finding delta
	subwalkmove(steer_yaw, fakedist); //movetype_step physics
	local vector xvec1 = vec1; xvec1.z = 0;
	self.velocity.z = vec1.z = vec1.z - 20;

	//dprint(vtos(self.velocity));
	//dprint("wheel 1 velocity\n");

	self = truck.wheel2;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	vec2 = self.origin - view;
	vec2 = 10 * vec2;
	vec2.z = .6 * vec2.z;
	setorigin(self, view);
	subwalkmove(steer_yaw, fakedist);
	local vector xvec2 = vec1; xvec2.z = 0;
	self.velocity.z = vec2.z = vec2.z - 20;
	
	//=================================================================
	//change in rear wheels velocity
	//=================================================================

	//truck yaw (ideal)
	//local vector axel = truck.wheel1.origin - truck.wheel2.origin; //lateral vec
	//local float axel_yaw = vectoyaw(axel) + 90;
	//local float truck_yaw = vectoyaw(truck.angles); //original truck yaw

	local vector pivot = (truck.wheel1.origin + truck.wheel2.origin) * 0.5;
	local vector chassis_vec = pivot - truck.origin; //delta (forward vec)
	local float chassis_yaw = vectoyaw(chassis_vec); //new truck yaw
	pivot = pivot - oldpivot;

	//local float truck_dist = pivot * chassis_vec;
	//truck_yaw = (axel_yaw - truck_yaw) * 10; //ideal
	//local vector lateral = truck_yaw * truck_dist * normalize(axel);

	//rear wheels
	self = truck.wheel3;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	//if (self.flags & FL_ONGROUND) {
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	vec3 = self.origin - view; //movestep delta
	vec3 = 10 * vec3;
	vec3.z = .6 * vec3.z;
	setorigin(self, view);
	local vector xvec3 = vec3;	xvec3.z = 0;
	subwalkmove(chassis_yaw, dist);
	//} 
	self.velocity.z = vec3.z = vec3.z - 20;

	self = truck.wheel4;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	//if (self.flags & FL_ONGROUND) {
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	vec4 = self.origin - view;
	vec4 = 10 * vec4;
	vec4.z = .6 * vec4.z;
	setorigin(self, view);
	local vector xvec4 = vec4;	xvec4.z = 0;
	subwalkmove(chassis_yaw, dist);
	//} 
	self.velocity.z = vec4.z = vec4.z - 20;

	//=================================================================
	//vehicle forces, moments
	//=================================================================
	//all fake wheels are in ideal locations and ideal velocities have been calculated for each wheel

	//grip
	chassis_vec = normalize(chassis_vec);
	local vector grip1, grip2, grip3, grip4;
	if !(truck.wheel1.flags & FL_ONGROUND)
		grip1 = '0 0 0';
	else { //vec1.z = vec1.z - 10;
		grip1 = (10 - vec1.z) * dir * 3; //mu*m*svec1.z^2
		truck.wheel1.velocity.z = vec1.z = 0;
		}
	if !(truck.wheel2.flags & FL_ONGROUND)
		grip2 = '0 0 0';
	else {// vec2.z = vec2.z - 10;
		grip2 = ( 10 - vec2.z) * dir * 3;
		truck.wheel2.velocity.z = vec2.z = 0;
		}
	if !(truck.wheel3.flags & FL_ONGROUND)
		grip3 = '0 0 0';
	else {// vec3.z = vec3.z - 10;
		grip3 = (10 - vec3.z) * chassis_vec * 3;
		truck.wheel3.velocity.z = vec3.z = 0;
		}
	if !(truck.wheel4.flags & FL_ONGROUND)
		grip4 = '0 0 0';
	else {// vec4.z = vec4.z - 10;
		grip4 = (10 - vec4.z) * chassis_vec * 3;
		truck.wheel4.velocity.z = vec4.z = 0;
		}

	//roll from z --double check directions
	local float mx1 = vec1.z * truck.wheel1.view_ofs.y;
	local float mx2 = vec2.z * truck.wheel2.view_ofs.y;
	local float mx3 = vec3.z * truck.wheel3.view_ofs.y;
	local float mx4 = vec4.z * truck.wheel4.view_ofs.y;
	avec.z = avec.z + mx1 + mx2 + mx3 + mx4;
	//roll from y
	mx1 = vec1.y * truck.wheel1.view_ofs.z;
	mx2 = vec2.y * truck.wheel2.view_ofs.z;
	mx3 = vec3.y * truck.wheel3.view_ofs.z;
	mx4 = vec4.y * truck.wheel4.view_ofs.z;
	avec.z = avec.z + mx1 + mx2 + mx3 + mx4;

	//pitch from z
	local float my1 = vec1.z / truck.wheel1.view_ofs.x;
	local float my2 = vec2.z / truck.wheel2.view_ofs.x;
	local float my3 = vec3.z / truck.wheel3.view_ofs.x;
	local float my4 = vec4.z / truck.wheel4.view_ofs.x;
	avec.x = (avec.x * 0) + my1 + my2 + my3 + my4;
	//pitch from x
	my1 = vec1.x / truck.wheel1.view_ofs.z;
	my2 = vec2.x / truck.wheel2.view_ofs.z;
	my3 = vec3.x / truck.wheel3.view_ofs.z;
	my4 = vec4.x / truck.wheel4.view_ofs.z;
	avec.x = (avec.x + my1 + my2 + my3 + my4) * 1;
	local vector chassis_angs = vectoangles(chassis_vec);
	avec.x = avec.x + ((chassis_angs.x - truck.angles.x) * 10);
	

	//work -- vector from momentum to ideal
	//only front wheels do work in ideal direction
	local vector work1 = vec1 - svec;
	work1.z = 0; //exclude vertical travel
	if (vlen(grip1) < vlen(work1))
		work1 = grip1; //limit work to grip
	if (vlen(work1) < vlen(svec))
		work1 = vlen(grip1) * normalize(grip1 - xvec1);
	work1.z = vec1.z - 10;
	if !(truck.wheel1.flags & FL_ONGROUND)
	{dprint(vtos(work1)); dprint(" no grip work1\n");}

	local vector work2 = vec2 - svec;
	work2.z = 0;
	if (vlen(grip2) < vlen(work2))
		work2 = grip2;
	if (vlen(work2) < vlen(svec))
		work2 = vlen(grip2) * normalize(grip2 - xvec2);
	work2.z = vec2.z - 10;

	local vector work3 = grip3;
	if (vlen(work3) < vlen(svec))
		work3 = vlen(grip3) * normalize(grip3-xvec3); //grip against momentum
	work3.z = vec3.z - 10;
	local vector work4 = grip4;
	if (vlen(work4) < vlen(svec))
		work4 = vlen(grip4) * normalize(grip4-xvec4);
	work4.z = vec4.z - 10;
	//actual travel
	//local vector xvec = svec;
	//xvec.z = 0;
	//svec.z = 0;
	svec = (svec + work1 + work2 + work3 + work4);
	//lift
	//svec.z = svec.z - 40;

	//yaw from work in x
	local float mz1 = work1.x / truck.wheel1.view_ofs.y;
	local float mz2 = work2.x / truck.wheel2.view_ofs.y;
	local float mz3 = work3.x / truck.wheel3.view_ofs.y;
	local float mz4 = work4.x / truck.wheel4.view_ofs.y;
	avec.y = avec.y + mz1 + mz2 + mz3 + mz4;

	//yaw from work in y
	mz1 = work1.y / truck.wheel1.view_ofs.x;
	mz2 = work2.y / truck.wheel2.view_ofs.x;
	mz3 = work3.y / truck.wheel3.view_ofs.x;
	mz4 = work4.y / truck.wheel4.view_ofs.x;
	avec.y = avec.y + mz1 + mz2 + mz3 + mz4;
	local float dang = (chassis_yaw - truck.angles.y);
	if (dang > 180) dang = -360 + dang;
	else if (dang < -180) dang = 360 + dang;
	avec.y = ((dang) * 10) + avec.y;
	//dprint(ftos(chassis_yaw));
	//dprint(" chassis yaw\n");
	//dprint(ftos(dang));
	//dprint(" dang\n");
	//dprint(ftos(steer_yaw));
	//dprint(" steer yaw\n");
	//dprint(ftos(truck.angles.y));
	//dprint(" start yaw\n");
	dprint(vtos(avec));
	dprint(" avec\n");
	//=================================================================
	//vehicle velocity, avelocity
	//=================================================================

	//suspension, move chassis
	//truck.avelocity = '0 0 0'; //from equalibrium
	//avec.x = 0;
	//avec.z = 0;
	truck.avelocity.y = avec.y; //only yaw for now
	truck.avelocity.x = avec.x; //pitch
	truck.velocity = svec;
	if ((truck.velocity.z < 0) && (truck.flags & FL_ONGROUND)) { //fix stuck
		truck.velocity.z = 0;
		truck.flags = truck.flags - FL_ONGROUND;
		}
	//avec = truck.angles + (avec * .1);
	truck.ideal_yaw = chassis_yaw;
	dprint(vtos(truck.velocity));
	dprint("truck velocity\n");
	//passengers after return
	self = truck;
	subChangeYaw(); //stops things  from breaking
	//truck.avelocity.y = avec.y * 0.25; //to actually turn
};

void() move_truck =
{
	//movestep
	local float dist = 0;
	if (self.driver) {
		dist = 10;
	//chassis physics / prethink
	//self.ideal_yaw = vectoyaw(self.angles);
	truck_physics(dist); }

	//child physics
	//if (self.driver)
		//cpyall(self.driver, dist);
	//cpyall(self.passenger, dist);
	//cpyall(self.turret, dist);

	//animate
	self.nextthink = time + 0.1;
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
	//self.think = cpywalk;
	self.owner = truck;
	self.solid = SOLID_TRIGGER;
	//self.flags = self.flags + FL_ONGROUND;
	self.classname = "wheel";
	setsize(self, '-8 -8 -8', '8 8 8');
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
	body_model("progs/e_mdls/e_truck.mdl");
	setsize(self, '-112 -40 0', '112 40 80');

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