#!/bin/sh

DIR=`dirname $0`

if [ -d /tmp/mksl3 ]
then
  rm /tmp/mksl3 -Rf
fi

mkdir /tmp/mksl3

if [ -n "$CLASSPATH" ]
then
  LOCALCLASSPATH=$CLASSPATH
fi

# add in the dependency .jar files, which reside in $DIR/lib
DIRLIBS=${DIR}/lib/*/*.jar
for i in ${DIRLIBS}
do
    # if the directory is empty, then it will return the input string
    # this is stupid, so case for it
    if [ "$i" != "${DIRLIBS}" ] ; then
      if [ -z "$LOCALCLASSPATH" ] ; then
        LOCALCLASSPATH=$i
      else
        LOCALCLASSPATH="$i":$LOCALCLASSPATH
      fi
    fi
done

javac -classpath "$LOCALCLASSPATH" -d /tmp/mksl3 ${DIR}/*.java
