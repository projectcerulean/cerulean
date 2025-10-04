GODOT := godot
EXPECTED_GODOT_VERSION := 4.3.stable

CERULEAN_PCK := cerulean.pck
TEST_LOG := test_log.txt
TEST_REPORT_XML := test_report.xml


$(CERULEAN_PCK): verify_godot_version import_project
	$(GODOT) --headless --export-pack Linux $@
.PHONY: $(CERULEAN_PCK)


test: verify_godot_version import_project
	$(GODOT) --headless --script addons/gut/gut_cmdln.gd -gdisable_colors -gjunit_xml_file=$(TEST_REPORT_XML) 2>&1 | tee $(TEST_LOG)
	$(GODOT) --headless --script src/test/util/test_report_verifier/verify_junit_test_report_xml.gd | grep -q JUNIT_TEST_REPORT_XML_VERIFIED_OK
	$(GODOT) --headless --script src/test/util/test_log_verifier/verify_test_log.gd | grep -q TEST_LOG_VERIFIED_OK
.PHONY: test


check_scripts: verify_godot_version import_project
	$(GODOT) --headless --script addons/gut/gut_cmdln.gd -gdisable_colors -gdir=src/test/unit/script_parsing 2>&1 | tee $(TEST_LOG)
	$(GODOT) --headless --script src/test/util/test_log_verifier/verify_test_log.gd | grep -q TEST_LOG_VERIFIED_OK
.PHONY: check_scripts


pack: $(CERULEAN_PCK)
.PHONY: pack


pck: $(CERULEAN_PCK)
.PHONY: pck


verify_godot_version:
	$(GODOT) --version | grep -qF $(EXPECTED_GODOT_VERSION)
.PHONY: verify_godot_version


.godot/uid_cache.bin:
	$(GODOT) --headless --import
	[ -f .godot/uid_cache.bin ]


import_project: .godot/uid_cache.bin
.PHONY: import_project
