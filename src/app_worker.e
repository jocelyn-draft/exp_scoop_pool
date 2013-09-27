note
	description: "Summary description for {APP_WORKER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APP_WORKER

inherit
	POOLABLE_ITEM
		redefine
			execute
		end

	SHARED_EXECUTION_ENVIRONMENT

create
	make,
	make_with_integer_id

feature {NONE} -- Initialization

	make (a_id: separate READABLE_STRING_8; a_buffer: like buffer; a_nb: INTEGER)
		do
			make_with_id (create {STRING_8}.make_from_separate (a_id), a_buffer, a_nb)
		end

	make_with_integer_id (a_id: INTEGER; a_buffer: like buffer; a_nb: INTEGER)
		do
			make_with_id (a_id.out, a_buffer, a_nb)
		end

	make_with_id (a_id: READABLE_STRING_8; a_buffer: like buffer; a_nb: INTEGER)
		do
			create id.make_from_string (a_id)
			buffer := a_buffer
			nb := a_nb.abs
		end

feature -- Access

	id: STRING

	nb: INTEGER

	buffer: separate APP_BUFFER

	is_running: BOOLEAN

	is_completed: BOOLEAN

feature -- Execution

	execute
		local
			i: INTEGER
			n: INTEGER
		do
			is_completed := False
			is_running := True
			from
				i := 1
				n := nb
			until
				i > n
			loop
				print ("<#" + processor_id_from_object (Current).out + "> " + generator + "[" + id + "] -> " + i.out + "%N")
				debug
					print ("<#" + processor_id_from_object (Current).out + "> " + generator + "[" + id + "] going to store " + i.out + "%N")
				end
				store (buffer, "[" + id + "] " + i.out + "%N")
				store (buffer, "[" + id + "] " + i.out + " Bis repetita%N")
				store (buffer, "[" + id + "] " + i.out + " Non placent%N")
				debug
					print ("<#" + processor_id_from_object (Current).out + "> " + generator + "[" + id + "] completed to store " + i.out + "%N")
				end

				i := i + 1
			end
--			store (buffer, id + "(nb:" + n.out + ") DONE.%N")
			print (id + "(nb:" + n.out + ") DONE.%N")
			is_running := False
			is_completed := True
			Precursor
		end

	store (a_buffer: separate APP_BUFFER; an_element: STRING)
		do
			a_buffer.extend (an_element)
		end

	frozen processor_id_from_object (a_object: ANY): INTEGER_32
		external
			"C inline use %"eif_scoop.h%""
		alias
			"RTS_PID(eif_access($a_object))"
		end

end
