DBNAME    = byulta.db
SQLITE3   = sqlite3
SQL       = $(SQLITE3) $(DBNAME)
MAXYARDS  = 96
TABLENAME = byuwc2020

.PHONY: all
all:
	@echo Targets are as follows:
	@egrep '^\.PHONY' Makefile | grep -vw all | awk '{print $$2}' | sed 's/^/    /'
	@echo Connect to the database by using: $(SQL)

.PHONY: schema
schema:
	$(SQL) < byultra.sql

.PHONY: byuwc2020
byuwc2020: schema
	test -f data/big_dogs_backyard_ultra_world_championship_2020.csv
	$(SQL) "DROP TABLE IF EXISTS byuwc2020"
	( echo .mode csv ; echo .import data/big_dogs_backyard_ultra_world_championship_2020.csv byuwc2020 ) | $(SQL)
	$(MAKE) TABLENAME=byuwc2020 table-unique-index populate-yards
	$(SQL) "INSERT OR IGNORE INTO events (eventname, tablename) VALUES ('Big Dog''s Backyard Ultra World Championship 2020', 'byuwc2020')"
	$(MAKE) show-events

.PHONY: populate-yards
populate-yards:
	@for i in `seq 1 $(MAXYARDS)` ; do $(SQL) "INSERT OR IGNORE INTO yards (etable, runner, yard, t) SELECT '$(TABLENAME)', runner, $${i}, 60 * SUBSTR(yard$${i}, 1, 2) + SUBSTR(yard$${i}, 4, 5) FROM $(TABLENAME) WHERE LENGTH(yard$$i) > 0 AND LOWER(yard$$i) NOT IN ('over', 'rtc')" ; done

.PHONY: table-unique-index
table-unique-index:
	$(SQL) "DROP INDEX IF EXISTS idx_unique_$(TABLENAME) ; CREATE UNIQUE INDEX idx_unique_$(TABLENAME) ON $(TABLENAME) (runner) ;"

.PHONY: show-events
show-events:
	@$(SQL) "SELECT * FROM events" 

.PHONY: clean
clean:
	rm -f $(DBNAME)

.PHONY: report
report:
	@$(SQL) -cmd ".headers on" "SELECT runner AS Runner, COUNT(*) AS Yards FROM yards WHERE '$(TABLENAME)' = etable GROUP BY 1 ORDER BY 2 DESC LIMIT 10" | column -t -s '|'

.PHONY: test
test:
	$(MAKE) clean byuwc2020
	$(MAKE) TABLENAME=byuwc2020 report
