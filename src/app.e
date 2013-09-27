note
	description: "Objects that ..."
	author: "$Author$"
	date: "$Date$"
	revision: "$Revision$"

class
	APP

inherit
	SHARED_EXECUTION_ENVIRONMENT

	POOL_ITEM_FACTORY [APP_WORKER]
create
	make

feature {NONE} -- Initialization

	make
			-- Initialize `Current'.
		local
			nb: INTEGER
			w: detachable separate APP_WORKER
--			s_id: separate STRING
		do
			nb := count
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
				else
					execute_worker (w)
				end
--				pool.force (w)
--				execute_worker (w)
			end
--			across
--				pool as c
--			loop
--				if attached c.item as w_item then
--					execute_worker (w_item)
--				end
--			end
			print ("Let's wait ...%N")
--			execution_environment.sleep ({INTEGER_64} 25 * {INTEGER_64} 1000_000_000)
--			print ("Enough sleeping ...%N")
			wait_for_completion (pool)
			print ("waiting is done.%N")
			print_buffer (buffer)
			print ("End....%N")
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

	count: INTEGER = 5

	worker_counter: INTEGER

	new_separate_item: separate APP_WORKER
		local
		do
			worker_counter := worker_counter + 1
--			create Result.make (create {STRING}.make_from_string ("Worker#" + worker_counter.out), buffer, 10 + (count - worker_counter) \\ 3)
			create Result.make_with_integer_id (worker_counter, buffer, 10 + (count - worker_counter) \\ 3)
		end

feature -- Status

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
--			print ("Launching " + worker_id (w) + "%N")
			w.execute
			print (pool.status + "%N")
			print ("worker launched%N")
		end

	pool_completed (a_pool: like pool): BOOLEAN
		do
			Result := across a_pool as c all attached c.item as w implies worker_is_completed (w) end
		end

	wait_for_completion (a_pool: like pool)
		require
			pool_completed (a_pool)
		do
			print ("Press ENTER when you think all " + count.out + " workers are done ...%N")
			io.read_line
--			print ("Wait 10 seconds...%N")
--			execution_environment.sleep (10_000_000_000)
--			print ("10 seconds waiting is done.%N")
			print ("Waiting for completion...%N")
			from
			until
				pool_completed (pool)
			loop
				execution_environment.sleep (1_000)
			end
			print ("Pool completed.%N")
		end

	print_buffer (buf: like buffer)
		do
			print (buf)
		end


end
