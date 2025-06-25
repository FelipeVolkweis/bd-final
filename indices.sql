-- Indice 1
CREATE INDEX idx_matricula_professor
ON MatricularOferecimento (
    PeriodoLetivo,
    NomeProf,
    SobrenomeProf,
    TelefoneProf,
    Status
);

-- Explain indice 1
EXPLAIN ANALYZE

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

-- Indice 2
CREATE INDEX idx_medias_notas_aluno
ON NotasMatricula (
    NomeAluno,
    SobrenomeAluno,
    TelefoneAluno,
    Nota
);

-- Explain indice 2
EXPLAIN ANALYZE

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

-- Indice 3
CREATE INDEX idx_mensagem_emissor
ON Mensagem (GrupoId, UsuarioEmissorNome, UsuarioEmissorSobrenome, UsuarioEmissorTelefone);

-- Explain indice 3
EXPLAIN ANALYZE


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