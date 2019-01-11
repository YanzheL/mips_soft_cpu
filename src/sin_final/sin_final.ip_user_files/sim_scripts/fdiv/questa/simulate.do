onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fdiv_opt

do {wave.do}

view wave
view structure
view signals

do {fdiv.udo}

run -all

quit -force
