export ANDROID_KEYSTORE_PROPERTIES_FILE_PATH='/Users/sergi/chordify/keystores/android-app/keystore.properties'
launchctl setenv ANDROID_KEYSTORE_PROPERTIES_FILE $ANDROID_KEYSTORE_PROPERTIES_FILE_PATH

historyg(){
  history | grep "$1"
}

gcu(){
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

thm-start() {
  sudo openvpn /opt/tryhackme_smascaro_eu1.ovpn &
}

thm-stop() {
  sudo killall openvpn
}

activate() {
  source ./venv/bin/activate
}
