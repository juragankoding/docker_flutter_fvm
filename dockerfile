FROM openjdk:11-jdk

ENV ANDROID_HOME="${PWD}/android-home"
ENV FLUTTER_HOME='/opt/flutter'
ENV FLUTTER_VERSION="3.7.4"
ENV ANDROID_COMPILE_SDK="29"
ENV ANDROID_BUILD_TOOLS="33.0.0"
ENV ANDROID_SDK_TOOLS="6514223"
ENV PATH=$PATH:${ANDROID_HOME}/cmdline-tools/tools/bin/:"$HOME/.pub-cache/bin":$FLUTTER_HOME

SHELL ["/bin/bash", "-c"] 

RUN echo "PATH=$PATH:${ANDROID_HOME}/cmdline-tools/tools/bin/:$HOME/.pub-cache/bin:$FLUTTER_HOME" >> /etc/bash.bashrc

RUN apt-get --quiet update --yes && \
 apt-get --quiet install --yes wget tar unzip tree && \
 apt-get install clang cmake ninja-build pkg-config libgtk-3-dev -y

RUN apt-get update && \
 apt-get install apt-transport-https && \
 wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg && \
 echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | tee /etc/apt/sources.list.d/dart_stable.list && \
 apt-get update && \
 apt-get install dart

RUN install -d $ANDROID_HOME && \
 wget --output-document=$ANDROID_HOME/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip && \
 unzip -o ${ANDROID_HOME}/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools

RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses || true && \
    sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-${ANDROID_COMPILE_SDK}" && \
    sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" && \
    sdkmanager --sdk_root=${ANDROID_HOME} --install "cmdline-tools;latest" && \
    sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS}"

RUN wget --output-document=/opt/flutter.tar.xz https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_${FLUTTER_VERSION}-stable.tar.xz && \
 mkdir $FLUTTER_HOME && \
 tar -xvf /opt/flutter.tar.xz -C $FLUTTER_HOME

RUN dart pub global activate fvm && \
 export PATH="$PATH":"$HOME/.pub-cache/bin" && \
 mkdir -p ${PWD}/.fvm_flutter && \
 fvm config --cache-path ${PWD}/.fvm_flutter