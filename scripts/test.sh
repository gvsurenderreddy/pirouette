config.section.reset() {
	echo "Active!";
}

function reset() { config.section.reset 2> /dev/null || return 1; }

reset;


