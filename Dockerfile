FROM rockylinux:8 AS builder

WORKDIR /build

COPY ./OpenVSP_3.44.2.tar.gz /build/OpenVSP_3.44.2.tar.gz
COPY ./v4.1.1.tar.gz /build/swig-4.1.1.tar.gz

RUN dnf update -y && \
    dnf groupinstall -y "Development Tools" && \
    dnf install -y epel-release && dnf config-manager --set-enabled powertools && dnf update -y && \
    dnf install -y wget cmake gcc-c++ libxml2-devel openjpeg2-devel python3-devel glm-devel rpm-build glew-devel swig doxygen graphviz texlive-scheme-basic gcc-toolset-12

RUN wget https://github.com/PhilipHazel/pcre2/releases/download/pcre2-10.42/pcre2-10.42.tar.gz && \
    tar -xzf pcre2-10.42.tar.gz && \
    cd pcre2-10.42 && \
    ./configure --prefix=/usr/local && \
    make -j$(nproc) && make install


ENV PATH=/opt/rh/gcc-toolset-12/root/usr/bin:$PATH \
    LD_LIBRARY_PATH=/opt/rh/gcc-toolset-12/root/usr/lib64:$LD_LIBRARY_PATH \
    MANPATH=/opt/rh/gcc-toolset-12/root/usr/share/man:$MANPATH \
    PKG_CONFIG_PATH=/opt/rh/gcc-toolset-12/root/usr/lib64/pkgconfig:$PKG_CONFIG_PATH \
    BUILD_HOME=/build

RUN tar -xzf swig-4.1.1.tar.gz && cd swig-4.1.1 &&  ./autogen.sh && ./configure --prefix=/usr/local && \
    make -j$(nproc) && make install

RUN cd /build && tar --no-same-owner -xzf OpenVSP_3.44.2.tar.gz && \
    cd /build/OpenVSP-OpenVSP_3.44.2/ &&  mkdir buildlibs &&  cd buildlibs && \
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DCMAKE_USE_SYSTEM_LIBXML2=true \
        -DCMAKE_USE_SYSTEM_FLTK=false \
        -DCMAKE_USE_SYSTEM_GLM=true \
        -DCMAKE_USE_SYSTEM_GLEW=true \
        -DCMAKE_USE_SYSTEM_CMINPACK=false \
        -DCMAKE_USE_SYSTEM_CPPTEST=false \
        ../Libraries && make -j$(nproc) 

RUN cd /build/OpenVSP-OpenVSP_3.44.2/ &&  mkdir build && cd build && \
    cmake -DCMAKE_BUILD_TYPE=Release \
        -DVSP_CPACK_GEN=RPM \
	    -DCMAKE_EXE_LINKER_FLAGS="-lstdc++fs" \
	    -DCMAKE_SHARED_LINKER_FLAGS="-lstdc++fs" \
	    -DVSP_LIBRARY_PATH=/build/OpenVSP-OpenVSP_3.44.2/buildlibs \
        ../src && make -j$(nproc) package


FROM scratch AS output

COPY --from=builder /build/OpenVSP-OpenVSP_3.44.2/build/OpenVSP-3.44.2-Linux.rpm /OpenVSP-3.44.2-Linux.rpm

CMD ["/bin/true"]
