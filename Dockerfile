FROM bitriseio/android-ndk
MAINTAINER Zachary Carter "carterza@gmail.com"


# Set the env variable DEBIAN_FRONTEND to noninteractive
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update --yes && apt-get install --yes \
  automake \
  autogen \
  bash \
  build-essential \
  git \
  freeglut3-dev \
  libopenal1 libopenal-dev \
  libc6-dev-i386 \
  libsdl2-dev \
  libsdl2-image-dev \
  mercurial && \
apt-get clean --yes

RUN git clone https://github.com/nim-lang/Nim.git /Nim && cd /Nim && \
    git clone --depth 1 https://github.com/nim-lang/csources.git && \
    cd csources && sh build.sh && cd ../ && bin/nim c koch && ./koch boot -d:release

RUN cd /Nim && ./koch nimble

ENV PATH=${PATH}:/Nim/bin

RUN git clone https://github.com/fragworks/frag.git && cd frag && git submodule update --init vendor/bx vendor/bgfx/ vendor/bimg

RUN cd frag && git submodule update --init vendor/bx vendor/bgfx/ vendor/bimg

RUN cd frag/vendor/bgfx && ../bx/tools/bin/linux/genie --with-shared-lib --gcc=android-arm gmake

ENV ANDROID_NDK_ROOT=${ANDROID_NDK_HOME}
ENV ANDROID_NDK_CLANG=${ANDROID_NDK_ROOT}/toolchains/llvm/prebuilt/linux-x86_64/
ENV ANDROID_NDK_ARM=${ANDROID_NDK_ROOT}/toolchains/arm-linux-androideabi-4.9/prebuilt/linux-x86_64/

RUN cd frag/vendor/bgfx/.build/projects/gmake-android-arm && make config=release32 bgfx-shared-lib

RUN cd frag && nimble install -y

COPY platforms/android/examples /examples
COPY platforms/android/app /app

RUN cp frag/vendor/bgfx/.build/android-arm/bin/libbgfx-shared-libRelease.so /app/src/main/jni/src/libbgfx-shared-libRelease.so

RUN cd /examples && nim c 00-hello-world/main.nim

RUN mkdir /out

RUN ${ANDROID_NDK_HOME}/ndk-build NDK_PROJECT_PATH=/app/src/main NDK_LIBS_OUT=/out

CMD cp -r /out/** /app/src/main/jniLibs && cp ${ANDROID_NDK_HOME}/sources/cxx-stl/llvm-libc++/libs/armeabi-v7a/libc++_shared.so /app/src/main/jniLibs/armeabi-v7a