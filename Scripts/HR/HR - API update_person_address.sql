declare

cursor c_address
is
select *
from per_addresses
where person_id  =276;

v_object_version_number number(15);

begin

    FOR rh IN c_address LOOP
    
    HR_PERSON_ADDRESS_API.update_person_address (
            p_effective_date    => rh.date_from,
            p_address_id        => rh.address_id,
            p_address_line1     => 'LAUREL 99',     -- street
            p_address_line2     => 'ROBLE',     -- Neighborhood
            --p_address_line3     => ' x',    --Municipality
            p_postal_code     => '43210',    --postal code
            p_town_or_city     => 'Acapulquito',   --City
            --p_region_1     => 'Aguascalientes', --State
            --p_country     => 'pais',   --Country
            p_telephone_number_1     => '12-345678',  --Telephone
            
            p_object_version_number => rh.object_version_number
    );

    END LOOP;
    
end;