FROM ubuntu:focal
ENV DEBIAN_FRONTEND noninteractive

# Install necessary library
WORKDIR /root
RUN apt update && apt upgrade -y && apt install --assume-yes software-properties-common git cmake g++ zlib* wget libssl1* libssl-dev -y

WORKDIR /root
RUN git clone https://github.com/LuongTanDat/licensepp-openssl.git
WORKDIR /root/licensepp-openssl
RUN cd /root/licensepp-openssl/3rdparty/cryptopp && make -j$(nproc) && make install && cd /root/licensepp-openssl/3rdparty/licensepp && mkdir -p build && cd /root/licensepp-openssl/3rdparty/licensepp/build && cmake .. && make -j$(nproc) && make install && cd /root/licensepp-openssl/3rdparty/ripe && mkdir -p build && cd /root/licensepp-openssl/3rdparty/ripe/build && cmake .. && make -j$(nproc) && make install

# install boost
WORKDIR /root
RUN wget https://boostorg.jfrog.io/artifactory/main/release/1.77.0/source/boost_1_77_0.tar.gz -O /root/boost_1_77_0.tar.gz && apt install --assume-yes build-essential autotools-dev libicu-dev build-essential libbz2-dev libboost-all-dev && tar -xvzf boost_1_77_0.tar.gz && cd /root/boost_1_77_0 && ./bootstrap.sh --prefix=/usr/ --with-libraries=python && ./b2 --with=all -j$(nproc) install

WORKDIR /root
RUN rm -rf boost_*

WORKDIR /root
RUN echo "export LD_LIBRARY_PATH=/usr/local/lib:\$LD_LIBRARY_PATH" | tee -a ~/.bashrc
# RUN apt install libssl1* libssl-dev -y

WORKDIR /root/licensepp-openssl/build
RUN export LD_LIBRARY_PATH=/usr/local/lib && cmake .. && make -j$(nproc)

EXPOSE 6262
WORKDIR /root/licensepp-openssl/build
CMD ["./licensepp-openssl-crow", "6262"]