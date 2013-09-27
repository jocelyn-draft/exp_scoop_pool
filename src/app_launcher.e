note
	description: "Objects that ..."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	APP_LAUNCHER

inherit
	SHARED_EXECUTION_ENVIRONMENT

	POOL_ITEM_FACTORY [APP_WORKER]
create
	make

feature {NONE} -- Initialization

	make (nb: INTEGER)
			-- Initialize `Current'.
		local
			w: detachable separate APP_WORKER
		do
			count := nb
			create buffer.make (100)
			print ("Multiple task sharing the same conf object.%N")
			create pool.make (nb, Current)
			set_pool_count (pool, nb)
			across
				1 |..| nb as c
			loop
				w := new_worker (pool)
				if w = Void then
					print ("Pool is full!%N")
				end
			end
			
			across
				pool as c
			loop
				if attached c.item as w_item then
					execute_worker (w_item)
				end
			end
		end

	new_worker (p: like pool): detachable separate APP_WORKER
		do
			Result := p.new_separate_item
		end

	set_pool_count (p: like pool; n: INTEGER)
		do
			p.set_count (n)
		end

feature -- Factory

	count: INTEGER

	worker_counter: INTEGER

	new_separate_item: separate APP_WORKER
		do
			worker_counter := worker_counter + 1
--			create Result.make (create {STRING}.make_from_string ("Worker#" + worker_counter.out), buffer, 10 + (count - worker_counter) \\ 3)
			create Result.make_with_integer_id (worker_counter, buffer, 10 + (count - worker_counter) \\ 3)
		end

feature -- Status

	is_completed: BOOLEAN
		do
			Result := pool_completed (pool)
		end

	pool: POOL [APP_WORKER]

	buffer: APP_BUFFER

	worker_id (w: separate APP_WORKER): STRING
		do
			create Result.make_from_separate (w.id)
		end

	worker_is_running (w: separate APP_WORKER): BOOLEAN
		do
			Result := w.is_running
		end

	worker_is_completed (w: separate APP_WORKER): BOOLEAN
		do
			Result := w.is_completed
		end

	execute_worker (w: separate APP_WORKER)
		do
			print ("Launching " + worker_id (w) + "%N")
			w.execute
			print (pool.status + "%N")
			print ("worker launched%N")
		end

	pool_completed (a_pool: like pool): BOOLEAN
		do
			Result := a_pool.count = 0
		end

	print_buffer
		do
			print_buffer_value (buffer)
		end

	print_buffer_value (buf: like buffer)
		do
			print (buf.text)
		end


end
