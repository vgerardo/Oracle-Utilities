-- -------------------------------------------------------------------------------------- --
-- Created by: Craig J. Butts                                                             --
--             Ogden, Utah                                                                --
--             (Yippie0001@yahoo.com)                                                     --
-- -------------------------------------------------------------------------------------- --
-- The REC_GROUP package was created to simplfy the process of creating and manipulating  --
-- an Array type structure in Oracle Forms.  This package uses Oracle Forms Built-Ins.    --
--                                                                                        --
-- -------------------------------------------------------------------------------------- --
-- Disclaimer:  The creator (me) of this package is not responsible in any way shape or   --
--              form for problems you may encounter while using this package.             --
--              !!USE IT AT YOUR OWN RISK!!  Support of this package is not available or  --
--              implied!  Again - USE IT AT YOUR OWN RISK!!
-- ====================================================================================== --
-- That having been said, I have tried to make this package completely portable.  You     --
-- should be able to copy this code directly to your Form or Form Library without having  --
-- to create any supporting objects, such as Alerts, parameters, data blocks, etc.        --
-- All data needed by the package methods are passed to the methods using parameters.     --
-- If you find a problem (bug) in one of the supplied functions or procedures please let  --
-- me know what you did to fix the bug or if you are having problems fixing the bug, send --
-- a test case that demonstrates the bug and I will "TRY" to help you fix the bug. I have --
-- a day job, so as stated in the Disclaimer - I do not offer support for this package,   --
-- but I am willing to try fix any bugs found and reported, just don't expect an immediate--
-- response to your bug report.  :-)                                                      --
-- -------------------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------------------- --
PACKAGE BODY REC_GROUP IS
	FUNCTION initialize(p_name VARCHAR2) RETURN BOOLEAN IS
		bRetVal        BOOLEAN := FALSE;
		curRecord      NUMBER;  
		recGroup       RECORDGROUP;
		groupCol       GROUPCOLUMN;
		colName        VARCHAR(100);     
	BEGIN
		IF ( p_name IS NULL ) THEN 
			message('P_NAME can not be NULL.',ACKNOWLEDGE);
			bRetVal := FALSE;
		ELSE
			curRecord := get_block_property(name_in('system.trigger_block'), CURRENT_RECORD);      
			
			-- See if there is already an RG with the same name as RG_NAME.
			recGroup := find_group(p_name);
			colName := p_name||'.key_value';
			
			-- Check if the Named Group already exists.
			-- Delete if it exists.
			IF ( NOT id_null(recGroup) ) THEN 
				delete_group(recGroup);
			END IF;
			-- Create the Record Group.
			recGroup := create_group(p_name);
			groupCol := add_group_column(recGroup,'key_value',CHAR_COLUMN,100);
			bRetVal := TRUE;
		END IF;
			
		RETURN bRetVal;
	END initialize;
	-- ----------------------------------------------------------------------------------- --

	FUNCTION ADD_VALUE(p_name VARCHAR2, p_value VARCHAR2, p_record NUMBER default null) RETURN BOOLEAN AS
		bRetVal     BOOLEAN := FALSE;
		recGroup    RECORDGROUP;
		groupCol    GROUPCOLUMN;
		tmpGC				GROUPCOLUMN;
		curRecord   NUMBER;
		colName     VARCHAR(100);
		nDummy			NUMBER;
		vDummy			VARCHAR2(100);
		row_no			NUMBER;
	BEGIN
		IF ( p_name IS NOT NULL AND p_value IS NOT NULL ) THEN 
			IF ( nvl(p_record,0) = 0 ) THEN 
				curRecord := get_block_Property(name_in('system.trigger_block'), current_record);
			ELSE
				curRecord := p_record;
			END IF;

			-- Get pointer to existing Record Group
			recGroup := find_group(p_name);
			-- Get pointer to column to add value too.
			colName := p_name||'.key_value';
			
			groupCol := find_column(colName);
						
			add_group_row(recGroup, curRecord);
			row_no := Get_Group_Row_Count(recGroup);
			set_group_char_cell(groupCol, curRecord, p_value);
			
			-- Loop throud the RG to verify the record we added.
			tmpGC := find_column(colName);
			nDummy := get_count(p_name);
			
			FOR j in 1..nDummy LOOP
				vDummy := get_group_char_cell(tmpGC, j);
				IF ( UPPER(vDummy) = UPPER(p_value) ) THEN 
					bRetVal := TRUE;
				END IF;
			END LOOP;
							
			IF ( nDummy > 0 ) THEN 
				bRetVal := TRUE;
			ELSE
				bRetVal := FALSE;
			END IF;
		END IF;
		RETURN bRetVal;
	END ADD_VALUE;
	-- ----------------------------------------------------------------------------------- --

	FUNCTION GET_VALUE(p_name VARCHAR2, p_record NUMBER) RETURN VARCHAR2 IS
		rowNbr      	NUMBER;
		recGroup    	RECORDGROUP;
		groupCol    	GROUPCOLUMN;
		the_rg_column  VARCHAR2(100);
		colName     	VARCHAR(100);
		colValue    	VARCHAR2(80);
		Exit_Function EXCEPTION; 
	BEGIN
		colName := p_name||'.key_value';
		
		-- Check if the RG exists and get it's ID.
		recGroup := Find_Group(p_name);
		
		IF Id_Null(recGroup) THEN 
			-- Use the CIR Messaging Functionality.
			Message('Record Group '||p_name||' does not exist',ACKNOWLEDGE); 
			RAISE Exit_Function; 
		END IF; 
	
		-- Make sure the column name specified exists in the record Group. 
		groupCol := Find_Column( the_rg_column );                                                              
		
		IF Id_Null(groupCol) THEN 
			Message('Column '||the_rg_column||' does not exist.',ACKNOWLEDGE); 
			RAISE Exit_Function; 
		END IF; 
	
		-- Get a count of the number of records in the record group 
		rowNbr := Get_Group_Row_Count( recGroup ); 
		
		-- Go to the Row Number specified and get the existing value.
		colValue := GET_GROUP_CHAR_CELL(groupCol, p_record); 
		
		IF colValue IS NOT NULL THEN 
			RETURN colValue;
		ELSE
			RETURN NULL;
		END IF;

		-- If we get here, we didn't find any matches. 
		RAISE Exit_Function; 
	EXCEPTION 
		WHEN Exit_Function THEN 
			RETURN NULL;    
	END GET_VALUE;
	-- ----------------------------------------------------------------------------------- --

	FUNCTION GET_NUMBER(p_name VARCHAR2, p_value VARCHAR2) RETURN NUMBER IS
		nRetVal        NUMBER;
		nCount         NUMBER; 
		recGroup       RECORDGROUP; 
		groupCol       GROUPCOLUMN; 
		vRgColumn      VARCHAR2(100);
		vColValue      VARCHAR2(80); 
		Exit_Function  Exception; 
	BEGIN
		vRgColumn := p_name||'.key_value';
		
		-- Determine if record group exists, and if so get its ID. 
		-- 
		recGroup := Find_Group( p_name ); 
		
		IF Id_Null(recGroup) THEN 
			Message('Record Group '||p_name||' does not exist.',ACKNOWLEDGE); 
			RAISE Exit_Function; 
		END IF; 
		
		-- Make sure the column name specified exists in the  
		-- record Group. 
		-- 
		groupCol := Find_Column( vRgColumn );                                                              
		                                                                                                        
		IF Id_Null(groupCol) THEN 
			Message('Column '||vRgColumn||' does not exist.',ACKNOWLEDGE); 
			RAISE Exit_Function; 
		END IF; 
		
		-- Get a count of the number of records in the record group 
		-- 
		nCount := Get_Group_Row_Count( recGroup ); 
		
		-- Loop through the records, getting the specified column's 
		-- value at each iteration and comparing it to 'the_value' 
		-- passed in.  Compare the values in a case insensitive manner. 
		-- 
		FOR j IN 1..nCount LOOP 
			vColValue := GET_GROUP_CHAR_CELL( groupCol, j ); 
			
			-- If we find a match, stop and return the 
			-- current row number. 
			-- 
			IF UPPER(vColValue) = UPPER(p_value) THEN 
				RETURN j; 
			END IF; 
		END LOOP; 
	
		-- If we get here, we didn't find any matches. 
		-- 
		RAISE Exit_Function; 
	EXCEPTION 
		WHEN Exit_Function THEN 
		RETURN 0; 
	END GET_NUMBER; 	
	-- ----------------------------------------------------------------------------------- --

	FUNCTION GET_COUNT(p_name VARCHAR2) RETURN NUMBER
	IS 
		nCount 				NUMBER; 
		recGroup 			RecordGroup; 
		groupCol 			GroupColumn; 
		recCol  			VARCHAR2(100);
		col_val				VARCHAR2(80); 
		Exit_Function	Exception; 
		nIgnore				NUMBER;
		bIgnore				BOOLEAN;
	BEGIN
		recCol := p_name||'.key_value';
		
		-- 
		-- Determine if record group exists, and if so get its ID. 
		-- 
		recGroup := Find_Group( p_name ); 
			
		IF Id_Null(recGroup) THEN 
			clear_message;
			Message('Record Group '||p_name||' does not exist So it was initialized.',ACKNOWLEDGE);
			bIgnore := initialize(p_name);
			RAISE Exit_Function; 
		END IF; 
	
		-- 
		-- Make sure the column name specified exists in the  
		-- record Group. 
		groupCol := Find_Column( recCol ); 	                                                          
		                                                          	                                                          
		IF Id_Null(groupCol) THEN 
			Message('Column '||recCol||' does not exist',ACKNOWLEDGE); 
			RAISE Exit_Function; 
		END IF; 
		--
		-- Get a count of the number of records in the record group 
		-- 
		nCount := Get_Group_Row_Count( recGroup ); 
	
		return nCount;
	EXCEPTION 
		WHEN Exit_Function THEN 
			RETURN 0; 
	END GET_COUNT; 
	-- ----------------------------------------------------------------------------------- --
	
	FUNCTION DELETE_VALUE(p_name VARCHAR2, p_value VARCHAR2) RETURN NUMBER IS
		nRetVal        NUMBER;
		recGroup       RECORDGROUP;
		colName        VARCHAR(100);
		nRec           NUMBER;
	
	BEGIN
		recGroup := find_group(p_name);
		colName := p_name||'.key_value';
		
		nRec := GET_NUMBER(p_name, p_value);
		delete_group_row(nRec);
		
		IF ( FORM_SUCCESS ) THEN 
			nRetVal := nRec;
		ELSE
			nRetVal := 0;
		END IF;
		
		RETURN nRetVal;   
	END DELETE_VALUE;
	-- ----------------------------------------------------------------------------------- --

	FUNCTION DELETE_VALUE(p_name VARCHAR2, p_record NUMBER) RETURN NUMBER IS
		nRetVal        NUMBER;
		recGroup       RECORDGROUP;
		colName        VARCHAR(100);
		
	BEGIN
		recGroup := find_group(p_name);
		colName := p_name||'.key_value';
		delete_group_row(recGroup, p_record);
		
		IF ( FORM_SUCCESS ) THEN 
			nRetVal := p_record;
		ELSE
			nRetVal := 0;
		END IF;
		
		RETURN nRetVal;      
	END DELETE_VALUE;
	-- ----------------------------------------------------------------------------------- --

	PROCEDURE REMOVE_GROUP( p_name VARCHAR2 ) IS 
		rg_id RecordGroup; 
	BEGIN 
		-- Make sure the Record Group exists before trying to delete it.
		rg_id := Find_Group( p_name ); 
		
		IF NOT Id_Null(rg_id) THEN 
			Delete_Group( rg_id ); 
		END IF; 
	END REMOVE_GROUP; 
	-- ----------------------------------------------------------------------------------- --

END REC_GROUP;--------------------------------------------------------------
