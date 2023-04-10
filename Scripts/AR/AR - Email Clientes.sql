
  CREATE OR REPLACE FORCE VIEW "BOLINF"."GRP_AR_EMAIL_CONTACT_ACCOUNT_V" ("CUST_ACCOUNT_ID", "EMAIL_ADDRESS") AS 
  SELECT ACCT_ROLE.CUST_ACCOUNT_ID
           --, REL_PARTY.email_address    gvp 2015.08.14 bug. error en subconsulta cuando existen varios emails
          , LISTAGG( trim(rel_party.email_address),';') WITHIN GROUP (ORDER BY rel_party.email_address) "Email_Address"   -- gvp 2015.08.14
        FROM HZ_CONTACT_POINTS CONT_POINT
            ,HZ_CUST_ACCOUNT_ROLES ACCT_ROLE
            ,HZ_PARTIES PARTY
            ,HZ_PARTIES REL_PARTY
            ,HZ_RELATIONSHIPS REL
            ,HZ_ORG_CONTACTS ORG_CONT
            ,HZ_CUST_ACCOUNTS ROLE_ACCT
            ,HZ_PERSON_LANGUAGE PER_LANG
       WHERE ACCT_ROLE.PARTY_ID = REL.PARTY_ID
         AND ACCT_ROLE.ROLE_TYPE = 'CONTACT'
         AND ORG_CONT.PARTY_RELATIONSHIP_ID = REL.RELATIONSHIP_ID
         AND REL.SUBJECT_ID = PARTY.PARTY_ID
         AND REL_PARTY.PARTY_ID = REL.PARTY_ID
         AND CONT_POINT.OWNER_TABLE_ID(+) = REL_PARTY.PARTY_ID
         AND CONT_POINT.CONTACT_POINT_TYPE(+) = 'EMAIL'
         AND CONT_POINT.PRIMARY_FLAG(+) = 'Y'
         AND ACCT_ROLE.CUST_ACCOUNT_ID = ROLE_ACCT.CUST_ACCOUNT_ID
         AND ROLE_ACCT.PARTY_ID = REL.OBJECT_ID
         AND PARTY.PARTY_ID = PER_LANG.PARTY_ID(+)
         AND PER_LANG.NATIVE_LANGUAGE(+) = 'Y'
         and ROLE_ACCT.status = 'A'                 -- gvp 2015.08.14 bug. error en subconsulta cuando existen varios emails
         and ACCT_ROLE.status = 'A'                 -- gvp 2015.08.14 bug. error en subconsulta cuando existen varios emails
    GROUP BY ACCT_ROLE.CUST_ACCOUNT_ID
           --, REL_PARTY.email_address              -- gvp 2015.08.14 bug. error en subconsulta cuando existen varios emails
    ORDER BY 1;
