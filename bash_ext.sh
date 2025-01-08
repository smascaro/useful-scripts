historyg() {
  history | grep "$1"
}

# Make sure to run git_aliases.sh so the following git aliases are found

gcu() {
  git cu
}

gu() {
  git unstage
}

glogg() {
  git logg
}

gss() {
  git ss
}

alias vi=vim

# Start THM's OpenVPN
thm-start() {
  sudo openvpn /opt/tryhackme_smascaro_eu1.ovpn &
}

# Stop THM's OpenVPN session
thm-stop() {
  sudo killall openvpn
}

# Activate a Python environment in the current directory
activate() {
  source ./venv/bin/activate
}
