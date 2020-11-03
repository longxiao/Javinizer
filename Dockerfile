
FROM ghcr.io/linuxserver/baseimage-ubuntu:version-486889a0

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections
RUN apt-get update -y && apt-get install -y curl unrar wget software-properties-common apt-transport-https
RUN add-apt-repository multiverse
RUN mkdir /home/Universal
WORKDIR /home/Universal
RUN wget https://ftp.jeff-server.com/Universal.linux-x64.1.4.6.rar \
    && unrar x Universal.linux-x64.1.4.6.rar \
    && rm Universal.linux-x64.1.4.6.rar
RUN chmod +x /home/Universal/Universal.Server

RUN wget -q https://packages.microsoft.com/config/ubuntu/18.04/packages-microsoft-prod.deb && dpkg -i packages-microsoft-prod.deb && apt-get update
RUN add-apt-repository universe
RUN apt-get install -y powershell
RUN apt-get install -y mediainfo
RUN add-apt-repository -y ppa:deadsnakes/ppa
RUN apt-get update -y
RUN apt-get install -y python3.8 python3-pip
RUN update-alternatives --install /usr/bin/python3 python3 /usr/bin/python3.8 10
RUN pip3 install pillow googletrans
RUN apt-get install -y git

# Add custom UD components
RUN pwsh -Command "Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted"
RUN pwsh -Command "Install-Module UniversalDashboard.Style"

# Clone dev Javinizer branch
WORKDIR /home
RUN git clone -b dev https://github.com/jvlflame/Javinizer.git

RUN wget https://ftp.jeff-server.com/UniversalDashboard.CodeEditor.rar \
    && unrar x UniversalDashboard.CodeEditor.rar \
    && rm UniversalDashboard.CodeEditor.rar

EXPOSE 5000
VOLUME ["/appdata"]
ENV Data__RepositoryPath ./appdata/Repository
ENV Data__ConnectionString ./appdata/database.db
ENV UniversalDashboard__AssetsFolder ./appdata/UniversalDashboard
ENV Logging__Path ./appdata/logs/log.txt
ENTRYPOINT ["/home/Universal/Universal.Server"]
