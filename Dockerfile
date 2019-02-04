FROM ubuntu:xenial

RUN apt-get update && apt-get install -y software-properties-common
RUN add-apt-repository ppa:attente/test && apt-get update && apt-get -y install bubblewrap subversion multiarch-support binutils
RUN svn checkout --trust-server-cert https://svn.webkit.org/repository/webkit/trunk WebKit
WORKDIR /WebKit
RUN sed -i 's/apt-get install/apt-get install -y/' Tools/gtk/install-dependencies
RUN Tools/gtk/install-dependencies --help
RUN groupadd -g 999 appuser && \
    useradd -r -u 999 -g appuser appuser
RUN chmod 777 /WebKit/ 
RUN mkdir /home/appuser
RUN chmod 777 /home/appuser
USER appuser
RUN Tools/Scripts/update-webkitgtk-libs
USER root
RUN apt-get update && \
    apt-get install build-essential software-properties-common -y && \
    add-apt-repository ppa:ubuntu-toolchain-r/test -y && \
    apt-get update && \
    apt-get install gcc-6 g++-6 -y && \
    update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 60 --slave /usr/bin/g++ g++ /usr/bin/g++-6
RUN apt-get install -y wget && wget http://security.ubuntu.com/ubuntu/pool/main/b/bubblewrap/bubblewrap_0.3.1-2_amd64.deb && apt install -y ./bubblewrap_0.3.1-2_amd64.deb

RUN wget https://github.com/Kitware/CMake/releases/download/v3.13.0/cmake-3.13.0-Linux-x86_64.tar.gz && \
    tar xf cmake-3.13.0-Linux-x86_64.tar.gz && \
    export PATH="`pwd`/cmake-3.13.0-Linux-x86_64/bin:$PATH" 

RUN sed -i 's/0.3.1/0.0.0/g' Source/cmake/OptionsGTK.cmake 
RUN cat Source/cmake/OptionsGTK.cmake
USER appuser
RUN export PATH="`pwd`/cmake-3.13.0-Linux-x86_64/bin:$PATH" && Tools/Scripts/build-webkit --gtk --debug

