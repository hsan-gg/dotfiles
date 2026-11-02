# Alt+B: run whatever is on the command line with bash instead of fish.
# Handy for pasted bash snippets (heredocs, [[ ]], $((..)), if/then/fi ...).
function run_in_bash --description 'Run the current command line in bash'
    set -l cmd (commandline | string collect)
    test -z "$cmd"; and return
    commandline -r -- "bash -c "(string escape -- $cmd)
    commandline -f execute
end
