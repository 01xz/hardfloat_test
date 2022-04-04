TARGET_LIST ?= div_tb sqrt_tb

SPECIALIZE_TYPE ?= RISCV

VCD_DIR ?= build

INC_DIR ?= ../HardFloat-1/source
SRC_DIR ?= ../HardFloat-1/source
TB_DIR  ?= testbench

IVERILOG := iverilog -I$(INC_DIR) -I$(SRC_DIR)/$(SPECIALIZE_TYPE)
VVP      := vvp
GTKWAVE  := gtkwave

vpath %.vi $(INC_DIR) $(SRC_DIR)/$(SPECIALIZE_TYPE)
vpath %.v $(TB_DIR) $(SRC_DIR) $(SRC_DIR)/$(SPECIALIZE_TYPE)

.PHONY: all
all: $(foreach target, $(TARGET_LIST), $(VCD_DIR)/$(target).vcd)

$(VCD_DIR)/%.vcd: $(VCD_DIR)/%.out
	@echo "# Building $@ ..."
	cd $(VCD_DIR); $(VVP) $(^F)

$(VCD_DIR)/%.out: %.v $(SRC_DIR)/*.v | $(VCD_DIR)
	@echo "# Building $@ ..."
	$(IVERILOG) -o $@ -s $* $^

$(VCD_DIR):
	@echo "# Creating $@ ..."
	mkdir -p $@

.PHONY: clean
clean:
	rm -rf $(VCD_DIR)
