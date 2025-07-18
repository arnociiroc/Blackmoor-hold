SUBSYSTEM_DEF(fire_burning)
	name = "Fire Burning"
	priority = FIRE_PRIORITY_BURNING
	flags = SS_NO_INIT|SS_BACKGROUND
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME

	var/list/currentrun = list()
	var/list/processing = list()

/datum/controller/subsystem/fire_burning/stat_entry()
	..("P:[processing.len]")

/obj
	var/fire_burn_start //make us not burn that long

/datum/controller/subsystem/fire_burning/fire(resumed = 0)
	if (!resumed)
		src.currentrun = processing.Copy()

	//cache for sanic speed (lists are references anyways)
	var/list/currentrun = src.currentrun

	while(currentrun.len)
		var/obj/O = currentrun[currentrun.len]
		currentrun.len--
		if (!O || QDELETED(O))
			processing -= O
			if (MC_TICK_CHECK)
				return
			continue

		if(O.resistance_flags & ON_FIRE) //in case an object is extinguished while still in currentrun
			if(!(O.resistance_flags & FIRE_PROOF))
				O.take_damage(1, BURN, "fire", 0)
			else
				O.extinguish()
			if(!O.fire_burn_start)
				O.fire_burn_start = world.time
			if(world.time > O.fire_burn_start + 30 SECONDS)
				O.extinguish()
		else
			O.extinguish()

		if (MC_TICK_CHECK)
			return

