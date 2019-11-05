FROM ubuntu:latest as mpd-builder
ENV BRANCH 0.21
ENV SUBVERSION 16
ENV VERSION ${BRANCH}.${SUBVERSION}
WORKDIR /usr/src/mpd/
RUN apt update && apt -y install g++ \
  libpcre3-dev \
  libmad0-dev libmpg123-dev libid3tag0-dev \
  libflac-dev libvorbis-dev libopus-dev \
  libadplug-dev libaudiofile-dev libsndfile1-dev libfaad-dev \
  libfluidsynth-dev libgme-dev libmikmod2-dev libmodplug-dev \
  libmpcdec-dev libwavpack-dev libwildmidi-dev \
  libsidplay2-dev libsidutils-dev libresid-builder-dev \
  libavcodec-dev libavformat-dev \
  libmp3lame-dev libtwolame-dev libshine-dev \
  libsamplerate0-dev libsoxr-dev \
  libbz2-dev libcdio-paranoia-dev libiso9660-dev libmms-dev \
  libzzip-dev \
  libcurl4-gnutls-dev libyajl-dev libexpat-dev \
  libasound2-dev libao-dev libjack-jackd2-dev libopenal-dev \
  libpulse-dev libshout3-dev \
  libsndio-dev \
  libmpdclient-dev \
  libnfs-dev libsmbclient-dev \
  libupnp-dev \
  libavahi-client-dev \
  libsqlite3-dev \
  libsystemd-dev \
  libgtest-dev \
  libboost-dev \
  libicu-dev \
  wget \
  python3-pip

RUN  pip3 install meson && apt install ninja-build && \
     wget http://www.musicpd.org/download/mpd/${BRANCH}/mpd-${VERSION}.tar.xz && \
     tar xf mpd-${VERSION}.tar.xz
RUN  cd mpd-${VERSION} && \
     /usr/local/bin/meson . output/release --buildtype=debugoptimized -Db_ndebug=true && \
   ninja -C output/release

FROM ubuntu:latest as mpd
WORKDIR /usr/local/bin
ENV BRANCH 0.21
ENV SUBVERSION 16
ENV VERSION ${BRANCH}.${SUBVERSION}
COPY --from=mpd-builder /usr/src/mpd/mpd-${VERSION}/output/release/mpd .
RUN useradd mpd && mkdir -p /run/mpd && mkdir -p /var/lib/mpd && chown mpd:mpd -R /var/lib/mpd && chown mpd:mpd -R /run/mpd  
RUN apt update && apt -y --no-install-recommends install libzzip-0-13 libavahi-client3 libsqlite3-0 libshine3 libmpdclient2 libpulse0 libopus0 libiso9660-10 libtwolame0 libmp3lame0 libwildmidi2 libwavpack1 libresid-builder0c2a libsidutils0 libmpg123-0 libmpcdec6 libmodplug1 libmikmod3 libmad0 libgme0 libfaad2 libaudiofile1 libfluidsynth1 libadplug-2.2.1-0v5 libshout3 libao4 libid3tag0 libsoxr0 libyajl2 libnfs11 libmms0 libsmbclient libupnp6 libavutil55 libavcodec57 libavformat57 libcurl4 libcurl3-gnutls libcdio-paranoia2 libcdio-cdda2 
RUN rm -rf /var/lib/apt/lists/*

EXPOSE 6600

CMD ["./mpd", "--stdout", "--no-daemon"]
