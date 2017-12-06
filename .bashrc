
eval `ssh-agent`
ssh-add

# Various ways to connect to a machine via ssh
# PEI-Genesis connections
alias con=sshConnect
alias d1-wapp01=sshConnect
alias d1app01=sshConnect
alias d1a1=sshConnect
alias hi=sshConnect
alias hello=sshConnect

# General command aliases
alias cls="clear"
alias bye="exit"
alias goodbye="exit"

# Modification to ls command
# Default command: ls --color -lahp
# Takes in a 2nd argument: r,t,g - reverse the order, order by time modified, and add a grep command
# 2nd argument can be any combo or order of the 3 letters
# If g is in the 2nd argument, add a 3rd argument, which is the string to search for
alias lst=listContents

# Change to git directory (/c/git/) and do an lst to see the files
alias gitd=changeToGitDirectory

# Changes directory (cd) but allows a second command
# Essentially cd /x/y/ | {command2}
# Used for learning purposes
alias dir=changeDir

# Helpers
# dir
alias cd2=changeDirWithExtraCommand

# lst
alias lcg=listContentsGrep

# -- All aliases below are Unix only --
test -s ~/.alias && . ~/.alias || true

# Combo of functions to tail a certain log - defaults and shortcuts are set for PEI-Genesis boxes
# 1st arg is the log to tail - no default, this is required
# 1st arg can also be a predefined log shortcut - err = error log, ssl-err = ssl error log
# 2nd arg is follow (boolean) - default is 1; will always follow unless 0 is passed in
alias tl=tailLog

# Helpers for tl
alias tes="tl ssl-err" # ssl error log
alias te="tl err" # error log
alias tesnofo="tl ssl-err 0" # ssl error log, no follow
alias tenofo="tl ssl-err 0" # error log, no follow

# Changes to the default apache log directory
alias errlog="cd /var/log/apache2/"

# If you want to specify a default editor, uncomment the line below and enter the editor of your choice
#export EDITOR=/usr/bin/vim
#export EDITOR=/usr/bin/mcedit

changeDirWithExtraCommand() {
	cd $1; # Do the directory change
	eval $2; # Evaulate the second string of args as 1 argument
}

changeDir() {
	if [[ -z $2 ]] # If no second arg passed in, just do a cd on the first argument
	then
		cd $1
	else # Else, build a grouped argument from the remaining arguments so that it can be called as one argument in the next function
		x=1
		cmd=""
		for var in "$@"
		do
			if (( $x > 1 ))
			then
				if [[ -z $cmd ]]
				then
					cmd="$var"
				else
					cmd="$cmd $var"
				fi
			fi
			((x++))
		done
		
		# Use the helper function to execute the cd on the first argument, and then the remaining arguments as one execution
		cd2 "$1" "$cmd"
	fi
}

changeToGitDirectory() {
	cd /c/git/
	lst
}	

sshConnect() {
	if [ -z ${1+x} ] # If the first argument is not there, just connect to the default box (jdunham@d1-wapp01)
	then
		ssh jdunham@d1-wapp01;
	else # Else, connect to whatever box the user passed in as the argument
		ssh jdunham@$1;
	fi
}

listContentsGrep() {
	$1 | grep $2
}

listContents() {
	cmd="ls --color -lahp" # Default command to run
	if [ -z ${1+x} ]; # If there is no argument passed in
	then
		$cmd # Run the command
	else
		if [[ $1 == *"r"* ]] # If the first arg contains an "r" (reverse the order)
		then
			cmd="$cmd""r" # Append an "r" to the default command
		fi
		
		if [[ $1 == *"t"* ]] # If the first arg contains an "t" (order by time)
		then
			cmd="$cmd""t" # Append an "t" to the default command
		fi
		
		if [[ $1 == *"g"* ]] # If the first arg contains an "g" (include a grep command)
		then
			lcg "$cmd" $2 # call listContentsGrep with the list command that was built + the 2nd arg which is the search string for the grep command
		else # No grep
			$cmd # Run the command that was built
		fi	
	fi
}

tailLog() {
	tailcommand="tail" # Begin building the tail command
	if [ -z ${2+x} ]; # If there is no 2nd arg (follow flag)
	then
		tailcommand="$tailcommand -f" # Add the -f flag to the tail command by default (why wouldn't you want to follow the log?)
	else
		if(( $2 == 0 )) # If there is a 2nd arg and it's 0
		then
			tailcommand="$tailcommand" # Don't append the -f flag to the command
		elif (( $2 == 1 )) # Else, if there is a 2nd arg and it's a 1
			then
				tailcommand="$tailcommand -f" # Append the follow flag
		else
			tailcommand="$tailcommand"
		fi
	fi
	
	if [ -z ${1+x} ]; # If no 1st arg
	then
		echo "No log specified to tail." # Inform the user a log is needed
	else
		if [[ $1 = "ssl-err" ]] # If the first arg is ssl-err
		then
			tailcommand="$tailcommand /var/log/apache2/ssl-jdunham.sandbox.peidev.net-error_log" # Set the tail command to include the ssl error log
		elif [[ $1 = "err" ]] # Else if the 1st arg is err
		then
			tailcommand="$tailcommand /var/log/apache2/jdunham.sandbox.peidev.net-error_log" # Tail the default error log
		else # No predefined logs
			tailcommand="$tailcommand $1" # Tail whatever log the user sends in
		fi
		$tailcommand # Exectute the command
	fi
}