# Checkpoint 04 — Database Advanced

**Disciplina:** Mastering Relational and Non-Relational Database  
**Pontuação Total:** 74 pontos (Questões 01 a 08)

---

## QUESTÃO 01 — Especificação do Package (8 pontos)

Crie a **especificação** (`SPEC`) do package `pkg_pedidos` contendo os seguintes elementos:

- **a)** Constante `c_desconto_maximo` do tipo `NUMBER` com valor `50`.
- **b)** Variável pública `g_ultimo_pedido_processado` do tipo `NUMBER`.
- **c)** Exceção pública `pedido_nao_encontrado`.
- **d)** Exceção pública `cliente_inativo`.
- **e)** Procedure `buscar_pedido(p_cod_pedido IN NUMBER)`.
- **f)** Function `calcular_total_pedido(p_cod_pedido IN NUMBER) RETURN NUMBER`.
- **g)** Procedure `cancelar_pedido(p_cod_pedido IN NUMBER, p_motivo IN VARCHAR2)`.

---

## QUESTÃO 02 — Function: Calcular Total do Pedido (10 pontos)

Implemente no `BODY` de `pkg_pedidos` a function:

```sql
FUNCTION calcular_total_pedido(p_cod_pedido IN NUMBER) RETURN NUMBER;
```

### Regras de Negócio:
- **a)** Consultar a tabela `ITEM_PEDIDO` somando:
  ```sql
  (QTD_ITEM * VAL_UNITARIO_ITEM) - VAL_DESCONTO_ITEM
  ```
  para todos os itens do pedido informado.
- **b)** Retornar o total calculado.
- **c)** Se o pedido não possuir itens (`NO_DATA_FOUND` ou soma `NULL`), retornar `0`.
- **d)** Atualizar a coluna `VAL_TOTAL_PEDIDO` na tabela `PEDIDO` com o valor calculado antes de retornar.

---

## QUESTÃO 03 — Procedure com Exceção: Buscar Pedido (10 pontos)

Implemente no `BODY` de `pkg_pedidos` a procedure:

```sql
PROCEDURE buscar_pedido(p_cod_pedido IN NUMBER);
```

### Regras de Negócio:
- **a)** Fazer `SELECT INTO` nas tabelas `PEDIDO` e `CLIENTE` (`JOIN`) para recuperar:
  - `COD_PEDIDO`
  - `NOM_CLIENTE`
  - `DAT_PEDIDO`
  - `VAL_TOTAL_PEDIDO`
- **b)** Exibir os dados com `DBMS_OUTPUT.PUT_LINE`.
- **c)** Disparar a exceção `pedido_nao_encontrado` caso o pedido não exista (utilize `RAISE`).
- **d)** Disparar a exceção `cliente_inativo` se o campo `STA_ATIVO` da tabela `CLIENTE` for diferente de `'S'`.
- **e)** Armazenar o `COD_PEDIDO` encontrado na variável pública `g_ultimo_pedido_processado`.

---

## QUESTÃO 04 — Procedure: Cancelar Pedido com Histórico (12 pontos)

Implemente no `BODY` de `pkg_pedidos` a procedure:

```sql
PROCEDURE cancelar_pedido(
    p_cod_pedido IN NUMBER,
    p_motivo     IN VARCHAR2
);
```

### Regras de Negócio:
- **a)** Verificar se o pedido existe e se `DAT_CANCELAMENTO` já está preenchida. Se já estiver cancelado, disparar:
  ```sql
  RAISE_APPLICATION_ERROR(-20201, 'Pedido ja cancelado');
  ```
- **b)** Atualizar `DAT_CANCELAMENTO = SYSDATE` na tabela `PEDIDO`.
- **c)** Inserir um registro na tabela `HISTORICO_PEDIDO` com todos os dados do pedido cancelado (`SEQ_HISTORICO_PEDIDO` gerado via `seq_historico.NEXTVAL`).
- **d)** Tratar qualquer erro inesperado com `WHEN OTHERS`, exibindo `SQLERRM` e relançando com `RAISE`.
- **e)** Utilizar `COMMIT` ao final caso tudo ocorra com sucesso.

---

## QUESTÃO 05 — Variável de Sessão: Contador de Operações (8 pontos)

Crie um package separado chamado `pkg_auditoria` contendo:

- **a)** Variável privada `g_total_pedidos_cancelados NUMBER := 0` no `BODY`.
- **b)** Variável privada `g_total_pedidos_consultados NUMBER := 0` no `BODY`.
- **c)** Procedure `registrar_cancelamento` que incrementa `g_total_pedidos_cancelados`.
- **d)** Procedure `registrar_consulta` que incrementa `g_total_pedidos_consultados`.
- **e)** Function `obter_resumo_sessao RETURN VARCHAR2` que retorne uma string no formato:
  ```text
  Cancelamentos: X | Consultas: Y
  ```

---

## QUESTÃO 06 — Package de Estoque: Baixa e Registro de Movimento (12 pontos)

Crie o package `pkg_estoque` com especificação e body contendo:

- **a)** Exceção `estoque_insuficiente` com `PRAGMA EXCEPTION_INIT` associado ao código `-20301`.
- **b)** Function:
  ```sql
  FUNCTION obter_saldo_estoque(
      p_cod_produto IN NUMBER,
      p_cod_estoque IN NUMBER
  ) RETURN NUMBER;
  ```
  Retorna a soma de `QTD_ESTOQUE` da tabela `ESTOQUE_PRODUTO` para o produto/estoque informado. Retorne `0` se não encontrar.
- **c)** Procedure:
  ```sql
  PROCEDURE dar_baixa_estoque(
      p_cod_produto IN NUMBER,
      p_cod_estoque IN NUMBER,
      p_quantidade  IN NUMBER
  );
  ```
  Com o seguinte fluxo:
  - **c.1)** Verificar o saldo usando `obter_saldo_estoque`. Se insuficiente, disparar:
    ```sql
    RAISE_APPLICATION_ERROR(
        -20301,
        'Saldo insuficiente para o produto ' || p_cod_produto
    );
    ```
  - **c.2)** Inserir registro em `MOVIMENTO_ESTOQUE` (`SEQ_MOVIMENTO_ESTOQUE` via `seq_movimento.NEXTVAL`, tipo saída = `2`).
  - **c.3)** Atualizar `QTD_ESTOQUE` na tabela `ESTOQUE_PRODUTO` subtraindo a quantidade.

---

## QUESTÃO 07 — Cursor no Package: Itens de um Pedido (10 pontos)

Adicione ao `BODY` do package `pkg_pedidos` a procedure:

```sql
PROCEDURE listar_itens_pedido(p_cod_pedido IN NUMBER);
```

### Regras de Negócio:
- **a)** Declarar um cursor explícito `c_itens` que faça `JOIN` entre `ITEM_PEDIDO` e `PRODUTO` trazendo:
  - `COD_ITEM_PEDIDO`
  - `NOM_PRODUTO`
  - `QTD_ITEM`
  - `VAL_UNITARIO_ITEM`
  - `VAL_DESCONTO_ITEM`
  - Valor líquido calculado:
    ```sql
    (QTD_ITEM * VAL_UNITARIO_ITEM - VAL_DESCONTO_ITEM)
    ```
- **b)** Percorrer o cursor com um `LOOP` e exibir cada linha com `DBMS_OUTPUT.PUT_LINE`.
- **c)** Ao final do loop, exibir o total geral dos itens.
- **d)** Se o cursor não retornar nenhum registro, exibir a mensagem `"Pedido sem itens cadastrados."` e disparar a exceção `pedido_nao_encontrado`.

---

## QUESTÃO 08 — Procedure com Parâmetros IN / OUT / IN OUT (10 pontos)

Crie no `BODY` de `pkg_pedidos` a procedure:

```sql
PROCEDURE calcular_desconto_pedido(
    p_cod_pedido     IN  NUMBER,
    p_percentual     IN  NUMBER,
    p_valor_desconto OUT NUMBER,
    p_novo_total     OUT NUMBER
);
```

### Regras de Negócio:
- **a)** Buscar o `VAL_TOTAL_PEDIDO` atual do pedido informado.
- **b)** Validar se `p_percentual` está entre `0` e `c_desconto_maximo` (constante da spec). Se ultrapassar, disparar:
  ```sql
  RAISE_APPLICATION_ERROR(
      -20401,
      'Desconto superior ao maximo permitido: ' || c_desconto_maximo || '%'
  );
  ```
- **c)** Calcular o valor do desconto:
  ```sql
  p_valor_desconto := VAL_TOTAL_PEDIDO * (p_percentual / 100);
  ```
- **d)** Calcular o novo total:
  ```sql
  p_novo_total := VAL_TOTAL_PEDIDO - p_valor_desconto;
  ```
- **e)** Atualizar os campos `VAL_DESCONTO` e `VAL_TOTAL_PEDIDO` na tabela `PEDIDO`.
