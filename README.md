# BoCompute

Podstawowy kontener obliczeniowy (wykonawczy) klastra BlueOcean.

Zmienna srodowiskowa DEBUG=true wlacza opcje debuggowania w niektorych uruchamianych procesach min w monit.

docker run -dt --rm --name bocompute -h $(hostname -f) --cpus $RDZENIE_BOCOMPUTE --memory $(echo ""$PAMIEC_BOCOMPUTE"G") --memory-swap $(echo ""$PAMIEC_BOCOMPUTE"G") --shm-size=$(df -h |grep /dev/shm | awk '{print $2}' | rev |cut -c 2- |rev | xargs -I{} expr {} - 1)g -v /etc/aliases:/etc/aliases -v /etc/msmtprc:/etc/msmtprc -p 6445:6445 --net cluster_network --ip $(echo 10.0.0.$(hostname -i | cut -d "." -f4)) -e DEBUG=true bockpl/bocompute:bocompute
