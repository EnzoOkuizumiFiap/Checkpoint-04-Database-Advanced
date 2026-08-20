/* QUESTÃO 02 — Function: Calcular Total do Pedido (10 pontos)

Implemente no body de pkg_pedidos a function: calcular_total_pedido(p_cod_pedido IN NUMBER) RETURN NUMBER que:
    
    a) Consulte a tabela ITEM_PEDIDO somando: (QTD_ITEM * VAL_UNITARIO_ITEM) - VAL_DESCONTO_ITEM para todos os itens do pedido informado.
    b) Retorne o total calculado.
    c) Se o pedido não possuir itens (NO_DATA_FOUND ou soma NULL), retorne 0.
    d) Atualize a coluna VAL_TOTAL_PEDIDO na tabela PEDIDO com o valor calculado antes de retornar.

*/

CREATE OR REPLACE PACKAGE BODY pkg_pedidos AS 

    FUNCTION calcular_total_pedido(p_cod_pedido IN NUMBER) RETURN NUMBER IS v_total NUMBER := 0;
    BEGIN
        -- Calculando o total dos itens do pedido
        select NVL(SUM((QTD_ITEM * VAL_DESCONTO_ITEM) - VAL_DESCONTO_ITEM), 0) into v_total from ITEM_PEDIDO where cod_pedido = p_cod_pedido;

        -- Atualizando os pedidos com o valor calculado
        update PEDIDO set VAL_TOTAL_PEDIDO = v_total where cod_pedido = p_cod_pedido;

        -- Retornando v_total
        return v_total;
    
    EXCEPTION
        when NO_DATA_FOUND THEN
            return 0;

    END calcular_total_pedido;
END pkg_pedidos;