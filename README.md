docker-zotonic
==============

Run Zotonic inside Docker

Build
=====
Before running for first time or whenever the Dockerfile changes, run ```build```

Shell
=====
To launch a new container and run a shell in it, run ```shell```.

Add Site
========
From inside the shell
1. ```supervisord``` to start Postgres and Zotonic.
2. Make sure Zotonic is running using ```/zotonic/bin/zotonic status```
3. Add site by running ```/zotonic/bin/zotonic addsite -s basesite $HOST```
4. Point your browser to http://$HOST:8000

Note ```$HOST``` was set by the ```shell``` script to the ```hostname``` of the host os.


