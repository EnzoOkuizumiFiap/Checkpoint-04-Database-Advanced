/* QUESTÃO 04 — Procedure: Cancelar Pedido com Histórico (12 pontos)
Implemente a procedure: cancelar_pedido(p_cod_pedido IN NUMBER, p_motivo IN VARCHAR2) que:
    a) Verifique se o pedido existe e se DAT_CANCELAMENTO já está preenchida.
       Se já estiver cancelado, dispare: RAISE_APPLICATION_ERROR(-20201,'Pedido ja cancelado')
    b) Atualize: DAT_CANCELAMENTO = SYSDATE na tabela PEDIDO.
    c) Insira um registro na tabela HISTORICO_PEDIDO com todos os dados do pedido cancelado
       (SEQ_HISTORICO_PEDIDO gerado pela sequência seq_historico.NEXTVAL).
    d) Trate qualquer erro inesperado com WHEN OTHERS, exibindo SQLERRM e relançando com RAISE.
    e) Utilize COMMIT ao final caso tudo ocorra com sucesso.

OBS: este é o arquivo FINAL e CUMULATIVO — contém as três rotinas do pacote
(calcular_total_pedido, buscar_pedido e cancelar_pedido) dentro do mesmo
CREATE OR REPLACE PACKAGE BODY. É este o body que efetivamente fica valendo
no banco após a execução, já que cada CREATE OR REPLACE PACKAGE BODY
substitui integralmente a versão anterior do objeto.

Pré-requisito: a sequência seq_historico precisa existir antes de compilar
este body. Caso ainda não tenha sido criada:
    CREATE SEQUENCE seq_historico START WITH 1 INCREMENT BY 1 NOCACHE NOCYCLE;
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


    PROCEDURE buscar_pedido(p_cod_pedido IN NUMBER) IS
        v_cod_pedido   PEDIDO.COD_PEDIDO%TYPE;
        v_nom_cliente  CLIENTE.NOM_CLIENTE%TYPE;
        v_dat_pedido   PEDIDO.DAT_PEDIDO%TYPE;
        v_val_total    PEDIDO.VAL_TOTAL_PEDIDO%TYPE;
        v_sta_ativo    CLIENTE.STA_ATIVO%TYPE;
    BEGIN
        SELECT p.COD_PEDIDO, c.NOM_CLIENTE, p.DAT_PEDIDO, p.VAL_TOTAL_PEDIDO, c.STA_ATIVO
          INTO v_cod_pedido, v_nom_cliente, v_dat_pedido, v_val_total, v_sta_ativo
          FROM PEDIDO p
          JOIN CLIENTE c ON c.COD_CLIENTE = p.COD_CLIENTE
         WHERE p.COD_PEDIDO = p_cod_pedido;

        IF v_sta_ativo <> 'S' THEN
            RAISE cliente_inativo;
        END IF;

        DBMS_OUTPUT.PUT_LINE('Pedido.......: ' || v_cod_pedido);
        DBMS_OUTPUT.PUT_LINE('Cliente......: ' || v_nom_cliente);
        DBMS_OUTPUT.PUT_LINE('Data pedido..: ' || TO_CHAR(v_dat_pedido, 'DD/MM/YYYY'));
        DBMS_OUTPUT.PUT_LINE('Valor total..: ' || v_val_total);

        g_ultimo_pedido_processado := v_cod_pedido;

    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE pedido_nao_encontrado;
        WHEN cliente_inativo THEN
            RAISE;
    END buscar_pedido;


    -- QUESTÃO 04
    PROCEDURE cancelar_pedido(
        p_cod_pedido IN NUMBER,
        p_motivo     IN VARCHAR2
    ) IS
        v_pedido PEDIDO%ROWTYPE;
    BEGIN
        -- Verifica se o pedido existe
        BEGIN
            SELECT * INTO v_pedido
              FROM PEDIDO
             WHERE COD_PEDIDO = p_cod_pedido;
        EXCEPTION
            WHEN NO_DATA_FOUND THEN
                RAISE pedido_nao_encontrado;
        END;

        -- Verifica se já foi cancelado
        IF v_pedido.DAT_CANCELAMENTO IS NOT NULL THEN
            RAISE_APPLICATION_ERROR(-20201, 'Pedido ja cancelado');
        END IF;

        -- Atualiza a data de cancelamento
        UPDATE PEDIDO
           SET DAT_CANCELAMENTO = SYSDATE
         WHERE COD_PEDIDO = p_cod_pedido;

        -- Grava o histórico com os dados do pedido cancelado
        INSERT INTO HISTORICO_PEDIDO (
            SEQ_HISTORICO_PEDIDO,
            COD_PEDIDO,
            COD_CLIENTE,
            DAT_PEDIDO,
            DAT_CANCELAMENTO,
            DAT_ENTREGA,
            VAL_TOTAL_PEDIDO,
            VAL_DESCONTO,
            SEQ_ENDERECO_CLIENTE,
            COD_VENDEDOR
        ) VALUES (
            seq_historico.NEXTVAL,
            v_pedido.COD_PEDIDO,
            v_pedido.COD_CLIENTE,
            v_pedido.DAT_PEDIDO,
            SYSDATE,
            v_pedido.DAT_ENTREGA,
            v_pedido.VAL_TOTAL_PEDIDO,
            v_pedido.VAL_DESCONTO,
            v_pedido.SEQ_ENDERECO_CLIENTE,
            v_pedido.COD_VENDEDOR
        );

        DBMS_OUTPUT.PUT_LINE('Motivo do cancelamento: ' || p_motivo);

        COMMIT;

    EXCEPTION
        WHEN pedido_nao_encontrado THEN
            RAISE;
        WHEN OTHERS THEN
            DBMS_OUTPUT.PUT_LINE('Erro ao cancelar pedido: ' || SQLERRM);
            RAISE;
    END cancelar_pedido;

END pkg_pedidos;
/