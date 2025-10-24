FROM photoprism/photoprism:250707

ARG PROXY
ENV http_proxy=$PROXY
ENV https_proxy=$PROXY

# see https://github.com/photoprism/photoprism/blob/develop/scripts/dist/Makefile
RUN make -C /scripts/ update
RUN make -C /scripts/ ffmpeg
RUN make -C /scripts/ tensorflow
RUN make -C /scripts/ clean
