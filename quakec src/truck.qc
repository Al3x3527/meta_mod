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
float (float dist, vector dir) truck_physics =
{
	local vector vec1, vec2, vec3, vec4;
	local entity truck = self;

	//=================================================================
	//steer and throttle inputs 
	//=================================================================

	//get input vectors
	//local float dist = 10; //temp
	//local vector dir;
	//if (self.driver)
	//dir = aim(self.owner.driver, 1000);
	//else dir = '0 1 0';
	
	//truck vectors - velocity from wheels vs gravity, est grip
	local vector svec = truck.velocity;
	local vector avec = truck.avelocity;
	local vector tvec = svec * 0.025;
	local float throttle = 1;
	local float fakedist = dist;
	if !(dist) {
		throttle = -1;
		fakedist = vlen(tvec)/4;
		}
	//clamp steer yaw to +- 85 degrees from current yaw

	local vector fakeangles = truck.angles;
	fakeangles.x = -fakeangles.x;
	makevectors(fakeangles); //starting angles

	local float steer_yaw = vectoyaw(dir);
	local float deflection = 3;
	local float damping = 0.6;

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
	subwalkmove(steer_yaw, fakedist); //movetype_step physics
	vec1 = self.origin - view; //get to current position from start position
	vec1.z = self.flyhack.z;
	if (vlen(vec1) < (0.9 * fakedist)){ 
	dprint("short step\n");
	vec1 = self.flyhack;}//probably accomplishing nothing.
	vec1.z = zcontrol(vec1.z, deflection, damping); //damped spring ratio
	if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	self.velocity.z = vec1.z - 10; //for next think

	self = truck.wheel2;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	self.flyhack.z = self.origin.z - view.z;
	setorigin(self, view);
	subwalkmove(steer_yaw, fakedist);
	vec2 = self.origin - view;
	vec2.z = self.flyhack.z;
	if (vlen(vec2) < (0.9 * fakedist)) {
		dprint("short step\n");
		vec2 = self.flyhack;
	}
	vec2.z = zcontrol(vec2.z, deflection, damping);
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
	subwalkmove(chassis_yaw, fakedist); //move from view
	vec3 = self.origin - view; //movestep delta
	vec3.z = self.flyhack.z;
	vec3.z = zcontrol(vec3.z, deflection, damping);
	if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	self.velocity.z = vec3.z - 10;

	self = truck.wheel4;
	if ((self.velocity.z == 0) && !(self.flags & FL_ONGROUND)) self.flags = self.flags + FL_ONGROUND;
	view = self.view_ofs;
	view = v_forward * view.x + v_right * view.y + v_up * view.z + truck.origin;
	self.flyhack.z = self.origin.z - view.z;
	setorigin(self, view);
	subwalkmove(chassis_yaw, fakedist);
	vec4 = self.origin - view;
	vec4.z = self.flyhack.z;
	vec4.z = zcontrol(vec4.z, deflection, damping);
	if (self.flags & FL_ONGROUND) self.flags = self.flags - FL_ONGROUND;
	self.velocity.z = vec4.z - 10;

	//=================================================================
	//vehicle forces, target vector
	//=================================================================
	//all fake wheels are in ideal locations and ideal velocities have been calculated for each wheel

	//svec = '0 0 0';

	//grip
	local float fgrip;
	local float rgrip = 0.6;
	if (dist)
		fgrip = dist;
	else fgrip = rgrip;
	
	chassis_vec = normalize(chassis_vec);
	local vector grip1, grip2, grip3, grip4;
	grip1 = normalize(vec1) * fgrip + v_right * rgrip;
	grip2 = normalize(vec2) * fgrip + v_right * rgrip;
	grip3 = v_forward * fgrip + v_right * rgrip;
	grip4 = v_forward * fgrip + v_right * rgrip;
	//if !(truck.wheel1.flags & FL_ONGROUND) does not work
	if (vec1.z < -1)
		grip1 = '0 0 0';
	else {
		grip1 = (1 - vec1.z) * grip1; //mu*m*svec1.z^2
		vec1.z = vec1.z - tvec.z;
		}
	if (vec2.z < -1)
		grip2 = '0 0 0';
	else {
		grip2 = (1 - vec2.z) * grip2;
		vec2.z = vec2.z - tvec.z;
		}
	if (vec3.z < -1)
		grip3 = '0 0 0';
	else {
		grip3 = (1 - vec3.z) * grip3;
		vec3.z = vec3.z - tvec.z;
		}
	if (vec4.z < -1)
		grip4 = '0 0 0';
	else {
		grip4 = (1 - vec4.z) * grip4;
		vec4.z = vec4.z - tvec.z;
		}
	
	//tvec = tvec * 0.1;
	local float hack = 0.5;

	local vector work1 = vec1;	work1.z = 0;
	work1 = xylimit(work1, grip1) * throttle;
	local vector control1 = xycontrol(work1, tvec, hack);
	work1.z = vec1.z;
	truck.wheel1.flyhack = work1;
	control1 = control1 + work1;
	work1.z = work1.z * throttle;

	local vector work2 = vec2;	work2.z = 0;
	work2 = xylimit(work2, grip2) * throttle;
	local vector control2 = xycontrol(work2, tvec, hack);
	work2.z = vec2.z;
	truck.wheel2.flyhack = work2;
	control2 = control2 + work2;
	work2.z = work2.z * throttle;

	local vector work3 = vec3;	work3.z = 0;
	work3 = xylimit(work3, grip3) * throttle;
	local vector control3 = xycontrol(work3, tvec, hack);
	work3.z = vec3.z;
	truck.wheel3.flyhack = work3;
	control3 = control3 + work3;
	work3.z = work3.z * throttle;

	local vector work4 = vec4;	work4.z = 0;
	work4 = xylimit(work4, grip4) * throttle;
	local vector control4 = xycontrol(work4, tvec, hack);
	work4.z = vec4.z;
	truck.wheel4.flyhack = work4;
	control4 = control4 + work4;
	work4.z = work4.z * throttle;

	//actual travel
	svec = (svec + ((control1 + control2 + control3 + control4) * 10));
	//svec = work1 + work2 + work3 + work4;

	local float dang;
	local vector final_vec = v_forward + (work1 + work2 - work3 - work4) * throttle;
	local vector final_angs = vectoangles(final_vec);

	dang = final_angs.x - truck.angles.x;
	if (dang > 180) dang = -360 + dang;
	else if (dang < -180) dang = 360 + dang;
	avec.x = ((dang) * 1);

	dang = (final_angs.y - truck.angles.y);
	if (dang > 180) dang = -360 + dang;
	else if (dang < -180) dang = 360 + dang;
	avec.y = ((dang) * 1);
	local float final_yaw = vectoyaw(final_vec);

	final_vec = v_right + (-work1 - work3 + work2 + work4) * throttle;
	final_angs = vectoangles(final_vec);

	dang = (final_angs.x - truck.angles.z);
	if (dang > 180) dang = -360 + dang;
	else if (dang < -180) dang = 360 + dang;
	avec.z = ((dang) * 1);

	local float start_yaw = vectoyaw(truck.angles);
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
	//dprint(ftos(start_yaw);
	//dprint(" start yaw\n");
	dprint(vtos(truck.angles));
	dprint(" start angles\n");
	//dprint(vtos(avec));
	//dprint(" avec\n");

	//=================================================================
	//vehicle velocity, avelocity
	//=================================================================

	//suspension, move chassis

	//truck.avelocity.y = avec.y * 1; //only yaw for now
	//truck.avelocity.x = avec.x * 1; //pitch
	truck.avelocity = avec;
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

	local float direction;
	dang = steer_yaw - start_yaw;
	if (dang > 15)
		direction = 1; //right
	else if (dang < -15)
		direction = -1; //left
	//else 0;
	return direction;
};

vector () truck_pilot =
{
	local entity truck = self;
	self = other;

	self.modelindex = 0;
	self.weaponmodel = string_null;
	self.movetype = MOVETYPE_FLY;

	local vector dir = aim(world, 1000);
	local vector target = truck.origin - dir * 200;
	target.z = target.z + 60;
	local vector delta = target - self.origin;
	delta = delta * 10;
	self.velocity = (self.velocity * 2 + delta) * 0.5;

	if (self.impulse == 16) {
		self.impulse = 0;
		setmodel(self, self.model);
		self.movetype = MOVETYPE_WALK;
		setorigin(self, truck.origin);
		self.velocity = truck.velocity;
		self.flags = self.flags - FL_VEHICLE;
		sprint(self, "Truck dismounted\n");
		truck.driver = world;
	}
	
	self = truck;
	return (dir);
}

void() truck_drive = [ $forward1, truck_drive ]
{
	local float dist = 0;
	if (self.driver) {
		other = self.driver;
		if (other.button2)
			dist = 4;
		//chassis physics / prethink
		local vector dir = truck_pilot();
	}
	local float direction = truck_physics(dist, dir);

	if (self.walkframe > 1)
		self.walkframe = 0;
	if !(direction)
		self.frame = $forward1 + self.walkframe;
	else if (direction == 1)
		self.frame = $right1 + self.walkframe;
	else 
		self.frame = $left1 + self.walkframe;
	if (dist)
		self.walkframe = self.walkframe + 1;
	
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
		other.flags = other.flags + FL_VEHICLE;
		self.nextthink = time + 0.1;
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
	self.think = truck_drive;
	//self.nextthink = time + 0.1;
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