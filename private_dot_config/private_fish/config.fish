if status is-interactive
    # Commands to run in interactive sessions can go here
end

# Remove the default greeting message
set -g fish_greeting ""

# Environment Variables (-gx exports globally)
set -gx EDITOR nvim
set -gx PATH $HOME/.local/bin $PATH

# Abbreviations (Text snippets that expand when you press space)
abbr gs "git status"
abbr gp "git push"
abbr gcm "git commit -m"

# Aliases (Traditional wrapper functions)
alias ll "ls -lah"
alias la "ls -A"

function packettracer
    set -x QT_QPA_PLATFORM xcb
    /usr/sbin/packettracer &
    disown

    # give it time to actually open a window
    sleep 15

    # poll until the window is gone
    while niri msg windows | grep -q 'App ID: "PacketTracer"'
        sleep 2
    end

    # window closed — kill whatever's left
    pkill -9 -f PacketTracer
    pkill -9 -f QtWebEngineProcess
    pkill -9 -f packettracer
end

# ── dev tools ──
if status is-interactive
    type -q fzf;      and fzf --fish | source          # Ctrl+R history, Ctrl+T files, Alt+C cd
    type -q zoxide;   and zoxide init fish | source    # z <dir>
    type -q direnv;   and direnv hook fish | source    # per-project .envrc
    type -q mise;     and mise activate fish | source  # per-project tool versions
    type -q atuin;    and atuin init fish --disable-up-arrow | source
    type -q starship; and starship init fish | source

    if type -q eza
        alias ls "eza --icons --group-directories-first"
        alias ll "eza -lah --icons --git"
        alias tree "eza --tree --icons"
    end
    abbr lg lazygit
    abbr gd "git diff"
    abbr gl "git log --oneline --graph -20"
end
...
