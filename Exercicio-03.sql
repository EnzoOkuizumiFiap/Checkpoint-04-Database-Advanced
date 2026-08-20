/* QUESTÃO 03 — Procedure com Exceção: Buscar Pedido (10 pontos)
Implemente a procedure: buscar_pedido(p_cod_pedido IN NUMBER) no body de pkg_pedidos que:
    a) Faça SELECT INTO nas tabelas PEDIDO e CLIENTE (JOIN) para recuperar:
       COD_PEDIDO, NOM_CLIENTE, DAT_PEDIDO, VAL_TOTAL_PEDIDO
    b) Exiba os dados com DBMS_OUTPUT.PUT_LINE.
    c) Dispare a exceção pedido_nao_encontrado caso o pedido não exista — use RAISE.
    d) Dispare a exceção cliente_inativo se o campo STA_ATIVO da tabela CLIENTE for diferente de 'S'.
    e) Armazene o COD_PEDIDO encontrado na variável pública g_ultimo_pedido_processado.

OBS: este arquivo é CUMULATIVO em relação à Questão 2 — o body do package é um único
objeto no Oracle, então cada CREATE OR REPLACE PACKAGE BODY substitui o anterior por
completo. Por isso a function calcular_total_pedido (Questão 2) é repetida aqui junto
com a nova procedure buscar_pedido, garantindo que nada seja perdido ao compilar.
*/

CREATE OR REPLACE PACKAGE BODY pkg_pedidos AS

    FUNCTION calcular_total_pedido(p_cod_pedido IN NUMBER) RETURN NUMBER IS
        v_total NUMBER := 0;
    BEGIN
        SELECT NVL(SUM((QTD_ITEM * VAL_UNITARIO_ITEM) - VAL_DESCONTO_ITEM), 0)
          INTO v_total
          FROM ITEM_PEDIDO
         WHERE COD_PEDIDO = p_cod_pedido;

        UPDATE PEDIDO
           SET VAL_TOTAL_PEDIDO = v_total
         WHERE COD_PEDIDO = p_cod_pedido;

        RETURN v_total;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RETURN 0;
    END calcular_total_pedido;


    -- QUESTÃO 03
    PROCEDURE buscar_pedido(p_cod_pedido IN NUMBER) IS
        v_cod_pedido   PEDIDO.COD_PEDIDO%TYPE;
        v_nom_cliente  CLIENTE.NOM_CLIENTE%TYPE;
        v_dat_pedido   PEDIDO.DAT_PEDIDO%TYPE;
        v_val_total    PEDIDO.VAL_TOTAL_PEDIDO%TYPE;
        v_sta_ativo    CLIENTE.STA_ATIVO%TYPE;
    BEGIN
        -- Busca o pedido e o cliente relacionado (JOIN)
        SELECT p.COD_PEDIDO, c.NOM_CLIENTE, p.DAT_PEDIDO, p.VAL_TOTAL_PEDIDO, c.STA_ATIVO
          INTO v_cod_pedido, v_nom_cliente, v_dat_pedido, v_val_total, v_sta_ativo
          FROM PEDIDO p
          JOIN CLIENTE c ON c.COD_CLIENTE = p.COD_CLIENTE
         WHERE p.COD_PEDIDO = p_cod_pedido;

        -- Valida se o cliente está ativo
        IF v_sta_ativo <> 'S' THEN
            RAISE cliente_inativo;
        END IF;

        -- Exibe os dados do pedido
        DBMS_OUTPUT.PUT_LINE('Pedido.......: ' || v_cod_pedido);
        DBMS_OUTPUT.PUT_LINE('Cliente......: ' || v_nom_cliente);
        DBMS_OUTPUT.PUT_LINE('Data pedido..: ' || TO_CHAR(v_dat_pedido, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('Valor total..: ' || v_val_total);

        -- Armazena na variável pública do pacote
        g_ultimo_pedido_processado := v_cod_pedido;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE pedido_nao_encontrado;
        WHEN cliente_inativo THEN
            RAISE;
    END buscar_pedido;

END pkg_pedidos;
/