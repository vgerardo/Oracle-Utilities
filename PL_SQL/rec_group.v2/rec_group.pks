-- -------------------------------------------------------------------------------------- --
-- Created by: Craig J. Butts                                                             --
--             Plain City, Utah                                                           --
--             (CraigButts@inbox.com)                                                     --
-- -------------------------------------------------------------------------------------- --
-- The REC_GROUP package was created to simplfy the process of creating and manipulating  --
-- an Array type structure in Oracle Forms.  This package uses Oracle Forms Built-Ins.    --
--                                                                                        --
-- -------------------------------------------------------------------------------------- --
-- Disclaimer:  The creator (me) of this package is not responsible in any way shape or   --
--              form for problems you may encounter while using this package.             --
--              !!USE IT AT YOUR OWN RISK!!  Support of this package is not available or  --
--              implied!  Again - USE IT AT YOUR OWN RISK!!											--
-- ====================================================================================== --
-- That having been said, I have tried to make this package completely portable.  You     --
-- should be able to copy this code directly to your Form or Form Library without having  --
-- to create any supporting objects, such as Alerts, parameters, data blocks, etc.        --
-- Although, I strongly suggest you use a Forms Alert to display messages to your users.  --
-- I have found this works much better than simply displaying the message in the status   --
-- bar.  
--    																												--
-- All data needed by the package methods are passed to the methods using parameters.     --
-- If you find a problem (bug) in one of the supplied functions or procedures please let  --
-- me know what you did to fix the bug or if you are having problems fixing the bug, send --
-- a test case that demonstrates the bug and I will "TRY" to help you fix the bug. I have --
-- a day job, so as stated in the Disclaimer - I do not offer support for this package,   --
-- but I am willing to try fix any bugs found and reported, just don't expect an immediate--
-- response to your bug report.  :-)                                                      --
-- -------------------------------------------------------------------------------------- --
-- -------------------------------------------------------------------------------------- --
PACKAGE REC_GROUP IS
	-- ----------------------------------------------------------------------------------- --
	-- Package Variables used by the RG Process                                            --
	-- ----------------------------------------------------------------------------------- --
	rg_name			VARCHAR2(150);		-- Name of the Record Group
	prev_value	VARCHAR2(500);		-- Previous Value of the Current Block Item.
	
	-- ----------------------------------------------------------------------------------- --
	-- Name:    INITIALIZE                                                                 --
	-- Returns: BOOLEAN  (TRUE  - RG Initialized successfully)                             --
	--                   (FALSE - RG Initialization Error)                                 --
	-- Purpose: This FUNCTION initializes a Forms Record Group so you can put values into  --
	--          the Record Group.                                                          --   
	-- ----------------------------------------------------------------------------------- --
	FUNCTION initialize(p_name VARCHAR2) RETURN BOOLEAN;

	-- ----------------------------------------------------------------------------------- --
	-- Name:    ADD_VALUE                                                                  --
	-- Returns: BOOLEAN  (TRUE  - Value Added successfully)                                --
	--                   (FALSE - Value Add Failed)                                        --
	-- Purpose:	Simple - Add a value to the Record Group at the specified row number.      --
	--					If you are updating an existing value in the record group, find the value  --
  --					in the Multi-Record Block first; then simply use add_value to ADD the new  --
  --					over the old value.                                                        --
	-- ----------------------------------------------------------------------------------- --
	FUNCTION ADD_VALUE(p_name VARCHAR2, p_value VARCHAR2, p_record NUMBER default null) RETURN BOOLEAN;

	-- ----------------------------------------------------------------------------------- --
	-- Name:    GET_VALUE  (Overloaded)                                                    --
	-- Returns: BOOLEAN  (TRUE  - Value Added successfully)                                --
	--                   (FALSE - Value Add Failed)                                        --
	-- Purpose: Go to the Row Number specified and return the value found.                 --
	-- ----------------------------------------------------------------------------------- --
	FUNCTION GET_VALUE(p_name VARCHAR2, p_record NUMBER) RETURN VARCHAR2;

	-- ----------------------------------------------------------------------------------- --
	-- Name:    GET_NUMBER                                                                 --
	-- Returns: NUMBER   (RowNumber where the value was found                              --
	--                   (0 - if the value is not found                                    --
	-- Purpose: Go to the Row Number specified and return the value found.                 --
	-- ----------------------------------------------------------------------------------- --
	FUNCTION GET_NUMBER(p_name VARCHAR2, p_value VARCHAR2) RETURN NUMBER;

	-- ----------------------------------------------------------------------------------- --
	-- Name:    GET_COUNT                                                                  --
	-- Param:		p_name - Name of the Record Group                                          --
	-- Returns: NUMBER   (Total Number of Rows in the Record Group                         --
	--                   (0 - if the value is not found                                    --
	-- Purpose: Return the number of Rows in a Record Group.                               --
	-- ---------------------------------------------------------------------------------- --
	FUNCTION GET_COUNT(p_name VARCHAR2) RETURN NUMBER;

	-- ----------------------------------------------------------------------------------- --
	-- Name:    DELETE_VALUE (Overloaded)                                                  --
	-- Params:  p_name - Name of the Record Group                                          --
	--          p_value - Value to find in the RG and delete                               --
	-- Returns: NUMBER   (RowNumber where the value was deleted from or                    --
	--                    0 - if the value is not found )                                  --
	-- Purpose: Allows the deleting of values from a Record Group. Typically called from   --
	--          the following triggers:                                                    --
	--          When-Remove-Record                                                         --
	-- ----------------------------------------------------------------------------------- --
	FUNCTION DELETE_VALUE(p_name VARCHAR2, p_value VARCHAR2) RETURN NUMBER;
	
	-- ----------------------------------------------------------------------------------- --
	-- Name:    DELETE_VALUE (Overloaded)                                                  --
	-- Params:  p_name - Name of the Record Group                                          --
	--          p_record - Row Number to delete from the RG                                --
	-- Returns: NUMBER   (RowNumber where the value was deleted from or                    --
	--                    0 - if the value is not found )                                  --
	-- Purpose: Allows the deleting of values from a Record Group. Typically called from   --
	--          the following triggers:                                                    --
	--          When-Remove-Record                                                         --
	-- ----------------------------------------------------------------------------------- --
	FUNCTION DELETE_VALUE(p_name VARCHAR2, p_record NUMBER) RETURN NUMBER;

	-- ----------------------------------------------------------------------------------- --
	-- Name:    REMOVE_GROUP                                                               --
	-- Params:  p_name - Name of the Record Group                                          --
	-- Purpose: Removes the specified Record Group from memory.                            --
	-- ----------------------------------------------------------------------------------- --
	PROCEDURE REMOVE_GROUP (p_name VARCHAR2);
		
END;