-- vw_aluno_financeiro
CREATE OR REPLACE VIEW vw_aluno_financeiro AS
WITH medias AS (
  SELECT
    NomeAluno,
    SobrenomeAluno,
    TelefoneAluno,
    AVG(Nota) AS MediaNotas
  FROM NotasMatricula
  GROUP BY NomeAluno, SobrenomeAluno, TelefoneAluno
),
taxas AS (
  SELECT
    NomeAluno,
    SobrenomeAluno,
    TelefoneAluno,
    SUM(Taxa) AS TotalTaxas
  FROM MatricularOferecimento
  GROUP BY NomeAluno, SobrenomeAluno, TelefoneAluno
)
SELECT
  u.Nome    || ' ' || u.Sobrenome   AS Aluno,
  ROUND(m.MediaNotas,2)             AS MediaGeral,
  COALESCE(t.TotalTaxas,0)          AS TotalTaxas
FROM Usuario u
JOIN medias m
  ON  (u.Nome, u.Sobrenome, u.Telefone)
  =   (m.NomeAluno, m.SobrenomeAluno, m.TelefoneAluno)
LEFT JOIN taxas t
  ON  (u.Nome, u.Sobrenome, u.Telefone)
  =   (t.NomeAluno, t.SobrenomeAluno, t.TelefoneAluno)
WHERE u.Tipo = 'aluno'
ORDER BY MediaGeral DESC;

select * from vw_aluno_financeiro


-- vw_ofertas_abertas 
CREATE OR REPLACE VIEW vw_ofertas_abertas AS
WITH matriculados AS (
    SELECT
        m.PeriodoLetivo,
        m.SiglaDisciplina,
        m.NomeProf, m.SobrenomeProf, m.TelefoneProf,
        COUNT(*) FILTER (WHERE m.Status IN ('confirmada','pendente')) AS alunos_inscritos
    FROM   MatricularOferecimento m
    GROUP  BY m.PeriodoLetivo,
             m.SiglaDisciplina,
             m.NomeProf, m.SobrenomeProf, m.TelefoneProf
)
SELECT
    o.PeriodoLetivo,
    o.SiglaDisciplina,
    d.CapacidadeTurma,
    COALESCE(m.alunos_inscritos,0)                            AS alunos_inscritos,
    d.CapacidadeTurma - COALESCE(m.alunos_inscritos,0)        AS vagas_disponiveis,
    o.DataMaxMatricula,
    o.NomeProf || ' ' || o.SobrenomeProf                      AS professor,
    o.NroSala || ' – ' || o.CidadeSala                        AS sala
FROM   Oferecimento o
JOIN   Disciplina   d ON d.Sigla = o.SiglaDisciplina
LEFT   JOIN matriculados m
       ON (m.PeriodoLetivo, m.SiglaDisciplina,
           m.NomeProf,     m.SobrenomeProf,    m.TelefoneProf)
        = (o.PeriodoLetivo, o.SiglaDisciplina,
           o.NomeProf,      o.SobrenomeProf,   o.TelefoneProf)
WHERE  o.DataMaxMatricula >= CURRENT_DATE
ORDER  BY o.PeriodoLetivo, o.SiglaDisciplina;

select * from vw_ofertas_abertas


-- vw_vagas_semestre
CREATE OR REPLACE VIEW vw_vagas_semestre AS

WITH capacidade_disc AS (
    SELECT
        o.PeriodoLetivo,
        o.SiglaDisciplina,
        SUM(d.CapacidadeTurma) AS vagas_total
    FROM   Oferecimento o
    JOIN   Disciplina   d ON d.Sigla = o.SiglaDisciplina
    GROUP  BY o.PeriodoLetivo, o.SiglaDisciplina
),


inscritos_disc AS (
    SELECT
        m.PeriodoLetivo,
        m.SiglaDisciplina,
        COUNT(*) FILTER (
            WHERE m.Status <> 'cancelada'
        ) AS inscritos
    FROM   MatricularOferecimento m
    GROUP  BY m.PeriodoLetivo, m.SiglaDisciplina
)

SELECT
    c.PeriodoLetivo,
    c.SiglaDisciplina,
    c.vagas_total,
    COALESCE(i.inscritos,0)                        AS inscritos,
    c.vagas_total - COALESCE(i.inscritos,0)        AS vagas_disponiveis,
    ROUND(
        100.0 * COALESCE(i.inscritos,0)
              / NULLIF(c.vagas_total,0)
    ,1)                                            AS ocupacao_pct
FROM   capacidade_disc c
LEFT   JOIN inscritos_disc i
       USING (PeriodoLetivo, SiglaDisciplina)
ORDER  BY c.PeriodoLetivo DESC, c.SiglaDisciplina;


select * from vw_vagas_semestre