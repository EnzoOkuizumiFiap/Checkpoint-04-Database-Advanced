/*
QUESTÃO 07 — Cursor no Package: Itens de um Pedido (10 pontos)

Adicione ao body do package pkg_pedidos a procedure:

listar_itens_pedido(p_cod_pedido IN NUMBER)

que:

a) Declare um cursor explícito c_itens que faça JOIN entre
ITEM_PEDIDO e PRODUTO trazendo:

- COD_ITEM_PEDIDO
- NOM_PRODUTO
- QTD_ITEM
- VAL_UNITARIO_ITEM
- VAL_DESCONTO_ITEM
- Valor líquido calculado:
  (QTD_ITEM * VAL_UNITARIO_ITEM - VAL_DESCONTO_ITEM)

b) Percorra o cursor com um LOOP e exiba cada linha
com DBMS_OUTPUT.PUT_LINE.

c) Ao final do loop, exiba o total geral dos itens.

d) Se o cursor não retornar nenhum registro, exiba:
Pedido sem itens cadastrados.

e) Dispare pedido_nao_encontrado.
*/


PROCEDURE listar_itens_pedido(p_cod_pedido IN NUMBER) IS

    CURSOR c_itens IS
        SELECT
            ip.COD_ITEM_PEDIDO,
            p.NOM_PRODUTO,
            ip.QTD_ITEM,
            ip.VAL_UNITARIO_ITEM,
            ip.VAL_DESCONTO_ITEM,
            (ip.QTD_ITEM * ip.VAL_UNITARIO_ITEM - ip.VAL_DESCONTO_ITEM) AS VALOR_LIQUIDO
        FROM ITEM_PEDIDO ip
        JOIN PRODUTO p
            ON p.COD_PRODUTO = ip.COD_PRODUTO
        WHERE ip.COD_PEDIDO = p_cod_pedido;

    v_total NUMBER := 0;
    v_tem_itens BOOLEAN := FALSE;

BEGIN

    FOR r_item IN c_itens LOOP

        v_tem_itens := TRUE;

        DBMS_OUTPUT.PUT_LINE('Código do item: ' || r_item.COD_ITEM_PEDIDO);
        DBMS_OUTPUT.PUT_LINE('Produto: ' || r_item.NOM_PRODUTO);
        DBMS_OUTPUT.PUT_LINE('Quantidade: ' || r_item.QTD_ITEM);
        DBMS_OUTPUT.PUT_LINE('Valor unitário: R$ ' || r_item.VAL_UNITARIO_ITEM);
        DBMS_OUTPUT.PUT_LINE('Desconto: R$ ' || r_item.VAL_DESCONTO_ITEM);
        DBMS_OUTPUT.PUT_LINE('Valor líquido: R$ ' || r_item.VALOR_LIQUIDO);
        DBMS_OUTPUT.PUT_LINE('-----------------------------');

        v_total := v_total + r_item.VALOR_LIQUIDO;

    END LOOP;

    IF v_tem_itens = FALSE THEN
        DBMS_OUTPUT.PUT_LINE('Pedido sem itens cadastrados.');
        RAISE pedido_nao_encontrado;
    END IF;

    DBMS_OUTPUT.PUT_LINE('Total geral dos itens: R$ ' || v_total);

END listar_itens_pedido;