USE ARIBA;

SET foreign_key_checks = 0;

LOAD DATA LOCAL INFILE '/conectum/Areas/TI/crones/Ariba/d_tiempo.txt'     	REPLACE INTO TABLE D_TIEMPO 		FIELDS TERMINATED BY '!' ENCLOSED BY '"' LINES STARTING BY '#';

LOAD DATA LOCAL INFILE '/conectum/Areas/TI/crones/Ariba/d_hotel.txt' 		REPLACE INTO TABLE D_HOTEL 		FIELDS TERMINATED BY '!' ENCLOSED BY '"' LINES STARTING BY '#';

LOAD DATA LOCAL INFILE '/conectum/Areas/TI/crones/Ariba/h_ordenes_compra.txt'   REPLACE INTO TABLE H_ORDENES_COMPRA     FIELDS TERMINATED BY '!' ENCLOSED BY '"' LINES STARTING BY '#';

SET foreign_key_checks = 1;

