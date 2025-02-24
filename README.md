# cmake-arduino

This project is a template for creating Arduino projects using CMake, using the MiniCore library.

> Arduino IDE does not need to be installed.

## Requirements

> Debian packages

- git
- cmake
- gcc-avr 
- binutils-avr 
- avr-libc 
- gdb-avr 
- avrdude (optionally)
- minipro (optionally)


### Compatibility

MiniCore expects that you just have an AVR microcontroller.
> The list of microcontrollers is available in the README for [MCUdude/MiniCore](https://github.com/MCUdude/MiniCore?tab=readme-ov-file#supported-microcontrollers)

## Quickstart

### Clone the repository

```bash
cd ~
git clone https://github.com/camratchford/cmake-arduino.git
cd cmake-arduino
```

### Installing third-party libraries

Third-party libraries include:
- [MCUdude/MiniCore](https://github.com/MCUdude/MiniCore)
- [adafruit/Adafruit_BusIO](https://github.com/adafruit/Adafruit_BusIO)
- [mathertel/RotaryEncoder](https://github.com/mathertel/RotaryEncoder)

A script at the root of this directory called `clone-third-party.sh` was made for convenience.

```bash
./clone-third-party.sh
```

### Optional - Installing avrdude programming tool

> Supported programmers are listed [here](https://avrdudes.github.io/avrdude/7.1/avrdude_3.html#index-Programmer-support).

```bash
sudo apt install avrdude
```

### (Optional) - Installing minipro programmer tool
Only the older XGecu models are supported and are easy to procure.

Supported programmers are listed below:

- TL866CS
- TL866A
- TL866II+

```bash
pushd ~ > /dev/null
git clone https://gitlab.com/DavidGriffith/minipro.git
cd minipro
make
sudo make install
sudo cp udev/*.rules /etc/udev/rules.d/
sudo udevadm trigger
sudo usermod -a -G plugdev $(logname)
sudo cp bash_completion.d/minipro /etc/bash_completion.d/
sudo cp man/minipro.1 /usr/local/share/man/man1
popd > /dev/null
```

### Edit the `cmake/definitions.cmake` file

Edit the `CMakeLists.txt` file to match your project's settings.

Variables that need to be set are:

| cmake variable        | description                                                     | default        |
|-----------------------|-----------------------------------------------------------------|----------------|
| `CMAKE_PROJECT_NAME`  | The name of the project                                         | cmake_arduino  |
| `AVR_MCU`             | The model of AVR microcontroller you're using                   | atmega328p     |
| `AVR_FREQ`            | The frequency of the AVR microcontroller in Hz                  | 8000000L       |
| `AVR_BAUD_RATE`       | The frequency to set the Serial device to                       | 19200          |
| `AVR_UPLOADTOOL`      | The software used to configure and upload the AVR chip          | avrdude        |
| `AVR_PROGRAMMER`      | The model of programmer that the `AVR_UPLOADTOOL` should see    | arduino        |
| `AVR_UPLOADTOOL_PORT` | The serial port that the `AVR_UPLOADTOOL` device is attached to | /dev/ttyUSB0   |
| `AVR_L_FUSE`          | The value of the low-byte fuses                                 | 0xC2           |
| `AVR_H_FUSE`          | The value of the high-byte fuses                                | 0xd9           |
| `AVR_E_FUSE`          | The value of the extended fuses                                 | 0xff           |
| `AVR_L_FUSE`          | The value of the lockbit fuses                                  | 0xff           |

> The default fuse values can be viewed [here](https://eleccelerator.com/fusecalc/fusecalc.php?chip=atmega328p&LOW=C2&HIGH=D9&EXTENDED=FF&LOCKBIT=FF) <br>
> Set to use the internal oscillator at 8MHz by default.
 
### Run the test program

```bash
mkdir -p build
cd build 
cmake ..
make
```

### Setting the fuses

```bash
make set_fuses
```


### Uploading the program

```bash
# if you change the variable CMAKE_PROJECT_NAME in CMakeLists.txt (default is 'cmake_arduino'), 
# you must also change the target name here.
make upload_cmake_arduino
```


