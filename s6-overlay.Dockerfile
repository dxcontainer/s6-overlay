ARG ALPINE_VERSION="latest"
FROM alpine:${ALPINE_VERSION} AS s6-overlay

RUN \
    apk add \
        --no-cache \
            xz

ARG S6_OVERLAY_VERSION

# This tarball contains the scripts implementing the overlay. We call it "noarch" because it is architecture- independent: it only contains scripts and other text files. Everyone 
# who wants to run s6-overlay needs to extract this tarball.
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz /tmp/s6-overlay-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-noarch.tar.xz.sha256 /tmp/s6-overlay-noarch.tar.xz.sha256

# This tarball contains all the necessary binaries from the s6 ecosystem, all linked statically and out of the way of your image's binaries. Unless you know for sure that your image 
# already comes with all the packages providing the binaries used in the overlay, you need to extract this tarball.
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz /tmp/s6-overlay-x86_64.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-x86_64.tar.xz.sha256 /tmp/s6-overlay-x86_64.tar.xz.sha256

ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz /tmp/s6-overlay-aarch64.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-aarch64.tar.xz.sha256 /tmp/s6-overlay-aarch64.tar.xz.sha256

# This tarball contains symlinks to the s6-overlay scripts so they are accessible via '/usr/bin'. It is normally not needed, all the scripts are accessible via the 'PATH' environment 
# variable, but if you have old user scripts containing shebangs such as '#!/usr/bin/with-contenv', installing these symlinks will make them work.
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz /tmp/s6-overlay-symlinks-noarch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-noarch.tar.xz.sha256 /tmp/s6-overlay-symlinks-noarch.tar.xz.sha256

# This tarball contains symlinks to the binaries from the s6 ecosystem provided by the second tarball, to make them accessible via '/usr/bin'. It is normally not needed, but if you have 
# old user scripts containing shebangs such as '#!/usr/bin/execlineb', installing these symlinks will make them work.
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz /tmp/s6-overlay-symlinks-arch.tar.xz
ADD https://github.com/just-containers/s6-overlay/releases/download/v${S6_OVERLAY_VERSION}/s6-overlay-symlinks-arch.tar.xz.sha256 /tmp/s6-overlay-symlinks-arch.tar.xz.sha256

RUN \
    cd \
        /tmp \
    && \
        sha256sum \
            -c \
                *.sha256

RUN \
    mkdir -p \
        /s6-overlay/s6-overlay-noarch \
        /s6-overlay/linux/amd64 \
        /s6-overlay/linux/arm64 \
        /s6-overlay/s6-overlay-symlinks-noarch \
        /s6-overlay/s6-overlay-symlinks-arch

RUN \
    tar \
        -x \
        -p \
        -f /tmp/s6-overlay-noarch.tar.xz \
        -C /s6-overlay/s6-overlay-noarch \
        -J

RUN \
    tar \
        -x \
        -p \
        -f /tmp/s6-overlay-x86_64.tar.xz \
        -C /s6-overlay/linux/amd64 \
        -J

RUN \
    tar \
        -x \
        -p \
        -f /tmp/s6-overlay-aarch64.tar.xz \
        -C /s6-overlay/linux/arm64 \
        -J

RUN \
    tar \
        -x \
        -p \
        -f /tmp/s6-overlay-symlinks-noarch.tar.xz \
        -C /s6-overlay/s6-overlay-symlinks-noarch \
        -J \
    && \
        unlink /s6-overlay/s6-overlay-symlinks-noarch/usr/bin/with-contenv

RUN \
    tar \
        -x \
        -p \
        -f /tmp/s6-overlay-symlinks-arch.tar.xz \
        -C /s6-overlay/s6-overlay-symlinks-arch \
        -J 

FROM scratch

COPY --from=s6-overlay /s6-overlay/ /s6-overlay/
COPY rootfs/ /s6-overlay-config/