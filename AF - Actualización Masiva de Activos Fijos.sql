

BEGIN

APPS.FA_BOOKS_PKG.UPDATE_ROW (
                X_Book_Type_Code => 'FISC',
                X_ASSET_ID => 112928,
                X_Life_In_Months => 1,
                X_COST => 1,
                X_ADJUSTED_COST => 1,
                X_LAST_UPDATE_DATE => SYSDATE,
                X_LAST_UPDATED_BY => 1,
                X_Calling_Fn => '1'
);

END;