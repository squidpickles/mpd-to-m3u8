# MPD to M3U8 XSLT

This is a very simple piece of XSLT that will take an MPEG-DASH MPD file and create an HLS master playlist from it.

## Scenario
Let's say you've set up a very basic DASH encoding pipeline:

```bash
# 4800k 1080p
ffmpeg -y -i "input.mkv" -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' \
  -vf -1:1080 -b:v 4800k -maxrate 4800k \
  -movflags faststart -bufsize 9600k -write_tmcd 0 "intermed_4800k.mp4"
# 2400k 720p
ffmpeg -y -i "input.mkv" -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' \
  -vf -1:720 -b:v 2400k -maxrate 2400k \
  -movflags faststart -bufsize 9600k -write_tmcd 0 "intermed_2400k.mp4"
...
# 128k AAC audio only
ffmpeg -y -i "input.mkv" -vn -c:a libfdk_aac -b:a 128k "audio_128k.m4a"

MP4Box -dash 2000 -rap -frag-rap -url-template -dash-profile onDemand -segment-name 'segment_$RepresentationID$' \
  -out playlist.mpd "intermed_4800k.mp4" "intermed_2400k.mp4" ... "audio_128k.m4a"
```
Now you create HLS playlists for each quality level:
```bash
ffmpeg -i intermed_4800k.mp4 -acodec copy -vcodec copy -hls_time 2 -hls_flags single_file hls_4800k.m3u8
...
ffmpeg -i audio_128k.m4a -acodec copy -vcodec copy -hls_time 2 -hls_flags single_file audio_128k.m3u8
```

Finally, you transform the master playlist using the XSLT file in this repo:
```bash
xsltproc --stringparam run_id "segment" mpd-to-m3u8.xsl playlist.mpd > playlist.m3u8
```

Happy streaming!
