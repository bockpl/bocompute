# BoCompute

Podstawowy kontener obliczeniowy (wykonawczy) klastra BlueOcean.

Zmienna srodowiskowa DEBUG=true wlacza opcje debuggowania w niektorych uruchamianych procesach min w monit.

docker run -dt --rm --name bocompute -h ${HOSTNAME} --cpus ${CPUS} --memory ${MEMORY} --memory-swap ${MEMORY-SWAP} --shm-size=${SHM-SIZE} -v /etc/aliases:/etc/aliases -v /etc/msmtprc:/etc/msmtprc -p 6445:6445 --net cluster_network --ip $(echo 10.0.0.$(hostname -i | cut -d "." -f4)) -e DEBUG=true bockpl/bocompute:bocompute
