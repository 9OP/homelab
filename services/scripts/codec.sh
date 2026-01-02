#!/bin/bash
# codec_checker.sh

echo "Scanning media library for codecs..."
echo "=================================="

h264_count=0
hevc_count=0

find /mnt/storage/media -type f \( -name "*.mkv" -o -name "*.mp4" -o -name "*.avi" \) | while read file; do
codec=$(ffprobe -v error -select_streams v:0 -show_entries stream=codec_name -of default=noprint_wrappers=1:nokey=1 "$file" 2>/dev/null)

case "$codec" in
    h264)
    echo "✅ H.264: $(basename "$file")"
    ;;
    hevc)
    echo "❌ H.265: $(basename "$file")"
    ;;
    *)
    echo "⚠️  Other ($codec): $(basename "$file")"
    ;;
esac
done
