/obj/machinery/computer/overwatch
	name = "Overwatch Console"
	desc = "State of the art machinery for giving orders to a squad."
	icon_state = "dummy"
	req_access = list(ACCESS_MARINE_BRIDGE)

	var/datum/squad/current_squad = null
	var/state = 0
	var/mob/living/carbon/human/info_from = null
	var/obj/machinery/camera/cam = null
	var/list/network = list("LEADER")
	var/x_offset_s = 0
	var/y_offset_s = 0
	var/x_offset_b = 0
	var/y_offset_b = 0
//	var/console_locked = 0


/obj/machinery/computer/overwatch/attackby(var/obj/I as obj, var/mob/user as mob)  //Can't break or disassemble.
	return

/obj/machinery/computer/overwatch/bullet_act(var/obj/item/projectile/Proj) //Can't shoot it
	return 0

/obj/machinery/computer/overwatch/attack_ai(var/mob/user as mob)
	return src.attack_hand(user)


/obj/machinery/computer/overwatch/attack_paw(var/mob/user as mob) //why monkey why
	return src.attack_hand(user)

/obj/machinery/computer/overwatch/attack_hand(mob/user)
	if(..())  //Checks for power outages
		return

	if(user.mind.skills_list && user.mind.skills_list["leadership"] < SKILL_LEAD_EXPERT)
		user << "<span class='warning'>You don't have the training to use [src].</span>"
		return


	user.set_interaction(src)
	var/dat = "<head><title>Overwatch Console</title></head><body>"

	if(!operator)
		dat += "<BR><B>Operator:</b> <A href='?src=\ref[src];operation=change_operator'>----------</A><BR>"
	else
		dat += "<BR><B>Operator:</b> <A href='?src=\ref[src];operation=change_operator'>[operator.name]</A><BR>"
		dat += "   <A href='?src=\ref[src];operation=logout'>{Stop Overwatch}</A><BR>"
		dat += "----------------------<br>"

		switch(src.state)
			if(0)
				if(!current_squad) //No squad has been set yet. Pick one.
					dat += "Current Squad: <A href='?src=\ref[src];operation=pick_squad'>----------</A><BR>"
				else
					dat += "Current Squad: [current_squad.name] Squad</A>   "
					dat += "<A href='?src=\ref[src];operation=message'>\[Message Squad\]</a><br><br>"
					dat += "----------------------<BR><BR>"
					if(current_squad.squad_leader && istype(current_squad.squad_leader))
						dat += "<B>Squad Leader:</B> <A href='?src=\ref[src];operation=get_info;info_from=\ref[current_squad.squad_leader]'>[current_squad.squad_leader.name]</a> "
						dat += "<A href='?src=\ref[src];operation=use_cam;cam_target=\ref[current_squad.squad_leader]'>\[CAM\]</a> "
						dat += "<A href='?src=\ref[src];operation=sl_message'>\[MSG\]</a> "
						dat += "<A href='?src=\ref[src];operation=change_lead'>\[CHANGE\]</a><BR><BR>"
					else
						dat += "<B>Squad Leader:</B> <font color=red>NONE</font><br> <A href='?src=\ref[src];operation=change_lead'>\[SCAN\]</a><BR>"
					dat += "<B>Primary Objective:</B> "
					if(current_squad.primary_objective)
						dat += "<A href='?src=\ref[src];operation=check_primary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_primary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_primary'>\[Set\]</A><BR>"
					dat += "<B>Secondary Objective:</B> "
					if(current_squad.secondary_objective)
						dat += "<A href='?src=\ref[src];operation=check_secondary'>\[Check\]</A> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					else
						dat += "<B><font color=red>NONE!</font></B> <A href='?src=\ref[src];operation=set_secondary'>\[Set\]</A><BR>"
					dat += "<BR>"
					dat += "<A href='?src=\ref[src];operation=supplies'>Supply Drop Control</a><BR>"
					dat += "<A href='?src=\ref[src];operation=bombs'>Orbital Bombardment Control</a><BR>"
					dat += "<A href='?src=\ref[src];operation=monitor'>Squad Monitor</a><BR>"
					dat += "<BR><BR>----------------------<BR></Body>"
					dat += "<BR><BR><A href='?src=\ref[src];operation=refresh'>{Refresh}</a></Body>"

			if(1)//Info screen.
				if(!current_squad)
					dat += "No Squad selected!<BR>"
				else

					var/leader_text = ""
					var/leader_count = 0
					var/spec_text = ""
					var/spec_count = 0
					var/medic_text = ""
					var/medic_count = 0
					var/engi_text = ""
					var/engi_count = 0
					var/smart_text = ""
					var/smart_count = 0
					var/marine_text = ""
					var/marine_count = 0
					var/misc_text = ""

					for(var/mob/living/carbon/human/H in mob_list)
						if(!H.mind) continue
						var/datum/squad/H_squad = H.mind.assigned_squad //This should be set always for squaddies.
						if(!H || !H_squad || H_squad != current_squad || H.z == 0) continue
						var/area/A = get_area(H)
						var/mob_state = ""
						var/role = ""
						var/dist = ""

						if(current_squad.squad_leader && H.z == current_squad.squad_leader.z && H.z != 0)
							dist = "[get_dist(H, current_squad.squad_leader)]"
						else
							dist = "<b>???</b>"
						if(H.mind)
							if(H.mind.assigned_role) role = H.mind.assigned_role
						if(H.stat == CONSCIOUS) mob_state = "Conscious"
						if(H.stat == UNCONSCIOUS) mob_state = "<b>Unconscious</b>"
						if(H.stat == DEAD) mob_state = "<font color='red'>DEAD</font>"

						switch(role)
							if("Squad Leader")
								leader_text += "<tr><td>[H.name]</td><td>[role]</td><td>[mob_state]</td><td>[sanitize(A.name)]</td><td><b>N/A</b></td><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>\[CAM\]</a></td></tr>"
								leader_count++
							if("Squad Specialist")
								spec_text += "<tr><td>[H.name]</td><td>[role]</td><td>[mob_state]</td><td>[sanitize(A.name)]</td><td>[dist]</td><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>\[CAM\]</a></td></tr>"
								spec_count++
							if("Squad Medic")
								medic_text += "<tr><td>[H.name]</td><td>[role]</td><td>[mob_state]</td><td>[sanitize(A.name)]</td><td>[dist]</td><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>\[CAM\]</a></td></tr>"
								medic_count++
							if("Squad Engineer")
								engi_text += "<tr><td>[H.name]</td><td>[role]</td><td>[mob_state]</td><td>[sanitize(A.name)]</td><td>[dist]</td><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>\[CAM\]</a></td></tr>"
								engi_count++
							if("Squad Smartgunner")
								smart_text += "<tr><td>[H.name]</td><td>[role]</td><td>[mob_state]</td><td>[sanitize(A.name)]</td><td>[dist]</td><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>\[CAM\]</a></td></tr>"
								smart_count++
							if("Squad Marine")
								marine_text += "<tr><td>[H.name]</td><td>[role]</td><td>[mob_state]</td><td>[sanitize(A.name)]</td><td>[dist]</td><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>\[CAM\]</a></td></tr>"
								marine_count++
							else
								misc_text += "<tr><td>[H.name]</td><td><i>[role]</i></td><td>[mob_state]</td><td>[sanitize(A.name)]</td><td>[dist]</td><td><A href='?src=\ref[src];operation=use_cam;cam_target=\ref[H]'>\[CAM\]</a></td></tr></tr>"

					dat += "<b>[leader_count ? "Squad Leader Deployed":"<font color='red'>No Squad Leader Deployed!</font>"]</b><BR>"
					dat += "<b>[spec_count ? "Squad Specialist Deployed":"<font color='red'>No Specialist Deployed!</font>"]</b><BR>"
					dat += "<b>[smart_count ? "Squad Smartgunner Deployed":"<font color='red'>No Smartgunner Deployed!</font>"]</b><BR>"
					dat += "<b>Squad Medics: [medic_count] Deployed | Squad Engineers: [engi_count] Deployed</b><BR>"
					dat += "<b>Squad Marines: [marine_count] Deployed</b><BR><BR>"
					dat += "<table border='1' style='width:100%' align='center'><tr>"
					dat += "<th>Name</th><th>Role</th><th>State</th><th>Location</th><th>SL Distance</th><th>Camera</th></tr>"
					dat += leader_text + spec_text + medic_text + engi_text + smart_text + marine_text + misc_text
					dat += "</table>"
				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=back'>{Back}</a></body>"
			if(2)
				dat += "<BR><B>Supply Drop Control</B><BR><BR>"
				if(!current_squad)
					dat += "No squad selected!"
				else
					dat += "<B>Current Supply Drop Status:</B> "
					if(current_squad.supply_timer)
						dat += "Launch tubes resetting<br>"
					else
						dat += "<font color='green'>Ready!</font><br>"
					dat += "<B>Launch Pad Status:</b> "
					var/obj/structure/closet/crate/C = locate() in current_squad.drop_pad.loc
					if(C)
						dat += "<font color='green'>Supply crate loaded</font><BR>"
					else
						dat += "Empty<BR>"
					dat += "<B>Supply Beacon Status:</b> "
					if(current_squad.sbeacon)
						if(istype(current_squad.sbeacon.loc,/turf))
							dat += "<font color='green'>Transmitting!</font><BR>"
						else
							dat += "Not Transmitting<BR>"
					else
						dat += "Not Transmitting<BR>"
					dat += "<B>X-Coordinate Offset:</B> [x_offset_s] <A href='?src=\ref[src];operation=supply_x'>\[Change\]</a><BR>"
					dat += "<B>Y-Coordinate Offset:</B> [y_offset_s] <A href='?src=\ref[src];operation=supply_y'>\[Change\]</a><BR><BR>"
					dat += "<A href='?src=\ref[src];operation=dropsupply'>\[LAUNCH!\]</a>"
				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=back'>{Back}</a></body>"
			if(3)
				dat += "<BR><B>Orbital Bombardment Control</B><BR><BR>"
				if(!current_squad)
					dat += "No squad selected!"
				else
					dat += "<B>Current Cannon Status:</B> "
					if(current_squad.bomb_timer)
						dat += "Shells Reloading<br>"
					else
						dat += "<font color='green'>Ready!</font><br>"
					dat += "<B>Beacon Status:</b> "
					if(current_squad.bbeacon)
						if(istype(current_squad.bbeacon.loc,/turf))
							dat += "<font color='green'>Transmitting!</font><BR>"
						else
							dat += "Not Transmitting<BR>"
					else
						dat += "Not Transmitting<BR>"
					dat += "<B>X-Coordinate Offset:</B> [x_offset_b] <A href='?src=\ref[src];operation=bomb_x'>\[Change\]</a><BR>"
					dat += "<B>Y-Coordinate Offset:</B> [y_offset_b] <A href='?src=\ref[src];operation=bomb_y'>\[Change\]</a><BR><BR>"
					dat += "<A href='?src=\ref[src];operation=dropbomb'>\[FIRE!\]</a>"
				dat += "<BR><BR>----------------------<br>"
				dat += "<A href='?src=\ref[src];operation=refresh'>{Refresh}</a><br>"
				dat += "<A href='?src=\ref[src];operation=back'>{Back}</a></body>"

	user << browse(dat, "window=overwatch;size=500x500")
	onclose(user, "overwatch")
	return

/obj/machinery/computer/overwatch/Topic(href, href_list)
	if(..())
		return

	if(!href_list["operation"])
		return

	if((usr.contents.Find(src) || (in_range(src, usr) && istype(src.loc, /turf))) || (istype(usr, /mob/living/silicon)))
		usr.set_interaction(src)

	switch(href_list["operation"])
		// main interface
		if("back")
			src.state = 0
		if("monitor")
			src.state = 1
		if("supplies")
			src.state = 2
		if("bombs")
			src.state = 3
		if("change_operator")
			if(current_squad)
				current_squad.overwatch_officer = usr
			operator = usr
			send_to_squad("Attention - your Overwatch officer is now [operator.name].") //This checks for squad, so we don't need to.
		if("logout")
			if(operator)
				send_to_squad("Attention - [operator.name] is no longer your Overwatch officer. Overwatch functions deactivated.")
			if(current_squad)
				current_squad.overwatch_officer = null //Reset the squad's officer.
			operator = null
			current_squad = null
			if(cam)
				usr.reset_view(null)
			cam = null
		if("pick_squad")
			if(operator == usr)
				if(current_squad)
					usr << "<span class='warning'>\icon[src] You are already selecting a squad.</span>"
				else
					var/list/squad_list = list()
					var/datum/squad/selected = null
					var/name_sel = "Cancel" //default
					for(var/datum/squad/S in RoleAuthority.squads)
						if(S.usable && !S.overwatch_officer)
							squad_list += S.name

					squad_list += "Cancel"
					name_sel = input("Which squad would you like to claim for Overwatch?") as null|anything in squad_list
					if(name_sel != "Cancel" && !isnull(name_sel))
						if(current_squad)
							usr << "<span class='warning'>\icon[src] You are already selecting a squad..</span>"
							return
						selected = get_squad_by_name(name_sel)
						if(selected)
							selected.overwatch_officer = usr //Link everything together, squad, console, and officer
							current_squad = selected
							send_to_squad("Attention - Your squad has been selected for Overwatch. Check your Status pane for objectives.")
							send_to_squad("Your Overwatch officer is: [operator.name].")
							src.attack_hand(usr)
							if(!current_squad.drop_pad) //Why the hell did this not link?
								for(var/obj/item/effect/supply_drop/S in item_list)
									S.force_link() //LINK THEM ALL!

						else
							usr << "<span class='warning'>\icon[src] Invalid input. Aborting.</span>"
		if("message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad:", "Squad Message")
				if(input)
					send_to_squad(input,1) //message, adds username
		if("sl_message")
			if(current_squad && operator == usr)
				var/input = stripped_input(usr, "Please write a message to announce to the squad leader:", "SL Message")
				if(input)
					send_to_squad(input,1,1) //message, adds usrname, only to leader
		if("check_primary")
			if(current_squad) //This is already checked, but ehh.
				if(current_squad.primary_objective)
					usr << "\icon[src] <b>Primary Objective:</b> [current_squad.primary_objective]"
		if("check_secondary")
			if(current_squad) //This is already checked, but ehh.
				if(current_squad.secondary_objective)
					usr << "\icon[src] <b>Secondary Objective:</b> [current_squad.secondary_objective]"
		if("set_primary")
			var/input = stripped_input(usr, "What will be the squad's primary objective?", "Primary Objective")
			if(input)
				current_squad.primary_objective = input
				send_to_squad("Your primary objective has changed. See Status pane for details.")
		if("set_secondary")
			var/input = stripped_input(usr, "What will be the squad's secondary objective?", "Secondary Objective")
			if(input)
				current_squad.secondary_objective = input
				send_to_squad("Your secondary objective has changed. See Status pane for details.")
		if("supply_x")
			var/input = input(usr,"What X-coordinate offset between -5 and 5 would you like? (Positive means east)","X Offset",0) as num
			if(input > 5) input = 5
			if(input < -5) input = -5
			usr << "\icon[src] X-offset is now [input]."
			src.x_offset_s = input
		if("supply_y")
			var/input = input(usr,"What Y-coordinate offset between -5 and 5 would you like? (Positive means north)","Y Offset",0) as num
			if(input > 5) input = 5
			if(input < -5) input = -5
			usr << "\icon[src] Y-offset is now [input]."
			y_offset_s = input
		if("bomb_x")
			var/input = input(usr,"What X-coordinate offset between -5 and 5 would you like? (Positive means east)","X Offset",0) as num
			if(input > 5) input = 5
			if(input < -5) input = -5
			usr << "\icon[src] X-offset is now [input]."
			x_offset_b = input
		if("bomb_y")
			var/input = input(usr,"What X-coordinate offset between -5 and 5 would you like? (Positive means north)","Y Offset",0) as num
			if(input > 5) input = 5
			if(input < -5) input = -5
			usr << "\icon[src] Y-offset is now [input]."
			y_offset_b = input
		if("refresh")
			src.attack_hand(usr)
		if("change_lead")
			change_lead()
		if("dropsupply")
			if(current_squad)
				if(current_squad.supply_timer)
					usr << "\icon[src] Supply drop not yet available!"
				else
					handle_supplydrop()
		if("dropbomb")
			if(current_squad)
				if(current_squad.bomb_timer)
					usr << "\icon[src] Orbital bombardment not yet available!"
				else
					handle_bombard()
		if("back")
			state = 0
		if("use_cam")
			if(current_squad)
				var/mob/cam_target = locate(href_list["cam_target"])
				var/obj/machinery/camera/new_cam = get_camera_from_target(cam_target)
				if(!new_cam || !new_cam.can_use())
					usr << "\icon[src] Searching for helmet cam.."
					usr << "\icon[src] No helmet cam found for this marine! Tell your squad to put their helmets on!"
				else if(cam && cam == new_cam)//click the camera you're watching a second time to stop watching.
					usr << "\icon[src] Stopping helmet cam view."
					cam = null
					usr.reset_view(null)
				else if(usr.client.view != world.view)
					usr << "<span class='warning'>You're too busy peering through binoculars.</span>"
				else
					usr << "\icon[src] Searching for helmet cam.."
					cam = new_cam
					usr << "\icon[src] Helmet cam found and linked."
					usr.reset_view(cam)
//	src.updateUsrDialog()
	src.attack_hand(usr) //The above doesn't ever seem to work.

/obj/machinery/computer/overwatch/check_eye(mob/user)
	if (user.is_mob_incapacitated(TRUE) || get_dist(user, src) > 1 || user.blinded) //user can't see - not sure why canmove is here.
		user.unset_interaction()
	else if (!cam || !cam.can_use()) //camera doesn't work, is no longer selected or is gone
		user.unset_interaction()


/obj/machinery/computer/overwatch/on_unset_interaction(mob/user)
	..()
	cam = null
	user.reset_view(null)

//returns the helmet camera the human is wearing
/obj/machinery/computer/overwatch/proc/get_camera_from_target(mob/living/carbon/human/H)
	if (current_squad)
		if (H && istype(H) && istype(H.head, /obj/item/clothing/head/helmet/marine))
			var/obj/item/clothing/head/helmet/marine/helm = H.head
			return helm.camera


//Sends a string to our currently selected squad.
/obj/machinery/computer/overwatch/proc/send_to_squad(var/txt = "", var/plus_name = 0, var/only_leader = 0)
	if(txt == "" || !current_squad || !operator) return //Logic

	var/text = sanitize(txt)
	var/nametext = ""
	if(plus_name)
		nametext = "[usr.name] transmits: "

	for(var/mob/living/carbon/human/M in living_mob_list)
		if(M && istype(M) && !M.stat && M.client && M.mind && (M.mind.assigned_squad == current_squad || M == usr)) //Only living and connected people in our squad
			if(!only_leader)
				M << "\icon[src] <font color='blue'><B>\[Overwatch\]:</b> [nametext][text]</font>"
			else
				if(is_leader_from_card(M))
					M << "\icon[src] <font color='blue'><B>\[SL Overwatch\]:</b> [nametext][text]</font>"

/obj/machinery/computer/overwatch/proc/handle_bombard()
	if(!usr) return
	if(!current_squad)
		usr << "\icon[src] No squad selected!"
		return
	if(!current_squad.bbeacon)
		usr << "\icon[src] No beacon detected!"
		return
	if(!isturf(current_squad.bbeacon.loc) || current_squad.bbeacon.z != 1)
		usr << "\icon[src] Beacon is not transmitting from the ground."
		return
	var/area/A = get_area(current_squad.bbeacon)
	if(A && istype(A,/area/lv624/ground/caves) || istype(A, /area/ice_colony/underground) || istype(A, /area/bigred/uground/))
		usr << "\icon[src] The beacon's signal is too weak. It is probably inside a cave."
		return

	var/x_offset = x_offset_b
	var/y_offset = y_offset_b
	var/turf/T = get_turf(current_squad.bbeacon)
	x_offset = round(x_offset)
	y_offset = round(y_offset)
	if(x_offset < -5) x_offset = -5 //None of these should be possible, but whatever
	if(x_offset > 5) x_offset = 5
	if(y_offset < -5) y_offset = -5
	if(y_offset > 5) y_offset = 5
	//All set, let's do this.
	send_to_squad("Initializing fire coordinates..")
	if(current_squad.bbeacon)
		playsound(current_squad.bbeacon.loc,'sound/effects/alert.ogg', 25, 1)  //Placeholder
	sleep(20)
	send_to_squad("Transmitting beacon feed..")
	sleep(20)
	send_to_squad("Calibrating trajectory window..")
	sleep(20)
	usr << "\icon[src] \red FIRING!!"
	send_to_squad("WARNING! Ballistic trans-atmospheric launch detected! Get outside of Danger Close!")
	spawn(6)
		if(!current_squad.bbeacon) //May have been destroyed en route
			send_to_squad("Trajectory beacon not found. Aborting launch.")
			return
		if(A)
			message_admins("ALERT: [usr] ([usr.key]) fired an orbital bombardment in [A.name] (<A HREF='?_src_=holder;adminplayerobservecoodjump=1;X=[T.x];Y=[T.y];Z=[T.z]'>JMP</a>)")
		current_squad.handle_btimer(20000)
		if(current_squad.bbeacon)
			cdel(current_squad.bbeacon) //Wipe the beacon. It's only good for one use.
			current_squad.bbeacon = null
		for(var/mob/living/carbon/H in living_mob_list)
			if((H.z == 3 || H.z == 4) && !src.stat) //Sulaco decks.
				H << "<span class='warning'>The deck of the USS Almayer shudders as the orbital cannons open fire on the colony.</span>"
				if(!H.buckled && H.client)
					shake_camera(H, 10, 1)
		x_offset += rand(-2,2) //Little bit of randomness.
		y_offset += rand(-2,2)
		var/turf/target = locate(T.x + x_offset,T.y + y_offset,T.z)
		if(target && istype(target))
			explosion(target,4,5,6,6,1,0) //massive boom
			for(var/turf/TU in range(6,target))
				if(!locate(/obj/flamer_fire) in TU)
					new/obj/flamer_fire(TU, 10, 40) //super hot flames


/obj/machinery/computer/overwatch/proc/change_lead()
	if(!usr || usr != operator)
		return
	if(!current_squad)
		usr << "\icon[src] No squad selected!"
		return
	for(var/mob/living/carbon/human/H in living_mob_list)
		if(is_leader_from_card(H) && get_squad_data_from_card(H) == current_squad && current_squad.squad_leader != H)
			current_squad.squad_leader = H
			usr << "\icon[src] New leader found and linked!"
			send_to_squad("Attention: A new squad leader has been set: [H.real_name].")
			return

	usr << "\icon[src] No new leaders found for this squad. They must have a squad set using the squad consoles."
	return

/obj/machinery/computer/overwatch/proc/handle_supplydrop()
	if(!usr || usr != operator)
		return

	if(!current_squad.sbeacon)
		usr << "\icon[src] No supply beacon detected!"
		return

	var/obj/structure/closet/crate/C = locate() in current_squad.drop_pad.loc //This thing should ALWAYS exist.
	if(!C || !istype(C))
		usr << "\icon[src] No crate was detected on the drop pad. Get Requisitions on the line!"
		return

	if(!isturf(current_squad.sbeacon.loc))
		usr << "\icon[src] The beacon was not detected on the ground."
		return

	var/area/A = get_area(current_squad.bbeacon)
	if(A && istype(A,/area/lv624/ground/caves) || istype(A, /area/ice_colony/underground))
		usr << "\icon[src] The beacon's signal is too weak. It is probably inside a cave."
		return

	var/turf/T = get_turf(current_squad.sbeacon)
	var/x_offset = x_offset_s
	var/y_offset = y_offset_s
	x_offset = round(x_offset)
	y_offset = round(y_offset)
	if(x_offset < -5 || x_offset > 5) x_offset = 0
	if(y_offset < -5 || y_offset > 5) y_offset = 0
	x_offset += rand(-2,2) //Randomize the drop zone a little bit.
	y_offset += rand(-2,2)

	C.visible_message("The [C] begins to load into a launch tube. Stand clear!")
	current_squad.handle_stimer(5000)
	send_to_squad("Supply Drop Incoming!")
	current_squad.sbeacon.visible_message("\blue The beacon begins to beep!")
	spawn(100)
		if(!current_squad) return
		if(current_squad.sbeacon)
			cdel(current_squad.sbeacon) //Wipe the beacon. It's only good for one use.
			current_squad.sbeacon = null
		playsound(C.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehh
		C.z = T.z
		C.x = T.x + x_offset
		C.y = T.y + x_offset
		spawn(0)
			playsound(C.loc,'sound/effects/bamf.ogg', 50, 1)  //Ehhhhhhhhh.
		C.visible_message("\icon[C] The [C] falls from the sky!")
		usr << "\icon[src] [C] launched! Another launch will be available in <b>5</b> minutes."



/obj/machinery/computer/overwatch/almayer
	density = 0
	icon = 'icons/obj/almayer.dmi'
	icon_state = "overwatch"




/obj/item/effect/supply_drop
	name = "Supply Drop Pad"
	desc = "Place a crate on here to allow bridge Overwatch officers to drop them on people's heads."
	icon = 'icons/effects/warning_stripes.dmi'
	anchored = 1
	density = 0
	unacidable = 1
	var/squad = "Alpha"
	var/sending_package = 0

	New() //Link a squad to a drop pad
		..()
		spawn(10)
			force_link()

	proc/force_link() //Somehow, it didn't get set properly on the new proc. Force it again,
		var/datum/squad/S = get_squad_by_name(squad)
		if(S)
			S.drop_pad = src
		else
			world << "Alert! Supply drop pads did not initialize properly."

/obj/item/effect/supply_drop/alpha
	icon_state = "alphadrop"
	squad = "Alpha"

/obj/item/effect/supply_drop/bravo
	icon_state = "bravodrop"
	squad = "Bravo"

/obj/item/effect/supply_drop/charlie
	icon_state = "charliedrop"
	squad = "Charlie"

/obj/item/effect/supply_drop/delta
	icon_state = "deltadrop"
	squad = "Delta"

/obj/item/device/squad_beacon
	name = "squad supply beacon"
	desc = "A rugged, glorified laser pointer capable of sending a beam into space. Activate and throw this to call for a supply drop."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion0"
	unacidable = 1
	w_class = 2
	var/activated = 0
	var/activation_time = 60
	var/datum/squad/squad = null
	var/icon_activated = "motion2"

/obj/item/device/squad_beacon/attack_self(mob/user)
	if(activated)
		user << "<span class='warning'>It's already been activated. Just leave it.</span>"
		return

	if(!ishuman(user)) return

	if(!user.mind)
		user << "<span class='warning'>It doesn't seem to do anything for you.</span>"
		return

	if(user.mind.assigned_squad)
		squad = user.mind.assigned_squad
	else
		squad = get_squad_data_from_card(user)

	if(!squad)
		user << "<span class='warning'>You need to be in a squad for this to do anything.</span>"
		return
	if(squad.sbeacon)
		user << "<span class='warning'>Your squad already has a beacon activated.</span>"
		return
	var/area/A = get_area(user)
	var/turf/TU = get_turf(user)
	var/turf/unsimulated/floor/F = TU
	if(!istype(A, /area/prison) && (!istype(F) || !F.is_groundmap_turf))
		user << "<span class='warning'>You have to be outside to activate this.</span>"
		return

	if(A && istype(A) && A.is_underground)
		user << "<span class='warning'>This won't work if you're standing underground.</span>"
		return

	var/delay = activation_time
	if(user.mind.skills_list)
		delay = max(10, delay - 20*user.mind.skills_list["leadership"])

	user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(do_after(user, delay, TRUE, 5, BUSY_ICON_CLOCK))

		squad.sbeacon = src
		forceMove(user.loc)
		activated = 1
		anchored = 1
		w_class = 10
		icon_state = "[icon_activated]"
		playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
		user.visible_message("[user] activates [src]",
		"You activate [src]")

/obj/item/device/squad_beacon/bomb
	name = "orbital beacon"
	desc = "A bulky device that fires a beam up to an orbiting vessel to send local coordinates."
	icon = 'icons/obj/device.dmi'
	icon_state = "motion4"
	w_class = 2
	activation_time = 80
	icon_activated = "motion1"

/obj/item/device/squad_beacon/bomb/attack_self(mob/user)
	if(activated)
		user << "<span class='warning'>It's already been activated. Just leave it.</span>"
		return
	if(!ishuman(user)) return
	if(!user.mind)
		user << "<span class='warning'>It doesn't seem to do anything for you.</span>"
		return

	if(user.mind.assigned_squad)
		squad = user.mind.assigned_squad
	else
		squad = get_squad_data_from_card(user)

	if(!squad)
		user << "<span class='warning'>You need to be in a squad for this to do anything.</span>"
		return
	if(squad.bbeacon)
		user << "<span class='warning'>Your squad already has a beacon activated.</span>"
		return

	if(user.z != 1)
		user << "<span class='warning'>You have to be on the planet to use this or it won't transmit.</span>"
		return

	var/area/A = get_area(user)
	if(A && istype(A) && A.is_underground)
		user << "<span class='warning'>This won't work if you're standing underground.</span>"

	var/delay = activation_time
	if(user.mind.skills_list)
		delay = max(15, delay - 20*user.mind.skills_list["leadership"])

	user.visible_message("<span class='notice'>[user] starts setting up [src] on the ground.</span>",
	"<span class='notice'>You start setting up [src] on the ground and inputting all the data it needs.</span>")
	if(do_after(user, delay, TRUE, 5, BUSY_ICON_CLOCK))

		message_admins("[user] ([user.key]) set up an orbital strike beacon.")
		squad.bbeacon = src //Set us up the bomb~
		forceMove(user.loc)
		activated = 1
		anchored = 1
		w_class = 10
		icon_state = "[icon_activated]"
		playsound(src, 'sound/machines/twobeep.ogg', 15, 1)
		user.visible_message("[user] activates [src]",
		"You activate [src]")

//This is perhaps one of the weirdest places imaginable to put it, but it's a leadership skill, so

/mob/living/carbon/human/verb/issue_order()

	set name = "Issue Order"
	set desc = "Issue an order to nearby humans, using your authority to strengthen their resolve."
	set category = "IC"

	if(!mind.skills_list || (mind.skills_list && mind.skills_list["leadership"] < SKILL_LEAD_TRAINED))
		src << "<span class='warning'>You are not competent enough in leadership to issue an order.</span>"
		return

	if(stat)
		src << "<span class='warning'>You cannot give an order in your current state.</span>"
		return

	if(command_aura_cooldown > 0)
		src << "<span class='warning'>You have recently given an order. Calm down.</span>"
		return

	var/choice = input(src, "Choose an order") in command_aura_allowed + "help" + "cancel"
	if(choice == "help")
		src << "<span class='notice'><br>Orders give a buff to nearby soldiers for a short period of time, followed by a cooldown, as follows:<br><B>Move</B> - Increased mobility and chance to dodge projectiles.<br><B>Hold</B> - Increased resistance to pain and combat wounds.<br><B>Focus</B> - Increased gun accuracy and effective range.<br></span>"
		return
	if(choice == "cancel") return
	command_aura = choice
	command_aura_cooldown = 45 //45 ticks
	command_aura_tick = 10 //10 ticks
	var/message = ""
	switch(command_aura)
		if("move")
			message = pick(";GET MOVING!", ";GO, GO, GO!", ";WE ARE ON THE MOVE!", ";MOVE IT!", ";DOUBLE TIME!")
			say(message)
		if("hold")
			message = pick(";DUCK AND COVER!", ";HOLD THE LINE!", ";HOLD POSITION!", ";STAND YOUR GROUND!", ";STAND AND FIGHT!")
			say(message)
		if("focus")
			message = pick(";FOCUS FIRE!", ";PICK YOUR TARGETS!", ";CENTER MASS!", ";CONTROLLED BURSTS!", ";AIM YOUR SHOTS!")
			say(message)
