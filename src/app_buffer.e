note
	description: "Summary description for {APP_BUFFER}."
	author: ""
	date: "$Date$"
	revision: "$Revision$"

class
	APP_BUFFER

create
	make

feature
	make (n: INTEGER)
		do
			create text.make (n)
		end

	text: STRING

	extend (s: separate STRING)
		local
			l_string: STRING
		do
			create l_string.make_from_separate (s)
			text.append (l_string)
		end

end
