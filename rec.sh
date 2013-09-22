#!/bin/sh

# Check parameter
if [ $# -ne 2 ]; then
  echo "usage: rec.sh TIME[sec] CHANNEL"
  exit 1
fi

# Parameter Setting
HOME_DIR=/home/endou/radio
TIME=$1
CHANNEL=$2
DATE=`date '+%Y%m%d-%H%M'`
OUTPUT_FLV=$HOME_DIR/output$DATE.flv
OUTPUT_MP3=$HOME_DIR/output$DATE.mp3

# Recording stream of radiko
#/usr/local/bin/rtmpdump --rtmp rtmpe://radiko.smartstream.ne.jp/ \
# --port 1935 \
# --app $CHANNEL/_defInst_ \
# --playpath simul-stream \
# --swfUrl http://radiko-dl.ssdl1.smartstream.ne.jp/radiko-dl/1.1/player/player_0.1.2.swf \
# --pageUrl http://radiko.jp/player/player.html#$CHANNEL \
# --flashVer "LNX 10,0,45,2" \
# --live \
# --stop $TIME \
# --flv $OUTPUT_FLV

# Record .flv by swftools
sh $HOME_DIR/swfrec.sh $CHANNEL $OUTPUT_FLV $TIME
# retry
if [ $? -ne 0 ] ; then
    echo "++++++++++++++++ retry 1 start ++++++++++++++"
    sh $HOME_DIR/swfrec.sh $CHANNEL $OUTPUT_FLV $TIME
    echo "++++++++++++++++ retry 1 end   ++++++++++++++"
fi

# Convert FLV to MP3
/usr/bin/ffmpeg -y -i $OUTPUT_FLV -ac 1 -ab 32 $OUTPUT_MP3

# rm FLV file if both FLV and MP3 exists
if [ -f $OUTPUT_FLV -a -f $OUTPUT_MP3 ]; then
  rm $OUTPUT_FLV
fi

# cp MP3 file to /var/www/html/radio
mv $OUTPUT_MP3 /var/www/html/radio
