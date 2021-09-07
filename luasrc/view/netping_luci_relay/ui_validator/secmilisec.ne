#
# Lets describe seconds: 0..999 and miliseconds: 0.001...0.999
#

MAIN			-> 	SECONDS ("." MILISECONDS):*

SECONDS			-> 	[0-9]
				|	[1-9] [0-9]
				|	[1-9] [0-9] [0-9]
				
MILISECONDS		-> 	[0-9]
				|	[0-9] [0-9]
				|	[0-9] [0-9] [0-9]