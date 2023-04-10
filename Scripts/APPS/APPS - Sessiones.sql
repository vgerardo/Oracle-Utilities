


  SELECT    'PGPD1I'
         || ','
         || 'Form'
         || ','
         || TO_CHAR (SYSDATE, 'YYYYMMDDHH24')
         || ','
         || ff.form_name
         || ','
         ||                                                               -- 1
           ff.user_form_name
         || ','
         ||                                                               -- 2
           fa.application_short_name
         || ','
         ||                                                               -- 3
           COUNT (*)
         || ','
         ||                                                               -- 4
           s.sid
         || ','
         ||                                                               -- 5
           s.inst_id
         || ','
         ||                                                               -- 6
           s.serial#
         || ','
         ||                                                               -- 7
           ','
         ||                                                               -- 8
           ','
         ||                                                               -- 9
           ','
         ||                                                              -- 10
           ','
         ||                                                              -- 11
           ','
         ||                                                              -- 12
           'N'
         || ','
    FROM fnd_login_resp_forms flrf,
         gv$session s,
         apps.fnd_form_vl ff,
         apps.fnd_application_vl fa
   WHERE     flrf.audsid = s.audsid
         AND flrf.form_id = ff.form_id
         AND fa.application_id = ff.application_id
         AND flrf.end_time IS NULL
GROUP BY form_name,
         user_form_name,
         application_short_name,
         s.sid,
         s.inst_id,
         s.serial#
UNION ALL
  SELECT    'PGPD1I'
         || ','
         || 'IcxUser'
         || ','
         || TO_CHAR (SYSDATE, 'YYYYMMDDHH24')
         || ','
         || REPLACE (fn.user_name, ',', ' ')
         || ','
         ||                                                               -- 1
           REPLACE (fr.responsibility_name, ',', ' ')
         || ','
         ||                                                               -- 2
           fa.application_short_name
         || ','
         ||                                                               -- 3
           COUNT (*)
         || ','
         ||                                                               -- 4
           ','
         ||                                                               -- 5
           ','
         ||                                                               -- 6
           ','
         ||                                                               -- 7
           ','
         ||                                                               -- 8
           ','
         ||                                                               -- 9
           ','
         ||                                                              -- 10
           ','
         ||                                                              -- 11
           ','
         ||                                                              -- 12
           'N'
         || ','
    FROM (SELECT v.PROFILE_OPTION_VALUE time_out
            FROM apps.FND_PROFILE_OPTIONS o, apps.FND_PROFILE_OPTION_VALUES v
           WHERE     PROFILE_OPTION_NAME = 'ICX_SESSION_TIMEOUT'
                 AND START_DATE_ACTIVE <= SYSDATE
                 AND NVL (END_DATE_ACTIVE, SYSDATE) >= SYSDATE
                 AND v.PROFILE_OPTION_ID = o.PROFILE_OPTION_ID
                 AND v.APPLICATION_ID = o.APPLICATION_ID
                 AND v.LEVEL_ID = 10001
                 AND v.PROFILE_OPTION_VALUE IS NOT NULL) fp,
         icx_sessions i,
         apps.fnd_application_vl fa,
         apps.fnd_responsibility_vl fr,
         applsys.fnd_user fn
   WHERE     i.disabled_flag = 'N'
         AND (    (  i.last_connect
                   +   DECODE (fp.time_out,
                               NULL, limit_time,
                               0, limit_time,
                               fp.time_out / 60)
                     / 24) > SYSDATE
              AND i.counter < i.limit_connects)
         AND i.responsibility_application_id = fa.application_id
         AND i.responsibility_id = fr.responsibility_id
         AND i.responsibility_application_id = fr.application_id
         AND i.user_id = fn.user_id
         AND fn.user_id <> -1
GROUP BY REPLACE (fn.user_name, ',', ' '),
         fr.responsibility_name,
         fa.application_short_name
UNION ALL
  SELECT    'PGPD1I'
         || ','
         || 'Session'
         || ','
         || TO_CHAR (SYSDATE, 'YYYYMMDDHH24')
         || ','
         || REPLACE (sub.module, ',', ' ')
         || ','
         ||                                                               -- 1
           REPLACE (sub.program, ',', ' ')
         || ','
         ||                                                               -- 2
           sub.inst_id
         || ','
         ||                                                               -- 3
           COUNT (*)
         || ','
         ||                                                               -- 4
           sub.machine
         || ','
         ||                                                               -- 5
           REPLACE (sub.action, ',', ' ')
         || ','
         ||                                                               -- 6
           sub.status
         || ','
         ||                                                               -- 7
           sub.USERNAME
         || ','
         ||                                                               -- 8
           ','
         ||                                                               -- 9
           ','
         ||                                                              -- 10
           ','
         ||                                                              -- 11
           ','
         ||                                                              -- 12
           'N'
         || ','
    FROM gv$session sub
   WHERE NVL (sub.osuser, 'x') <> 'SYSTEM' AND sub.TYPE <> 'BACKGROUND'
GROUP BY sub.module,
         sub.program,
         sub.inst_id,
         sub.machine,
         sub.action,
         sub.status,
         sub.USERNAME