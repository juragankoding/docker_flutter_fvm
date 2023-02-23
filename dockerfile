FROM openjdk:11-jdk

ENV ANDROID_HOME="${PWD}/android-home"
ENV ANDROID_COMPILE_SDK="29"
ENV ANDROID_BUILD_TOOLS="33.0.0"
ENV ANDROID_SDK_TOOLS="6514223"
ENV PATH=$PATH:${ANDROID_HOME}/cmdline-tools/tools/bin/

RUN apt-get --quiet update --yes && \
 apt-get --quiet install --yes wget tar unzip tree && \
 apt-get install clang cmake ninja-build pkg-config libgtk-3-dev -y

RUN install -d $ANDROID_HOME && \
 wget --output-document=$ANDROID_HOME/cmdline-tools.zip https://dl.google.com/android/repository/commandlinetools-linux-${ANDROID_SDK_TOOLS}_latest.zip && \
 unzip -o ${ANDROID_HOME}/cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools


# RUN pushd $ANDROID_HOME
# RUN popd
# RUN echo "export PATH=$PATH:${ANDROID_HOME}/cmdline-tools/tools/bin/" >> /etc/bash.bashrc

RUN yes | sdkmanager --sdk_root=${ANDROID_HOME} --licenses || true
RUN sdkmanager --sdk_root=${ANDROID_HOME} "platforms;android-${ANDROID_COMPILE_SDK}" && \
    sdkmanager --sdk_root=${ANDROID_HOME} "platform-tools" && \
    sdkmanager --sdk_root=${ANDROID_HOME} --install "cmdline-tools;latest" && \
    sdkmanager --sdk_root=${ANDROID_HOME} "build-tools;${ANDROID_BUILD_TOOLS}"

RUN apt-get update
RUN apt-get install apt-transport-https
RUN wget -qO- https://dl-ssl.google.com/linux/linux_signing_key.pub | gpg --dearmor -o /usr/share/keyrings/dart.gpg
RUN echo 'deb [signed-by=/usr/share/keyrings/dart.gpg arch=amd64] https://storage.googleapis.com/download.dartlang.org/linux/debian stable main' | tee /etc/apt/sources.list.d/dart_stable.list

RUN apt-get update
RUN apt-get install dart

RUN dart pub global activate fvm
RUN export PATH="$PATH":"$HOME/.pub-cache/bin"

RUN mkdir -p ${PWD}/.fvm_flutter
RUN fvm config --cache-path ${PWD}/.fvm_flutter
RUN fvm install
RUN fvm list
RUN fvm use --force