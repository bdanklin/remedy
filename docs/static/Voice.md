## Voice Channels
Discord voice channels allow audio data to be sent to the voice servers over UDP.
A bot is able to connect to up to one voice channel per guild. One websocket
connection will be opened and maintained for each voice channel the bot joins.
The websocket connection should reconnect automatically the same way that the
main Discord gateway websocket connections do. For available voice functions and
usage see the `Remedy.Voice` module.

## FFmpeg
Remedy uses the powerful [ffmpeg](https://ffmpeg.org/) command line utility to
encode any audio (or video) file for sending to Discord's voice servers.
By default Remedy will look for the executable `ffmpeg` in the system path.
If the executable is elsewhere, the path may be configured via
`config :remedy, :ffmpeg, "/path/to/ffmpeg"`.
The function `Remedy.Voice.play/4` allows sound to played via files, local or
remote, or via raw data that gets piped to `stdin` of the `ffmpeg` process.
When playing from a url, the url can be a name of a file on the filesystem or a url
of file on a remote server - [ffmpeg supports a ton of protocols](https://www.ffmpeg.org/ffmpeg-protocols.html),
the most common of which are probably `http` or simply reading a file from the filesystem.
It is also possible to send raw opus frames, bypassing ffmpeg, if desired.

## youtube-dl
With only `ffmpeg` installed, Remedy supports playing audio/video files or raw, piped
data as discussed in the section above. Remedy also has support for `youtube-dl`, another
powerful command line utility for downloading audio/video from online video services.
Although the name implies support for Youtube, `youtube-dl` supports downloading from
[an immense list of sites](https://github.com/ytdl-org/youtube-dl/blob/master/docs/supportedsites.md).
By default Remedy will look for the executable `youtube-dl` in the system path. If the
executable is elsewhere, the path may be configured via `config :remedy, :youtubedl, "/path/to/youtube-dl"`.
When `Remedy.Voice.play/4` is called with `:ytdl` for the `type` parameter, `youtube-dl` will be
run with options `-f bestaudio -q -o -`, which will attempt to download the audio at the given url and pipe it to `ffmpeg`.

## streamlink
Remedy also has support for `streamlink`, yet another powerful command line utility for downloading live streams from online video streaming services.
By default Remedy will look for the executable `streamlink` in the system path.
If the executable is elsewhere, the path may be configured via `config :remedy, :streamlink, "/path/to/streamlink"`.
When `Remedy.Voice.play/4` is called with `:stream` for the `type` parameter, `streamlink`
will be attempt to download the live stream content and pipe it to `ffmpeg`.
Using `streamlink` with Remedy depends on `youtube-dl` to get the underlying
stream URL from the user-friendly URL that's given as input.

## Audio Timeout
Upon invoking `Remedy.Voice.play/4`, the player process has a large configurable initial window
(`20_000` milliseconds by default) that it must generate audio within before timing out. This is done to allow
ample time for slow networks to download large audio/video files. This configurable timeout only applies to when
`play` is initially invoked; once audio has begun transmitting, the timeout drops to `500` milliseconds.
Because the `ffmpeg` process doesn't close when its input device is `stdin`, which is the case
when `type` is set to `:pipe`, `:ytdl`, or `:stream` the timeout is necessary to promtly detect end of input.
If the audio process times out with the initial window, the `Remedy.Struct.Event.SpeakingUpdate`
that is generated will have its `timed_out` field set to `true`. It will be `false` in all other cases.
If your use case does not include large, slow downloads and you wish to more quickly be notified
of timeouts or errors, you may consider setting `audio_timeout` to a lower value.
However, `youtube-dl` typically takes at least 2.5 seconds to begin outputting audio data,
even on a fast connection.
If your use case involves playing large files at a timestamp several hours in like this,
`play(guild_id, url, :ytdl, start_time: "2:37:56")`, you may consider setting the timeout to a higher value, as downloading a large youtube video and having `ffmpeg` seek through several hours
of audio may take 15-20 seconds, even with a fast network connection.

## Voice Events
There are a few voice related events that bots can consume with a `Remedy.Consumer` process:
  - `t:Remedy.Consumer.voice_state_update/0`
  - `t:Remedy.Consumer.voice_server_update/0`
  - `t:Remedy.Consumer.voice_speaking_update/0`
  - `t:Remedy.Consumer.voice_ready/0`

Both `t:Remedy.Consumer.voice_state_update/0` and `t:Remedy.Consumer.voice_server_update/0`
are sent by the shard gateway session when a bot joins a voice channel. The receipt of both of
these events is required for a voice gateway session to begin, and it happens automatically when
joining a channel. The `t:Remedy.Consumer.voice_state_update/0` event is also sent every time
any user joins or leaves a voice channel, and `t:Remedy.Struct.Guild.voice_states/0` is
automatically updated within the guild cache to reflect current state of voice channels.

A use case for listening to both `t:Remedy.Consumer.voice_state_update/0` and
`t:Remedy.Consumer.voice_server_update/0` events would be to outsource voice connections to
an application outisde of Remedy. This can be done by setting the config option
`voice_auto_connect` to `false` and taking the session and token information
from both of the events and passing them to your external voice app.
Outside of this niche use case, another use case for listening solely to the
`t:Remedy.Consumer.voice_state_update/0` event would be to detect when users join or leave
voice channels.

The `t:Remedy.Consumer.voice_speaking_update/0` is generated by Remedy for convenience. It is
sent everytime the bot starts or stops speaking/sending audio. A use case for this event is if
you have a queue of URLs to play, listening to the `t:Remedy.Consumer.voice_speaking_update/0`
will let the bot know when the current URL has finished playing and that it should begin playing
the next one in the queue. The alternative approach for this use case that is not event-driven
is to periodically call `Remedy.Voice.playing?/1` and wait for it to return `false` as the
trigger to play the next URL. Note that the third element in the event is of type
`t:Remedy.Struct.VoiceWSState.t/0` and not `t:Remedy.Struct.WSState.t/0`.

The `t:Remedy.Consumer.voice_ready/0` is generated by Remedy for convencience. It is sent
when the bot is ready to begin sending audio data upon joining a voice channel. From the moment
the bot joins a voice channel, Remedy handles the multi-step handshaking process that is
required before any audio packets can be sent or received. It is a common use case for bot to
immediately begin playing audio upon joining a voice channel. Calling `Remedy.Voice.play/4`
directly after calling `Remedy.Voice.join_channel/4` will always return an error as several
network actions must take place before playing audio is possible. Listening for the
`t:Remedy.Consumer.voice_ready/0` event can be used by the bot to begin playing audio as soon
as it is able to. The alternative approach for this use case that is not event-driven is to
periodically call `Remedy.Voice.ready?/1` and wait for it to return `true` as the trigger to
begin playing. Another common approach is to define a `try_play` function as follows:
```elixir
def try_play(guild_id, url, type, opts \\ []) do
  case Remedy.Voice.play(guild_id, url, type, opts) do
    {:error, _msg} ->
      Process.sleep(100)
      try_play(guild_id, url, type, opts)

    _ ->
      :ok
  end
end
```
Note that the third element in the event is of type `t:Remedy.Struct.VoiceWSState.t/0` and
not `t:Remedy.Struct.WSState.t/0`.
