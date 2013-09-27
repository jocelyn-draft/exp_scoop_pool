note
	description: "Summary description for {POOLABLE_ITEM}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

deferred class
	POOLABLE_ITEM

feature	-- Access

	pool: detachable separate POOL [POOLABLE_ITEM]

feature -- Execution

	execute
		do
			release
		end

feature -- Change

	set_pool (p: like pool)
		do
			pool := p
		end

	release
		do
			if attached pool as p then
				pool_release (p)
			end
		end

	pool_release (p: separate POOL [POOLABLE_ITEM])
		do
			p.release_item (Current)
		end


end
