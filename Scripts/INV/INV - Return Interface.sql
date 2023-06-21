
-- DOC ID 1115743.1 Various Receiving Open Interface (ROI) Transactions
-- DOC ID 360340.1  Return Receiving Transaction

DECLARE

BEGIN

-- FIRST
-- Perform a RETURN to RECEIVING
-- return to receiving transaction before you can process the return to vendor
--     Receipt_routing      = Standard Receipt
--     Transaction_tye      = RETURN TO RECEIVING
--     Parent_Transation_ID = Transaction ID for DELIVERY Transaction
--

    RCV_TRANSACTIONS_INTERFACE
    MTL_TRANSACTION_LOTS_INTERFACE  --Only if the ITEM is "Lot/Serial controlled"
    MTL_SERIAL_NUMBERS_INTERFACE    --Only if the ITEM is "Lot/Serial controlled"

-- SECOND 
-- Perform a RETURN to VENDOR for a Standard Purchase Order
--     Receipt_routing      = Standard Receipt
--     Transaction_tye      = RETURN TO VENDOR
--     Parent_Transation_ID = Transaction ID for RECEIVE Transaction
--