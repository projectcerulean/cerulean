GODOT := godot
EXPECTED_GODOT_VERSION := 4.1.1

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
	@[ -f $@ ]
	@if grep -q 'tests="0"' $(TEST_REPORT_XML); then echo 'Some tests did not run.'; exit 1; fi
	@if grep -q 'status="no asserts"' $(TEST_REPORT_XML); then echo 'Some tests did not have any assertions.'; exit 1; fi
	@if grep -q '<failure' $(TEST_REPORT_XML); then echo 'There were failing tests.'; exit 1; fi
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

