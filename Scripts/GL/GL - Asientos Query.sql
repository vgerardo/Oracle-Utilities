
select  b.je_batch_id batch_id ,
        h.je_header_id header_id ,
        l.je_line_num line ,
        l.code_combination_id ccid ,
        g.segment1 || '.' || g.segment2 || '.' || g.segment3 ||
        '.' || g.segment4 || '.' || g.segment5 || '.' || g.segment6 ||
        '.' || g.segment7 || '.' || g.segment8 || '.' || g.segment9 ||
        '.' || g.segment10 combination ,
        l.entered_dr entered_dr,
        l.entered_cr entered_cr,
        l.accounted_dr accounted_dr,
        l.accounted_cr accounted_cr,
        l.status
from    gl_je_lines l,
        gl_je_headers h,
        gl_je_batches b,
        gl_code_combinations g
where   b.je_batch_id = h.je_batch_id
        --and h.je_header_id = &je_header_id
        and l.je_header_id = h.je_header_id
        and h.je_batch_id = b.je_batch_id
        and l.code_combination_id = g.code_combination_id
order by h.je_header_id, l.je_line_num;