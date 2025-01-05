GODOT := godot
EXPECTED_GODOT_VERSION := 4.3

CERULEAN_PCK := cerulean.pck
TEST_LOG := test_log.txt
TEST_REPORT_XML := test_report.xml


GODOT_VERSION := $(shell $(GODOT) --version)
ifeq (,$(findstring $(EXPECTED_GODOT_VERSION),$(GODOT_VERSION)))
$(error Invalid godot version '$(GODOT_VERSION)', expected $(EXPECTED_GODOT_VERSION).[...]))
endif


$(CERULEAN_PCK):
	$(call godot_project_init)
	$(GODOT) --headless --export-pack Linux/X11 $@
.PHONY: $(CERULEAN_PCK)


test:
	$(call godot_project_init)
	$(GODOT) --headless --script addons/gut/gut_cmdln.gd -gdisable_colors -gjunit_xml_file=$(TEST_REPORT_XML) 2>&1 | tee $(TEST_LOG)
	$(GODOT) --headless --script src/test/util/test_report_verifier/verify_junit_test_report_xml.gd | grep -q JUNIT_TEST_REPORT_XML_VERIFIED_OK
	$(GODOT) --headless --script src/test/util/test_log_verifier/verify_test_log.gd | grep -q TEST_LOG_VERIFIED_OK
.PHONY: test


check_scripts:
	$(call godot_project_init)
	$(GODOT) --headless --script addons/gut/gut_cmdln.gd -gdisable_colors -gdir=src/test/unit/script_parsing 2>&1 | tee $(TEST_LOG)
	$(GODOT) --headless --script src/test/util/test_log_verifier/verify_test_log.gd | grep -q TEST_LOG_VERIFIED_OK
.PHONY: check_scripts


pack: $(CERULEAN_PCK)
.PHONY: pack


pck: $(CERULEAN_PCK)
.PHONY: pck


define godot_project_init =
	[ -d .godot/imported ] || $(GODOT) --headless --import
endef

