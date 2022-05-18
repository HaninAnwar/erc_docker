FROM ghcr.io/europeanroverchallenge/erc-remote-image-base:latest
FROM osrf/ros:noetic-desktop
FROM ros:noetic-perception 

# install catkin tools
RUN apt-get update && apt-get -y upgrade && apt-get install -y \
	ros-noetic-catkin python3-catkin-tools \
	&& rm -rf /var/lib/apt/lists/*
# install git 
RUN apt-get update && \
    apt-get upgrade -y && \
    apt-get install -y git	
# install rtabmap packages
RUN apt-get update  && apt-get install -y \
    ros-noetic-rtabmap \
    ros-noetic-rtabmap-ros \
    && rm -rf /var/lib/apt/lists/*

RUN apt-get update && apt-get install -y \
    ros-noetic-navigation \
    && rm -rf /var/lib/apt/lists/*
    
# Install additional packages
RUN apt-get update && apt-get -y upgrade && apt-get -y install \
  tmux \
  && rm -rf /var/lib/apt/lists/*

# Copy packages and build the workspace
WORKDIR /sim_ws
COPY src ./src
RUN apt-get update \ 
  && rosdep update \
  && rosdep install --from-paths src -iy \
  && rm -rf /var/lib/apt/lists/*
RUN catkin config --extend /opt/ros/noetic && catkin build --no-status

# Automatically source the workspace when starting a bash session
RUN echo "source /sim_ws/devel/setup.bash" >> /etc/bash.bashrc

# Install start script
COPY ./start.sh /

CMD ["/start.sh"]

#git clone launch files package
#RUN git clone https://github.com/ERC-22/launch_packages.git
#ADD ssh-private-key /root/.ssh/id_rsa
#RUN git clone git@host:repo/ERC-22/launch_packages.git
RUN mkdir -p /root/.ssh/ && \
    echo "$SSH_KEY" > /root/.ssh/id_rsa && \
    chmod -R 600 /root/.ssh/ && \
    ssh-keyscan -t rsa github.com >> ~/.ssh/known_hosts

# Clone a repository (my website in this case)
#RUN git clone git@github.com:ERC-22/launch_packages.git
RUN git clone https://github.com/ERC-22/launch_packages.git



