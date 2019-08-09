#!/bin/bash
PATH=/opt/python/python3.6.7/bin:$PATH
LD_LIBRARY_PATH="/opt/python/python3.6.7/lib"
export PATH LD_LIBRARY_PATH
jupyterhub --config /jupyterhub_config.py 2>&1 > jupyterhub.log&
exit 0