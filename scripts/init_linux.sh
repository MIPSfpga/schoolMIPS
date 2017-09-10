#!/bin/bash

SCRIPTPATH=$( cd $(dirname $0) ; pwd -P )
TOP_BOARD=$SCRIPTPATH/../board
TOP_PROGRAM=$SCRIPTPATH/../program

for board in $TOP_BOARD/*
do
    if [ -d $board ] && [ "$TOP_BOARD/program" != "$board" ]; then
	rm -f $board/*.bat
	cp $SCRIPTPATH/board/common/*.sh $board
	chmod a+x $board/*.sh
    fi
done

for program in $TOP_PROGRAM/*
do
    if [ -d $program ]; then
	rm -f $program/*.bat
	cp $SCRIPTPATH/program/common/*.sh $program
	chmod a+x $program/*.sh
    fi
done
