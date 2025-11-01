# Use a base Ubuntu image
FROM ubuntu:24.04

# Avoid prompts from apt
ENV DEBIAN_FRONTEND=noninteractive
ENV USER="docker"

# Install necessary dependencies
RUN apt update && apt install -y curl wget git unzip xz-utils zip libglu1-mesa make jq

# Install add user with sudo
RUN apt update && apt install -y sudo
RUN adduser --disabled-password --gecos '' $USER
RUN adduser $USER sudo
RUN echo '%sudo ALL=(ALL) NOPASSWD:ALL' >> /etc/sudoers
USER $USER

# Install OpenJDK
RUN sudo apt-get install -y openjdk-21-jdk

# Install FVM
RUN cd ~/ && curl -fsSL https://fvm.app/install.sh | bash
# Add FVM to PATH
ENV PATH="/home/$USER/.pub-cache/bin:${PATH}"
# Add Flutter to PATH
ENV PATH="/home/$USER/fvm/default/bin:${PATH}"

COPY --chown=$USER:$USER .fvmrc /tmp/.fvmrc
RUN FLUTTER_VERSION=$(cat /tmp/.fvmrc | jq -r '.flutter') && fvm install $FLUTTER_VERSION && fvm global $FLUTTER_VERSION
RUN flutter --version
RUN flutter precache --android

# Set up Android SDK
ENV ANDROID_HOME=/opt/android-sdk
RUN sudo mkdir -p ${ANDROID_HOME}/cmdline-tools && \
    sudo wget -q https://dl.google.com/android/repository/commandlinetools-linux-8092744_latest.zip -O android-cmdline-tools.zip && \
    sudo unzip -q android-cmdline-tools.zip -d ${ANDROID_HOME}/cmdline-tools && \
    sudo mv ${ANDROID_HOME}/cmdline-tools/cmdline-tools ${ANDROID_HOME}/cmdline-tools/latest && \
    sudo rm android-cmdline-tools.zip

ENV PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${ANDROID_HOME}/platform-tools:${PATH}"
RUN sudo chown -R $USER /opt/android-sdk
RUN flutter config --android-sdk=/opt/android-sdk

# Accept licenses and install necessary Android SDK components
RUN yes | sdkmanager --licenses
RUN sdkmanager "platform-tools" "platforms;android-36" "build-tools;34.0.0" "ndk;27.0.12077973"

# Clean up existing app directory and copy the project
RUN sudo rm -rf /app
RUN sudo mkdir /app
RUN sudo chown -R $USER /app
COPY --chown=$USER:$USER . /app
WORKDIR /app

# Create .env (empty values)
RUN cp .env.example .env

RUN flutter pub get
RUN dart pub run build_runner build
RUN flutter build apk --release
