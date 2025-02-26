/*
============================================================

Vehicle_Truck

============================================================
*/

//calculate vehicle_truck velocity and avelocity from wheels post engine physics
void() truck_physics =
{
	local vector vec1, vec2, vec3, vec4;
	local entity truck = self;

	//get input vectors
	local vector dir = aim(self.owner.driver, 1000);
	local float steer_yaw = vectoyaw(dir);
	//clamp steer yaw to +- 85 degrees from current yaw
	local float dist = 10; //temp

	//truck vectors - velocity from wheels vs gravity, est grip
	local vector svec = truck.velocity;
	local vector avec = truck.avelocity;
	
	//front wheels
	self = truck.wheel1;
	subwalkmove(steer_yaw, dist);
	vec1 = self.view_ofs - (self.owner.origin - self.origin);
	vec1 = 10 * vec1;
	vec1.z = .6 * vec1.z;

	self = truck.wheel2;
	subwalkmove(steer_yaw, dist);
	vec2 = self.view_ofs - (self.owner.origin - self.origin);
	vec2 = 10 * vec2;
	vec2.z = .6 * vec2.z;

	//truck yaw
	local vector axel = truck.wheel1.origin - truck.wheel2.origin;
	local float axel_yaw = vectoyaw(axel) + 90;
	local float truck_yaw = vectoyaw(truck.angles);
	local vector pivot = (truck.wheel1.origin + truck.wheel2.origin) * 0.5;
	pivot = pivot - truck.origin; //delta
	local float truck_dist = vlen(pivot);
	avec.z = (axel_yaw - truck_yaw) * 10; //ideal

	//rear wheels
	self = truck.wheel3;
	cpywalk();
	vec3 = self.view_ofs - (self.owner.origin - self.origin);
	vec3 = 10 * vec3;
	vec3.z = .6 * vec3.z;

	self = truck.wheel4;
	cpywalk();
	vec4 = self.view_ofs - (self.owner.origin - self.origin);
	vec4 = 10 * vec4;
	vec4.z = .6 * vec4.z;

	//lift
	svec.z = svec.z + vec1.z + vec2.z + vec3.z + vec4.z;

	//roll from lift
	local float mx1 = vec1.z * truck.wheel1.view_ofs.y;
	local float mx2 = vec2.z * truck.wheel2.view_ofs.y;
	local float mx3 = vec3.z * truck.wheel3.view_ofs.y;
	local float mx4 = vec4.z * truck.wheel4.view_ofs.y;
	avec.x = avec.x + mx1 + mx2 + mx3 + mx4;

	//pitch from lift
	local float my1 = vec1.z * truck.wheel1.view_ofs.x;
	local float my2 = vec2.z * truck.wheel2.view_ofs.x;
	local float my3 = vec3.z * truck.wheel3.view_ofs.x;
	local float my4 = vec4.z * truck.wheel4.view_ofs.x;
	avec.y = avec.y + my1 + my2 + my3 + my4;

	//slide


	//animate
	self = truck;
};

void() move_truck =
{
	//movestep
	local float dist;

	//chassis physics
	truck_physics();

	//child physics
	cpyall(self.driver, dist);
	cpyall(self.passenger, dist);
	cpyall(self.turret, dist);
};

//decorative item
void() vehicle_truck =
{

};

//physics wheels
void(float i) spawn_truck_wheel =
{
	local entity truck = self;
	self = entity wheel = spawn();
	self.movetype = movetype_step;
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

	self.think = wheel_think;

	self = truck;
}

void() spawn_vehicle_truck =
{
	//body with wheels model
	self.solid = SOLID_SLIDEBOX;
	self.movetype = MOVETYPE_STEP;

	//wheels -- not the visible model
	local float i = 0;
	while (i < 4) i++;
	{
		spawn_truck_wheel(i);
	}

};

void() func_spawn_truck_use =
{
	self = entity truck = spawn();
	spawn_vehicle_truck();
};

void() func_spawn_truck =
{
	if (SUB_Inhibit())
		return;

	self.use = self.think = func_spawn_truck_use;
	func_spawn_start();
};