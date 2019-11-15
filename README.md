# BoCompute

Podstawowy kontener obliczeniowy (wykonawczy) klastra BlueOcean.

docker run -dt --rm --name bocompute -h $(hostname -f) --cpus $RDZENIE_BOCOMPUTE --memory $(echo ""$PAMIEC_BOCOMPUTE"G") --memory-swap $(echo ""$PAMIEC_BOCOMPUTE"G") --shm-size=$(df -h |grep /dev/shm | awk '{print $2}' | rev |cut -c 2- |rev | xargs -I{} expr {} - 1)g --device /dev/fuse -v /etc/aliases:/etc/aliases -v /etc/msmtprc:/etc/msmtprc --privileged -p 6445:6445 -p 8000:8000 -p 8081:8081 --net cluster_network --ip $(echo 10.0.0.$(hostname -i | cut -d "." -f4)) -v /opt/software/Blueocean/Configs/jupyterhub/jupyterhub_config.py:/var/run/jupyterhub/jupyterhub_config.py -e DEBUG=true bockpl/bocompute:bocompute
