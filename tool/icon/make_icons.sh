#!/bin/sh
# Scales the icon masters in build/icon into the Android and iOS icon sets.
# Needs ffmpeg. Run tool/icon/render_icon_test.dart first.
set -e
res=android/app/src/main/res
scale() { ffmpeg -y -hide_banner -loglevel error -i "$1" -vf "scale=$3:$3:flags=lanczos$4" "$2"; }

for pair in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  d=${pair%%:*}; px=${pair##*:}
  scale build/icon/icon_full.png "$res/mipmap-$d/ic_launcher.png" "$px"
done
# Adaptive icon layers are 108 dp.
for pair in mdpi:108 hdpi:162 xhdpi:216 xxhdpi:324 xxxhdpi:432; do
  d=${pair%%:*}; px=${pair##*:}
  scale build/icon/icon_foreground.png "$res/mipmap-$d/ic_launcher_foreground.png" "$px"
  scale build/icon/icon_background.png "$res/mipmap-$d/ic_launcher_background.png" "$px"
  scale build/icon/icon_monochrome.png "$res/mipmap-$d/ic_launcher_monochrome.png" "$px"
done

# iOS: every size its Contents.json lists, without alpha.
ios=ios/Runner/Assets.xcassets/AppIcon.appiconset
for f in "$ios"/*.png; do
  px=$(ffprobe -v error -select_streams v:0 -show_entries stream=width -of csv=p=0 "$f")
  scale build/icon/icon_full.png "$f" "$px" ",format=rgb24"
done
echo "icons written"
