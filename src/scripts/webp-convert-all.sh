#!/bin/bash

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
M2_ROOT="$SCRIPT_DIR/.."

LOG_FILE="$M2_ROOT/var/log/webp.info.log"
ERROR_LOG_FILE="$M2_ROOT/var/log/webp.error.log"

info_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $LOG_FILE
}
error_log() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> $ERROR_LOG_FILE
}

start=`date +%s`
info_log "Starting the conversion process"

cd "$M2_ROOT/pub/media" || exit

find ./ -type d -name cache -prune \
-o \( -type f -iname \*.jpg -o -iname \*.jpeg -o -iname \*.png \) -print0 |

while IFS= read -r -d $'\0' file;
  do
    if [[ ! -e "$file.webp" && ! -e "$file.webpfail" ]]; then
        info_log "Converting: $file -> $file.webp"
        cwebp -q 80 -quiet "$file" -o "$file.webp" || (touch $file.webpfail && error_log "Failed to convert $file" && continue )
    fi
  done

end=`date +%s`
runtime=$((end-start))

info_log "Execution completed in $runtime seconds."
info_log "Ending the conversion process"
