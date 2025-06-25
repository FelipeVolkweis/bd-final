-- Consulta 1
SELECT
    m.PeriodoLetivo,
    m.SiglaDisciplina,
    COUNT(*) FILTER (WHERE m.Status = 'cancelada') AS Cancelada,
    COUNT(*) FILTER (WHERE m.Status = 'confirmada') AS Confirmada,
    COUNT(*) FILTER (WHERE m.Status = 'pendente') AS Pendente,
    COUNT(*) FILTER (WHERE m.Status = 'concluida') AS Concluida,
    COUNT(*) FILTER (WHERE m.Status = 'reprovada') AS Reprovada,
    COUNT(*) FILTER (WHERE m.Status = 'trancada') AS Trancada,
    COUNT(*) AS TotalMatriculados,
    d.CapacidadeTurma AS QuantidadeDeVagas
FROM MatricularOferecimento m
JOIN Disciplina d ON d.Sigla = m.SiglaDisciplina
WHERE  m.PeriodoLetivo = '2025.1'
GROUP BY m.PeriodoLetivo, m.SiglaDisciplina, d.CapacidadeTurma
ORDER BY m.SiglaDisciplina;


-- Consulta 2
WITH medias AS (
  SELECT  n.NomeAluno,
          n.SobrenomeAluno,
          n.TelefoneAluno,
          AVG(n.Nota) AS media
  FROM    NotasMatricula n
  GROUP BY n.NomeAluno, n.SobrenomeAluno, n.TelefoneAluno
)
SELECT  u.Nome || ' ' || u.Sobrenome         AS Nome,
        DATE_PART('year', AGE(current_date, u.DataNasc))::int  AS Idade,
        ROUND(m.media,2)                                      AS MediaGeral,
        COALESCE( ROUND(SUM(mo.Taxa),2), 0.00)                AS TotalTaxas
FROM    medias           m
JOIN    Usuario          u
       ON (u.Nome, u.Sobrenome, u.Telefone)
        = (m.NomeAluno, m.SobrenomeAluno, m.TelefoneAluno)
LEFT JOIN MatricularOferecimento mo
       ON (mo.NomeAluno, mo.SobrenomeAluno, mo.TelefoneAluno)
        = (u.Nome,      u.Sobrenome,      u.Telefone)

GROUP BY u.Nome, u.Sobrenome, u.Telefone, u.DataNasc, m.media
ORDER BY MediaGeral DESC;

-- Consulta 3
SELECT
  d.Codigo                     AS coddepto,
  d.Nome                       AS departamento,
  d.NomeProfChefe              AS nomeprof,
  d.SobrenomeProfChefe         AS sobrenomeprof,
  STRING_AGG(
    DISTINCT cc.SiglaDisciplina, ', ' ORDER BY cc.SiglaDisciplina
  )                            AS disciplinas
FROM Departamento d
LEFT JOIN Curso c
  ON c.CodigoDepartamento = d.Codigo
LEFT JOIN ComposicaoCurso cc
  ON cc.CodigoCurso = c.Codigo
GROUP BY
  d.Codigo,
  d.Nome,
  d.NomeProfChefe,
  d.SobrenomeProfChefe
ORDER BY d.Codigo;

-- Consulta 4
WITH turma AS (
    SELECT
        o.PeriodoLetivo,
        o.SiglaDisciplina,
        o.NomeProf,
        o.SobrenomeProf,
        o.TelefoneProf,
        d.CapacidadeTurma AS capacidade,
        COUNT(*) FILTER (
            WHERE m.Status IN ('confirmada', 'concluida')
        ) AS matriculados
    FROM Oferecimento o
    JOIN Disciplina d
      ON d.Sigla = o.SiglaDisciplina
    LEFT JOIN MatricularOferecimento m
      ON m.PeriodoLetivo   = o.PeriodoLetivo
     AND m.SiglaDisciplina = o.SiglaDisciplina
     AND m.NomeProf        = o.NomeProf
     AND m.SobrenomeProf   = o.SobrenomeProf
     AND m.TelefoneProf    = o.TelefoneProf
    GROUP BY
        o.PeriodoLetivo,
        o.SiglaDisciplina,
        o.NomeProf,
        o.SobrenomeProf,
        o.TelefoneProf,
        d.CapacidadeTurma
)
SELECT
    PeriodoLetivo,
    ROUND(
        100.0 * SUM(matriculados) / NULLIF(SUM(capacidade), 0),
        1
    ) AS ocupacao_pct
FROM turma
GROUP BY PeriodoLetivo
ORDER BY PeriodoLetivo DESC;

-- Consulta 5
WITH estat AS (
    SELECT
        m.NomeProf,
        m.SobrenomeProf,
        m.SiglaDisciplina,
        COUNT(*) AS matriculas_total,
        COUNT(*) FILTER (
            WHERE m.Status IN ('cancelada', 'reprovada', 'trancada')
        ) AS evasoes
    FROM MatricularOferecimento m
    GROUP BY
        m.NomeProf,
        m.SobrenomeProf,
        m.SiglaDisciplina
)
SELECT
    NomeProf,
    SobrenomeProf,
    SiglaDisciplina,
    evasoes,
    matriculas_total,
    ROUND(100.0 * evasoes / matriculas_total, 1) AS evasao_pct
FROM estat
ORDER BY
    evasao_pct DESC,
    evasoes DESC
LIMIT 15;

-- Consulta 6
WITH contagem_msg AS (
    SELECT
        gu.NomeUsuario,
        gu.SobrenomeUsuario,
        gu.TelefoneUsuario,
        COUNT(*) AS msgs_enviadas
    FROM Mensagem m
    JOIN GrupoUsuarios gu
      ON (
          gu.GrupoId,
          gu.NomeUsuario,
          gu.SobrenomeUsuario,
          gu.TelefoneUsuario
         ) = (
          m.GrupoId,
          m.UsuarioEmissorNome,
          m.UsuarioEmissorSobrenome,
          m.UsuarioEmissorTelefone
         )
    GROUP BY
        gu.NomeUsuario,
        gu.SobrenomeUsuario,
        gu.TelefoneUsuario
),
medias AS (
    SELECT
        NomeAluno,
        SobrenomeAluno,
        TelefoneAluno,
        AVG(Nota) AS media_notas
    FROM NotasMatricula
    GROUP BY
        NomeAluno,
        SobrenomeAluno,
        TelefoneAluno
)
SELECT
    c.NomeUsuario AS nome,
    c.SobrenomeUsuario AS sobrenome,
    c.msgs_enviadas,
    ROUND(COALESCE(m.media_notas, 0), 2) AS media_notas
FROM contagem_msg c
LEFT JOIN medias m
  ON (
      m.NomeAluno,
      m.SobrenomeAluno,
      m.TelefoneAluno
     ) = (
      c.NomeUsuario,
      c.SobrenomeUsuario,
      c.TelefoneUsuario
     )
ORDER BY c.msgs_enviadas DESC;

-- Consulta 7
WITH matriculas_prof AS (
    SELECT
        m.NomeProf,
        m.SobrenomeProf,
        m.TelefoneProf,
        SUM(m.Taxa) AS receita,
        COUNT(*) AS total_mat,
        COUNT(*) FILTER (
            WHERE m.Status IN ('cancelada', 'reprovada', 'trancada')
        ) AS evasoes
    FROM MatricularOferecimento m
    WHERE m.PeriodoLetivo >= '2023.1'
    GROUP BY
        m.NomeProf,
        m.SobrenomeProf,
        m.TelefoneProf
),
notas_prof AS (
    SELECT
        n.NomeProf,
        n.SobrenomeProf,
        n.TelefoneProf,
        AVG(n.Nota) AS media_notas
    FROM NotasMatricula n
    WHERE n.PeriodoLetivo >= '2024.1'
    GROUP BY
        n.NomeProf,
        n.SobrenomeProf,
        n.TelefoneProf
)
SELECT
    mp.NomeProf,
    mp.SobrenomeProf,
    mp.TelefoneProf,
    ROUND(mp.receita, 2) AS receita_total,
    mp.total_mat AS matrículas,
    mp.evasoes,
    ROUND(100.0 * mp.evasoes / NULLIF(mp.total_mat, 0), 1) AS evasao_pct,
    ROUND(n.media_notas, 2) AS media_notas
FROM matriculas_prof mp
LEFT JOIN notas_prof n
  USING (NomeProf, SobrenomeProf, TelefoneProf)
ORDER BY receita_total DESC;