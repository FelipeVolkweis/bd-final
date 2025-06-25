DROP SCHEMA public CASCADE;
CREATE SCHEMA public;
SET search_path TO public;

CREATE TABLE Unidade (
    Cidade VARCHAR(50) CHECK (Cidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    Estado VARCHAR(50) CHECK (Estado ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    Pais VARCHAR(50) CHECK (Pais ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    Bloco VARCHAR(10) CHECK (Bloco IS NULL OR Bloco ~ '^[A-Za-z0-9]{{1,10}}$'),
    Predio VARCHAR(10) CHECK (Predio IS NULL OR Predio ~ '^[A-Za-z0-9]{{1,10}}$'),
    PRIMARY KEY (Cidade, Estado, Pais)
);

CREATE TABLE Sala (
    NroSala VARCHAR(4) CHECK (NroSala ~ '^[0-9]{{1,4}}$'),
    CidadeUnidade VARCHAR(50) CHECK (CidadeUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    EstadoUnidade VARCHAR(50) CHECK (EstadoUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    PaisUnidade VARCHAR(50) CHECK (PaisUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    Capacidade INTEGER CHECK (Capacidade BETWEEN 1 AND 9999),
    PRIMARY KEY (NroSala, CidadeUnidade, EstadoUnidade, PaisUnidade),
    FOREIGN KEY (CidadeUnidade, EstadoUnidade, PaisUnidade) REFERENCES Unidade (Cidade, Estado, Pais)
);

CREATE TABLE Usuario (
    Nome VARCHAR(50) CHECK (Nome ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    Sobrenome VARCHAR(50) CHECK (Sobrenome ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    Telefone VARCHAR(15) CHECK (Telefone ~ '^[0-9]{{8,15}}$'),
    DataNasc DATE NOT NULL,
    EnderecoCep VARCHAR(8) NOT NULL CHECK (EnderecoCep ~ '^[0-9]{{8}}$'),
    EnderecoNumero VARCHAR(10) NOT NULL CHECK (EnderecoNumero ~ '^[A-Za-z0-9]{{1,10}}$'),
    EnderecoBairro VARCHAR(50) NOT NULL CHECK (EnderecoBairro ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    Sexo CHAR(1) NOT NULL CHECK (Sexo IN ('M', 'F', 'O')),
    Email VARCHAR(255) NOT NULL UNIQUE CHECK (Email ~ '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{{2,}}$'),
    Senha VARCHAR(255) NOT NULL CHECK (char_length(Senha) BETWEEN 8 AND 255),
    Tipo VARCHAR(12) NOT NULL CHECK (Tipo IN ('aluno', 'professor', 'funcionario')),
    Area VARCHAR(100) CHECK (Area ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,100}}$'),
    Titulacao VARCHAR(20) CHECK (Titulacao ~ '^[A-Za-z0-9. ]{{2,20}}$'),
    CidadeUnidade VARCHAR(50) NOT NULL CHECK (CidadeUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    EstadoUnidade VARCHAR(50) NOT NULL CHECK (EstadoUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    PaisUnidade VARCHAR(50) NOT NULL CHECK (PaisUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    PRIMARY KEY (Nome, Sobrenome, Telefone),
    FOREIGN KEY (CidadeUnidade, EstadoUnidade, PaisUnidade) REFERENCES Unidade (Cidade, Estado, Pais)
);

CREATE TABLE Departamento (
    Codigo VARCHAR(6) CHECK (Codigo ~ '^[0-9]{{1,6}}$'),
    Nome VARCHAR(100) NOT NULL CHECK (Nome ~ '^[A-Za-zÀ-ÖØ-öø-ÿ0-9 .,]{{2,100}}$'),
    NomeProfChefe VARCHAR(50) NOT NULL CHECK (NomeProfChefe ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProfChefe VARCHAR(50) NOT NULL CHECK (SobrenomeProfChefe ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProfChefe VARCHAR(15) NOT NULL CHECK (TelefoneProfChefe ~ '^[0-9]{{8,15}}$'),
    PRIMARY KEY (Codigo),
    FOREIGN KEY (NomeProfChefe, SobrenomeProfChefe, TelefoneProfChefe) REFERENCES Usuario (Nome, Sobrenome, Telefone)
);

CREATE TABLE Disciplina (
    Sigla VARCHAR(10) CHECK (Sigla ~ '^[A-Z0-9]{{1,10}}$'),
    CapacidadeTurma INTEGER NOT NULL CHECK (CapacidadeTurma BETWEEN 1 AND 999),
    MaterialBasico VARCHAR(500) CHECK (char_length(MaterialBasico) <= 500),
    NroAulasSemanais INTEGER NOT NULL CHECK (NroAulasSemanais BETWEEN 1 AND 999),
    CidadeUnidade VARCHAR(50) CHECK (CidadeUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    EstadoUnidade VARCHAR(50) CHECK (EstadoUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    PaisUnidade VARCHAR(50) CHECK (PaisUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    PRIMARY KEY (Sigla),
    FOREIGN KEY (CidadeUnidade, EstadoUnidade, PaisUnidade) REFERENCES Unidade (Cidade, Estado, Pais)
);

CREATE TABLE Curso (
    Codigo VARCHAR(6) CHECK (Codigo ~ '^[0-9]{{1,6}}$'),
    Nome VARCHAR(100) NOT NULL CHECK (Nome ~ '^[A-Za-zÀ-ÖØ-öø-ÿ0-9 .,]{{2,100}}$'),
    NivelEnsino VARCHAR(12) NOT NULL CHECK (NivelEnsino IN ('fundamental','médio','técnico','graduação')),
    Ementa VARCHAR(500) NOT NULL CHECK (char_length(Ementa) <= 500),
    CargaHoraria VARCHAR(6) NOT NULL CHECK (CargaHoraria ~ '^[0-9]{{1,6}}$'),
    NumeroVagas INTEGER NOT NULL CHECK (NumeroVagas BETWEEN 1 AND 999999),
    NroSala VARCHAR(4) CHECK (NroSala ~ '^[0-9]{{1,4}}$'),
    CidadeSala VARCHAR(50) CHECK (CidadeSala ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    EstadoSala VARCHAR(50) CHECK (EstadoSala ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    PaisSala VARCHAR(50) CHECK (PaisSala ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    CodigoDepartamento VARCHAR(6) NOT NULL CHECK (CodigoDepartamento ~ '^[0-9]{{1,6}}$'),
    CidadeUnidade VARCHAR(50) CHECK (CidadeUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    EstadoUnidade VARCHAR(50) CHECK (EstadoUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    PaisUnidade VARCHAR(50) CHECK (PaisUnidade ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    PRIMARY KEY (Codigo),
    FOREIGN KEY (NroSala, CidadeSala, EstadoSala, PaisSala) REFERENCES Sala (NroSala, CidadeUnidade, EstadoUnidade, PaisUnidade),
    FOREIGN KEY (CodigoDepartamento) REFERENCES Departamento (Codigo),
    FOREIGN KEY (CidadeUnidade, EstadoUnidade, PaisUnidade) REFERENCES Unidade (Cidade, Estado, Pais)
);

CREATE TABLE Grupo (
    Id VARCHAR(6) CHECK (Id ~ '^[0-9]{{1,6}}$'),
    PRIMARY KEY (Id)
);

CREATE TABLE Mensagem (
    TimestampData DATE,
    TimestampHorario TIME,
    GrupoId VARCHAR(6) CHECK (GrupoId ~ '^[0-9]{{1,6}}$'),
    UsuarioEmissorNome VARCHAR(50) CHECK (UsuarioEmissorNome ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    UsuarioEmissorSobrenome VARCHAR(50) CHECK (UsuarioEmissorSobrenome ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    UsuarioEmissorTelefone VARCHAR(15) CHECK (UsuarioEmissorTelefone ~ '^[0-9]{{8,15}}$'),
    Texto VARCHAR(1000) NOT NULL CHECK (Texto !~ '[^A-Za-zÀ-ÖØ-öø-ÿ0-9 .,]'),
    PRIMARY KEY (TimestampData, TimestampHorario, GrupoId, UsuarioEmissorNome, UsuarioEmissorSobrenome, UsuarioEmissorTelefone),
    FOREIGN KEY (GrupoId) REFERENCES Grupo (Id),
    FOREIGN KEY (UsuarioEmissorNome, UsuarioEmissorSobrenome, UsuarioEmissorTelefone) REFERENCES Usuario (Nome, Sobrenome, Telefone)
);

CREATE TABLE Oferecimento (
    PeriodoLetivo VARCHAR(6) CHECK (PeriodoLetivo ~ '^[0-9]{{4}}\.[1-3]$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    NomeProf VARCHAR(50) CHECK (NomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProf VARCHAR(50) CHECK (SobrenomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProf VARCHAR(15) CHECK (TelefoneProf ~ '^[0-9]{{8,15}}$'),
    DataMaxMatricula DATE NOT NULL,
    NroSala VARCHAR(4) NOT NULL CHECK (NroSala ~ '^[0-9]{{1,4}}$'),
    CidadeSala VARCHAR(50) NOT NULL CHECK (CidadeSala ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    EstadoSala VARCHAR(50) NOT NULL CHECK (EstadoSala ~ '^[A-Za-zÀ-ÖØ-öø-ÿ ]{{2,50}}$'),
    PaisSala VARCHAR(50) NOT NULL CHECK (PaisSala ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    PRIMARY KEY (PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf),
    FOREIGN KEY (SiglaDisciplina) REFERENCES Disciplina (Sigla),
    FOREIGN KEY (NomeProf, SobrenomeProf, TelefoneProf) REFERENCES Usuario (Nome, Sobrenome, Telefone),
    FOREIGN KEY (NroSala, CidadeSala, EstadoSala, PaisSala) REFERENCES Sala (NroSala, CidadeUnidade, EstadoUnidade, PaisUnidade)
);

CREATE TABLE AvaliarOferecimento (
    NomeAluno VARCHAR(50) CHECK (NomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeAluno VARCHAR(50) CHECK (SobrenomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneAluno VARCHAR(15) CHECK (TelefoneAluno ~ '^[0-9]{{8,15}}$'),
    PeriodoLetivo VARCHAR(6) CHECK (PeriodoLetivo ~ '^[0-9]{{4}}\.[1-3]$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    NomeProf VARCHAR(50) CHECK (NomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProf VARCHAR(50) CHECK (SobrenomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProf VARCHAR(15) CHECK (TelefoneProf ~ '^[0-9]{{8,15}}$'),
    Texto VARCHAR(1000) CHECK (Texto !~ '[^A-Za-zÀ-ÖØ-öø-ÿ0-9 .,]'),

    NotaDidatica NUMERIC(3,1) CHECK (NotaDidatica BETWEEN 0.0 AND 10.0 OR NotaDidatica IS NULL),
    NotaMaterial NUMERIC(3,1) CHECK (NotaMaterial BETWEEN 0.0 AND 10.0 OR NotaMaterial IS NULL),
    NotaConteudo NUMERIC(3,1) CHECK (NotaConteudo BETWEEN 0.0 AND 10.0 OR NotaConteudo IS NULL),
    NotaInfra NUMERIC(3,1) CHECK (NotaInfra BETWEEN 0.0 AND 10.0 OR NotaInfra IS NULL),

    CHECK (
      Texto IS NOT NULL OR
      NotaDidatica IS NOT NULL OR
      NotaMaterial IS NOT NULL OR
      NotaConteudo IS NOT NULL OR
      NotaInfra IS NOT NULL
    ),

    PRIMARY KEY (NomeAluno, SobrenomeAluno, TelefoneAluno, PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf),
    FOREIGN KEY (NomeAluno, SobrenomeAluno, TelefoneAluno) REFERENCES Usuario (Nome, Sobrenome, Telefone),
    FOREIGN KEY (PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf) REFERENCES Oferecimento (PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf)
);


CREATE TABLE MatricularOferecimento (
    NomeAluno VARCHAR(50) CHECK (NomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeAluno VARCHAR(50) CHECK (SobrenomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneAluno VARCHAR(15) CHECK (TelefoneAluno ~ '^[0-9]{{8,15}}$'),
    PeriodoLetivo VARCHAR(6) CHECK (PeriodoLetivo ~ '^[0-9]{{4}}\.[1-3]$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    NomeProf VARCHAR(50) CHECK (NomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProf VARCHAR(50) CHECK (SobrenomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProf VARCHAR(15) CHECK (TelefoneProf ~ '^[0-9]{{8,15}}$'),
    DataMatricula DATE NOT NULL,
    Status VARCHAR(20) NOT NULL CHECK (Status IN ('confirmada','pendente','cancelada','concluida','reprovada','trancada')),
    Taxa NUMERIC(10,2),
    PRIMARY KEY (NomeAluno, SobrenomeAluno, TelefoneAluno, PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf),
    FOREIGN KEY (NomeAluno, SobrenomeAluno, TelefoneAluno) REFERENCES Usuario (Nome, Sobrenome, Telefone),
    FOREIGN KEY (PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf) REFERENCES Oferecimento (PeriodoLetivo, SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf)
);

CREATE TABLE DisciplinaPreRequisito (
    CodigoCurso VARCHAR(6) CHECK (CodigoCurso ~ '^[0-9]{{1,6}}$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    PRIMARY KEY (CodigoCurso, SiglaDisciplina),
    FOREIGN KEY (CodigoCurso) REFERENCES Curso (Codigo),
    FOREIGN KEY (SiglaDisciplina) REFERENCES Disciplina (Sigla)
);

CREATE TABLE CursoPreRequisito (
    CodigoCurso VARCHAR(6) CHECK (CodigoCurso ~ '^[0-9]{{1,6}}$'),
    CodigoCursoPreReq VARCHAR(6) CHECK (CodigoCursoPreReq ~ '^[0-9]{{1,6}}$'),
    PRIMARY KEY (CodigoCurso, CodigoCursoPreReq),
    FOREIGN KEY (CodigoCurso) REFERENCES Curso (Codigo),
    FOREIGN KEY (CodigoCursoPreReq) REFERENCES Curso (Codigo)
);

CREATE TABLE ComposicaoCurso (
    CodigoCurso VARCHAR(6) CHECK (CodigoCurso ~ '^[0-9]{{1,6}}$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    PRIMARY KEY (CodigoCurso, SiglaDisciplina),
    FOREIGN KEY (CodigoCurso) REFERENCES Curso (Codigo),
    FOREIGN KEY (SiglaDisciplina) REFERENCES Disciplina (Sigla)
);

CREATE TABLE DisciplinasEResponsaveis (
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    NomeProf VARCHAR(50) CHECK (NomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProf VARCHAR(50) CHECK (SobrenomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProf VARCHAR(15) CHECK (TelefoneProf ~ '^[0-9]{{8,15}}$'),
    PRIMARY KEY (SiglaDisciplina, NomeProf, SobrenomeProf, TelefoneProf),
    FOREIGN KEY (SiglaDisciplina) REFERENCES Disciplina (Sigla),
    FOREIGN KEY (NomeProf, SobrenomeProf, TelefoneProf) REFERENCES Usuario (Nome, Sobrenome, Telefone)
);

CREATE TABLE GrupoUsuarios (
    GrupoId VARCHAR(6) CHECK (GrupoId ~ '^[0-9]{{1,6}}$'),
    NomeUsuario VARCHAR(50) CHECK (NomeUsuario ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeUsuario VARCHAR(50) CHECK (SobrenomeUsuario ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneUsuario VARCHAR(15) CHECK (TelefoneUsuario ~ '^[0-9]{{8,15}}$'),
    PRIMARY KEY (GrupoId, NomeUsuario, SobrenomeUsuario, TelefoneUsuario),
    FOREIGN KEY (GrupoId) REFERENCES Grupo (Id),
    FOREIGN KEY (NomeUsuario, SobrenomeUsuario, TelefoneUsuario) REFERENCES Usuario (Nome, Sobrenome, Telefone)
);

CREATE TABLE RegrasCurso (
    CodigoCurso VARCHAR(6) CHECK (CodigoCurso ~ '^[0-9]{{1,6}}$'),
    Regra VARCHAR(100) CHECK (Regra ~ '^[A-Za-zÀ-ÖØ-öø-ÿ0-9 .,]{{1,100}}$'),
    PRIMARY KEY (CodigoCurso, Regra),
    FOREIGN KEY (CodigoCurso) REFERENCES Curso (Codigo)
);

CREATE TABLE InfraestruturaCurso (
    CodigoCurso VARCHAR(6) CHECK (CodigoCurso ~ '^[0-9]{{1,6}}$'),
    Infraestrutura VARCHAR(100) CHECK (Infraestrutura ~ '^[A-Za-zÀ-ÖØ-öø-ÿ0-9 .,]{{1,100}}$'),
    PRIMARY KEY (CodigoCurso, Infraestrutura),
    FOREIGN KEY (CodigoCurso) REFERENCES Curso (Codigo)
);

CREATE TABLE NotasMatricula (
    NomeAluno VARCHAR(50) CHECK (NomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeAluno VARCHAR(50) CHECK (SobrenomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneAluno VARCHAR(15) CHECK (TelefoneAluno ~ '^[0-9]{{8,15}}$'),
    PeriodoLetivo VARCHAR(6) CHECK (PeriodoLetivo ~ '^[0-9]{{4}}\.[1-3]$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    NomeProf VARCHAR(50) CHECK (NomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProf VARCHAR(50) CHECK (SobrenomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProf VARCHAR(15) CHECK (TelefoneProf ~ '^[0-9]{{8,15}}$'),
    Nota NUMERIC(3,1) CHECK (Nota BETWEEN 0.0 AND 10.0),
    PRIMARY KEY (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf, Nota
    ),
    FOREIGN KEY (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf
    )
        REFERENCES MatricularOferecimento (
            NomeAluno, SobrenomeAluno, TelefoneAluno,
            PeriodoLetivo, SiglaDisciplina,
            NomeProf, SobrenomeProf, TelefoneProf
        )
);

CREATE TABLE BolsasMatricula (
    NomeAluno VARCHAR(50) CHECK (NomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeAluno VARCHAR(50) CHECK (SobrenomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneAluno VARCHAR(15) CHECK (TelefoneAluno ~ '^[0-9]{{8,15}}$'),
    PeriodoLetivo VARCHAR(6) CHECK (PeriodoLetivo ~ '^[0-9]{{4}}\.[1-3]$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    NomeProf VARCHAR(50) CHECK (NomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProf VARCHAR(50) CHECK (SobrenomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProf VARCHAR(15) CHECK (TelefoneProf ~ '^[0-9]{{8,15}}$'),
    Bolsa VARCHAR(100) CHECK (Bolsa ~ '^[A-Za-zÀ-ÖØ-öø-ÿ0-9 .,]{{1,100}}$'),
    PRIMARY KEY (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf, Bolsa
    ),
    FOREIGN KEY (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf
    ) REFERENCES MatricularOferecimento (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf
    )
);


CREATE TABLE DescontosMatricula (
    NomeAluno VARCHAR(50) CHECK (NomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeAluno VARCHAR(50) CHECK (SobrenomeAluno ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneAluno VARCHAR(15) CHECK (TelefoneAluno ~ '^[0-9]{{8,15}}$'),
    PeriodoLetivo VARCHAR(6) CHECK (PeriodoLetivo ~ '^[0-9]{{4}}\.[1-3]$'),
    SiglaDisciplina VARCHAR(10) CHECK (SiglaDisciplina ~ '^[A-Z0-9]{{1,10}}$'),
    NomeProf VARCHAR(50) CHECK (NomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    SobrenomeProf VARCHAR(50) CHECK (SobrenomeProf ~ '^[A-Za-zÀ-ÖØ-öø-ÿ]{{2,50}}$'),
    TelefoneProf VARCHAR(15) CHECK (TelefoneProf ~ '^[0-9]{{8,15}}$'),
    Desconto NUMERIC(5,2) CHECK (Desconto BETWEEN 0.0 AND 100.0),
    PRIMARY KEY (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf, Desconto
    ),
    FOREIGN KEY (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf
    ) REFERENCES MatricularOferecimento (
        NomeAluno, SobrenomeAluno, TelefoneAluno,
        PeriodoLetivo, SiglaDisciplina,
        NomeProf, SobrenomeProf, TelefoneProf
    )
);