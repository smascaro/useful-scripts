export ANDROID_KEYSTORE_PROPERTIES_FILE_PATH='/Users/sergi/chordify/keystores/android-app/keystore.properties'
launchctl setenv ANDROID_KEYSTORE_PROPERTIES_FILE $ANDROID_KEYSTORE_PROPERTIES_FILE_PATH

historyg(){
  history | grep "$1"
}

alias git='LANG=en_GB git'

gcu(){
  git cu
}

tunnel-diminished(){
  ssh -L8000:127.0.0.1:8000 -N -v diminished.intranet.chordify.net
}

gu() {
  git unstage
}

glogg() {
  git logg
}

alias vi=vim