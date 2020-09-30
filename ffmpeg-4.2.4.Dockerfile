FROM nvcr.io/nvidia/cuda:10.0-cudnn7-devel-ubuntu18.04
ENV cwd="/home/"
WORKDIR $cwd

RUN apt-get -y update

RUN apt-get install -y \
    software-properties-common \
    build-essential \
    checkinstall \
    cmake \
    pkg-config \
    yasm \
    git \
    vim \
    curl \
    wget \
    gfortran \
    sudo \
    apt-transport-https \
    libcanberra-gtk-module \
    libcanberra-gtk3-module \
    dbus-x11 \
    vlc \
    iputils-ping \
    python3-dev \
    python3-pip

# some image/media dependencies
RUN apt-get install -y \
    libjpeg8-dev \
    libpng-dev \
    libtiff5-dev \
    libtiff-dev \
    libavcodec-dev \
    libavformat-dev \
    libswscale-dev \
    libdc1394-22-dev \
    libxine2-dev

# dependencies for FFMPEG build
RUN apt-get install -y libchromaprint1 libchromaprint-dev frei0r-plugins-dev gnutls-bin ladspa-sdk libavc1394-0 libavc1394-dev libiec61883-0 libiec61883-dev libass-dev libbluray-dev libbs2b-dev libcaca-dev libgme-dev libgsm1-dev libopenmpt-dev libopus-dev libpulse-dev librsvg2-dev librubberband-dev libshine-dev libsnappy-dev libsoxr-dev libspeex-dev libtwolame-dev libvpx-dev libwavpack-dev libwebp-dev libx265-dev libx264-dev libzmq3-dev libzvbi-dev libopenal-dev libomxil-bellagio-dev libcdio-dev libcdio-paranoia-dev libsdl2-dev libmp3lame-dev libssh-dev libtheora-dev libxvidcore-dev

# Compiling NVIDIA Headers ("ffnvcodec")
# RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git &&\
#     cd nv-codec-headers &&\
#     make install &&\
#     cd .. && rm -r nv-codec-headers

RUN DEBIAN_FRONTEND=noninteractive apt-get install -y tzdata python3-tk
ENV TZ=Asia/Singapore
RUN ln -snf /usr/share/zoneinfo/$TZ /etc/localtime && echo $TZ > /etc/timezone

RUN apt-get clean && rm -rf /tmp/* /var/tmp/* /var/lib/apt/lists/* && apt-get -y autoremove

### APT END ###

RUN pip3 install --no-cache-dir --upgrade pip 

RUN pip3 install --no-cache-dir \
    setuptools==41.0.0 \
    protobuf==3.13.0 \
    numpy==1.15.4 \
    cryptography==2.3

RUN pip3 install --no-cache-dir --ignore-installed pyxdg==0.26

RUN pip3 install --no-cache-dir jupyter==1.0.0
RUN echo 'alias jup="jupyter notebook --allow-root --no-browser"' >> ~/.bashrc

RUN pip3 install --no-cache-dir \
    GPUtil==1.4.0 \
    tqdm==4.50.0 \
    requests==2.24.0 \
    python-dotenv==0.14.0

RUN pip3 install --no-cache-dir opencv-python==4.4.0.44

# Compiling NVIDIA Headers ("ffnvcodec")
RUN git clone https://git.videolan.org/git/ffmpeg/nv-codec-headers.git &&\
    cd nv-codec-headers &&\
    make install &&\
    cd .. && rm -r nv-codec-headers


# INSTALL FFMPEG
RUN git clone https://git.ffmpeg.org/ffmpeg.git &&\
    cd ffmpeg &&\
    git checkout n4.2.4 &&\
    ./configure --enable-cuda --enable-cuvid --enable-nvenc --enable-nvdec --enable-nonfree --enable-libnpp --extra-cflags="-I/usr/local/cuda/include -I/usr/local/include" --extra-ldflags=-L/usr/local/cuda/lib64 --prefix=/usr --extra-version=0ubuntu0.2 --toolchain=hardened --libdir=/usr/lib/x86_64-linux-gnu --incdir=/usr/include/x86_64-linux-gnu --enable-gpl --disable-stripping --enable-avisynth --enable-ladspa --enable-libass --enable-libbluray --enable-libbs2b --enable-libcaca --enable-libcdio --enable-libfontconfig --enable-libfreetype --enable-libfribidi --enable-libgme --enable-libgsm --enable-libmp3lame --enable-libopenmpt --enable-libopus --enable-libpulse --enable-librubberband --enable-librsvg --enable-libshine --enable-libsnappy --enable-libsoxr --enable-libspeex --enable-libssh --enable-libtheora --enable-libtwolame --enable-libvorbis --enable-libvpx --enable-libwavpack --enable-libwebp --enable-libx265 --enable-libxml2 --enable-libxvid --enable-libzmq --enable-libzvbi --enable-omx --enable-openal --enable-opengl --enable-sdl2 --enable-libdc1394 --enable-libdrm --enable-libiec61883 --enable-chromaprint --enable-frei0r --enable-libx264 --enable-shared &&\
    make -j11 &&\
    make install &&\
    cd .. && rm -r ffmpeg
RUN pip3 install --no-cache-dir ffmpeg-python 

ENV NVIDIA_VISIBLE_DEVICES all
ENV NVIDIA_DRIVER_CAPABILITIES video,compute,utility
