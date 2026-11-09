CREATE DATABASE IF NOT EXISTS db_sistema_integrado_views;
USE db_sistema_integrado_views;

-- 1. LIMPEZA E CRIAÇÃO DAS TABELAS
DROP VIEW IF EXISTS
    vw_pao_disponivel,
    vw_cliente_resumo,
    vw_ingredientes_estoque,
    vw_vendas_por_dia,
    vw_preco_medio_bebidas,
    vw_medicamento_valido,
    vw_venda_medicamento,
    vw_relatorio_passagens,
    vw_cliente_telefone,
    vw_pacotes_disponiveis,
    vw_produto_estoque_filial,
    vw_fornecedor_produto,
    vw_baixo_estoque,
    vw_auditoria_estoque,
    vw_relatorio_gerencial_vendas;

DROP TABLE IF EXISTS
    Padaria_Pao,
    Padaria_Cliente,
    Padaria_Ingrediente,
    Padaria_Pedido,
    Padaria_Produto,
    Farmacia_Medicamento,
    Farmacia_Venda,
    Agenc_Passagem,
    Agenc_Cliente,
    Agenc_Destino,
    Agenc_Pacote,
    Estoque,
    Produto,
    Filial,
    Fornecedor;

CREATE TABLE Padaria_Pao (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    preco DECIMAL(10,2),
    disponivel TINYINT(1) DEFAULT 1
);

CREATE TABLE Padaria_Cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    telefone VARCHAR(20)
);

CREATE TABLE Padaria_Ingrediente (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome_ingrediente VARCHAR(100),
    quantidade_estoque INT
);

CREATE TABLE Padaria_Pedido (
    id_pedido INT PRIMARY KEY AUTO_INCREMENT,
    data_pedido DATE,
    total DECIMAL(10,2)
);

CREATE TABLE Padaria_Produto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    categoria VARCHAR(50),
    preco DECIMAL(10,2)
);

CREATE TABLE Farmacia_Medicamento (
    id_medicamento INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    validade DATE
);

CREATE TABLE Farmacia_Venda (
    id_venda INT PRIMARY KEY AUTO_INCREMENT,
    id_medicamento INT,
    quantidade INT
);

CREATE TABLE Agenc_Cliente (
    id_cliente INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    telefone VARCHAR(20)
);

CREATE TABLE Agenc_Destino (
    id_destino INT PRIMARY KEY AUTO_INCREMENT,
    nome_destino VARCHAR(100)
);

CREATE TABLE Agenc_Passagem (
    id_passagem INT PRIMARY KEY AUTO_INCREMENT,
    id_cliente INT,
    id_destino INT,
    data_voo DATE,
    preco DECIMAL(10,2)
);

CREATE TABLE Agenc_Pacote (
    id_pacote INT PRIMARY KEY AUTO_INCREMENT,
    destino VARCHAR(100),
    vagas INT
);

CREATE TABLE Fornecedor (
    cnpj_fornecedor VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE Filial (
    cnpj_filial VARCHAR(20) PRIMARY KEY,
    nome VARCHAR(100)
);

CREATE TABLE Produto (
    id INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100),
    preco DECIMAL(10,2),
    cnpj_fornecedor VARCHAR(20)
);

CREATE TABLE Estoque (
    id_estoque INT PRIMARY KEY AUTO_INCREMENT,
    cnpj_filial VARCHAR(20),
    id_produto INT,
    quantidade INT,
    preco DECIMAL(10,2)
);


-- 2. DADOS DE TESTE
INSERT INTO Padaria_Pao
VALUES
    (1, 'Pão Francês', 0.80, 1),
    (2, 'Pão Doce', 1.50, 0);

INSERT INTO Padaria_Cliente
VALUES
    (1, 'João Silva', '99999-1111');

INSERT INTO Padaria_Ingrediente
VALUES
    (1, 'Farinha de Trigo', 50);

INSERT INTO Padaria_Pedido
VALUES
    (1, '2026-11-01', 150.00),
    (2, '2026-11-01', 80.00);

INSERT INTO Padaria_Produto
VALUES
    (1, 'Suco de Laranja', 'Bebidas', 8.00),
    (2, 'Café', 'Bebidas', 4.00);

INSERT INTO Farmacia_Medicamento
VALUES
    (1, 'Dipirona', '2027-12-31'),
    (2, 'Remédio Vencido', '2025-01-01');

INSERT INTO Farmacia_Venda
VALUES
    (1, 1, 5);

INSERT INTO Agenc_Cliente
VALUES
    (1, 'Ana Souza', '98888-2222');

INSERT INTO Agenc_Destino
VALUES
    (1, 'Paris');

INSERT INTO Agenc_Passagem
VALUES
    (1, 1, 1, '2026-12-15', 3500.00);

INSERT INTO Agenc_Pacote
VALUES
    (1, 'Cancún', 10),
    (2, 'Esgotado', 0);

INSERT INTO Fornecedor
VALUES
    ('11.111.111/0001-11', 'Distribuidora Alfa');

INSERT INTO Filial
VALUES
    ('99.111.111/0001-01', 'Filial Centro');

INSERT INTO Produto
VALUES
    (1, 'Refrigerante 2L', 8.50, '11.111.111/0001-11');

INSERT INTO Estoque
VALUES
    (1, '99.111.111/0001-01', 1, 100, 8.50);


-- 3. VIEWS E CONSULTAS (EXERCÍCIOS 1 A 20)
-- Padaria
CREATE VIEW vw_pao_disponivel AS
SELECT nome, preco
FROM Padaria_Pao
WHERE disponivel = 1;

SELECT *
FROM vw_pao_disponivel
ORDER BY nome ASC;

CREATE VIEW vw_cliente_resumo AS
SELECT
    id_cliente AS codigo,
    nome,
    telefone
FROM Padaria_Cliente;

CREATE VIEW vw_ingredientes_estoque AS
SELECT
    nome_ingrediente,
    quantidade_estoque
FROM Padaria_Ingrediente;

CREATE VIEW vw_vendas_por_dia AS
SELECT
    data_pedido,
    SUM(total) AS valor_total_vendido
FROM Padaria_Pedido
GROUP BY data_pedido;

CREATE VIEW vw_preco_medio_bebidas AS
SELECT AVG(preco) AS preco_medio
FROM Padaria_Produto
WHERE categoria = 'Bebidas';


-- Farmácia
CREATE VIEW vw_medicamento_valido AS
SELECT *
FROM Farmacia_Medicamento
WHERE validade > CURDATE();

CREATE VIEW vw_venda_medicamento AS
SELECT
    m.nome AS medicamento,
    v.quantidade
FROM Farmacia_Venda v
INNER JOIN Farmacia_Medicamento m
    ON v.id_medicamento = m.id_medicamento;


-- Agência de Viagens
CREATE VIEW vw_relatorio_passagens AS
SELECT
    p.id_passagem AS codigo_passagem,
    c.nome AS nome_passageiro,
    d.nome_destino AS destino_viagem,
    p.data_voo AS data_partida,
    p.preco AS valor_passagem
FROM Agenc_Passagem p
INNER JOIN Agenc_Cliente c
    ON p.id_cliente = c.id_cliente
INNER JOIN Agenc_Destino d
    ON p.id_destino = d.id_destino;

CREATE VIEW vw_cliente_telefone AS
SELECT
    id_cliente,
    nome,
    telefone
FROM Agenc_Cliente;

CREATE VIEW vw_pacotes_disponiveis AS
SELECT
    id_pacote,
    destino,
    vagas
FROM Agenc_Pacote
WHERE vagas > 0
WITH CHECK OPTION;


-- Empresa
CREATE VIEW vw_produto_estoque_filial AS
SELECT
    p.nome AS produto,
    e.quantidade,
    e.preco,
    f.nome AS filial
FROM Estoque e
INNER JOIN Produto p
    ON e.id_produto = p.id
INNER JOIN Filial f
    ON e.cnpj_filial = f.cnpj_filial;

CREATE VIEW vw_fornecedor_produto AS
SELECT
    f.nome AS fornecedor,
    p.nome AS produto
FROM Fornecedor f
INNER JOIN Produto p
    ON f.cnpj_fornecedor = p.cnpj_fornecedor;

SELECT table_name AS nome_visao
FROM information_schema.views
WHERE table_schema = DATABASE();

SHOW CREATE VIEW vw_fornecedor_produto;

CREATE OR REPLACE VIEW vw_fornecedor_produto AS
SELECT
    f.nome AS fornecedor,
    p.nome AS produto,
    p.preco
FROM Fornecedor f
INNER JOIN Produto p
    ON f.cnpj_fornecedor = p.cnpj_fornecedor;

CREATE VIEW vw_baixo_estoque AS
SELECT *
FROM Estoque
WHERE quantidade < 20;

DROP VIEW IF EXISTS vw_baixo_estoque;

CREATE VIEW vw_auditoria_estoque AS
SELECT
    cnpj_filial,
    COUNT(id_produto) AS total_produtos,
    SUM(quantidade) AS total_itens
FROM Estoque
GROUP BY cnpj_filial;

CREATE VIEW vw_relatorio_gerencial_vendas AS
SELECT
    p.nome AS produto,
    SUM(e.quantidade) AS total_unidades_estoque,
    SUM(e.quantidade * e.preco) AS valor_total_potencial
FROM Produto p
INNER JOIN Estoque e
    ON p.id = e.id_produto
GROUP BY p.id, p.nome;