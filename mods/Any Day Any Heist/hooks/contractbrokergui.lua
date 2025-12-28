Hooks:PreHook(ContractBrokerGui, "setup", "pre_hook_setup_tabs", function(self)
	if Global.random_jobs.filter_added == false then
		table.insert(ContractBrokerGui.tabs, { "menu_filter_random", "_setup_filter_random" })
		Global.random_jobs.filter_added = true
	end
end)

Hooks:PostHook(ContractBrokerGui, "_create_job_data", "post_hook_create_job_data", function(self)
	local random_contacts = {
		randoms = 1,
		random_pros = 1,
		random_stealth = 1,
		random_stealth_pros = 1,
		dayselect = 1,
		escapes = 1
	}

	local jobs = self._job_data
	local contacts = self._contact_data
	
	local job_tweak, dlc, date_value, contact, contact_tweak = nil
	
	for index, job_id in ipairs(tweak_data.narrative:get_jobs_index()) do
		job_tweak = tweak_data.narrative:job_data(job_id)
		contact = job_tweak.contact
		contact_tweak = tweak_data.narrative.contacts[contact]
		
		if random_contacts[contact] == 1 then
			dlc = not job_tweak.dlc or managers.dlc:is_dlc_unlocked(job_tweak.dlc)
			dlc = dlc and not tweak_data.narrative:is_job_locked(job_id)
		
			table.insert(jobs, {
				job_id = job_id,
				job_tweak = job_tweak,
				contact = contact,
				contact_tweak = contact_tweak,
				enabled = dlc,
				date_value = false,
				is_new = false
			})

			contacts[contact] = contacts[contact] or {}
			
			--table.insert(contacts[contact], jobs[#jobs]) not sure if this is needed???
		end
	end
end)

function ContractBrokerGui:_setup_filter_random()
	local randoms = {
		{
			"menu_filter_random_regular"
		},
		{
			"menu_filter_random_pro"
		},
		{
			"menu_filter_random_stealth"
		},
		{
			"menu_filter_random_stealth_pro"
		},
		{
			"menu_filter_dayselect"
		},
		{
			"menu_filter_escape"
		}
	}
	local last_y = 0
	local check_new_job_data = {
		filter_key = "contact",
		filter_func = ContractBrokerGui.perform_filter_random
	}

	for _, filter in ipairs(randoms) do
		local text = self:_add_filter_button(filter[1], last_y, {
			check_new_job_data = check_new_job_data,
			text_macros = filter[2]
		})
		last_y = text:bottom() + 1
	end
	
	self:add_filter("contact", ContractBrokerGui.perform_filter_random)
	self:set_sorting_function(ContractBrokerGui.perform_standard_sort)
end

function ContractBrokerGui:perform_filter_random(contact, optional_current_filter)
	local current_filter = optional_current_filter or self._current_filter or 1
	local allow = false
	
	if contact then
		if current_filter == 1 then
			allow = allow or contact == "randoms"
		elseif current_filter == 2 then
			allow = allow or contact == "random_pros"
		elseif current_filter == 3 then
			allow = allow or contact == "random_stealth"
		elseif current_filter == 4 then
			allow = allow or contact == "random_stealth_pros"
		elseif current_filter == 5 then
			allow = allow or contact == "dayselect"
		elseif current_filter == 6 then
			allow = allow or contact == "escapes"
		end
	end

	return allow
end