.PHONY: doctor verify rebuild sql practice

.DEFAULT_GOAL := doctor

ROOT := $(abspath $(dir $(lastword $(MAKEFILE_LIST))))

doctor:
	$(ROOT)/scripts/doctor.sh

verify:
	$(ROOT)/scripts/verify_solutions.sh

rebuild:
	$(ROOT)/scripts/download_ipeds.sh
	python3 $(ROOT)/scripts/build_db.py

sql:
	cd $(ROOT) && sqlite3 -init sql/sqlite3.init ipeds_practice.sqlite

practice:
	$(ROOT)/scripts/practice.sh
