CREATE TABLE IF NOT EXISTS events (
	   id INTEGER PRIMARY KEY,
	   eventname TEXT UNIQUE,
	   tablename TEXT UNIQUE
) ;

CREATE TABLE IF NOT EXISTS yards (
	   id INTEGER PRIMARY KEY,
	   etable TEXT NOT NULL,
	   runner TEXT NOT NULL,
	   yard INTEGER NOT NULL,
	   t INTEGER NOT NULL,
	   FOREIGN KEY (etable) REFERENCES events (tablename)
) ;

DROP INDEX IF EXISTS idx_unique_yards ;
CREATE UNIQUE INDEX idx_unique_yards ON yards (etable, runner, yard) ;
