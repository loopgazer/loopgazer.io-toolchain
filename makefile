PIO_TOOLCHAINS=/home/${USER}/.platformio/packages
TOOLCHAIN_NAME=toolchain-gccarmnoneeabi@10.1.1
TARGET=${PIO_TOOLCHAINS}/${TOOLCHAIN_NAME}

LIB_PATH=arm-none-eabi/lib

.SILENT:

install: wipe replicate fix

wipe:
	clear
	rm -rf ${TARGET}

replicate:
	echo Creating toolchain directory at ${TARGET}...
	mkdir -p ${TARGET}
	echo Copying original toolchain content...
	cp -rf ./src/** ${TARGET}
	echo Adding PIO toolchain manifest...
	cp package.json ${TARGET}/package.json

fix:
	echo Copying Cortex-Mx math libraries...
	cp ./addons/** ${TARGET}/${LIB_PATH}
