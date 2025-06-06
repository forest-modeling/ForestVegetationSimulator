
all : iet01 iet02 iet03 compress iedb calibStats DBReportTest econdb \
	firedb climdb ffe_svs climate climatePutGet maxActs ccadj nested

iet01 :
	@echo Test iet01, basic functionality
	rm -f iet01_Out.db
	-../../bin/FVSie --keywordfile=iet01.key
	-grep -v "\-999" iet01.sum      > iet01.tmp
	-grep -v "\-999" iet01.sum.save > iet01.tmp.save
	-diff -w iet01.tmp iet01.tmp.save
	rm -f iet01.tmp iet01.tmp.save
	-sqlite3 iet01_Out.db < iet01_Out_sqlite.sql > iet01_db_dump.txt
	-diff -w iet01_db_dump.txt iet01_db_dump.txt.save
	@echo Test iet01 ended

iet02 :
	@echo Test iet02, test use of stop/restart, same as iet01.
	rm -f iet01_Out.db
	-../../bin/FVSie --keywordfile=iet01.key --stoppoint=2,2040,iet02.stop
	-../../bin/FVSie --restart=iet02.stop
	grep -v "\-999" iet01.sum      > iet01.tmp
	grep -v "\-999" iet01.sum.save > iet01.tmp.save
	-diff -w iet01.tmp iet01.tmp.save
	rm -f iet01.tmp iet01.tmp.save
	-sqlite3 iet01_Out.db < iet01_Out_sqlite.sql > iet02_db_dump.txt
	-diff -w iet02_db_dump.txt iet02_db_dump.txt.save
	@echo Test iet02 ended

iet03 :
	@echo Test iet03, simple test of ffe with stop/restart
	-../../bin/FVSie --keywordfile=iet03.key --stoppoint=1,2003,iet03.stop
	-../../bin/FVSie --restart=iet03.stop
	grep -v "\-999" iet03.sum      > iet03.tmp
	grep -v "\-999" iet03.sum.save > iet03.tmp.save
	-diff -w iet03.tmp iet03.tmp.save
	rm -f iet03.tmp iet03.tmp.save
	@echo Test iet03 ended

iedb :
	@echo Test ie database read and write
	rm -f FVSieOut.db
	-../../bin/FVSie --keywordfile=ie.key
	-sqlite3 FVSieOut.db < FVSieOut.sql > ie_db_dump.txt
	-diff -w ie_db_dump.txt ie_db_dump.txt.save
	@echo Test ie database ended

compress :
	@echo Test ie compress
	-../../bin/FVSie --keywordfile=compress.key
	-diff -w compress.out compress.out.save
	@echo Test ie compress ended

calibStats :
	@echo Test FVS_CalibStats read and write
	rm -f calibStats.db
	-../../bin/FVSie --keywordfile=calibStats.key
	-sqlite3 calibStats.db ".header on" "select StandID,TreeSize,SpeciesFVSnum,\
        SpeciesFVS,NumTrees,round(ScaleFactor,3),round(StdErrRatio,2) \
        from FVS_CalibStats" > calibStats_dump.txt
	-diff -w calibStats_dump.txt calibStats_dump.txt.save
	@echo Test FVS_CalibStats ended

DBReportTest :
	@echo Test Database Extension output read and write
	rm -f DBReportTest.db
	-../../bin/FVSie --keywordfile=DBReportTest.key
	@echo Testing database returns... 
	-sqlite3 DBReportTest.db < DBReportTest.sql > DBReportTest_dump.txt
	-diff -w DBReportTest_dump.txt DBReportTest_dump.txt.save
	@echo Test FVS_DBReportTest ended

econdb :
	@echo Test econ database read and write
	rm -f EconDB_Out.db
	-../../bin/FVSie --keywordfile=EconDB.key
	-sqlite3 EconDB_Out.db "select Year,SpeciesPLANTS,Total_Value \
   from FVS_EconHarvestValue;" > EconDB_Out.dump
	-sqlite3 EconDB_Out.db "select round(PNV,1),Mrch_BoardFoot_Volume \
   from FVS_EconSummary;" >> EconDB_Out.dump
	-diff -w EconDB_Out.dump EconDB_Out.dump.save
	@echo Test econ database ended

firedb :
	@echo Test fire database read and write
	rm -f FVSieFireOutput.db
	-../../bin/FVSie --keywordfile=fireTest.key
	-sqlite3 FVSieFireOutput.db < Fire_db_Out.sql > fireTest_db_dump.txt
	-diff -w fireTest_db_dump.txt fireTest_db_dump.txt.save
	@echo Test fire database ended

climdb :
	@echo Test climate database read and write
	rm -f ClimOut.db
	-../../bin/FVSie --keywordfile=Clim.key
	-sqlite3 ClimOut.db "Select SpeciesFVS,Count(SpeciesFVS) \
   from FVS_Climate group by SpeciesFVS;" > Clim.db.txt
	-diff -w Clim.db.txt Clim.db.txt.save
	@echo Test climate database ended

ffe_svs :
	@echo Test FFE with SVS and stop/restart
	-../../bin/FVSie --keywordfile=ffe_svs.key --stoppoint=1,2003,ffe_svs.stop
	-../../bin/FVSie --restart=ffe_svs.stop
	-diff -w ffe_svs_007.svs ffe_svs_007.svs.save
	-diff -w ffe_svs_index.svs ffe_svs_index.svs.save
	rm -f ffe_svs_*.svs ffe_svs_*.grd
	@echo Test FFE with SVS ended

climate :
	@echo Test Climate-FVS
	-../../bin/FVSie --keywordfile=climate.key
	-grep -v "\-999" climate.sum      > climate.tmp
	-grep -v "\-999" climate.sum.save > climate.tmp.save
	-diff -w climate.tmp climate.tmp.save
	rm -f climate.tmp climate.tmp.save
	@echo Test Climate-FVS ended

climatePutGet :
	@echo Test Climate-FVS with PutGet
	-../../bin/FVSie --keywordfile=climate.key --stoppoint=1,2040,climate.stop
	-../../bin/FVSie --restart=climate.stop
	-grep -v "\-999" climate.sum      > climate.tmp
	-grep -v "\-999" climate.sum.save > climate.tmp.save
	-diff -w climate.tmp climate.tmp.save
	rm -f climate.tmp climate.tmp.save
	@echo Test Climate-FVS with PutGet ended

maxActs :
	@echo Test having many compute statements
	-../../bin/FVSie --keywordfile=maxActs.key
	@echo This grep command should not find the string
	-grep "OPTION/ACTIVITY STORAGE AREA IS FULL" maxActs.out
	rm -f maxActs.out
	@echo Test having many compute statements ended

ccadj :
	@echo Test THINcc with a CCADJ keyword
	-../../bin/FVSie --keywordfile=ccadj.key
	-grep -v "\-999" ccadj.sum      > ccadj.tmp
	-grep -v "\-999" ccadj.sum.save > ccadj.tmp.save
	-diff -w ccadj.tmp ccadj.tmp.save
	rm -f ccadj.tmp ccadj.tmp.save
	@echo Test THINcc with a CCADJ keyword ended

nested :
	@echo Test Nested Addfile keyword
	-../../bin/FVSie --keywordfile=NestedAddFile.key
	-grep -v "\-999" NestedAddFile.sum      > NestedAddFile.tmp
	-grep -v "\-999" NestedAddFile.sum.save > NestedAddFile.tmp.save
	-diff -w NestedAddFile.tmp NestedAddFile.tmp.save
	rm -f NestedAddFile.tmp NestedAddFile.tmp.save
	@echo Test Nested Addfile keyword ended
	@echo Tests\FVSie\makefile finished

clean : 
#	remove calibStats files
	rm -rfv calibStats_dump.txt calibStats.db calibStats.out 
#	remove ccadj files
	rm -rfv ccadj.out ccadj.sum
#	remove Clim files
	rm -rfv Clim.db.txt Clim.out ClimOut.db
#	remove climate files
	rm -rfv climate.out climate.stop climate.sum 
#	remove compress files
	rm -rfv compress.out
#	remove DBReportTest files
	rm -rfv DBReportTest_dump.txt DBReportTest.db DBReportTest.out DBReportTest.sng
#	remove ffe_svs files
	rm -rfv ffe_svs.out ffe_svs.sng ffe_svs.stop ffe_svs.sum 
#	remove fire files
	rm -rfv fireTest_db_dump.txt fireTest.out fireTest.sng
#	remove FVS files
	rm -rfv FVSieFireOutput.db FVSieOut.db FVSOut.db
#	remove ie files
	rm -rfv ie_db_dump.txt ie.out 
#	remove iet01 files
	rm -rfv iet01.out iet01.sum iet01.trl iet01_Out.db iet01_db_dump.txt
#	remove iet02 files
	rm -rfv iet02_db_dump.txt iet02.stop 
#	remove iet03 files
	rm -rfv iet03.out iet03.sng iet03.stop iet03.sum 
#	remove Econ files
	rm -rfv EconDB_Out.db EconDB_Out.dump EconDB.out EconDB.trl
#	remove Nested AddFile files
	rm -rfv NestedOut.db NestedAddFile.out NestedAddFile.sum NestedAddFile.trl NestedAddFile.chp
#	remove test files
	rm -rfv EconDB_Out.db EconDB_Out.dump EconDB.out EconDB.trl

