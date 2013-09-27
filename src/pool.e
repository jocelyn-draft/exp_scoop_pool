note
	description: "Summary description for {POOL}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	POOL [G -> POOLABLE_ITEM]

inherit
	ITERABLE [detachable separate G]

create
	make

feature {NONE} -- Initialization

	make (n: INTEGER; f: like factory)
		do
			factory := f
			capacity := n
			create items.make_empty (n)
			create available_items.make_empty (n)
--			create busy_items.make_filled (False, n)
			create busy_items.make_empty (n)
		end

feature -- Access

	count: INTEGER

	status: STRING
		do
			Result := count.out + " items"
		end

	capacity: INTEGER

	factory: separate POOL_ITEM_FACTORY [G]

feature -- Access

	new_cursor: ITERATION_CURSOR [detachable like new_separate_item]
			-- Fresh cursor associated with current structure
		do
			Result := items.new_cursor
		end

feature {NONE} -- Internal

	items: SPECIAL [detachable like new_separate_item]

	busy_items: SPECIAL [BOOLEAN]

	available_items: SPECIAL [INTEGER]

	last_available_index: INTEGER

feature -- Change

	set_count (n: INTEGER)
		local
			g: detachable separate G
		do
			capacity := n
			items.fill_with (g, 0, n - 1)
			busy_items.fill_with (False, 0, n - 1)
		end

feature -- Access

	factory_new_separate_item (f: like factory): separate G
		do
			Result := f.new_separate_item
		end

	new_separate_item: detachable separate G
		local
			i,n,pos: INTEGER
			lst: like busy_items
			l_item: detachable like new_separate_item
		do
			from
				lst := busy_items
				pos := -1
				i := 0
				n := lst.count - 1
			until
				i > n or l_item /= Void or pos >= 0
			loop
				if not lst [i] then -- is free (i.e not busy)
					pos := i

					if items.valid_index (pos) then
						l_item := items [pos]
						if l_item /= Void then
							busy_items [pos] := True
						end
					end
					if l_item = Void then
							-- Empty, then let's create one.
						l_item := factory_new_separate_item (factory)
						register_item (l_item)
						items [pos] := l_item
					end
				end
				i := i + 1
			end
			if l_item = Void then
				check overcapacity: False end
--				Result := factory.new_separate_item
			else
				count := count + 1
				busy_items [pos] := True
				Result := l_item
			end
		end

	register_item (a_item: attached like new_separate_item)
		do
			a_item.set_pool (Current)
		end

	release_item (a_item: attached like new_separate_item)
		local
			i,n,pos: INTEGER
			lst: like items
		do
				-- release handler for reuse
			from
				lst := items
				i := 0
				n := lst.count - 1
			until
				i > n or lst [i] = a_item
			loop
				i := i + 1
			end
			if i <= n then
				pos := i
				busy_items [pos] := False
				count := count - 1
--				items [pos] := Void
			else
				check known_item: False end
			end
		end

end
