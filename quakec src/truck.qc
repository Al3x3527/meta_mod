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
void() truck_physics =
{
	local vector vec1, vec2, vec3, vec4;
	local entity truck = self;

	//=================================================================
	//steer and throttle inputs 
	//=================================================================

	//get input vectors
	local float dist = 10; //temp
	local vector dir = aim(self.owner.driver, 1000);
	dir.z = 0; // steer in xy plane
	dir = normalize(dir);

	//truck vectors - velocity from wheels vs gravity, est grip
	local vector svec = truck.velocity;
	local vector avec = truck.avelocity;
	local vector fakevelocity = dist * 10 * dir;
	//clamp steer yaw to +- 85 degrees from current yaw
	local float fakedist = vlen(fakevelocity - svec);\
	makevectors(truck.angles); //starting angles
	if ((dir * v_forward) < 0)
		dir = v_right;
	local float steer_yaw = vectoyaw(dir);

	//=================================================================
	//front wheels work against momentum
	//=================================================================
	   
	//ideal work against momentum
	//front wheels
	self = truck.wheel1; //virtual
	local vector view = self.view_ofs;
	view = v_forward * view.y + v_right * view.x + v_up * view.z + truck.origin; //start from the resting position
	setorigin (self, view); 
	subwalkmove(steer_yaw, fakedist); //movetype_step physics
	vec1 = self.view_ofs - (self.owner.origin - self.origin); //ideal distance traveled after walk physics
	vec1 = 10 * vec1; //as velocity
	vec1.z = .6 * vec1.z; //damped spring ratio

	self = truck.wheel2;
	view = self.view_ofs;
	view = v_forward * view.y + v_right * view.x + v_up * view.z + truck.origin;
	setorigin(self, view);
	subwalkmove(steer_yaw, fakedist);
	vec2 = self.view_ofs - (self.owner.origin - self.origin);
	vec2 = 10 * vec2;
	vec2.z = .6 * vec2.z;

	
	//=================================================================
	//change in rear wheels velocity
	//=================================================================

	//truck yaw (ideal)
	local vector axel = truck.wheel1.origin - truck.wheel2.origin; //lateral vec
	local float axel_yaw = vectoyaw(axel) + 90;
	local float truck_yaw = vectoyaw(truck.angles); //original truck yaw

	local vector pivot = (truck.wheel1.origin + truck.wheel2.origin) * 0.5;
	pivot = pivot - truck.origin + (v_forward * view.y); //delta (forward vec)
	local float chassis_yaw = vectoyaw(pivot); //new truck yaw

	local float truck_dist = vlen(pivot);
	avec.z = (axel_yaw - truck_yaw) * 10; //ideal
	vector lateral = avec.z * truck_dist * normalize(axel);

	//rear wheels
	self = truck.wheel3;
	view = self.view_ofs;
	view = v_forward * view.y + v_right * view.x + v_up * view.z + truck.origin;
	setorigin(self, view);
	subwalkmove(chassis_yaw, truck_dist);
	vec3 = self.origin - view; //movestep delta
	vec3 = 10 * vec3;
	vec3.z = .6 * vec3.z;

	self = truck.wheel4;
	view = self.view_ofs;
	view = v_forward * view.y + v_right * view.x + v_up * view.z + truck.origin;
	setorigin(self, view);
	subwalkmove(chassis_yaw, truck_dist);
	vec4 = self.origin - view;
	vec4 = 10 * vec4;
	vec4.z = .6 * vec4.z;

	//=================================================================
	//vehicle forces, moments
	//=================================================================
	//all fake wheels are in ideal locations and ideal velocities have been calculated for each wheel

	local vector newangles = normalize(pivot);

	//lift
	svec.z = svec.z + vec1.z + vec2.z + vec3.z + vec4.z;

	//roll from z --double check directions
	local float mx1 = vec1.z * truck.wheel1.view_ofs.y;
	local float mx2 = vec2.z * truck.wheel2.view_ofs.y;
	local float mx3 = vec3.z * truck.wheel3.view_ofs.y;
	local float mx4 = vec4.z * truck.wheel4.view_ofs.y;
	avec.x = avec.x + mx1 + mx2 + mx3 + mx4;
	//roll from y
	mx1 = vec1.y * truck.wheel1.view_ofs.z;
	mx2 = vec2.y * truck.wheel2.view_ofs.z;
	mx3 = vec3.y * truck.wheel3.view_ofs.z;
	mx4 = vec4.y * truck.wheel4.view_ofs.z;
	avec.x = avec.x + mx1 + mx2 + mx3 + mx4;

	//pitch from z
	local float my1 = vec1.z * truck.wheel1.view_ofs.x;
	local float my2 = vec2.z * truck.wheel2.view_ofs.x;
	local float my3 = vec3.z * truck.wheel3.view_ofs.x;
	local float my4 = vec4.z * truck.wheel4.view_ofs.x;
	avec.y = avec.y + my1 + my2 + my3 + my4;
	//pitch from x
	my1 = vec1.x * truck.wheel1.view_ofs.z;
	my2 = vec2.x * truck.wheel2.view_ofs.z;
	my3 = vec3.x * truck.wheel3.view_ofs.z;
	my4 = vec4.x * truck.wheel4.view_ofs.z;
	avec.y = avec.y + my1 + my2 + my3 + my4;

	//grip
	local vector grip1, grip2, grip3, grip4;
	if !(truck.wheel1.flags & FL_ONGROUND)
		grip1 = '0 0 0';
	else grip1 = -vec1.z * dir; //mu*m*svec1.z^2
	if !(truck.wheel2.flags & FL_ONGROUND)
		grip2 = '0 0 0';
	else grip2 = -vec2.z * dir;
	if !(truck.wheel3.flags & FL_ONGROUND)
		grip3 = '0 0 0';
	else grip3 = -vec3.z * newangles;
	if !(truck.wheel4.flags & FL_ONGROUND)
		grip4 = '0 0 0';
	else grip4 = -vec4.z * newangles;

	//work -- vector from momentum to ideal
	//only front wheels do work in ideal direction
	local vector work1 = vec1 - svec;
	work1.z = 0; //exclude vertical travel
	if (vlen(grip1) < vlen(work1))
		work1 = grip1; //limit work to grip

	local vector work2 = vec2 - svec;
	work2.z = 0;
	if (vlen(grip2) < vlen(work2))
		work2 = grip2;

	local vector work3 = grip3;

	local vector work4 = grip4;

	//actual travel
	local vector xvec = svec;
	xvec.z = 0;
	svec = svec + work1 + work2 + work3 + work4;

	//=================================================================
	//vehicle velocity, avelocity
	//=================================================================

	//suspension, move chassis
	truck.avelocity = avec; //from equalibrium
	truck.velocity = svec;

	//passengers after return
	self = truck;
};

void() move_truck =
{
	//movestep
	local float dist;

	//chassis physics / prethink
	truck_physics();

	//child physics
	cpyall(self.driver, dist);
	cpyall(self.passenger, dist);
	cpyall(self.turret, dist);

	//animate
};

//decorative item
void() vehicle_truck =
{
	precache_model("progs/e_mdls/e_truck.mdl");
	if (SUB_Inhibit())
		return;
	spawn_vehicle_truck();
};

//physics wheels
void(float i) spawn_truck_wheel =
{
	local entity truck = self;
	
	local entity wheel = spawn();
	self = wheel;
	self.movetype = MOVETYPE_STEP;
	self.think = cpywalk;
	self.owner = truck;
	if !(i) {
	truck.wheel1 = self;
	self.origin = truck.origin + '70 30 7'; //placeholder
	}
	else if (i == 1) {
	truck.wheel2 = self;
	self.origin = truck.origin + '70 -30 7';
	}
	else if (i == 2) {
	truck.wheel3 = self;
	self.origin = truck.origin + '-70 30 7';
	}
	else if (i == 3) {
	truck.wheel4 = self;
	self.origin = truck.origin + '-70 -30 7';
	}
	else dprint("too many wheels spawned!\n");

	self = truck;
}

void() spawn_vehicle_truck =
{
	//body with wheels model
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_BOUNCE;
	body_model("progs/e_mdls/e_truck.mdl");
	setsize(self, '-112 -40 0', '112 40 80');

	//wheels -- not the visible model
	local float i = 0;
	while (i < 4) i++;
	{
		spawn_truck_wheel(i);
	}

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