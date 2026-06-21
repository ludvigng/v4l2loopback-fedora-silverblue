ARG FEDORA_VERSION=44
FROM registry.fedoraproject.org/fedora:$FEDORA_VERSION as v4l2loopback_git
WORKDIR workdir
RUN dnf install git -y
RUN git clone https://github.com/umlaeute/v4l2loopback
RUN cd v4l2loopback
FROM registry.fedoraproject.org/fedora:$FEDORA_VERSION
WORKDIR workdir
VOLUME ["/build"]
RUN dnf update -y
RUN dnf install kernel-devel kernel-modules-internal-`uname -r` kernel-devel-`uname -r` awk  -y
COPY --from=v4l2loopback_git workdir/v4l2loopback ./
RUN make clean
RUN make
RUN if [ -f build/v4l2loopback.priv ]; then /usr/src/kernels/`uname -r`/scripts/sign-file sha256 build/v4l2loopback.priv build/v4l2loopback.cer v4l2loopback.ko; else echo "No certificate found, can't sign module with secure boot key"; fi
RUN rm -rf ./build/v4l2loopback
RUN mkdir -p ./build/v4l2loopback
RUN cp ./v4l2loopback.ko ./build/v4l2loopback
