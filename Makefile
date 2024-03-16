GODOT := godot
EXPECTED_GODOT_VERSION := 4.2.1

CERULEAN_PCK := cerulean.pck
TEST_REPORT_XML := test_report.xml


GODOT_VERSION := $(shell $(GODOT) --version)
ifeq (,$(findstring $(EXPECTED_GODOT_VERSION),$(GODOT_VERSION)))
$(error Invalid godot version '$(GODOT_VERSION)', expected $(EXPECTED_GODOT_VERSION).[...]))
endif


$(CERULEAN_PCK):
	$(call godot_project_init)
	$(GODOT) --headless --export-pack Linux/X11 $@
.PHONY: $(CERULEAN_PCK)

$(TEST_REPORT_XML):
	$(call godot_project_init)
	$(GODOT) --headless --script addons/gut/gut_cmdln.gd -gjunit_xml_file=$@
	$(GODOT) --headless --script src/test/util/verify_junit_test_report_xml.gd | grep -q JUNIT_TEST_REPORT_XML_VERIFIED_OK
.PHONY: $(TEST_REPORT_XML)


pack: $(CERULEAN_PCK)
.PHONY: pack


pck: $(CERULEAN_PCK)
.PHONY: pck


test: $(TEST_REPORT_XML)
.PHONY: test


define godot_project_init =
	[ -d .godot/imported ] || ( $(GODOT) --headless --editor --quit && $(GODOT) --headless --export-pack Linux/X11 /dev/null )
endef

