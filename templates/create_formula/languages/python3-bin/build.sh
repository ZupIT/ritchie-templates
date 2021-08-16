#!/bin/sh

BINARY_NAME=run.sh
BINARY_MAIN=main
BIN_FOLDER=bin
SRC_FOLDER=src

checkCommand () {
	if ! command -v "$1" >/dev/null; then
    	echo "$1 required" >&2;
		exit 1;
	fi
}

#check os
if [[ $OSTYPE == 'darwin'* ]]; then
	BIN_FOLDER=$BIN_FOLDER'/darwin'
elif [[ $OSTYPE == 'linux-gnu'* ]]; then
	BIN_FOLDER=$BIN_FOLDER/'linux'
fi

#python-build:
	checkCommand pip3

	pip3 install pyinstaller
	checkCommand pyinstaller

	mkdir -p $BIN_FOLDER
	cp -r src/requirements.txt $BIN_FOLDER
	pip3 install -r $SRC_FOLDER/requirements.txt --user --disable-pip-version-check

	pyinstaller -y --distpath $BIN_FOLDER --onefile --clean $SRC_FOLDER/main.py


#clean-build-files
	rm -rf src/__pycache__
	rm -rf build

#sh_unix:
	{
	echo "#!/bin/bash"
	echo "if [ -f /.dockerenv ] ; then"
	echo "pip3 install -r \$(dirname \"\$0\")/requirements.txt --user --disable-pip-version-check >> /dev/null"
	echo "fi"
	echo "cd \$(dirname \"\$0\")"
	echo "./main"
	} >> $BIN_FOLDER/$BINARY_NAME
	
	chmod +x $BIN_FOLDER/$BINARY_NAME
	chmod +x $BIN_FOLDER/$BINARY_MAIN

#docker:
	cp Dockerfile set_umask.sh $BIN_FOLDER
