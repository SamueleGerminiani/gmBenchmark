# Requirements

- Linux
- Modelsim on the $PATH (vsim, vlog, vlib)

# How to run

Run the "runFaisal.sh" script in the "faisal" directory to simulate the faults and generate the vcd files in the output directory.

For example

```
cd arb2/harm/faisal/ && bash runFaisal.sh
```

The following scripts require the HARM tool (https://github.com/SamueleGerminiani/harm)

Run the "runHarm.sh" script to mine assertions using harm and perform fault coverage using the vcd files in the output directory

Run the "runGM.sh" script to perform fault coverage of the assertions stored in gmAssertions.txt (assertions mined using the goldminer tool) using the vcd files in the output directory

Warning: you may need to adjust the paths in the scripts
