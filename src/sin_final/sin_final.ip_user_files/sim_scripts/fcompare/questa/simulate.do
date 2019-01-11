onbreak {quit -f}
onerror {quit -f}

vsim -t 1ps -lib xil_defaultlib fcompare_opt

do {wave.do}

view wave
view structure
view signals

do {fcompare.udo}

run -all

quit -force
