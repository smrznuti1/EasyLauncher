FROM ubuntu:22.04

RUN apt-get update && \
    apt-get install -y openjdk-17-jdk wget unzip git && \
    rm -rf /var/lib/apt/lists/*

ENV ANDROID_SDK_ROOT=/opt/android-sdk
ENV ANDROID_HOME=$ANDROID_SDK_ROOT
ENV PATH=$PATH:$ANDROID_SDK_ROOT/cmdline-tools/latest/bin:$ANDROID_SDK_ROOT/platform-tools

RUN mkdir -p $ANDROID_SDK_ROOT/cmdline-tools && \
    cd $ANDROID_SDK_ROOT/cmdline-tools && \
    wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip -O cmdline-tools.zip && \
    unzip cmdline-tools.zip && \
    rm cmdline-tools.zip && \
    mv cmdline-tools latest

RUN yes | $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager --licenses
RUN $ANDROID_SDK_ROOT/cmdline-tools/latest/bin/sdkmanager "platform-tools" "platforms;android-33" "build-tools;33.0.2"

WORKDIR /build

COPY . .
COPY ./known_hosts /root/.ssh/known_hosts

RUN echo "sdk.dir=$ANDROID_SDK_ROOT" > local.properties


RUN ./gradlew clean
RUN ./gradlew assembleWithoutInternetNightlyRelease


RUN $ANDROID_SDK_ROOT/build-tools/33.0.2/apksigner sign \
    --ks ./my-release-key.jks \
    --ks-key-alias my-key-alias \
    --ks-pass pass:thisismycreds \
    --key-pass pass:thisismycreds \
    --out app-release-signed.apk \
    /build/app/build/outputs/apk/withoutInternetNightly/release/app.easy.launcher_v0.3.3-Release.apk

RUN --mount=type=secret,id=myssh scp -i /run/secrets/myssh ./app-release-signed.apk mi17043@alas.matf.bg.ac.rs:/home/mi17043/public_html/Senatus_Populusque_Romanus/


