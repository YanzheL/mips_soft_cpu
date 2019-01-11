onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fmult_opt

do {wave.do}

view wave
view structure
view signals

do {fmult.udo}

run -all

quit -force
