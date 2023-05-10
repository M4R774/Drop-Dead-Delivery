extends RayCast3D


func get_colliding_bodies():
	var bodies = []
	if self.is_colliding() and self.get_collider().is_in_group("enemy"):
		if bodies.size() == 0 or !bodies.has(self.get_collider()):
			bodies.append(self.get_collider())
	if $RayCast2.is_colliding() and $RayCast2.get_collider().is_in_group("enemy"):
		if bodies.size()  == 0 or !bodies.has($RayCast2.get_collider()):
			bodies.append($RayCast2.get_collider())
	if $RayCast3.is_colliding() and $RayCast3.get_collider().is_in_group("enemy"):
		if bodies.size()  == 0 or !bodies.has($RayCast3.get_collider()):
			bodies.append($RayCast3.get_collider())
	return(bodies)
