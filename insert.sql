CREATE EXTENSION IF NOT EXISTS unaccent;

TRUNCATE
  DescontosMatricula, BolsasMatricula, NotasMatricula,
  GrupoUsuarios, Grupo,
  AvaliarOferecimento, MatricularOferecimento,
  Oferecimento, Curso, Disciplina,
  Departamento, Usuario,
  Sala, Unidade
CASCADE;

INSERT INTO Unidade (Cidade, Estado, Pais, Bloco, Predio)
SELECT
  'Cidade' || chr(65 + mod(gs - 1, 26)) || chr(65 + ((gs - 1) / 26)::int),
  'Estado' || chr(65 + mod(gs - 1, 26)) || chr(65 + ((gs - 1) / 26)::int),
  'Brasil',
  chr(65 + mod(gs - 1, 6)),
  (1 + mod(gs, 10))::varchar
FROM generate_series(1, 30) AS gs;

INSERT INTO Sala (NroSala, CidadeUnidade, EstadoUnidade, PaisUnidade, Capacidade)
SELECT
  LPAD(row_number()
        OVER (PARTITION BY u.Cidade,u.Estado,u.Pais
              ORDER BY random())::text , 4, '0')
  , u.Cidade, u.Estado, u.Pais
  , 20 + floor(random()*80)::int
FROM Unidade u
CROSS JOIN generate_series(1,20);

WITH nomes(n) AS (
  SELECT unnest(ARRAY[
    'Ana', 'Bruno', 'Carlos', 'Daniela', 'Eduardo', 'Fernanda', 'Gabriel', 'Helena',
    'Igor', 'Julia', 'Lucas', 'Mariana', 'Nicolas', 'Olivia', 'Pedro', 'Rafaela',
    'Sofia', 'Thiago', 'Valéria', 'William'
  ])
), sobrenomes(s) AS (
  SELECT unnest(ARRAY[
    'Silva', 'Souza', 'Costa', 'Oliveira', 'Pereira', 'Rodrigues', 'Almeida',
    'Nunes', 'Gomes', 'Barbosa'
  ])
), base AS (
  SELECT
    n.n AS nome,
    s.s AS sobrenome,
    gs   AS idx
  FROM nomes n
  CROSS JOIN sobrenomes s
  CROSS JOIN generate_series(1, 4) gs
), enumerado AS (
  SELECT
    b.*,
    row_number() OVER () AS rn
  FROM base b
)
INSERT INTO Usuario (
  Nome, Sobrenome, Telefone, DataNasc,
  EnderecoCep, EnderecoNumero, EnderecoBairro,
  Sexo, Email, Senha, Tipo, Area, Titulacao,
  CidadeUnidade, EstadoUnidade, PaisUnidade
)
SELECT
  e.nome,
  e.sobrenome,
  lpad((50000000 + floor(random() * 49999999))::int::text, 9, '0'),
  date '1980-01-01' + (random() * 15000)::int,
  lpad((random() * 99999999)::int::text, 8, '0'),
  (1 + floor(random() * 999))::text,
  'Bairro' ||
    chr((65 + mod(e.rn - 1, 26))::int) ||
    chr((65 + mod(((e.rn - 1) / 26), 26))::int) ||
    chr((65 + ((e.rn - 1) / 676)::int)::int),
  (ARRAY['M', 'F', 'O'])[1 + floor(random() * 3)::int],
  lower(
    regexp_replace(unaccent(e.nome), '[^a-zA-Z]', '', 'g')
  ) || '.' ||
  lower(
    regexp_replace(unaccent(e.sobrenome), '[^a-zA-Z]', '', 'g')
  ) || e.idx || '@escola.com',
  md5(random()::text),
  (ARRAY['aluno', 'professor', 'funcionario'])[1 + floor(random() * 3)::int],
  'Area' ||
    chr((65 + mod(e.rn - 1, 26))::int) ||
    chr((65 + mod(((e.rn - 1) / 26), 26))::int) ||
    chr((65 + ((e.rn - 1) / 676)::int)::int),
  (ARRAY['Doutor', 'Mestre', 'Especialista'])[1 + floor(random() * 3)::int],
  su.Cidade,
  su.Estado,
  su.Pais
FROM enumerado e
CROSS JOIN LATERAL (
  SELECT
    Cidade,
    Estado,
    Pais
  FROM Unidade
  ORDER BY random()
  LIMIT 1
) su;


WITH

alvo AS (
    SELECT 6 AS qtd_deptos
),


profs_base AS (
    SELECT DISTINCT ON (u.Nome, u.Sobrenome)
           u.Nome, u.Sobrenome, u.Telefone
    FROM   Usuario u
    WHERE  u.Tipo = 'professor'
    ORDER  BY u.Nome, u.Sobrenome, random()
),


quota AS (
    SELECT pb.*,
           CASE
             WHEN rn <= 0.80 * total THEN 1
             WHEN rn <= 0.95 * total THEN 2
             ELSE                           3
           END                                       AS max_deptos
    FROM (
        SELECT pb.*,
               ROW_NUMBER() OVER (ORDER BY random()) AS rn,
               COUNT(*)      OVER ()                 AS total
        FROM   profs_base pb
    ) pb
),


vagas AS (
    SELECT q.Nome, q.Sobrenome, q.Telefone
    FROM   quota q
    CROSS  JOIN generate_series(1, q.max_deptos)
),


chefes_escolhidos AS (
    SELECT v.*
    FROM   vagas v
    ORDER  BY random()
    LIMIT  (SELECT qtd_deptos FROM alvo)
),


base AS (
    SELECT COALESCE(MAX(Codigo)::int, 0) AS ultimo
    FROM   Departamento
)


INSERT INTO Departamento (
       Codigo,
       Nome,
       NomeProfChefe, SobrenomeProfChefe, TelefoneProfChefe
)
SELECT
       LPAD((ROW_NUMBER() OVER () + ultimo)::text, 3, '0')       AS Codigo,
       'Departamento ' || (ROW_NUMBER() OVER () + ultimo)        AS Nome,
       c.Nome,
       c.Sobrenome,
       c.Telefone
FROM   chefes_escolhidos c, base;



INSERT INTO Disciplina (
  Sigla, CapacidadeTurma, MaterialBasico, NroAulasSemanais,
  CidadeUnidade, EstadoUnidade, PaisUnidade
)
SELECT
  'DISC' || lpad(gs::text,3,'0'),
  30 + (gs % 20),
  'Material básico da disciplina ' || gs,
  2 + (gs % 4),
  u.Cidade, u.Estado, u.Pais
FROM generate_series(1,150) gs
JOIN LATERAL (
  SELECT Cidade, Estado, Pais FROM Unidade ORDER BY random() LIMIT 1
) u ON TRUE;

INSERT INTO Curso (
  Codigo, Nome, NivelEnsino, Ementa, CargaHoraria,
  NumeroVagas, CodigoDepartamento,
  NroSala, CidadeSala, EstadoSala, PaisSala,
  CidadeUnidade, EstadoUnidade, PaisUnidade
)
SELECT
  lpad(gs::text,4,'0'),
  'Curso ' || gs,
  (ARRAY['fundamental','médio','técnico','graduação'])[1 + floor(random()*4)::int],
  'Ementa do curso ' || gs,
  (600 + gs)::text,
  50 + (gs % 50),
  (SELECT Codigo FROM Departamento ORDER BY random() LIMIT 1),
  s.NroSala, s.CidadeUnidade, s.EstadoUnidade, s.PaisUnidade,
  u.Cidade, u.Estado, u.Pais
FROM generate_series(1,60) gs
JOIN LATERAL (SELECT * FROM Sala ORDER BY random() LIMIT 1) s ON TRUE
JOIN LATERAL (SELECT Cidade,Estado,Pais FROM Unidade ORDER BY random() LIMIT 1) u ON TRUE;


WITH deptos_sem_curso AS (
    SELECT d.Codigo
    FROM   Departamento d
    WHERE  NOT EXISTS (SELECT 1
                       FROM   Curso c
                       WHERE  c.CodigoDepartamento = d.Codigo)
)
INSERT INTO Curso (
    Codigo, Nome, NivelEnsino, Ementa, CargaHoraria,
    NumeroVagas, CodigoDepartamento,
    NroSala, CidadeSala, EstadoSala, PaisSala,
    CidadeUnidade, EstadoUnidade, PaisUnidade
)
SELECT
    LPAD( (ROW_NUMBER() OVER ()
           + COALESCE((SELECT MAX(Codigo)::int FROM Curso),0)
          )::text, 4, '0')          AS Codigo,
    'Curso auto ' || LPAD(d.Codigo,3,'0') AS Nome,
    (ARRAY['fundamental','médio','técnico','graduação'])
        [1+floor(random()*4)::int]  AS NivelEnsino,
    'Ementa genérica', '600',
    40,
    d.Codigo                        AS CodigoDepartamento,
    s.NroSala, s.CidadeUnidade, s.EstadoUnidade, s.PaisUnidade,
    u.Cidade,  u.Estado,        u.Pais
FROM deptos_sem_curso d
JOIN LATERAL (SELECT * FROM Sala    ORDER BY random() LIMIT 1) s ON TRUE
JOIN LATERAL (SELECT * FROM Unidade ORDER BY random() LIMIT 1) u ON TRUE;

WITH novos AS (
    SELECT Codigo
    FROM   Curso
    WHERE  Nome LIKE 'Curso auto %'
)
INSERT INTO ComposicaoCurso (CodigoCurso, SiglaDisciplina)
SELECT n.Codigo,
       d.Sigla
FROM   novos      n
JOIN   Disciplina d ON random() < 0.35
WHERE  NOT EXISTS (
          SELECT 1
          FROM   ComposicaoCurso cc
          WHERE  cc.CodigoCurso     = n.Codigo
          AND    cc.SiglaDisciplina = d.Sigla
);


WITH profs AS (
  SELECT
    Nome,
    Sobrenome,
    Telefone,
    (1 + floor(random()*4))::int AS num_turmas_por_periodo
  FROM   Usuario
  WHERE  Tipo = 'professor'
),

periodos(PeriodoLetivo) AS (
  VALUES ('2025.1'),
         ('2024.2'),
         ('2024.1'),
         ('2023.2'),
         ('2023.1')
),


ofertas AS (
  SELECT
    pr.Nome,
    pr.Sobrenome,
    pr.Telefone,
    p.PeriodoLetivo,
    d.Sigla                               AS SiglaDisciplina,


    make_date(
        split_part(p.PeriodoLetivo,'.',1)::int,
        CASE split_part(p.PeriodoLetivo,'.',2)
             WHEN '1' THEN  2
             WHEN '2' THEN  7
             WHEN '3' THEN 11
        END,
        1
    ) + (floor(random()*30))::int         AS DataMaxMatricula,


    s.NroSala,
    s.CidadeUnidade   AS CidadeSala,
    s.EstadoUnidade   AS EstadoSala,
    s.PaisUnidade     AS PaisSala
  FROM  profs pr
  CROSS JOIN periodos p

  JOIN LATERAL (
      SELECT Sigla
      FROM   Disciplina
      ORDER  BY random()
      LIMIT  pr.num_turmas_por_periodo
  ) d ON TRUE

  JOIN LATERAL (
      SELECT *
      FROM   Sala
      ORDER  BY random()
      LIMIT  1
  ) s ON TRUE
)

INSERT INTO Oferecimento (
  PeriodoLetivo,
  SiglaDisciplina,
  NomeProf,
  SobrenomeProf,
  TelefoneProf,
  DataMaxMatricula,
  NroSala,
  CidadeSala,
  EstadoSala,
  PaisSala
)
SELECT
  PeriodoLetivo,
  SiglaDisciplina,
  Nome,
  Sobrenome,
  Telefone,
  DataMaxMatricula,
  NroSala,
  CidadeSala,
  EstadoSala,
  PaisSala
FROM ofertas;


WITH candidatas AS (
    SELECT c.Codigo                AS cod_curso,
           d.Sigla                 AS sigla_disc,
           row_number() OVER (PARTITION BY c.Codigo) AS ordem_curso
    FROM   Curso c
    CROSS  JOIN LATERAL (
           SELECT Sigla
           FROM   Disciplina
           ORDER  BY random()
           LIMIT  6
    ) d
), ranqueadas AS (
    SELECT  ca.*,
            row_number() OVER (PARTITION BY sigla_disc
                               ORDER BY cod_curso)  AS vez_da_disciplina
    FROM    candidatas ca
)
INSERT INTO ComposicaoCurso (CodigoCurso, SiglaDisciplina)
SELECT cod_curso, sigla_disc
FROM   ranqueadas
WHERE  ordem_curso      <= 3 + floor(random()*4)
  AND  vez_da_disciplina<= 2
ORDER  BY cod_curso;

WITH pares AS (
    SELECT c1.Codigo AS curso ,
           c2.Codigo AS prereq ,
           row_number() OVER (PARTITION BY c1.Codigo) AS ordem
    FROM   Curso c1
    CROSS  JOIN LATERAL (
           SELECT Codigo
           FROM   Curso
           WHERE  Codigo <> c1.Codigo
           ORDER  BY random()
           LIMIT  3
    ) c2
)
INSERT INTO CursoPreRequisito (CodigoCurso, CodigoCursoPreReq)
SELECT curso, prereq
FROM   pares
WHERE  ordem <= floor(random()*3)
AND    NOT EXISTS (
          SELECT 1
          FROM   CursoPreRequisito cp
          WHERE  cp.CodigoCurso       = curso
          AND    cp.CodigoCursoPreReq = prereq
       );

WITH candidatos AS (
    SELECT cc.CodigoCurso,
           pre.SiglaDisciplina,
           row_number() OVER (PARTITION BY cc.CodigoCurso,
                                            cc.SiglaDisciplina) AS ordem
    FROM   ComposicaoCurso cc
    CROSS  JOIN LATERAL (
           SELECT cc2.SiglaDisciplina
           FROM   ComposicaoCurso cc2
           WHERE  cc2.CodigoCurso      = cc.CodigoCurso
           AND    cc2.SiglaDisciplina <> cc.SiglaDisciplina
           ORDER  BY random()
           LIMIT  3
    ) pre
)
INSERT INTO DisciplinaPreRequisito (CodigoCurso, SiglaDisciplina)
SELECT DISTINCT
       CodigoCurso,
       SiglaDisciplina
FROM   candidatos
WHERE  ordem <= floor(random()*3)
AND    NOT EXISTS (
          SELECT 1
          FROM   DisciplinaPreRequisito dp
          WHERE  dp.CodigoCurso      = candidatos.CodigoCurso
          AND    dp.SiglaDisciplina = candidatos.SiglaDisciplina
       );




WITH candidatos AS (
  SELECT
    trim(format('%s.%s', 2025 - (gs % 4), 1 + gs % 3)) AS PeriodoLetivo,
    d.Sigla                AS SiglaDisc,


    p.Nome, p.Sobrenome, p.Telefone,


    make_date(
        split_part(trim(format('%s.%s', 2025 - (gs % 4), 1 + gs % 3)),'.',1)::int,
        CASE split_part(trim(format('%s.%s', 2025 - (gs % 4), 1 + gs % 3)),'.',2)
             WHEN '1' THEN 2
             WHEN '2' THEN 7
             WHEN '3' THEN 11
        END,
        1
    ) + (floor(random()*30))::int       AS DataMax,

    s.NroSala, s.CidadeUnidade, s.EstadoUnidade, s.PaisUnidade
  FROM generate_series(1,4000) gs


  CROSS JOIN LATERAL (
      SELECT Sigla
      FROM   Disciplina
      ORDER  BY random()
      LIMIT  1
  ) d


  JOIN LATERAL (
      SELECT *
      FROM   Usuario
      WHERE  Tipo = 'professor'
      ORDER  BY random()
      LIMIT  1
  ) p ON TRUE


  JOIN LATERAL (
      SELECT *
      FROM   Sala
      ORDER  BY random()
      LIMIT  1
  ) s ON TRUE
)
, unicos AS (
  SELECT DISTINCT ON (PeriodoLetivo, SiglaDisc, Nome, Sobrenome, Telefone) *
  FROM   candidatos
  ORDER  BY PeriodoLetivo, SiglaDisc, Nome, Sobrenome, Telefone, random()
  LIMIT  1800
)
INSERT INTO Oferecimento (
  PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf,
  DataMaxMatricula, NroSala, CidadeSala, EstadoSala, PaisSala
)
SELECT
  PeriodoLetivo, SiglaDisc, Nome, Sobrenome, Telefone,
  DataMax, NroSala, CidadeUnidade, EstadoUnidade, PaisUnidade
FROM   unicos;



WITH alunos AS (
  SELECT Nome, Sobrenome, Telefone
  FROM   Usuario
  WHERE  Tipo = 'aluno'
)

INSERT INTO MatricularOferecimento (
  NomeAluno, SobrenomeAluno, TelefoneAluno,
  PeriodoLetivo, SiglaDisciplina,
  NomeProf, SobrenomeProf, TelefoneProf,
  DataMatricula, Status, Taxa
)
SELECT
  a.Nome, a.Sobrenome, a.Telefone,
  o.PeriodoLetivo, o.SiglaDisciplina,
  o.NomeProf,  o.SobrenomeProf,  o.TelefoneProf,
  o.DataMaxMatricula - (1 + floor(random()*15))::int               AS DataMatricula,

  CASE
    WHEN o.PeriodoLetivo = '2025.1' THEN
         CASE
           WHEN random() < 0.05 THEN 'cancelada'
           WHEN random() < 0.20 THEN 'pendente'
           ELSE 'confirmada'
         END
    ELSE
         CASE
           WHEN random() < 0.05 THEN 'cancelada'
           WHEN random() < 0.15 THEN 'trancada'
           WHEN random() < 0.30 THEN 'reprovada'
           ELSE                     'concluida'
         END
  END                                                             AS Status,

  round((random()*500)::numeric, 2)                               AS Taxa

FROM Oferecimento o
JOIN Disciplina d ON d.Sigla = o.SiglaDisciplina

JOIN LATERAL (
  SELECT *
  FROM   alunos
  ORDER  BY random()
  LIMIT  ( ceil(d.CapacidadeTurma*0.70)
          + floor(random()*ceil(d.CapacidadeTurma*0.25)) )
) a ON TRUE;

INSERT INTO NotasMatricula (
  NomeAluno, SobrenomeAluno, TelefoneAluno,
  PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf,
  Nota
)
SELECT
  NomeAluno, SobrenomeAluno, TelefoneAluno,
  PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf,
  round((random()*10)::numeric, 1)
FROM MatricularOferecimento
WHERE Status = 'confirmada';

INSERT INTO BolsasMatricula (
  NomeAluno, SobrenomeAluno, TelefoneAluno,
  PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf,
  Bolsa
)
SELECT
  NomeAluno, SobrenomeAluno, TelefoneAluno,
  PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf,
  (ARRAY['CNPq','CAPES','FAPESP','Institutional'])[1 + floor(random()*4)]
FROM MatricularOferecimento
WHERE random() < 0.1;

INSERT INTO DescontosMatricula (
  NomeAluno, SobrenomeAluno, TelefoneAluno,
  PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf,
  Desconto
)
SELECT
  NomeAluno, SobrenomeAluno, TelefoneAluno,
  PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf,
  round((random()*50)::numeric, 2)
FROM MatricularOferecimento
WHERE random() < 0.15;

INSERT INTO Grupo(Id)
SELECT lpad(gs::text,6,'0') FROM generate_series(1,80) gs;

INSERT INTO GrupoUsuarios (GrupoId, NomeUsuario, SobrenomeUsuario, TelefoneUsuario)
SELECT
        g.Id,
        u.Nome, u.Sobrenome, u.Telefone
FROM    Usuario u
JOIN LATERAL ( SELECT Id
               FROM   Grupo
               ORDER  BY random()
               LIMIT  1 ) g   ON TRUE
WHERE   u.Tipo = 'aluno'
  AND   NOT EXISTS (
          SELECT 1
          FROM   GrupoUsuarios gu
          WHERE  gu.NomeUsuario     = u.Nome
          AND    gu.SobrenomeUsuario= u.Sobrenome
          AND    gu.TelefoneUsuario = u.Telefone );

WITH limites AS (
  SELECT
    gu.GrupoId,
    gu.NomeUsuario,
    gu.SobrenomeUsuario,
    gu.TelefoneUsuario,
    (10 + floor(random()*2991))::int AS qt_msgs
  FROM GrupoUsuarios gu
),


series AS (
  SELECT
    l.GrupoId,
    l.NomeUsuario,
    l.SobrenomeUsuario,
    l.TelefoneUsuario,
    generate_series(1, l.qt_msgs) AS gs
  FROM limites l
),

base AS (
  SELECT
    (now() - (random() * '90 days'::interval))
    + (row_number() OVER (ORDER BY GrupoId, NomeUsuario, SobrenomeUsuario, TelefoneUsuario, gs)
       * '1 microsecond'::interval)
    AS ts,
    GrupoId,
    NomeUsuario,
    SobrenomeUsuario,
    TelefoneUsuario,
    row_number() OVER (ORDER BY GrupoId, NomeUsuario, SobrenomeUsuario, TelefoneUsuario, gs)
      AS rn
  FROM series
)

INSERT INTO Mensagem (
  TimestampData,
  TimestampHorario,
  GrupoId,
  UsuarioEmissorNome,
  UsuarioEmissorSobrenome,
  UsuarioEmissorTelefone,
  Texto
)
SELECT
  date(ts)                             AS TimestampData,
  ts::time(3)                          AS TimestampHorario,
  GrupoId,
  NomeUsuario,
  SobrenomeUsuario,
  TelefoneUsuario,
  'Mensagem ' || rn                    AS Texto
FROM base;