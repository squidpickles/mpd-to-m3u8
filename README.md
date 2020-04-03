# MPD to M3U8 XSLT

This is a small piece of XSLT that will take an MPEG-DASH MPD file and create an HLS master playlist from it.

It was designed for a specific project, where we had tooling to create MPD files with suitable media metadata, but wanted to generate HLS playlists with the same metadata extracted. It may work for your project with no adaptation, but it doesn't handle complex MPD or HLS features, and may have some hardcoded assumptions that don't fit. PRs or feature requests are welcome, if it's something that could be supplied as a template parameter.

This tool specifically generates master HLS playlists; the individual stream playlists must exist on the server for it to work. It means that it's unlikely for an end-user to be able to transform an MPEG-DASH-streamed video into an HLS-streamed video without server-side support.

## Usage example
Let's say you've set up a very basic DASH encoding pipeline:

```bash
# 4800k 1080p
ffmpeg -y -i "input.mkv" -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' \
  -vf scale=-1:1080 -b:v 4800k -maxrate 4800k \
  -movflags faststart -bufsize 9600k -write_tmcd 0 "intermed_4800k.mp4"
# 2400k 720p
ffmpeg -y -i "input.mkv" -c:v libx264 -x264opts 'keyint=24:min-keyint=24:no-scenecut' \
  -vf scale=-1:720 -b:v 2400k -maxrate 2400k \
  -movflags faststart -bufsize 9600k -write_tmcd 0 "intermed_2400k.mp4"
...
# 128k AAC audio only
ffmpeg -y -i "input.mkv" -vn -c:a libfdk_aac -b:a 128k "audio_128k.m4a"

MP4Box -dash 2000 -rap -frag-rap -url-template -dash-profile onDemand -segment-name 'segment_$RepresentationID$' \
  -out playlist.mpd "intermed_4800k.mp4:id=4800k" "intermed_2400k.mp4:id=2400k" ... "audio_128k.m4a:id=128k"
```
Now you create HLS playlists for each quality level:
```bash
ffmpeg -i intermed_4800k.mp4 -acodec copy -vcodec copy -hls_time 2 -hls_flags single_file hls_4800k.m3u8
ffmpeg -i intermed_2400k.mp4 -acodec copy -vcodec copy -hls_time 2 -hls_flags single_file hls_2400k.m3u8
...
ffmpeg -i audio_128k.m4a -acodec copy -vcodec copy -hls_time 2 -hls_flags single_file audio_128k.m3u8
```

Finally, you transform the master playlist using the XSLT file in this repo:
```bash
xsltproc --stringparam run_id "hls" mpd_to_hls.xsl playlist.mpd > playlist.m3u8
```

The `run_id` is the prefix name for the HLS playlists; in the case above, they were named `hls_(representation id).m3u8`, so the `run_id` is `hls`.

Happy streaming!
