
SELECT SUM (operand), SUM(ADJUSTED_AMOUNT)
FROM oe_price_adjustments_v
WHERE 1=1
    AND applied_flag = 'Y'
    and list_line_type_code = 'DIS'
    AND line_id = 702944
    ;