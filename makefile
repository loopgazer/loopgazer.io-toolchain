PIO_TOOLCHAINS=/home/${USER}/.platformio/packages
TOOLCHAIN_NAME=toolchain-gccarmnoneeabi@10.1.1
LIB_PATH=arm-none-eabi/lib
TARGET=${PIO_TOOLCHAINS}/${TOOLCHAIN_NAME}

INSTALL_SCRIPT=pio.py

.SILENT:

install.pio:
	echo "Fetching PlatformioIO installation script..."
	curl -fsSL "https://raw.githubusercontent.com/platformio/platformio-core-installer/master/get-platformio.py" -o "${INSTALL_SCRIPT}"
	echo "Installing PlatformIO..."
	python3 ${INSTALL_SCRIPT}
	rm -f ${INSTALL_SCRIPT}
	echo "Soft-linking binaries..."
	sudo ln -sf ~/.platformio/penv/bin/platformio /usr/local/bin/platformio
	sudo ln -sf ~/.platformio/penv/bin/pio /usr/local/bin/pio
	sudo ln -sf ~/.platformio/penv/bin/piodebuggdb /usr/local/bin/piodebuggdb

install.udev:
	echo "Retrieving PIO udev rule..."
	curl -fsSL https://raw.githubusercontent.com/platformio/platformio-core/master/scripts/99-platformio-udev.rules | sudo tee /etc/udev/rules.d/99-platformio-udev.rules

install.toolchain: wipe replicate fix

install.all: install.pio install.udev install.toolchain

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
	echo Adding PIO PM manifest...
	cp .piopm ${TARGET}/.piopm

fix:
	echo Copying Cortex-Mx math libraries...
	cp ./addons/** ${TARGET}/${LIB_PATH}
