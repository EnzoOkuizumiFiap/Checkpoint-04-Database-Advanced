/* QUESTÃO 08 — Procedure com Parâmetros IN / OUT / IN OUT (10 pontos)
Crie no body de pkg_pedidos a procedure:
PROCEDURE calcular_desconto_pedido(
    p_cod_pedido     IN NUMBER,
    p_percentual     IN NUMBER,
    p_valor_desconto OUT NUMBER,
    p_novo_total     OUT NUMBER
);
A procedure deve:
    a) Buscar o VAL_TOTAL_PEDIDO atual do pedido informado.
    b) Validar que p_percentual está entre 0 e c_desconto_maximo (constante da spec). Se ultrapassar, disparar:
       RAISE_APPLICATION_ERROR(-20401, 'Desconto superior ao maximo permitido: ' || c_desconto_maximo || '%');
    c) Calcular o valor do desconto:
       p_valor_desconto := VAL_TOTAL_PEDIDO * (p_percentual / 100);
    d) Calcular o novo total:
       p_novo_total := VAL_TOTAL_PEDIDO - p_valor_desconto;
    e) Atualizar os campos VAL_DESCONTO e VAL_TOTAL_PEDIDO na tabela PEDIDO.

OBS: este arquivo é CUMULATIVO em relação às questões anteriores do package pkg_pedidos — o body do package é um único
objeto no Oracle, então cada CREATE OR REPLACE PACKAGE BODY substitui o anterior por completo. Por isso todas as
procedures e functions anteriores (Questões 02, 03, 04 e 07) são mantidas aqui junto com a nova procedure
calcular_desconto_pedido, garantindo que nada seja perdido ao compilar.
*/

PROCEDURE calcular_desconto_pedido (
    p_cod_pedido     IN NUMBER,
    p_percentual     IN NUMBER,
    p_valor_desconto OUT NUMBER,
    p_novo_total     OUT NUMBER
) AS
    v_total_atual NUMBER;
BEGIN
    -- Busca o VAL_TOTAL_PEDIDO atual do pedido informado
    SELECT val_total_pedido
      INTO v_total_atual
      FROM pedido
     WHERE cod_pedido = p_cod_pedido;

    -- Validação do percentual do desconto do pedido
    IF p_percentual < 0 OR p_percentual > c_desconto_maximo THEN
        RAISE_APPLICATION_ERROR(
            -20401,
            'Desconto superior ao maximo permitido: ' || c_desconto_maximo || '%'
        );
    END IF;

    -- Cálculos do desconto e do novo total
    p_valor_desconto := v_total_atual * (p_percentual / 100);
    p_novo_total := v_total_atual - p_valor_desconto;

    -- Atualiza o pedido
    UPDATE pedido
       SET val_desconto     = p_valor_desconto,
           val_total_pedido = p_novo_total
     WHERE cod_pedido = p_cod_pedido;
END calcular_desconto_pedido;