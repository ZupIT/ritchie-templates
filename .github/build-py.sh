#!/bin/bash
export NAMEDOCKERIMAGEBUILDER=$1

checkBuild() {
  initialPwd=$(pwd)
  file=$1
  folder="${file/\/config.json/}"
  autoBuildOnRelease=$(cat "$file" | jq '.autoBuildOnRelease')
  dockerImageBuilder=$(cat "$file" | jq '.dockerImageBuilder')

  if [[ $autoBuildOnRelease == true && \"$NAMEDOCKERIMAGEBUILDER\" == $dockerImageBuilder ]]; then
    chmod -R 777 .
    echo "Building $autoBuildOnRelease.... $file"
    if [[ -f "$folder/bin" ]] ; then
      echo "Remove old bin folder ..."
      rm -rf "$folder/bin"
    fi
    if [[ -f "$folder/build.sh" ]] ; then
        echo "Build with build.sh ..."
        cd $folder && ./build.sh
    else
        echo "Build with Makefile ...."
        make -C $folder > /dev/null
    fi
    pwd
    echo "Tree of above pwd: "
    tree
    cd ../..
  fi
  cd $initialPwd
}

checkCommand () {
    if ! command -v "$1" >/dev/null; then
      if [[ "$2" == "" ]] ; then
        echo -e "\\e[91m✘ Error: \\e[33;1m$1 \\e[0mis required";
      else
        echo -e "\\e[91m✘ Error: \\e[33;1m$2\\e[0m";
      fi
      exit 1;
    fi
}

checkCommand find "Find is required"
checkCommand make "Make is required"
checkCommand jq "Jq is required"

export -f checkBuild
find . -name "config.json" -exec bash -c 'checkBuild "{}"' \;
