# Alias for opening intelij
alias idea=/home/stbarre/Desktop/idea-IC-223.8214.52/bin/idea.sh

# alias for improved rm command
alias rm='rm -iv'

# alias for improved ls command
alias ls='ls -AshCF --color'

# alias for shorter python command
alias python='python3'

# Improved xclip command
alias xclip="xclip -sel clip"

# Sorted ls command
alias lss='ls -S'

# Shorter upgrade command
alias uu='sudo apt upgrade -y && sudo apt upgrade -y'

# Improved gitprune capabilities
alias gitprune="git fetch -p && for branch in \$(git for-each-ref --format '%(refname) %(upstream:track)' refs/heads | awk '\$2 == \"[gone]\" {sub(\"refs/heads/\", \"\", \$1); print \$1}'); do git branch -d \$branch; done"

# Shortest python command
alias py='python3'

# Improved wordcount command
alias wc=/home/stbarre/Scripts/wc.sh

# Move to the parent folder.
alias ..='cd ..;pwd'

# Move up two parent folders.
alias ....='cd ../..;pwd'

# Move up three parent folders.
alias ......='cd ../../..;pwd'

# Press c to clear the terminal screen.
alias c='clear'

# Press h to view the bash history.
alias h='history'

# Display the directory structure better.
alias tree='tree --dirsfirst -F'

# Make a directory and all parent directories with verbosity.
alias mkdir='mkdir -p -v'

# Head of history
alias hh='h | head'

# Tail of history
alias ht='h | tail'


# Add an "alert" alias for long running commands.  Use like so:
#   sleep 10; alert
alias alert='notify-send --urgency=low -i "$([ $? = 0 ] && echo terminal || echo error)" "$(history|tail -n1|sed -e '\''s/^\s*[0-9]\+\s*//;s/[;&|]\s*alert$//'\'')"'


# Maven Clean Install Alias
alias mci='mvn clean install'





