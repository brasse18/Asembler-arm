USER=pi
HOST=raspberrypi
MODULE=counter
PASSWD=raspberry
DIR=interrupt
LINES=10
GPIO=10

all: upload build enable

getirq: upload
	@ssh ${HOST} 'cd ${DIR}; sudo insmod check_irq.ko gpio=${GPIO}; sudo rmmod check_irq'
	make LINES=2 grablogs

upload:
	scp -r ${DIR} ${HOST}:

build:
	ssh ${HOST} 'cd ${DIR}; make clean; sudo make all'

enable:
	ssh ${HOST} 'cd ${DIR}; sudo insmod bin/${MODULE}.ko'

grablogs:
	ssh ${HOST} 'tail -n${LINES} /var/log/kern.log'

clean:
	ssh ${HOST} 'rm -r ${DIR}'

disable:
	ssh ${HOST} 'sudo rmmod ${MODULE}'
