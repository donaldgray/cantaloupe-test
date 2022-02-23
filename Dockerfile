FROM ubuntu:latest

ENV JAVA_HOME=/opt/jdk
ENV PATH=$PATH:/opt/jdk/bin:/opt/maven/bin
ARG DEBIAN_FRONTEND=noninteractive

# Install various dependencies:
# * ca-certificates is needed by wget
# * ffmpeg is needed by FfmpegProcessor
# * wget download stuffs in this dockerfile
# * libopenjp2-tools is needed by OpenJpegProcessor
# * All the rest is needed by GrokProcessor
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    ffmpeg \
    wget \
    libopenjp2-tools \
    liblcms2-dev \
    libpng-dev \
    libzstd-dev \
    libtiff-dev \
    libjpeg-dev \
    zlib1g-dev \
    libwebp-dev \
    libimage-exiftool-perl \
    unzip \
    && rm -rf /var/lib/apt/lists/*

# Install various other dependencies that aren't in apt
# Install GrokProcessor dependencies
RUN wget -q https://github.com/GrokImageCompression/grok/releases/download/v7.6.5/libgrokj2k1_7.6.5-1_amd64.deb \
    && wget -q https://github.com/GrokImageCompression/grok/releases/download/v7.6.5/grokj2k-tools_7.6.5-1_amd64.deb \
    && dpkg -i ./libgrokj2k1_7.6.5-1_amd64.deb \
    && dpkg -i --ignore-depends=libjpeg62-turbo ./grokj2k-tools_7.6.5-1_amd64.deb \
    # Install OpenJDK
    && wget -q https://github.com/AdoptOpenJDK/openjdk16-binaries/releases/download/jdk-16.0.1%2B9/OpenJDK16U-jdk_x64_linux_hotspot_16.0.1_9.tar.gz \
    && tar xfz OpenJDK16U-jdk_x64_linux_hotspot_16.0.1_9.tar.gz \
    && mv jdk-16.0.1+9 /opt/jdk

# Install TurboJpegProcessor dependencies
RUN mkdir -p /opt/libjpeg-turbo/lib
COPY libjpeg /opt/libjpeg-turbo/lib

# A non-root user
RUN adduser --system cantaloupe

# Download Cantaloupe
RUN wget -q https://github.com/cantaloupe-project/cantaloupe/releases/download/v5.0.5/cantaloupe-5.0.5.zip \
    && unzip cantaloupe-5.0.5.zip \
    && rm cantaloupe-5.0.5.zip \
    && mkdir -p /cantaloupe \
    && cp cantaloupe-5.0.5/cantaloupe-5.0.5.jar /cantaloupe \
    && chown -R cantaloupe /cantaloupe

COPY cantaloupe.properties.docker /cantaloupe/cantaloupe.properties

USER cantaloupe
CMD ["sh", "-c", "java -Dcantaloupe.config=/cantaloupe/cantaloupe.properties -jar /cantaloupe/cantaloupe-5.0.5.jar"]
