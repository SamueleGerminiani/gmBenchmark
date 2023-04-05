#!/bin/bash

iverilog -g2001 -osimv -s ibex_id_stage_bench /home/sam/goldminer/RunTime/goldmine.out/ibex_id_stage/ibex_id_stage_bench.v /home/sam/goldminer/verilog/IBex/ibex_id_stage.v /home/sam/goldminer/verilog/IBex/ibex_decoder.v /home/sam/goldminer/verilog/IBex/ibex_controller.v /home/sam/goldminer/verilog/IBex/ibex_register_file_ff.v  -I/home/sam/goldminer/verilog/IBex