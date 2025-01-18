#!/bin/bash

directory="../pub/media"
cd "$directory" || exit

# Function to process files with specific extensions
process_files() {
  local extension="$1"

  find . -type f -name "*${extension}" | while read -r file; do
    echo "$file"
    basename="${file%.*}"

    if [ -f "$basename" ]; then
      echo "$file"
      rm "$file"
    fi
  done
}

# List of extensions to process
extensions=("jpg.webp" "jpeg.webp" "png.webp" "webpfail")

# Loop through each extension and call the function
for ext in "${extensions[@]}"; do
  process_files "$ext"
done