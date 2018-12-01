# Pull base image.
FROM jlesage/baseimage-gui:alpine-3.8-glibc

# Define working directory.
WORKDIR /tmp

# Install xterm.
RUN apk --no-cache add \
	desktop-file-utils \
	adwaita-icon-theme \
	ttf-dejavu \
	unrar \
	unzip \
	tar \
	bzip2 \
	gzip \
	thunar \
	thunar-archive-plugin

# Maximize only the main/initial window.
# RUN \
#     sed-patch 's/<application type="normal">/<application type="normal" title="thunar">/' \
# 	/etc/xdg/openbox/rc.xml

# Generate and install favicons.
RUN \
    APP_ICON_URL=https://git.xfce.org/xfce/thunar/plain/icons/128x128/Thunar.png && \
	install_app_icon.sh "$APP_ICON_URL"

# Add files.
COPY rootfs/ /

# Set the name of the application.
ENV APP_NAME="thunar" \
	S6_KILL_GRACETIME=8000

# Define mountable directories.
VOLUME ["/config"]
VOLUME ["/mnt"]

# Metadata.
LABEL \
      org.label-schema.name="thunar" \
      org.label-schema.description="Docker container for thunar" \
      org.label-schema.version="unknown" \
      org.label-schema.vcs-url="https://github.com/shokinn/docker-thunar" \
	  org.label-schema.schema-version="1.0"