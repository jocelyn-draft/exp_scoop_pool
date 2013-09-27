note
	description: "Objects that ..."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	APP

create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			launcher: separate APP_LAUNCHER
		do
			create launcher.make (10)
			reach_end (launcher)
		end

	reach_end (a_launcher: separate APP_LAUNCHER)
		require
			a_launcher.is_completed
		do
			a_launcher.print_buffer
			print ("End%N")
		end

end
