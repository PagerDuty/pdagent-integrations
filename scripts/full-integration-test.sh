# Usage: ./scripts/run-console.sh <ubuntu OR centos>

OS=$1
make build-${OS}
if [ $OS == "ubuntu" ]
then
    docker stop pdagent-integrations-ubuntu
    docker rm pdagent-integrations-ubuntu
    docker run --name pdagent-integrations-ubuntu  -d --privileged -v /sys/fs/cgroup:/sys/fs/cgroup:ro -it pdagent-integrations-ubuntu
elif [ $OS == 'centos' ]
then
    docker stop pdagent-integrations-centos
    docker rm pdagent-integrations-centos
    docker run -d --privileged=true --tmpfs /tmp --tmpfs /run -v /sys/fs/cgroup:/sys/fs/cgroup:ro -it pdagent-integrations-centos
fi

_PID=$(docker ps -q -f ancestor=pdagent-integrations-${OS})
docker exec $_PID /bin/bash /usr/share/pdagent-integrations/scripts/install.sh $OS

if [ -z $TEST_FILE ]
then
    docker exec $_PID /bin/bash /usr/share/pdagent-integrations/pdagenttestinteg/run-tests.sh 
else
    docker exec -it $_PID /bin/bash ./pdagenttestinteg/${TEST_FILE}
fi

