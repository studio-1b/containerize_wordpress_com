#/bin/bash

7z i &>/dev/null
if [ $? -ne 0 ]; then
  apk add 7z 7z-doc
fi

WAIT=600
BAK_DIR="/var/local"
VOL_DIR="/mnt"
#while [ 0 -eq 0 ]; do
  echo "."
  for f in $(seq 1 10); do
    echo "File -> $f"
    BAK="$BAK_DIR/vol$f.7z"
    VOL="$VOL_DIR/vol$f"
    if [ -f $BAK ] && [ -d $VOL ] && [ ! "$( ls -A $VOL/* )" ]; then
      # extract to empty volume
      echo extract
      cd $VOL/
      7z x $BAK
    elif [ ! -f $BAK ] && [ -d $VOL ] && [ "$( ls -A $VOL/* )" ]; then
      # create new backup
      echo create
      cd $VOL/
      7z a $BAK $VOL/* -snl
      WAIT=0
    elif [ -f $BAK ] && [ -d $VOL ] && [ "$( ls -A $VOL/* )" ]; then
      # update backup
      echo update
      cd $VOL/
      7z u $BAK $VOL/* -snl
    fi
  done

  sleep $WAIT
#done
