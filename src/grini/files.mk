# location of grini src
SRC_GRINI_PREFIX						:= $(SRC_PREFIX)grini/

# this file
GRINI_MKF								:= $(SRC_GRINI_PREFIX)files.mk

# end products, binary, executable, etc
GRINI_EXEC_NAME							:= grini
GRINI_BLD_EXEC							:= $(EHC_BIN_VARIANT_PREFIX)$(GRINI_EXEC_NAME)$(EXEC_SUFFIX)
GRINI_ALL_PUB_EXECS						:= $(patsubst %,$(EHC_BIN_PREFIX)%/$(GRINI_EXEC_NAME)$(EXEC_SUFFIX),$(GRIN_PUB_VARIANTS))
GRINI_ALL_EXECS							:= $(patsubst %,$(EHC_BIN_PREFIX)%/$(GRINI_EXEC_NAME)$(EXEC_SUFFIX),$(GRIN_VARIANTS))

# main + sources + dpds, for .chs
GRINI_MAIN								:= GRINI
GRINI_HS_MAIN_SRC_CHS					:= $(patsubst %,$(SRC_GRINI_PREFIX)%.chs,$(GRINI_MAIN))
GRINI_HS_MAIN_DRV_HS					:= $(patsubst $(SRC_GRINI_PREFIX)%.chs,$(EHC_BLD_VARIANT_PREFIX)%.hs,$(GRINI_HS_MAIN_SRC_CHS))

GRINI_HS_UTIL_SRC_CHS					:= $(patsubst %,$(SRC_GRINI_PREFIX)%.chs,GRINICommon GRINIRun)
GRINI_HS_UTIL_DRV_HS					:= $(patsubst $(SRC_GRINI_PREFIX)%.chs,$(EHC_BLD_VARIANT_PREFIX)%.hs,$(GRINI_HS_UTIL_SRC_CHS))

GRINI_HS_ALL_SRC_CHS					:= $(GRINI_HS_MAIN_SRC_CHS) $(GRINI_HS_UTIL_SRC_CHS)
GRINI_HS_ALL_DRV_HS						:= $(GRINI_HS_MAIN_DRV_HS) $(GRINI_HS_UTIL_DRV_HS)

# main + sources + dpds, for .cag
GRINI_AGSETUP_MAIN_SRC_CAG				:= $(patsubst %,$(SRC_GRINI_PREFIX)%.cag,GRINISetup)

GRINI_AG_S_MAIN_SRC_CAG					:= $(GRINI_AGSETUP_MAIN_SRC_CAG)
GRINI_AG_ALL_MAIN_SRC_CAG				:= $(GRINI_AG_S_MAIN_SRC_CAG)

# all src
GRINI_ALL_SRC							:= $(GRINI_AG_ALL_MAIN_SRC_CAG) $(GRINI_AG_ALL_DPDS_SRC_CAG) $(GRINI_HS_ALL_SRC_CHS)

# derived
GRINI_AG_S_MAIN_DRV_AG					:= $(patsubst $(SRC_GRINI_PREFIX)%.cag,$(EHC_BLD_VARIANT_PREFIX)%.ag,$(GRINI_AG_S_MAIN_SRC_CAG))
GRINI_AG_ALL_MAIN_DRV_AG				:= $(GRINI_AG_S_MAIN_DRV_AG)

GRINI_AG_S_MAIN_DRV_HS					:= $(GRINI_AG_S_MAIN_DRV_AG:.ag=.hs)
GRINI_AG_ALL_MAIN_DRV_HS				:= $(GRINI_AG_S_MAIN_DRV_HS)

# distribution
GRINI_DIST_FILES						:= $(GRINI_ALL_SRC) $(GRINI_MKF)

# variant dispatch rules
$(patsubst $(BIN_PREFIX)%$(EXEC_SUFFIX),%,$(GRINI_ALL_EXECS)): %: $(BIN_PREFIX)%$(EXEC_SUFFIX)

$(GRINI_ALL_EXECS): $(EHC_BIN_PREFIX)%/$(GRINI_EXEC_NAME)$(EXEC_SUFFIX): $(GRINI_ALL_SRC)
	$(MAKE) lib-eh-$*
	$(MAKE) EHC_VARIANT=$* grini-variant-$*

# rules
$(patsubst %,grini-variant-%,$(GRIN_VARIANTS)): grini-variant-dflt

grini-variant-dflt: $(GRINI_HS_ALL_DRV_HS) $(GRINI_AG_ALL_MAIN_DRV_HS) $(LIB_EH_UTIL_INS_FLAG) $(LIB_EHC_INS_FLAG)
	mkdir -p $(dir $(GRINI_BLD_EXEC))
	$(GHC) --make $(GHC_OPTS) $(GHC_OPTS_OPTIM) -package $(LIB_EH_UTIL_PKG_NAME) -package $(LIB_EHC_PKG_NAME) -i$(EHC_BLD_VARIANT_PREFIX) $(EHC_BLD_VARIANT_PREFIX)$(GRINI_MAIN).hs -o $(GRINI_BLD_EXEC)

$(GRINI_AG_ALL_MAIN_DRV_AG) $(GRINI_AG_ALL_DPDS_DRV_AG): $(EHC_BLD_VARIANT_PREFIX)%.ag: $(SRC_GRINI_PREFIX)%.cag $(SHUFFLE)
	mkdir -p $(@D)
	$(SHUFFLE_AG) $(LIB_EHC_SHUFFLE_DEFS) --gen-reqm="($(EHC_VARIANT) $(EHC_ASPECTS))" --base=$(*F) --variant-order="$(EHC_SHUFFLE_ORDER)" $< > $@

$(GRINI_AG_S_MAIN_DRV_HS): %.hs: %.ag
	$(AGC) -cfspr $(UUAGC_OPTS_WHEN_EHC) -P$(EHC_BLD_VARIANT_PREFIX) -P$(INS_EHC_LIB_AG_PREFIX) $<

$(GRINI_HS_MAIN_DRV_HS): $(EHC_BLD_VARIANT_PREFIX)%.hs: $(SRC_GRINI_PREFIX)%.chs $(SHUFFLE)
	mkdir -p $(@D)
	$(SHUFFLE_HS) $(LIB_EHC_SHUFFLE_DEFS) --gen-reqm="($(EHC_VARIANT) $(EHC_ASPECTS))" --base=Main --variant-order="$(EHC_SHUFFLE_ORDER)" $< > $@

$(GRINI_HS_UTIL_DRV_HS): $(EHC_BLD_VARIANT_PREFIX)%.hs: $(SRC_GRINI_PREFIX)%.chs $(SHUFFLE)
	mkdir -p $(@D)
	$(SHUFFLE_HS) $(LIB_EHC_SHUFFLE_DEFS) --gen-reqm="($(EHC_VARIANT) $(EHC_ASPECTS))" --base=$(*F) --variant-order="$(EHC_SHUFFLE_ORDER)" $< > $@

