/* QUESTÃO 01 — Especificação do Package (8 pontos)

Crie a ESPECIFICAÇÃO do package pkg_pedidos contendo os seguintes elementos:

    a) Constante c_desconto_maximo do tipo NUMBER com valor 50.
    b) Variável pública g_ultimo_pedido_processado do tipo NUMBER.
    c) Exceção pública pedido_nao_encontrado.
    d) Exceção pública cliente_inativo.
    e) Procedure buscar_pedido(p_cod_pedido IN NUMBER).
    f) Function calcular_total_pedido(p_cod_pedido IN NUMBER) RETURN NUMBER.
    g) Procedure cancelar_pedido(p_cod_pedido IN NUMBER, p_motivo IN VARCHAR2).
*/

CREATE OR REPLACE PACKAGE pkg_pedidos AS
    -- Constante pública: fixa em 50 para limitar o desconto máximo permitido
    c_desconto_maximo CONSTANT NUMBER := 50;
    
    -- Variável pública de sessão: armazena o código do último pedido consultado
    g_ultimo_pedido_processado NUMBER;
    
    -- Exceções públicas: disparadas pelo pacote e tratáveis externamente
    pedido_nao_encontrado EXCEPTION;
    cliente_inativo EXCEPTION;
    
    -- Assinatura de procedures e functions públicas (interface do pacote)
    PROCEDURE buscar_pedido(p_cod_pedido IN NUMBER);
    FUNCTION calcular_total_pedido(p_cod_pedido IN NUMBER) RETURN NUMBER;
    PROCEDURE cancelar_pedido(p_cod_pedido IN NUMBER, p_motivo IN VARCHAR2);
    
END pkg_pedidos;