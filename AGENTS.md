# Diretrizes do Agente — Checkpoint 04 (Database Advanced)

Este repositório contém exercícios e checkpoints da disciplina **Mastering Relational and Non-Relational Database**, focados em **Oracle PL/SQL** (Packages, Procedures, Functions, Cursors, Exceptions e Transações).

---

## 🎯 Objetivo Principal

Ao gerar soluções para as questões, o modelo deve produzir código **funcional, limpo e didático**, voltado para estudantes que ainda estão consolidando seus conhecimentos em SQL e PL/SQL.

---

## 📝 Diretrizes de Comentários no Código

1. **Objetividade e Clareza**:
   - Faça comentários pontuais, diretos e sem prolixidade (máximo de 1 a 2 linhas por bloco relevante).
   - Evite textos longos que poluem o código ou atrapalham a leitura.

2. **O que comentar**:
   - **Estruturas de Pacotes**: Diferença prática entre o que fica na `SPEC` (público) e no `BODY` (implementação/privado).
   - **Comandos DML e Consultas**: Explicar a finalidade de `SELECT ... INTO`, `JOIN`, funções agregadoras e `NVL/COALESCE`.
   - **Parâmetros e Variáveis**: Destacar o uso de `IN`, `OUT`, `IN OUT`, variáveis globais (`g_`) e constantes (`c_`).
   - **Controle de Transação**: Indicar o motivo do `COMMIT` ou controle transacional.
   - **Tratamento de Exceções**:
     - Explicar quando usar `RAISE` (exceções declaradas) vs `RAISE_APPLICATION_ERROR` (erros customizados com código negativo).
     - Explicar o papel de `PRAGMA EXCEPTION_INIT` e blocos `WHEN OTHERS`.
   - **Cursores**: Comentar brevemente a declaração do cursor, abertura/iteração (`LOOP` ou `FOR r IN`) e verificação de dados.

3. **Exemplo de Comentário Ideal no Código**:
   ```sql
   -- Verifica se o pedido existe e recupera o status atual
   SELECT sta_ativo INTO v_status
     FROM cliente
    WHERE cod_cliente = p_cod_cliente;

   -- Se cliente estiver inativo, dispara exceção pública do package
   IF v_status <> 'S' THEN
      RAISE cliente_inativo;
   END IF;
   ```

---

## 💡 Diretrizes de Explicação Fora do Código (Na Resposta)

Após apresentar o código de cada questão:

1. **Síntese Rápida (1 a 2 frases)**: O que a rotina resolve.
2. **"Dicionário PL/SQL" (Tópicos curtos)**:
   - Explicar apenas os comandos e conceitos novos ou mais difíceis usados naquela questão específica.
   - Exemplo:
     - `PRAGMA EXCEPTION_INIT`: Associa um nome de exceção a um código de erro numérico do Oracle (ex: `-20301`).
     - `SELECT INTO`: Armazena o resultado de uma consulta em variáveis PL/SQL (requer que retorne exatamente 1 linha).
     - `RAISE_APPLICATION_ERROR`: Interrompe a execução exibindo uma mensagem personalizada e um código de erro entre -20000 e -20999.

---

## 🏷️ Padrões e Boas Práticas de Código

- **Palavras-chave em MAIÚSCULAS**: `CREATE OR REPLACE`, `PACKAGE`, `PROCEDURE`, `FUNCTION`, `BEGIN`, `EXCEPTION`, `END`, etc.
- **Convenção de Nomenclatura**:
  - `p_` : Parâmetros (ex: `p_cod_pedido`)
  - `v_` : Variáveis locais (ex: `v_total`)
  - `g_` : Variáveis globais/de pacote (ex: `g_ultimo_pedido_processado`)
  - `c_` : Constantes ou Cursores (ex: `c_desconto_maximo`, `c_itens`)
  - `e_` : Exceções personalizadas (ex: `pedido_nao_encontrado`)
- **Robustez**: Sempre prever cenários nulos (`NVL`), ausência de dados (`NO_DATA_FOUND`) e fechamento correto de cursores.
