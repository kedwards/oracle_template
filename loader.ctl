--
-- sqlldr userid=$USER/$PASS@DB_CONNECT_NAME control=loader.ctl log=loader.log bad=loader.bad discard=loader.dsc
--
options ( skip=1 )
load data
  infile '$FILE_NAME.csv'
  badfile loader.bad
  discardfile loader.dsc
  truncate into table $FILE_NAME
  fields terminated by ","
  optionally enclosed by '"'
  trailing nullcols (
      column_1
      , column_2
      , column..N
  )
