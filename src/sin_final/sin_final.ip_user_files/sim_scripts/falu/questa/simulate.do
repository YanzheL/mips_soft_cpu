onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib falu_opt

do {wave.do}

view wave
view structure
view signals

do {falu.udo}

run -all

quit -force
