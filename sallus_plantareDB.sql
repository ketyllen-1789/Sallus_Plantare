-- =========================================================================
-- ATIVIDADE AVALIATIVA : TRANSFORMAÇÃO DO MODELO CONCEITUAL (DER)
-- SISTEMA: SALLUS PLANTARE - GERENCIADOR DE PLANTÕES MÉDICOS
-- =========================================================================

DROP DATABASE IF EXISTS Sallus_plantare;
CREATE DATABASE Sallus_plantare;
USE Sallus_plantare;

-- =========================================================================
-- 1. TABELA PROFISSIONAL DE SAUDE (Entidade Independente / Alocação)
-- CONCEITO: Centraliza os profissionais (Médicos, Enfermeiros) aptos a assumir plantões.
-- ARQUITETURA: Evita o uso de chaves primárias naturais complexas adotando 'idProfissional_de_saude'.
-- SEGURANÇA: Mantém o CPF e o Registro de Classe protegidos com regras UNIQUE no banco.
-- =========================================================================
CREATE TABLE Profissional_de_saude (
-- SURROGATE KEY: Garante estabilidade física para chaves estrangeiras na tabela de plantões
idProfissional_de_saude INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

nome VARCHAR(125) NOT NULL,

-- CHAVE NATURAL 1: O CPF identifica unicamente o cidadão e possui restrição UNIQUE
CPF VARCHAR(11) NOT NULL UNIQUE,

cargo ENUM('Médico(a)', 'Enfermeiro(a)', 'Técnico(a) em Enfermagem') NOT NULL,
especialidade VARCHAR(50) NOT NULL DEFAULT 'Geral',




-- CHAVE NATURAL COMPOSTA (PARTE 1): Componentes do conselho profissional (CRM/COREN)
numero_registro VARCHAR(15) NOT NULL,
uf_registro CHAR(2) NOT NULL,

-- MAPEAMENTO ATÔMICO DO ENDEREÇO RESIDENCIAL (1FN)
logradouro VARCHAR(150) NOT NULL,
numero_endereco VARCHAR(10) NOT NULL,
bairro VARCHAR(60) NOT NULL,
cidade VARCHAR(60) NOT NULL,
uf_endereco CHAR(2) NOT NULL,
cep CHAR(8) NOT NULL,

-- CHAVE NATURAL UNIQUE COMPOSTA: Impede que um mesmo número de conselho seja clonado no mesmo estado
UNIQUE KEY uq_registro_estado (numero_registro, uf_registro)


) ENGINE=InnoDB;

-- =========================================================================
-- 1.1 TABELA PROFISSIONAL_EMAIL (Normalização Multivalorada do Gerenciador)
-- CONCEITO: Isola os canais de contato de avisos de plantão do profissional (1FN).
-- DEPENDÊNCIA: Vincula-se diretamente à Surrogate Key da tabela principal de saúde.
-- =========================================================================
CREATE TABLE ProfissionalEmail (
idProfissional_de_saude INT UNSIGNED NOT NULL,
email VARCHAR(100) NOT NULL,

-- Chave Primária Composta interna
PRIMARY KEY (idProfissional_de_saude, email),

-- Chave Estrangeira: Depende diretamente de Profissional_de_saude
CONSTRAINT fk_profissional_email
FOREIGN KEY (idProfissional_de_saude)
REFERENCES Profissional_de_saude(idProfissional_de_saude)
ON DELETE CASCADE
ON UPDATE CASCADE
) ENGINE=InnoDB;

-- =========================================================================
-- 2. TABELA INSTITUICAO_MEDICA (Entidade Independente / Local do Plantão)
-- CONCEITO: Cadastra os hospitais, UPAs e clínicas onde as escalas acontecem.
-- ARQUITETURA: Usa idInstituicao como Surrogate Key para simplificar os relacionamentos.
-- RESTRICÃO: Garante a unicidade do estabelecimento usando o CNPJ como Chave Natural UNIQUE.
-- =========================================================================
CREATE TABLE Instituicao_medica (
-- SURROGATE KEY: Chave primária artificial criada pelo sistema para indexação rápida
idInstituicao INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

nome_fantasia VARCHAR(100) NOT NULL,
razao_social VARCHAR(150) NOT NULL UNIQUE,

-- CHAVE NATURAL: Identificador fiscal real do hospital, protegido contra duplicidade
CNPJ CHAR(14) NOT NULL UNIQUE,

tipo_estabelecimento ENUM('Hospital', 'UPA', 'UBS', 'Clínica Privada') NOT NULL,

-- MAPEAMENTO ATÔMICO DE ENDEREÇO (Garante conformidade com a 1ª Forma Normal)
logradouro VARCHAR(150) NOT NULL,
numero VARCHAR(10) NOT NULL,
bairro VARCHAR(60) NOT NULL,
cidade VARCHAR(60) NOT NULL,
uf CHAR(2) NOT NULL,
cep CHAR(8) NOT NULL
) ENGINE=InnoDB;

-- =========================================================================
-- 3. TABELA PLANTAO (Entidade Dependente / O Núcleo do Gerenciador de Escalas)
-- CONCEITO: Consolida o agendamento cruzando o profissional escalado e o hospital local.
-- RELACIONAMENTO N:M RESOLVIDO: Traz as chaves substitutas das tabelas pai como Foreign Keys.
-- =========================================================================
CREATE TABLE Plantao (
-- SURROGATE KEY DO PLANTÃO
idPlantao INT UNSIGNED NOT NULL AUTO_INCREMENT PRIMARY KEY,

data_plantao DATE NOT NULL,
turno ENUM('Matutino', 'Vespertino', 'Noturno', 'Plantão 24h') NOT NULL,
setor ENUM('UTI Adulto', 'UTI Pediátrica', 'Emergência/Pronto Socorro', 'Enfermaria', 'Centro Cirúrgico') NOT NULL,
status_plantao ENUM('Agendado', 'Confirmado', 'Realizado', 'Cancelado') NOT NULL DEFAULT 'Agendado',

-- CHAVES ESTRANGEIRAS (FK): Referenciam as tabelas que foram criadas acima
idInstituicao INT UNSIGNED NOT NULL,
idProfissional_de_saude INT UNSIGNED NOT NULL,

CONSTRAINT fk_plantao_instituicao
FOREIGN KEY (idInstituicao)
REFERENCES Instituicao_medica(idInstituicao)
ON DELETE RESTRICT
ON UPDATE CASCADE,

CONSTRAINT fk_plantao_profissional
FOREIGN KEY (idProfissional_de_saude)
REFERENCES Profissional_de_saude(idProfissional_de_saude)
ON DELETE RESTRICT
ON UPDATE CASCADE
) ENGINE=InnoDB;

